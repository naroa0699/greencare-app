import 'package:flutter/material.dart';

enum AppThemeType { tierra, otono, bosque, rosa, pastel }

/// Colección de temas y paletas usados en la app.
/// Los nombres y emojis ayudan a elegir el estilo desde la UI del TFG.
class AppThemes {
  static ThemeData getTheme(AppThemeType type) {
    final scheme = _lightScheme(type);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: scheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            );
          }
          return TextStyle(color: scheme.onSurfaceVariant, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.onPrimary);
          }
          return IconThemeData(color: scheme.onSurfaceVariant);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      cardTheme: CardThemeData(color: scheme.surfaceContainerHighest),
    );
  }

  static ThemeData getDarkTheme(AppThemeType type) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkScheme(type),
      scaffoldBackgroundColor: _darkScheme(type).surface,
      appBarTheme: AppBarTheme(
        backgroundColor: _darkScheme(type).primary,
        foregroundColor: _darkScheme(type).onPrimary,
        elevation: 0,
      ),
    );
  }

  static ColorScheme _lightScheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.tierra:
        return const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF606C38),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFFDDA15E),
          onPrimaryContainer: Color(0xFF283618),
          secondary: Color(0xFFBC6C25),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFFFEFAE0),
          onSecondaryContainer: Color(0xFF283618),
          surface: Color(0xFFFEFAE0),
          onSurface: Color(0xFF283618),
          surfaceContainerHighest: Color(0xFFF5F0D0),
          onSurfaceVariant: Color(0xFF606C38),
          error: Color(0xFFB00020),
          onError: Color(0xFFFFFFFF),
          outline: Color(0xFF606C38),
        );
      case AppThemeType.otono:
        return const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF335C67),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFFE09F3E),
          onPrimaryContainer: Color(0xFF540B0E),
          secondary: Color(0xFF9E2A2B),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFFFFF3B0),
          onSecondaryContainer: Color(0xFF540B0E),
          surface: Color(0xFFFFF8E7),
          onSurface: Color(0xFF540B0E),
          surfaceContainerHighest: Color(0xFFFFF3B0),
          onSurfaceVariant: Color(0xFF335C67),
          error: Color(0xFFB00020),
          onError: Color(0xFFFFFFFF),
          outline: Color(0xFF335C67),
        );
      case AppThemeType.bosque:
        return const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF52796F),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFF84A98C),
          onPrimaryContainer: Color(0xFF2F3E46),
          secondary: Color(0xFF354F52),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFFCAD2C5),
          onSecondaryContainer: Color(0xFF2F3E46),
          surface: Color(0xFFEEF2EE),
          onSurface: Color(0xFF2F3E46),
          surfaceContainerHighest: Color(0xFFCAD2C5),
          onSurfaceVariant: Color(0xFF52796F),
          error: Color(0xFFB00020),
          onError: Color(0xFFFFFFFF),
          outline: Color(0xFF52796F),
        );
      case AppThemeType.rosa:
        return const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFC37D92),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFFD89A9E),
          onPrimaryContainer: Color(0xFF846267),
          secondary: Color(0xFF846267),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFFE0C1B3),
          onSecondaryContainer: Color(0xFF846267),
          surface: Color(0xFFF8EEE8),
          onSurface: Color(0xFF846267),
          surfaceContainerHighest: Color(0xFFE0C1B3),
          onSurfaceVariant: Color(0xFFC37D92),
          error: Color(0xFFB00020),
          onError: Color(0xFFFFFFFF),
          outline: Color(0xFFC37D92),
        );
      case AppThemeType.pastel:
        return const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF84A59D),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFFF5CAC3),
          onPrimaryContainer: Color(0xFF5A7870),
          secondary: Color(0xFFF28482),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFFF7EDE2),
          onSecondaryContainer: Color(0xFF5A7870),
          surface: Color(0xFFFDF6F0),
          onSurface: Color(0xFF5A7870),
          surfaceContainerHighest: Color(0xFFF7EDE2),
          onSurfaceVariant: Color(0xFF84A59D),
          error: Color(0xFFB00020),
          onError: Color(0xFFFFFFFF),
          outline: Color(0xFF84A59D),
        );
    }
  }

  static ColorScheme _darkScheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.tierra:
        return const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFDDA15E),
          onPrimary: Color(0xFF283618),
          primaryContainer: Color(0xFF606C38),
          onPrimaryContainer: Color(0xFFFEFAE0),
          secondary: Color(0xFFBC6C25),
          onSecondary: Color(0xFFFEFAE0),
          secondaryContainer: Color(0xFF283618),
          onSecondaryContainer: Color(0xFFFEFAE0),
          surface: Color(0xFF1E2510),
          onSurface: Color(0xFFFEFAE0),
          surfaceContainerHighest: Color(0xFF2A3318),
          onSurfaceVariant: Color(0xFFDDA15E),
          error: Color(0xFFCF6679),
          onError: Color(0xFF370B1E),
          outline: Color(0xFFDDA15E),
        );
      case AppThemeType.otono:
        return const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFE09F3E),
          onPrimary: Color(0xFF540B0E),
          primaryContainer: Color(0xFF335C67),
          onPrimaryContainer: Color(0xFFFFF3B0),
          secondary: Color(0xFF9E2A2B),
          onSecondary: Color(0xFFFFF3B0),
          secondaryContainer: Color(0xFF540B0E),
          onSecondaryContainer: Color(0xFFFFF3B0),
          surface: Color(0xFF1A0A0A),
          onSurface: Color(0xFFFFF3B0),
          surfaceContainerHighest: Color(0xFF2A1010),
          onSurfaceVariant: Color(0xFFE09F3E),
          error: Color(0xFFCF6679),
          onError: Color(0xFF370B1E),
          outline: Color(0xFFE09F3E),
        );
      case AppThemeType.bosque:
        return const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF84A98C),
          onPrimary: Color(0xFF2F3E46),
          primaryContainer: Color(0xFF354F52),
          onPrimaryContainer: Color(0xFFCAD2C5),
          secondary: Color(0xFF52796F),
          onSecondary: Color(0xFFCAD2C5),
          secondaryContainer: Color(0xFF2F3E46),
          onSecondaryContainer: Color(0xFFCAD2C5),
          surface: Color(0xFF1A2428),
          onSurface: Color(0xFFCAD2C5),
          surfaceContainerHighest: Color(0xFF243035),
          onSurfaceVariant: Color(0xFF84A98C),
          error: Color(0xFFCF6679),
          onError: Color(0xFF370B1E),
          outline: Color(0xFF84A98C),
        );
      case AppThemeType.rosa:
        return const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFD89A9E),
          onPrimary: Color(0xFF846267),
          primaryContainer: Color(0xFFC37D92),
          onPrimaryContainer: Color(0xFFE0C1B3),
          secondary: Color(0xFF846267),
          onSecondary: Color(0xFFE0C1B3),
          secondaryContainer: Color(0xFF5A3F44),
          onSecondaryContainer: Color(0xFFE0C1B3),
          surface: Color(0xFF2A1A1E),
          onSurface: Color(0xFFE0C1B3),
          surfaceContainerHighest: Color(0xFF3A2428),
          onSurfaceVariant: Color(0xFFD89A9E),
          error: Color(0xFFCF6679),
          onError: Color(0xFF370B1E),
          outline: Color(0xFFD89A9E),
        );
      case AppThemeType.pastel:
        return const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFF5CAC3),
          onPrimary: Color(0xFF5A7870),
          primaryContainer: Color(0xFF84A59D),
          onPrimaryContainer: Color(0xFFF7EDE2),
          secondary: Color(0xFFF28482),
          onSecondary: Color(0xFFF7EDE2),
          secondaryContainer: Color(0xFF5A3F3E),
          onSecondaryContainer: Color(0xFFF7EDE2),
          surface: Color(0xFF1E2A28),
          onSurface: Color(0xFFF7EDE2),
          surfaceContainerHighest: Color(0xFF283835),
          onSurfaceVariant: Color(0xFFF5CAC3),
          error: Color(0xFFCF6679),
          onError: Color(0xFF370B1E),
          outline: Color(0xFFF5CAC3),
        );
    }
  }

  static String getName(AppThemeType type) {
    switch (type) {
      case AppThemeType.tierra:
        return 'Tierra y oliva';
      case AppThemeType.otono:
        return 'Otoño cálido';
      case AppThemeType.bosque:
        return 'Bosque sereno';
      case AppThemeType.rosa:
        return 'Rosa vintage';
      case AppThemeType.pastel:
        return 'Pastel suave';
    }
  }

  static String getEmoji(AppThemeType type) {
    switch (type) {
      case AppThemeType.tierra:
        return '🌿';
      case AppThemeType.otono:
        return '🍂';
      case AppThemeType.bosque:
        return '🌲';
      case AppThemeType.rosa:
        return '🌸';
      case AppThemeType.pastel:
        return '🍑';
    }
  }
}
