import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';
import 'providers.dart';

/// Pantalla de contratación de una suscripción. Recibe el tipo (producto o
/// negocio) y muestra sus planes. Al continuar, reutiliza el flujo de pago
/// existente (PaymentMethodPage); no duplica la selección de método de pago.
class SubscriptionPage extends ConsumerWidget {
  final SubscriptionType type;

  const SubscriptionPage({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final state = ref.watch(plansControllerProvider(type));
    final controller = ref.read(plansControllerProvider(type).notifier);

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: const Text('Suscripción'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: switch (state.status) {
          PlansStatus.loading =>
            const Center(child: CircularProgressIndicator()),
          PlansStatus.error => Center(
              child: Text(
                state.errorMessage ?? 'Error al cargar los planes',
                style: tt.bodyMedium,
              ),
            ),
          PlansStatus.loaded => Padding(
              padding: const EdgeInsets.all(VaultSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: VaultSpacing.sm),
                  Text(
                    SubscriptionCopy.titleFor(type),
                    style: tt.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: VaultSpacing.xs),
                  Text(
                    SubscriptionCopy.subtitleFor(type),
                    style: tt.bodyMedium?.copyWith(
                      color: VaultColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: VaultSpacing.xl),
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.plans.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: VaultSpacing.md),
                      itemBuilder: (context, index) {
                        final plan = state.plans[index];
                        return _PlanTile(
                          plan: plan,
                          selected: plan.id == state.selected?.id,
                          onTap: () => controller.selectPlan(plan),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: VaultSpacing.md),
                  ElevatedButton.icon(
                    onPressed: state.selected == null
                        ? null
                        : () => context.push(AppRoutes.paymentMethod),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VaultColors.accent,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Continuar al pago'),
                  ),
                ],
              ),
            ),
        },
      ),
    );
  }
}

/// Tile de un plan, con el mismo lenguaje visual que los métodos de pago:
/// borde accent + radio cuando está seleccionado.
class _PlanTile extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool selected;
  final VoidCallback onTap;

  const _PlanTile({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(VaultSpacing.lg),
        decoration: BoxDecoration(
          color: VaultColors.surface,
          borderRadius: VaultRadius.cardBorder,
          border: Border.all(
            color: selected ? VaultColors.accent : VaultColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(plan.name, style: tt.titleMedium),
                ),
                Text(
                  '\$${plan.price.toStringAsFixed(0)}',
                  style: tt.titleMedium?.copyWith(
                    color: VaultColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: VaultSpacing.sm),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected
                      ? VaultColors.accent
                      : VaultColors.textSecondary,
                  size: VaultIconSize.md,
                ),
              ],
            ),
            const SizedBox(height: VaultSpacing.sm),
            ...plan.benefits.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: VaultSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check,
                      size: VaultIconSize.sm,
                      color: VaultColors.success,
                    ),
                    const SizedBox(width: VaultSpacing.sm),
                    Expanded(
                      child: Text(
                        b,
                        style: tt.bodySmall?.copyWith(
                          color: VaultColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

