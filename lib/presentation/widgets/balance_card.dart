import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';

/// Balance card showing total balance with gradient background
class BalanceCard extends StatelessWidget {
  final double balance;
  final String currency;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$$balance',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  LucideIcons.wallet,
                  color: colorScheme.onPrimary,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _BalanceInfoItem(
                  icon: LucideIcons.trendingUp,
                  label: 'Income',
                  color: colorScheme.onPrimary,
                ),
              ),
              Expanded(
                child: _BalanceInfoItem(
                  icon: LucideIcons.trendingDown,
                  label: 'Expenses',
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _BalanceInfoItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
