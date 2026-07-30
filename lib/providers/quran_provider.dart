import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quran_model.dart';
import '../repositories/quran_repository.dart';
import 'settings_provider.dart';

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository();
});

final surahsProvider = FutureProvider<List<Surah>>((ref) async {
  final language = ref.watch(settingsProvider).locale.languageCode;
  return ref.watch(quranRepositoryProvider).getAllSurahs(language: language);
});

final surahDetailProvider = FutureProvider.family<SurahDetail, int>((ref, surahNumber) async {
  final language = ref.watch(settingsProvider).locale.languageCode;
  return ref.watch(quranRepositoryProvider).getSurahDetail(surahNumber, language: language);
});

final quranSearchProvider = StateProvider<String>((ref) => '');

final lastReadProvider = FutureProvider<({int surah, int ayah})>((ref) async {
  return ref.watch(quranRepositoryProvider).getLastRead();
});

final filteredSurahsProvider = Provider<List<Surah>>((ref) {
  final surahsAsync = ref.watch(surahsProvider);
  final query = ref.watch(quranSearchProvider);

  final surahs = surahsAsync.when(
    data: (data) => data,
    loading: () => <Surah>[],
    error: (_, __) => <Surah>[],
  );

  if (query.isEmpty) return surahs;

  final q = query.toLowerCase().trim();
  return surahs.where((s) {
    if (int.tryParse(q) != null && s.number == int.parse(q)) {
      return true;
    }
    if (s.nameArabic.toLowerCase().contains(q)) return true;
    if (s.englishName.toLowerCase().contains(q)) return true;
    if (s.englishNameTranslation.toLowerCase().contains(q)) return true;
    return false;
  }).toList();
});