import '../../../core/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/enums.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';
import '../../favorites/presentation/favorites_tab.dart';
import '../../home/presentation/feed_tab.dart';
import '../../home/presentation/providers.dart' show feedControllerProvider, FeedStatus;
import 'profile_actions.dart';
import 'providers.dart';
import 'asset_widgets.dart';
import 'profile_header.dart';

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
    _tabController = TabController(length: 3, vsync: this)
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
            Tab(text: 'Publicaciones'),
            Tab(text: 'Guardados'),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              heroTag: 'profile_fab',
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
                    roles: authState.user?.roles ?? [UserRole.user],
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: VaultSpacing.lg),
                    child: ProfileActions(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: AssetsBody(ref: ref, state: assetsState),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 72)),
              ],
            ),
          ),
          _MyPostsTab(userId: authState.user?.id ?? ''),
          const FavoritesTab(),
        ],
      ),
    );
  }
}

/// Tab que muestra solo las publicaciones del usuario actual.
class _MyPostsTab extends ConsumerWidget {
  final String userId;

  const _MyPostsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedControllerProvider);
    final controller = ref.read(feedControllerProvider.notifier);
    final tt = Theme.of(context).textTheme;

    if (feedState.status == FeedStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final myPosts = feedState.posts.where((p) => p.authorId == userId).toList();

    if (myPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(VaultSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.dynamic_feed_outlined,
                  size: VaultIconSize.xl, color: VaultColors.textSecondary),
              const SizedBox(height: VaultSpacing.lg),
              Text(
                'Sin publicaciones',
                style: tt.titleLarge,
              ),
              const SizedBox(height: VaultSpacing.sm),
              Text(
                'Tus publicaciones del feed apareceran aqui.',
                textAlign: TextAlign.center,
                style: tt.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadFeed(),
      child: ListView.builder(
        padding: const EdgeInsets.all(VaultSpacing.md),
        itemCount: myPosts.length,
        itemBuilder: (context, index) {
          final post = myPosts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: VaultSpacing.lg),
            child: PostCard(
              post: post,
              onLikeTap: () => controller.toggleLike(post.id),
              onSaveTap: () => controller.toggleSave(post.id),
              onDeleteTap: () => controller.deletePost(post.id),
            ),
          );
        },
      ),
    );
  }
}
