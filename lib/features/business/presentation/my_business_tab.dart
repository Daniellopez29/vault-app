import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
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
                onPressed: () => ref.read(businessControllerProvider.notifier).load(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      case BusinessStatus.loaded:
        final business = state.business;
        return business == null
            ? _EmptyView(
                onAdd: () => context.push(AppRoutes.registerBusiness).then(
                      (_) => ref.read(businessControllerProvider.notifier).load(),
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
            const Icon(Icons.storefront_outlined,
                size: VaultIconSize.xl, color: VaultColors.textSecondary),
            const SizedBox(height: VaultSpacing.lg),
            const Text(
              "No tienes un negocio registrado",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VaultColors.textPrimary,
              ),
            ),
            const SizedBox(height: VaultSpacing.sm),
            const Text(
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
                  padding: const EdgeInsets.symmetric(vertical: VaultSpacing.md),
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

class _AdminView extends ConsumerStatefulWidget {
  final BusinessEntity business;

  const _AdminView({required this.business});

  @override
  ConsumerState<_AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends ConsumerState<_AdminView> {
  late final TextEditingController _locationController =
      TextEditingController(text: widget.business.location);
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
    final ok = await ref.read(businessControllerProvider.notifier).uploadPhoto(
          bytes: bytes,
          filename: picked.name,
        );

    if (!mounted) return;
    setState(() => _uploadingPhoto = false);
    if (!ok) {
      final error = ref.read(businessControllerProvider).errorMessage ?? 'No se pudo subir la foto';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  void didUpdateWidget(covariant _AdminView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.business.location != widget.business.location &&
        _locationController.text != widget.business.location) {
      _locationController.text = widget.business.location;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveLocation() async {
    setState(() => _saving = true);
    final ok = await ref
        .read(businessControllerProvider.notifier)
        .updateLocation(_locationController.text.trim());
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Dirección actualizada.' : 'No se pudo guardar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(VaultSpacing.md),
      children: [
        Text(widget.business.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        if (widget.business.isVerified) ...[
          const SizedBox(height: VaultSpacing.xs),
          const Row(
            children: [
              Icon(Icons.verified, size: VaultIconSize.sm, color: VaultColors.success),
              SizedBox(width: VaultSpacing.xs),
              Text('Verificado', style: TextStyle(color: VaultColors.success)),
            ],
          ),
        ],
        const SizedBox(height: VaultSpacing.lg),
        _section(
          title: "Imágenes",
          child: SizedBox(
            height: 96,
            child: Row(
              children: [
                Expanded(
                  child: widget.business.photos.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(VaultRadius.sm),
                          child: ItemImage(imageUrl: widget.business.photos[0]),
                        )
                      : _imagePlaceholder(),
                ),
                const SizedBox(width: VaultSpacing.sm),
                Expanded(
                  child: widget.business.photos.length > 1
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(VaultRadius.sm),
                          child: ItemImage(imageUrl: widget.business.photos[1]),
                        )
                      : _imagePlaceholder(),
                ),
                const SizedBox(width: VaultSpacing.sm),
                Expanded(
                  child: GestureDetector(
                    onTap: _uploadingPhoto ? null : _addPhoto,
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
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _saving ? null : _saveLocation,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar dirección'),
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
          onTap: () => context.push(
            AppRoutes.subscription,
            extra: SubscriptionType.business,
          ),
        ),
      ],
    );
  }

  Widget _section({required String title, required Widget child, String? note}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VaultSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: VaultColors.textPrimary,
            ),
          ),
          const SizedBox(height: VaultSpacing.sm),
          child,
          if (note != null) ...[
            const SizedBox(height: VaultSpacing.xs),
            Text(note, style: const TextStyle(color: VaultColors.textSecondary, fontSize: 12)),
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
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (_) {},
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
              const Icon(Icons.campaign_outlined,
                  color: Colors.white, size: VaultIconSize.lg),
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
