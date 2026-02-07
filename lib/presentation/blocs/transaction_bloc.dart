import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failures.dart';
import '../../data/models/transaction_model.dart';
import '../../services/storage_service.dart';

// Events
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final TransactionModel transaction;

  const AddTransaction({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransaction extends TransactionEvent {
  final TransactionModel transaction;

  const UpdateTransaction({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransaction extends TransactionEvent {
  final String transactionId;

  const DeleteTransaction({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

class FilterTransactions extends TransactionEvent {
  final TransactionType? type;
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterTransactions({
    this.type,
    this.category,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [type, category, startDate, endDate];
}

// States
abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionsLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final double totalIncome;
  final double totalExpenses;
  final double balance;

  const TransactionsLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
  });

  @override
  List<Object?> get props => [transactions, totalIncome, totalExpenses, balance];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TransactionOperationSuccess extends TransactionState {}

// BLoC
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final StorageService _storageService;

  TransactionBloc({required StorageService storageService})
      : _storageService = storageService,
        super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<FilterTransactions>(_onFilterTransactions);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    await _loadTransactions(emit);
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      await _storageService.addTransaction(event.transaction);
      emit(TransactionOperationSuccess());
      await _loadTransactions(emit);
    } catch (e) {
      emit(TransactionError(message: 'Failed to add transaction'));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      await _storageService.updateTransaction(event.transaction);
      emit(TransactionOperationSuccess());
      await _loadTransactions(emit);
    } catch (e) {
      emit(TransactionError(message: 'Failed to update transaction'));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      await _storageService.deleteTransaction(event.transactionId);
      emit(TransactionOperationSuccess());
      await _loadTransactions(emit);
    } catch (e) {
      emit(TransactionError(message: 'Failed to delete transaction'));
    }
  }

  Future<void> _onFilterTransactions(
    FilterTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      var transactions = _storageService.getAllTransactions();

      if (event.type != null) {
        transactions = transactions.where((t) => t.type == event.type).toList();
      }
      if (event.category != null && event.category!.isNotEmpty) {
        transactions = transactions.where((t) => t.category == event.category).toList();
      }
      if (event.startDate != null && event.endDate != null) {
        transactions = transactions
            .where((t) => t.date.isAfter(event.startDate!) && t.date.isBefore(event.endDate!))
            .toList();
      }

      final totalIncome = transactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);
      final totalExpenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);
      final balance = totalIncome - totalExpenses;

      emit(TransactionsLoaded(
        transactions: transactions,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        balance: balance,
      ));
    } catch (e) {
      emit(TransactionError(message: 'Failed to filter transactions'));
    }
  }

  Future<void> _loadTransactions(Emitter<TransactionState> emit) async {
    try {
      final transactions = _storageService.getAllTransactions();
      final totalIncome = _storageService.getTotalIncome();
      final totalExpenses = _storageService.getTotalExpenses();
      final balance = _storageService.getBalance();

      emit(TransactionsLoaded(
        transactions: transactions,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        balance: balance,
      ));
    } catch (e) {
      emit(TransactionError(message: 'Failed to load transactions'));
    }
  }
}
