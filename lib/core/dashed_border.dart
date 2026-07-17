import 'package:flutter/material.dart';

/// Contorno punteado para las zonas de "agregar imagen" (foto de perfil,
/// fotos de un activo/negocio, imágenes de un post) -- las distingue
/// visualmente de un card normal, cuyo borde es sólido.
class DashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderRadius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final BoxShape shape;

  const DashedBorder({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius = 16,
    this.strokeWidth = 1.5,
    this.dashLength = 5,
    this.gapLength = 4,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        borderRadius: borderRadius,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        gapLength: gapLength,
        shape: shape,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final BoxShape shape;

  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
    required this.shape,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
        inset, inset, size.width - strokeWidth, size.height - strokeWidth);

    final path = Path();
    if (shape == BoxShape.circle) {
      path.addOval(rect);
    } else {
      path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)));
    }

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        borderRadius != oldDelegate.borderRadius ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashLength != oldDelegate.dashLength ||
        gapLength != oldDelegate.gapLength ||
        shape != oldDelegate.shape;
  }
}
