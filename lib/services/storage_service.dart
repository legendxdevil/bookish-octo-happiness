import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_constants.dart';
import '../data/models/chat_message_model.dart';
import '../data/models/financial_goal_model.dart';
import '../data/models/settings_model.dart';
import '../data/models/transaction_model.dart';
import '../data/models/user_model.dart';

/// Service for managing local data storage using Hive and secure storage
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late Box<UserModel> _userBox;
  late Box<TransactionModel> _transactionsBox;
  late Box<FinancialGoalModel> _goalsBox;
  late Box<SettingsModel> _settingsBox;
  late Box<ChatMessageModel> _chatBox;
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accountName: 'antigravity_secure_storage',
    ),
  );

  bool _isInitialized = false;

  /// Initialize Hive boxes and secure storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Register adapters
      Hive.registerAdapter(TransactionModelAdapter());
      Hive.registerAdapter(TransactionTypeAdapter());
      Hive.registerAdapter(FinancialGoalModelAdapter());
      Hive.registerAdapter(GoalStatusAdapter());
      Hive.registerAdapter(UserModelAdapter());
      Hive.registerAdapter(ChatMessageModelAdapter());
      Hive.registerAdapter(MessageSenderAdapter());
      Hive.registerAdapter(SettingsModelAdapter());

      // Open boxes
      _userBox = await Hive.openBox<UserModel>(AppConstants.userBox);
      _transactionsBox = await Hive.openBox<TransactionModel>(AppConstants.transactionsBox);
      _goalsBox = await Hive.openBox<FinancialGoalModel>(AppConstants.goalsBox);
      _settingsBox = await Hive.openBox<SettingsModel>(AppConstants.settingsBox);
      _chatBox = await Hive.openBox<ChatMessageModel>(AppConstants.chatBox);

      // Initialize default settings if needed
      if (_settingsBox.isEmpty) {
        await _settingsBox.put('settings', SettingsModel.defaultSettings());
      }

      _isInitialized = true;
      if (kDebugMode) {
        print('Storage Service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Storage Service initialization error: $e');
      }
      rethrow;
    }
  }

  // ==================== SECURE STORAGE ====================

  /// Store API key securely
  Future<void> setApiKey(String apiKey) async {
    await _secureStorage.write(key: AppConstants.apiKeyKey, value: apiKey);
  }

  /// Retrieve API key from secure storage
  Future<String?> getApiKey() async {
    return await _secureStorage.read(key: AppConstants.apiKeyKey);
  }

  /// Delete API key
  Future<void> deleteApiKey() async {
    await _secureStorage.delete(key: AppConstants.apiKeyKey);
  }

  /// Store auth token securely
  Future<void> setAuthToken(String token) async {
    await _secureStorage.write(key: AppConstants.authTokenKey, value: token);
  }

  /// Retrieve auth token
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: AppConstants.authTokenKey);
  }

  /// Delete auth token
  Future<void> deleteAuthToken() async {
    await _secureStorage.delete(key: AppConstants.authTokenKey);
  }

  // ==================== USER ====================

  /// Save user data
  Future<void> saveUser(UserModel user) async {
    await _userBox.put('current_user', user);
  }

  /// Get current user
  UserModel? getCurrentUser() {
    return _userBox.get('current_user');
  }

  /// Delete user data
  Future<void> deleteUser() async {
    await _userBox.delete('current_user');
  }

  /// Check if user is logged in
  bool get isLoggedIn => _userBox.containsKey('current_user');

  // ==================== TRANSACTIONS ====================

  /// Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  /// Get all transactions
  List<TransactionModel> getAllTransactions() {
    return _transactionsBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get transactions by type
  List<TransactionModel> getTransactionsByType(TransactionType type) {
    return _transactionsBox.values
        .where((t) => t.type == type)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get transactions for a date range
  List<TransactionModel> getTransactionsForDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _transactionsBox.values
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get transactions by category
  List<TransactionModel> getTransactionsByCategory(String category) {
    return _transactionsBox.values
        .where((t) => t.category == category)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Update transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  /// Delete transaction
  Future<void> deleteTransaction(String id) async {
    await _transactionsBox.delete(id);
  }

  /// Get total income
  double getTotalIncome() {
    return _transactionsBox.values
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Get total expenses
  double getTotalExpenses() {
    return _transactionsBox.values
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Get current balance
  double getBalance() {
    return getTotalIncome() - getTotalExpenses();
  }

  /// Get monthly income
  double getMonthlyIncome(int year, int month) {
    return _transactionsBox.values
        .where((t) =>
            t.type == TransactionType.income &&
            t.date.year == year &&
            t.date.month == month)
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Get monthly expenses
  double getMonthlyExpenses(int year, int month) {
    return _transactionsBox.values
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.year == year &&
            t.date.month == month)
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Get category-wise spending
  Map<String, double> getCategorySpending(int year, int month) {
    final spending = <String, double>{};
    for (final transaction in _transactionsBox.values) {
      if (transaction.type == TransactionType.expense &&
          transaction.date.year == year &&
          transaction.date.month == month) {
        spending[transaction.category] =
            (spending[transaction.category] ?? 0) + transaction.amount;
      }
    }
    return spending;
  }

  // ==================== GOALS ====================

  /// Add a new goal
  Future<void> addGoal(FinancialGoalModel goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  /// Get all goals
  List<FinancialGoalModel> getAllGoals() {
    return _goalsBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get active goals
  List<FinancialGoalModel> getActiveGoals() {
    return _goalsBox.values
        .where((g) => g.status == GoalStatus.active)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Update goal
  Future<void> updateGoal(FinancialGoalModel goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  /// Delete goal
  Future<void> deleteGoal(String id) async {
    await _goalsBox.delete(id);
  }

  /// Get total savings (sum of all goal current amounts)
  double getTotalSavings() {
    return _goalsBox.values.fold(0, (sum, g) => sum + g.currentAmount);
  }

  // ==================== SETTINGS ====================

  /// Get settings
  SettingsModel getSettings() {
    return _settingsBox.get('settings') ?? SettingsModel.defaultSettings();
  }

  /// Update settings
  Future<void> updateSettings(SettingsModel settings) async {
    await _settingsBox.put('settings', settings);
  }

  /// Update specific setting
  Future<void> updateSetting(String key, dynamic value) async {
    final currentSettings = getSettings();
    SettingsModel newSettings;
    
    switch (key) {
      case 'themeMode':
        newSettings = currentSettings.copyWith(themeMode: value as String);
        break;
      case 'currency':
        newSettings = currentSettings.copyWith(currency: value as String);
        break;
      case 'notificationsEnabled':
        newSettings = currentSettings.copyWith(notificationsEnabled: value as bool);
        break;
      case 'privacyMode':
        newSettings = currentSettings.copyWith(privacyMode: value as bool);
        break;
      case 'aiTipsEnabled':
        newSettings = currentSettings.copyWith(aiTipsEnabled: value as bool);
        break;
      default:
        return;
    }
    
    await updateSettings(newSettings);
  }

  // ==================== CHAT ====================

  /// Save chat message
  Future<void> saveChatMessage(ChatMessageModel message) async {
    await _chatBox.put(message.id, message);
  }

  /// Get all chat messages
  List<ChatMessageModel> getAllChatMessages() {
    return _chatBox.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Delete chat history
  Future<void> clearChatHistory() async {
    await _chatBox.clear();
  }

  // ==================== DATA EXPORT/IMPORT ====================

  /// Export all user data as JSON
  Future<Map<String, dynamic>> exportData() async {
    return {
      'user': getCurrentUser()?.toString(),
      'transactions': getAllTransactions().map((t) => {
        'id': t.id,
        'title': t.title,
        'amount': t.amount,
        'type': t.type.name,
        'category': t.category,
        'date': t.date.toIso8601String(),
        'note': t.note,
      }).toList(),
      'goals': getAllGoals().map((g) => {
        'id': g.id,
        'title': g.title,
        'description': g.description,
        'targetAmount': g.targetAmount,
        'currentAmount': g.currentAmount,
        'deadline': g.deadline.toIso8601String(),
        'status': g.status.name,
      }).toList(),
      'settings': {
        'themeMode': getSettings().themeMode,
        'currency': getSettings().currency,
        'notificationsEnabled': getSettings().notificationsEnabled,
        'privacyMode': getSettings().privacyMode,
      },
    };
  }

  /// Clear all data (for logout/reset)
  Future<void> clearAllData() async {
    await _userBox.clear();
    await _transactionsBox.clear();
    await _goalsBox.clear();
    await _chatBox.clear();
    await deleteApiKey();
    await deleteAuthToken();
  }
}
