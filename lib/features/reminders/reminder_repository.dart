import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../../core/storage/prefs.dart';

class ReminderRepository {
  ReminderRepository(this._notifications);

  final FlutterLocalNotificationsPlugin _notifications;
  bool _ready = false;

  static const _dailyBaseId = 200; // + weekday
  static const _inactivityId = 300;
  static const _streakId = 301;

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(initSettings);

    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    _ready = true;
  }

  Future<void> cancelAll() async {
    if (!_ready) return;
    await _notifications.cancelAll();
  }

  Future<void> scheduleAll(ReminderSettings settings, ReminderContext context) async {
    if (!_ready) return;
    await cancelAll();

    if (!settings.premiumEnabled) return;

    if (settings.dailyEnabled) {
      await _scheduleDaily(settings, context);
    }

    if (settings.inactivityEnabled) {
      await _scheduleInactivity(settings, context);
    }

    if (settings.streakEnabled) {
      await _scheduleStreak(settings, context);
    }
  }

  Future<void> rescheduleOnSession(ReminderSettings settings, ReminderContext context) async {
    await scheduleAll(settings, context);
  }

  Future<void> _scheduleDaily(ReminderSettings settings, ReminderContext context) async {
    final days = settings.dailyDays.isEmpty
        ? [1, 2, 3, 4, 5, 6, 7]
        : settings.dailyDays.toList();

    for (final weekday in days) {
      if (_isInQuietHours(settings, settings.dailyTimeMinutes)) continue;
      final id = _dailyBaseId + weekday;
      final time = _nextInstanceOfTime(settings.dailyTimeMinutes, weekday: weekday);
      try {
        await _notifications.zonedSchedule(
          id,
          'Time to focus. Start your session.',
          '',
          time,
          _details(),
          androidAllowWhileIdle: true,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } on PlatformException {
        // Ignore exact alarm permission errors.
      }
    }
  }

  Future<void> _scheduleInactivity(ReminderSettings settings, ReminderContext context) async {
    if (context.todayFocusedSeconds > 0) return;
    if (_isInQuietHours(settings, settings.inactivityTimeMinutes)) return;
    final time = _nextInstanceOfTime(settings.inactivityTimeMinutes);
    try {
      await _notifications.zonedSchedule(
        _inactivityId,
        'Still time to get a small win today.',
        '',
        time,
        _details(),
        androidAllowWhileIdle: true,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on PlatformException {
      // Ignore exact alarm permission errors.
    }
  }

  Future<void> _scheduleStreak(ReminderSettings settings, ReminderContext context) async {
    if (context.currentStreak <= 0) return;
    if (context.todayFocusedSeconds > 0) return;
    if (_isInQuietHours(settings, settings.streakTimeMinutes)) return;
    final time = _nextInstanceOfTime(settings.streakTimeMinutes);
    try {
      await _notifications.zonedSchedule(
        _streakId,
        'Don’t break your streak 🔥',
        '',
        time,
        _details(),
        androidAllowWhileIdle: true,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on PlatformException {
      // Ignore exact alarm permission errors.
    }
  }

  bool _isInQuietHours(ReminderSettings settings, int minutes) {
    if (!settings.quietHoursEnabled) return false;
    final start = settings.quietStartMinutes;
    final end = settings.quietEndMinutes;
    if (start == end) return false;
    if (start < end) {
      return minutes >= start && minutes < end;
    }
    return minutes >= start || minutes < end;
  }

  tz.TZDateTime _nextInstanceOfTime(int minutes, {int? weekday}) {
    final now = tz.TZDateTime.now(tz.local);
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (weekday != null) {
      while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    }

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      'focus_reminders',
      'Focus Reminders',
      channelDescription: 'Focus reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }
}

class ReminderSettings {
  ReminderSettings({
    required this.premiumEnabled,
    required this.dailyEnabled,
    required this.dailyTimeMinutes,
    required this.dailyDays,
    required this.inactivityEnabled,
    required this.inactivityTimeMinutes,
    required this.streakEnabled,
    required this.streakTimeMinutes,
    required this.quietHoursEnabled,
    required this.quietStartMinutes,
    required this.quietEndMinutes,
  });

  final bool premiumEnabled;
  final bool dailyEnabled;
  final int dailyTimeMinutes;
  final List<int> dailyDays;
  final bool inactivityEnabled;
  final int inactivityTimeMinutes;
  final bool streakEnabled;
  final int streakTimeMinutes;
  final bool quietHoursEnabled;
  final int quietStartMinutes;
  final int quietEndMinutes;
}

class ReminderContext {
  ReminderContext({
    required this.todayFocusedSeconds,
    required this.currentStreak,
  });

  final int todayFocusedSeconds;
  final int currentStreak;
}

class ReminderPrefs {
  static const _dailyEnabledKey = 'daily_reminder_enabled';
  static const _dailyTimeKey = 'daily_reminder_time';
  static const _dailyDaysKey = 'daily_reminder_days';
  static const _inactivityEnabledKey = 'inactivity_reminder_enabled';
  static const _inactivityTimeKey = 'inactivity_reminder_time';
  static const _streakEnabledKey = 'streak_reminder_enabled';
  static const _streakTimeKey = 'streak_reminder_time';
  static const _quietEnabledKey = 'quiet_hours_enabled';
  static const _quietStartKey = 'quiet_hours_start';
  static const _quietEndKey = 'quiet_hours_end';

  static bool getDailyEnabled() => Prefs.getBool(_dailyEnabledKey) ?? false;
  static int getDailyTime() => Prefs.getInt(_dailyTimeKey) ?? 540;
  static List<int> getDailyDays() {
    final list = Prefs.getStringList(_dailyDaysKey) ?? [];
    return list.map(int.parse).toList();
  }

  static bool getInactivityEnabled() =>
      Prefs.getBool(_inactivityEnabledKey) ?? false;
  static int getInactivityTime() => Prefs.getInt(_inactivityTimeKey) ?? 1080;

  static bool getStreakEnabled() => Prefs.getBool(_streakEnabledKey) ?? false;
  static int getStreakTime() => Prefs.getInt(_streakTimeKey) ?? 1200;

  static bool getQuietEnabled() => Prefs.getBool(_quietEnabledKey) ?? false;
  static int getQuietStart() => Prefs.getInt(_quietStartKey) ?? 1320;
  static int getQuietEnd() => Prefs.getInt(_quietEndKey) ?? 420;

  static Future<void> setDailyEnabled(bool value) =>
      Prefs.setBool(_dailyEnabledKey, value);
  static Future<void> setDailyTime(int value) =>
      Prefs.setInt(_dailyTimeKey, value);
  static Future<void> setDailyDays(List<int> value) =>
      Prefs.setStringList(_dailyDaysKey, value.map((e) => e.toString()).toList());

  static Future<void> setInactivityEnabled(bool value) =>
      Prefs.setBool(_inactivityEnabledKey, value);
  static Future<void> setInactivityTime(int value) =>
      Prefs.setInt(_inactivityTimeKey, value);

  static Future<void> setStreakEnabled(bool value) =>
      Prefs.setBool(_streakEnabledKey, value);
  static Future<void> setStreakTime(int value) =>
      Prefs.setInt(_streakTimeKey, value);

  static Future<void> setQuietEnabled(bool value) =>
      Prefs.setBool(_quietEnabledKey, value);
  static Future<void> setQuietStart(int value) =>
      Prefs.setInt(_quietStartKey, value);
  static Future<void> setQuietEnd(int value) =>
      Prefs.setInt(_quietEndKey, value);
}
