import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';

/// Service for interacting with Gemini AI API
class AIService {
  late Dio _dio;
  String? _apiKey;

  AIService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.geminiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  /// Set the Gemini API key
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  /// Check if API key is configured
  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  /// Generate a financial tip based on user's financial data
  Future<String> generateFinancialTip({
    required double balance,
    required double monthlyIncome,
    required double monthlyExpenses,
    required double savingsRate,
  }) async {
    if (!isConfigured) {
      throw const AIServiceFailure('Gemini API key not configured');
    }

    try {
      final prompt = AppConstants.financialTipPrompt
          .replaceAll('{balance}', balance.toStringAsFixed(2))
          .replaceAll('{income}', monthlyIncome.toStringAsFixed(2))
          .replaceAll('{expenses}', monthlyExpenses.toStringAsFixed(2))
          .replaceAll('{savingsRate}', savingsRate.toStringAsFixed(1));

      final response = await _generateContent(prompt);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('AI Service Error: $e');
      }
      throw AIServiceFailure('Failed to generate tip: ${e.toString()}');
    }
  }

  /// Generate comprehensive financial analysis report
  Future<String> generateFinancialAnalysis({
    required double balance,
    required double monthlyIncome,
    required double monthlyExpenses,
    required double savingsRate,
    required Map<String, double> categorySpending,
  }) async {
    if (!isConfigured) {
      throw const AIServiceFailure('Gemini API key not configured');
    }

    try {
      final topCategories = categorySpending.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      final categoriesStr = topCategories
          .take(5)
          .map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}')
          .join(', ');

      final prompt = AppConstants.financialAnalysisPrompt
          .replaceAll('{balance}', balance.toStringAsFixed(2))
          .replaceAll('{income}', monthlyIncome.toStringAsFixed(2))
          .replaceAll('{expenses}', monthlyExpenses.toStringAsFixed(2))
          .replaceAll('{savingsRate}', savingsRate.toStringAsFixed(1))
          .replaceAll('{topCategories}', categoriesStr);

      final response = await _generateContent(prompt);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('AI Service Error: $e');
      }
      throw AIServiceFailure('Failed to generate analysis: ${e.toString()}');
    }
  }

  /// Generate financial goal plan with AI recommendations
  Future<String> generateGoalPlan({
    required String goalName,
    required double targetAmount,
    required double currentSavings,
    required DateTime deadline,
    required double monthlyIncome,
    required double monthlyExpenses,
  }) async {
    if (!isConfigured) {
      throw const AIServiceFailure('Gemini API key not configured');
    }

    try {
      final prompt = AppConstants.goalPlanningPrompt
          .replaceAll('{goalName}', goalName)
          .replaceAll('{targetAmount}', targetAmount.toStringAsFixed(2))
          .replaceAll('{currentSavings}', currentSavings.toStringAsFixed(2))
          .replaceAll('{deadline}', deadline.toIso8601String().split('T')[0])
          .replaceAll('{monthlyIncome}', monthlyIncome.toStringAsFixed(2))
          .replaceAll('{monthlyExpenses}', monthlyExpenses.toStringAsFixed(2));

      final response = await _generateContent(prompt);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('AI Service Error: $e');
      }
      throw AIServiceFailure('Failed to generate goal plan: ${e.toString()}');
    }
  }

  /// Chat with AI assistant
  Future<String> chatWithAI({
    required String message,
    required List<Map<String, String>> context,
  }) async {
    if (!isConfigured) {
      throw const AIServiceFailure('Gemini API key not configured');
    }

    try {
      final response = await _generateContent(message);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('AI Service Error: $e');
      }
      throw AIServiceFailure('Failed to get AI response: ${e.toString()}');
    }
  }

  /// Internal method to generate content using Gemini API
  Future<String> _generateContent(String prompt) async {
    if (_apiKey == null) {
      throw const AIServiceFailure('API key not set');
    }

    final url = 
        '/models/${AppConstants.geminiModel}:generateContent?key=$_apiKey';

    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 2048,
        'topP': 0.9,
        'topK': 40,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        }
      ]
    };

    final response = await _dio.post(url, data: body);

    if (response.statusCode == 200) {
      final candidates = response.data['candidates'] as List<dynamic>;
      if (candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content['parts'] as List<dynamic>;
        if (parts.isNotEmpty) {
          return parts[0]['text'] as String;
        }
      }
      throw const AIServiceFailure('Empty response from AI');
    } else {
      throw AIServiceFailure(
          'API Error: ${response.statusCode} - ${response.statusMessage}');
    }
  }

  /// Validate API key by making a test request
  Future<bool> validateApiKey(String apiKey) async {
    try {
      final testService = AIService();
      testService.setApiKey(apiKey);
      await testService._generateContent('Hello');
      return true;
    } catch (e) {
      return false;
    }
  }
}
