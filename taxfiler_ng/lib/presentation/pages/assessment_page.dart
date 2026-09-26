import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/usecases/pdf_generator.dart';
import '../blocs/tax_bloc.dart';

class AssessmentPage extends StatelessWidget {
  const AssessmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_NG');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tax Assessment', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        actions: [
          Builder(builder: (ctx) {
            final s = ctx.watch<TaxBloc>().state;
            final assessment = s is TaxLoaded ? s.assessment : null;
            return IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
              onPressed: assessment == null ? null : () => PdfGenerator.printAssessment(assessment),
            );
          }),
        ],
      ),
      body: BlocBuilder<TaxBloc, TaxState>(
        builder: (context, state) {
          if (state is! TaxLoaded || state.assessment == null) return const SizedBox.shrink();
          final a = state.assessment!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero result
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: a.isNilReturn ? AppColors.primaryGradient : AppColors.dangerGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(a.isNilReturn ? Icons.check_circle_rounded : Icons.receipt_long_rounded, color: Colors.white, size: 36),
                      const Gap(12),
                      Text(a.isNilReturn ? 'NIL RETURN' : '₦${fmt.format(a.taxLiability)}',
                          style: AppTextStyles.displayMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                      Text(a.isNilReturn ? 'No tax owed for ${a.year.label}' : 'Tax due for ${a.year.label}',
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                      const Gap(8),
                      Text('Effective rate: ${a.effectiveTaxRate.toStringAsFixed(1)}%',
                          style: AppTextStyles.labelMedium.copyWith(color: Colors.white.withValues(alpha: 0.7))),
                    ],
                  ),
                ),

                const Gap(24),

                _Section(title: 'Income Summary', rows: [
                  ('Gross Income', '₦${fmt.format(a.grossIncome)}'),
                  ('Less: Business Expenses', '-₦${fmt.format(a.totalExpenses)}'),
                  ('Net Income', '₦${fmt.format(a.netIncome)}'),
                ]),

                const Gap(16),

                _Section(title: 'Deductions', rows: [
                  ('Pension (8%)', '-₦${fmt.format(a.pensionDeduction)}'),
                  ('NHF (2.5%)', '-₦${fmt.format(a.nhfDeduction)}'),
                  ('NHI (5%)', '-₦${fmt.format(a.nhiDeduction)}'),
                  ('Consolidated Relief', '-₦${fmt.format(a.consolidatedRelief)}'),
                  ('Total Deductions', '-₦${fmt.format(a.totalDeductions)}'),
                ]),

                const Gap(16),

                _Section(title: 'Tax Computation', rows: [
                  ('Taxable Income', '₦${fmt.format(a.taxableIncome)}'),
                ]),

                const Gap(12),

                Text('Band Breakdown', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                const Gap(8),

                ...a.bandBreakdown.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary)),
                            Text('${(b.rate * 100).toStringAsFixed(0)}% on ₦${fmt.format(b.taxable)}',
                                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                        Text('₦${fmt.format(b.tax)}',
                            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.danger)),
                      ],
                    ),
                  ),
                )),

                const Gap(24),
                ElevatedButton.icon(
                  onPressed: () => PdfGenerator.shareAssessment(a),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download PDF Assessment'),
                ),
                const Gap(32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<(String, String)> rows;
  const _Section({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
        const Gap(8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: rows.asMap().entries.map((e) => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.value.$1, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    Text(e.value.$2, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  ],
                ),
                if (e.key < rows.length - 1) ...[const Gap(10), const Divider(height: 1, color: AppColors.border), const Gap(10)],
              ],
            )).toList(),
          ),
        ),
      ],
    );
  }
}
