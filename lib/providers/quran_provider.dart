import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quran_model.dart';
import '../repositories/quran_repository.dart';

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository();
});

final surahsProvider = FutureProvider<List<Surah>>((ref) async {
  return ref.watch(quranRepositoryProvider).getAllSurahs();
});

final surahDetailProvider =
    FutureProvider.family<SurahDetail, int>((ref, surahNumber) async {
  return ref.watch(quranRepositoryProvider).getSurahDetail(surahNumber);
});

final quranSearchProvider = StateProvider<String>((ref) => '');

final filteredSurahsProvider = Provider<AsyncValue<List<Surah>>>((ref) {
  final surahsAsync = ref.watch(surahsProvider);
  final query = ref.watch(quranSearchProvider);

  return surahsAsync.whenData((surahs) {
    if (query.isEmpty) return surahs;
    final q = query.toLowerCase();
    return surahs
        .where((s) =>
            s.number.toString() == q ||
            s.name.contains(q) ||
            s.englishName.toLowerCase().contains(q),)
        .toList();
  });
});

final lastReadProvider = Provider<({int surah, int ayah})>((ref) {
  return ref.watch(quranRepositoryProvider).getLastRead();
});
