import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _prefs;

  static const String _todayFocusedSecondsKey = 'today_focused_seconds';
  static const String _todayDateKey = 'today_date';
  static const String _completedSessionsTotalKey = 'completed_sessions_total';
  static const String _lastPaywallDateKey = 'last_paywall_date';
  static const String _isPremiumCachedKey = 'is_premium_cached';
  static const String _languageCodeKey = 'language_code';
  static const String _customStartFocusSecondsKey = 'custom_start_focus_seconds';
  static const String _customPomodoroFocusSecondsKey =
      'custom_pomodoro_focus_seconds';
  static const String _customPomodoroBreakSecondsKey =
      'custom_pomodoro_break_seconds';
  static const String _selectedSoundIdKey = 'selected_sound_id';
  static const String _soundVolumeKey = 'sound_volume';
  static const String _autoPlayEnabledKey = 'auto_play_enabled';

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

  static int? getCustomStartFocusSeconds() {
    return _prefs.getInt(_customStartFocusSecondsKey);
  }

  static Future<void> setCustomStartFocusSeconds(int value) async {
    await _prefs.setInt(_customStartFocusSecondsKey, value);
  }

  static int? getCustomPomodoroFocusSeconds() {
    return _prefs.getInt(_customPomodoroFocusSecondsKey);
  }

  static Future<void> setCustomPomodoroFocusSeconds(int value) async {
    await _prefs.setInt(_customPomodoroFocusSecondsKey, value);
  }

  static int? getCustomPomodoroBreakSeconds() {
    return _prefs.getInt(_customPomodoroBreakSecondsKey);
  }

  static Future<void> setCustomPomodoroBreakSeconds(int value) async {
    await _prefs.setInt(_customPomodoroBreakSecondsKey, value);
  }

  static String? getLanguageCode() {
    return _prefs.getString(_languageCodeKey);
  }

  static Future<void> setLanguageCode(String value) async {
    await _prefs.setString(_languageCodeKey, value);
  }

  static String? getString(String key) => _prefs.getString(key);

  static Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static int? getInt(String key) => _prefs.getInt(key);

  static Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static double? getDouble(String key) => _prefs.getDouble(key);

  static Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  static bool? getBool(String key) => _prefs.getBool(key);

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static List<String>? getStringList(String key) => _prefs.getStringList(key);

  static Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  static String? getSelectedSoundId() => _prefs.getString(_selectedSoundIdKey);

  static Future<void> setSelectedSoundId(String value) async {
    await _prefs.setString(_selectedSoundIdKey, value);
  }

  static double? getSoundVolume() => _prefs.getDouble(_soundVolumeKey);

  static Future<void> setSoundVolume(double value) async {
    await _prefs.setDouble(_soundVolumeKey, value);
  }

  static bool? getAutoPlayEnabled() => _prefs.getBool(_autoPlayEnabledKey);

  static Future<void> setAutoPlayEnabled(bool value) async {
    await _prefs.setBool(_autoPlayEnabledKey, value);
  }
}
