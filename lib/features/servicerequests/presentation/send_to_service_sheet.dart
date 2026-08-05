import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../profile/domain/entities.dart';
import '../../profile/presentation/providers.dart';
import '../domain/entities.dart';
import '../domain/usecases.dart';
import 'providers.dart';

/// Hoja para mandar uno de mis activos a un negocio (servicio o
/// reparación) desde el chat -- solo se ofrece si la persona con la que
/// hablo tiene un negocio registrado (ver `_MaintenanceRequestButton` en
/// `chat_page.dart`).
class SendToServiceSheet extends ConsumerStatefulWidget {
  final String businessId;
  final String businessName;

  const SendToServiceSheet({
    super.key,
    required this.businessId,
    required this.businessName,
  });

  @override
  ConsumerState<SendToServiceSheet> createState() => _SendToServiceSheetState();
}

class _SendToServiceSheetState extends ConsumerState<SendToServiceSheet> {
  String? _assetId;
  String _type = ServiceRequestType.servicio;
  bool _sending = false;
  String? _errorMessage;

  Future<void> _submit() async {
    final assetId = _assetId;
    if (assetId == null) return;

    setState(() {
      _sending = true;
      _errorMessage = null;
    });

    final result = await ref.read(createServiceRequestUseCaseProvider)(
      CreateServiceRequestParams(
        assetId: assetId,
        businessId: widget.businessId,
        type: _type,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _sending = false;
        _errorMessage = failure.message;
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final assetsState = ref.watch(profileAssetsControllerProvider);
    final assets = assetsState.assets;

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
          Text(
            'Enviar a ${widget.businessName}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: VaultSpacing.md),
          if (assets.isEmpty)
            Text(
              'No tienes activos registrados todavía.',
              style: TextStyle(color: VaultColors.textSecondary),
            )
          else ...[
            DropdownButtonFormField<String>(
              initialValue: _assetId,
              decoration: const InputDecoration(
                labelText: 'Artículo',
                border: OutlineInputBorder(),
              ),
              items: assets
                  .map(
                    (AssetEntity a) =>
                        DropdownMenuItem(value: a.id, child: Text(a.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _assetId = v),
            ),
            const SizedBox(height: VaultSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: ServiceRequestType.servicio,
                  child: Text('Servicio'),
                ),
                DropdownMenuItem(
                  value: ServiceRequestType.reparacion,
                  child: Text('Reparación'),
                ),
              ],
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: VaultSpacing.sm),
              Text(_errorMessage!, style: TextStyle(color: VaultColors.error)),
            ],
            const SizedBox(height: VaultSpacing.lg),
            ElevatedButton(
              onPressed: _assetId == null || _sending ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: VaultColors.primary,
                padding: const EdgeInsets.symmetric(vertical: VaultSpacing.md),
              ),
              child: _sending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Enviar'),
            ),
          ],
        ],
      ),
    );
  }
}
