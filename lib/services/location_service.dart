import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/prayer_model.dart';

/// Service de géolocalisation et calcul des horaires de prière.
class LocationService {
  /// Demande la permission et retourne la position actuelle.
  Future<Position> getCurrentPosition() async {
    final permission = await Permission.location.request();
    if (permission.isDenied || permission.isPermanentlyDenied) {
      throw const PermissionException(
        'La localisation est nécessaire pour les horaires de prière',
      );
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('Activez le GPS pour obtenir votre position');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
  }

  /// Dernière position connue ou position par défaut (Paris).
  Future<({double lat, double lng, String? city})> getLocation() async {
    try {
      final position = await getCurrentPosition();
      return (lat: position.latitude, lng: position.longitude, city: null);
    } on AppException {
      return (
        lat: AppConstants.defaultLatitude,
        lng: AppConstants.defaultLongitude,
        city: AppConstants.defaultCity,
      );
    }
  }
}

/// Service de calcul des horaires de prière via la librairie Adhan.
class PrayerService {
  DailyPrayerTimes calculatePrayerTimes({
    required double latitude,
    required double longitude,
    CalculationMethodType method = CalculationMethodType.muslimWorldLeague,
    DateTime? date,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final params = _getCalculationParameters(method);
    final prayerDate = date ?? DateTime.now();
    final dateComponents = DateComponents.from(prayerDate);
    final times = PrayerTimes(coordinates, dateComponents, params);

    return DailyPrayerTimes(
      fajr: times.fajr.toLocal(),
      sunrise: times.sunrise.toLocal(),
      dhuhr: times.dhuhr.toLocal(),
      asr: times.asr.toLocal(),
      maghrib: times.maghrib.toLocal(),
      isha: times.isha.toLocal(),
      date: prayerDate,
    );
  }

  CalculationParameters _getCalculationParameters(CalculationMethodType method) {
    return switch (method) {
      CalculationMethodType.muslimWorldLeague => CalculationMethod.muslim_world_league.getParameters(),
      CalculationMethodType.egyptian => CalculationMethod.egyptian.getParameters(),
      CalculationMethodType.karachi => CalculationMethod.karachi.getParameters(),
      CalculationMethodType.ummAlQura => CalculationMethod.umm_al_qura.getParameters(),
      CalculationMethodType.dubai => CalculationMethod.dubai.getParameters(),
      CalculationMethodType.moonsightingCommittee => CalculationMethod.moon_sighting_committee.getParameters(),
      CalculationMethodType.northAmerica => CalculationMethod.north_america.getParameters(),
      CalculationMethodType.kuwait => CalculationMethod.kuwait.getParameters(),
      CalculationMethodType.qatar => CalculationMethod.qatar.getParameters(),
      CalculationMethodType.singapore => CalculationMethod.singapore.getParameters(),
      CalculationMethodType.tehran => CalculationMethod.tehran.getParameters(),
      CalculationMethodType.turkey => CalculationMethod.turkey.getParameters(),
    };
  }
}
