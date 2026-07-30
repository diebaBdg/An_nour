import 'dart:math';
import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/constants/app_constants.dart';
import '../models/prayer_model.dart';
import '../services/storage_service.dart';

class LocationService {
  Future<({double lat, double lng, String? city})> getLocation() async {
    // 1. Localisation personnalisée en priorité
    final useCustom = StorageService.getBool(
      AppConstants.keyUseCustomLocation,
      defaultValue: false,
    );

    if (useCustom) {
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
      if (kDebugMode) print('📍 Localisation personnalisée: $city');
      return (lat: lat, lng: lng, city: city);
    }

    // 2. Essai GPS avec timeout strict de 5s
    try {
      final permission = await Permission.location.status;
      if (permission.isDenied) {
        await Permission.location.request();
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('GPS désactivé');

      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw Exception('Permission refusée');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );

      final city = _nearestSenegalCity(position.latitude, position.longitude);
      if (kDebugMode) {
        print(
            '📍 GPS: ${position.latitude}, ${position.longitude} -> ${city ?? "hors Sénégal"}');
      }
      return (
        lat: position.latitude,
        lng: position.longitude,
        city: city ?? 'Dakar, Sénégal',
      );
    } catch (e) {
      if (kDebugMode) print('📍 GPS échoué ($e) → Dakar par défaut');
    }

    // 3. Fallback : Dakar
    return (
      lat: AppConstants.defaultLatitude,
      lng: AppConstants.defaultLongitude,
      city: AppConstants.defaultCity,
    );
  }

  /// Retourne la ville sénégalaise la plus proche si < 60 km, sinon null.
  String? _nearestSenegalCity(double lat, double lng) {
    String? closest;
    double minDist = 60.0;

    for (final entry in AppConstants.senegalCities.entries) {
      final d = _haversine(lat, lng, entry.value.lat, entry.value.lng);
      if (d < minDist) {
        minDist = d;
        closest = '${entry.key}, Sénégal';
      }
    }

    // Si dans les limites géo du Sénégal mais aucune ville proche
    if (closest == null &&
        lat >= 12.0 &&
        lat <= 17.0 &&
        lng >= -18.0 &&
        lng <= -11.0) {
      return 'Sénégal';
    }

    return closest;
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}

/// Calcul des horaires de prière via la librairie Adhan.
class PrayerService {
  DailyPrayerTimes calculatePrayerTimes({
    required double latitude,
    required double longitude,
    CalculationMethodType method = CalculationMethodType.muslimWorldLeague,
    DateTime? date,
    String? city,
  }) {
    final coords = Coordinates(latitude, longitude);
    final params = _params(method);
    final now = date ?? DateTime.now();
    final times = PrayerTimes(coords, DateComponents.from(now), params);

    return DailyPrayerTimes(
      fajr: times.fajr.toLocal(),
      sunrise: times.sunrise.toLocal(),
      dhuhr: times.dhuhr.toLocal(),
      asr: times.asr.toLocal(),
      maghrib: times.maghrib.toLocal(),
      isha: times.isha.toLocal(),
      date: now,
      city: city ?? AppConstants.defaultCity,
    );
  }

  CalculationParameters _params(CalculationMethodType method) {
    return switch (method) {
      CalculationMethodType.muslimWorldLeague =>
        CalculationMethod.muslim_world_league.getParameters(),
      CalculationMethodType.egyptian =>
        CalculationMethod.egyptian.getParameters(),
      CalculationMethodType.karachi =>
        CalculationMethod.karachi.getParameters(),
      CalculationMethodType.ummAlQura =>
        CalculationMethod.umm_al_qura.getParameters(),
      CalculationMethodType.dubai => CalculationMethod.dubai.getParameters(),
      CalculationMethodType.moonsightingCommittee =>
        CalculationMethod.moon_sighting_committee.getParameters(),
      CalculationMethodType.northAmerica =>
        CalculationMethod.north_america.getParameters(),
      CalculationMethodType.kuwait =>
        CalculationMethod.kuwait.getParameters(),
      CalculationMethodType.qatar => CalculationMethod.qatar.getParameters(),
      CalculationMethodType.singapore =>
        CalculationMethod.singapore.getParameters(),
      CalculationMethodType.tehran =>
        CalculationMethod.tehran.getParameters(),
      CalculationMethodType.turkey => CalculationMethod.turkey.getParameters(),
    };
  }
}
