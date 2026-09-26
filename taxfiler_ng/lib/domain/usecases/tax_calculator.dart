import '../../core/constants/app_constants.dart';
import '../entities/tax_entities.dart';

class TaxCalculator {
  /// Computes full PIT assessment under Nigeria Tax Act 2025
  static TaxAssessment calculate({
    required String id,
    required TaxYear year,
    required List<IncomeEntry> incomes,
    required List<ExpenseEntry> expenses,
    required bool hasPension,
    required bool hasNhf,
    required bool hasNhi,
  }) {
    final grossIncome = incomes.fold(0.0, (sum, e) => sum + e.amountNgn);
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final netIncome = grossIncome - totalExpenses;

    // Statutory deductions
    final pensionDeduction = hasPension ? netIncome * AppConstants.pensionRate : 0.0;
    final nhfDeduction = hasNhf ? netIncome * AppConstants.nhfRate : 0.0;
    final nhiDeduction = hasNhi ? netIncome * AppConstants.nhiRate : 0.0;

    // Consolidated Relief Allowance: higher of ₦200,000 or 1% of gross income
    const craBase = AppConstants.consolidatedReliefAllowance;
    final craPercent = grossIncome * AppConstants.consolidatedReliefPercent;
    final consolidatedRelief = (craBase > craPercent ? craBase : craPercent) + (grossIncome * 0.20);

    final totalDeductions = pensionDeduction + nhfDeduction + nhiDeduction + consolidatedRelief;
    final taxableIncome = (netIncome - totalDeductions).clamp(0.0, double.infinity);

    final breakdown = _computeBands(taxableIncome);
    final taxLiability = breakdown.fold(0.0, (sum, b) => sum + b.tax);
    final effectiveTaxRate = grossIncome > 0 ? (taxLiability / grossIncome) * 100 : 0.0;

    return TaxAssessment(
      id: id,
      year: year,
      grossIncome: grossIncome,
      totalExpenses: totalExpenses,
      pensionDeduction: pensionDeduction,
      nhfDeduction: nhfDeduction,
      nhiDeduction: nhiDeduction,
      consolidatedRelief: consolidatedRelief,
      totalDeductions: totalDeductions,
      taxableIncome: taxableIncome,
      taxLiability: taxLiability,
      effectiveTaxRate: effectiveTaxRate,
      status: FilingStatus.readyToFile,
      calculatedAt: DateTime.now(),
      bandBreakdown: breakdown,
    );
  }

  static List<TaxBandBreakdown> _computeBands(double taxableIncome) {
    final bands = <TaxBandBreakdown>[];
    double remaining = taxableIncome;

    final definitions = [
      (label: 'First ₦300,000', from: 0.0, to: 300000.0, rate: 0.07),
      (label: 'Next ₦300,000', from: 300000.0, to: 600000.0, rate: 0.11),
      (label: 'Next ₦500,000', from: 600000.0, to: 1100000.0, rate: 0.15),
      (label: 'Next ₦500,000', from: 1100000.0, to: 1600000.0, rate: 0.19),
      (label: 'Next ₦1,600,000', from: 1600000.0, to: 3200000.0, rate: 0.21),
      (label: 'Above ₦3,200,000', from: 3200000.0, to: double.infinity, rate: 0.24),
    ];

    for (final band in definitions) {
      if (remaining <= 0) break;
      final bandSize = band.to == double.infinity ? remaining : (band.to - band.from);
      final taxable = remaining < bandSize ? remaining : bandSize;
      final tax = taxable * band.rate;
      bands.add(TaxBandBreakdown(
        label: band.label,
        from: band.from,
        to: band.to,
        rate: band.rate,
        taxable: taxable,
        tax: tax,
      ));
      remaining -= taxable;
    }

    return bands;
  }

  static double penaltyForLateFiling(int monthsLate) {
    if (monthsLate <= 0) return 0;
    return AppConstants.lateFilingFirstMonth +
        ((monthsLate - 1) * AppConstants.lateFilingSubsequentMonth);
  }
}
