import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/skeleton.dart';
import '../../auth/presentation/providers.dart';
import '../../business/domain/entities.dart';
import '../../business/presentation/providers.dart';
import '../../chat/presentation/chat_page.dart';

/// Directorio de especialistas: quien ofrece que servicio.
///
/// Lo ve cualquier usuario, sin importar su rol. Desde aqui un coleccionista
/// puede encontrar a alguien que restaure o repare sus activos. El catálogo
/// de cada negocio vive en `businesses/{id}/services` (ver
/// `businessservices` en `api/`).
class ServicesDirectoryPage extends ConsumerWidget {
  const ServicesDirectoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(allBusinessesProvider);
    return businessesAsync.when(
        loading: () => const _DirectorySkeleton(),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(VaultSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'No se pudieron cargar los servicios',
                  style: TextStyle(color: VaultColors.textSecondary),
                ),
                const SizedBox(height: VaultSpacing.md),
                ElevatedButton(
                  onPressed: () => ref.invalidate(allBusinessesProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (businesses) {
          if (businesses.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(VaultSpacing.xl),
                child: Text(
                  'Aún no hay especialistas con servicios publicados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: VaultColors.textSecondary),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allBusinessesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(VaultSpacing.md),
              itemCount: businesses.length,
              itemBuilder: (context, index) =>
                  _BusinessCard(business: businesses[index]),
            ),
          );
        },
    );
  }
}

/// Tarjeta de un negocio con los servicios que ofrece.
class _BusinessCard extends ConsumerWidget {
  final BusinessEntity business;

  const _BusinessCard({required this.business});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final currentUserId = ref.watch(authControllerProvider).user?.id;
    final isSelf = currentUserId != null && currentUserId == business.userId;
    final servicesState = ref.watch(businessServicesControllerProvider(business.id));

    return Container(
      margin: const EdgeInsets.only(bottom: VaultSpacing.md),
      padding: const EdgeInsets.all(VaultSpacing.md),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: VaultColors.background,
                  borderRadius: BorderRadius.circular(VaultRadius.sm),
                ),
                child: const Icon(
                  Icons.build_outlined,
                  color: VaultColors.primary,
                  size: VaultIconSize.md,
                ),
              ),
              const SizedBox(width: VaultSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name.isNotEmpty ? business.name : 'Especialista',
                      style: tt.titleSmall,
                    ),
                    Text(
                      '${servicesState.services.length} servicios',
                      style: tt.labelSmall?.copyWith(color: VaultColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (!isSelf)
                TextButton.icon(
                  onPressed: () => context.push(
                    AppRoutes.chat,
                    extra: ChatPageArgs(
                      recipientId: business.userId,
                      recipientName: business.name.isNotEmpty ? business.name : 'Especialista',
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: VaultColors.primary,
                  ),
                  icon: const Icon(Icons.chat_bubble_outline,
                      size: VaultIconSize.sm),
                  label: const Text('Contactar'),
                ),
            ],
          ),
          if (business.description.isNotEmpty) ...[
            const SizedBox(height: VaultSpacing.sm),
            Text(
              business.description,
              style: tt.bodyMedium?.copyWith(color: VaultColors.textSecondary),
            ),
          ],
          const SizedBox(height: VaultSpacing.md),
          if (servicesState.status == BusinessServicesStatus.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: VaultSpacing.sm),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (servicesState.services.isEmpty)
            Text(
              'Sin servicios publicados todavía.',
              style: tt.labelSmall?.copyWith(color: VaultColors.textSecondary),
            )
          else
            ...servicesState.services.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: VaultSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service.title, style: tt.bodyLarge),
                          if (service.description.isNotEmpty)
                            Text(
                              service.description,
                              style: tt.labelSmall?.copyWith(
                                color: VaultColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: VaultSpacing.sm),
                    Text(
                      service.price > 0
                          ? '\$${service.price.toStringAsFixed(0)}'
                          : 'A convenir',
                      style: tt.titleSmall?.copyWith(color: VaultColors.accent),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DirectorySkeleton extends StatelessWidget {
  const _DirectorySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(VaultSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: VaultSpacing.md),
        padding: const EdgeInsets.all(VaultSpacing.md),
        decoration: BoxDecoration(
          color: VaultColors.surface,
          borderRadius: VaultRadius.cardBorder,
          border: Border.all(color: VaultColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 44, height: 44),
            const SizedBox(width: VaultSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonLine(widthFactor: 0.4, height: 14),
                  SizedBox(height: VaultSpacing.sm),
                  SkeletonLine(widthFactor: 0.9),
                  SizedBox(height: VaultSpacing.xs),
                  SkeletonLine(widthFactor: 0.6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
