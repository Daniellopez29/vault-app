import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'widgets.dart';

class FavoritesTab extends ConsumerWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesControllerProvider);

    switch (state.status) {
      case FavoritesStatus.initial:
      case FavoritesStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case FavoritesStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.errorMessage ?? 'Error al cargar favoritos'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref
                    .read(favoritesControllerProvider.notifier)
                    .loadSavedPosts(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      case FavoritesStatus.loaded:
        if (state.posts.isEmpty) return const EmptyFavoritesView();
        return RefreshIndicator(
          onRefresh: () => ref
              .read(favoritesControllerProvider.notifier)
              .loadSavedPosts(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.posts.length,
            itemBuilder: (context, index) {
              final post = state.posts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FavoriteCard(
                  post: post,
                  onRemove: () => ref
                      .read(favoritesControllerProvider.notifier)
                      .removeSavedPost(post.id),
                ),
              );
            },
          ),
        );
    }
  }
}