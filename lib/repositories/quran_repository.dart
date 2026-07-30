import '../models/quran_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../core/constants/app_constants.dart';

class QuranRepository {
  QuranRepository({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  static const Map<String, int> _translationIds = {
    'fr': 31, // Muhammad Hamidullah
    'en': 20, // Saheeh International
    'ar': 136, // Montada Islamic Foundation
  };

  int _translationIdFor(String language) =>
      _translationIds[language] ?? _translationIds['en']!;

  Future<List<Surah>> getAllSurahs({String language = 'fr'}) async {
    try {
      print('📱 Récupération des sourates...');
      final response = await _api.get('/chapters');
      print('📱 Réponse reçue avec clés: ${response.keys}');

      if (response.containsKey('chapters')) {
        final chapters = response['chapters'] as List<dynamic>;
        print('📱 Nombre de chapitres: ${chapters.length}');

        final surahs = chapters
            .map((e) {
          final json = e as Map<String, dynamic>;
          print('📱 Parsing: ${json['id']} - ${json['name_simple'] ?? json['name']}');
          return Surah.fromQuranApiJson(json);
        })
            .toList();

        surahs.sort((a, b) => a.id.compareTo(b.id));
        print('📱 ${surahs.length} sourates parsées avec succès');
        return surahs;
      }

      throw Exception('Format de réponse inattendu');
    } catch (e) {
      print('❌ Erreur dans getAllSurahs: $e');
      throw Exception('Erreur lors du chargement des sourates: $e');
    }
  }

  Future<SurahDetail> getSurahDetail(int number, {String language = 'fr'}) async {
    try {
      print('📱 Récupération de la sourate $number...');

      final arabicResponse = await _api.get('/quran/verses/uthmani?chapter_number=$number');
      print('📱 Versets arabes reçus');

      final chapterResponse = await _api.get('/chapters/$number');
      final surahJson = chapterResponse['chapter'] as Map<String, dynamic>? ?? {};
      final surah = Surah.fromQuranApiJson(surahJson);
      print('📱 Sourate: ${surah.id} - ${surah.englishName}');

      final arabicVerses = arabicResponse['verses'] as List<dynamic>? ?? [];
      print('📱 Versets arabes: ${arabicVerses.length}');

      Map<int, String> translations = {};
      try {
        final translationId = _translationIdFor(language);
        final translationResponse = await _api.get('/quran/translations/$translationId?chapter_number=$number');

        final translationVerses = translationResponse['translations'] as List<dynamic>? ?? [];
        print('📱 Traductions reçues: ${translationVerses.length}');

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
      } catch (e) {
        print('⚠️ Erreur lors de la récupération des traductions: $e');
      }

      final ayahs = <Ayah>[];
      for (var verse in arabicVerses) {
        final v = verse as Map<String, dynamic>;
        final verseKey = v['verse_key'] as String?;
        if (verseKey == null || !verseKey.contains(':')) continue;
        final verseNumber = int.tryParse(verseKey.split(':').last) ?? 0;
        if (verseNumber > 0) {
          String arabicText = v['text_uthmani'] as String? ?? '';
          if (arabicText.isEmpty) {
            arabicText = v['text'] as String? ?? '';
          }
          if (arabicText.isEmpty) {
            arabicText = v['text_indopak'] as String? ?? '';
          }

          ayahs.add(Ayah(
            id: v['id'] as int? ?? 0,
            number: verseNumber,
            numberInSurah: verseNumber,
            text: arabicText,
            translation: translations[verseNumber],
            audioUrl: v['audio']?['url'] as String?,
          ));
        }
      }

      print('📱 ${ayahs.length} versets parsés');

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
      print('❌ Erreur dans getSurahDetail: $e');
      throw Exception('Erreur lors du chargement de la sourate $number: $e');
    }
  }

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