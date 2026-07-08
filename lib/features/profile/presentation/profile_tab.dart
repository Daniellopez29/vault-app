import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';
import '../../favorites/presentation/favorites_tab.dart';
import 'providers.dart';
import 'widgets.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final assetsState = ref.watch(profileAssetsControllerProvider);
    final email = authState.user?.email ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(authState.user?.fullName ?? email),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push(AppRoutes.settings),
            ),
          ],
          bottom: TabBar(
            indicatorColor: VaultColors.primary,
            labelColor: VaultColors.primary,
            unselectedLabelColor: VaultColors.textSecondary,
            tabs: const [
              Tab(text: 'Mis Activos'),
              Tab(text: 'Guardados'),
            ],
          ),
        ),
        body: TabBarView(
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
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: AssetsBody(ref: ref, state: assetsState),
                  ),
                ],
              ),
            ),
            const FavoritesTab(),
          ],
        ),
      ),
    );
  }
}