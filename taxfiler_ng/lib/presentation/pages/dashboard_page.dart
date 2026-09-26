import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/auth/auth_repository.dart';
import '../blocs/tax_bloc.dart';
import '../widgets/page_transitions.dart';
import 'income_page.dart';
import 'expenses_page.dart';
import 'assessment_page.dart';
import 'connect_accounts_page.dart';
import 'login_page.dart';

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
                width: 34, height: 34,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 18),
              ),
              const Gap(10),
              Text('TaxFiler NG', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.link_rounded, color: AppColors.textSecondary),
              tooltip: 'Connect Accounts',
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => BlocProvider.value(value: context.read<TaxBloc>(), child: const ConnectAccountsPage()),
              )),
            ),
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
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
              tooltip: 'Log Out',
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(delegate: SliverChildListDelegate([
            const Gap(8),

            // Deadline banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: daysLeft < 60 ? AppColors.dangerGradient : AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (daysLeft < 60 ? AppColors.danger : AppColors.primary).withValues(alpha: 0.28),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
                  ),
                  const Gap(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Filing Deadline: 31 March ${now.year + 1}',
                            style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        const Gap(2),
                        Text('$daysLeft days remaining',
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                      ],
                    ),
                  ),
                  const Gap(8),
                  const Text('⚠', style: TextStyle(fontSize: 22)),
                ],
              ),
            ).animate().fadeIn(),

            const Gap(24),

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

            const Gap(16),

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

            const Gap(28),

            // Deductions
            Text('Statutory Deductions', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary)),
            const Gap(14),
            _DeductionToggle(label: 'Pension (8%)', subtitle: 'NSITF / RSA Pension Fund', key_: 'pension', value: state.hasPension),
            const Gap(10),
            _DeductionToggle(label: 'NHF (2.5%)', subtitle: 'National Housing Fund', key_: 'nhf', value: state.hasNhf),
            const Gap(10),
            _DeductionToggle(label: 'NHI (5%)', subtitle: 'National Health Insurance', key_: 'nhi', value: state.hasNhi),

            const Gap(28),

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

Future<void> _confirmLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Log Out?', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary)),
      content: Text(
        'Your data stays saved on this device. You can log back in any time.',
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log Out')),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  await AuthRepository().logOut();
  if (!context.mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    FadeSlidePageRoute(builder: (_) => const LoginPage()),
    (route) => false,
  );
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 17),
                ),
                if (onTap != null)
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
              ],
            ),
            const Gap(16),
            Text(
              value,
              style: (fullWidth ? AppTextStyles.displaySmall : AppTextStyles.headlineLarge)
                  .copyWith(color: AppColors.textPrimary),
            ),
            const Gap(6),
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      const Gap(2),
                      Text(subtitle, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (value) ...[
                  const AppChip(label: 'Active', color: AppColors.success, icon: Icons.check_rounded),
                  const Gap(10),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => context.read<TaxBloc>().add(DeductionToggled(key_, v)),
          ),
        ],
      ),
    );
  }
}
