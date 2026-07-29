import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_widgets.dart';
import '../../models/dua_model.dart';
import '../../models/favorite_model.dart';
import '../../providers/favorites_provider.dart';

/// Écran unifié des favoris (sourates, douas, hadiths).
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favoris')),
      body: favorites.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.favorite_outline,
              title: 'Aucun favori',
              subtitle: 'Ajoutez des sourates, douas ou hadiths à vos favoris',
            )
          : DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: AppColors.emerald,
                    tabs: [
                      Tab(text: 'Sourates'),
                      Tab(text: 'Douas'),
                      Tab(text: 'Hadiths'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _FavoritesList(
                          items: favorites
                              .where((f) => f.type == FavoriteType.surah)
                              .toList(),
                          emptyMessage: 'Aucune sourate favorite',
                        ),
                        _FavoritesList(
                          items: favorites
                              .where((f) => f.type == FavoriteType.dua)
                              .toList(),
                          emptyMessage: 'Aucune invocation favorite',
                          onTap: (item) {
                            if (item.data != null) {
                              context.push(
                                '/dua/${item.id}',
                                extra: Dua.fromJson(item.data!),
                              );
                            }
                          },
                        ),
                        _FavoritesList(
                          items: favorites
                              .where((f) => f.type == FavoriteType.hadith)
                              .toList(),
                          emptyMessage: 'Aucun hadith favorite',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _FavoritesList extends ConsumerWidget {
  const _FavoritesList({
    required this.items,
    required this.emptyMessage,
    this.onTap,
  });

  final List<FavoriteItem> items;
  final String emptyMessage;
  final void Function(FavoriteItem item)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.bookmark_outline,
        title: emptyMessage,
      );
    }

    final favorites = ref.watch(favoritesProvider.notifier);

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text(item.subtitle),
          trailing: IconButton(
            icon: const Icon(Icons.favorite_rounded, color: AppColors.gold),
            onPressed: () => favorites.toggle(item),
          ),
          onTap: () {
            if (onTap != null) {
              onTap!(item);
            } else if (item.type == FavoriteType.surah) {
              context.push('/quran/${item.id}');
            }
          },
        );
      },
    );
  }
}
