import 'dart:convert';

import '../../../core/storage/prefs.dart';

class DayFocusStat {
  DayFocusStat({
    required this.date,
    required this.focusedSeconds,
    required this.sessions,
  });

  final String date; // yyyy-mm-dd
  final int focusedSeconds;
  final int sessions;

  int get focusedMinutes => focusedSeconds ~/ 60;
}

class StreakData {
  StreakData({
    required this.current,
    required this.best,
    required this.lastFocusedDate,
  });

  final int current;
  final int best;
  final String lastFocusedDate;
}

class StatsRepository {
  static const _focusLogKey = 'focus_log';
  static const _bestStreakKey = 'best_streak';
  static const _currentStreakKey = 'current_streak';
  static const _lastFocusedDateKey = 'last_focused_date';
  static const _totalFocusedSecondsKey = 'total_focused_seconds';

  Future<void> addFocusSession(int seconds) async {
    final today = Prefs.todayDateString();
    final log = _loadLog();

    final entry = log[today] ?? {'focused_seconds': 0, 'sessions': 0};
    entry['focused_seconds'] = (entry['focused_seconds'] ?? 0) + seconds;
    entry['sessions'] = (entry['sessions'] ?? 0) + 1;
    log[today] = entry;

    await _saveLog(log);

    final total = _getTotalFocusedSeconds() + seconds;
    await _setTotalFocusedSeconds(total);

    await _updateStreaks(today);
  }

  DayFocusStat getTodayStats() {
    final today = Prefs.todayDateString();
    final log = _loadLog();
    final entry = log[today];
    return DayFocusStat(
      date: today,
      focusedSeconds: entry?['focused_seconds'] ?? 0,
      sessions: entry?['sessions'] ?? 0,
    );
  }

  List<DayFocusStat> getLastDaysStats(int days) {
    final log = _loadLog();
    final result = <DayFocusStat>[];
    for (var i = days - 1; i >= 0; i--) {
      final date = _dateString(DateTime.now().subtract(Duration(days: i)));
      final entry = log[date];
      result.add(
        DayFocusStat(
          date: date,
          focusedSeconds: entry?['focused_seconds'] ?? 0,
          sessions: entry?['sessions'] ?? 0,
        ),
      );
    }
    return result;
  }

  int getTotalFocusedSeconds() => _getTotalFocusedSeconds();

  StreakData getStreakData() {
    final last = _getLastFocusedDate();
    final current = _getCurrentStreak();
    final best = _getBestStreak();

    if (last.isEmpty) {
      return StreakData(current: 0, best: best, lastFocusedDate: last);
    }

    final today = _parseDate(_dateString(DateTime.now()));
    final lastDate = _parseDate(last);
    final diff = today.difference(lastDate).inDays;
    final visibleCurrent = diff <= 1 ? current : 0;

    return StreakData(current: visibleCurrent, best: best, lastFocusedDate: last);
  }

  Map<String, Map<String, int>> _loadLog() {
    final raw = Prefs.getString(_focusLogKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final result = <String, Map<String, int>>{};
    for (final entry in decoded.entries) {
      final value = entry.value as Map<String, dynamic>;
      result[entry.key] = {
        'focused_seconds': value['focused_seconds'] ?? 0,
        'sessions': value['sessions'] ?? 0,
      };
    }
    return result;
  }

  Future<void> _saveLog(Map<String, Map<String, int>> log) async {
    await Prefs.setString(_focusLogKey, jsonEncode(log));
  }

  Future<void> _updateStreaks(String today) async {
    final last = _getLastFocusedDate();
    final current = _getCurrentStreak();

    final yesterday = _dateString(DateTime.now().subtract(const Duration(days: 1)));

    int newCurrent;
    if (last == today) {
      newCurrent = current;
    } else if (last == yesterday) {
      newCurrent = current + 1;
    } else {
      newCurrent = 1;
    }

    await _setCurrentStreak(newCurrent);
    await _setLastFocusedDate(today);

    final best = _getBestStreak();
    if (newCurrent > best) {
      await _setBestStreak(newCurrent);
    }
  }

  int _getBestStreak() => Prefs.getInt(_bestStreakKey) ?? 0;
  int _getCurrentStreak() => Prefs.getInt(_currentStreakKey) ?? 0;
  String _getLastFocusedDate() => Prefs.getString(_lastFocusedDateKey) ?? '';
  int _getTotalFocusedSeconds() => Prefs.getInt(_totalFocusedSecondsKey) ?? 0;

  Future<void> _setBestStreak(int value) async => Prefs.setInt(_bestStreakKey, value);
  Future<void> _setCurrentStreak(int value) async =>
      Prefs.setInt(_currentStreakKey, value);
  Future<void> _setLastFocusedDate(String value) async =>
      Prefs.setString(_lastFocusedDateKey, value);
  Future<void> _setTotalFocusedSeconds(int value) async =>
      Prefs.setInt(_totalFocusedSecondsKey, value);

  String _dateString(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  DateTime _parseDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return DateTime.now();
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
