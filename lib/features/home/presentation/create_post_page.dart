import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/dashed_border.dart';
import '../../../core/dimens.dart';
import '../../../core/error.dart';
import '../../../core/theme.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';
import 'providers.dart';

/// Pantalla del botón "+" de la barra inferior: publicar en el Feed, con
/// texto y/o fotos. El backend exige texto aunque haya fotos (comentario
/// mínimo), así que el campo de texto siempre es obligatorio.
class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final _contentController = TextEditingController();
  final List<XFile> _images = [];
  bool _posting = false;

  @override
  void dispose() {
    _contentController.dispose();
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

  Future<void> _publish() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Escribe algo para publicar')));
      return;
    }

    setState(() => _posting = true);

    final images = <PostImageUpload>[];
    for (final image in _images) {
      images.add(PostImageUpload(bytes: await image.readAsBytes(), filename: image.name));
    }

    final result = await ref.read(createPostUseCaseProvider).call(
          CreatePostParams(content: content, images: images),
        );

    if (!mounted) return;
    setState(() => _posting = false);

    result.fold(
      (failure) {
        // No se limpia el texto ni las fotos: el usuario puede corregir y
        // reintentar (importante para ModerationFailure -- contenido
        // rechazado por ofensivo, o servicio de moderación caído).
        final isModeration = failure is ModerationFailure;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: isModeration ? VaultColors.error : null,
          ),
        );
      },
      (_) {
        ref.read(feedControllerProvider.notifier).loadFeed();
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: const Text('Nueva publicación'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: VaultSpacing.md),
            child: Center(
              child: _posting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton(
                      onPressed: _publish,
                      child: const Text('Publicar'),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(VaultSpacing.lg),
          children: [
            TextField(
              controller: _contentController,
              maxLines: 6,
              minLines: 3,
              style: const TextStyle(color: VaultColors.primary),
              decoration: InputDecoration(
                hintText: '¿Qué quieres compartir con la comunidad?',
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
            ),
            const SizedBox(height: VaultSpacing.lg),
            Text('Fotos (opcional)', style: tt.titleMedium),
            const SizedBox(height: VaultSpacing.sm),
            Wrap(
              spacing: VaultSpacing.sm,
              runSpacing: VaultSpacing.sm,
              children: [
                for (var i = 0; i < _images.length; i++) _ImageThumb(
                  image: _images[i],
                  onRemove: () => _removeImage(i),
                ),
                _AddImageTile(onTap: _addImages),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final XFile image;
  final VoidCallback onRemove;

  const _ImageThumb({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: VaultRadius.cardBorder,
          // Image.memory (no Image.network/Image.file) funciona igual en
          // web y móvil a partir de los bytes que ya nos da XFile.
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

class _AddImageTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddImageTile({required this.onTap});

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
