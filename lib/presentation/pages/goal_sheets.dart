import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/financial_goal_model.dart';
import '../../services/storage_service.dart';
import '../blocs/goal_bloc.dart';
import '../widgets/custom_text_field.dart';

class AddGoalSheet extends StatefulWidget {
  const AddGoalSheet({super.key});

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  
  DateTime _deadline = DateTime.now().add(const Duration(days: 365));

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final targetAmount = double.tryParse(_targetAmountController.text) ?? 0;
      final currentAmount = double.tryParse(_currentAmountController.text) ?? 0;

      final goal = FinancialGoalModel.create(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        deadline: _deadline,
      );

      context.read<GoalBloc>().add(AddGoal(goal: goal));
      Navigator.pop(context);
    }
  }

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
                  'Create New Goal',
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
                    CustomTextField(
                      controller: _titleController,
                      label: 'Goal Name',
                      hint: 'e.g., New Car, Emergency Fund',
                      prefixIcon: LucideIcons.target,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a goal name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Describe your goal...',
                      prefixIcon: LucideIcons.fileText,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _targetAmountController,
                            label: 'Target Amount',
                            hint: '0.00',
                            prefixIcon: LucideIcons.dollarSign,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _currentAmountController,
                            label: 'Current Savings',
                            hint: '0.00',
                            prefixIcon: LucideIcons.piggyBank,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Deadline',
                      hint: DateFormat('MMM dd, yyyy').format(_deadline),
                      prefixIcon: LucideIcons.calendar,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _deadline,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                        );
                        if (picked != null) {
                          setState(() => _deadline = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Create Goal'),
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

class GoalDetailsSheet extends StatelessWidget {
  final FinancialGoalModel goal;

  const GoalDetailsSheet({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = goal.progressPercentage / 100;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
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
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                children: [
                  // Goal Icon and Title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.tertiary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            LucideIcons.target,
                            size: 40,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          goal.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          goal.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Progress Section
                  Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\$${goal.currentAmount.toStringAsFixed(2)}',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  'Current Savings',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${goal.targetAmount.toStringAsFixed(2)}',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Target',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            backgroundColor: colorScheme.surface,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              goal.isCompleted
                                  ? colorScheme.secondary
                                  : colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${goal.progressPercentage.toStringAsFixed(1)}% Complete',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: goal.isCompleted
                                ? colorScheme.secondary
                                : colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Deadline
                  _DetailRow(
                    icon: LucideIcons.calendar,
                    label: 'Deadline',
                    value: DateFormat('MMMM dd, yyyy').format(goal.deadline),
                  ),
                  const SizedBox(height: 16),
                  // Remaining
                  _DetailRow(
                    icon: LucideIcons.wallet,
                    label: 'Remaining',
                    value: '\$${goal.remainingAmount.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 24),
                  // AI Plan Section
                  if (goal.aiPlan != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.sparkles,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AI Financial Plan',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            goal.aiPlan!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer
                                  .withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (!goal.isCompleted) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final storageService = StorageService();
                          final now = DateTime.now();
                          final monthlyIncome = storageService.getMonthlyIncome(
                              now.year, now.month);
                          final monthlyExpenses = storageService.getMonthlyExpenses(
                              now.year, now.month);

                          context.read<GoalBloc>().add(
                            GenerateGoalPlan(
                              goal: goal,
                              monthlyIncome: monthlyIncome,
                              monthlyExpenses: monthlyExpenses,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        icon: const Icon(LucideIcons.sparkles),
                        label: const Text('Generate AI Plan'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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

    return Row(
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
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
