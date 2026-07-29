import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/loading_widgets.dart';
import '../../providers/quran_provider.dart';

/// Liste des 114 sourates avec recherche et favoris.
class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(filteredSurahsProvider);
    final lastRead = ref.watch(lastReadProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('Le Saint Coran'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (v) =>
                    ref.read(quranSearchProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: 'Rechercher par nom ou numéro...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: lastRead.surah > 1
                      ? IconButton(
                          icon: const Icon(Icons.bookmark_rounded),
                          color: AppColors.gold,
                          onPressed: () =>
                              context.push('/quran/${lastRead.surah}'),
                          tooltip: 'Reprendre la lecture',
                        )
                      : null,
                ),
              ),
            ),
          ),
          surahsAsync.when(
            loading: () => const SliverFillRemaining(
              child: ShimmerListPlaceholder(),
            ),
            error: (e, _) => SliverFillRemaining(
              child: ErrorStateWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(surahsProvider),
              ),
            ),
            data: (surahs) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final surah = surahs[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.emerald.withValues(alpha: 0.12),
                      child: Text(
                        '${surah.number}',
                        style: const TextStyle(
                          color: AppColors.emerald,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(surah.englishName),
                    subtitle: Text(
                      '${surah.englishNameTranslation} • ${surah.numberOfAyahs} versets',
                    ),
                    trailing: Text(
                      surah.name,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                      ),
                    ),
                    onTap: () => context.push('/quran/${surah.number}'),
                  );
                },
                childCount: surahs.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
