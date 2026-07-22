import 'package:flutter/material.dart';
import '../dimens.dart';
import '../theme.dart';

/// Bloque gris que pulsa suavemente, usado para armar esqueletos de carga.
///
/// Vive en core porque lo usan varias features. Cada pantalla compone sus
/// propios esqueletos con estas piezas, respetando la forma de su contenido.
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = VaultRadius.sm,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respeta la preferencia de accesibilidad "reducir movimiento".
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (reduceMotion) {
      return _box(0.55);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => _box(0.35 + (_controller.value * 0.35)),
    );
  }

  Widget _box(double opacity) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: VaultColors.textSecondary.withValues(alpha: opacity * 0.4),
        borderRadius: BorderRadius.circular(widget.radius),
      ),
    );
  }
}

/// Línea de texto simulada. Ancho relativo para que las líneas no queden
/// todas iguales y se vea natural.
class SkeletonLine extends StatelessWidget {
  final double widthFactor;
  final double height;

  const SkeletonLine({
    super.key,
    this.widthFactor = 1.0,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: SkeletonBox(height: height),
    );
  }
}

