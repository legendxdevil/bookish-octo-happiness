import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/transaction_model.dart';
import '../blocs/transaction_bloc.dart';
import '../widgets/custom_text_field.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  TransactionType _type = TransactionType.expense;
  String _category = AppConstants.expenseCategories[0];
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text) ?? 0;
      
      final transaction = TransactionModel.create(
        title: _titleController.text.trim(),
        amount: amount,
        type: _type,
        category: _category,
        date: _date,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      context.read<TransactionBloc>().add(AddTransaction(transaction: transaction));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categories = _type == TransactionType.expense
        ? AppConstants.expenseCategories
        : AppConstants.incomeCategories;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Add Transaction',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
          ),
          Divider(color: colorScheme.outline),
          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type Selector
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _type = TransactionType.expense;
                                _category = AppConstants.expenseCategories[0];
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _type == TransactionType.expense
                                      ? colorScheme.error
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Expense',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: _type == TransactionType.expense
                                        ? colorScheme.onError
                                        : colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _type = TransactionType.income;
                                _category = AppConstants.incomeCategories[0];
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _type == TransactionType.income
                                      ? colorScheme.secondary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Income',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: _type == TransactionType.income
                                        ? colorScheme.onSecondary
                                        : colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Title
                    CustomTextField(
                      controller: _titleController,
                      label: 'Title',
                      hint: 'e.g., Grocery Shopping',
                      prefixIcon: LucideIcons.fileText,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Amount
                    CustomTextField(
                      controller: _amountController,
                      label: 'Amount',
                      hint: '0.00',
                      prefixIcon: LucideIcons.dollarSign,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Category
                    Text(
                      'Category',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final isSelected = _category == category;
                        return ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _category = category);
                            }
                          },
                          selectedColor: _type == TransactionType.income
                              ? colorScheme.secondaryContainer
                              : colorScheme.errorContainer,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Date
                    CustomTextField(
                      label: 'Date',
                      hint: DateFormat('MMM dd, yyyy').format(_date),
                      prefixIcon: LucideIcons.calendar,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _date = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Note
                    CustomTextField(
                      controller: _noteController,
                      label: 'Note (Optional)',
                      hint: 'Add a note...',
                      prefixIcon: LucideIcons.stickyNote,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Add Transaction'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterTransactionsSheet extends StatelessWidget {
  const FilterTransactionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Filter Transactions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    context.read<TransactionBloc>().add(LoadTransactions());
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
          Divider(color: colorScheme.outline),
          ListTile(
            leading: const Icon(LucideIcons.arrowDownLeft),
            title: const Text('Income Only'),
            onTap: () {
              context.read<TransactionBloc>().add(
                const FilterTransactions(type: TransactionType.income),
              );
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.arrowUpRight),
            title: const Text('Expenses Only'),
            onTap: () {
              context.read<TransactionBloc>().add(
                const FilterTransactions(type: TransactionType.expense),
              );
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class TransactionDetailsSheet extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsSheet({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isIncome = transaction.type == TransactionType.income;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isIncome
                        ? colorScheme.secondaryContainer
                        : colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isIncome ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                    size: 32,
                    color: isIncome
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  transaction.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isIncome ? colorScheme.secondary : colorScheme.error,
                  ),
                ),
                const SizedBox(height: 24),
                _DetailRow(
                  icon: LucideIcons.tag,
                  label: 'Category',
                  value: transaction.category,
                ),
                _DetailRow(
                  icon: LucideIcons.calendar,
                  label: 'Date',
                  value: DateFormat('MMMM dd, yyyy').format(transaction.date),
                ),
                if (transaction.note != null)
                  _DetailRow(
                    icon: LucideIcons.stickyNote,
                    label: 'Note',
                    value: transaction.note!,
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
