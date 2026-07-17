import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/enums.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';
import '../../favorites/presentation/favorites_tab.dart';
import 'providers.dart';
import 'widgets.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final assetsState = ref.watch(profileAssetsControllerProvider);
    final email = authState.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(authState.user?.fullName ?? email),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: VaultColors.primary,
          labelColor: VaultColors.primary,
          unselectedLabelColor: VaultColors.textSecondary,
          tabs: const [
            Tab(text: 'Mis Activos'),
            Tab(text: 'Guardados'),
          ],
        ),
      ),
      // Solo tiene sentido agregar un activo desde la pestaña "Mis Activos"
      // -- en "Guardados" no se muestra.
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => context.push(AppRoutes.registerAsset),
              tooltip: 'Agregar activo',
              child: const Icon(Icons.add),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: () =>
                ref.read(profileAssetsControllerProvider.notifier).loadAssets(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ProfileHeader(
                    email: email,
                    fullName: authState.user?.fullName,
                    totalArticles: assetsState.totalArticles,
                    categoryCounts: assetsState.categoryCounts,
                    avatarUrl: authState.user?.avatarUrl ?? '',
                    role: authState.user?.role ?? UserRole.user,
                  ),
                ),
                SliverToBoxAdapter(
                  child: AssetsBody(ref: ref, state: assetsState),
                ),
                // Deja espacio para que el FAB no tape el último activo.
                const SliverToBoxAdapter(child: SizedBox(height: 72)),
              ],
            ),
          ),
          const FavoritesTab(),
        ],
      ),
    );
  }
}
