import '../../../core/localization/app_localizations.dart';

class FocusPreset {
  const FocusPreset({
    required this.id,
    required this.name,
    required this.focusSeconds,
    required this.breakSeconds,
    required this.isBuiltIn,
    required this.isPremium,
    this.autoStartBreak = true,
    this.autoStartNextFocus = false,
    this.whiteNoiseSoundId,
    this.reminderProfileId,
  });

  static const String idStartNow = 'start_now';
  static const String idPomodoro = 'pomodoro';
  static const String idDeepWork = 'deep_work';
  static const String idStudy = 'study';
  static const String idSprint = 'sprint';
  static const String idLongFocus = 'long_focus';

  final String id;
  final String name;
  final int focusSeconds;
  final int breakSeconds;
  final bool isBuiltIn;
  final bool isPremium;
  final bool autoStartBreak;
  final bool autoStartNextFocus;
  final String? whiteNoiseSoundId;
  final String? reminderProfileId;

  bool get hasBreak => breakSeconds > 0;

  FocusPreset copyWith({
    String? id,
    String? name,
    int? focusSeconds,
    int? breakSeconds,
    bool? isBuiltIn,
    bool? isPremium,
    bool? autoStartBreak,
    bool? autoStartNextFocus,
    String? whiteNoiseSoundId,
    String? reminderProfileId,
  }) {
    return FocusPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      focusSeconds: focusSeconds ?? this.focusSeconds,
      breakSeconds: breakSeconds ?? this.breakSeconds,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isPremium: isPremium ?? this.isPremium,
      autoStartBreak: autoStartBreak ?? this.autoStartBreak,
      autoStartNextFocus: autoStartNextFocus ?? this.autoStartNextFocus,
      whiteNoiseSoundId: whiteNoiseSoundId ?? this.whiteNoiseSoundId,
      reminderProfileId: reminderProfileId ?? this.reminderProfileId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'focusSeconds': focusSeconds,
      'breakSeconds': breakSeconds,
      'isBuiltIn': isBuiltIn,
      'isPremium': isPremium,
      'autoStartBreak': autoStartBreak,
      'autoStartNextFocus': autoStartNextFocus,
      'whiteNoiseSoundId': whiteNoiseSoundId,
      'reminderProfileId': reminderProfileId,
    };
  }

  static FocusPreset fromJson(Map<String, dynamic> json) {
    return FocusPreset(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Preset',
      focusSeconds: json['focusSeconds'] as int? ?? 1500,
      breakSeconds: json['breakSeconds'] as int? ?? 0,
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? true,
      autoStartBreak: json['autoStartBreak'] as bool? ?? true,
      autoStartNextFocus: json['autoStartNextFocus'] as bool? ?? false,
      whiteNoiseSoundId: json['whiteNoiseSoundId'] as String?,
      reminderProfileId: json['reminderProfileId'] as String?,
    );
  }

  String displayName(AppLocalizations loc) {
    switch (id) {
      case idStartNow:
        return loc.t('start_now');
      case idPomodoro:
        return loc.t('pomodoro');
      case idDeepWork:
        return loc.t('deep_work');
      case idStudy:
        return loc.t('study');
      case idSprint:
        return loc.t('sprint');
      case idLongFocus:
        return loc.t('long_focus');
      default:
        return name;
    }
  }

  String displaySubtitle(AppLocalizations loc) {
    switch (id) {
      case idStartNow:
        return loc.t('start_now_subtitle');
      case idPomodoro:
        return loc.t('pomodoro_subtitle');
      default:
        return durationLabel(loc);
    }
  }

  String durationLabel(AppLocalizations loc) {
    final focusMinutes = (focusSeconds / 60).round();
    final breakMinutes = (breakSeconds / 60).round();
    if (breakSeconds <= 0) {
      return '$focusMinutes ${loc.t('minutes_short')}';
    }
    return '$focusMinutes/$breakMinutes';
  }
}
