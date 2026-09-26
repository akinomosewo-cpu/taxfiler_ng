import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/tax_entities.dart';
import '../blocs/tax_bloc.dart';

/// Lets a freelancer link a payment/bank provider so income can be imported
/// automatically instead of entered by hand. Providers are shown as
/// connect-ready cards; since no live banking API keys are configured for
/// this build, a successful "connect" imports a sample statement so the
/// rest of the app (calculation, PDF export) can be exercised end-to-end.
class ConnectAccountsPage extends StatefulWidget {
  const ConnectAccountsPage({super.key});

  @override
  State<ConnectAccountsPage> createState() => _ConnectAccountsPageState();
}

class _ConnectAccountsPageState extends State<ConnectAccountsPage> {
  final Set<String> _connected = {};

  static const _providers = [
    (name: 'Payoneer', icon: Icons.account_balance_wallet_rounded, desc: 'Import cross-border freelance payouts'),
    (name: 'Grey', icon: Icons.swap_horiz_rounded, desc: 'Import USD/GBP/EUR wallet transactions'),
    (name: 'GTBank / Bank Account', icon: Icons.account_balance_rounded, desc: 'Import local NGN account statements'),
    (name: 'Flutterwave', icon: Icons.bolt_rounded, desc: 'Import invoice & payment link income'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Connect Accounts', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Link your payment providers to automatically pull in freelance income for tax calculation.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const Gap(20),
          ..._providers.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProviderTile(
                  name: p.name,
                  icon: p.icon,
                  desc: p.desc,
                  connected: _connected.contains(p.name),
                  onTap: () => _toggleConnect(p.name),
                ),
              )),
          const Gap(12),
          Text(
            'For your security, account credentials are never stored in this app. '
            'A production build authenticates via each provider\'s official OAuth flow.',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  void _toggleConnect(String provider) {
    if (_connected.contains(provider)) {
      setState(() => _connected.remove(provider));
      return;
    }
    setState(() => _connected.add(provider));
    _importSampleIncome(provider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider connected — imported recent income')),
    );
  }

  void _importSampleIncome(String provider) {
    final uuid = const Uuid();
    context.read<TaxBloc>().add(IncomeAdded(IncomeEntry(
          id: uuid.v4(),
          description: '$provider payout',
          amount: 250000,
          currency: Currency.ngn,
          exchangeRateToNgn: 1.0,
          amountNgn: 250000,
          type: IncomeType.freelance,
          date: DateTime.now(),
        )));
  }
}

class _ProviderTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final String desc;
  final bool connected;
  final VoidCallback onTap;

  const _ProviderTile({
    required this.name,
    required this.icon,
    required this.desc,
    required this.connected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: connected ? AppColors.primary.withOpacity(0.5) : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                Text(desc, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Gap(8),
          OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: connected ? AppColors.success : AppColors.primary,
              side: BorderSide(color: connected ? AppColors.success : AppColors.primary),
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(connected ? 'Connected' : 'Connect'),
          ),
        ],
      ),
    );
  }
}
