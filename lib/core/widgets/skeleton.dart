import 'package:flutter/material.dart';
import '../dimens.dart';
import '../theme.dart';

/// Bloque con efecto shimmer deslizante, usado para armar esqueletos de carga.
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
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (reduceMotion) {
      return _staticBox();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => _shimmerBox(),
    );
  }

  Widget _staticBox() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: VaultColors.divider.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(widget.radius),
      ),
    );
  }

  Widget _shimmerBox() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        gradient: LinearGradient(
          begin: Alignment(-1.0 + (2.0 * _controller.value), 0),
          end: Alignment(-1.0 + (2.0 * _controller.value) + 1.0, 0),
          colors: [
            VaultColors.divider.withValues(alpha: 0.3),
            VaultColors.divider.withValues(alpha: 0.7),
            VaultColors.divider.withValues(alpha: 0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
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