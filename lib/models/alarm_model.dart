import 'package:hive/hive.dart';

part 'alarm_model.g.dart';

@HiveType(typeId: 0)
class AlarmModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  int hour;

  @HiveField(3)
  int minute;

  // Total days in one cycle (e.g. 4)
  @HiveField(4)
  int cycleTotalDays;

  // How many of those days the alarm is ON (e.g. 3)
  @HiveField(5)
  int cycleOnDays;

  // Whether the alarm is enabled at all
  @HiveField(6)
  bool isEnabled;

  // Weekend behaviour:
  // true  = weekends COUNT toward cycle (alarm just won't ring on them)
  // false = weekends PAUSE the cycle (only weekdays advance the counter)
  @HiveField(7)
  bool weekendsCountTowardCycle;

  // Whether alarm should skip ringing on weekends
  @HiveField(8)
  bool skipWeekends;

  // The date that is considered Day 1 of the cycle
  @HiveField(9)
  DateTime cycleStartDate;

  // Path to user's chosen audio file
  @HiveField(10)
  String? audioPath;

  // Snooze duration in minutes
  @HiveField(11)
  int snoozeDurationMinutes;

  AlarmModel({
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
    required this.cycleTotalDays,
    required this.cycleOnDays,
    required this.isEnabled,
    required this.weekendsCountTowardCycle,
    required this.skipWeekends,
    required this.cycleStartDate,
    this.audioPath,
    this.snoozeDurationMinutes = 10,
  });

  /// Returns the 0-based position of [date] within the current cycle.
  /// Respects the weekendsCountTowardCycle setting.
  int cyclePositionFor(DateTime date) {
    final start = DateTime(
        cycleStartDate.year, cycleStartDate.month, cycleStartDate.day);
    final target = DateTime(date.year, date.month, date.day);

    if (weekendsCountTowardCycle) {
      // Every calendar day advances the counter
      final diff = target.difference(start).inDays;
      if (diff < 0) return -1;
      return diff % cycleTotalDays;
    } else {
      // Only weekdays (Mon–Fri) advance the counter
      int weekdayCount = 0;
      DateTime cursor = start;
      while (cursor.isBefore(target)) {
        cursor = cursor.add(const Duration(days: 1));
        if (cursor.weekday <= 5) weekdayCount++;
      }
      if (target.isBefore(start)) return -1;
      return weekdayCount % cycleTotalDays;
    }
  }

  /// Returns true if the alarm should RING on [date].
  bool shouldRingOn(DateTime date) {
    if (!isEnabled) return false;

    final isWeekend = date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;

    if (skipWeekends && isWeekend) return false;

    final pos = cyclePositionFor(date);
    if (pos < 0) return false;

    // Positions 0..(cycleOnDays-1) are ON days
    return pos < cycleOnDays;
  }

  /// Returns the next DateTime this alarm will ring, starting from [from].
  DateTime? nextRingDate({DateTime? from}) {
    DateTime cursor = from ?? DateTime.now();
    // Start checking from today (or tomorrow if today's time has passed)
    final now = DateTime.now();
    DateTime checkDate = DateTime(cursor.year, cursor.month, cursor.day);

    if (cursor.year == now.year &&
        cursor.month == now.month &&
        cursor.day == now.day) {
      final alarmToday =
          DateTime(now.year, now.month, now.day, hour, minute);
      if (now.isAfter(alarmToday)) {
        checkDate = checkDate.add(const Duration(days: 1));
      }
    }

    for (int i = 0; i < 365; i++) {
      if (shouldRingOn(checkDate)) {
        return DateTime(
            checkDate.year, checkDate.month, checkDate.day, hour, minute);
      }
      checkDate = checkDate.add(const Duration(days: 1));
    }
    return null;
  }

  String get timeString {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get cycleDescription =>
      'ON $cycleOnDays / $cycleTotalDays days · ${skipWeekends ? (weekendsCountTowardCycle ? "Weekends count, skip ring" : "Weekends paused") : "All days"}';
}
