/// Modèle représentant une prière quotidienne.
class PrayerTime {
  const PrayerTime({
    required this.name,
    required this.time,
    required this.arabicName,
  });

  final String name;
  final DateTime time;
  final String arabicName;

  bool get isPassed => time.isBefore(DateTime.now());

  String get formattedTime {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Ensemble des horaires de prière du jour.
class DailyPrayerTimes {
  const DailyPrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    this.city,
  });

  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime date;
  final String? city;

  List<PrayerTime> get all => [
        PrayerTime(name: 'Fajr', time: fajr, arabicName: 'الفجر'),
        PrayerTime(name: 'Sunrise', time: sunrise, arabicName: 'الشروق'),
        PrayerTime(name: 'Dhuhr', time: dhuhr, arabicName: 'الظهر'),
        PrayerTime(name: 'Asr', time: asr, arabicName: 'العصر'),
        PrayerTime(name: 'Maghrib', time: maghrib, arabicName: 'المغرب'),
        PrayerTime(name: 'Isha', time: isha, arabicName: 'العشاء'),
      ];

  /// Prières obligatoires (sans le lever du soleil).
  List<PrayerTime> get obligatory => all.where((p) => p.name != 'Sunrise').toList();

  /// Prochaine prière à venir.
  PrayerTime? get nextPrayer {
    final now = DateTime.now();
    for (final prayer in obligatory) {
      if (prayer.time.isAfter(now)) return prayer;
    }
    return obligatory.first;
  }

  Duration? get timeUntilNextPrayer {
    final next = nextPrayer;
    if (next == null) return null;
    return next.time.difference(DateTime.now());
  }
}

/// Méthodes de calcul des horaires de prière.
enum CalculationMethodType {
  muslimWorldLeague('Muslim World League'),
  egyptian('Egyptian General Authority'),
  karachi('University of Islamic Sciences, Karachi'),
  ummAlQura('Umm Al-Qura University, Makkah'),
  dubai('Dubai'),
  moonsightingCommittee('Moonsighting Committee'),
  northAmerica('ISNA (North America)'),
  kuwait('Kuwait'),
  qatar('Qatar'),
  singapore('Singapore'),
  tehran('Institute of Geophysics, Tehran'),
  turkey('Diyanet İşleri Başkanlığı, Turkey');

  const CalculationMethodType(this.label);
  final String label;
}
