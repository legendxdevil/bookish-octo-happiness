import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'financial_goal_model.g.dart';

@HiveType(typeId: 2)
enum GoalStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  completed,
  @HiveField(2)
  paused,
}

@HiveType(typeId: 3)
class FinancialGoalModel extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final double targetAmount;
  
  @HiveField(4)
  final double currentAmount;
  
  @HiveField(5)
  final DateTime deadline;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final GoalStatus status;
  
  @HiveField(8)
  final String? aiPlan;
  
  @HiveField(9)
  final List<String> milestones;

  const FinancialGoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.createdAt,
    this.status = GoalStatus.active,
    this.aiPlan,
    this.milestones = const [],
  });

  factory FinancialGoalModel.create({
    required String title,
    required String description,
    required double targetAmount,
    double currentAmount = 0,
    required DateTime deadline,
    String? aiPlan,
    List<String> milestones = const [],
  }) {
    return FinancialGoalModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      deadline: deadline,
      createdAt: DateTime.now(),
      aiPlan: aiPlan,
      milestones: milestones,
    );
  }

  double get progressPercentage => 
      targetAmount > 0 ? (currentAmount / targetAmount * 100).clamp(0, 100) : 0;

  double get remainingAmount => targetAmount - currentAmount;

  bool get isCompleted => currentAmount >= targetAmount;

  FinancialGoalModel copyWith({
    String? id,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    DateTime? createdAt,
    GoalStatus? status,
    String? aiPlan,
    List<String>? milestones,
  }) {
    return FinancialGoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      aiPlan: aiPlan ?? this.aiPlan,
      milestones: milestones ?? this.milestones,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        targetAmount,
        currentAmount,
        deadline,
        createdAt,
        status,
        aiPlan,
        milestones,
      ];
}
