import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failures.dart';
import '../../data/models/financial_goal_model.dart';
import '../../services/ai_service.dart';
import '../../services/storage_service.dart';

// Events
abstract class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object?> get props => [];
}

class LoadGoals extends GoalEvent {}

class AddGoal extends GoalEvent {
  final FinancialGoalModel goal;

  const AddGoal({required this.goal});

  @override
  List<Object?> get props => [goal];
}

class UpdateGoal extends GoalEvent {
  final FinancialGoalModel goal;

  const UpdateGoal({required this.goal});

  @override
  List<Object?> get props => [goal];
}

class DeleteGoal extends GoalEvent {
  final String goalId;

  const DeleteGoal({required this.goalId});

  @override
  List<Object?> get props => [goalId];
}

class GenerateGoalPlan extends GoalEvent {
  final FinancialGoalModel goal;
  final double monthlyIncome;
  final double monthlyExpenses;

  const GenerateGoalPlan({
    required this.goal,
    required this.monthlyIncome,
    required this.monthlyExpenses,
  });

  @override
  List<Object?> get props => [goal, monthlyIncome, monthlyExpenses];
}

class UpdateGoalProgress extends GoalEvent {
  final String goalId;
  final double amount;

  const UpdateGoalProgress({
    required this.goalId,
    required this.amount,
  });

  @override
  List<Object?> get props => [goalId, amount];
}

// States
abstract class GoalState extends Equatable {
  const GoalState();

  @override
  List<Object?> get props => [];
}

class GoalInitial extends GoalState {}

class GoalLoading extends GoalState {}

class GoalsLoaded extends GoalState {
  final List<FinancialGoalModel> goals;
  final double totalSavings;

  const GoalsLoaded({
    required this.goals,
    required this.totalSavings,
  });

  @override
  List<Object?> get props => [goals, totalSavings];
}

class GoalError extends GoalState {
  final String message;

  const GoalError({required this.message});

  @override
  List<Object?> get props => [message];
}

class GoalPlanGenerated extends GoalState {
  final String plan;
  final FinancialGoalModel goal;

  const GoalPlanGenerated({
    required this.plan,
    required this.goal,
  });

  @override
  List<Object?> get props => [plan, goal];
}

class GoalOperationSuccess extends GoalState {}

// BLoC
class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final StorageService _storageService;
  final AIService _aiService;

  GoalBloc({
    required StorageService storageService,
    required AIService aiService,
  })  : _storageService = storageService,
        _aiService = aiService,
        super(GoalInitial()) {
    on<LoadGoals>(_onLoadGoals);
    on<AddGoal>(_onAddGoal);
    on<UpdateGoal>(_onUpdateGoal);
    on<DeleteGoal>(_onDeleteGoal);
    on<GenerateGoalPlan>(_onGenerateGoalPlan);
    on<UpdateGoalProgress>(_onUpdateGoalProgress);
  }

  Future<void> _onLoadGoals(
    LoadGoals event,
    Emitter<GoalState> emit,
  ) async {
    emit(GoalLoading());
    await _loadGoals(emit);
  }

  Future<void> _onAddGoal(
    AddGoal event,
    Emitter<GoalState> emit,
  ) async {
    emit(GoalLoading());
    try {
      await _storageService.addGoal(event.goal);
      emit(GoalOperationSuccess());
      await _loadGoals(emit);
    } catch (e) {
      emit(GoalError(message: 'Failed to add goal'));
    }
  }

  Future<void> _onUpdateGoal(
    UpdateGoal event,
    Emitter<GoalState> emit,
  ) async {
    emit(GoalLoading());
    try {
      await _storageService.updateGoal(event.goal);
      emit(GoalOperationSuccess());
      await _loadGoals(emit);
    } catch (e) {
      emit(GoalError(message: 'Failed to update goal'));
    }
  }

  Future<void> _onDeleteGoal(
    DeleteGoal event,
    Emitter<GoalState> emit,
  ) async {
    emit(GoalLoading());
    try {
      await _storageService.deleteGoal(event.goalId);
      emit(GoalOperationSuccess());
      await _loadGoals(emit);
    } catch (e) {
      emit(GoalError(message: 'Failed to delete goal'));
    }
  }

  Future<void> _onGenerateGoalPlan(
    GenerateGoalPlan event,
    Emitter<GoalState> emit,
  ) async {
    emit(GoalLoading());
    try {
      if (!_aiService.isConfigured) {
        emit(GoalError(message: 'Please configure Gemini API key in settings'));
        return;
      }

      final plan = await _aiService.generateGoalPlan(
        goalName: event.goal.title,
        targetAmount: event.goal.targetAmount,
        currentSavings: event.goal.currentAmount,
        deadline: event.goal.deadline,
        monthlyIncome: event.monthlyIncome,
        monthlyExpenses: event.monthlyExpenses,
      );

      // Update goal with AI plan
      final updatedGoal = event.goal.copyWith(aiPlan: plan);
      await _storageService.updateGoal(updatedGoal);

      emit(GoalPlanGenerated(plan: plan, goal: updatedGoal));
      await _loadGoals(emit);
    } on AIServiceFailure catch (e) {
      emit(GoalError(message: e.message));
    } catch (e) {
      emit(GoalError(message: 'Failed to generate goal plan'));
    }
  }

  Future<void> _onUpdateGoalProgress(
    UpdateGoalProgress event,
    Emitter<GoalState> emit,
  ) async {
    emit(GoalLoading());
    try {
      final goals = _storageService.getAllGoals();
      final goal = goals.firstWhere((g) => g.id == event.goalId);
      
      final updatedGoal = goal.copyWith(
        currentAmount: goal.currentAmount + event.amount,
        status: (goal.currentAmount + event.amount) >= goal.targetAmount
            ? GoalStatus.completed
            : goal.status,
      );
      
      await _storageService.updateGoal(updatedGoal);
      emit(GoalOperationSuccess());
      await _loadGoals(emit);
    } catch (e) {
      emit(GoalError(message: 'Failed to update goal progress'));
    }
  }

  Future<void> _loadGoals(Emitter<GoalState> emit) async {
    try {
      final goals = _storageService.getAllGoals();
      final totalSavings = _storageService.getTotalSavings();

      emit(GoalsLoaded(
        goals: goals,
        totalSavings: totalSavings,
      ));
    } catch (e) {
      emit(GoalError(message: 'Failed to load goals'));
    }
  }
}
