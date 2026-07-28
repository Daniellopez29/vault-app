import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';

/// Texto de marca que cicla entre "VAULT" y categorías de activos con
/// una animación de fade + slide vertical.
class AnimatedBrandText extends StatefulWidget {
  final TextStyle? style;
  final Duration displayDuration;
  final Duration transitionDuration;

  const AnimatedBrandText({
    super.key,
    this.style,
    this.displayDuration = const Duration(seconds: 3),
    this.transitionDuration = const Duration(milliseconds: 600),
  });

  @override
  State<AnimatedBrandText> createState() => _AnimatedBrandTextState();
}

class _AnimatedBrandTextState extends State<AnimatedBrandText>
    with SingleTickerProviderStateMixin {
  static const _words = ['VAULT', 'SNEAKERS', 'RELOJES', 'BOLSOS', 'GORRAS', 'LENTES'];

  int _currentIndex = 0;
  int _nextIndex = 1;
  late final AnimationController _controller;
  late final Animation<double> _fadeOut;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideOut;
  late final Animation<Offset> _slideIn;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.transitionDuration,
    );

    _fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1, curve: Curves.easeOut),
      ),
    );
    _slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.4),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex = _nextIndex;
          _nextIndex = (_nextIndex + 1) % _words.length;
        });
        _controller.reset();
      }
    });

    _startCycle();
  }

  void _startCycle() {
    _timer = Timer.periodic(widget.displayDuration, (_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (reduceMotion) {
      return Text('VAULT', style: _effectiveStyle);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final isFirstHalf = _controller.value <= 0.5;

        return SlideTransition(
          position: isFirstHalf ? _slideOut : _slideIn,
          child: FadeTransition(
            opacity: isFirstHalf ? _fadeOut : _fadeIn,
            child: Text(
              isFirstHalf ? _words[_currentIndex] : _words[_nextIndex],
              style: _effectiveStyle,
            ),
          ),
        );
      },
    );
  }

  TextStyle get _effectiveStyle =>
      widget.style ??
      const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        color: VaultColors.primary,
      );
}