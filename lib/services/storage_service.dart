import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

class StorageService {
  StorageService._();

  static late SharedPreferences _prefs;
  static late Box<dynamic> _settingsBox;
  static late Box<dynamic> _favoritesBox;
  static late Box<dynamic> _tasbihBox;
  static late Box<dynamic> _cacheBox;

  static SharedPreferences get prefs => _prefs;
  static Box<dynamic> get settingsBox => _settingsBox;
  static Box<dynamic> get favoritesBox => _favoritesBox;
  static Box<dynamic> get tasbihBox => _tasbihBox;
  static Box<dynamic> get cacheBox => _cacheBox;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _favoritesBox = await Hive.openBox(AppConstants.favoritesBox);
    _tasbihBox = await Hive.openBox(AppConstants.tasbihBox);
    _cacheBox = await Hive.openBox(AppConstants.cacheBox);
  }

  static Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  static String? getString(String key) => _prefs.getString(key);

  static Future<void> setBool(String key, bool value) =>
      _prefs.setBool(key, value);

  static bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  static Future<void> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  static double getDouble(String key, {double defaultValue = 1.0}) =>
      _prefs.getDouble(key) ?? defaultValue;

  static Future<void> setInt(String key, int value) =>
      _prefs.setInt(key, value);

  static int? getInt(String key) => _prefs.getInt(key);

}
