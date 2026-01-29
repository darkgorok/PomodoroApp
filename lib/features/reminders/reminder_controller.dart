import 'package:flutter/foundation.dart';

import '../focus/controller/stats_controller.dart';
import 'reminder_repository.dart';

class ReminderController extends ChangeNotifier {
  ReminderController({required this.repo, required this.stats});

  final ReminderRepository repo;
  final StatsController stats;

  bool dailyEnabled = false;
  int dailyTimeMinutes = 540;
  List<int> dailyDays = [];
  bool inactivityEnabled = false;
  int inactivityTimeMinutes = 1080;
  bool streakEnabled = false;
  int streakTimeMinutes = 1200;
  bool quietHoursEnabled = false;
  int quietStartMinutes = 1320;
  int quietEndMinutes = 420;

  Future<void> init() async {
    dailyEnabled = ReminderPrefs.getDailyEnabled();
    dailyTimeMinutes = ReminderPrefs.getDailyTime();
    dailyDays = ReminderPrefs.getDailyDays();
    inactivityEnabled = ReminderPrefs.getInactivityEnabled();
    inactivityTimeMinutes = ReminderPrefs.getInactivityTime();
    streakEnabled = ReminderPrefs.getStreakEnabled();
    streakTimeMinutes = ReminderPrefs.getStreakTime();
    quietHoursEnabled = ReminderPrefs.getQuietEnabled();
    quietStartMinutes = ReminderPrefs.getQuietStart();
    quietEndMinutes = ReminderPrefs.getQuietEnd();
    await scheduleAll();
  }

  Future<void> requestPermissionsOnFirstOpen() async {
    if (ReminderPrefs.getPermissionRequested()) return;
    await repo.requestPermissions();
    await ReminderPrefs.setPermissionRequested(true);
  }

  ReminderSettings _settings() => ReminderSettings(
        premiumEnabled: stats.isPremiumCached,
        dailyEnabled: dailyEnabled,
        dailyTimeMinutes: dailyTimeMinutes,
        dailyDays: dailyDays,
        inactivityEnabled: inactivityEnabled,
        inactivityTimeMinutes: inactivityTimeMinutes,
        streakEnabled: streakEnabled,
        streakTimeMinutes: streakTimeMinutes,
        quietHoursEnabled: quietHoursEnabled,
        quietStartMinutes: quietStartMinutes,
        quietEndMinutes: quietEndMinutes,
      );

  ReminderContext _context() => ReminderContext(
        todayFocusedSeconds: stats.todayFocusedSeconds,
        currentStreak: stats.currentStreak,
      );

  Future<void> scheduleAll() async {
    await repo.scheduleAll(_settings(), _context());
    notifyListeners();
  }

  Future<void> rescheduleOnSession() async {
    await repo.rescheduleOnSession(_settings(), _context());
  }

  Future<void> cancelAll() async {
    await repo.cancelAll();
  }

  Future<void> setDailyEnabled(bool value) async {
    dailyEnabled = value;
    await ReminderPrefs.setDailyEnabled(value);
    await scheduleAll();
  }

  Future<void> setDailyTime(int minutes) async {
    dailyTimeMinutes = minutes;
    await ReminderPrefs.setDailyTime(minutes);
    await scheduleAll();
  }

  Future<void> setDailyDays(List<int> days) async {
    dailyDays = days;
    await ReminderPrefs.setDailyDays(days);
    await scheduleAll();
  }

  Future<void> setInactivityEnabled(bool value) async {
    inactivityEnabled = value;
    await ReminderPrefs.setInactivityEnabled(value);
    await scheduleAll();
  }

  Future<void> setInactivityTime(int minutes) async {
    inactivityTimeMinutes = minutes;
    await ReminderPrefs.setInactivityTime(minutes);
    await scheduleAll();
  }

  Future<void> setStreakEnabled(bool value) async {
    streakEnabled = value;
    await ReminderPrefs.setStreakEnabled(value);
    await scheduleAll();
  }

  Future<void> setStreakTime(int minutes) async {
    streakTimeMinutes = minutes;
    await ReminderPrefs.setStreakTime(minutes);
    await scheduleAll();
  }

  Future<void> setQuietEnabled(bool value) async {
    quietHoursEnabled = value;
    await ReminderPrefs.setQuietEnabled(value);
    await scheduleAll();
  }

  Future<void> setQuietStart(int minutes) async {
    quietStartMinutes = minutes;
    await ReminderPrefs.setQuietStart(minutes);
    await scheduleAll();
  }

  Future<void> setQuietEnd(int minutes) async {
    quietEndMinutes = minutes;
    await ReminderPrefs.setQuietEnd(minutes);
    await scheduleAll();
  }
}
