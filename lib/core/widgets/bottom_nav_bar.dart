import 'package:flutter/material.dart';
import '../dimens.dart';
import '../theme.dart';

/// Un elemento de la barra de navegación inferior.
/// Vive en core porque lo usan tanto el shell (que arma el nav por rol)
/// como la propia barra.
class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}

/// Barra de navegación inferior de la app, con el botón "+" central.
///
/// El botón "+" no representa una página: por eso el índice del botón se
/// convierte al índice de página saltándolo.
class VaultBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;
  final List<NavItem> navItems;

  const VaultBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddPressed,
    required this.navItems,
  });

  @override
  Widget build(BuildContext context) {
    // Sin esto, esta barra (persistente en el shell, nunca reconstruida por
    // su padre) se queda con los colores del modo con el que se montó,
    // porque solo usa VaultColors y nunca lee Theme.of.
    Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: VaultColors.surface,
        border: Border(top: BorderSide(color: VaultColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: VaultSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              if (item.icon == Icons.add) {
                return _AddButton(onTap: onAddPressed);
              }
              final pageIndex = index > 2 ? index - 1 : index;
              return _NavIcon(
                icon: item.icon,
                isActive: currentIndex == pageIndex,
                onTap: () => onTabSelected(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: VaultIconSize.lg,
        color: isActive ? VaultColors.primary : VaultColors.textSecondary,
      ),
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: VaultColors.primary, width: 1.5),
        ),
        child: Icon(
          Icons.add,
          color: VaultColors.primary,
          size: VaultIconSize.md,
        ),
      ),
    );
  }
}
