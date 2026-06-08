import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_themes.dart';

/// Gestor simple del tema de la app (guarda la preferencia en SharedPreferences).
/// Lo hice como parte del TFG para mantener el tema y el modo oscuro.
class ThemeProvider extends ChangeNotifier {
  AppThemeType _themeType = AppThemeType.tierra;
  bool _isDark = false;

  AppThemeType get themeType => _themeType;
  bool get isDark => _isDark;
  ThemeData get theme => AppThemes.getTheme(_themeType);
  ThemeData get darkTheme => AppThemes.getDarkTheme(_themeType);

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt('themeType') ?? 0;
      _isDark = prefs.getBool('isDark') ?? false;
      if (themeIndex >= 0 && themeIndex < AppThemeType.values.length) {
        _themeType = AppThemeType.values[themeIndex];
      } else {
        _themeType = AppThemeType.tierra;
        await prefs.setInt('themeType', 0);
      }
    } catch (e) {
      _themeType = AppThemeType.tierra;
    }
    notifyListeners();
  }

  Future<void> setTheme(AppThemeType type) async {
    _themeType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeType', type.index);
    notifyListeners();
  }

  Future<void> toggleDark() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
    notifyListeners();
  }
}
