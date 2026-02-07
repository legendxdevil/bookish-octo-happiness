import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/transaction_model.dart';
import '../blocs/transaction_bloc.dart';
import '../widgets/custom_text_field.dart';
import 'transaction_sheets.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            onPressed: () {
              _showFilterBottomSheet();
            },
            icon: const Icon(LucideIcons.filter),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.circleAlert,
                    size: 48,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TransactionBloc>().add(LoadTransactions());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TransactionsLoaded) {
            return Column(
              children: [
                // Summary Cards
                Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Income',
                          amount: state.totalIncome,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Expenses',
                          amount: state.totalExpenses,
                          color: colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Balance',
                          amount: state.balance,
                          color: state.balance >= 0
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: colorScheme.outline),
                // Transactions List
                Expanded(
                  child: state.transactions.isEmpty
                      ? _EmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppConstants.defaultPadding),
                          itemCount: state.transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = state.transactions[index];
                            return _TransactionCard(
                              transaction: transaction,
                              onTap: () => _showTransactionDetails(transaction),
                              onDelete: () => _deleteTransaction(transaction.id),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddTransactionDialog();
        },
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add'),
      ),
    );
  }

  void _showAddTransactionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionSheet(),
    );
  }

  void _showTransactionDetails(TransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      builder: (context) => TransactionDetailsSheet(transaction: transaction),
    );
  }

  void _deleteTransaction(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TransactionBloc>().add(
                DeleteTransaction(transactionId: id),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterTransactionsSheet(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.abs().toStringAsFixed(0)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TransactionCard({
    required this.transaction,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isIncome = transaction.type == TransactionType.income;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          LucideIcons.trash2,
          color: colorScheme.onError,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isIncome
                  ? colorScheme.secondaryContainer
                  : colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
              color: isIncome
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onErrorContainer,
            ),
          ),
          title: Text(
            transaction.title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${transaction.category} • ${DateFormat('MMM dd').format(transaction.date)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: Text(
            '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isIncome ? colorScheme.secondary : colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.wallet,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first transaction to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
