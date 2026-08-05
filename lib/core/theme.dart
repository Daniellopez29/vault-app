import 'package:flutter/material.dart';

class _LightPalette {
  static const primary = Color(0xFF2D2D3A);
  static const accent = Color(0xFFFF6B35);
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const success = Color(0xFF4CAF50);
  static const textPrimary = Color(0xFF2D2D3A);
  static const textSecondary = Color(0xFF9E9E9E);
  static const error = Color(0xFFE53935);
  static const divider = Color(0xFFE0E0E0);
}

class _DarkPalette {
  static const primary = Color(0xFF6B6B85);
  static const accent = Color(0xFFFF7A47);
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E22);
  static const success = Color(0xFF66BB6A);
  static const textPrimary = Color(0xFFECECEC);
  static const textSecondary = Color(0xFFA0A0AA);
  static const error = Color(0xFFEF5350);
  static const divider = Color(0xFF3A3A40);
}

/// Colores usados fuera de `ColorScheme` (contenedores, íconos, bordes
/// dibujados a mano). Se resuelven según el `Brightness` activo, que
/// [VaultTheme.syncBrightness] mantiene sincronizado con el `themeMode` real
/// de `MaterialApp` -- así cada pantalla sigue usando `VaultColors.x` sin
/// tener que leer el modo oscuro por su cuenta.
abstract class VaultColors {
  static Brightness _brightness = Brightness.light;
  static bool get _dark => _brightness == Brightness.dark;

  static Color get primary =>
      _dark ? _DarkPalette.primary : _LightPalette.primary;
  static Color get accent => _dark ? _DarkPalette.accent : _LightPalette.accent;
  static Color get background =>
      _dark ? _DarkPalette.background : _LightPalette.background;
  static Color get surface =>
      _dark ? _DarkPalette.surface : _LightPalette.surface;
  static Color get success =>
      _dark ? _DarkPalette.success : _LightPalette.success;
  static Color get textPrimary =>
      _dark ? _DarkPalette.textPrimary : _LightPalette.textPrimary;
  static Color get textSecondary =>
      _dark ? _DarkPalette.textSecondary : _LightPalette.textSecondary;
  static Color get error => _dark ? _DarkPalette.error : _LightPalette.error;
  static Color get divider =>
      _dark ? _DarkPalette.divider : _LightPalette.divider;
}

abstract class VaultTheme {
  /// Debe llamarse cada vez que cambia el modo oscuro (ver
  /// `ThemeModeController` en `core/providers.dart`), antes del rebuild que
  /// dispara el cambio de `themeMode`, para que los `VaultColors.x` estáticos
  /// coincidan con el `ThemeData` que `MaterialApp` está por aplicar.
  static void syncBrightness(Brightness brightness) {
    VaultColors._brightness = brightness;
  }

  static ThemeData get light => _build(
    brightness: Brightness.light,
    primary: _LightPalette.primary,
    accent: _LightPalette.accent,
    background: _LightPalette.background,
    surface: _LightPalette.surface,
    success: _LightPalette.success,
    textPrimary: _LightPalette.textPrimary,
    textSecondary: _LightPalette.textSecondary,
    error: _LightPalette.error,
    divider: _LightPalette.divider,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    primary: _DarkPalette.primary,
    accent: _DarkPalette.accent,
    background: _DarkPalette.background,
    surface: _DarkPalette.surface,
    success: _DarkPalette.success,
    textPrimary: _DarkPalette.textPrimary,
    textSecondary: _DarkPalette.textSecondary,
    error: _DarkPalette.error,
    divider: _DarkPalette.divider,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color accent,
    required Color background,
    required Color surface,
    required Color success,
    required Color textPrimary,
    required Color textSecondary,
    required Color error,
    required Color divider,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
        onSurfaceVariant: textPrimary,
        outline: divider,
        outlineVariant: divider,
        surfaceContainerHighest: surface,
        surfaceContainerHigh: surface,
        surfaceContainer: background,
        surfaceContainerLow: background,
        surfaceContainerLowest: background,
        secondaryContainer: brightness == Brightness.dark
            ? const Color(0xFF4A3226)
            : const Color(0xFFFFE0D6),
        onSecondaryContainer: brightness == Brightness.dark
            ? Colors.white
            : primary,
        primaryContainer: brightness == Brightness.dark
            ? const Color(0xFF33333F)
            : const Color(0xFFE8E8F0),
        onPrimaryContainer: brightness == Brightness.dark
            ? Colors.white
            : primary,
        tertiary: accent,
        onTertiary: Colors.white,
        tertiaryContainer: brightness == Brightness.dark
            ? const Color(0xFF4A3226)
            : const Color(0xFFFFE0D6),
        onTertiaryContainer: brightness == Brightness.dark
            ? Colors.white
            : primary,
        errorContainer: brightness == Brightness.dark
            ? const Color(0xFF4A2422)
            : const Color(0xFFFFDAD6),
        onErrorContainer: error,
        inverseSurface: textPrimary,
        onInverseSurface: background,
        inversePrimary: const Color(0xFFB8B8C8),
        shadow: Colors.black,
        scrim: Colors.black,
        surfaceTint: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: error)),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: error, width: 2),
        ),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(color: divider, thickness: 1),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: textPrimary,
          letterSpacing: 2,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 14, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 13, color: textSecondary),
        labelSmall: TextStyle(fontSize: 11, color: textSecondary),
      ),
    );
  }
}
