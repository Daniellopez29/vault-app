import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/dashed_border.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';
import 'providers.dart';

/// Condiciones posibles de un activo (mismo mapeo que register_asset_page).
enum _Condition { nuevo, usado, comoNuevo }

extension _ConditionUI on _Condition {
  String get label {
    switch (this) {
      case _Condition.nuevo:
        return 'Nuevo';
      case _Condition.usado:
        return 'Usado';
      case _Condition.comoNuevo:
        return 'Semi nuevo';
    }
  }

  String get value {
    switch (this) {
      case _Condition.nuevo:
        return 'nuevo';
      case _Condition.usado:
        return 'usado';
      case _Condition.comoNuevo:
        return 'seminuevo';
    }
  }

  static _Condition fromValue(String value) {
    switch (value) {
      case 'usado':
        return _Condition.usado;
      case 'seminuevo':
        return _Condition.comoNuevo;
      default:
        return _Condition.nuevo;
    }
  }
}

/// Edita los datos y las fotos de un activo ya registrado. Las fotos se
/// suben/borran al instante (mismo patrón que "Mi negocio"); los campos de
/// texto se guardan juntos con el botón "Guardar cambios".
class EditAssetPage extends ConsumerStatefulWidget {
  final AssetEntity asset;

  const EditAssetPage({super.key, required this.asset});

  @override
  ConsumerState<EditAssetPage> createState() => _EditAssetPageState();
}

class _EditAssetPageState extends ConsumerState<EditAssetPage> {
  final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController(text: widget.asset.name);
  late final _brandController = TextEditingController(text: widget.asset.brand);
  late final _priceController = TextEditingController(
    text: widget.asset.originalPrice.toStringAsFixed(0),
  );
  late final _storeController = TextEditingController(
    text: widget.asset.origin,
  );
  late final _sizeController = TextEditingController(text: widget.asset.size);
  late final _notesController = TextEditingController(
    text: widget.asset.notes ?? '',
  );

  late AssetCategory _category = widget.asset.category;
  late _Condition _condition = _ConditionUI.fromValue(widget.asset.condition);
  bool _saving = false;
  bool _uploadingPhoto = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _storeController.dispose();
    _sizeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    final bytes = await picked.readAsBytes();
    final ok = await ref
        .read(profileAssetsControllerProvider.notifier)
        .uploadPhoto(widget.asset.id, bytes: bytes, filename: picked.name);

    if (!mounted) return;
    setState(() => _uploadingPhoto = false);
    if (!ok) {
      final error =
          ref.read(profileAssetsControllerProvider).errorMessage ??
          'No se pudo subir la foto';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _removePhoto(String photoId) async {
    final ok = await ref
        .read(profileAssetsControllerProvider.notifier)
        .deletePhoto(widget.asset.id, photoId);
    if (!mounted || ok) return;
    final error =
        ref.read(profileAssetsControllerProvider).errorMessage ??
        'No se pudo quitar la foto';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final updated = widget.asset.copyWith(
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      category: _category,
      originalPrice:
          double.tryParse(_priceController.text.trim()) ??
          widget.asset.originalPrice,
      origin: _storeController.text.trim(),
      condition: _condition.value,
      size: _sizeController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final ok = await ref
        .read(profileAssetsControllerProvider.notifier)
        .editAsset(updated);

    if (!mounted) return;
    if (ok) {
      context.pop();
    } else {
      setState(() => _saving = false);
      final error =
          ref.read(profileAssetsControllerProvider).errorMessage ??
          'No se pudieron guardar los cambios';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch para que la grilla de fotos refleje subidas/borrados al instante.
    final matches = ref
        .watch(profileAssetsControllerProvider)
        .assets
        .where((a) => a.id == widget.asset.id);
    final current = matches.isEmpty ? widget.asset : matches.first;

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(title: const Text('Editar activo')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(VaultSpacing.lg),
            children: [
              Text('Fotos', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: VaultSpacing.sm),
              Wrap(
                spacing: VaultSpacing.sm,
                runSpacing: VaultSpacing.sm,
                children: [
                  for (final photo in current.photos)
                    _PhotoThumb(
                      url: photo.url,
                      onRemove: () => _removePhoto(photo.id),
                    ),
                  _AddPhotoTile(uploading: _uploadingPhoto, onTap: _addPhoto),
                ],
              ),
              const SizedBox(height: VaultSpacing.xl),

              const _Label('Categoría', required: true),
              _CategoryChips(
                selected: _category,
                onSelected: (c) => setState(() => _category = c),
              ),
              const SizedBox(height: VaultSpacing.lg),

              _AssetField(
                controller: _nameController,
                label: 'Nombre / Modelo',
                icon: Icons.label_outline,
                maxLength: 60,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: VaultSpacing.md),
              _AssetField(
                controller: _brandController,
                label: 'Marca',
                icon: Icons.sell_outlined,
                maxLength: 40,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ingresa la marca' : null,
              ),
              const SizedBox(height: VaultSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _AssetField(
                      controller: _priceController,
                      label: 'Precio de compra',
                      icon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      maxLength: 10,
                    ),
                  ),
                  const SizedBox(width: VaultSpacing.md),
                  Expanded(
                    child: _AssetField(
                      controller: _storeController,
                      label: 'Tienda',
                      icon: Icons.storefront_outlined,
                      maxLength: 50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: VaultSpacing.lg),

              const _Label('Condición'),
              _ConditionChips(
                selected: _condition,
                onSelected: (c) => setState(() => _condition = c),
              ),
              const SizedBox(height: VaultSpacing.lg),

              _AssetField(
                controller: _sizeController,
                label: 'Talla',
                icon: Icons.straighten_outlined,
                maxLength: 15,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () =>
                      setState(() => _sizeController.text = 'Sin talla'),
                  child: const Text('Sin talla'),
                ),
              ),
              const SizedBox(height: VaultSpacing.md),
              _AssetField(
                controller: _notesController,
                label: 'Comentario',
                icon: Icons.chat_bubble_outline,
                maxLines: 3,
                maxLength: 300,
              ),
              const SizedBox(height: VaultSpacing.xl),

              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: VaultColors.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: VaultSpacing.md,
                  ),
                ),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_alt_outlined),
                label: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final bool required;
  const _Label(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VaultSpacing.sm),
      child: Text(
        required ? '$text (Obligatorio)' : text,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final String url;
  final VoidCallback onRemove;

  const _PhotoThumb({required this.url, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: VaultRadius.cardBorder,
          child: Image.network(url, width: 96, height: 96, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final bool uploading;
  final VoidCallback onTap;
  const _AddPhotoTile({required this.uploading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: uploading ? null : onTap,
      child: DashedBorder(
        color: VaultColors.divider,
        borderRadius: VaultRadius.card,
        child: Container(
          width: 96,
          height: 96,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: VaultColors.surface,
            borderRadius: VaultRadius.cardBorder,
          ),
          child: uploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  Icons.add_photo_alternate_outlined,
                  color: VaultColors.textSecondary,
                  size: VaultIconSize.lg,
                ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final AssetCategory selected;
  final ValueChanged<AssetCategory> onSelected;

  const _CategoryChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: VaultSpacing.sm,
      runSpacing: VaultSpacing.sm,
      children: AssetCategory.values.map((c) {
        return _ChoiceChip(
          label: c.displayName,
          isSelected: c == selected,
          onTap: () => onSelected(c),
        );
      }).toList(),
    );
  }
}

class _ConditionChips extends StatelessWidget {
  final _Condition selected;
  final ValueChanged<_Condition> onSelected;

  const _ConditionChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: VaultSpacing.sm,
      runSpacing: VaultSpacing.sm,
      children: _Condition.values.map((c) {
        return _ChoiceChip(
          label: c.label,
          isSelected: c == selected,
          onTap: () => onSelected(c),
        );
      }).toList(),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: VaultSpacing.lg,
          vertical: VaultSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? VaultColors.success : VaultColors.surface,
          borderRadius: VaultRadius.buttonBorder,
          border: Border.all(
            color: isSelected ? VaultColors.success : VaultColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : VaultColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _AssetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _AssetField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: VaultColors.primary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: VaultColors.primary),
        filled: true,
        fillColor: VaultColors.surface,
        border: OutlineInputBorder(
          borderRadius: VaultRadius.buttonBorder,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: VaultRadius.buttonBorder,
          borderSide: BorderSide(
            color: VaultColors.primary.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: VaultRadius.buttonBorder,
          borderSide: BorderSide(color: VaultColors.primary, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
