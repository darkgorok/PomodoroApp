import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _prefs;

  static const String _todayFocusedSecondsKey = 'today_focused_seconds';
  static const String _todayDateKey = 'today_date';
  static const String _completedSessionsTotalKey = 'completed_sessions_total';
  static const String _lastPaywallDateKey = 'last_paywall_date';
  static const String _isPremiumCachedKey = 'is_premium_cached';
  static const String _languageCodeKey = 'language_code';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String todayDateString([DateTime? now]) {
    final date = now ?? DateTime.now();
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static int getTodayFocusedSeconds() {
    return _prefs.getInt(_todayFocusedSecondsKey) ?? 0;
  }

  static Future<void> setTodayFocusedSeconds(int value) async {
    await _prefs.setInt(_todayFocusedSecondsKey, value);
  }

  static String? getTodayDate() {
    return _prefs.getString(_todayDateKey);
  }

  static Future<void> setTodayDate(String value) async {
    await _prefs.setString(_todayDateKey, value);
  }

  static int getCompletedSessionsTotal() {
    return _prefs.getInt(_completedSessionsTotalKey) ?? 0;
  }

  static Future<void> setCompletedSessionsTotal(int value) async {
    await _prefs.setInt(_completedSessionsTotalKey, value);
  }

  static String? getLastPaywallDate() {
    return _prefs.getString(_lastPaywallDateKey);
  }

  static Future<void> setLastPaywallDate(String value) async {
    await _prefs.setString(_lastPaywallDateKey, value);
  }

  static bool getIsPremiumCached() {
    return _prefs.getBool(_isPremiumCachedKey) ?? false;
  }

  static Future<void> setIsPremiumCached(bool value) async {
    await _prefs.setBool(_isPremiumCachedKey, value);
  }

  static String? getLanguageCode() {
    return _prefs.getString(_languageCodeKey);
  }

  static Future<void> setLanguageCode(String value) async {
    await _prefs.setString(_languageCodeKey, value);
  }
}
