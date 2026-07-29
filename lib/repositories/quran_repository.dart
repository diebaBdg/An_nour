import '../models/quran_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../core/constants/app_constants.dart';

/// Repository pour le Coran (API + cache local).
class QuranRepository {
  QuranRepository({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<Surah>> getAllSurahs() async {
    final data = await _api.getQuran('/surah');
    final surahs = (data['surahs'] as List<dynamic>)
        .map((e) => Surah.fromJson(e as Map<String, dynamic>))
        .toList();
    return surahs;
  }

  Future<SurahDetail> getSurahDetail(int number, {String edition = 'fr.hamidullah'}) async {
    final arabicData = await _api.getQuran('/surah/$number');
    final translationData = await _api.getQuran('/surah/$number/$edition');

    final surah = Surah.fromJson(arabicData);
    final arabicAyahs = arabicData['ayahs'] as List<dynamic>;

    final ayahs = <Ayah>[];
    for (var i = 0; i < arabicAyahs.length; i++) {
      final arabicJson = arabicAyahs[i] as Map<String, dynamic>;
      final transJson = (translationData['ayahs'] as List<dynamic>)[i]
          as Map<String, dynamic>;
      ayahs.add(Ayah.fromJson(
        arabicJson,
        translation: transJson['text'] as String?,
      ));
    }

    return SurahDetail(surah: surah, ayahs: ayahs);
  }

  Future<List<Surah>> searchSurahs(String query, List<Surah> allSurahs) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return Future.value(allSurahs);

    final results = allSurahs.where((s) {
      return s.number.toString() == q ||
          s.name.contains(q) ||
          s.englishName.toLowerCase().contains(q) ||
          s.englishNameTranslation.toLowerCase().contains(q);
    }).toList();

    return Future.value(results);
  }

  Future<void> saveLastRead(int surahNumber, int ayahNumber) async {
    await StorageService.setInt(AppConstants.keyLastSurah, surahNumber);
    await StorageService.setInt(AppConstants.keyLastAyah, ayahNumber);
  }

  ({int surah, int ayah}) getLastRead() {
    return (
      surah: StorageService.getInt(AppConstants.keyLastSurah) ?? 1,
      ayah: StorageService.getInt(AppConstants.keyLastAyah) ?? 1,
    );
  }
}
