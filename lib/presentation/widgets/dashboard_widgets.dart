import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';

/// Quick actions widget for dashboard
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final actions = [
      _QuickActionItem(
        icon: LucideIcons.plus,
        label: 'Add',
        color: colorScheme.primary,
        onTap: () {
          // Navigate to add transaction
        },
      ),
      _QuickActionItem(
        icon: LucideIcons.target,
        label: 'Goal',
        color: colorScheme.secondary,
        onTap: () {
          // Navigate to goals
        },
      ),
      _QuickActionItem(
        icon: LucideIcons.chartNoAxesColumn,
        label: 'Stats',
        color: colorScheme.tertiary,
        onTap: () {
          // Show statistics
        },
      ),
      _QuickActionItem(
        icon: LucideIcons.circleEllipsis,
        label: 'More',
        color: colorScheme.surfaceVariant,
        onTap: () {
          // Show more options
        },
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((action) => _buildActionButton(context, action)).toList(),
    );
  }

  Widget _buildActionButton(BuildContext context, _QuickActionItem action) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: action.color.withOpacity(0.2),
              ),
            ),
            child: Icon(
              action.icon,
              color: action.color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

/// Recent transactions widget for dashboard
class RecentTransactions extends StatelessWidget {
  final List transactions;

  const RecentTransactions({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.history,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Transactions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all transactions
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (transactions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No transactions yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...transactions.take(3).map((transaction) {
                final isIncome = transaction.type.toString().contains('income');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isIncome
                              ? colorScheme.secondaryContainer
                              : colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isIncome
                              ? LucideIcons.arrowDownLeft
                              : LucideIcons.arrowUpRight,
                          color: isIncome
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onErrorContainer,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              transaction.category,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isIncome
                              ? colorScheme.secondary
                              : colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

/// Savings progress widget for dashboard
class SavingsProgress extends StatelessWidget {
  final double totalSavings;
  final int activeGoalsCount;
  final double savingsRate;

  const SavingsProgress({
    super.key,
    required this.totalSavings,
    required this.activeGoalsCount,
    required this.savingsRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.piggyBank,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Savings Progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SavingsStat(
                    label: 'Total Saved',
                    value: '\$${totalSavings.toStringAsFixed(0)}',
                    color: colorScheme.secondary,
                  ),
                ),
                Expanded(
                  child: _SavingsStat(
                    label: 'Active Goals',
                    value: '$activeGoalsCount',
                    color: colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _SavingsStat(
                    label: 'Savings Rate',
                    value: '${savingsRate.toStringAsFixed(0)}%',
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingsStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SavingsStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
