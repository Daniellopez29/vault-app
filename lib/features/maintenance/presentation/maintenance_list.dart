import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';
import 'providers.dart';

/// Historial de mantenimiento de un activo -- lo usa tanto el dueño (en
/// [AssetDetailPage], con el botón para agregar entradas) como cualquier
/// comprador viendo el detalle de un producto en venta (de solo lectura,
/// ver [ProductDetailPage]). Es un [Column] (no un [ListView]) a propósito,
/// para poder embeberse dentro de otra lista sin pelear por el alto.
class MaintenanceList extends StatelessWidget {
  final MaintenanceState state;

  const MaintenanceList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case MaintenanceStatus.loading:
        return const Padding(
          padding: EdgeInsets.all(VaultSpacing.lg),
          child: Center(child: CircularProgressIndicator()),
        );
      case MaintenanceStatus.error:
        return Padding(
          padding: const EdgeInsets.all(VaultSpacing.lg),
          child: Center(
            child: Text(state.errorMessage ?? 'Error al cargar el historial'),
          ),
        );
      case MaintenanceStatus.loaded:
        if (state.entries.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(VaultSpacing.xl),
            child: Center(
              child: Text(
                'Sin registros de mantenimiento todavía.',
                style: TextStyle(color: VaultColors.textSecondary),
              ),
            ),
          );
        }
        return Column(
          children: state.entries.map((e) => MaintenanceTile(entry: e)).toList(),
        );
    }
  }
}

class MaintenanceTile extends StatelessWidget {
  final MaintenanceEntry entry;

  const MaintenanceTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final dateStr = DateFormat('dd/MM/yyyy').format(entry.date);

    return Container(
      margin: const EdgeInsets.only(bottom: VaultSpacing.sm),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(entry.type.displayName, style: tt.titleSmall),
              Text(dateStr, style: const TextStyle(color: VaultColors.textSecondary)),
            ],
          ),
          const SizedBox(height: VaultSpacing.xs),
          Text(entry.description, style: tt.bodyMedium),
          if (entry.cost != null) ...[
            const SizedBox(height: VaultSpacing.xs),
            Text('Costo: \$${entry.cost!.toStringAsFixed(0)}',
                style: const TextStyle(color: VaultColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
