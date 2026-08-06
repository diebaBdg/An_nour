class Dua {
  const Dua({
    required this.id,
    required this.category,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.reference,
  });

  final String id;
  final String category;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'] as String,
      category: json['category'] as String? ?? 'Divers',
      arabic: json['arabic'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'arabic': arabic,
        'transliteration': transliteration,
        'translation': translation,
        'reference': reference,
      };
}

/// Catégorie d'invocations (Hisn al-Muslim).
class DuaCategory {
  const DuaCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  final int id;
  final String name;
  final String icon;

  factory DuaCategory.fromJson(Map<String, dynamic> json) {
    return DuaCategory(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
    );
  }
}
