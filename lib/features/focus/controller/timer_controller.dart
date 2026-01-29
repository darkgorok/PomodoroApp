import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../model/presets.dart';
import 'stats_controller.dart';

class TimerController extends ChangeNotifier {
  TimerController({
    required FocusPreset preset,
    required this.stats,
    this.onSessionComplete,
    this.onFocusStart,
    this.onFocusEnd,
    this.onBreakStart,
  })  : preset = preset,
        remainingSeconds = preset.focusSeconds,
        _focusSeconds = preset.focusSeconds,
        _breakSeconds = preset.breakSeconds,
        isBreak = false,
        isRunning = false;

  FocusPreset preset;
  final StatsController stats;
  final VoidCallback? onSessionComplete;
  final VoidCallback? onFocusStart;
  final VoidCallback? onFocusEnd;
  final VoidCallback? onBreakStart;

  int remainingSeconds;
  bool isRunning;
  bool isBreak;
  Timer? _timer;

  int get focusSeconds => _focusSeconds;
  int get breakSeconds => _breakSeconds;
  int get segmentSeconds => isBreak ? breakSeconds : focusSeconds;

  int _focusSeconds;
  int _breakSeconds;

  void updateDurations({required int focusSeconds, required int breakSeconds}) {
    _focusSeconds = focusSeconds;
    _breakSeconds = breakSeconds;
    if (!isRunning) {
      isBreak = false;
      remainingSeconds = _focusSeconds;
    }
    notifyListeners();
  }

  void applyPreset(FocusPreset next) {
    final wasRunning = isRunning;
    _timer?.cancel();
    preset = next;
    _focusSeconds = next.focusSeconds;
    _breakSeconds = next.breakSeconds;
    isRunning = false;
    isBreak = false;
    remainingSeconds = _focusSeconds;
    if (wasRunning) {
      onFocusEnd?.call();
    }
    notifyListeners();
  }

  void start() {
    if (isRunning) return;
    _startTimer();
    if (!isBreak) {
      onFocusStart?.call();
    }
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
    onFocusEnd?.call();
    notifyListeners();
  }

  void restart() {
    _timer?.cancel();
    isBreak = false;
    remainingSeconds = focusSeconds;
    isRunning = false;
    notifyListeners();
    _startTimer();
    onFocusStart?.call();
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
      stats.addFocusSession(focusSeconds);
      if (breakSeconds > 0) {
        isBreak = true;
        remainingSeconds = breakSeconds;
        notifyListeners();
        onBreakStart?.call();
        _startTimer();
        return;
      }
    }

    onFocusEnd?.call();
    onSessionComplete?.call();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
