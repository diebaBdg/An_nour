import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/prayer_model.dart';

/// Service de notifications locales pour les rappels de prière.
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted == true;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Planifie une notification pour chaque prière obligatoire.
  static Future<void> schedulePrayerNotifications(DailyPrayerTimes times) async {
    await cancelAll();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_channel',
        'Horaires de prière',
        channelDescription: 'Notifications pour les heures de prière',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    var id = 0;
    for (final prayer in times.obligatory) {
      if (prayer.time.isAfter(DateTime.now())) {
        await _plugin.zonedSchedule(
          id++,
          'Heure de ${prayer.name}',
          'Il est temps pour la prière ${prayer.arabicName}',
          tz.TZDateTime.from(prayer.time, tz.local),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
