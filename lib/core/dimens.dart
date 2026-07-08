import 'package:flutter/material.dart';
import 'theme.dart';

/// Tokens de espaciado. Escala base de 4 en 4.
/// Usar SIEMPRE en lugar de números sueltos en EdgeInsets, SizedBox, gap, etc.
abstract class VaultSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Radios de esquina. Deben coincidir con los del theme (cards, botones).
abstract class VaultRadius {
  static const sm = 8.0;
  static const button = 12.0;
  static const card = 16.0;

  static BorderRadius get cardBorder => BorderRadius.circular(card);
  static BorderRadius get buttonBorder => BorderRadius.circular(button);
}

/// Tamaños de íconos, para no repartir `size:` mágicos por los widgets.
abstract class VaultIconSize {
  static const sm = 18.0;
  static const md = 22.0;
  static const lg = 26.0;
  static const xl = 48.0;
}

/// Sombras centralizadas. Tu estética es flat (elevation 0), así que
/// el default es SIN sombra. Un único lugar decide si algo eleva.
abstract class VaultShadows {
  static const none = <BoxShadow>[];

  /// Sombra sutil para cards que sí necesiten separarse del fondo.
  static List<BoxShadow> get card => [
    BoxShadow(
      color: VaultColors.primary.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}