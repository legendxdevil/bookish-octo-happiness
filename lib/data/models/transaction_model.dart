import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 1)
class TransactionModel extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final double amount;
  
  @HiveField(3)
  final TransactionType type;
  
  @HiveField(4)
  final String category;
  
  @HiveField(5)
  final DateTime date;
  
  @HiveField(6)
  final String? note;
  
  @HiveField(7)
  final String? paymentMethod;
  
  @HiveField(8)
  final bool isRecurring;
  
  @HiveField(9)
  final String? receiptImage;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
    this.paymentMethod,
    this.isRecurring = false,
    this.receiptImage,
  });

  factory TransactionModel.create({
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    DateTime? date,
    String? note,
    String? paymentMethod,
    bool isRecurring = false,
    String? receiptImage,
  }) {
    return TransactionModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date ?? DateTime.now(),
      note: note,
      paymentMethod: paymentMethod,
      isRecurring: isRecurring,
      receiptImage: receiptImage,
    );
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? note,
    String? paymentMethod,
    bool? isRecurring,
    String? receiptImage,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isRecurring: isRecurring ?? this.isRecurring,
      receiptImage: receiptImage ?? this.receiptImage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        type,
        category,
        date,
        note,
        paymentMethod,
        isRecurring,
        receiptImage,
      ];
}
