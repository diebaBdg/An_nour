class TasbihSession {
  const TasbihSession({
    required this.dhikr,
    required this.count,
    required this.target,
    required this.timestamp,
  });

  final String dhikr;
  final int count;
  final int target;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
    'dhikr': dhikr,
    'count': count,
    'target': target,
    'timestamp': timestamp.toIso8601String(),
  };

  factory TasbihSession.fromJson(Map<String, dynamic> json) {
    return TasbihSession(
      dhikr: json['dhikr'] as String,
      count: json['count'] as int,
      target: json['target'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static TasbihSession fromJsonSafe(dynamic json) {
    if (json is Map<String, dynamic>) {
      return TasbihSession.fromJson(json);
    } else if (json is Map<dynamic, dynamic>) {
      return TasbihSession.fromJson(
        Map<String, dynamic>.from(json),
      );
    } else {
      throw FormatException('Invalid JSON format for TasbihSession: $json');
    }
  }
}

enum DhikrType {
  subhanAllah('SubhanAllah', 'سُبْحَانَ اللَّهِ', 33),
  alhamdulillah('Alhamdulillah', 'الْحَمْدُ لِلَّهِ', 33),
  allahuAkbar('Allahu Akbar', 'اللَّهُ أَكْبَرُ', 34),
  laIlahaIllallah('La ilaha illallah', 'لَا إِلَٰهَ إِلَّا اللَّهُ', 100),
  astaghfirullah('Astaghfirullah', 'أَسْتَغْفِرُ اللَّه', 100);

  const DhikrType(this.label, this.arabic, this.defaultTarget);
  final String label;
  final String arabic;
  final int defaultTarget;
}