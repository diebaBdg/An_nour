abstract final class AppConstants {
  static const String appName = 'An-Nour';
  static const String appTagline = 'La lumière sur votre chemin';

  // Hive boxes
  static const String quranBox = 'quran';

  // SharedPreferences keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';
  static const String keyTextScale = 'text_scale';
  static const String keyPrayerMethod = 'prayer_method';
  static const String keyReciter = 'reciter';
  static const String keyNotifications = 'notifications_enabled';

  // API
  static const String quranApiBase = 'https://api.alquran.cloud/v1';
  static const String hadithApiBase = 'https://hadithapi.com/api';

  static const double defaultLatitude = 14.7167;
  static const double defaultLongitude = -17.4677;
  static const String defaultCity = 'Dakar, Sénégal';

  // Coordonnées des principales villes du Sénégal
  static const Map<String, ({double lat, double lng})> senegalCities = {
    'Dakar': (lat: 14.7167, lng: -17.4677),
    'Saint-Louis': (lat: 16.0197, lng: -16.4960),
    'Thiès': (lat: 14.7900, lng: -16.9250),
    'Kaolack': (lat: 14.1462, lng: -16.0740),
    'Ziguinchor': (lat: 12.5820, lng: -16.2700),
    'Touba': (lat: 14.8500, lng: -15.8833),
    'Mbour': (lat: 14.4167, lng: -16.9667),
    'Louga': (lat: 15.6147, lng: -16.2240),
    'Tambacounda': (lat: 13.7708, lng: -13.6673),
    'Kolda': (lat: 12.8833, lng: -14.9500),
    'Diourbel': (lat: 14.6500, lng: -16.2333),
    'Sédhiou': (lat: 12.7076, lng: -15.5569),
    'Kédougou': (lat: 12.5556, lng: -12.1808),
    'Fatick': (lat: 14.3333, lng: -16.4000),
    'Matam': (lat: 15.6605, lng: -13.2570),
  };

  // Clés SharedPreferences
  static const String keyLastSurah = 'last_read_surah';
  static const String keyLastAyah = 'last_read_ayah';
  static const String keyUseCustomLocation = 'use_custom_location';
  static const String keyCustomLatitude = 'custom_latitude';
  static const String keyCustomLongitude = 'custom_longitude';
  static const String keyCustomCity = 'custom_city';

  // Boxes Hive
  static const String settingsBox = 'settings_box';
  static const String favoritesBox = 'favorites_box';
  static const String tasbihBox = 'tasbih_box';
  static const String cacheBox = 'cache_box';
}
