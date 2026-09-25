class AppConstants {
  AppConstants._();

  static const String appName = 'TaxFiler NG';
  static const String appVersion = '1.0.0';

  // Storage
  static const String taxProfileBox = 'tax_profile_box';
  static const String incomeBox = 'income_box';
  static const String expenseBox = 'expense_box';
  static const String assessmentBox = 'assessment_box';

  // Nigeria Tax Act 2025 - PIT Bands
  static const double taxFreeThreshold = 800000;
  static const double band1Limit = 1000000;
  static const double band2Limit = 3000000;
  static const double band3Limit = 6000000;
  static const double band4Limit = 10000000;

  static const double band1Rate = 0.07;
  static const double band2Rate = 0.11;
  static const double band3Rate = 0.15;
  static const double band4Rate = 0.19;
  static const double band5Rate = 0.21;
  static const double band6Rate = 0.24;

  // Penalties
  static const double lateFilingFirstMonth = 100000;
  static const double lateFilingSubsequentMonth = 50000;

  // Filing deadline
  static const int filingDeadlineMonth = 3; // March
  static const int filingDeadlineDay = 31;

  // Allowable deductions
  static const double consolidatedReliefAllowance = 200000;
  static const double consolidatedReliefPercent = 0.01; // 1% of gross income
  static const double pensionRate = 0.08; // 8% employee contribution
  static const double nhfRate = 0.025; // 2.5% NHF
  static const double nhiRate = 0.05; // 5% NHI

  // CBN API (for exchange rates)
  static const String cbnRateUrl = 'https://api.exchangerate-api.com/v4/latest/USD';
}

enum IncomeType {
  freelance('Freelance / Contract'),
  salary('Salary / PAYE'),
  business('Business Income'),
  rental('Rental Income'),
  investment('Investment / Dividends'),
  foreign('Foreign Income'),
  other('Other');

  const IncomeType(this.label);
  final String label;
}

enum ExpenseType {
  equipment('Equipment / Tools'),
  software('Software / Subscriptions'),
  internet('Internet / Data'),
  transport('Transport / Travel'),
  rent('Office / Workspace Rent'),
  training('Training / Courses'),
  marketing('Marketing'),
  other('Other Business Expense');

  const ExpenseType(this.label);
  final String label;
}

enum Currency {
  ngn('NGN', '₦', 1.0),
  usd('USD', '\$', 0.0),
  gbp('GBP', '£', 0.0),
  eur('EUR', '€', 0.0);

  const Currency(this.code, this.symbol, this.rateToNgn);
  final String code;
  final String symbol;
  final double rateToNgn;
}

enum FilingStatus {
  notStarted,
  inProgress,
  readyToFile,
  filed,
}

enum TaxYear {
  y2024('2024', DateTime(2024, 1, 1), DateTime(2024, 12, 31)),
  y2025('2025', DateTime(2025, 1, 1), DateTime(2025, 12, 31)),
  y2026('2026', DateTime(2026, 1, 1), DateTime(2026, 12, 31));

  const TaxYear(this.label, this.start, this.end);
  final String label;
  final DateTime start;
  final DateTime end;
}
