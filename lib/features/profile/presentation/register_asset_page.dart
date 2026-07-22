import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dashed_border.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';
import 'providers.dart';

/// Condiciones posibles de un activo (chips). El texto visible deriva de aquí.
enum _Condition { nuevo, usado, comoNuevo }

extension _ConditionUI on _Condition {
  String get label {
    switch (this) {
      case _Condition.nuevo:     return 'Nuevo';
      case _Condition.usado:     return 'Usado';
      case _Condition.comoNuevo: return 'Como nuevo';
    }
  }

  /// Debe coincidir con el CHECK constraint de `assets.condition` (init.sql):
  /// nuevo/seminuevo/usado.
  String get value {
    switch (this) {
      case _Condition.nuevo:     return 'nuevo';
      case _Condition.usado:     return 'usado';
      case _Condition.comoNuevo: return 'seminuevo';
    }
  }
}

class RegisterAssetPage extends ConsumerStatefulWidget {
  const RegisterAssetPage({super.key});

  @override
  ConsumerState<RegisterAssetPage> createState() => _RegisterAssetPageState();
}

class _RegisterAssetPageState extends ConsumerState<RegisterAssetPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _storeController = TextEditingController();
  final _sizeController = TextEditingController();
  final _notesController = TextEditingController();

  AssetCategory _category = AssetCategory.sneakers;
  _Condition _condition = _Condition.nuevo;
  bool _saving = false;

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

  void _onPhotoTap() {
    // Solo visual por ahora. La selección/subida real llega con el storage.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Agregar foto (próximamente)')),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final asset = AssetEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: _category,
      brand: _brandController.text.trim(),
      name: _nameController.text.trim(),
      imageUrl: '', // el storage devolverá la URL real más adelante
      acquisitionDate: DateTime.now(),
      originalPrice: double.tryParse(_priceController.text.trim()) ?? 0,
      origin: _storeController.text.trim(),
      size: _sizeController.text.trim(),
      condition: _condition.value,
      servicesCount: 0,
      restorationsCount: 0,
      isVerified: false,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final ok = await ref
        .read(profileAssetsControllerProvider.notifier)
        .addAsset(asset);

    if (!mounted) return;
    if (ok) {
      context.pop();
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo registrar el activo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(title: const Text('Registra tu accesorio')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(VaultSpacing.lg),
            children: [
              Text(
                'Añade un nuevo producto a tu inventario',
                style: tt.bodyMedium,
              ),
              const SizedBox(height: VaultSpacing.lg),

              _AssetPhotoPicker(onTap: _onPhotoTap),
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
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: VaultSpacing.md),
              _AssetField(
                controller: _brandController,
                label: 'Marca',
                icon: Icons.sell_outlined,
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
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: VaultSpacing.md),
                  Expanded(
                    child: _AssetField(
                      controller: _storeController,
                      label: 'Tienda',
                      icon: Icons.storefront_outlined,
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
              ),
              const SizedBox(height: VaultSpacing.md),
              _AssetField(
                controller: _notesController,
                label: 'Comentario',
                icon: Icons.chat_bubble_outline,
                maxLines: 3,
              ),
              const SizedBox(height: VaultSpacing.xl),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saving ? null : () => context.pop(),
                      icon: const Icon(Icons.close),
                      label: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: VaultSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
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
                      label: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Etiqueta de sección del formulario.
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

/// Bloque de fotos: una grande al centro y dos laterales (solo visual).
class _AssetPhotoPicker extends StatelessWidget {
  final VoidCallback onTap;
  const _AssetPhotoPicker({required this.onTap});

  Widget _slot(double size, {bool primary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: DashedBorder(
        color: VaultColors.divider,
        borderRadius: VaultRadius.card,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: VaultColors.surface,
            borderRadius: VaultRadius.cardBorder,
          ),
          child: Icon(
            Icons.photo_camera_outlined,
            color: VaultColors.textSecondary,
            size: primary ? VaultIconSize.lg : VaultIconSize.md,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _slot(64),
        const SizedBox(width: VaultSpacing.md),
        _slot(104, primary: true),
        const SizedBox(width: VaultSpacing.md),
        _slot(64),
      ],
    );
  }
}

/// Chips de categoría (selección única).
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

/// Chips de condición (selección única).
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

/// Chip de opción reutilizable (verde cuando está seleccionado).
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

/// Campo de texto reutilizable del formulario, con el estilo del theme.
class _AssetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _AssetField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: VaultColors.primary),
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
          borderSide: const BorderSide(color: VaultColors.primary, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}