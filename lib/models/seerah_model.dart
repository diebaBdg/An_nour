class SeerahEvent {
  const SeerahEvent({
    required this.id,
    required this.year,
    required this.era,
    required this.title,
    required this.arabic,
    required this.summary,
    required this.description,
    required this.location,
    required this.icon,
  });

  final String id;
  final int year;
  final String era;
  final String title;
  final String arabic;
  final String summary;
  final String description;
  final String location;
  final String icon;

  factory SeerahEvent.fromJson(Map<String, dynamic> json) {
    return SeerahEvent(
      id: json['id'] as String,
      year: json['year'] as int,
      era: json['era'] as String,
      title: json['title'] as String,
      arabic: json['arabic'] as String,
      summary: json['summary'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      icon: json['icon'] as String,
    );
  }
}

enum SeerahEra {
  preProphethood('Avant la prophétie', 'pre-prophethood'),
  meccan('Période mecquoise', 'meccan'),
  medinan('Période médinoise', 'medinan');

  const SeerahEra(this.label, this.key);
  final String label;
  final String key;
}
