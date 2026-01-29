import 'package:flutter/foundation.dart';
import '../../../core/storage/prefs.dart';
import '../data/stats_repository.dart';

class StatsController extends ChangeNotifier {
  StatsController() : _repo = StatsRepository();

  final StatsRepository _repo;

  int todayFocusedSeconds = 0;
  int sessionsToday = 0;
  int completedSessionsTotal = 0;
  int currentStreak = 0;
  int bestStreak = 0;
  int totalFocusedSeconds = 0;
  List<DayFocusStat> weeklyStats = const [];
  List<DayFocusStat> calendarStats = const [];

  String lastPaywallDate = '';
  bool isPremiumCached = false;

  Future<void> init() async {
    completedSessionsTotal = Prefs.getCompletedSessionsTotal();
    lastPaywallDate = Prefs.getLastPaywallDate() ?? '';
    isPremiumCached = Prefs.getIsPremiumCached();
    await _refreshStats();
  }

  int get todayFocusedMinutes => todayFocusedSeconds ~/ 60;

  Future<void> addFocusSession(int seconds) async {
    await _repo.addFocusSession(seconds);
    completedSessionsTotal += 1;
    await Prefs.setCompletedSessionsTotal(completedSessionsTotal);
    await _refreshStats();
  }

  Future<void> _refreshStats() async {
    final today = _repo.getTodayStats();
    todayFocusedSeconds = today.focusedSeconds;
    sessionsToday = today.sessions;

    final streak = _repo.getStreakData();
    currentStreak = streak.current;
    bestStreak = streak.best;

    totalFocusedSeconds = _repo.getTotalFocusedSeconds();

    weeklyStats = _repo.getLastDaysStats(7);
    calendarStats = _repo.getLastDaysStats(30);

    notifyListeners();
  }

  bool shouldShowPaywallAndMark() {
    if (isPremiumCached) return false;
    final today = Prefs.todayDateString();
    if (completedSessionsTotal >= 2 && lastPaywallDate != today) {
      lastPaywallDate = today;
      Prefs.setLastPaywallDate(today);
      notifyListeners();
      return true;
    }
    return false;
  }

  void markPaywallShown() {
    final today = Prefs.todayDateString();
    lastPaywallDate = today;
    Prefs.setLastPaywallDate(today);
    notifyListeners();
  }

  Future<void> setPremiumCached(bool value) async {
    isPremiumCached = value;
    await Prefs.setIsPremiumCached(value);
    notifyListeners();
  }
}
