import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../marketplace/presentation/item_image.dart';
import '../domain/entities.dart';
import 'providers.dart';

/// Artículos que le llegaron al negocio del usuario -- se muestra dentro de
/// "Mi negocio". Solo lista los que siguen en curso (una vez que el dueño
/// confirma la recepción, el flujo ya cerró y no hace falta seguir
/// mostrándolo acá).
class IncomingRequestsSection extends ConsumerWidget {
  const IncomingRequestsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(incomingServiceRequestsControllerProvider);

    switch (state.status) {
      case ServiceRequestsStatus.initial:
      case ServiceRequestsStatus.loading:
        return const Padding(
          padding: EdgeInsets.all(VaultSpacing.lg),
          child: Center(child: CircularProgressIndicator()),
        );
      case ServiceRequestsStatus.error:
        return Padding(
          padding: const EdgeInsets.all(VaultSpacing.lg),
          child: Text(state.errorMessage ?? 'Error al cargar los artículos recibidos'),
        );
      case ServiceRequestsStatus.loaded:
        final active = state.requests
            .where((r) => r.status != ServiceRequestStatus.confirmado)
            .toList();
        if (active.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(VaultSpacing.lg),
            child: Text(
              'No tienes artículos pendientes.',
              style: TextStyle(color: VaultColors.textSecondary),
            ),
          );
        }
        return Column(
          children: active.map((r) => _IncomingRequestTile(request: r)).toList(),
        );
    }
  }
}

class _IncomingRequestTile extends ConsumerStatefulWidget {
  final ServiceRequestEntity request;

  const _IncomingRequestTile({required this.request});

  @override
  ConsumerState<_IncomingRequestTile> createState() => _IncomingRequestTileState();
}

class _IncomingRequestTileState extends ConsumerState<_IncomingRequestTile> {
  bool _acting = false;

  (String, Color) get _statusInfo => switch (widget.request.status) {
        ServiceRequestStatus.pendienteAceptacion => ('Por aceptar', VaultColors.textSecondary),
        ServiceRequestStatus.enEspera => ('En espera', VaultColors.accent),
        ServiceRequestStatus.enServicio => ('En servicio', VaultColors.primary),
        ServiceRequestStatus.terminado => ('Terminado', VaultColors.success),
        _ => (widget.request.status, VaultColors.textSecondary),
      };

  Future<void> _run(Future<bool> Function(String) action) async {
    setState(() => _acting = true);
    final ok = await action(widget.request.id);
    if (!mounted) return;
    setState(() => _acting = false);
    if (!ok) {
      final error = ref.read(incomingServiceRequestsControllerProvider).errorMessage ??
          'No se pudo actualizar la solicitud';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Widget? _actionButton() {
    final notifier = ref.read(incomingServiceRequestsControllerProvider.notifier);
    final (label, onPressed) = switch (widget.request.status) {
      ServiceRequestStatus.pendienteAceptacion => ('Aceptar', notifier.accept),
      ServiceRequestStatus.enEspera => ('Iniciar', notifier.start),
      ServiceRequestStatus.enServicio => ('Marcar terminado', notifier.finish),
      _ => (null, null),
    };
    if (label == null || onPressed == null) return null;

    return TextButton(
      onPressed: _acting ? null : () => _run(onPressed),
      child: _acting
          ? const SizedBox(
              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final (statusLabel, statusColor) = _statusInfo;
    final action = _actionButton();

    return Container(
      margin: const EdgeInsets.only(bottom: VaultSpacing.sm),
      padding: const EdgeInsets.all(VaultSpacing.md),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        border: Border.all(color: VaultColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(VaultRadius.sm),
            child: SizedBox(
              width: 56,
              height: 56,
              child: ItemImage(imageUrl: widget.request.assetImageUrl),
            ),
          ),
          const SizedBox(width: VaultSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(widget.request.assetName,
                          style: tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: VaultSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(VaultRadius.sm),
                      ),
                      child: Text(
                        statusLabel,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: VaultSpacing.xs),
                Text(
                  'De ${widget.request.ownerName} · ${widget.request.type == 'reparacion' ? 'Reparación' : 'Servicio'}',
                  style: tt.bodySmall?.copyWith(color: VaultColors.textSecondary),
                ),
                if (widget.request.status == ServiceRequestStatus.terminado)
                  Padding(
                    padding: const EdgeInsets.only(top: VaultSpacing.xs),
                    child: Text(
                      'Esperando que el cliente confirme la entrega.',
                      style: tt.bodySmall?.copyWith(color: VaultColors.textSecondary),
                    ),
                  ),
                if (action != null)
                  Align(alignment: Alignment.centerRight, child: action),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
