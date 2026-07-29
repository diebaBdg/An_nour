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
      category: json['category'] as String,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      translation: json['translation'] as String,
      reference: json['reference'] as String,
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

enum DuaCategory {
  morning('Matin', 'morning'),
  evening('Soir', 'evening'),
  travel('Voyage', 'travel'),
  illness('Maladie', 'illness'),
  food('Nourriture', 'food'),
  sleep('Sommeil', 'sleep'),
  mosque('Mosquée', 'mosque'),
  protection('Protection', 'protection'),
  forgiveness('Pardon', 'forgiveness'),
  misc('Divers', 'misc');

  const DuaCategory(this.label, this.key);
  final String label;
  final String key;
}
