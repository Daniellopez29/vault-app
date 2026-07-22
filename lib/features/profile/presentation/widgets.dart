import 'package:go_router/go_router.dart';
import '../../../core/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/dimens.dart';
import '../../../core/enums.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';
import '../domain/entities.dart';
import 'providers.dart';

class ProfileHeader extends ConsumerStatefulWidget {
  final String email;
  final int totalArticles;
  final Map<String, int> categoryCounts;
  final String? fullName;
  final String avatarUrl;
  final UserRole role;

  const ProfileHeader({
    super.key,
    required this.email,
    required this.totalArticles,
    required this.categoryCounts,
    required this.avatarUrl,
    required this.role,
    this.fullName,
  });

  @override
  ConsumerState<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<ProfileHeader> {
  bool _uploadingPhoto = false;

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    final bytes = await picked.readAsBytes();
    final ok = await ref.read(authControllerProvider.notifier).uploadProfilePhoto(
          bytes: bytes,
          filename: picked.name,
        );

    if (!mounted) return;
    setState(() => _uploadingPhoto = false);
    if (!ok) {
      final error = ref.read(authControllerProvider).errorMessage ??
          'No se pudo actualizar la foto de perfil';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final displayName = widget.fullName?.isNotEmpty == true ? widget.fullName! : widget.email;
    final forSaleCount = ref.watch(profileAssetsControllerProvider).assets
        .where((a) => a.isForSale)
        .length;

    return Container(
      margin: const EdgeInsets.all(VaultSpacing.lg),
      padding: const EdgeInsets.all(VaultSpacing.lg),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        boxShadow: VaultShadows.card,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.role.displayName, style: tt.titleMedium),
                    Text(widget.email, style: tt.labelSmall),
                  ],
                ),
              ),
              _AvatarPicker(
                avatarUrl: widget.avatarUrl,
                uploading: _uploadingPhoto,
                onTap: _pickPhoto,
              ),
            ],
          ),
          const SizedBox(height: VaultSpacing.sm),
          Text(displayName, style: tt.headlineSmall, textAlign: TextAlign.center),
          const Divider(height: VaultSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatColumn(label: 'Artículos', value: '${widget.totalArticles}'),
              _StatColumn(label: 'En venta', value: '$forSaleCount'),
            ],
          ),
          const SizedBox(height: VaultSpacing.md),
          if (widget.categoryCounts.isEmpty)
            Text('Aún no tienes artículos registrados', style: tt.bodyMedium)
          else
            Wrap(
              alignment: WrapAlignment.center,
              spacing: VaultSpacing.sm,
              runSpacing: VaultSpacing.sm,
              children: widget.categoryCounts.entries
                  .map((e) => _CategoryChip(label: '${e.key} (${e.value})'))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  final String avatarUrl;
  final bool uploading;
  final VoidCallback onTap;

  const _AvatarPicker({required this.avatarUrl, required this.uploading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: uploading ? null : onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: VaultColors.primary.withValues(alpha: 0.1),
            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            child: avatarUrl.isEmpty
                ? Icon(Icons.person, size: 36, color: VaultColors.primary)
                : null,
          ),
          if (uploading)
            const Positioned.fill(
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: VaultColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(value, style: tt.headlineSmall),
        Text(label, style: tt.bodyMedium),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: VaultSpacing.md, vertical: VaultSpacing.xs),
      decoration: BoxDecoration(
        color: VaultColors.background,
        borderRadius: VaultRadius.buttonBorder,
        border: Border.all(color: VaultColors.divider),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class AssetsBody extends StatelessWidget {
  final WidgetRef ref;
  final ProfileAssetsState state;

  const AssetsBody({super.key, required this.ref, required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case ProfileAssetsStatus.initial:
      case ProfileAssetsStatus.loading:
        return const Padding(
          padding: EdgeInsets.all(VaultSpacing.xxl),
          child: Center(child: CircularProgressIndicator()),
        );
      case ProfileAssetsStatus.error:
        return Padding(
          padding: const EdgeInsets.all(VaultSpacing.xl),
          child: Column(
            children: [
              Text(state.errorMessage ?? 'Error al cargar tus artículos'),
              const SizedBox(height: VaultSpacing.md),
              TextButton(
                onPressed: () => ref
                    .read(profileAssetsControllerProvider.notifier)
                    .loadAssets(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      case ProfileAssetsStatus.loaded:
        if (state.assets.isEmpty) return const EmptyAssetsView();
        return AssetsGrid(assets: state.assets);
    }
  }
}

class EmptyAssetsView extends StatelessWidget {
  const EmptyAssetsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: VaultSpacing.xxl, horizontal: VaultSpacing.xl),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 56, color: VaultColors.textSecondary),
          const SizedBox(height: VaultSpacing.md),
          Text(
            'Aún no has registrado ningún activo',
            textAlign: TextAlign.center,
            style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: VaultSpacing.xs),
          Text(
            'Usa el botón "Agregar activo" para registrar tu primera pieza',
            textAlign: TextAlign.center,
            style: tt.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class AssetsGrid extends StatelessWidget {
  final List<AssetEntity> assets;

  const AssetsGrid({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(VaultSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: VaultSpacing.md,
        crossAxisSpacing: VaultSpacing.md,
        childAspectRatio: 0.66,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) => AssetCard(asset: assets[index]),
    );
  }
}

class AssetCard extends ConsumerWidget {
  final AssetEntity asset;

  const AssetCard({super.key, required this.asset});

  void _openPublishSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VaultColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(VaultRadius.card)),
      ),
      builder: (_) => PublishAssetSheet(asset: asset),
    );
  }

  void _openSellSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VaultColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(VaultRadius.card)),
      ),
      builder: (_) => SellAssetSheet(asset: asset),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final notifier = ref.read(profileAssetsControllerProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        boxShadow: VaultShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.assetDetail, extra: asset),
                child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: VaultColors.background,
                    child: Center(
                      child: Icon(Icons.image_outlined,
                          size: VaultIconSize.lg,
                          color: VaultColors.textSecondary),
                    ),
                  ),
                ),
                if (asset.isPublished)
                  Positioned(
                    top: VaultSpacing.xs,
                    left: VaultSpacing.xs,
                    child: _StatusBadge(
                      label: 'Publicado',
                      color: VaultColors.primary,
                    ),
                  ),
                if (asset.isForSale)
                  Positioned(
                    top: VaultSpacing.xs,
                    right: VaultSpacing.xs,
                    child: _StatusBadge(
                      label: '\$${asset.salePrice?.toStringAsFixed(0) ?? ''}',
                      color: VaultColors.accent,
                    ),
                  ),
              ],
            ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: VaultSpacing.sm, vertical: VaultSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.brand, style: tt.titleMedium?.copyWith(fontSize: 12)),
                Text(asset.name,
                    style: tt.bodyLarge?.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('Talla: ${asset.size}',
                    style: tt.bodyMedium?.copyWith(fontSize: 10)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: VaultSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CardAction(
                  icon: asset.isPublished ? Icons.public : Icons.public_off,
                  color: asset.isPublished
                      ? VaultColors.primary
                      : VaultColors.textSecondary,
                  onTap: () => _openPublishSheet(context),
                ),
                _CardAction(
                  icon: asset.isForSale ? Icons.sell : Icons.sell_outlined,
                  color: asset.isForSale
                      ? VaultColors.accent
                      : VaultColors.textSecondary,
                  onTap: () => _openSellSheet(context),
                ),
                _CardAction(
                  icon: Icons.delete_outline,
                  color: VaultColors.textSecondary,
                  onTap: () => notifier.deleteAsset(asset.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge de estado (Publicado / En venta) sobre la imagen del activo.
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: VaultSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(VaultRadius.sm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Botón de acción de la card, con densidad compacta.
class _CardAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CardAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: VaultIconSize.sm, color: color),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}

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
    ref.read(profileAssetsControllerProvider.notifier).setForSale(
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
    ref.read(profileAssetsControllerProvider.notifier).setForSale(
      widget.asset,
      forSale: false,
    );
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
              style: const TextStyle(color: VaultColors.primary),
              decoration: InputDecoration(
                labelText: 'Precio de venta',
                prefixIcon:
                const Icon(Icons.attach_money, color: VaultColors.primary),
                filled: true,
                fillColor: VaultColors.background,
                border: OutlineInputBorder(
                  borderRadius: VaultRadius.buttonBorder,
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) {
                final value = double.tryParse((v ?? '').trim());
                if (value == null || value <= 0) return 'Ingresa un precio válido';
                return null;
              },
            ),
            const SizedBox(height: VaultSpacing.md),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(color: VaultColors.primary),
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
              label: Text(alreadyForSale ? 'Guardar cambios' : 'Poner en venta'),
            ),
            if (alreadyForSale) ...[
              const SizedBox(height: VaultSpacing.sm),
              TextButton.icon(
                onPressed: _removeFromSale,
                style: TextButton.styleFrom(
                    foregroundColor: VaultColors.error),
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
    _captionController =
        TextEditingController(text: widget.asset.publishCaption ?? '');
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _publish() {
    ref.read(profileAssetsControllerProvider.notifier).setPublished(
      widget.asset,
      published: true,
      caption: _captionController.text.trim().isEmpty
          ? null
          : _captionController.text.trim(),
    );
    Navigator.pop(context);
  }

  void _unpublish() {
    ref.read(profileAssetsControllerProvider.notifier).setPublished(
      widget.asset,
      published: false,
    );
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
          Text('Presume ${widget.asset.name} en la comunidad',
              style: tt.bodyMedium),
          const SizedBox(height: VaultSpacing.lg),
          TextField(
            controller: _captionController,
            maxLines: 3,
            style: const TextStyle(color: VaultColors.primary),
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
