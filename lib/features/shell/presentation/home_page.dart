import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums.dart';
import '../../../../core/router.dart';
import '../../home/presentation/feed_tab.dart';
import '../../profile/presentation/profile_tab.dart';
import '../../reviews/presentation/reviews_tab.dart';
import '../../services/presentation/services_tab.dart';
import '../../marketplace/presentation/shop_view.dart';
import '../../marketplace/presentation/seller_commerce_view.dart';
import '../../cart/presentation/cart_tab.dart';
import '../../auth/presentation/providers.dart';
import '../../home/presentation/widgets.dart';

/// Shell principal de la app ya con sesión iniciada.
/// Arma el IndexedStack de pestañas y el bottom nav según el rol.
/// No es autenticación (eso vive en auth) ni el feed (eso es la feature home).
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 1;

  List<Widget> _buildPages(UserRole role) {
    switch (role) {
      case UserRole.user:
        return const [
          ShopView(),
          FeedTab(),
          CartTab(),
          ProfileTab(),
        ];
      case UserRole.seller:
        return const [
          ShopView(),
          FeedTab(),
          SellerCommerceView(),
          ProfileTab(),
        ];
      case UserRole.restorer:
        return const [
          FeedTab(),
          ServicesTab(),
          ReviewsTab(),
          ProfileTab(),
        ];
      case UserRole.service:
        return const [
          FeedTab(),
          ServicesTab(),
          ReviewsTab(),
          ProfileTab(),
        ];
    }
  }

  List<_NavItem> _buildNavItems(UserRole role) {
    switch (role) {
      case UserRole.user:
        return const [
          _NavItem(icon: Icons.storefront_outlined,   label: 'Shop'),
          _NavItem(icon: Icons.home_outlined,         label: 'Feed'),
          _NavItem(icon: Icons.add,                   label: ''),
          _NavItem(icon: Icons.shopping_cart_outlined, label: 'Cart'),
          _NavItem(icon: Icons.person_outline,        label: 'Perfil'),
        ];
      case UserRole.seller:
        return const [
          _NavItem(icon: Icons.storefront_outlined,   label: 'Shop'),
          _NavItem(icon: Icons.home_outlined,         label: 'Feed'),
          _NavItem(icon: Icons.add,                   label: ''),
          _NavItem(icon: Icons.sell_outlined,         label: 'Ventas'),
          _NavItem(icon: Icons.person_outline,        label: 'Perfil'),
        ];
      case UserRole.restorer:
        return const [
          _NavItem(icon: Icons.home_outlined,  label: 'Feed'),
          _NavItem(icon: Icons.build_outlined, label: 'Servicios'),
          _NavItem(icon: Icons.add,            label: ''),
          _NavItem(icon: Icons.star_outline,   label: 'Reseñas'),
          _NavItem(icon: Icons.person_outline, label: 'Perfil'),
        ];
      case UserRole.service:
        return const [
          _NavItem(icon: Icons.home_outlined,  label: 'Feed'),
          _NavItem(icon: Icons.build_outlined, label: 'Servicios'),
          _NavItem(icon: Icons.add,            label: ''),
          _NavItem(icon: Icons.star_outline,   label: 'Reseñas'),
          _NavItem(icon: Icons.person_outline, label: 'Perfil'),
        ];
    }
  }

  /// El botón "+" siempre es "crear publicación" para el Feed, igual para
  /// todos los roles.
  void _onAddPressed() {
    context.push(AppRoutes.createPost);
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authControllerProvider).user?.role ?? UserRole.user;
    final pages = _buildPages(role);
    final navItems = _buildNavItems(role);

    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _currentIndex, children: pages),
      ),
      bottomNavigationBar: VaultBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: (navIndex) {
          final pageIndex = navIndex > 2 ? navIndex - 1 : navIndex;
          setState(() => _currentIndex = pageIndex);
        },
        onAddPressed: _onAddPressed,
        navItems: navItems,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}


