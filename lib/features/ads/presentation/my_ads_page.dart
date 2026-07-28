import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';
import '../domain/usecases.dart';
import 'providers.dart';

/// Pantalla "Mis anuncios": editar/borrar los anuncios propios y ver sus
/// impressions/clicks -- `PUT/DELETE /ads/:id` y el conteo ya existían en
/// el backend sin ninguna pantalla que los usara.
class MyAdsPage extends ConsumerWidget {
  const MyAdsPage({super.key});

  void _confirmDelete(BuildContext context, WidgetRef ref, AdEntity ad) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar anuncio'),
        content: Text('¿Eliminar "${ad.title}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final ok = await ref.read(myAdsControllerProvider.notifier).delete(ad.id);
              if (!context.mounted) return;
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ref.read(myAdsControllerProvider).errorMessage ??
                          'No se pudo eliminar el anuncio',
                    ),
                  ),
                );
              }
            },
            child: Text('Eliminar', style: TextStyle(color: VaultColors.error)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, AdEntity ad) {
    final titleController = TextEditingController(text: ad.title);
    final descriptionController = TextEditingController(text: ad.description);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar anuncio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              autofocus: true,
            ),
            const SizedBox(height: VaultSpacing.md),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;
              Navigator.of(context).pop();
              final ok = await ref.read(myAdsControllerProvider.notifier).update(
                    UpdateAdParams(
                      id: ad.id,
                      title: title,
                      description: descriptionController.text.trim(),
                      imageUrl: ad.imageUrl,
                      targetSection: ad.targetSection,
                      targetId: ad.targetId,
                    ),
                  );
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ref.read(myAdsControllerProvider).errorMessage ??
                          'No se pudo actualizar el anuncio',
                    ),
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myAdsControllerProvider);

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(title: const Text('Mis anuncios')),
      body: switch (state.status) {
        MyAdsStatus.loading => const Center(child: CircularProgressIndicator()),
        MyAdsStatus.error => Center(
            child: Padding(
              padding: const EdgeInsets.all(VaultSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Error al cargar tus anuncios'),
                  const SizedBox(height: VaultSpacing.md),
                  TextButton(
                    onPressed: () => ref.read(myAdsControllerProvider.notifier).load(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        MyAdsStatus.loaded => state.ads.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(VaultSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.campaign_outlined,
                          size: 56, color: VaultColors.textSecondary),
                      const SizedBox(height: VaultSpacing.md),
                      const Text(
                        'Todavía no tienes anuncios',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: VaultSpacing.xs),
                      Text(
                        'Anuncia un producto en venta o tu negocio desde su sección.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: VaultColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(VaultSpacing.md),
                itemCount: state.ads.length,
                separatorBuilder: (_, _) => const SizedBox(height: VaultSpacing.sm),
                itemBuilder: (context, index) {
                  final ad = state.ads[index];
                  return _AdTile(
                    ad: ad,
                    onEdit: () => _showEditDialog(context, ref, ad),
                    onDelete: () => _confirmDelete(context, ref, ad),
                  );
                },
              ),
      },
    );
  }
}

class _AdTile extends StatelessWidget {
  final AdEntity ad;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdTile({required this.ad, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final active = ad.status == 'active';

    return Container(
      padding: const EdgeInsets.all(VaultSpacing.md),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        border: Border.all(color: VaultColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(ad.title, style: tt.titleSmall, maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: VaultSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: active ? VaultColors.success : VaultColors.textSecondary,
                  borderRadius: BorderRadius.circular(VaultRadius.sm),
                ),
                child: Text(
                  active ? 'Activo' : 'Inactivo',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (ad.description.isNotEmpty) ...[
            const SizedBox(height: VaultSpacing.xs),
            Text(ad.description, style: tt.bodySmall?.copyWith(color: VaultColors.textSecondary),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: VaultSpacing.sm),
          Row(
            children: [
              Icon(Icons.visibility_outlined, size: VaultIconSize.sm, color: VaultColors.textSecondary),
              const SizedBox(width: VaultSpacing.xs),
              Text('${ad.impressions}', style: tt.labelSmall),
              const SizedBox(width: VaultSpacing.md),
              Icon(Icons.touch_app_outlined, size: VaultIconSize.sm, color: VaultColors.textSecondary),
              const SizedBox(width: VaultSpacing.xs),
              Text('${ad.clicks}', style: tt.labelSmall),
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, color: VaultColors.textSecondary),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
