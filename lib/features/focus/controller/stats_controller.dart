import 'package:flutter/foundation.dart';
import '../../../core/storage/prefs.dart';

class StatsController extends ChangeNotifier {
  int todayFocusedSeconds = 0;
  int completedSessionsTotal = 0;
  String lastPaywallDate = '';
  bool isPremiumCached = false;

  Future<void> init() async {
    _syncDate();
    todayFocusedSeconds = Prefs.getTodayFocusedSeconds();
    completedSessionsTotal = Prefs.getCompletedSessionsTotal();
    lastPaywallDate = Prefs.getLastPaywallDate() ?? '';
    isPremiumCached = Prefs.getIsPremiumCached();
    notifyListeners();
  }

  int get todayFocusedMinutes => todayFocusedSeconds ~/ 60;

  Future<void> addFocusSeconds(int seconds) async {
    _syncDate();
    todayFocusedSeconds += seconds;
    completedSessionsTotal += 1;
    await Prefs.setTodayFocusedSeconds(todayFocusedSeconds);
    await Prefs.setCompletedSessionsTotal(completedSessionsTotal);
    notifyListeners();
  }

  bool shouldShowPaywallAndMark() {
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

  void _syncDate() {
    final today = Prefs.todayDateString();
    final storedDate = Prefs.getTodayDate();
    if (storedDate != today) {
      Prefs.setTodayDate(today);
      Prefs.setTodayFocusedSeconds(0);
      todayFocusedSeconds = 0;
    }
  }
}
