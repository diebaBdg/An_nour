class IslamicEvent {
  const IslamicEvent({
    required this.name,
    required this.hijriMonth,
    required this.hijriDay,
    required this.description,
  });

  final String name;
  final int hijriMonth;
  final int hijriDay;
  final String description;
}

/// Représentation d'une date hijri.
class HijriDateInfo {
  const HijriDateInfo({
    required this.day,
    required this.month,
    required this.monthName,
    required this.year,
    required this.formatted,
  });

  final int day;
  final int month;
  final String monthName;
  final int year;
  final String formatted;
}
