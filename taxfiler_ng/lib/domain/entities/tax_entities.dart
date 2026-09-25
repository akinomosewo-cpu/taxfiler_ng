import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

class TaxProfile extends Equatable {
  final String id;
  final String fullName;
  final String tin; // Tax Identification Number
  final String stateOfResidence;
  final String occupation;
  final bool isSelfEmployed;
  final DateTime createdAt;

  const TaxProfile({
    required this.id,
    required this.fullName,
    required this.tin,
    required this.stateOfResidence,
    required this.occupation,
    required this.isSelfEmployed,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, fullName, tin, stateOfResidence, occupation, isSelfEmployed, createdAt];
}

class IncomeEntry extends Equatable {
  final String id;
  final String description;
  final double amount;
  final Currency currency;
  final double exchangeRateToNgn;
  final double amountNgn;
  final IncomeType type;
  final DateTime date;
  final String? clientName;
  final String? invoiceRef;

  const IncomeEntry({
    required this.id,
    required this.description,
    required this.amount,
    required this.currency,
    required this.exchangeRateToNgn,
    required this.amountNgn,
    required this.type,
    required this.date,
    this.clientName,
    this.invoiceRef,
  });

  @override
  List<Object?> get props => [id, description, amount, currency, amountNgn, type, date];
}

class ExpenseEntry extends Equatable {
  final String id;
  final String description;
  final double amount;
  final ExpenseType type;
  final DateTime date;
  final bool hasReceipt;

  const ExpenseEntry({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.hasReceipt,
  });

  @override
  List<Object?> get props => [id, description, amount, type, date];
}

class TaxAssessment extends Equatable {
  final String id;
  final TaxYear year;
  final double grossIncome;
  final double totalExpenses;
  final double pensionDeduction;
  final double nhfDeduction;
  final double nhiDeduction;
  final double consolidatedRelief;
  final double totalDeductions;
  final double taxableIncome;
  final double taxLiability;
  final double effectiveTaxRate;
  final FilingStatus status;
  final DateTime calculatedAt;
  final List<TaxBandBreakdown> bandBreakdown;

  const TaxAssessment({
    required this.id,
    required this.year,
    required this.grossIncome,
    required this.totalExpenses,
    required this.pensionDeduction,
    required this.nhfDeduction,
    required this.nhiDeduction,
    required this.consolidatedRelief,
    required this.totalDeductions,
    required this.taxableIncome,
    required this.taxLiability,
    required this.effectiveTaxRate,
    required this.status,
    required this.calculatedAt,
    required this.bandBreakdown,
  });

  double get netIncome => grossIncome - totalExpenses;
  bool get isNilReturn => taxableIncome <= AppConstants.taxFreeThreshold;
  int get daysUntilDeadline {
    final now = DateTime.now();
    final deadline = DateTime(now.year + 1, AppConstants.filingDeadlineMonth, AppConstants.filingDeadlineDay);
    return deadline.difference(now).inDays;
  }

  @override
  List<Object?> get props => [id, year, grossIncome, taxableIncome, taxLiability, status];
}

class TaxBandBreakdown extends Equatable {
  final String label;
  final double from;
  final double to;
  final double rate;
  final double taxable;
  final double tax;

  const TaxBandBreakdown({
    required this.label,
    required this.from,
    required this.to,
    required this.rate,
    required this.taxable,
    required this.tax,
  });

  @override
  List<Object?> get props => [label, from, to, rate, taxable, tax];
}
