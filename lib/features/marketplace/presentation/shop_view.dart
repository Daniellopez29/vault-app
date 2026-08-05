import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../business/presentation/businesses_tab.dart';
import '../../services/presentation/services_directory_page.dart';
import 'shop_tab.dart';

/// Contenedor del Shop con dos apartados deslizables:
/// 1) "Productos": el catálogo del marketplace (ShopTab, sin cambios).
/// 2) "Negocios": el directorio de negocios registrados.
///
/// Las pestañas hacen visible que ambos existen; el TabBarView permite
/// además deslizar entre ellos con el dedo.
class ShopView extends StatelessWidget {
  const ShopView({super.key});

  @override
  Widget build(BuildContext context) {
    // ShopView vive en el IndexedStack persistente del shell (home_page.dart)
    // y su padre nunca la reconstruye tras el primer build, así que sin esto
    // el AppBar/TabBar se quedan con los colores del modo con el que se montó.
    Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: VaultColors.background,
        appBar: AppBar(
          backgroundColor: VaultColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
          bottom: TabBar(
            labelColor: VaultColors.primary,
            unselectedLabelColor: VaultColors.textSecondary,
            indicatorColor: VaultColors.primary,
            tabs: [
              Tab(text: 'Productos'),
              Tab(text: 'Negocios'),
              Tab(text: 'Especialistas'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [ShopTab(), BusinessesTab(), ServicesDirectoryPage()],
        ),
      ),
    );
  }
}
