import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/arabic_text.dart';
import '../../core/widgets/loading_widgets.dart';
import '../../providers/quran_provider.dart';

/// Lecture d'une sourate avec texte arabe et traduction française.
class SurahDetailScreen extends ConsumerStatefulWidget {
  const SurahDetailScreen({super.key, required this.surahNumber});

  final int surahNumber;

  @override
  ConsumerState<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends ConsumerState<SurahDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quranRepositoryProvider).saveLastRead(widget.surahNumber, 1);
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
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final ayah = detail.ayahs[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
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
                            ],
                          ),
                          const SizedBox(height: 12),
                          ArabicText(text: ayah.text, fontSize: 24),
                          if (ayah.translation != null) ...[
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
                  childCount: detail.ayahs.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
