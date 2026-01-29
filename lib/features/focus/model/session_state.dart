enum SessionMode {
  startNow,
  pomodoro,
}

class SessionState {
  const SessionState({
    required this.mode,
    required this.remainingSeconds,
    required this.isRunning,
    required this.isBreak,
  });

  final SessionMode mode;
  final int remainingSeconds;
  final bool isRunning;
  final bool isBreak;
}
