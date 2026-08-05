import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';
import 'providers.dart';
import 'widgets.dart';

class OrderSuccessPage extends ConsumerStatefulWidget {
  const OrderSuccessPage({super.key});

  @override
  ConsumerState<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends ConsumerState<OrderSuccessPage>
    with TickerProviderStateMixin {
  late final OrderSummaryEntity _summary;

  late final AnimationController _circleController;
  late final Animation<double> _circleScale;

  late final AnimationController _checkController;
  late final Animation<double> _checkScale;
  late final Animation<double> _checkOpacity;

  late final AnimationController _contentController;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;

  late final AnimationController _summaryController;
  late final Animation<double> _summaryOpacity;
  late final Animation<Offset> _summarySlide;

  late final AnimationController _buttonController;
  late final Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();
    _summary = ref.read(cartControllerProvider).summary;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartControllerProvider.notifier).clear();
    });

    // 1. Círculo verde crece con bounce
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _circleScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.elasticOut),
    );

    // 2. Check aparece con bounce
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _checkScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
    _checkOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _checkController, curve: Curves.easeIn));

    // 3. Texto principal sube con fade
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );

    // 4. Resumen sube con fade
    _summaryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _summaryOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _summaryController, curve: Curves.easeOut),
    );
    _summarySlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _summaryController,
            curve: Curves.easeOutCubic,
          ),
        );

    // 5. Botón aparece con fade
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _buttonOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );

    _playSequence();
  }

  Future<void> _playSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _circleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _checkController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _contentController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _summaryController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _buttonController.forward();
  }

  @override
  void dispose() {
    _circleController.dispose();
    _checkController.dispose();
    _contentController.dispose();
    _summaryController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: VaultColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(VaultSpacing.lg),
          child: Column(
            children: [
              const Spacer(),

              // Círculo + check animados
              ScaleTransition(
                scale: _circleScale,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: VaultColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: FadeTransition(
                    opacity: _checkOpacity,
                    child: ScaleTransition(
                      scale: _checkScale,
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: VaultIconSize.xl,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: VaultSpacing.xl),

              // Texto principal
              SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _contentOpacity,
                  child: Column(
                    children: [
                      Text(
                        'Orden creada exitosamente',
                        style: tt.headlineMedium?.copyWith(
                          color: VaultColors.success,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: VaultSpacing.sm),
                      Text(
                        'Aquí tienes un resumen de tu pedido',
                        style: tt.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: VaultSpacing.xl),

              // Resumen del pedido
              SlideTransition(
                position: _summarySlide,
                child: FadeTransition(
                  opacity: _summaryOpacity,
                  child: Container(
                    padding: const EdgeInsets.all(VaultSpacing.lg),
                    decoration: BoxDecoration(
                      color: VaultColors.surface,
                      borderRadius: VaultRadius.cardBorder,
                      border: Border.all(color: VaultColors.divider),
                    ),
                    child: Column(
                      children: [
                        SummaryRow(
                          label: 'Subtotal',
                          value: '\$${_summary.subtotal.toStringAsFixed(0)}',
                        ),
                        if (_summary.discount > 0)
                          SummaryRow(
                            label: 'Descuento',
                            value: '-\$${_summary.discount.toStringAsFixed(0)}',
                          ),
                        Divider(color: VaultColors.divider),
                        SummaryRow(
                          label: 'Total',
                          value: '\$${_summary.total.toStringAsFixed(0)}',
                          emphasized: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Botón con fade
              FadeTransition(
                opacity: _buttonOpacity,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Regresar al home'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
