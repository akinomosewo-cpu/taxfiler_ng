import 'package:flutter_test/flutter_test.dart';
import 'package:taxfiler_ng/core/constants/app_constants.dart';
import 'package:taxfiler_ng/domain/entities/tax_entities.dart';
import 'package:taxfiler_ng/domain/usecases/tax_calculator.dart';

IncomeEntry _income(double amountNgn) => IncomeEntry(
      id: 'i',
      description: 'test income',
      amount: amountNgn,
      currency: Currency.ngn,
      exchangeRateToNgn: 1.0,
      amountNgn: amountNgn,
      type: IncomeType.freelance,
      date: DateTime(2025, 1, 1),
    );

ExpenseEntry _expense(double amount) => ExpenseEntry(
      id: 'e',
      description: 'test expense',
      amount: amount,
      type: ExpenseType.equipment,
      date: DateTime(2025, 1, 1),
      hasReceipt: true,
    );

void main() {
  group('TaxCalculator.calculate', () {
    test('zero income produces a nil return with no tax liability', () {
      final assessment = TaxCalculator.calculate(
        id: '1',
        year: TaxYear.y2025,
        incomes: [],
        expenses: [],
        hasPension: false,
        hasNhf: false,
        hasNhi: false,
      );

      expect(assessment.grossIncome, 0);
      expect(assessment.taxLiability, 0);
      expect(assessment.isNilReturn, isTrue);
    });

    test('low income after reliefs falls under the tax-free threshold', () {
      final assessment = TaxCalculator.calculate(
        id: '2',
        year: TaxYear.y2025,
        incomes: [_income(600000)],
        expenses: [],
        hasPension: false,
        hasNhf: false,
        hasNhi: false,
      );

      // CRA = max(200000, 1% of 600000) + 20% of 600000 = 200000 + 120000 = 320000
      // taxable = 600000 - 320000 = 280000, all in the 7% first band.
      expect(assessment.taxableIncome, closeTo(280000, 0.01));
      expect(assessment.taxLiability, closeTo(280000 * 0.07, 0.01));
    });

    test('expenses reduce net income and therefore tax liability', () {
      final withoutExpenses = TaxCalculator.calculate(
        id: '3a',
        year: TaxYear.y2025,
        incomes: [_income(5000000)],
        expenses: [],
        hasPension: false,
        hasNhf: false,
        hasNhi: false,
      );
      final withExpenses = TaxCalculator.calculate(
        id: '3b',
        year: TaxYear.y2025,
        incomes: [_income(5000000)],
        expenses: [_expense(1000000)],
        hasPension: false,
        hasNhf: false,
        hasNhi: false,
      );

      expect(withExpenses.totalExpenses, 1000000);
      expect(withExpenses.taxableIncome, lessThan(withoutExpenses.taxableIncome));
      expect(withExpenses.taxLiability, lessThan(withoutExpenses.taxLiability));
    });

    test('statutory deductions (pension, NHF, NHI) reduce taxable income', () {
      final base = TaxCalculator.calculate(
        id: '4a',
        year: TaxYear.y2025,
        incomes: [_income(5000000)],
        expenses: [],
        hasPension: false,
        hasNhf: false,
        hasNhi: false,
      );
      final withDeductions = TaxCalculator.calculate(
        id: '4b',
        year: TaxYear.y2025,
        incomes: [_income(5000000)],
        expenses: [],
        hasPension: true,
        hasNhf: true,
        hasNhi: true,
      );

      expect(withDeductions.pensionDeduction, greaterThan(0));
      expect(withDeductions.nhfDeduction, greaterThan(0));
      expect(withDeductions.nhiDeduction, greaterThan(0));
      expect(withDeductions.taxableIncome, lessThan(base.taxableIncome));
    });

    test('band breakdown sums to total tax liability across multiple bands', () {
      final assessment = TaxCalculator.calculate(
        id: '5',
        year: TaxYear.y2025,
        incomes: [_income(20000000)],
        expenses: [],
        hasPension: false,
        hasNhf: false,
        hasNhi: false,
      );

      final sumOfBands = assessment.bandBreakdown.fold(0.0, (sum, b) => sum + b.tax);
      expect(sumOfBands, closeTo(assessment.taxLiability, 0.01));
      expect(assessment.bandBreakdown.length, greaterThan(1));
      // Highest band (24%) should be present for very high income.
      expect(assessment.bandBreakdown.last.rate, 0.24);
    });

    test('taxable income never goes negative when deductions exceed income', () {
      final assessment = TaxCalculator.calculate(
        id: '6',
        year: TaxYear.y2025,
        incomes: [_income(100000)],
        expenses: [_expense(90000)],
        hasPension: true,
        hasNhf: true,
        hasNhi: true,
      );

      expect(assessment.taxableIncome, greaterThanOrEqualTo(0));
      expect(assessment.taxLiability, greaterThanOrEqualTo(0));
    });

    test('effective tax rate is zero when gross income is zero', () {
      final assessment = TaxCalculator.calculate(
        id: '7',
        year: TaxYear.y2025,
        incomes: [],
        expenses: [],
        hasPension: false,
        hasNhf: false,
        hasNhi: false,
      );

      expect(assessment.effectiveTaxRate, 0);
    });
  });

  group('TaxCalculator.penaltyForLateFiling', () {
    test('no penalty when not late', () {
      expect(TaxCalculator.penaltyForLateFiling(0), 0);
      expect(TaxCalculator.penaltyForLateFiling(-1), 0);
    });

    test('first month late incurs the flat ₦100,000 fine', () {
      expect(TaxCalculator.penaltyForLateFiling(1), 100000);
    });

    test('subsequent months add ₦50,000 each', () {
      expect(TaxCalculator.penaltyForLateFiling(2), 150000);
      expect(TaxCalculator.penaltyForLateFiling(4), 250000);
    });
  });
}
