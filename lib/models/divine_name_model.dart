class DivineName {
  const DivineName({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.meaning,
  });

  final int number;
  final String arabic;
  final String transliteration;
  final String translation;
  final String meaning;

  factory DivineName.fromJson(Map<String, dynamic> json) {
    return DivineName(
      number: json['number'] as int,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      translation: json['translation'] as String,
      meaning: json['meaning'] as String,
    );
  }
}
