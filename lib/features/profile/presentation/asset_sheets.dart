import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';
import 'providers.dart';

/// Hoja para poner un activo en venta (precio + descripción de la oferta).
class SellAssetSheet extends ConsumerStatefulWidget {
  final AssetEntity asset;

  const SellAssetSheet({super.key, required this.asset});

  @override
  ConsumerState<SellAssetSheet> createState() => _SellAssetSheetState();
}

class _SellAssetSheetState extends ConsumerState<SellAssetSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.asset.salePrice?.toStringAsFixed(0) ?? '',
    );
    _descController = TextEditingController(
      text: widget.asset.saleDescription ?? '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(profileAssetsControllerProvider.notifier)
        .setForSale(
          widget.asset,
          forSale: true,
          price: double.tryParse(_priceController.text.trim()),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
        );
    Navigator.pop(context);
  }

  void _removeFromSale() {
    ref
        .read(profileAssetsControllerProvider.notifier)
        .setForSale(widget.asset, forSale: false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final alreadyForSale = widget.asset.isForSale;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: VaultSpacing.lg,
        right: VaultSpacing.lg,
        top: VaultSpacing.lg,
        bottom: VaultSpacing.lg + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              alreadyForSale ? 'Editar venta' : 'Poner en venta',
              style: tt.titleLarge,
            ),
            const SizedBox(height: VaultSpacing.xs),
            Text(widget.asset.name, style: tt.bodyMedium),
            const SizedBox(height: VaultSpacing.lg),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: VaultColors.primary),
              decoration: InputDecoration(
                labelText: 'Precio de venta',
                prefixIcon: Icon(
                  Icons.attach_money,
                  color: VaultColors.primary,
                ),
                filled: true,
                fillColor: VaultColors.background,
                border: OutlineInputBorder(
                  borderRadius: VaultRadius.buttonBorder,
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) {
                final value = double.tryParse((v ?? '').trim());
                if (value == null || value <= 0)
                  return 'Ingresa un precio válido';
                return null;
              },
            ),
            const SizedBox(height: VaultSpacing.md),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              style: TextStyle(color: VaultColors.primary),
              decoration: InputDecoration(
                labelText: 'Descripción de la oferta',
                alignLabelWithHint: true,
                filled: true,
                fillColor: VaultColors.background,
                border: OutlineInputBorder(
                  borderRadius: VaultRadius.buttonBorder,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: VaultSpacing.lg),
            ElevatedButton.icon(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: VaultColors.accent,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.sell_outlined),
              label: Text(
                alreadyForSale ? 'Guardar cambios' : 'Poner en venta',
              ),
            ),
            if (alreadyForSale) ...[
              const SizedBox(height: VaultSpacing.sm),
              TextButton.icon(
                onPressed: _removeFromSale,
                style: TextButton.styleFrom(foregroundColor: VaultColors.error),
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('Quitar de venta'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Hoja para publicar un activo en el Feed (caption opcional).
class PublishAssetSheet extends ConsumerStatefulWidget {
  final AssetEntity asset;

  const PublishAssetSheet({super.key, required this.asset});

  @override
  ConsumerState<PublishAssetSheet> createState() => _PublishAssetSheetState();
}

class _PublishAssetSheetState extends ConsumerState<PublishAssetSheet> {
  late final TextEditingController _captionController;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(
      text: widget.asset.publishCaption ?? '',
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _publish() {
    ref
        .read(profileAssetsControllerProvider.notifier)
        .setPublished(
          widget.asset,
          published: true,
          caption: _captionController.text.trim().isEmpty
              ? null
              : _captionController.text.trim(),
        );
    Navigator.pop(context);
  }

  void _unpublish() {
    ref
        .read(profileAssetsControllerProvider.notifier)
        .setPublished(widget.asset, published: false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final alreadyPublished = widget.asset.isPublished;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: VaultSpacing.lg,
        right: VaultSpacing.lg,
        top: VaultSpacing.lg,
        bottom: VaultSpacing.lg + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            alreadyPublished ? 'Editar publicación' : 'Publicar en el Feed',
            style: tt.titleLarge,
          ),
          const SizedBox(height: VaultSpacing.xs),
          Text(
            'Presume ${widget.asset.name} en la comunidad',
            style: tt.bodyMedium,
          ),
          const SizedBox(height: VaultSpacing.lg),
          TextField(
            controller: _captionController,
            maxLines: 3,
            style: TextStyle(color: VaultColors.primary),
            decoration: InputDecoration(
              labelText: 'Mensaje (opcional)',
              hintText: '¿Qué quieres decir sobre esta pieza?',
              alignLabelWithHint: true,
              filled: true,
              fillColor: VaultColors.background,
              border: OutlineInputBorder(
                borderRadius: VaultRadius.buttonBorder,
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: VaultSpacing.lg),
          ElevatedButton.icon(
            onPressed: _publish,
            icon: const Icon(Icons.public),
            label: Text(alreadyPublished ? 'Guardar cambios' : 'Publicar'),
          ),
          if (alreadyPublished) ...[
            const SizedBox(height: VaultSpacing.sm),
            TextButton.icon(
              onPressed: _unpublish,
              style: TextButton.styleFrom(foregroundColor: VaultColors.error),
              icon: const Icon(Icons.public_off),
              label: const Text('Quitar del feed'),
            ),
          ],
        ],
      ),
    );
  }
}
