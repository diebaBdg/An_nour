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

  int get number => id;
  int get numberOfAyahs => numberOfVerses;

  factory Surah.fromQuranApiJson(Map<String, dynamic> json) {
    String translatedName = '';
    if (json['translated_name'] != null) {
      translatedName = json['translated_name']['name'] as String? ?? '';
    }

    String englishName = translatedName;
    if (englishName.isEmpty) {
      englishName = json['name_simple'] as String? ?? json['name'] as String? ?? '';
    }

    return Surah(
      id: json['id'] as int? ?? 0,
      name: json['name_simple'] as String? ?? json['name'] as String? ?? '',
      nameArabic: json['name_arabic'] as String? ?? '',
      englishName: englishName,
      englishNameTranslation: translatedName,
      numberOfVerses: json['verses_count'] as int? ?? 0,
      revelationType: json['revelation_place'] as String? ?? '',
      revelationOrder: json['revelation_order'] as int? ?? 0,
    );
  }

  factory Surah.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('translated_name') ||
        json.containsKey('name_arabic') ||
        json.containsKey('name_simple')) {
      return Surah.fromQuranApiJson(json);
    }

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

class Ayah {
  final int id;
  final int number;
  final int numberInSurah;
  final String text;
  final String? translation;
  final String? audioUrl;
  final int surahNumber;

  Ayah({
    required this.id,
    required this.number,
    required this.numberInSurah,
    required this.text,
    this.translation,
    this.audioUrl,
    this.surahNumber = 0,
  });

  /// URL audio par verset (récitateur Alafasy) construite à la demande.
  String get computedAudioUrl {
    if (audioUrl != null && audioUrl!.isNotEmpty) return audioUrl!;
    final s = surahNumber.toString().padLeft(3, '0');
    final a = numberInSurah.toString().padLeft(3, '0');
    return 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$s$a.mp3';
  }

  factory Ayah.fromJson(Map<String, dynamic> json, {String? translation}) {
    final verseKey = json['verse_key'] as String?;
    int verseNumber = 0;
    int surahNum = 0;
    if (verseKey != null && verseKey.contains(':')) {
      final parts = verseKey.split(':');
      surahNum = int.tryParse(parts.first) ?? 0;
      verseNumber = int.tryParse(parts.last) ?? 0;
    } else {
      verseNumber = json['verse_number'] as int? ??
          json['numberInSurah'] as int? ??
          json['number'] as int? ??
          0;
    }

    final text = json['text_uthmani'] as String? ??
        json['text'] as String? ??
        '';

    return Ayah(
      id: json['id'] as int? ?? 0,
      number: verseNumber,
      numberInSurah: verseNumber,
      text: text,
      translation: translation,
      audioUrl: json['audio']?['url'] as String? ?? json['audio'] as String?,
      surahNumber: surahNum,
    );
  }
}

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

  /// URL du flux audio continu de la sourate entière (récitateur Alafasy).
  String get fullSurahAudioUrl {
    final s = surah.number.toString().padLeft(3, '0');
    return 'https://download.quranicaudio.com/quran/alafasy/complete-surahs/$s.mp3';
  }
}
