import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/financial_goal_model.dart';
import '../blocs/goal_bloc.dart';
import '../widgets/custom_text_field.dart';
import 'goal_sheets.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  @override
  void initState() {
    super.initState();
    context.read<GoalBloc>().add(LoadGoals());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Goals'),
      ),
      body: BlocBuilder<GoalBloc, GoalState>(
        builder: (context, state) {
          if (state is GoalLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GoalError) {
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
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<GoalBloc>().add(LoadGoals());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is GoalsLoaded) {
            if (state.goals.isEmpty) {
              return _EmptyState(onAddGoal: () => _showAddGoalDialog());
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: state.goals.length,
              itemBuilder: (context, index) {
                final goal = state.goals[index];
                return _GoalCard(
                  goal: goal,
                  onTap: () => _showGoalDetails(goal),
                  onAddFunds: () => _showAddFundsDialog(goal),
                  onDelete: () => _deleteGoal(goal.id),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(),
        icon: const Icon(LucideIcons.plus),
        label: const Text('New Goal'),
      ),
    );
  }

  void _showAddGoalDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddGoalSheet(),
    );
  }

  void _showGoalDetails(FinancialGoalModel goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalDetailsSheet(goal: goal),
    );
  }

  void _showAddFundsDialog(FinancialGoalModel goal) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Funds'),
        content: CustomTextField(
          controller: controller,
          label: 'Amount',
          hint: '0.00',
          prefixIcon: LucideIcons.dollarSign,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                context.read<GoalBloc>().add(
                  UpdateGoalProgress(goalId: goal.id, amount: amount),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteGoal(String goalId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<GoalBloc>().add(DeleteGoal(goalId: goalId));
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
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddGoal;

  const _EmptyState({required this.onAddGoal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.target,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No goals yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set a financial goal to start saving',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddGoal,
            icon: const Icon(LucideIcons.plus),
            label: const Text('Create Goal'),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final FinancialGoalModel goal;
  final VoidCallback onTap;
  final VoidCallback onAddFunds;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.onTap,
    required this.onAddFunds,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = goal.progressPercentage / 100;

    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(LucideIcons.trash2, color: colorScheme.onError),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Deadline: ${DateFormat('MMM dd, yyyy').format(goal.deadline)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (goal.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Completed',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      goal.isCompleted ? colorScheme.secondary : colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${goal.currentAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${goal.targetAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${goal.progressPercentage.toStringAsFixed(1)}% complete',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!goal.isCompleted)
                      TextButton.icon(
                        onPressed: onAddFunds,
                        icon: const Icon(LucideIcons.plus, size: 16),
                        label: const Text('Add'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 32),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
