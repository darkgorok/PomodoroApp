import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/ui/back_swipe.dart';
import '../../core/ui/app_background.dart';
import '../focus/controller/stats_controller.dart';
import '../focus/ui/paywall_screen.dart';
import 'reminder_controller.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({
    super.key,
    required this.controller,
    required this.stats,
  });

  final ReminderController controller;
  final StatsController stats;

  @override
  State<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.requestPermissionsOnFirstOpen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final controller = widget.controller;
    final stats = widget.stats;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(loc.t('reminders')),
      ),
      body: BackSwipe(
        onBack: () => Navigator.of(context).maybePop(),
        child: SafeArea(
          bottom: false,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(appBackgroundAsset(context)),
                fit: BoxFit.cover,
              ),
            ),
            child: AnimatedBuilder(
              animation: Listenable.merge([controller, stats]),
              builder: (context, _) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                  _SectionTitle(title: loc.t('daily_reminder')),
                  _CardBlock(
                    child: Column(
                      children: [
                        _ToggleRow(
                          title: loc.t('daily_reminder'),
                          value: controller.dailyEnabled,
                          onChanged: stats.isPremiumCached
                              ? (v) => controller.setDailyEnabled(v)
                              : (_) => _openPaywall(context),
                        ),
                        _TimeRow(
                          title: loc.t('time'),
                          value: _formatMinutes(controller.dailyTimeMinutes),
                          onTap: stats.isPremiumCached
                              ? () => _pickTime(
                                    context,
                                    controller.dailyTimeMinutes,
                                    controller.setDailyTime,
                                  )
                              : () => _openPaywall(context),
                        ),
                        _DaysSelector(
                          selectedDays: controller.dailyDays,
                          onChanged: stats.isPremiumCached
                              ? controller.setDailyDays
                              : (_) => _openPaywall(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: loc.t('inactivity_reminder')),
                  _CardBlock(
                    child: Column(
                      children: [
                        _ToggleRow(
                          title: loc.t('inactivity_reminder'),
                          value: controller.inactivityEnabled,
                          onChanged: stats.isPremiumCached
                              ? (v) => controller.setInactivityEnabled(v)
                              : (_) => _openPaywall(context),
                        ),
                        _TimeRow(
                          title: loc.t('after_time'),
                          value: _formatMinutes(controller.inactivityTimeMinutes),
                          onTap: stats.isPremiumCached
                              ? () => _pickTime(
                                    context,
                                    controller.inactivityTimeMinutes,
                                    controller.setInactivityTime,
                                  )
                              : () => _openPaywall(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (stats.currentStreak > 1) ...[
                    _SectionTitle(title: loc.t('streak_reminder')),
                    _CardBlock(
                      child: Column(
                        children: [
                          _ToggleRow(
                            title: loc.t('streak_reminder'),
                            value: controller.streakEnabled,
                            onChanged: stats.isPremiumCached
                                ? (v) => controller.setStreakEnabled(v)
                                : (_) => _openPaywall(context),
                          ),
                          _TimeRow(
                            title: loc.t('send_after'),
                            value: _formatMinutes(controller.streakTimeMinutes),
                            onTap: stats.isPremiumCached
                                ? () => _pickTime(
                                      context,
                                      controller.streakTimeMinutes,
                                      controller.setStreakTime,
                                    )
                                : () => _openPaywall(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _SectionTitle(title: loc.t('quiet_hours')),
                  _CardBlock(
                    child: Column(
                      children: [
                        _ToggleRow(
                          title: loc.t('quiet_hours'),
                          value: controller.quietHoursEnabled,
                          onChanged: stats.isPremiumCached
                              ? (v) => controller.setQuietEnabled(v)
                              : (_) => _openPaywall(context),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _TimeRow(
                                title: loc.t('from'),
                                value: _formatMinutes(controller.quietStartMinutes),
                                onTap: stats.isPremiumCached
                                    ? () => _pickTime(
                                          context,
                                          controller.quietStartMinutes,
                                          controller.setQuietStart,
                                        )
                                    : () => _openPaywall(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _TimeRow(
                                title: loc.t('to'),
                                value: _formatMinutes(controller.quietEndMinutes),
                                onTap: stats.isPremiumCached
                                    ? () => _pickTime(
                                          context,
                                          controller.quietEndMinutes,
                                          controller.setQuietEnd,
                                        )
                                    : () => _openPaywall(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _openPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    int currentMinutes,
    Future<void> Function(int) onSave,
  ) async {
    final initial = DateTime(2020, 1, 1, currentMinutes ~/ 60, currentMinutes % 60);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        int tempMinutes = currentMinutes;
        return Container(
          height: 260,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: initial,
                  use24hFormat: true,
                  onDateTimeChanged: (value) {
                    tempMinutes = value.hour * 60 + value.minute;
                  },
                ),
              ),
              CupertinoButton(
                onPressed: () async {
                  await onSave(tempMinutes);
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context).t('save')),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatMinutes(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E2138),
        ),
      ),
    );
  }
}

class _CardBlock extends StatelessWidget {
  const _CardBlock({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1E2138),
              fontWeight: FontWeight.w600,
            ),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B6F8C),
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1E2138),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: Color(0xFF9AA0C8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DaysSelector extends StatelessWidget {
  const _DaysSelector({required this.selectedDays, required this.onChanged});

  final List<int> selectedDays;
  final ValueChanged<List<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = _weekdayLabels(AppLocalizations.of(context));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Wrap(
        spacing: 8,
        children: List.generate(7, (index) {
          final day = index + 1;
          final selected = selectedDays.contains(day) || selectedDays.isEmpty;
          return ChoiceChip(
            label: Text(labels[index]),
            selected: selected,
            selectedColor: const Color(0xFF4B55C9),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF6B6F8C),
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) {
              final next = selectedDays.toList();
              if (selectedDays.isEmpty) {
                next.add(day);
              } else if (selected) {
                next.remove(day);
              } else {
                next.add(day);
              }
              onChanged(next);
            },
          );
        }),
      ),
    );
  }

  List<String> _weekdayLabels(AppLocalizations loc) {
    return [
      loc.t('weekday_mon'),
      loc.t('weekday_tue'),
      loc.t('weekday_wed'),
      loc.t('weekday_thu'),
      loc.t('weekday_fri'),
      loc.t('weekday_sat'),
      loc.t('weekday_sun'),
    ];
  }
}
