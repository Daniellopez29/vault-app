import 'package:flutter/material.dart';

/// Contador animado que interpola desde [begin] hasta [end] con easing.
///
/// Soporta prefijo y sufijo para formatos tipo "$1,200" o "24 items".
/// Usa [formatValue] para personalizar el formato del número.
class AnimatedCounter extends StatelessWidget {
  final double begin;
  final double end;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;
  final String Function(double value) formatValue;

  const AnimatedCounter({
    super.key,
    this.begin = 0,
    required this.end,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
    this.style,
    required this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, _) {
        return Text(
          formatValue(value),
          style: style,
        );
      },
    );
  }
}