import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/arabic_text.dart';
import '../../core/widgets/loading_widgets.dart';
import '../../providers/quran_provider.dart';

class SurahDetailScreen extends ConsumerStatefulWidget {
  const SurahDetailScreen({super.key, required this.surahNumber});

  final int surahNumber;

  @override
  ConsumerState<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends ConsumerState<SurahDetailScreen> {
  bool _isLastReadSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isLastReadSaved) {
        ref
            .read(quranRepositoryProvider)
            .saveLastRead(widget.surahNumber, 1);
        _isLastReadSaved = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(surahDetailProvider(widget.surahNumber));

    return Scaffold(
      body: detailAsync.when(
        loading: () =>
        const LoadingIndicator(message: 'Chargement de la sourate...'),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () =>
              ref.invalidate(surahDetailProvider(widget.surahNumber)),
        ),
        data: (detail) {
          final hasBismillah = detail.surah.number != 9 && detail.bismillah != null;
          final displayAyahs = detail.ayahs;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 160,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(detail.surah.englishName),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.emerald, AppColors.emeraldDark],
                      ),
                    ),
                    child: Center(
                      child: ArabicText(
                        text: detail.surah.name,
                        fontSize: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '${detail.surah.englishNameTranslation} • ${detail.surah.numberOfAyahs} versets • ${detail.surah.revelationType}',
                    style: context.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              if (hasBismillah) ...[
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.emerald.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        ArabicText(
                          text: detail.bismillah!,
                          fontSize: 28,
                          color: AppColors.emerald,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Au nom d\'Allah, le Tout Miséricordieux, le Très Miséricordieux',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 8),
                ),
              ],
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    // Si on a un Bismillah, on saute le premier verset car il contient le Bismillah
                    final ayahIndex = hasBismillah ? index + 1 : index;

                    if (ayahIndex >= displayAyahs.length) {
                      return const SizedBox.shrink();
                    }

                    final ayah = displayAyahs[ayahIndex];

                    final bool isFirstAyahAfterBismillah = hasBismillah && index == 0;

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Indicateur de verset
                              CircleAvatar(
                                radius: 14,
                                backgroundColor:
                                AppColors.emerald.withValues(alpha: 0.12),
                                child: Text(
                                  '${ayah.numberInSurah}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.emerald,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Indicateur "premier verset" si c'est le cas
                              if (isFirstAyahAfterBismillah)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Premier verset',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ArabicText(
                            text: ayah.text,
                            fontSize: 24,
                          ),
                          if (ayah.translation != null && ayah.translation!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              ayah.translation!,
                              style: context.textTheme.bodyLarge,
                            ),
                          ],
                          const Divider(height: 32),
                        ],
                      ),
                    );
                  },
                  // Ajuster le nombre d'items
                  childCount: hasBismillah
                      ? displayAyahs.length - 1
                      : displayAyahs.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}