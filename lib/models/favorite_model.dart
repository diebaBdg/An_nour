class FavoriteItem {
  const FavoriteItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.data,
  });

  final String id;
  final FavoriteType type;
  final String title;
  final String subtitle;
  final Map<String, dynamic>? data;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'subtitle': subtitle,
    'data': data,
  };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] as String,
      type: FavoriteType.values.byName(json['type'] as String),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  static FavoriteItem fromJsonSafe(dynamic json) {
    if (json is Map<String, dynamic>) {
      return FavoriteItem.fromJson(json);
    } else if (json is Map<dynamic, dynamic>) {
      return FavoriteItem.fromJson(
        Map<String, dynamic>.from(json),
      );
    } else {
      throw FormatException('Invalid JSON format for FavoriteItem: $json');
    }
  }
}

enum FavoriteType { surah, dua, hadith }

enum Reciter {
  alafasy('Mishary Rashid Alafasy', 'ar.alafasy'),
  husary('Mahmoud Khalil Al-Husary', 'ar.husary'),
  minshawi('Mohamed Siddiq Al-Minshawi', 'ar.minshawi'),
  sudais('Abdur-Rahman As-Sudais', 'ar.abdurrahmaansudais');

  const Reciter(this.label, this.edition);
  final String label;
  final String edition;
}