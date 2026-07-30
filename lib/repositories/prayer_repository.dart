import '../models/prayer_model.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../core/constants/app_constants.dart';

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

    print('📍 Calcul des horaires pour: ${location.city ?? "Sénégal"}');
    print('📍 Coordonnées: ${location.lat}, ${location.lng}');

    // Calculer les heures de prière
    final times = _prayerService.calculatePrayerTimes(
      latitude: location.lat,
      longitude: location.lng,
      method: method,
      city: location.city ?? 'Sénégal',
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
      city: location.city ?? 'Sénégal',
    ),
    city: location.city ?? 'Sénégal',
    );

    if (scheduleNotifications) {
      await NotificationService.schedulePrayerNotifications(result.times);
    }

    return result;
  }

  Future<void> saveCustomLocation({
    required double latitude,
    required double longitude,
    required String city,
  }) async {
    await StorageService.setBool(AppConstants.keyUseCustomLocation, true);
    await StorageService.setDouble(AppConstants.keyCustomLatitude, latitude);
    await StorageService.setDouble(AppConstants.keyCustomLongitude, longitude);
    await StorageService.setString(AppConstants.keyCustomCity, city);
  }

  Future<void> disableCustomLocation() async {
    await StorageService.setBool(AppConstants.keyUseCustomLocation, false);
  }

  ({double lat, double lng, String city})? getCustomLocation() {
    final useCustom = StorageService.getBool(
      AppConstants.keyUseCustomLocation,
      defaultValue: false,
    );

    if (!useCustom) return null;

    final lat = StorageService.getDouble(
      AppConstants.keyCustomLatitude,
      defaultValue: AppConstants.defaultLatitude,
    );
    final lng = StorageService.getDouble(
      AppConstants.keyCustomLongitude,
      defaultValue: AppConstants.defaultLongitude,
    );
    final city = StorageService.getString(AppConstants.keyCustomCity) ??
        AppConstants.defaultCity;

    return (lat: lat, lng: lng, city: city);
  }

  List<({String name, double lat, double lng})> getSenegalCities() {
    return AppConstants.senegalCities.entries.map((entry) {
      return (
      name: entry.key,
      lat: entry.value.lat,
      lng: entry.value.lng,
      );
    }).toList();
  }
}