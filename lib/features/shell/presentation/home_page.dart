import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../home/presentation/feed_tab.dart';
import '../../profile/presentation/profile_tab.dart';
import '../../marketplace/presentation/shop_view.dart';
import '../../cart/presentation/cart_tab.dart';

/// Shell principal de la app ya con sesión iniciada.
///
/// La navegación es la misma para todos los roles: lo específico de cada rol
/// (comercio, servicios, reseñas) vive dentro del Perfil, no en el nav.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 1;

  static const _pages = [
    ShopView(),
    FeedTab(),
    CartTab(),
    ProfileTab(),
  ];

  static const _navItems = [
    NavItem(icon: Icons.storefront_outlined, label: 'Shop'),
    NavItem(icon: Icons.home_outlined, label: 'Feed'),
    NavItem(icon: Icons.add, label: ''),
    NavItem(icon: Icons.shopping_cart_outlined, label: 'Cart'),
    NavItem(icon: Icons.person_outline, label: 'Perfil'),
  ];

  /// El botón "+" siempre es "crear publicación" para el Feed.
  void _onAddPressed() {
    context.push(AppRoutes.createPost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: VaultBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: (navIndex) {
          final pageIndex = navIndex > 2 ? navIndex - 1 : navIndex;
          setState(() => _currentIndex = pageIndex);
        },
        onAddPressed: _onAddPressed,
        navItems: _navItems,
      ),
    );
  }
}
