import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/dimens.dart';
import '../../../core/enums.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';
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

