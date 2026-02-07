/// App-wide constants for Antigravity
class AppConstants {
  // App Info
  static const String appName = 'Antigravity';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your AI-powered personal finance assistant';
  
  // Storage Keys
  static const String settingsBox = 'settings';
  static const String transactionsBox = 'transactions';
  static const String goalsBox = 'goals';
  static const String chatBox = 'chat';
  static const String userBox = 'user';
  static const String apiKeyKey = 'gemini_api_key';
  static const String authTokenKey = 'auth_token';
  
  // Default Values
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Categories
  static const List<String> expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Health',
    'Education',
    'Other',
  ];
  
  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Business',
    'Gift',
    'Other',
  ];
  
  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'UPI',
    'Bank Transfer',
    'Other',
  ];
  
  // Currencies
  static const List<String> currencies = [
    'USD',
    'EUR',
    'GBP',
    'INR',
    'JPY',
    'AUD',
    'CAD',
  ];
  
  // Date Formats
  static const List<String> dateFormats = [
    'MMM dd, yyyy',
    'dd/MM/yyyy',
    'MM/dd/yyyy',
    'yyyy-MM-dd',
  ];
  
  // AI
  static const String geminiModel = 'gemini-pro';
  static const String geminiApiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
  // AI Prompts
  static const String financialTipPrompt = 'Give me a short, actionable financial tip based on my spending habits. Keep it under 100 words.';
  static const String financialAnalysisPrompt = 'Analyze my financial data and provide insights on: 1) Spending patterns 2) Areas to save 3) Budget recommendations. Be concise.';
  static const String goalPlanningPrompt = 'Help me create a plan to achieve my financial goal. Consider my current savings rate and suggest actionable steps.';
  
  // Security
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  
  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}
