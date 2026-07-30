class Hadith {
  const Hadith({
    required this.id,
    required this.collection,
    required this.bookNumber,
    required this.hadithNumber,
    required this.arabic,
    required this.english,
    required this.narrator,
    required this.theme,
  });

  final String id;
  final String collection;
  final int bookNumber;
  final int hadithNumber;
  final String arabic;
  final String english;
  final String narrator;
  final String theme;

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'] as String,
      collection: json['collection'] as String? ?? '',
      bookNumber: json['bookNumber'] as int? ?? 0,
      hadithNumber: json['hadithNumber'] as int? ?? 0,
      arabic: json['arabic'] as String? ?? '',
      english: json['english'] as String? ?? json['text'] as String? ?? '',
      narrator: json['narrator'] as String? ?? '',
      theme: json['theme'] as String? ?? 'Général',
    );
  }

  String get reference => '$collection $bookNumber:$hadithNumber';
}

class DailyQuote {
  const DailyQuote({
    required this.text,
    required this.reference,
    required this.type,
    this.arabic,
  });

  final String text;
  final String reference;
  final QuoteType type;
  final String? arabic;
}

enum QuoteType { quran, hadith }
