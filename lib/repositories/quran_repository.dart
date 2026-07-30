import '../models/quran_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../core/constants/app_constants.dart';

class QuranRepository {
  QuranRepository({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  /// Map des langues vers les IDs de traduction disponibles.
  static const Map<String, int> _translationIds = {
    'fr': 31, // Muhammad Hamidullah
    'en': 20, // Saheeh International
    'ar': 136, // Montada Islamic Foundation
  };

  int _translationIdFor(String language) =>
      _translationIds[language] ?? _translationIds['en']!;

  Future<List<Surah>> getAllSurahs({String language = 'fr'}) async {
    try {
      final response = await _api.get('/chapters?language=$language');
      if (response.containsKey('chapters')) {
        final chapters = response['chapters'] as List<dynamic>;
        return chapters
            .map((e) => Surah.fromQuranApiJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Format de réponse inattendu');
    } catch (e) {
      throw Exception('Erreur lors du chargement des sourates: $e');
    }
  }

  Future<SurahDetail> getSurahDetail(int number, {String language = 'fr'}) async {
    try {
      // 1. Versets en arabe (texte uthmani)
      final arabicResponse =
          await _api.get('/quran/verses/uthmani?chapter_number=$number');

      // 2. Traduction dans la langue sélectionnée
      final translationId = _translationIdFor(language);
      final translationResponse =
          await _api.get('/quran/translations/$translationId?chapter_number=$number');

      // 3. Infos de la sourate (nom traduit selon la langue)
      final chapterResponse = await _api.get('/chapters?language=$language');
      final chapters = chapterResponse['chapters'] as List<dynamic>;
      final surahJson = chapters.firstWhere(
        (c) => (c as Map<String, dynamic>)['id'] as int? == number,
        orElse: () => <String, dynamic>{'id': number},
      ) as Map<String, dynamic>;
      final surah = Surah.fromQuranApiJson(surahJson);

      // 4. Construire la map des traductions (indexées par numéro de verset)
      final arabicVerses =
          arabicResponse['verses'] as List<dynamic>? ?? [];
      final translationVerses =
          translationResponse['translations'] as List<dynamic>? ?? [];

      final Map<int, String> translations = {};
      for (var i = 0; i < translationVerses.length && i < arabicVerses.length; i++) {
        final verse = arabicVerses[i] as Map<String, dynamic>;
        final verseKey = verse['verse_key'] as String?;
        if (verseKey != null && verseKey.contains(':')) {
          final verseNumber = int.tryParse(verseKey.split(':').last) ?? 0;
          if (verseNumber > 0) {
            final rawText = translationVerses[i]['text'] as String? ?? '';
            translations[verseNumber] = _cleanTranslationText(rawText);
          }
        }
      }

      // 5. Construire la liste des versets
      final ayahs = <Ayah>[];
      for (var verse in arabicVerses) {
        final v = verse as Map<String, dynamic>;
        final verseKey = v['verse_key'] as String?;
        if (verseKey == null || !verseKey.contains(':')) continue;
        final verseNumber = int.tryParse(verseKey.split(':').last) ?? 0;
        if (verseNumber > 0) {
          ayahs.add(Ayah(
            id: v['id'] as int? ?? 0,
            number: verseNumber,
            numberInSurah: verseNumber,
            text: v['text_uthmani'] as String? ?? '',
            translation: translations[verseNumber],
          ));
        }
      }

      // 6. Gérer le Bismillah
      String? bismillah;
      if (number != 9 && ayahs.isNotEmpty) {
        final firstAyah = ayahs.first.text;
        if (firstAyah.startsWith('بِسْمِ')) {
          bismillah = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
        }
      }

      return SurahDetail(
        surah: surah,
        ayahs: ayahs,
        bismillah: bismillah,
      );
    } catch (e) {
      throw Exception('Erreur lors du chargement de la sourate $number: $e');
    }
  }

  /// Nettoie le texte de traduction (retire les balises <sup>...</sup>).
  String _cleanTranslationText(String text) {
    return text
        .replaceAll(RegExp(r'<sup[^>]*>.*?</sup>'), '')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }

  Future<void> saveLastRead(int surahNumber, int ayahNumber) async {
    await StorageService.setInt(AppConstants.keyLastSurah, surahNumber);
    await StorageService.setInt(AppConstants.keyLastAyah, ayahNumber);
  }

  ({int surah, int ayah}) getLastRead() {
    final surah = StorageService.getInt(AppConstants.keyLastSurah) ?? 0;
    final ayah = StorageService.getInt(AppConstants.keyLastAyah) ?? 0;
    return (surah: surah, ayah: ayah);
  }
}
