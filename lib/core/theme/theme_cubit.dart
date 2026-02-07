import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import 'app_theme.dart';
import 'app_dark_theme.dart';

/// Theme Cubit for managing app theme state
class ThemeCubit extends Cubit<ThemeMode> {
  late Box _settingsBox;
  
  ThemeCubit() : super(ThemeMode.light) {
    _init();
  }
  
  Future<void> _init() async {
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    final themeMode = _settingsBox.get('themeMode', defaultValue: 'light');
    emit(_getThemeModeFromString(themeMode));
  }
  
  ThemeMode _getThemeModeFromString(String themeMode) {
    switch (themeMode) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    await _settingsBox.put('themeMode', mode.name);
    emit(mode);
  }
  
  ThemeData getThemeData(BuildContext context) {
    switch (state) {
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark
            ? darkTheme
            : lightTheme;
      default:
        return lightTheme;
    }
  }
}
