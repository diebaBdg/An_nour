abstract final class AppConstants {
  static const String appName = 'An-Nour';
  static const String appTagline = 'La lumière sur votre chemin';

  // Hive boxes
  static const String settingsBox = 'settings';
  static const String favoritesBox = 'favorites';
  static const String tasbihBox = 'tasbih';
  static const String quranBox = 'quran';
  static const String cacheBox = 'cache';

  // SharedPreferences keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';
  static const String keyTextScale = 'text_scale';
  static const String keyPrayerMethod = 'prayer_method';
  static const String keyReciter = 'reciter';
  static const String keyNotifications = 'notifications_enabled';
  static const String keyLastSurah = 'last_surah';
  static const String keyLastAyah = 'last_ayah';

  // API
  static const String quranApiBase = 'https://api.alquran.cloud/v1';
  static const String hadithApiBase = 'https://hadithapi.com/api';

  // Defaults
  static const double defaultLatitude = 48.8566;
  static const double defaultLongitude = 2.3522;
  static const String defaultCity = 'Paris';
}
