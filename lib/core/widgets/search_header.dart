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
  final int unreadNotificationsCount;
  final int unreadChatCount;

  const VaultSearchHeader({
    super.key,
    required this.query,
    required this.onQueryChanged,
    required this.onNotificationsTap,
    required this.onChatTap,
    this.hintText = 'Buscar',
    this.unreadNotificationsCount = 0,
    this.unreadChatCount = 0,
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
            badgeCount: unreadNotificationsCount,
          ),
          _HeaderIconButton(
            icon: Icons.chat_bubble_outline,
            onTap: onChatTap,
            badgeCount: unreadChatCount,
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
/// Muestra un badge con el conteo cuando [badgeCount] > 0 -- antes no había
/// nada que distinguiera "llegó algo nuevo" de "no hay nada", así que había
/// que entrar a la pantalla para enterarte.
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  const _HeaderIconButton({required this.icon, required this.onTap, this.badgeCount = 0});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon,
            color: VaultColors.textPrimary,
            size: VaultIconSize.lg,
          ),
          if (badgeCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 16),
                decoration: const BoxDecoration(
                  color: VaultColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : '$badgeCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
