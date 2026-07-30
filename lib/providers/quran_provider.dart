import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quran_model.dart';
import '../repositories/quran_repository.dart';

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository();
});

final surahsProvider = FutureProvider<List<Surah>>((ref) async {
  return ref.watch(quranRepositoryProvider).getAllSurahs();
});

final surahDetailProvider = FutureProvider.family<SurahDetail, int>((ref, surahNumber) async {
  return ref.watch(quranRepositoryProvider).getSurahDetail(surahNumber);
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
    // Recherche par numéro
    if (int.tryParse(q) != null && s.number == int.parse(q)) {
      return true;
    }
    // Recherche par nom arabe
    if (s.nameArabic.toLowerCase().contains(q)) return true;
    // Recherche par nom anglais
    if (s.englishName.toLowerCase().contains(q)) return true;
    // Recherche par traduction
    if (s.englishNameTranslation.toLowerCase().contains(q)) return true;
    return false;
  }).toList();
});