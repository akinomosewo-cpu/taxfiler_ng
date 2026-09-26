import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/tax_entities.dart';
import '../blocs/tax_bloc.dart';

class IncomePage extends StatelessWidget {
  const IncomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'en_NG');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Income', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: () => _showAddIncomeSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<TaxBloc, TaxState>(
        builder: (context, state) {
          if (state is! TaxLoaded) return const SizedBox.shrink();
          if (state.incomes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payments_outlined, color: AppColors.textTertiary, size: 48),
                  const Gap(16),
                  Text('No income added yet', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textSecondary)),
                  const Gap(8),
                  Text('Tap + to add your freelance, salary or business income.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary), textAlign: TextAlign.center),
                  const Gap(24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(
                      onPressed: () => _showAddIncomeSheet(context),
                      child: const Text('Add Income'),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.incomes.length,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (_, i) {
              final entry = state.incomes[i];
              return Dismissible(
                key: Key(entry.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                ),
                onDismissed: (_) => context.read<TaxBloc>().add(IncomeDeleted(entry.id)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.trending_up_rounded, color: AppColors.success, size: 16),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.description, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                            Text('${entry.type.label} • ${DateFormat('MMM d, yyyy').format(entry.date)}',
                                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₦${fmt.format(entry.amountNgn)}',
                              style: AppTextStyles.headlineSmall.copyWith(color: AppColors.success)),
                          if (entry.currency != Currency.ngn)
                            Text('${entry.currency.symbol}${fmt.format(entry.amount)}',
                                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddIncomeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(
        value: context.read<TaxBloc>(),
        child: const _AddIncomeSheet(),
      ),
    );
  }
}

class _AddIncomeSheet extends StatefulWidget {
  const _AddIncomeSheet();
  @override State<_AddIncomeSheet> createState() => _AddIncomeSheetState();
}

class _AddIncomeSheetState extends State<_AddIncomeSheet> {
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  IncomeType _type = IncomeType.freelance;
  Currency _currency = Currency.ngn;
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Income', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
          const Gap(20),
          TextField(
            controller: _descCtrl,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Description (e.g. Upwork contract)'),
          ),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                  decoration: const InputDecoration(hintText: 'Amount'),
                ),
              ),
              const Gap(12),
              DropdownButton<Currency>(
                value: _currency,
                dropdownColor: AppColors.surfaceElevated,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                items: Currency.values.map((c) => DropdownMenuItem(value: c, child: Text(c.code))).toList(),
                onChanged: (c) => setState(() => _currency = c!),
              ),
            ],
          ),
          const Gap(12),
          DropdownButtonFormField<IncomeType>(
            initialValue: _type,
            dropdownColor: AppColors.surfaceElevated,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Income type'),
            items: IncomeType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
            onChanged: (t) => setState(() => _type = t!),
          ),
          const Gap(20),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
              if (_descCtrl.text.isEmpty || amount <= 0) return;
              final rate = _currency == Currency.ngn ? 1.0 : 1600.0; // fallback rate
              context.read<TaxBloc>().add(IncomeAdded(IncomeEntry(
                id: _uuid.v4(),
                description: _descCtrl.text,
                amount: amount,
                currency: _currency,
                exchangeRateToNgn: rate,
                amountNgn: amount * rate,
                type: _type,
                date: DateTime.now(),
              )));
              Navigator.pop(context);
            },
            child: const Text('Add Income'),
          ),
        ],
      ),
    );
  }
}
