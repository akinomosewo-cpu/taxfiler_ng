import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/tax_entities.dart';
import '../blocs/tax_bloc.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'en_NG');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Expenses', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: () => _showAddSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<TaxBloc, TaxState>(
        builder: (context, state) {
          if (state is! TaxLoaded || state.expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_outlined, color: AppColors.textTertiary, size: 48),
                  const Gap(16),
                  Text('No expenses added', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textSecondary)),
                  const Gap(8),
                  Text('Add deductible business expenses to reduce your tax.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary), textAlign: TextAlign.center),
                  const Gap(24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(onPressed: () => _showAddSheet(context), child: const Text('Add Expense')),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.expenses.length,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (_, i) {
              final e = state.expenses[i];
              return Dismissible(
                key: Key(e.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                ),
                onDismissed: (_) => context.read<TaxBloc>().add(ExpenseDeleted(e.id)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.receipt_long_outlined, color: AppColors.warning, size: 16),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.description, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                            Text('${e.type.label} • ${DateFormat('MMM d').format(e.date)}',
                                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Text('₦${fmt.format(e.amount)}', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.warning)),
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

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(value: context.read<TaxBloc>(), child: const _AddExpenseSheet()),
    );
  }
}

class _AddExpenseSheet extends StatefulWidget {
  const _AddExpenseSheet();
  @override State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  ExpenseType _type = ExpenseType.equipment;
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Expense', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
          const Gap(20),
          TextField(
            controller: _descCtrl,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Description (e.g. Laptop purchase)'),
          ),
          const Gap(12),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Amount in ₦'),
          ),
          const Gap(12),
          DropdownButtonFormField<ExpenseType>(
            initialValue: _type,
            dropdownColor: AppColors.surfaceElevated,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Expense type'),
            items: ExpenseType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
            onChanged: (t) => setState(() => _type = t!),
          ),
          const Gap(20),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
              if (_descCtrl.text.isEmpty || amount <= 0) return;
              context.read<TaxBloc>().add(ExpenseAdded(ExpenseEntry(
                id: _uuid.v4(),
                description: _descCtrl.text,
                amount: amount,
                type: _type,
                date: DateTime.now(),
                hasReceipt: false,
              )));
              Navigator.pop(context);
            },
            child: const Text('Add Expense'),
          ),
        ],
      ),
    );
  }
}
