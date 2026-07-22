import 'package:flutter/material.dart';
import '../dimens.dart';
import '../theme.dart';

/// Header compartido con barra de búsqueda + accesos a notificaciones y chat.
///
/// Vive en core porque lo usan varias features (Shop y Feed). No conoce
/// providers: recibe callbacks, así cada pantalla decide qué filtra y a
/// dónde navega.
class VaultSearchHeader extends StatelessWidget {
  final String query;
  final String hintText;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onNotificationsTap;
  final VoidCallback onChatTap;

  const VaultSearchHeader({
    super.key,
    required this.query,
    required this.onQueryChanged,
    required this.onNotificationsTap,
    required this.onChatTap,
    this.hintText = 'Buscar',
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: VaultColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: VaultSpacing.md,
      toolbarHeight: 68,
      title: Row(
        children: [
          Expanded(
            child: _SearchField(
              query: query,
              hintText: hintText,
              onChanged: onQueryChanged,
            ),
          ),
          const SizedBox(width: VaultSpacing.sm),
          _HeaderIconButton(
            icon: Icons.notifications_outlined,
            onTap: onNotificationsTap,
          ),
          _HeaderIconButton(
            icon: Icons.chat_bubble_outline,
            onTap: onChatTap,
          ),
        ],
      ),
    );
  }
}

/// Campo de búsqueda controlado. Muestra una "X" para limpiar cuando hay texto.
class _SearchField extends StatefulWidget {
  final String query;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.query,
    required this.hintText,
    required this.onChanged,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant _SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mantiene el campo sincronizado si el estado se limpia desde fuera.
    if (widget.query != _controller.text) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: VaultColors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: VaultColors.textSecondary),
        prefixIcon: const Icon(
          Icons.search,
          color: VaultColors.textSecondary,
          size: VaultIconSize.md,
        ),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.close,
                  color: VaultColors.textSecondary,
                  size: VaultIconSize.sm,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
              ),
        filled: true,
        fillColor: VaultColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: VaultSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VaultRadius.card),
          borderSide: const BorderSide(color: VaultColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VaultRadius.card),
          borderSide: const BorderSide(color: VaultColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VaultRadius.card),
          borderSide: const BorderSide(color: VaultColors.primary),
        ),
      ),
    );
  }
}

/// Botón de ícono del header (notificaciones / chat), con estilo consistente.
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: VaultColors.textPrimary,
        size: VaultIconSize.lg,
      ),
    );
  }
}
