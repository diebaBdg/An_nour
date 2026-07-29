import '../models/prayer_model.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

/// Repository pour les horaires de prière et la localisation.
class PrayerRepository {
  PrayerRepository({
    LocationService? locationService,
    PrayerService? prayerService,
  })  : _locationService = locationService ?? LocationService(),
        _prayerService = prayerService ?? PrayerService();

  final LocationService _locationService;
  final PrayerService _prayerService;

  Future<({DailyPrayerTimes times, String? city})> getTodayPrayerTimes({
    CalculationMethodType method = CalculationMethodType.muslimWorldLeague,
    bool scheduleNotifications = false,
  }) async {
    final location = await _locationService.getLocation();
    final times = _prayerService.calculatePrayerTimes(
      latitude: location.lat,
      longitude: location.lng,
      method: method,
    );

    final result = (
      times: DailyPrayerTimes(
        fajr: times.fajr,
        sunrise: times.sunrise,
        dhuhr: times.dhuhr,
        asr: times.asr,
        maghrib: times.maghrib,
        isha: times.isha,
        date: times.date,
        city: location.city,
      ),
      city: location.city,
    );

    if (scheduleNotifications) {
      await NotificationService.schedulePrayerNotifications(result.times);
    }

    return result;
  }
}
