// Unit tests for the local-only auth flow: signup stores a hashed
// credential, login validates it, wrong passwords are rejected, and logout
// clears the session flag without deleting the stored account.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxfiler_ng/data/auth/auth_repository.dart';

void main() {
  late AuthRepository auth;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    auth = AuthRepository(prefs: await SharedPreferences.getInstance());
  });

  test('signUp stores an account and logs the user in without storing the plaintext password', () async {
    expect(await auth.hasAccount(), isFalse);

    await auth.signUp(email: 'Freelancer@Example.com', password: 'super-secret');

    expect(await auth.hasAccount(), isTrue);
    expect(await auth.isLoggedIn(), isTrue);

    final prefs = await SharedPreferences.getInstance();
    final storedValues = prefs.getKeys().map((k) => prefs.get(k)).toList();
    expect(storedValues, isNot(contains('super-secret')));
  });

  test('logIn succeeds with the correct email and password (case-insensitive email)', () async {
    await auth.signUp(email: 'user@taxfiler.ng', password: 'correcthorse');
    await auth.logOut();

    final ok = await auth.logIn(email: 'USER@taxfiler.ng', password: 'correcthorse');

    expect(ok, isTrue);
    expect(await auth.isLoggedIn(), isTrue);
  });

  test('logIn rejects an incorrect password', () async {
    await auth.signUp(email: 'user@taxfiler.ng', password: 'correcthorse');
    await auth.logOut();

    final ok = await auth.logIn(email: 'user@taxfiler.ng', password: 'wrong-password');

    expect(ok, isFalse);
    expect(await auth.isLoggedIn(), isFalse);
  });

  test('logOut clears the logged-in flag but keeps the account so the user can log back in', () async {
    await auth.signUp(email: 'user@taxfiler.ng', password: 'correcthorse');
    expect(await auth.isLoggedIn(), isTrue);

    await auth.logOut();

    expect(await auth.isLoggedIn(), isFalse);
    expect(await auth.hasAccount(), isTrue);

    final ok = await auth.logIn(email: 'user@taxfiler.ng', password: 'correcthorse');
    expect(ok, isTrue);
  });

  test('continueAsGuest logs the user in without creating an account', () async {
    await auth.continueAsGuest();

    expect(await auth.isLoggedIn(), isTrue);
    expect(await auth.isGuest(), isTrue);
    expect(await auth.hasAccount(), isFalse);
  });
}
