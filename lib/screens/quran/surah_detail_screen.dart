import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/arabic_text.dart';
import '../../core/widgets/loading_widgets.dart';
import '../../models/quran_model.dart';
import '../../providers/quran_provider.dart';

class SurahDetailScreen extends ConsumerStatefulWidget {
  const SurahDetailScreen({super.key, required this.surahNumber});

  final int surahNumber;

  @override
  ConsumerState<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends ConsumerState<SurahDetailScreen> {
  bool _isLastReadSaved = false;
  late final AudioPlayer _player;
  int? _playingAyahIndex;
  bool _isPlayingFullSurah = false;
  bool _isLoadingAudio = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onAudioComplete();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isLastReadSaved) {
        ref.read(quranRepositoryProvider).saveLastRead(widget.surahNumber, 1);
        _isLastReadSaved = true;
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _onAudioComplete() {
    if (_isPlayingFullSurah) {
      setState(() {
        _isPlayingFullSurah = false;
        _playingAyahIndex = null;
      });
      return;
    }
    if (_playingAyahIndex != null) {
      final next = _playingAyahIndex! + 1;
      final detail = ref.read(surahDetailProvider(widget.surahNumber));
      detail.whenData((d) {
        if (next < d.ayahs.length) {
          _playAyah(next, d);
        } else {
          setState(() => _playingAyahIndex = null);
        }
      });
    }
  }

  Future<void> _playAyah(int index, SurahDetail detail) async {
    final ayah = detail.ayahs[index];
    try {
      setState(() {
        _isLoadingAudio = true;
        _playingAyahIndex = index;
        _isPlayingFullSurah = false;
      });
      await _player.setUrl(ayah.computedAudioUrl);
      await _player.play();
    } catch (_) {
      if (mounted) context.showSnack('Lecture audio impossible');
    } finally {
      if (mounted) setState(() => _isLoadingAudio = false);
    }
  }

  Future<void> _playFullSurah(SurahDetail detail) async {
    try {
      setState(() {
        _isLoadingAudio = true;
        _isPlayingFullSurah = true;
        _playingAyahIndex = null;
      });
      await _player.setUrl(detail.fullSurahAudioUrl);
      await _player.play();
    } catch (_) {
      if (mounted) context.showSnack('Lecture audio impossible');
    } finally {
      if (mounted) setState(() => _isLoadingAudio = false);
    }
  }

  Future<void> _stopAudio() async {
    await _player.stop();
    setState(() {
      _playingAyahIndex = null;
      _isPlayingFullSurah = false;
    });
  }

  void _showAyahOptions(BuildContext context, Ayah ayah, int index, SurahDetail detail) {
    final isPlaying = _playingAyahIndex == index && !_isPlayingFullSurah;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AyahOptionsSheet(
        ayah: ayah,
        isPlaying: isPlaying,
        onPlay: () {
          Navigator.pop(context);
          if (isPlaying) {
            _stopAudio();
          } else {
            _playAyah(index, detail);
          }
        },
        onTranslate: (language) {
          Navigator.pop(context);
          _showTranslation(context, ayah, language);
        },
        onCopy: () {
          Navigator.pop(context);
          final text = '${ayah.text}\n\n${ayah.translation ?? ''}';
          Clipboard.setData(ClipboardData(text: text));
          context.showSnack('Verset copié');
        },
        onShare: () {
          Navigator.pop(context);
          Share.share(
            '${ayah.text}\n\n${ayah.translation ?? ''}\n\n${detail.surah.englishName} ${detail.surah.number}:${ayah.numberInSurah}',
            subject: 'Coran - An-Nour',
          );
        },
      ),
    );
  }

  void _showTranslation(BuildContext context, Ayah ayah, String language) {
    showDialog<void>(
      context: context,
      builder: (context) => _TranslationDialog(ayah: ayah, language: language),
    );
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
          final hasBismillah = detail.hasBismillah;
          final displayAyahs = detail.ayahs;
          final isAudioActive = _isPlayingFullSurah || _playingAyahIndex != null;

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
                  child: Column(
                    children: [
                      Text(
                        '${detail.surah.englishNameTranslation} • ${detail.surah.numberOfAyahs} versets • ${detail.surah.revelationType}',
                        style: context.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: isAudioActive
                            ? _stopAudio
                            : () => _playFullSurah(detail),
                        icon: _isLoadingAudio && _isPlayingFullSurah
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Icon(isAudioActive
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded),
                        label: Text(
                          isAudioActive
                              ? 'Arrêter la lecture'
                              : 'Écouter la sourate',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.emerald,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
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
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ],
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final ayah = displayAyahs[index];
                    final isPlaying = _playingAyahIndex == index && !_isPlayingFullSurah;

                    return _AyahTile(
                      ayah: ayah,
                      isPlaying: isPlaying,
                      isLoadingAudio:
                      _isLoadingAudio && _playingAyahIndex == index,
                      onTap: () =>
                          _showAyahOptions(context, ayah, index, detail),
                      onPlayTap: () {
                        if (isPlaying) {
                          _stopAudio();
                        } else {
                          _playAyah(index, detail);
                        }
                      },
                    );
                  },
                  childCount: displayAyahs.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}

class _AyahTile extends StatelessWidget {
  const _AyahTile({
    required this.ayah,
    required this.isPlaying,
    required this.isLoadingAudio,
    required this.onTap,
    required this.onPlayTap,
  });

  final Ayah ayah;
  final bool isPlaying;
  final bool isLoadingAudio;
  final VoidCallback onTap;
  final VoidCallback onPlayTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: isPlaying
            ? BoxDecoration(
          color: AppColors.emerald.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        )
            : null,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.emerald.withValues(alpha: 0.12),
                  child: Text(
                    '${ayah.numberInSurah}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.emerald,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: isLoadingAudio
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.emerald,
                        ),
                      )
                          : Icon(
                        isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_outline_rounded,
                        color: AppColors.emerald,
                      ),
                      onPressed: onPlayTap,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: onTap,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ArabicText(
              text: ayah.text,
              fontSize: 24,
              color: isPlaying ? AppColors.emerald : null,
            ),
            if (ayah.translation != null && ayah.translation!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(ayah.translation!, style: context.textTheme.bodyLarge),
            ],
            const Divider(height: 32),
          ],
        ),
      ),
    );
  }
}

class _AyahOptionsSheet extends StatelessWidget {
  const _AyahOptionsSheet({
    required this.ayah,
    required this.isPlaying,
    required this.onPlay,
    required this.onTranslate,
    required this.onCopy,
    required this.onShare,
  });

  final Ayah ayah;
  final bool isPlaying;
  final VoidCallback onPlay;
  final void Function(String language) onTranslate;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  static const _languages = [
    ('fr', 'Français'),
    ('en', 'English'),
    ('ar', 'العربية'),
    ('es', 'Español'),
    ('tr', 'Türkçe'),
    ('ur', 'اردو'),
    ('id', 'Indonesia'),
    ('ru', 'Русский'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Verset ${ayah.numberInSurah}',
                style: context.textTheme.titleLarge),
          ),
          ListTile(
            leading: Icon(
              isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
              color: AppColors.emerald,
            ),
            title: Text(isPlaying ? 'Pause' : 'Écouter ce verset'),
            onTap: onPlay,
          ),
          ListTile(
            leading: const Icon(Icons.translate_rounded, color: AppColors.emerald),
            title: const Text('Traduire dans une autre langue'),
            onTap: () => _showLanguagePicker(context),
          ),
          ListTile(
            leading: const Icon(Icons.copy_rounded, color: AppColors.emerald),
            title: const Text('Copier'),
            onTap: onCopy,
          ),
          ListTile(
            leading: const Icon(Icons.share_rounded, color: AppColors.emerald),
            title: const Text('Partager'),
            onTap: onShare,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Choisir une langue',
                  style: context.textTheme.titleLarge),
            ),
            ..._languages.map((lang) => ListTile(
              title: Text(lang.$2),
              onTap: () {
                Navigator.pop(context);
                onTranslate(lang.$1);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _TranslationDialog extends ConsumerWidget {
  const _TranslationDialog({required this.ayah, required this.language});

  final Ayah ayah;
  final String language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationAsync = ref.watch(ayahTranslationProvider(
      (surah: ayah.surahNumber, ayah: ayah.numberInSurah, language: language),
    ));

    return AlertDialog(
      title: const Text('Traduction'),
      content: SizedBox(
        width: double.maxFinite,
        child: translationAsync.when(
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Erreur: $e'),
          data: (translation) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ArabicText(text: ayah.text, fontSize: 20),
                const SizedBox(height: 16),
                Text(
                  translation ?? 'Aucune traduction disponible',
                  style: context.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}