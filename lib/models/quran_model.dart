/// Modèle d'une sourate du Coran.
class Surah {
  final int id;
  final String name;
  final String nameArabic;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfVerses;
  final String revelationType;
  final int revelationOrder;

  Surah({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfVerses,
    required this.revelationType,
    required this.revelationOrder,
  });

  // Getters pour la compatibilité avec l'ancien code
  int get number => id;
  int get numberOfAyahs => numberOfVerses;

  /// Factory pour l'API Quran.com
  factory Surah.fromQuranApiJson(Map<String, dynamic> json) {
    // Gérer le nom traduit
    String translatedName = '';
    if (json['translated_name'] != null) {
      translatedName = json['translated_name']['name'] as String? ?? '';
    }

    // Gérer le nom en anglais
    String englishName = '';
    if (json['translated_name'] != null) {
      englishName = json['translated_name']['name'] as String? ?? '';
    }
    if (englishName.isEmpty) {
      englishName = json['name'] as String? ?? '';
    }

    return Surah(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      nameArabic: json['name_arabic'] as String? ?? json['name'] as String? ?? '',
      englishName: englishName,
      englishNameTranslation: translatedName,
      numberOfVerses: json['verses_count'] as int? ?? 0,
      revelationType: json['revelation_place'] as String? ?? '',
      revelationOrder: json['revelation_order'] as int? ?? 0,
    );
  }

  /// Factory générique qui détecte automatiquement le format
  factory Surah.fromJson(Map<String, dynamic> json) {
    // Si le JSON contient les clés de l'API Quran.com
    if (json.containsKey('translated_name') || json.containsKey('name_arabic')) {
      return Surah.fromQuranApiJson(json);
    }

    // Sinon, on essaie le format de l'ancienne API Al-Quran Cloud
    return Surah(
      id: json['number'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      nameArabic: json['name'] as String? ?? '',
      englishName: json['englishName'] as String? ?? '',
      englishNameTranslation: json['englishNameTranslation'] as String? ?? '',
      numberOfVerses: json['numberOfAyahs'] as int? ?? 0,
      revelationType: json['revelationType'] as String? ?? '',
      revelationOrder: 0,
    );
  }
}

/// Modèle d'un verset (ayah).
class Ayah {
  final int id;
  final int number;
  final int numberInSurah;
  final String text;
  final String? translation;
  final String? audioUrl;

  Ayah({
    required this.id,
    required this.number,
    required this.numberInSurah,
    required this.text,
    this.translation,
    this.audioUrl,
  });

  factory Ayah.fromJson(Map<String, dynamic> json, {String? translation}) {
    // Récupérer le numéro du verset
    final int verseNumber = json['verse_number'] as int? ??
        json['numberInSurah'] as int? ??
        json['number'] as int? ?? 0;

    return Ayah(
      id: json['id'] as int? ?? 0,
      number: verseNumber,
      numberInSurah: verseNumber,
      text: json['text'] as String? ?? '',
      translation: translation,
      audioUrl: json['audio']?['url'] as String? ?? json['audio'] as String?,
    );
  }
}

/// Détail complet d'une sourate avec versets.
class SurahDetail {
  final Surah surah;
  final List<Ayah> ayahs;
  final String? bismillah;

  SurahDetail({
    required this.surah,
    required this.ayahs,
    this.bismillah,
  });

  bool get hasBismillah => surah.id != 9 && bismillah != null;
}