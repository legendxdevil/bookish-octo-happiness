import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';

/// Expense chart widget showing category-wise spending
class ExpenseChart extends StatelessWidget {
  final Map<String, double> categorySpending;

  const ExpenseChart({
    super.key,
    required this.categorySpending,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (categorySpending.isEmpty) {
      return _EmptyChartState();
    }

    // Sort and take top 5 categories
    final sortedEntries = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedEntries.take(5).toList();
    final total = topCategories.fold(0.0, (sum, e) => sum + e.value);

    // Generate colors
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.error,
      colorScheme.surfaceVariant,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.chartPie,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Spending by Category',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: topCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value.key;
                    final amount = entry.value.value;
                    final percentage = total > 0 ? (amount / total * 100) : 0;

                    return PieChartSectionData(
                      color: colors[index % colors.length],
                      value: amount,
                      title: '${percentage.toStringAsFixed(0)}%',
                      radius: 60,
                      titleStyle: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: topCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value.key;
                final amount = entry.value.value;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '\$${amount.toStringAsFixed(0)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChartState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
        child: Center(
          child: Column(
            children: [
              Icon(
                LucideIcons.chartPie,
                size: 48,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No expense data yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
