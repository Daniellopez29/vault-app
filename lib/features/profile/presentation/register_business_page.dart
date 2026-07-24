import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/dashed_border.dart';
import '../../../core/dimens.dart';
import '../../../core/enums.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';
import '../../business/presentation/providers.dart';
import '../domain/usecases.dart';
import 'providers.dart';

/// Categoría del negocio (chips). El texto visible ("Mantenimiento"/
/// "Reparación") es el que pide el diseño; internamente se mapea al
/// CHECK constraint real de `businesses.type` (restaurador/servicio) y
/// también determina el rol que se le asigna al usuario.
enum _BusinessCategory { mantenimiento, reparacion }

extension _BusinessCategoryUI on _BusinessCategory {
  String get label {
    switch (this) {
      case _BusinessCategory.mantenimiento: return 'Mantenimiento';
      case _BusinessCategory.reparacion:    return 'Reparación';
    }
  }

  String get businessType {
    switch (this) {
      case _BusinessCategory.mantenimiento: return 'servicio';
      case _BusinessCategory.reparacion:    return 'restaurador';
    }
  }

  UserRole get role {
    switch (this) {
      case _BusinessCategory.mantenimiento: return UserRole.service;
      case _BusinessCategory.reparacion:    return UserRole.restorer;
    }
  }
}

class RegisterBusinessPage extends ConsumerStatefulWidget {
  const RegisterBusinessPage({super.key});

  @override
  ConsumerState<RegisterBusinessPage> createState() => _RegisterBusinessPageState();
}

class _RegisterBusinessPageState extends ConsumerState<RegisterBusinessPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailsController = TextEditingController();

  final Set<_BusinessCategory> _categories = {_BusinessCategory.mantenimiento};
  final List<XFile> _images = [];
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _addImages() async {
    final picked = await ImagePicker().pickMultiImage(maxWidth: 1600, imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() => _images.addAll(picked));
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elige al menos una categoría')),
      );
      return;
    }
    setState(() => _saving = true);

    final result = await ref.read(registerBusinessUseCaseProvider).call(
          RegisterBusinessParams(
            name: _nameController.text.trim(),
            types: _categories.map((c) => c.businessType).toList(),
            description: _detailsController.text.trim(),
            location: _addressController.text.trim(),
          ),
        );

    if (!mounted) return;

    final ok = result.fold((failure) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
      return false;
    }, (_) => true);

    if (!ok) return;

    // El negocio quedó registrado -- se AGREGAN los roles de las
    // categorías elegidas al histórico de la cuenta, sin reemplazar los
    // que ya tenía (a diferencia de antes, que sobreescribía el rol).
    await ref
        .read(authControllerProvider.notifier)
        .addRoles(_categories.map((c) => c.role).toList());

    // El negocio recién creado no trae su id de vuelta en esta llamada --
    // se recarga "mi negocio" (que sí lo tiene) antes de poder subir fotos.
    await ref.read(businessControllerProvider.notifier).load();
    for (final image in _images) {
      final bytes = await image.readAsBytes();
      await ref
          .read(businessControllerProvider.notifier)
          .uploadPhoto(bytes: bytes, filename: image.name);
    }

    // El directorio público del Shop (allBusinessesProvider) se cachea
    // hasta que se invalide explícitamente -- sin esto, el negocio recién
    // creado quedaba invisible ahí hasta reiniciar la app.
    ref.invalidate(allBusinessesProvider);

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(title: const Text('Registra tu negocio')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(VaultSpacing.lg),
            children: [
              Text('Añade tu negocio a nuestra aplicación', style: tt.bodyMedium),
              const SizedBox(height: VaultSpacing.lg),

              Text('Fotos (opcional)', style: tt.titleMedium),
              const SizedBox(height: VaultSpacing.sm),
              Wrap(
                spacing: VaultSpacing.sm,
                runSpacing: VaultSpacing.sm,
                children: [
                  for (var i = 0; i < _images.length; i++)
                    _BusinessImageThumb(image: _images[i], onRemove: () => _removeImage(i)),
                  _AddBusinessImageTile(onTap: _addImages),
                ],
              ),
              const SizedBox(height: VaultSpacing.xl),

              _BusinessLabel('Nombre'),
              _BusinessField(
                controller: _nameController,
                label: 'Nombre',
                icon: Icons.storefront_outlined,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ingresa el nombre del negocio' : null,
              ),
              const SizedBox(height: VaultSpacing.lg),

              _BusinessLabel('Categoría', required: true),
              Text(
                'Puedes elegir ambas si tu negocio hace las dos cosas',
                style: tt.labelSmall,
              ),
              const SizedBox(height: VaultSpacing.sm),
              _BusinessCategoryChips(
                selected: _categories,
                onToggle: (c) => setState(() {
                  if (_categories.contains(c)) {
                    _categories.remove(c);
                  } else {
                    _categories.add(c);
                  }
                }),
              ),
              const SizedBox(height: VaultSpacing.lg),

              _BusinessLabel('Dirección'),
              _BusinessField(
                controller: _addressController,
                label: 'Dirección',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: VaultSpacing.lg),

              _BusinessLabel('Detalles del Negocio'),
              _BusinessField(
                controller: _detailsController,
                label: 'Detalles del Negocio',
                icon: Icons.chat_bubble_outline,
                maxLines: 4,
              ),
              const SizedBox(height: VaultSpacing.sm),
              Text(
                '* Agregar una imagen donde se muestre la ubicación del local en el mapa',
                style: tt.labelSmall,
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

class _BusinessLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _BusinessLabel(this.text, {this.required = false});

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

/// Miniatura de una foto ya seleccionada, con botón para quitarla. Mismo
/// patrón que `register_asset_page.dart`/`create_post_page.dart`.
class _BusinessImageThumb extends StatelessWidget {
  final XFile image;
  final VoidCallback onRemove;

  const _BusinessImageThumb({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: VaultRadius.cardBorder,
          child: FutureBuilder<Uint8List>(
            future: image.readAsBytes(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(width: 96, height: 96, color: VaultColors.surface);
              }
              return Image.memory(snapshot.data!, width: 96, height: 96, fit: BoxFit.cover);
            },
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Casilla para agregar una foto nueva.
class _AddBusinessImageTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddBusinessImageTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DashedBorder(
        color: VaultColors.divider,
        borderRadius: VaultRadius.card,
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: VaultColors.surface,
            borderRadius: VaultRadius.cardBorder,
          ),
          child: Icon(Icons.add_photo_alternate_outlined,
              color: VaultColors.textSecondary, size: VaultIconSize.lg),
        ),
      ),
    );
  }
}

class _BusinessCategoryChips extends StatelessWidget {
  final Set<_BusinessCategory> selected;
  final ValueChanged<_BusinessCategory> onToggle;

  const _BusinessCategoryChips({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: VaultSpacing.sm,
      runSpacing: VaultSpacing.sm,
      children: _BusinessCategory.values.map((c) {
        final isSelected = selected.contains(c);
        return GestureDetector(
          onTap: () => onToggle(c),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: VaultSpacing.lg,
              vertical: VaultSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? VaultColors.success : VaultColors.surface,
              borderRadius: VaultRadius.buttonBorder,
              border: Border.all(color: isSelected ? VaultColors.success : VaultColors.divider),
            ),
            child: Text(
              c.label,
              style: TextStyle(
                color: isSelected ? Colors.white : VaultColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BusinessField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final String? Function(String?)? validator;

  const _BusinessField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
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
          borderSide: BorderSide(color: VaultColors.primary.withValues(alpha: 0.2)),
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
