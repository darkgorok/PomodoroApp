import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../model/presets.dart';
import '../model/session_state.dart';
import 'stats_controller.dart';

class TimerController extends ChangeNotifier {
  TimerController({
    required this.preset,
    required this.stats,
    this.onSessionComplete,
  })  : remainingSeconds = preset.focusSeconds,
        isBreak = false,
        isRunning = false;

  final FocusPreset preset;
  final StatsController stats;
  final VoidCallback? onSessionComplete;

  int remainingSeconds;
  bool isRunning;
  bool isBreak;
  Timer? _timer;

  SessionMode get mode => preset.mode;
  int get focusSeconds => preset.focusSeconds;
  int get breakSeconds => preset.breakSeconds;
  int get segmentSeconds => isBreak ? breakSeconds : focusSeconds;

  void start() {
    if (isRunning) return;
    _startTimer();
  }

  void pause() {
    if (!isRunning) return;
    _timer?.cancel();
    isRunning = false;
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    isRunning = false;
    isBreak = false;
    remainingSeconds = focusSeconds;
    notifyListeners();
  }

  void restart() {
    _timer?.cancel();
    isBreak = false;
    remainingSeconds = focusSeconds;
    isRunning = false;
    notifyListeners();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    notifyListeners();
  }

  void _onTick(Timer timer) {
    if (remainingSeconds > 0) {
      remainingSeconds -= 1;
      notifyListeners();
    }
    if (remainingSeconds == 0) {
      _handleFinish();
    }
  }

  void _handleFinish() {
    _timer?.cancel();
    isRunning = false;
    HapticFeedback.mediumImpact();

    if (!isBreak) {
      stats.addFocusSeconds(focusSeconds);
      if (mode == SessionMode.pomodoro && breakSeconds > 0) {
        isBreak = true;
        remainingSeconds = breakSeconds;
        notifyListeners();
        _startTimer();
        return;
      }
    }

    onSessionComplete?.call();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
