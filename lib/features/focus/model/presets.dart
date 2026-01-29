import 'session_state.dart';

class FocusPreset {
  const FocusPreset({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.focusSeconds,
    required this.breakSeconds,
  });

  final SessionMode mode;
  final String title;
  final String subtitle;
  final int focusSeconds;
  final int breakSeconds;

  static const FocusPreset startNow = FocusPreset(
    mode: SessionMode.startNow,
    title: 'Start Now',
    subtitle: '5 minutes. Just begin',
    focusSeconds: 5 * 60,
    breakSeconds: 0,
  );

  static const FocusPreset pomodoro = FocusPreset(
    mode: SessionMode.pomodoro,
    title: 'Pomodoro',
    subtitle: '25/5 classic',
    focusSeconds: 25 * 60,
    breakSeconds: 5 * 60,
  );
}
