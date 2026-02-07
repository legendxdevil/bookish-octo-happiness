import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 7)
class SettingsModel extends Equatable {
  @HiveField(0)
  final String? geminiApiKey;
  
  @HiveField(1)
  final String themeMode;
  
  @HiveField(2)
  final String currency;
  
  @HiveField(3)
  final String? defaultPaymentMethod;
  
  @HiveField(4)
  final bool notificationsEnabled;
  
  @HiveField(5)
  final bool privacyMode;
  
  @HiveField(6)
  final String dateFormat;
  
  @HiveField(7)
  final bool aiTipsEnabled;

  const SettingsModel({
    this.geminiApiKey,
    this.themeMode = 'light',
    this.currency = 'USD',
    this.defaultPaymentMethod,
    this.notificationsEnabled = true,
    this.privacyMode = false,
    this.dateFormat = 'MMM dd, yyyy',
    this.aiTipsEnabled = true,
  });

  factory SettingsModel.defaultSettings() {
    return const SettingsModel();
  }

  bool get hasApiKey => geminiApiKey != null && geminiApiKey!.isNotEmpty;

  SettingsModel copyWith({
    String? geminiApiKey,
    String? themeMode,
    String? currency,
    String? defaultPaymentMethod,
    bool? notificationsEnabled,
    bool? privacyMode,
    String? dateFormat,
    bool? aiTipsEnabled,
  }) {
    return SettingsModel(
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      defaultPaymentMethod: defaultPaymentMethod ?? this.defaultPaymentMethod,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      privacyMode: privacyMode ?? this.privacyMode,
      dateFormat: dateFormat ?? this.dateFormat,
      aiTipsEnabled: aiTipsEnabled ?? this.aiTipsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        geminiApiKey,
        themeMode,
        currency,
        defaultPaymentMethod,
        notificationsEnabled,
        privacyMode,
        dateFormat,
        aiTipsEnabled,
      ];
}
