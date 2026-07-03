import 'package:flutter/material.dart';

abstract class VaultColors {
  static const primary       = Color(0xFF2D2D3A);
  static const accent        = Color(0xFFFF6B35);
  static const background    = Color(0xFFF5F5F5);
  static const surface       = Color(0xFFFFFFFF);
  static const success       = Color(0xFF4CAF50);
  static const textPrimary   = Color(0xFF2D2D3A);
  static const textSecondary = Color(0xFF9E9E9E);
  static const error         = Color(0xFFE53935);
  static const divider       = Color(0xFFE0E0E0);
}

abstract class VaultTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: VaultColors.background,
      colorScheme: const ColorScheme(
        brightness:          Brightness.light,
        primary:             VaultColors.primary,
        onPrimary:           Colors.white,
        secondary:           VaultColors.accent,
        onSecondary:         Colors.white,
        error:               VaultColors.error,
        onError:             Colors.white,
        surface:             VaultColors.surface,
        onSurface:           VaultColors.textPrimary,
        onSurfaceVariant:    VaultColors.textPrimary,
        outline:             VaultColors.divider,
        outlineVariant:      VaultColors.divider,
        surfaceContainerHighest: VaultColors.surface,
        surfaceContainerHigh:    VaultColors.surface,
        surfaceContainer:        VaultColors.background,
        surfaceContainerLow:     VaultColors.background,
        surfaceContainerLowest:  VaultColors.background,
        secondaryContainer:      Color(0xFFFFE0D6),
        onSecondaryContainer:    VaultColors.primary,
        primaryContainer:        Color(0xFFE8E8F0),
        onPrimaryContainer:      VaultColors.primary,
        tertiary:                VaultColors.accent,
        onTertiary:              Colors.white,
        tertiaryContainer:       Color(0xFFFFE0D6),
        onTertiaryContainer:     VaultColors.primary,
        errorContainer:          Color(0xFFFFDAD6),
        onErrorContainer:        VaultColors.error,
        inverseSurface:          VaultColors.primary,
        onInverseSurface:        Colors.white,
        inversePrimary:          Color(0xFFB8B8C8),
        shadow:                  Colors.black,
        scrim:                   Colors.black,
        surfaceTint:             Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: VaultColors.surface,
        foregroundColor: VaultColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VaultColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VaultColors.primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: VaultColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: VaultColors.primary,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: VaultColors.divider),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: VaultColors.primary, width: 2),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: VaultColors.error),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: VaultColors.error, width: 2),
        ),
        labelStyle: TextStyle(color: VaultColors.textSecondary),
        hintStyle: TextStyle(color: VaultColors.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: VaultColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: VaultColors.divider,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: VaultColors.textPrimary,
          letterSpacing: 2,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: VaultColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: VaultColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: VaultColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          color: VaultColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          color: VaultColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          color: VaultColors.textSecondary,
        ),
      ),
    );
  }
}