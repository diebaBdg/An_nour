import '../models/quran_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../core/constants/app_constants.dart';

class QuranRepository {
  QuranRepository({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<List<Surah>> getAllSurahs() async {
    try {
      print('📱 Récupération des sourates...');
      final response = await _api.get('/chapters');
      print('📱 Réponse reçue: ${response.keys}');

      if (response.containsKey('chapters')) {
        final chapters = response['chapters'] as List<dynamic>;
        print('📱 Nombre de chapitres: ${chapters.length}');

        final surahs = chapters
            .map((e) {
          final json = e as Map<String, dynamic>;
          print('📱 Parsing: ${json['id']} - ${json['name']}');
          return Surah.fromJson(json);
        })
            .toList();

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

      // Récupérer les versets en arabe (Uthmani)
      final arabicResponse = await _api.get('/quran/verses/uthmani?chapter_number=$number');

      // Récupérer la traduction
      final translationResponse = await _api.get('/quran/verses/indopak?chapter_number=$number&language=$language');

      // Extraire les versets
      final arabicVerses = arabicResponse['verses'] as List<dynamic>? ?? [];
      final translationVerses = translationResponse['verses'] as List<dynamic>? ?? [];

      print('📱 Versets arabes: ${arabicVerses.length}, Traductions: ${translationVerses.length}');

      // Récupérer les informations de la sourate
      final surahInfo = arabicResponse['meta']?['chapter'] as Map<String, dynamic>? ?? {};
      final surah = Surah.fromJson(surahInfo);
      print('📱 Sourate: ${surah.id} - ${surah.englishName}');

      // Créer une map des traductions par numéro de verset
      final Map<int, String> translations = {};
      for (var verse in translationVerses) {
        final verseNumber = verse['verse_number'] as int? ?? 0;
        final text = verse['text'] as String? ?? '';
        if (verseNumber > 0) {
          translations[verseNumber] = text;
        }
      }

      // Construire la liste des versets
      final ayahs = <Ayah>[];
      for (var verse in arabicVerses) {
        final verseNumber = verse['verse_number'] as int? ?? 0;
        if (verseNumber > 0) {
          ayahs.add(Ayah(
            id: verse['id'] as int? ?? 0,
            number: verseNumber,
            numberInSurah: verseNumber,
            text: verse['text'] as String? ?? '',
            translation: translations[verseNumber],
            audioUrl: verse['audio']?['url'] as String?,
          ));
        }
      }

      print('📱 ${ayahs.length} versets parsés');

      // Gérer le Bismillah
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

  Future<void> saveLastRead(int surahNumber, int ayahNumber) async {
    try {
      await StorageService.setInt(AppConstants.keyLastSurah, surahNumber);
      await StorageService.setInt(AppConstants.keyLastAyah, ayahNumber);
      print('📱 Dernière lecture sauvegardée: Sourate $surahNumber, Verset $ayahNumber');
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde: $e');
    }
  }

  ({int surah, int ayah}) getLastRead() {
    try {
      final surah = StorageService.getInt(AppConstants.keyLastSurah) ?? 0;
      final ayah = StorageService.getInt(AppConstants.keyLastAyah) ?? 0;
      return (surah: surah, ayah: ayah);
    } catch (e) {
      print('❌ Erreur lors de la récupération de la dernière lecture: $e');
      return (surah: 0, ayah: 0);
    }
  }
}