import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failures.dart';
import '../../data/models/settings_model.dart';
import '../../services/ai_service.dart';
import '../../services/storage_service.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateApiKey extends SettingsEvent {
  final String apiKey;

  const UpdateApiKey({required this.apiKey});

  @override
  List<Object?> get props => [apiKey];
}

class UpdateThemeMode extends SettingsEvent {
  final String themeMode;

  const UpdateThemeMode({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}

class UpdateCurrency extends SettingsEvent {
  final String currency;

  const UpdateCurrency({required this.currency});

  @override
  List<Object?> get props => [currency];
}

class UpdateNotifications extends SettingsEvent {
  final bool enabled;

  const UpdateNotifications({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class UpdatePrivacyMode extends SettingsEvent {
  final bool enabled;

  const UpdatePrivacyMode({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class UpdateAiTips extends SettingsEvent {
  final bool enabled;

  const UpdateAiTips({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class ValidateApiKey extends SettingsEvent {
  final String apiKey;

  const ValidateApiKey({required this.apiKey});

  @override
  List<Object?> get props => [apiKey];
}

class ExportData extends SettingsEvent {}

class ImportData extends SettingsEvent {
  final Map<String, dynamic> data;

  const ImportData({required this.data});

  @override
  List<Object?> get props => [data];
}

class ClearAllData extends SettingsEvent {}

// States
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final SettingsModel settings;
  final bool isApiKeyValid;

  const SettingsLoaded({
    required this.settings,
    this.isApiKeyValid = false,
  });

  @override
  List<Object?> get props => [settings, isApiKeyValid];

  SettingsLoaded copyWith({
    SettingsModel? settings,
    bool? isApiKeyValid,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      isApiKeyValid: isApiKeyValid ?? this.isApiKeyValid,
    );
  }
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ApiKeyValidated extends SettingsState {
  final bool isValid;

  const ApiKeyValidated({required this.isValid});

  @override
  List<Object?> get props => [isValid];
}

class DataExported extends SettingsState {
  final Map<String, dynamic> data;

  const DataExported({required this.data});

  @override
  List<Object?> get props => [data];
}

class DataImported extends SettingsState {}

class DataCleared extends SettingsState {}

class SettingsOperationSuccess extends SettingsState {}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final StorageService _storageService;
  final AIService _aiService;

  SettingsBloc({
    required StorageService storageService,
    required AIService aiService,
  })  : _storageService = storageService,
        _aiService = aiService,
        super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateApiKey>(_onUpdateApiKey);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateCurrency>(_onUpdateCurrency);
    on<UpdateNotifications>(_onUpdateNotifications);
    on<UpdatePrivacyMode>(_onUpdatePrivacyMode);
    on<UpdateAiTips>(_onUpdateAiTips);
    on<ValidateApiKey>(_onValidateApiKey);
    on<ExportData>(_onExportData);
    on<ImportData>(_onImportData);
    on<ClearAllData>(_onClearAllData);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final settings = _storageService.getSettings();
      final apiKey = await _storageService.getApiKey();
      
      if (apiKey != null && apiKey.isNotEmpty) {
        _aiService.setApiKey(apiKey);
      }

      emit(SettingsLoaded(
        settings: settings.copyWith(geminiApiKey: apiKey),
        isApiKeyValid: _aiService.isConfigured,
      ));
    } catch (e) {
      emit(SettingsError(message: 'Failed to load settings'));
    }
  }

  Future<void> _onUpdateApiKey(
    UpdateApiKey event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _storageService.setApiKey(event.apiKey);
      _aiService.setApiKey(event.apiKey);
      
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(
        settings: currentState.settings.copyWith(geminiApiKey: event.apiKey),
        isApiKeyValid: true,
      ));
    } catch (e) {
      emit(SettingsError(message: 'Failed to save API key'));
    }
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _storageService.updateSetting('themeMode', event.themeMode);
      
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(
        settings: currentState.settings.copyWith(themeMode: event.themeMode),
      ));
    } catch (e) {
      emit(SettingsError(message: 'Failed to update theme'));
    }
  }

  Future<void> _onUpdateCurrency(
    UpdateCurrency event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _storageService.updateSetting('currency', event.currency);
      
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(
        settings: currentState.settings.copyWith(currency: event.currency),
      ));
    } catch (e) {
      emit(SettingsError(message: 'Failed to update currency'));
    }
  }

  Future<void> _onUpdateNotifications(
    UpdateNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _storageService.updateSetting('notificationsEnabled', event.enabled);
      
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(
        settings: currentState.settings.copyWith(notificationsEnabled: event.enabled),
      ));
    } catch (e) {
      emit(SettingsError(message: 'Failed to update notifications'));
    }
  }

  Future<void> _onUpdatePrivacyMode(
    UpdatePrivacyMode event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _storageService.updateSetting('privacyMode', event.enabled);
      
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(
        settings: currentState.settings.copyWith(privacyMode: event.enabled),
      ));
    } catch (e) {
      emit(SettingsError(message: 'Failed to update privacy mode'));
    }
  }

  Future<void> _onUpdateAiTips(
    UpdateAiTips event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _storageService.updateSetting('aiTipsEnabled', event.enabled);
      
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(
        settings: currentState.settings.copyWith(aiTipsEnabled: event.enabled),
      ));
    } catch (e) {
      emit(SettingsError(message: 'Failed to update AI tips setting'));
    }
  }

  Future<void> _onValidateApiKey(
    ValidateApiKey event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final isValid = await _aiService.validateApiKey(event.apiKey);
      emit(ApiKeyValidated(isValid: isValid));
      
      if (isValid) {
        await _storageService.setApiKey(event.apiKey);
        _aiService.setApiKey(event.apiKey);
      }
    } catch (e) {
      emit(ApiKeyValidated(isValid: false));
    }
  }

  Future<void> _onExportData(
    ExportData event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final data = await _storageService.exportData();
      emit(DataExported(data: data));
      
      // Reload settings after export
      final settings = _storageService.getSettings();
      emit(SettingsLoaded(
        settings: settings,
        isApiKeyValid: _aiService.isConfigured,
      ));
    } catch (e) {
      emit(SettingsError(message: 'Failed to export data'));
    }
  }

  Future<void> _onImportData(
    ImportData event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      // TODO: Implement data import logic
      emit(DataImported());
      
      // Reload settings after import
      final settings = _storageService.getSettings();
      emit(SettingsLoaded(
        settings: settings,
        isApiKeyValid: _aiService.isConfigured,
      ));
    } catch (e) {
      emit(SettingsError(message: 'Failed to import data'));
    }
  }

  Future<void> _onClearAllData(
    ClearAllData event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      await _storageService.clearAllData();
      emit(DataCleared());
    } catch (e) {
      emit(SettingsError(message: 'Failed to clear data'));
    }
  }
}
