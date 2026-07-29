import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../models/favorite_model.dart';
import '../models/prayer_model.dart';
import '../services/storage_service.dart';

/// Modèle des paramètres utilisateur persistés.
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('fr'),
    this.textScale = 1.0,
    this.prayerMethod = CalculationMethodType.muslimWorldLeague,
    this.reciter = Reciter.alafasy,
    this.notificationsEnabled = true,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final double textScale;
  final CalculationMethodType prayerMethod;
  final Reciter reciter;
  final bool notificationsEnabled;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    double? textScale,
    CalculationMethodType? prayerMethod,
    Reciter? reciter,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      textScale: textScale ?? this.textScale,
      prayerMethod: prayerMethod ?? this.prayerMethod,
      reciter: reciter ?? this.reciter,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

/// Notifier Riverpod pour les paramètres de l'application.
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  void _load() {
    final themeIndex = StorageService.getInt(AppConstants.keyThemeMode) ?? 0;
    final localeCode = StorageService.getString(AppConstants.keyLocale) ?? 'fr';
    final textScale = StorageService.getDouble(AppConstants.keyTextScale);
    final methodIndex = StorageService.getInt(AppConstants.keyPrayerMethod) ?? 0;
    final reciterIndex = StorageService.getInt(AppConstants.keyReciter) ?? 0;
    final notifications =
        StorageService.getBool(AppConstants.keyNotifications, defaultValue: true);

    state = AppSettings(
      themeMode: ThemeMode.values[themeIndex.clamp(0, 2)],
      locale: Locale(localeCode),
      textScale: textScale,
      prayerMethod: CalculationMethodType.values[methodIndex.clamp(0, CalculationMethodType.values.length - 1)],
      reciter: Reciter.values[reciterIndex.clamp(0, Reciter.values.length - 1)],
      notificationsEnabled: notifications,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await StorageService.setInt(AppConstants.keyThemeMode, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setLocale(Locale locale) async {
    await StorageService.setString(AppConstants.keyLocale, locale.languageCode);
    state = state.copyWith(locale: locale);
  }

  Future<void> setTextScale(double scale) async {
    await StorageService.setDouble(AppConstants.keyTextScale, scale);
    state = state.copyWith(textScale: scale);
  }

  Future<void> setPrayerMethod(CalculationMethodType method) async {
    await StorageService.setInt(AppConstants.keyPrayerMethod, method.index);
    state = state.copyWith(prayerMethod: method);
  }

  Future<void> setReciter(Reciter reciter) async {
    await StorageService.setInt(AppConstants.keyReciter, reciter.index);
    state = state.copyWith(reciter: reciter);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await StorageService.setBool(AppConstants.keyNotifications, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
