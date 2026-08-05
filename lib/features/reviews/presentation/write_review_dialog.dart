import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../domain/usecases.dart';
import 'providers.dart';

/// Diálogo para reseñar a un vendedor -- el backend exige que quien lo
/// abre ya le haya comprado algo a `providerId` (ver
/// `CreateReviewUseCase.Execute` en api/, que devuelve 403 si no).
class WriteReviewDialog extends ConsumerStatefulWidget {
  final String providerId;

  const WriteReviewDialog({super.key, required this.providerId});

  @override
  ConsumerState<WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends ConsumerState<WriteReviewDialog> {
  final _controller = TextEditingController();
  bool _sending = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _sending = true;
      _errorMessage = null;
    });

    final result = await ref.read(addReviewUseCaseProvider)(
      AddReviewParams(providerId: widget.providerId, content: content),
    );

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _sending = false;
        _errorMessage = failure.message;
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return AlertDialog(
      title: const Text('Dejar reseña'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cuéntale a otros compradores cómo fue tu experiencia con este vendedor.',
            style: TextStyle(color: VaultColors.textSecondary),
          ),
          const SizedBox(height: VaultSpacing.md),
          TextField(
            controller: _controller,
            maxLines: 4,
            maxLength: 500,
            autofocus: true,
            enabled: !_sending,
            decoration: const InputDecoration(
              hintText: 'Escribe tu reseña...',
              border: OutlineInputBorder(),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: VaultSpacing.sm),
            Text(_errorMessage!, style: TextStyle(color: VaultColors.error)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _sending ? null : _submit,
          child: _sending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Publicar'),
        ),
      ],
    );
  }
}
