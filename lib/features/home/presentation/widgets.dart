import 'package:flutter/material.dart';

const _kDark = Color(0xFF2D2D3A); // mismo color que usas en los botones de login

/// Barra de navegación inferior de Vault: Shop, Home, [+], Carrito, Perfil.
/// El [+] es una acción (abrir "Nuevo Activo"), no una pestaña.
class VaultBottomNavBar extends StatelessWidget {
  final int currentIndex; // 0=Shop, 1=Home, 2=Carrito, 3=Perfil
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;

  const VaultBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.08))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavIcon(icon: Icons.storefront_outlined, isActive: currentIndex == 0, onTap: () => onTabSelected(0)),
          _NavIcon(icon: Icons.home_outlined, isActive: currentIndex == 1, onTap: () => onTabSelected(1)),
          _AddButton(onTap: onAddPressed),
          _NavIcon(icon: Icons.shopping_bag_outlined, isActive: currentIndex == 2, onTap: () => onTabSelected(2)),
          _NavIcon(icon: Icons.person_outline, isActive: currentIndex == 3, onTap: () => onTabSelected(3)),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIcon({required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 26, color: isActive ? _kDark : _kDark.withValues(alpha: 0.35)),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _kDark, width: 1.5)),
        child: const Icon(Icons.add, color: _kDark, size: 22),
      ),
    );
  }
}

/// Placeholder reutilizable para pantallas pendientes de diseñar.
class PlaceholderView extends StatelessWidget {
  final String title;
  const PlaceholderView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
    );
  }
}