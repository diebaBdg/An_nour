import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../models/prayer_model.dart';
import '../repositories/prayer_repository.dart';
import '../providers/settings_provider.dart';

final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return PrayerRepository();
});

final prayerTimesProvider = FutureProvider<DailyPrayerTimes>((ref) async {
  final repo = ref.watch(prayerRepositoryProvider);
  final settings = ref.watch(settingsProvider);
  final result = await repo.getTodayPrayerTimes(
    method: settings.prayerMethod,
    scheduleNotifications: settings.notificationsEnabled,
  );
  return result.times;
});

final prayerCountdownProvider = FutureProvider<Duration?>((ref) async {
  final times = await ref.watch(prayerTimesProvider.future);
  return times.timeUntilNextPrayer;
});

final prayerCountdownTimerProvider = StreamProvider<Duration>((ref) {
  final controller = StreamController<Duration>();

  Timer? timer;

  void updateCountdown() {
    ref.read(prayerTimesProvider.future).then((times) {
      final duration = times.timeUntilNextPrayer ?? Duration.zero;
      if (!controller.isClosed) {
        controller.add(duration);
      }
    }).catchError((error) {
      if (!controller.isClosed) {
        controller.add(Duration.zero);
      }
    });
  }

  // Mise à jour initiale
  updateCountdown();

  // Mise à jour toutes les secondes
  timer = Timer.periodic(const Duration(seconds: 1), (_) {
    updateCountdown();
  });

  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });



  return controller.stream;
});