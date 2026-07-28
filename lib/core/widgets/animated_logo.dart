import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Logo animado con giro 3D periódico en el eje Y.
///
/// Cada [pauseDuration] el logo hace un spin completo de 360° con efecto
/// de perspectiva 3D, luego descansa. Respeta "reducir movimiento".
class VaultAnimatedLogo extends StatefulWidget {
  final double height;
  final String assetPath;
  final Duration spinDuration;
  final Duration pauseDuration;

  const VaultAnimatedLogo({
    super.key,
    this.height = 140,
    this.assetPath = 'assets/images/logo_login.png',
    this.spinDuration = const Duration(milliseconds: 1200),
    this.pauseDuration = const Duration(seconds: 4),
  });

  @override
  State<VaultAnimatedLogo> createState() => _VaultAnimatedLogoState();
}

class _VaultAnimatedLogoState extends State<VaultAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.spinDuration,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startLoop();
  }

  Future<void> _startLoop() async {
    while (mounted) {
      await Future.delayed(widget.pauseDuration);
      if (!mounted) return;
      await _controller.forward(from: 0);
    }
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
      return Image.asset(widget.assetPath, height: widget.height);
    }

    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_rotationAnimation.value),
          child: child,
        );
      },
      child: Image.asset(widget.assetPath, height: widget.height),
    );
  }
}