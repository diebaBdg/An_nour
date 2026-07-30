import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../providers/quran_provider.dart';

class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahsProvider);
    final filteredSurahs = ref.watch(filteredSurahsProvider);
    final lastReadAsync = ref.watch(lastReadProvider);

    print('📱 QuranScreen build - surahsAsync: ${surahsAsync.runtimeType}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le Saint Coran'),
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(surahsProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rafraîchissement...')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (v) =>
                ref.read(quranSearchProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: 'Rechercher par nom ou numéro...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: lastReadAsync.when(
                    data: (lastRead) {
                      if (lastRead.surah > 0) {
                        return IconButton(
                          icon: const Icon(Icons.bookmark_rounded),
                          color: AppColors.gold,
                          onPressed: () =>
                              context.push('/quran/${lastRead.surah}'),
                          tooltip: 'Reprendre la lecture',
                        );
                      }
                      return null;
                    },
                    loading: () => null,
                    error: (_, __) => null,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 0.1),
                ),
              ),
            ),
            Expanded(
              child: surahsAsync.when(
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Chargement des sourates...'),
                    ],
                  ),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erreur: ${e.toString()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(surahsProvider),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
                data: (surahs) {
                  print('📱 Données reçues: ${surahs.length} sourates');
                  print('📱 Filtrées: ${filteredSurahs.length} sourates');

                  if (filteredSurahs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucune sourate trouvée',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredSurahs.length,
                    itemBuilder: (context, index) {
                      final surah = filteredSurahs[index];
                      print('📱 Affichage: ${surah.id} - ${surah.englishName}');

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                            AppColors.emerald.withValues(alpha: 0.12),
                            child: Text(
                              '${surah.number}',
                              style: const TextStyle(
                                color: AppColors.emerald,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          title: Text(
                            surah.englishName.isNotEmpty
                                ? surah.englishName
                                : 'Sourate ${surah.number}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${surah.englishNameTranslation.isNotEmpty ? surah.englishNameTranslation : "Sourate"} • ${surah.numberOfAyahs} versets',
                          ),
                          trailing: Text(
                            surah.nameArabic.isNotEmpty
                                ? surah.nameArabic
                                : surah.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => context.push('/quran/${surah.number}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}