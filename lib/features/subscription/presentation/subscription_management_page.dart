import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';
import 'providers.dart';

/// Pantalla "Mi suscripción": estado de la suscripción propia (si existe),
/// con opción de cancelarla. Reemplaza el vacío que quedaba después de
/// pagar -- antes no había ningún lugar para ver ni administrar lo que se
/// acababa de contratar.
class SubscriptionManagementPage extends ConsumerWidget {
  const SubscriptionManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionStatusControllerProvider);

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(title: const Text('Mi suscripción')),
      body: SafeArea(
        child: switch (state.status) {
          SubscriptionStatusLoad.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          SubscriptionStatusLoad.error => Center(
            child: Padding(
              padding: const EdgeInsets.all(VaultSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Error al cargar tu suscripción'),
                  const SizedBox(height: VaultSpacing.md),
                  TextButton(
                    onPressed: () => ref
                        .read(subscriptionStatusControllerProvider.notifier)
                        .load(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
          SubscriptionStatusLoad.loaded =>
            state.subscription == null
                ? const _NoSubscriptionView()
                : _ActiveSubscriptionView(
                    subscription: state.subscription!,
                    state: state,
                  ),
        },
      ),
    );
  }
}

class _NoSubscriptionView extends StatelessWidget {
  const _NoSubscriptionView();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VaultSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 56,
              color: VaultColors.textSecondary,
            ),
            const SizedBox(height: VaultSpacing.md),
            Text(
              'Todavía no tienes una suscripción activa',
              textAlign: TextAlign.center,
              style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: VaultSpacing.xs),
            Text(
              'Contrata un plan para anunciar tus productos o tu negocio.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium,
            ),
            const SizedBox(height: VaultSpacing.lg),
            ElevatedButton(
              onPressed: () => context.push(
                AppRoutes.subscription,
                extra: SubscriptionType.product,
              ),
              child: const Text('Ver planes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveSubscriptionView extends ConsumerWidget {
  final SubscriptionStatus subscription;
  final SubscriptionStatusState state;

  const _ActiveSubscriptionView({
    required this.subscription,
    required this.state,
  });

  void _confirmCancel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar suscripción'),
        content: const Text(
          '¿Estás seguro? Perderás tus anuncios activos y los beneficios del plan '
          'al final del periodo actual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final ok = await ref
                  .read(subscriptionStatusControllerProvider.notifier)
                  .cancel();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok
                        ? 'Suscripción cancelada'
                        : ref
                                  .read(subscriptionStatusControllerProvider)
                                  .errorMessage ??
                              'No se pudo cancelar la suscripción',
                  ),
                ),
              );
            },
            child: Text(
              'Cancelar suscripción',
              style: TextStyle(color: VaultColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    // Los planes no dependen del tipo (ver SubscriptionPlan), 'product' solo
    // fija el copy de la pantalla de planes -- reutilizamos la misma lista
    // para cruzar el nombre del plan contratado.
    final plans = ref
        .watch(plansControllerProvider(SubscriptionType.product))
        .plans;
    final plan = plans.where((p) => p.id == subscription.planId).firstOrNull;
    final renewalDate = DateFormat(
      'dd/MM/yyyy',
    ).format(subscription.currentPeriodEnd);

    return ListView(
      padding: const EdgeInsets.all(VaultSpacing.lg),
      children: [
        Container(
          padding: const EdgeInsets.all(VaultSpacing.lg),
          decoration: BoxDecoration(
            color: VaultColors.surface,
            borderRadius: VaultRadius.cardBorder,
            border: Border.all(color: VaultColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium_outlined,
                    color: VaultColors.accent,
                  ),
                  const SizedBox(width: VaultSpacing.sm),
                  Expanded(
                    child: Text(
                      plan?.name ?? subscription.planId,
                      style: tt.titleMedium,
                    ),
                  ),
                  _StatusChip(
                    active: subscription.isActive,
                    status: subscription.status,
                  ),
                ],
              ),
              const SizedBox(height: VaultSpacing.md),
              _row(
                context,
                subscription.status == 'canceled'
                    ? 'Vigente hasta'
                    : 'Próxima renovación',
                renewalDate,
              ),
              if (plan != null) ...[
                const SizedBox(height: VaultSpacing.sm),
                ...plan.benefits.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(top: VaultSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
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
            ],
          ),
        ),
        if (subscription.isActive) ...[
          const SizedBox(height: VaultSpacing.xl),
          OutlinedButton(
            onPressed: state.canceling
                ? null
                : () => _confirmCancel(context, ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: VaultColors.error,
              side: BorderSide(color: VaultColors.error),
            ),
            child: state.canceling
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Cancelar suscripción'),
          ),
        ],
      ],
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: VaultColors.textSecondary)),
          Text(value, style: TextStyle(color: VaultColors.textPrimary)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool active;
  final String status;

  const _StatusChip({required this.active, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VaultSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: active ? VaultColors.success : VaultColors.textSecondary,
        borderRadius: BorderRadius.circular(VaultRadius.sm),
      ),
      child: Text(
        active ? 'Activa' : status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
