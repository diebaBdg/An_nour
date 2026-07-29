/// Modèle d'une sourate du Coran.
class Surah {
  const Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      englishNameTranslation: json['englishNameTranslation'] as String? ?? '',
      numberOfAyahs: json['numberOfAyahs'] as int,
      revelationType: json['revelationType'] as String? ?? '',
    );
  }
}

/// Modèle d'un verset (ayah).
class Ayah {
  const Ayah({
    required this.number,
    required this.numberInSurah,
    required this.text,
    this.translation,
    this.audioUrl,
  });

  final int number;
  final int numberInSurah;
  final String text;
  final String? translation;
  final String? audioUrl;

  factory Ayah.fromJson(Map<String, dynamic> json, {String? translation}) {
    return Ayah(
      number: json['number'] as int,
      numberInSurah: json['numberInSurah'] as int,
      text: json['text'] as String,
      translation: translation,
      audioUrl: json['audio'] as String?,
    );
  }
}

/// Détail complet d'une sourate avec versets.
class SurahDetail {
  const SurahDetail({
    required this.surah,
    required this.ayahs,
  });

  final Surah surah;
  final List<Ayah> ayahs;
}
