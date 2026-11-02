import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/alarm_model.dart';
import 'alarm_storage.dart';

/// Top-level callback — must be a top-level or static function.
/// Called by AndroidAlarmManager when an alarm fires.
@pragma('vm:entry-point')
Future<void> alarmCallback(int id) async {
  // Re-init Hive in the background isolate
  await Hive.initFlutter();
  Hive.registerAdapter(AlarmModelAdapter());
  final box = await Hive.openBox<AlarmModel>('alarms');

  // Find the alarm by its int id (we store alarm int id separately)
  final alarms = box.values.toList();
  AlarmModel? alarm;
  for (final a in alarms) {
    if (a.id.hashCode.abs() % 100000 == id) {
      alarm = a;
      break;
    }
  }

  if (alarm == null || !alarm.isEnabled) return;

  final now = DateTime.now();
  if (!alarm.shouldRingOn(now)) {
    // Not a ring day — schedule next occurrence silently
    await AlarmScheduler.scheduleNext(alarm);
    return;
  }

  // Fire the notification
  final fln = FlutterLocalNotificationsPlugin();
  const androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  await fln.initialize(
    const InitializationSettings(android: androidInit),
  );

  const androidDetails = AndroidNotificationDetails(
    'alarm_channel',
    'Alarms',
    channelDescription: 'Cycle alarm notifications',
    importance: Importance.max,
    priority: Priority.max,
    fullScreenIntent: true,
    category: AndroidNotificationCategory.alarm,
    sound: RawResourceAndroidNotificationSound('alarm_sound'),
    playSound: true,
    enableVibration: true,
    ongoing: true,
    autoCancel: false,
  );

  await fln.show(
    id,
    '⏰ ${alarm.label}',
    'Tap to snooze or dismiss',
    const NotificationDetails(android: androidDetails),
    payload: alarm.id,
  );

  // Send signal to UI via IsolateNameServer if app is open
  final SendPort? uiPort =
      IsolateNameServer.lookupPortByName('alarm_ui_port');
  uiPort?.send(alarm.id);

  // Schedule next ring
  await AlarmScheduler.scheduleNext(alarm);
}

class AlarmScheduler {
  static Future<void> init() async {
    await AndroidAlarmManager.initialize();
  }

  /// Schedule the next ring for [alarm], starting from tomorrow.
  static Future<void> scheduleNext(AlarmModel alarm) async {
    if (!alarm.isEnabled) return;

    final next = alarm.nextRingDate(
        from: DateTime.now().add(const Duration(minutes: 1)));
    if (next == null) return;

    final intId = alarm.id.hashCode.abs() % 100000;
    await AndroidAlarmManager.oneShotAt(
      next,
      intId,
      alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      alarmClock: true,
    );
  }

  /// Schedule alarm starting from today (or next valid day).
  static Future<void> scheduleAlarm(AlarmModel alarm) async {
    if (!alarm.isEnabled) {
      await cancelAlarm(alarm);
      return;
    }
    final intId = alarm.id.hashCode.abs() % 100000;
    // Cancel any existing
    await AndroidAlarmManager.cancel(intId);

    final next = alarm.nextRingDate();
    if (next == null) return;

    await AndroidAlarmManager.oneShotAt(
      next,
      intId,
      alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      alarmClock: true,
    );
  }

  static Future<void> cancelAlarm(AlarmModel alarm) async {
    final intId = alarm.id.hashCode.abs() % 100000;
    await AndroidAlarmManager.cancel(intId);
  }

  /// Snooze: re-fire after [minutes] minutes
  static Future<void> snooze(AlarmModel alarm) async {
    final intId = alarm.id.hashCode.abs() % 100000;
    final snoozeTime = DateTime.now()
        .add(Duration(minutes: alarm.snoozeDurationMinutes));

    await AndroidAlarmManager.oneShotAt(
      snoozeTime,
      intId,
      alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: false,
      alarmClock: true,
    );
  }
}
