import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-only authentication.
///
/// TaxFiler NG has no backend, so credentials never leave the device: a
/// salted SHA-256 hash of the password is stored (never the plaintext), and
/// a simple "logged in" flag lets returning users skip straight past the
/// login screen. This is intentionally lightweight (a PIN-lock style guard
/// for a single-user device), not a substitute for real server-side auth.
class AuthRepository {
  AuthRepository({SharedPreferences? prefs}) : _prefsOverride = prefs;

  final SharedPreferences? _prefsOverride;

  static const _keyEmail = 'auth_email';
  static const _keyPasswordHash = 'auth_password_hash';
  static const _keyLoggedIn = 'auth_logged_in';
  static const _keyGuest = 'auth_is_guest';

  Future<SharedPreferences> _prefs() async => _prefsOverride ?? await SharedPreferences.getInstance();

  /// Whether a local account has already been created on this device.
  Future<bool> hasAccount() async {
    final prefs = await _prefs();
    return prefs.containsKey(_keyEmail) && prefs.containsKey(_keyPasswordHash);
  }

  /// Whether the current session should skip auth and go straight in.
  Future<bool> isLoggedIn() async {
    final prefs = await _prefs();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  Future<bool> isGuest() async {
    final prefs = await _prefs();
    return prefs.getBool(_keyGuest) ?? false;
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _hashPassword(String email, String password) {
    final bytes = utf8.encode('taxfiler_ng::$email::$password');
    return sha256.convert(bytes).toString();
  }

  /// Creates the local account, storing only a hashed credential, and marks
  /// the user as logged in.
  Future<void> signUp({required String email, required String password}) async {
    final prefs = await _prefs();
    final normalized = _normalizeEmail(email);
    await prefs.setString(_keyEmail, normalized);
    await prefs.setString(_keyPasswordHash, _hashPassword(normalized, password));
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setBool(_keyGuest, false);
  }

  /// Validates the given credentials against the stored hash. Returns true
  /// and marks the session logged in on success.
  Future<bool> logIn({required String email, required String password}) async {
    final prefs = await _prefs();
    final storedEmail = prefs.getString(_keyEmail);
    final storedHash = prefs.getString(_keyPasswordHash);
    if (storedEmail == null || storedHash == null) return false;

    final normalized = _normalizeEmail(email);
    if (storedEmail != normalized) return false;

    final candidateHash = _hashPassword(normalized, password);
    if (candidateHash != storedHash) return false;

    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setBool(_keyGuest, false);
    return true;
  }

  /// Enters the app without creating an account, for people who just want
  /// to try it out. Guest data still stays entirely on-device.
  Future<void> continueAsGuest() async {
    final prefs = await _prefs();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setBool(_keyGuest, true);
  }

  /// Clears the logged-in flag. The stored account (if any) is preserved so
  /// the user can log back in.
  Future<void> logOut() async {
    final prefs = await _prefs();
    await prefs.setBool(_keyLoggedIn, false);
    await prefs.setBool(_keyGuest, false);
  }
}
