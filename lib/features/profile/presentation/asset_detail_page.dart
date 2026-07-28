import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';
import '../../maintenance/domain/entities.dart';
import '../../maintenance/presentation/providers.dart';
import '../domain/entities.dart';

/// Detalle de un activo: sus datos + el historial de mantenimiento.
/// Recibe el AssetEntity por parámetro (viene del perfil).
class AssetDetailPage extends ConsumerWidget {
  final AssetEntity asset;

  const AssetDetailPage({super.key, required this.asset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final maintenanceState = ref.watch(maintenanceControllerProvider(asset.id));

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: Text(asset.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () => context.push(AppRoutes.editAsset, extra: asset),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: VaultColors.primary,
        onPressed: () => _openAddSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Mantenimiento'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(VaultSpacing.md),
        children: [
          _AssetSummary(asset: asset),
          const SizedBox(height: VaultSpacing.lg),
          Text('Historial de mantenimiento', style: tt.titleMedium),
          const SizedBox(height: VaultSpacing.sm),
          _MaintenanceList(state: maintenanceState),
          const SizedBox(height: VaultSpacing.lg),
          Text('Certificado blockchain', style: tt.titleMedium),
          const SizedBox(height: VaultSpacing.sm),
          _CertificateSection(asset: asset),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _openAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VaultColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(VaultRadius.card)),
      ),
      builder: (_) => _AddMaintenanceSheet(assetId: asset.id, ref: ref),
    );
  }
}

/// Resumen visual del activo (datos clave).
class _AssetSummary extends StatelessWidget {
  final AssetEntity asset;

  const _AssetSummary({required this.asset});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

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
          Text(asset.brand, style: tt.titleMedium),
          Text(asset.name, style: tt.bodyMedium),
          const SizedBox(height: VaultSpacing.sm),
          _row('Categoría', asset.category.displayName),
          _row('Condición', asset.condition),
          _row('Talla', asset.size),
          _row('Origen', asset.origin),
          _row('Servicios', '${asset.servicesCount}'),
          _row('Restauraciones', '${asset.restorationsCount}'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VaultSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: VaultColors.textSecondary)),
          Text(value, style: const TextStyle(color: VaultColors.textPrimary)),
        ],
      ),
    );
  }
}

/// Certificado de propiedad emitido en Vara Network: mientras la
/// certificación asíncrona no haya terminado (`asset.isVerified == false`,
/// ver `AssetModel.fromJson`), solo se avisa que está en curso.
class _CertificateSection extends ConsumerWidget {
  final AssetEntity asset;

  const _CertificateSection({required this.asset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!asset.isVerified) {
      return Container(
        padding: const EdgeInsets.all(VaultSpacing.md),
        decoration: BoxDecoration(
          color: VaultColors.surface,
          borderRadius: VaultRadius.cardBorder,
          border: Border.all(color: VaultColors.divider),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: VaultSpacing.md),
            Expanded(child: Text('Verificando en Vara Network...')),
          ],
        ),
      );
    }

    final ownerName = ref.watch(authControllerProvider).user?.fullName ?? 'Tú';
    final txId = asset.blockchainTxId ?? '';
    final shortTxId =
        txId.length > 14 ? '${txId.substring(0, 8)}…${txId.substring(txId.length - 6)}' : txId;

    return Container(
      padding: const EdgeInsets.all(VaultSpacing.md),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        border: Border.all(color: VaultColors.success),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user, color: VaultColors.success),
              const SizedBox(width: VaultSpacing.sm),
              Text('Certificado de propiedad',
                  style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: VaultSpacing.sm),
          _certRow('Dueño', ownerName),
          _certRow('Producto', '${asset.brand} ${asset.name}'),
          _certRow('Categoría', asset.category.displayName),
          const SizedBox(height: VaultSpacing.xs),
          Row(
            children: [
              const Text('ID en Vara: ', style: TextStyle(color: VaultColors.textSecondary)),
              Expanded(
                child: Text(shortTxId, style: const TextStyle(fontFamily: 'monospace')),
              ),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: txId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ID copiado')),
                  );
                },
                icon: const Icon(Icons.copy, size: VaultIconSize.sm),
                label: const Text('Copiar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _certRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: VaultColors.textSecondary)),
          Text(value, style: const TextStyle(color: VaultColors.textPrimary)),
        ],
      ),
    );
  }
}

/// Lista del historial, con estados de carga/vacío/error.
class _MaintenanceList extends StatelessWidget {
  final MaintenanceState state;

  const _MaintenanceList({required this.state});

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
          children: state.entries.map((e) => _MaintenanceTile(entry: e)).toList(),
        );
    }
  }
}

class _MaintenanceTile extends StatelessWidget {
  final MaintenanceEntry entry;

  const _MaintenanceTile({required this.entry});

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
              Text(dateStr,
                  style: const TextStyle(color: VaultColors.textSecondary)),
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

/// Formulario para agregar una entrada de mantenimiento.
class _AddMaintenanceSheet extends StatefulWidget {
  final String assetId;
  final WidgetRef ref;

  const _AddMaintenanceSheet({required this.assetId, required this.ref});

  @override
  State<_AddMaintenanceSheet> createState() => _AddMaintenanceSheetState();
}

class _AddMaintenanceSheetState extends State<_AddMaintenanceSheet> {
  MaintenanceType _type = MaintenanceType.cleaning;
  final _descController = TextEditingController();
  final _costController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _descController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_descController.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final entry = MaintenanceEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      assetId: widget.assetId,
      type: _type,
      date: DateTime.now(),
      description: _descController.text.trim(),
      cost: double.tryParse(_costController.text.trim()),
    );

    final ok = await widget.ref
        .read(maintenanceControllerProvider(widget.assetId).notifier)
        .addEntry(entry);

    if (mounted) {
      setState(() => _saving = false);
      if (ok) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        VaultSpacing.lg,
        VaultSpacing.lg,
        VaultSpacing.lg,
        VaultSpacing.lg + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Nuevo mantenimiento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: VaultSpacing.md),
          DropdownButtonFormField<MaintenanceType>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: 'Tipo',
              border: OutlineInputBorder(),
            ),
            items: MaintenanceType.values
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.displayName),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _type = v ?? _type),
          ),
          const SizedBox(height: VaultSpacing.md),
          TextField(
            controller: _descController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: VaultSpacing.md),
          TextField(
            controller: _costController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Costo (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: VaultSpacing.lg),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: VaultColors.primary,
              padding: const EdgeInsets.symmetric(vertical: VaultSpacing.md),
            ),
            child: _saving
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
