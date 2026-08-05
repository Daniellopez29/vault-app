import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../ads/presentation/advertise_flow.dart';
import '../../marketplace/presentation/item_image.dart';
import '../../subscription/domain/entities.dart';
import '../domain/entities.dart';
import 'providers.dart';

/// Pestaña "Mi negocio". El estado (¿tiene negocio?, sus datos) viene de
/// `businessControllerProvider`, que filtra `GET /businesses` por el usuario
/// actual (el backend no tiene un endpoint "mi negocio" propio).
class MyBusinessTab extends ConsumerWidget {
  const MyBusinessTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(businessControllerProvider);

    switch (state.status) {
      case BusinessStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case BusinessStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.errorMessage ?? 'Error al cargar tu negocio'),
              const SizedBox(height: VaultSpacing.md),
              TextButton(
                onPressed: () =>
                    ref.read(businessControllerProvider.notifier).load(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      case BusinessStatus.loaded:
        final business = state.business;
        return business == null
            ? _EmptyView(
                onAdd: () => context
                    .push(AppRoutes.registerBusiness)
                    .then(
                      (_) =>
                          ref.read(businessControllerProvider.notifier).load(),
                    ),
              )
            : _AdminView(business: business);
    }
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VaultSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: VaultIconSize.xl,
              color: VaultColors.textSecondary,
            ),
            const SizedBox(height: VaultSpacing.lg),
            Text(
              "No tienes un negocio registrado",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VaultColors.textPrimary,
              ),
            ),
            const SizedBox(height: VaultSpacing.sm),
            Text(
              "Crea tu negocio para gestionar tus datos, horarios y ubicación.",
              textAlign: TextAlign.center,
              style: TextStyle(color: VaultColors.textSecondary),
            ),
            const SizedBox(height: VaultSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VaultColors.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: VaultSpacing.md,
                  ),
                ),
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text("Agregar negocio"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Categorías de negocio (chips de selección múltiple). Debe coincidir con
/// el CHECK constraint de `businesses.types` (servicio/restaurador) --
/// mismo mapeo que `register_business_page.dart`.
enum _BusinessCategory { mantenimiento, reparacion }

extension _BusinessCategoryUI on _BusinessCategory {
  String get label {
    switch (this) {
      case _BusinessCategory.mantenimiento:
        return 'Mantenimiento';
      case _BusinessCategory.reparacion:
        return 'Reparación';
    }
  }

  String get value {
    switch (this) {
      case _BusinessCategory.mantenimiento:
        return 'servicio';
      case _BusinessCategory.reparacion:
        return 'restaurador';
    }
  }

  static _BusinessCategory? fromValue(String value) {
    switch (value) {
      case 'servicio':
        return _BusinessCategory.mantenimiento;
      case 'restaurador':
        return _BusinessCategory.reparacion;
      default:
        return null;
    }
  }
}

class _AdminView extends ConsumerStatefulWidget {
  final BusinessEntity business;

  const _AdminView({required this.business});

  @override
  ConsumerState<_AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends ConsumerState<_AdminView> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.business.name,
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.business.description);
  late final TextEditingController _locationController = TextEditingController(
    text: widget.business.location,
  );
  late final TextEditingController _specialtiesController =
      TextEditingController(text: widget.business.specialties.join(', '));
  late Set<_BusinessCategory> _categories = widget.business.types
      .map(_BusinessCategoryUI.fromValue)
      .whereType<_BusinessCategory>()
      .toSet();

  bool _saving = false;
  bool _uploadingPhoto = false;

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
        .read(businessControllerProvider.notifier)
        .uploadPhoto(bytes: bytes, filename: picked.name);

    if (!mounted) return;
    setState(() => _uploadingPhoto = false);
    if (!ok) {
      final error =
          ref.read(businessControllerProvider).errorMessage ??
          'No se pudo subir la foto';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _removePhoto(String photoId) async {
    final ok = await ref
        .read(businessControllerProvider.notifier)
        .deletePhoto(photoId);
    if (!mounted || ok) return;
    final error =
        ref.read(businessControllerProvider).errorMessage ??
        'No se pudo quitar la foto';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _specialtiesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elige al menos una categoría')),
      );
      return;
    }
    setState(() => _saving = true);
    final ok = await ref
        .read(businessControllerProvider.notifier)
        .update(
          name: _nameController.text.trim(),
          types: _categories.map((c) => c.value).toList(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          specialties: _specialtiesController.text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
        );
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Negocio actualizado.' : 'No se pudo guardar.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se lee de nuevo del provider (no de widget.business) para que la
    // grilla de fotos refleje subidas/borrados al instante.
    final business =
        ref.watch(businessControllerProvider).business ?? widget.business;

    return ListView(
      padding: const EdgeInsets.all(VaultSpacing.md),
      children: [
        if (business.isVerified) ...[
          Row(
            children: [
              Icon(
                Icons.verified,
                size: VaultIconSize.sm,
                color: VaultColors.success,
              ),
              SizedBox(width: VaultSpacing.xs),
              Text('Verificado', style: TextStyle(color: VaultColors.success)),
            ],
          ),
          const SizedBox(height: VaultSpacing.md),
        ],
        _section(
          title: "Imágenes",
          child: Wrap(
            spacing: VaultSpacing.sm,
            runSpacing: VaultSpacing.sm,
            children: [
              for (final photo in business.photos)
                _PhotoThumb(
                  url: photo.url,
                  onRemove: () => _removePhoto(photo.id),
                ),
              GestureDetector(
                onTap: _uploadingPhoto ? null : _addPhoto,
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: _uploadingPhoto
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _imagePlaceholder(isAdd: true),
                ),
              ),
            ],
          ),
        ),
        _section(
          title: "Categoría",
          child: _BusinessCategoryChips(
            selected: _categories,
            onToggle: (c) => setState(() {
              _categories.contains(c)
                  ? _categories.remove(c)
                  : _categories.add(c);
            }),
          ),
        ),
        _section(
          title: "Nombre",
          child: TextField(
            controller: _nameController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ),
        _section(
          title: "Descripción",
          child: TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ),
        _section(
          title: "Especialidades",
          child: TextField(
            controller: _specialtiesController,
            decoration: const InputDecoration(
              hintText: "Separadas por coma, ej: sneakers, relojes",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        _section(
          title: "Dirección",
          child: TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              hintText: "Calle, número, colonia",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: VaultColors.primary,
              padding: const EdgeInsets.symmetric(vertical: VaultSpacing.md),
            ),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Guardar cambios'),
          ),
        ),
        _section(
          title: "Días de atención",
          child: Wrap(
            spacing: VaultSpacing.sm,
            children: [
              _dayChip("Lun"),
              _dayChip("Mar"),
              _dayChip("Mié"),
              _dayChip("Jue"),
              _dayChip("Vie"),
              _dayChip("Sáb"),
              _dayChip("Dom"),
            ],
          ),
          // Pendiente: mismo caso que las fotos, no hay campo de horarios
          // en el backend todavía.
          note: "Próximamente: el backend aún no admite horarios de negocio.",
        ),
        const SizedBox(height: VaultSpacing.lg),
        _BusinessSubscriptionCard(
          onTap: () => startAdvertiseFlow(
            context,
            ref,
            type: SubscriptionType.business,
            business: business,
          ),
        ),
      ],
    );
  }

  Widget _section({
    required String title,
    required Widget child,
    String? note,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VaultSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: VaultColors.textPrimary,
            ),
          ),
          const SizedBox(height: VaultSpacing.sm),
          child,
          if (note != null) ...[
            const SizedBox(height: VaultSpacing.xs),
            Text(
              note,
              style: TextStyle(color: VaultColors.textSecondary, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _imagePlaceholder({bool isAdd = false}) {
    return Container(
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: BorderRadius.circular(VaultRadius.sm),
        border: Border.all(color: VaultColors.divider),
      ),
      child: Icon(
        isAdd ? Icons.add_a_photo_outlined : Icons.image_outlined,
        color: VaultColors.textSecondary,
      ),
    );
  }

  Widget _dayChip(String label) {
    return FilterChip(label: Text(label), selected: false, onSelected: (_) {});
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
          borderRadius: BorderRadius.circular(VaultRadius.sm),
          child: SizedBox(
            width: 96,
            height: 96,
            child: ItemImage(imageUrl: url),
          ),
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

class _BusinessCategoryChips extends StatelessWidget {
  final Set<_BusinessCategory> selected;
  final ValueChanged<_BusinessCategory> onToggle;

  const _BusinessCategoryChips({
    required this.selected,
    required this.onToggle,
  });

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
              border: Border.all(
                color: isSelected ? VaultColors.success : VaultColors.divider,
              ),
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

/// Card de suscripción del negocio, al fondo de la administración.
/// Fondo accent (señal de compra). El texto viene de SubscriptionCopy
/// (dominio), no hardcodeado. Navega a la pantalla de planes de negocio.
class _BusinessSubscriptionCard extends StatelessWidget {
  final VoidCallback onTap;

  const _BusinessSubscriptionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Material(
      color: VaultColors.accent,
      borderRadius: BorderRadius.circular(VaultRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(VaultRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(VaultSpacing.lg),
          child: Row(
            children: [
              const Icon(
                Icons.campaign_outlined,
                color: Colors.white,
                size: VaultIconSize.lg,
              ),
              const SizedBox(width: VaultSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SubscriptionCopy.titleFor(SubscriptionType.business),
                      style: tt.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: VaultSpacing.xs),
                    Text(
                      SubscriptionCopy.subtitleFor(SubscriptionType.business),
                      style: tt.bodySmall?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
