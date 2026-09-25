# TaxFiler NG 🧾

Nigerian freelancer and self-employed tax self-assessment app. Built for the Nigeria Tax Act 2025 — computes PIT liability, applies statutory deductions, generates a ready-to-file assessment, and exports a PDF return.

## Features
- Add income in NGN, USD, GBP, EUR (auto-converts at CBN rate)
- Add deductible business expenses
- Toggle statutory deductions: Pension (8%), NHF (2.5%), NHI (5%)
- Full PIT band computation under NTA 2025
- Nil return detection (income below ₦800,000 threshold)
- Countdown to 31 March filing deadline
- Late filing penalty calculator
- PDF assessment export

## Setup
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Architecture
Clean Architecture + BLoC. Tax engine is a pure Dart class with zero Flutter dependencies — fully testable.

## App 1 of 11 — Abuja Infrastructure Series
