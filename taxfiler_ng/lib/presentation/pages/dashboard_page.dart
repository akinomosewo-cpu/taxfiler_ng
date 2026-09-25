import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../blocs/tax_bloc.dart';
import 'income_page.dart';
import 'expenses_page.dart';
import 'assessment_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _fmt = NumberFormat('#,##0', 'en_NG');

  @override
  void initState() {
    super.initState();
    context.read<TaxBloc>().add(const TaxInitialized());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<TaxBloc, TaxState>(
          builder: (context, state) {
            if (state is! TaxLoaded) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            return _Content(state: state, fmt: _fmt);
          },
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final TaxLoaded state;
  final NumberFormat fmt;

  const _Content({required this.state, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final deadline = DateTime(now.year + 1, 3, 31);
    final daysLeft = deadline.difference(now).inDays;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: AppColors.background,
          title: Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 18),
              ),
              const Gap(10),
              Text('TaxFiler NG', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary)),
            ],
          ),
          actions: [
            // Year selector
            PopupMenuButton<TaxYear>(
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(state.selectedYear.label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
                    const Icon(Icons.expand_more, color: AppColors.primary, size: 18),
                  ],
                ),
              ),
              onSelected: (y) => context.read<TaxBloc>().add(TaxYearChanged(y)),
              itemBuilder: (_) => TaxYear.values.map((y) => PopupMenuItem(
                value: y,
                child: Text(y.label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
              )).toList(),
            ),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(delegate: SliverChildListDelegate([
            const Gap(8),

            // Deadline banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: daysLeft < 60 ? AppColors.dangerGradient : AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Filing Deadline: 31 March ${now.year + 1}',
                            style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                        Text('$daysLeft days remaining',
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                  ),
                  Text('⚠', style: TextStyle(fontSize: 20)),
                ],
              ),
            ).animate().fadeIn(),

            const Gap(20),

            // Income / Expense / Tax cards
            Row(children: [
              Expanded(child: _SummaryCard(
                label: 'Total Income',
                value: '₦${fmt.format(state.totalIncome)}',
                icon: Icons.trending_up_rounded,
                color: AppColors.success,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: context.read<TaxBloc>(), child: const IncomePage()))),
              ).animate(delay: 50.ms).fadeIn().slideY(begin: 0.1)),
              const Gap(12),
              Expanded(child: _SummaryCard(
                label: 'Total Expenses',
                value: '₦${fmt.format(state.totalExpenses)}',
                icon: Icons.trending_down_rounded,
                color: AppColors.warning,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: context.read<TaxBloc>(), child: const ExpensesPage()))),
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1)),
            ]),

            const Gap(12),

            _SummaryCard(
              label: 'Estimated Tax Liability',
              value: state.assessment != null
                  ? (state.assessment!.isNilReturn ? 'NIL RETURN — No tax owed' : '₦${fmt.format(state.assessment!.taxLiability)}')
                  : 'Tap Calculate to see your tax',
              icon: Icons.calculate_outlined,
              color: AppColors.primary,
              fullWidth: true,
              onTap: state.assessment != null
                  ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: context.read<TaxBloc>(), child: const AssessmentPage())))
                  : null,
            ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1),

            const Gap(20),

            // Deductions
            Text('Statutory Deductions', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
            const Gap(12),
            _DeductionToggle(label: 'Pension (8%)', subtitle: 'NSITF / RSA Pension Fund', key_: 'pension', value: state.hasPension),
            const Gap(8),
            _DeductionToggle(label: 'NHF (2.5%)', subtitle: 'National Housing Fund', key_: 'nhf', value: state.hasNhf),
            const Gap(8),
            _DeductionToggle(label: 'NHI (5%)', subtitle: 'National Health Insurance', key_: 'nhi', value: state.hasNhi),

            const Gap(24),

            // Calculate button
            ElevatedButton.icon(
              onPressed: state.incomes.isEmpty
                  ? null
                  : () => context.read<TaxBloc>().add(const TaxCalculated()),
              icon: const Icon(Icons.calculate_rounded),
              label: const Text('Calculate My Tax'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.surfaceElevated,
              ),
            ).animate(delay: 200.ms).fadeIn(),

            if (state.assessment != null) ...[
              const Gap(12),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => BlocProvider.value(value: context.read<TaxBloc>(), child: const AssessmentPage()),
                )),
                icon: const Icon(Icons.description_outlined),
                label: const Text('View Full Assessment'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ).animate(delay: 250.ms).fadeIn(),
            ],

            const Gap(32),
          ])),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool fullWidth;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 15),
                ),
                if (onTap != null)
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
              ],
            ),
            const Gap(12),
            Text(value, style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary)),
            const Gap(4),
            Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _DeductionToggle extends StatelessWidget {
  final String label;
  final String subtitle;
  final String key_;
  final bool value;

  const _DeductionToggle({
    required this.label,
    required this.subtitle,
    required this.key_,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? AppColors.primary.withOpacity(0.4) : AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                Text(subtitle, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: (v) => context.read<TaxBloc>().add(DeductionToggled(key_, v)),
          ),
        ],
      ),
    );
  }
}
