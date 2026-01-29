extension DurationFormatting on int {
  String toMinutesSeconds() {
    final minutes = this ~/ 60;
    final seconds = this % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

extension DurationFormattingOnDuration on Duration {
  String toMinutesSeconds() => inSeconds.toMinutesSeconds();
}
