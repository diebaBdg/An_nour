import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/prayer_model.dart';
import '../services/storage_service.dart';

/// Service de géolocalisation et calcul des horaires de prière
class LocationService {
  /// Demande la permission et retourne la position actuelle
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

  /// Récupère la localisation (personnalisée, GPS ou défaut)
  Future<({double lat, double lng, String? city})> getLocation() async {
    // 1. Vérifier si une localisation personnalisée est utilisée
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

      if (kDebugMode) {
        print('📍 Utilisation de la localisation personnalisée: $city ($lat, $lng)');
      }
      return (lat: lat, lng: lng, city: city);
    }

    // 2. Essayer d'obtenir la position GPS
    try {
      final position = await getCurrentPosition();
      if (kDebugMode) {
        print('📍 Position GPS: ${position.latitude}, ${position.longitude}');
      }

      final city = await _getCityName(position.latitude, position.longitude);
      return (
      lat: position.latitude,
      lng: position.longitude,
      city: city ?? 'Sénégal'
      );
    } catch (e) {
      if (kDebugMode) {
        print('📍 Erreur GPS, utilisation de Dakar par défaut: $e');
      }
      // 3. Fallback sur Dakar (Sénégal)
      return (
      lat: AppConstants.defaultLatitude,
      lng: AppConstants.defaultLongitude,
      city: AppConstants.defaultCity,
      );
    }
  }

  /// Récupère le nom de la ville à partir des coordonnées
  Future<String?> _getCityName(double lat, double lng) async {
    try {
      // Vérifier si les coordonnées correspondent à une ville du Sénégal
      for (final entry in AppConstants.senegalCities.entries) {
        final cityLat = entry.value.lat;
        final cityLng = entry.value.lng;
        final distance = _calculateDistance(lat, lng, cityLat, cityLng);
        if (distance < 50) { // Moins de 50 km
          return entry.key;
        }
      }

      // Si on est au Sénégal, retourner "Sénégal"
      if (lat >= 12.0 && lat <= 17.0 && lng >= -18.0 && lng <= -11.0) {
        return 'Sénégal';
      }

      // Si on est en Afrique de l'Ouest
      if (lat >= 4.0 && lat <= 25.0 && lng >= -20.0 && lng <= 15.0) {
        return 'Afrique de l\'Ouest';
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Calcule la distance en kilomètres entre deux points (formule de Haversine)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Rayon de la Terre en km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * pi / 180;
}

/// Service de calcul des horaires de prière via la librairie Adhan
class PrayerService {
  DailyPrayerTimes calculatePrayerTimes({
    required double latitude,
    required double longitude,
    CalculationMethodType method = CalculationMethodType.muslimWorldLeague,
    DateTime? date,
    String? city,
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
      city: city ?? AppConstants.defaultCity,
    );
  }

  CalculationParameters _getCalculationParameters(CalculationMethodType method) {
    return switch (method) {
      CalculationMethodType.muslimWorldLeague =>
          CalculationMethod.muslim_world_league.getParameters(),
      CalculationMethodType.egyptian =>
          CalculationMethod.egyptian.getParameters(),
      CalculationMethodType.karachi =>
          CalculationMethod.karachi.getParameters(),
      CalculationMethodType.ummAlQura =>
          CalculationMethod.umm_al_qura.getParameters(),
      CalculationMethodType.dubai =>
          CalculationMethod.dubai.getParameters(),
      CalculationMethodType.moonsightingCommittee =>
          CalculationMethod.moon_sighting_committee.getParameters(),
      CalculationMethodType.northAmerica =>
          CalculationMethod.north_america.getParameters(),
      CalculationMethodType.kuwait =>
          CalculationMethod.kuwait.getParameters(),
      CalculationMethodType.qatar =>
          CalculationMethod.qatar.getParameters(),
      CalculationMethodType.singapore =>
          CalculationMethod.singapore.getParameters(),
      CalculationMethodType.tehran =>
          CalculationMethod.tehran.getParameters(),
      CalculationMethodType.turkey =>
          CalculationMethod.turkey.getParameters(),
    };
  }
}