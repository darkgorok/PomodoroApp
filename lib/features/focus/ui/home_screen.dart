import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../reminders/reminder_controller.dart';
import '../../reminders/reminder_settings_screen.dart';
import '../../settings/locale_controller.dart';
import '../../settings/ui/settings_screen.dart';
import '../controller/presets_controller.dart';
import '../controller/stats_controller.dart';
import '../model/presets.dart';
import '../components/preset_tile.dart';
import '../components/session_card.dart';
import 'paywall_screen.dart';
import 'presets_screen.dart';
import 'stats_screen.dart';
import 'timer_screen.dart';
import 'upgrade_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.stats,
    required this.localeController,
    required this.reminderController,
    required this.presetsController,
  });

  final StatsController stats;
  final LocaleController localeController;
  final ReminderController reminderController;
  final PresetsController presetsController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _paywallVisible = false;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowPaywall());

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('home_title')),
        actions: [
          IconButton(
            onPressed: _openReminders,
            icon: const Icon(CupertinoIcons.bell),
          ),
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(CupertinoIcons.settings),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/AppBackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.stats, widget.presetsController]),
          builder: (context, _) {
            final loc = AppLocalizations.of(context);
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _SummaryCard(
                  focusedMinutes: widget.stats.todayFocusedMinutes,
                  sessionsToday: widget.stats.sessionsToday,
                  currentStreak: widget.stats.currentStreak,
                  title: loc.t('today_focused'),
                  sessionsLabel: loc.t('sessions_today'),
                  streakLabel: loc.t('current_streak'),
                  daysLabel: loc.t('days_short'),
                  backgroundImage: 'assets/ButtonBackgroundDarkBlue.png',
                  backgroundScale: const Offset(1.1, 1),
                ),
                const SizedBox(height: 16),
                SessionCard(
                  title: loc.t('start_now'),
                  subtitle: loc.t('start_now_subtitle'),
                  icon: Icons.play_arrow_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B68FF), Color(0xFF8FA0FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  backgroundImage: 'assets/ButtonBackground.png',
                  backgroundScale: const Offset(1.1, 1),
                  onTap: () => _openTimer(_findPreset(FocusPreset.idStartNow)),
                ),
                const SizedBox(height: 12),
                SessionCard(
                  title: loc.t('pomodoro'),
                  subtitle: loc.t('pomodoro_subtitle'),
                  icon: Icons.timer_outlined,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8A7A), Color(0xFFFFB08A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  backgroundImage: 'assets/PomodoroBtnBackground.png',
                  backgroundScale: const Offset(1.1, 1),
                  onTap: () => _openTimer(_findPreset(FocusPreset.idPomodoro)),
                ),
                const SizedBox(height: 12),
                SessionCard(
                  title: loc.t('your_progress'),
                  subtitle: loc.t('stats_streaks_subtitle'),
                  icon: Icons.show_chart_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B68FF), Color(0xFF8FA0FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  backgroundImage: 'assets/ButtonBackground.png',
                  backgroundScale: const Offset(1.1, 1),
                  onTap: _openStats,
                ),
                if (widget.stats.isPremiumCached) ...[
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.t('presets'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _openPresets,
                        child: Text(loc.t('see_all')),
                      ),
                    ],
                  ),
                  PresetTile(
                    title: _findPreset(FocusPreset.idPomodoro).displayName(loc),
                    subtitle:
                        _findPreset(FocusPreset.idPomodoro).displaySubtitle(loc),
                    locked: false,
                    onTap: () => _openTimer(_findPreset(FocusPreset.idPomodoro)),
                  ),
                  const SizedBox(height: 12),
                  PresetTile(
                    title: _findPreset(FocusPreset.idDeepWork).displayName(loc),
                    subtitle:
                        _findPreset(FocusPreset.idDeepWork).displaySubtitle(loc),
                    locked: widget.presetsController.isLocked(
                        _findPreset(FocusPreset.idDeepWork)),
                    onTap: () {
                      final preset = _findPreset(FocusPreset.idDeepWork);
                      if (widget.presetsController.isLocked(preset)) {
                        _openPaywall();
                      } else {
                        _openTimer(preset);
                      }
                    },
                  ),
                ],
                const SizedBox(height: 12),
                _TipCard(
                  title: loc.t('small_rule'),
                  text: loc.t('small_rule_text'),
                  backgroundImage: 'assets/ButtonBackgroundGrey.png',
                  backgroundScale: const Offset(1.1, 1),
                ),
                const SizedBox(height: 12),
                _LockedCard(
                  title: loc.t('customize'),
                  subtitle: loc.t('customize_locked_subtitle'),
                  backgroundImage: 'assets/ButtonBackgroundDarkGrey.png',
                  backgroundScale: const Offset(1.1, 1),
                  onTap: _openUpgrade,
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _openTimer(FocusPreset preset) {
    widget.presetsController.selectPreset(preset);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TimerScreen(
          preset: preset,
          stats: widget.stats,
          reminderController: widget.reminderController,
          presetsController: widget.presetsController,
        ),
      ),
    );
  }

  void _openUpgrade() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UpgradeScreen()),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          localeController: widget.localeController,
          stats: widget.stats,
          reminderController: widget.reminderController,
        ),
      ),
    );
  }

  void _openPaywall() {
    widget.stats.markPaywallShown();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
  }

  void _openStats() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StatsScreen(stats: widget.stats)),
    );
  }

  void _openPresets() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PresetsScreen(
          presetsController: widget.presetsController,
          stats: widget.stats,
          reminderController: widget.reminderController,
        ),
      ),
    );
  }

  void _openReminders() {
    if (!widget.stats.isPremiumCached) {
      _openUpgrade();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReminderSettingsScreen(
          controller: widget.reminderController,
          stats: widget.stats,
        ),
      ),
    );
  }

  void _maybeShowPaywall() {
    if (_paywallVisible) return;
    if (widget.stats.shouldShowPaywallAndMark()) {
      _paywallVisible = true;
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const PaywallScreen()))
          .whenComplete(() {
        if (mounted) {
          setState(() {
            _paywallVisible = false;
          });
        }
      });
    }
  }

  FocusPreset _findPreset(String id) {
    return widget.presetsController.presets
        .firstWhere((preset) => preset.id == id);
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.focusedMinutes,
    required this.sessionsToday,
    required this.currentStreak,
    required this.title,
    required this.sessionsLabel,
    required this.streakLabel,
    required this.daysLabel,
    this.backgroundImage,
    this.backgroundScale = const Offset(1, 1),
    this.onTap,
  });

  final int focusedMinutes;
  final int sessionsToday;
  final int currentStreak;
  final String title;
  final String sessionsLabel;
  final String streakLabel;
  final String daysLabel;
  final String? backgroundImage;
  final Offset backgroundScale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF4B55C9),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4B55C9), Color(0xFF6C6DDA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 12,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (backgroundImage != null)
                Positioned.fill(
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.diagonal3Values(
                      backgroundScale.dx,
                      backgroundScale.dy,
                      1,
                    ),
                    child: Image.asset(
                      backgroundImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$focusedMinutes ${AppLocalizations.of(context).t('minutes_short')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 1,
                      width: 220,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$sessionsLabel: $sessionsToday',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        if (currentStreak > 0) ...[
                          const SizedBox(width: 10),
                          Text(
                            '🔥 $streakLabel: $currentStreak $daysLabel',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedCard extends StatelessWidget {
  const _LockedCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.backgroundImage,
    this.backgroundScale = const Offset(1, 1),
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? backgroundImage;
  final Offset backgroundScale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2E2F4C),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E2F4C), Color(0xFF3C3F66)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (backgroundImage != null)
                Positioned.fill(
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.diagonal3Values(
                      backgroundScale.dx,
                      backgroundScale.dy,
                      1,
                    ),
                    child: Image.asset(
                      backgroundImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style:
                                const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white70),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.title,
    required this.text,
    this.backgroundImage,
    this.backgroundScale = const Offset(1, 1),
  });

  final String title;
  final String text;
  final String? backgroundImage;
  final Offset backgroundScale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: Ink(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            if (backgroundImage != null)
              Positioned.fill(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(
                    backgroundScale.dx,
                    backgroundScale.dy,
                    1,
                  ),
                  child: Image.asset(
                    backgroundImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEDEEFE),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Color(0xFF6C6DDA)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(text, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
