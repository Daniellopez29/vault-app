import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/animated_counter.dart';
import '../../auth/presentation/providers.dart';
import '../../business/presentation/providers.dart';
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

    final businessId = ref.watch(businessControllerProvider).business?.id;
    final servicesCount = businessId == null
        ? 0
        : ref
              .watch(businessServicesControllerProvider(businessId))
              .services
              .length;

    final hasCollection = stats.totalAssets > 0;
    final hasServices =
        restorer != null && (servicesCount > 0 || restorer.reviewsCount > 0);

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
          if (hasServices)
            _ServicesSection(profile: restorer!, servicesCount: servicesCount),
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
      appBar: AppBar(title: const Text('Estadísticas'), centerTitle: true),
      body: child,
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(VaultSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insights_outlined,
              size: VaultIconSize.xl,
              color: VaultColors.textSecondary,
            ),
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

/// Estadísticas de la colección de activos con contadores animados.
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
        _AnimatedValueHighlight(
          label: 'Valor total',
          targetValue: stats.totalValue,
        ),
        const SizedBox(height: VaultSpacing.md),
        Row(
          children: [
            Expanded(
              child: _AnimatedStatCard(
                icon: Icons.inventory_2_outlined,
                label: 'Activos',
                targetValue: stats.totalAssets.toDouble(),
                formatValue: (v) => '${v.round()}',
              ),
            ),
            const SizedBox(width: VaultSpacing.md),
            Expanded(
              child: _AnimatedStatCard(
                icon: Icons.payments_outlined,
                label: 'Valor promedio',
                targetValue: stats.averageValue,
                formatValue: (v) => money.format(v),
              ),
            ),
          ],
        ),
        const SizedBox(height: VaultSpacing.md),
        Row(
          children: [
            Expanded(
              child: _AnimatedStatCard(
                icon: Icons.sell_outlined,
                label: 'En venta',
                targetValue: stats.forSaleCount.toDouble(),
                formatValue: (v) => '${v.round()}',
                accent: true,
              ),
            ),
            const SizedBox(width: VaultSpacing.md),
            Expanded(
              child: _AnimatedStatCard(
                icon: Icons.public,
                label: 'Publicados',
                targetValue: stats.publishedCount.toDouble(),
                formatValue: (v) => '${v.round()}',
              ),
            ),
          ],
        ),
        const SizedBox(height: VaultSpacing.md),
        Row(
          children: [
            Expanded(
              child: _AnimatedStatCard(
                icon: Icons.verified_user_outlined,
                label: 'Verificados',
                targetValue: stats.verifiedCount.toDouble(),
                formatValue: (v) => '${v.round()}',
              ),
            ),
            const SizedBox(width: VaultSpacing.md),
            Expanded(
              child: _AnimatedStatCard(
                icon: Icons.build_outlined,
                label: 'Mantenimientos',
                targetValue: (stats.servicesCount + stats.restorationsCount)
                    .toDouble(),
                formatValue: (v) => '${v.round()}',
              ),
            ),
          ],
        ),
        const SizedBox(height: VaultSpacing.lg),
        Text('Por categoría', style: tt.titleMedium),
        const SizedBox(height: VaultSpacing.sm),
        _AnimatedCategoryBreakdown(stats: stats),
      ],
    );
  }
}

/// Estadísticas como especialista: servicios ofrecidos y reputación.
class _ServicesSection extends StatelessWidget {
  final RestorerProfileEntity profile;
  final int servicesCount;

  const _ServicesSection({required this.profile, required this.servicesCount});

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
              child: _AnimatedStatCard(
                icon: Icons.handyman_outlined,
                label: 'Servicios',
                targetValue: servicesCount.toDouble(),
                formatValue: (v) => '${v.round()}',
              ),
            ),
            const SizedBox(width: VaultSpacing.md),
            Expanded(
              child: _AnimatedStatCard(
                icon: Icons.star_outline,
                label: 'Calificación',
                targetValue: profile.rating,
                formatValue: (v) => v > 0 ? v.toStringAsFixed(1) : '--',
              ),
            ),
          ],
        ),
        const SizedBox(height: VaultSpacing.md),
        _AnimatedStatCard(
          icon: Icons.reviews_outlined,
          label: 'Reseñas recibidas',
          targetValue: profile.reviewsCount.toDouble(),
          formatValue: (v) => '${v.round()}',
        ),
      ],
    );
  }
}

/// Tarjeta destacada con el valor total animado, en navy para dar jerarquía.
class _AnimatedValueHighlight extends StatelessWidget {
  final String label;
  final double targetValue;

  const _AnimatedValueHighlight({
    required this.label,
    required this.targetValue,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final money = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

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
          AnimatedCounter(
            end: targetValue,
            duration: const Duration(milliseconds: 1500),
            formatValue: (v) => money.format(v),
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

/// Tarjeta de una métrica con contador animado.
class _AnimatedStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double targetValue;
  final String Function(double) formatValue;
  final bool accent;

  const _AnimatedStatCard({
    required this.icon,
    required this.label,
    required this.targetValue,
    required this.formatValue,
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
          AnimatedCounter(
            end: targetValue,
            duration: const Duration(milliseconds: 1200),
            formatValue: formatValue,
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

/// Desglose por categoría con barras animadas proporcionales.
class _AnimatedCategoryBreakdown extends StatelessWidget {
  final CollectionStats stats;

  const _AnimatedCategoryBreakdown({required this.stats});

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
          for (var i = 0; i < entries.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: VaultSpacing.md),
              child: _AnimatedCategoryRow(
                category: entries[i].key.displayName,
                count: entries[i].value,
                fraction: entries[i].value / maxCount,
                delay: Duration(milliseconds: 150 * i),
              ),
            ),
        ],
      ),
    );
  }
}

/// Fila de categoría individual con barra y contador animados.
class _AnimatedCategoryRow extends StatefulWidget {
  final String category;
  final int count;
  final double fraction;
  final Duration delay;

  const _AnimatedCategoryRow({
    required this.category,
    required this.count,
    required this.fraction,
    required this.delay,
  });

  @override
  State<_AnimatedCategoryRow> createState() => _AnimatedCategoryRowState();
}

class _AnimatedCategoryRowState extends State<_AnimatedCategoryRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _barAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _barAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.category, style: tt.bodyMedium),
            AnimatedCounter(
              end: widget.count.toDouble(),
              duration: const Duration(milliseconds: 1000),
              formatValue: (v) => '${v.round()}',
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: VaultColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: VaultSpacing.xs),
        AnimatedBuilder(
          animation: _barAnimation,
          builder: (context, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(VaultRadius.sm),
              child: LinearProgressIndicator(
                value: widget.fraction * _barAnimation.value,
                minHeight: 6,
                backgroundColor: VaultColors.background,
                valueColor: AlwaysStoppedAnimation(VaultColors.primary),
              ),
            );
          },
        ),
      ],
    );
  }
}
