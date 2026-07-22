import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';
import '../../profile/domain/entities.dart';
import '../../profile/presentation/providers.dart';
import '../domain/entities.dart';
import 'providers.dart';

/// Estadísticas del usuario. Muestra secciones según lo que realmente tiene:
/// su colección si registró activos, y su actividad como especialista si
/// ofrece servicios. No depende del rol, sino de los datos reales.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(collectionStatsProvider);
    final userId = ref.watch(authControllerProvider).user?.id;
    final restorerState = userId == null
        ? null
        : ref.watch(restorerProfileControllerProvider(userId));
    final restorer = restorerState?.profile;

    final hasCollection = stats.totalAssets > 0;
    final hasServices =
        restorer != null && (restorer.services.isNotEmpty || restorer.reviewsCount > 0);

    if (!hasCollection && !hasServices) {
      return const _StatsScaffold(child: _EmptyStats());
    }

    return _StatsScaffold(
      child: ListView(
        padding: const EdgeInsets.all(VaultSpacing.md),
        children: [
          if (hasCollection) ...[
            _CollectionSection(stats: stats),
            if (hasServices) const SizedBox(height: VaultSpacing.xl),
          ],
          if (hasServices) _ServicesSection(profile: restorer),
          const SizedBox(height: VaultSpacing.xl),
        ],
      ),
    );
  }
}

class _StatsScaffold extends StatelessWidget {
  final Widget child;

  const _StatsScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: const Text('Estadísticas'),
        centerTitle: true,
      ),
      body: child,
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(VaultSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_outlined,
                size: VaultIconSize.xl, color: VaultColors.textSecondary),
            SizedBox(height: VaultSpacing.lg),
            Text(
              'Aún no hay datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VaultColors.textPrimary,
              ),
            ),
            SizedBox(height: VaultSpacing.sm),
            Text(
              'Registra activos u ofrece servicios para ver tus estadísticas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: VaultColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estadísticas de la colección de activos.
class _CollectionSection extends StatelessWidget {
  final CollectionStats stats;

  const _CollectionSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final money = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mi colección', style: tt.titleMedium),
        const SizedBox(height: VaultSpacing.sm),
        _ValueHighlight(
          label: 'Valor total',
          value: money.format(stats.totalValue),
        ),
        const SizedBox(height: VaultSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.inventory_2_outlined,
                label: 'Activos',
                value: '${stats.totalAssets}',
              ),
            ),
            const SizedBox(width: VaultSpacing.md),
            Expanded(
              child: _StatCard(
                icon: Icons.payments_outlined,
                label: 'Valor promedio',
                value: money.format(stats.averageValue),
              ),
            ),
          ],
        ),
        const SizedBox(height: VaultSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.sell_outlined,
                label: 'En venta',
                value: '${stats.forSaleCount}',
                accent: true,
              ),
            ),
            const SizedBox(width: VaultSpacing.md),
            Expanded(
              child: _StatCard(
                icon: Icons.public,
                label: 'Publicados',
                value: '${stats.publishedCount}',
              ),
            ),
          ],
        ),
        const SizedBox(height: VaultSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.verified_user_outlined,
                label: 'Verificados',
                value: '${stats.verifiedCount}',
              ),
            ),
            const SizedBox(width: VaultSpacing.md),
            Expanded(
              child: _StatCard(
                icon: Icons.build_outlined,
                label: 'Mantenimientos',
                value: '${stats.servicesCount + stats.restorationsCount}',
              ),
            ),
          ],
        ),
        const SizedBox(height: VaultSpacing.lg),
        Text('Por categoría', style: tt.titleMedium),
        const SizedBox(height: VaultSpacing.sm),
        _CategoryBreakdown(stats: stats),
      ],
    );
  }
}

/// Estadísticas como especialista: servicios ofrecidos y reputación.
class _ServicesSection extends StatelessWidget {
  final RestorerProfileEntity profile;

  const _ServicesSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Como especialista', style: tt.titleMedium),
        const SizedBox(height: VaultSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.handyman_outlined,
                label: 'Servicios',
                value: '${profile.services.length}',
              ),
            ),
            const SizedBox(width: VaultSpacing.md),
            Expanded(
              child: _StatCard(
                icon: Icons.star_outline,
                label: 'Calificación',
                value: profile.rating > 0
                    ? profile.rating.toStringAsFixed(1)
                    : '--',
              ),
            ),
          ],
        ),
        const SizedBox(height: VaultSpacing.md),
        _StatCard(
          icon: Icons.reviews_outlined,
          label: 'Reseñas recibidas',
          value: '${profile.reviewsCount}',
        ),
      ],
    );
  }
}

/// Tarjeta destacada con el valor total, en navy para dar jerarquía.
class _ValueHighlight extends StatelessWidget {
  final String label;
  final String value;

  const _ValueHighlight({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(VaultSpacing.lg),
      decoration: BoxDecoration(
        color: VaultColors.primary,
        borderRadius: VaultRadius.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: tt.labelSmall?.copyWith(color: Colors.white70)),
          const SizedBox(height: VaultSpacing.xs),
          Text(
            value,
            style: tt.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de una métrica. [accent] se usa solo para señales de comercio.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool accent;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = accent ? VaultColors.accent : VaultColors.primary;

    return Container(
      padding: const EdgeInsets.all(VaultSpacing.md),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        border: Border.all(color: VaultColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: VaultIconSize.md),
          const SizedBox(height: VaultSpacing.sm),
          Text(
            value,
            style: tt.titleLarge?.copyWith(
              color: VaultColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: tt.labelSmall?.copyWith(color: VaultColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Desglose por categoría con barras proporcionales.
class _CategoryBreakdown extends StatelessWidget {
  final CollectionStats stats;

  const _CategoryBreakdown({required this.stats});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final entries = stats.byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = entries.first.value;

    return Container(
      padding: const EdgeInsets.all(VaultSpacing.md),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        border: Border.all(color: VaultColors.divider),
      ),
      child: Column(
        children: [
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: VaultSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key.displayName, style: tt.bodyMedium),
                      Text(
                        '${entry.value}',
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: VaultColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: VaultSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(VaultRadius.sm),
                    child: LinearProgressIndicator(
                      value: entry.value / maxCount,
                      minHeight: 6,
                      backgroundColor: VaultColors.background,
                      valueColor: const AlwaysStoppedAnimation(
                        VaultColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

