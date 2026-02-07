import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/models/transaction_model.dart';
import '../../services/ai_service.dart';
import '../../services/storage_service.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {}

class RefreshDashboard extends DashboardEvent {}

class LoadMonthlyData extends DashboardEvent {
  final int year;
  final int month;

  const LoadMonthlyData({
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [year, month];
}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final double savingsRate;
  final List<TransactionModel> recentTransactions;
  final Map<String, double> categorySpending;
  final String? aiTip;
  final int activeGoalsCount;
  final double totalSavings;

  const DashboardLoaded({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.savingsRate,
    required this.recentTransactions,
    required this.categorySpending,
    this.aiTip,
    required this.activeGoalsCount,
    required this.totalSavings,
  });

  @override
  List<Object?> get props => [
        totalBalance,
        monthlyIncome,
        monthlyExpenses,
        savingsRate,
        recentTransactions,
        categorySpending,
        aiTip,
        activeGoalsCount,
        totalSavings,
      ];

  DashboardLoaded copyWith({
    double? totalBalance,
    double? monthlyIncome,
    double? monthlyExpenses,
    double? savingsRate,
    List<TransactionModel>? recentTransactions,
    Map<String, double>? categorySpending,
    String? aiTip,
    int? activeGoalsCount,
    double? totalSavings,
  }) {
    return DashboardLoaded(
      totalBalance: totalBalance ?? this.totalBalance,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      savingsRate: savingsRate ?? this.savingsRate,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      categorySpending: categorySpending ?? this.categorySpending,
      aiTip: aiTip ?? this.aiTip,
      activeGoalsCount: activeGoalsCount ?? this.activeGoalsCount,
      totalSavings: totalSavings ?? this.totalSavings,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final StorageService _storageService;
  final AIService _aiService;

  DashboardBloc({
    required StorageService storageService,
    required AIService aiService,
  })  : _storageService = storageService,
        _aiService = aiService,
        super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<LoadMonthlyData>(_onLoadMonthlyData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _loadDashboardData(emit);
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadDashboardData(emit);
  }

  Future<void> _onLoadMonthlyData(
    LoadMonthlyData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    
    final totalBalance = _storageService.getBalance();
    final monthlyIncome = _storageService.getMonthlyIncome(event.year, event.month);
    final monthlyExpenses = _storageService.getMonthlyExpenses(event.year, event.month);
    final savingsRate = monthlyIncome > 0
        ? ((monthlyIncome - monthlyExpenses) / monthlyIncome * 100).clamp(0, 100).toDouble()
        : 0.0;
    
    final transactions = _storageService.getAllTransactions().take(5).toList();
    final categorySpending = _storageService.getCategorySpending(event.year, event.month);
    final activeGoalsCount = _storageService.getActiveGoals().length;
    final totalSavings = _storageService.getTotalSavings();

    String? aiTip;
    if (_aiService.isConfigured) {
      try {
        aiTip = await _aiService.generateFinancialTip(
          balance: totalBalance,
          monthlyIncome: monthlyIncome,
          monthlyExpenses: monthlyExpenses,
          savingsRate: savingsRate,
        );
      } catch (e) {
        // AI tip is optional, continue without it
      }
    }

    emit(DashboardLoaded(
      totalBalance: totalBalance,
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlyExpenses,
      savingsRate: savingsRate,
      recentTransactions: transactions,
      categorySpending: categorySpending,
      aiTip: aiTip,
      activeGoalsCount: activeGoalsCount,
      totalSavings: totalSavings,
    ));
  }

  Future<void> _loadDashboardData(Emitter<DashboardState> emit) async {
    try {
      final now = DateTime.now();
      final totalBalance = _storageService.getBalance();
      final monthlyIncome = _storageService.getMonthlyIncome(now.year, now.month);
      final monthlyExpenses = _storageService.getMonthlyExpenses(now.year, now.month);
      final savingsRate = monthlyIncome > 0
          ? ((monthlyIncome - monthlyExpenses) / monthlyIncome * 100).clamp(0, 100).toDouble()
          : 0.0;
      
      final transactions = _storageService.getAllTransactions().take(5).toList();
      final categorySpending = _storageService.getCategorySpending(now.year, now.month);
      final activeGoalsCount = _storageService.getActiveGoals().length;
      final totalSavings = _storageService.getTotalSavings();

      String? aiTip;
      if (_aiService.isConfigured) {
        try {
          aiTip = await _aiService.generateFinancialTip(
            balance: totalBalance,
            monthlyIncome: monthlyIncome,
            monthlyExpenses: monthlyExpenses,
            savingsRate: savingsRate,
          );
        } catch (e) {
          // AI tip is optional, continue without it
        }
      }

      emit(DashboardLoaded(
        totalBalance: totalBalance,
        monthlyIncome: monthlyIncome,
        monthlyExpenses: monthlyExpenses,
        savingsRate: savingsRate,
        recentTransactions: transactions,
        categorySpending: categorySpending,
        aiTip: aiTip,
        activeGoalsCount: activeGoalsCount,
        totalSavings: totalSavings,
      ));
    } catch (e) {
      emit(DashboardError(message: 'Failed to load dashboard data'));
    }
  }
}
