import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/transaction_model.dart';
import '../blocs/dashboard_bloc.dart';
import '../widgets/ai_tip_card.dart';
import '../widgets/balance_card.dart';
import '../widgets/expense_chart.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  Future<void> _onRefresh() async {
    context.read<DashboardBloc>().add(RefreshDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                snap: true,
                title: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.tertiary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        LucideIcons.wallet,
                        size: 20,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      // Show notifications
                    },
                    icon: Badge(
                      smallSize: 8,
                      child: Icon(
                        LucideIcons.bell,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              // Content
              SliverToBoxAdapter(
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading) {
                      return const _DashboardSkeleton();
                    }

                    if (state is DashboardError) {
                      return _DashboardError(
                        message: state.message,
                        onRetry: _onRefresh,
                      );
                    }

                    if (state is DashboardLoaded) {
                      return Padding(
                        padding: const EdgeInsets.all(AppConstants.defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Balance Card
                            BalanceCard(
                              balance: state.totalBalance,
                              currency: 'USD',
                            ).animate().fadeIn().slideY(),
                            
                            const SizedBox(height: 24),
                            
                            // Quick Actions
                            const QuickActions(),
                            
                            const SizedBox(height: 24),
                            
                            // Monthly Overview
                            Row(
                              children: [
                                Expanded(
                                  child: _OverviewCard(
                                    title: 'Income',
                                    amount: state.monthlyIncome,
                                    icon: LucideIcons.arrowDownLeft,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _OverviewCard(
                                    title: 'Expenses',
                                    amount: state.monthlyExpenses,
                                    icon: LucideIcons.arrowUpRight,
                                    color: colorScheme.error,
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 100.ms).slideY(),
                            
                            const SizedBox(height: 24),
                            
                            // AI Tip Card
                            if (state.aiTip != null)
                              AITipCard(
                                tip: state.aiTip!,
                                onTap: () {
                                  // Navigate to detailed report
                                  _showDetailedReport(context, state);
                                },
                              ).animate().fadeIn(delay: 200.ms).slideY(),
                            
                            const SizedBox(height: 24),
                            
                            // Expense Chart
                            ExpenseChart(
                              categorySpending: state.categorySpending,
                            ).animate().fadeIn(delay: 300.ms).slideY(),
                            
                            const SizedBox(height: 24),
                            
                            // Savings Progress
                            SavingsProgress(
                              totalSavings: state.totalSavings,
                              activeGoalsCount: state.activeGoalsCount,
                              savingsRate: state.savingsRate,
                            ).animate().fadeIn(delay: 400.ms).slideY(),
                            
                            const SizedBox(height: 24),
                            
                            // Recent Transactions
                            RecentTransactions(
                              transactions: state.recentTransactions,
                            ).animate().fadeIn(delay: 500.ms).slideY(),
                            
                            const SizedBox(height: 100),
                          ],
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailedReport(BuildContext context, DashboardLoaded state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
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
              // Title
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.sparkles,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Financial Report',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Generated for ${DateFormat('MMMM yyyy').format(DateTime.now())}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x),
                    ),
                  ],
                ),
              ),
              Divider(color: colorScheme.outline),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Balance',
                            value: '\$${state.totalBalance.toStringAsFixed(2)}',
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Savings Rate',
                            value: '${state.savingsRate.toStringAsFixed(1)}%',
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // AI Analysis
                    Container(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.brainCircuit,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AI Analysis',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (state.aiTip != null)
                            Text(
                              state.aiTip!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Top Expenses
                    Text(
                      'Top Spending Categories',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final sorted = state.categorySpending.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));
                        final top5 = sorted.take(5);
                        return Column(
                          children: top5.map((entry) => _CategoryItem(
                            category: entry.key,
                            amount: entry.value,
                            total: state.monthlyExpenses,
                          )).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String category;
  final double amount;
  final double total;

  const _CategoryItem({
    required this.category,
    required this.amount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percentage = total > 0 ? (amount / total * 100) : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              category,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${amount.toStringAsFixed(2)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          SizedBox(height: 200, child: Card(child: SizedBox.expand())),
          SizedBox(height: 24),
          SizedBox(height: 80, child: Card(child: SizedBox.expand())),
          SizedBox(height: 24),
          SizedBox(height: 200, child: Card(child: SizedBox.expand())),
          SizedBox(height: 24),
          SizedBox(height: 150, child: Card(child: SizedBox.expand())),
        ],
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
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
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
