import 'package:flutter/material.dart';
import '../dimens.dart';
import '../theme.dart';

/// Botón que al activarse muestra un relleno progresivo de izquierda a
/// derecha, al estilo de apps de pago. Cuando termina la animación de
/// relleno ejecuta [onCompleted].
///
/// Dos estados: idle (esperando toque) y filling (animando).
/// El caller controla cuándo arranca con [filling] y escucha [onCompleted].
class FillButton extends StatefulWidget {
  final String label;
  final String fillingLabel;
  final IconData? icon;
  final bool filling;
  final bool enabled;
  final VoidCallback? onPressed;
  final VoidCallback? onCompleted;
  final Duration fillDuration;
  final Color backgroundColor;
  final Color fillColor;
  final Color foregroundColor;

  const FillButton({
    super.key,
    required this.label,
    this.fillingLabel = 'Procesando...',
    this.icon,
    this.filling = false,
    this.enabled = true,
    this.onPressed,
    this.onCompleted,
    this.fillDuration = const Duration(milliseconds: 1800),
    this.backgroundColor = VaultColors.accent,
    this.fillColor = const Color(0xFFE55A2B),
    this.foregroundColor = Colors.white,
  });

  @override
  State<FillButton> createState() => _FillButtonState();
}

class _FillButtonState extends State<FillButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.fillDuration,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted?.call();
      }
    });

    if (widget.filling) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant FillButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filling && !oldWidget.filling) {
      _controller.forward(from: 0);
    } else if (!widget.filling && oldWidget.filling) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && !widget.filling;

    return GestureDetector(
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: enabled
                  ? widget.backgroundColor
                  : widget.backgroundColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(VaultRadius.button),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Barra de relleno progresivo
                if (widget.filling)
                  FractionallySizedBox(
                    widthFactor: _controller.value,
                    heightFactor: 1.0,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.fillColor,
                        borderRadius: BorderRadius.circular(VaultRadius.button),
                      ),
                    ),
                  ),
                // Contenido centrado
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null && !widget.filling) ...[
                        Icon(widget.icon, color: widget.foregroundColor, size: VaultIconSize.md),
                        const SizedBox(width: VaultSpacing.sm),
                      ],
                      if (widget.filling) ...[
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: widget.foregroundColor,
                          ),
                        ),
                        const SizedBox(width: VaultSpacing.sm),
                      ],
                      Text(
                        widget.filling ? widget.fillingLabel : widget.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.foregroundColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}