import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/time/duration_ext.dart';
import '../../../core/ui/back_swipe.dart';
import '../components/primary_button.dart';
import '../components/progress_ring.dart';
import '../controller/presets_controller.dart';
import '../controller/stats_controller.dart';
import '../controller/timer_controller.dart';
import '../model/presets.dart';
import '../sound/white_noise_controller.dart';
import '../../reminders/reminder_controller.dart';
import '../../reminders/reminder_settings_screen.dart';
import 'edit_preset_screen.dart';
import 'paywall_screen.dart';
import 'upgrade_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({
    super.key,
    required this.preset,
    required this.stats,
    required this.reminderController,
    required this.presetsController,
  });

  final FocusPreset preset;
  final StatsController stats;
  final ReminderController reminderController;
  final PresetsController presetsController;

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with WidgetsBindingObserver {
  late final TimerController _controller;
  late final WhiteNoiseController _noise;
  bool _dialogVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _noise = WhiteNoiseController();
    _noise.loadPrefs();
    _controller = TimerController(
      preset: widget.preset,
      stats: widget.stats,
      onSessionComplete: _handleSessionComplete,
      onFocusStart: _noise.handleFocusStart,
      onFocusEnd: _noise.handleFocusEnd,
      onBreakStart: _noise.handleFocusEnd,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _noise.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _noise.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackSwipe(
        onBack: () => Navigator.of(context).maybePop(),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/AppBackgroundDark.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _TimerAppBar(
                  title: _titleForPreset(context),
                  onBellTap: () => _openReminders(context),
                ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final progress = _controller.segmentSeconds == 0
                          ? 0.0
                          : (_controller.remainingSeconds / _controller.segmentSeconds);
                      final statusText = _controller.isBreak
                          ? AppLocalizations.of(context).t('break')
                          : AppLocalizations.of(context).t('focus');

                      return Column(
                        children: [
                          const SizedBox(height: 28),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _PresetPill(
                                label:
                                    '${AppLocalizations.of(context).t('preset')}: ${_controller.preset.displayName(AppLocalizations.of(context))}',
                                onTap: () => _openPresetSelector(context),
                              ),
                              const SizedBox(height: 8),
                              _SoundButton(
                                isPremium: widget.stats.isPremiumCached,
                                label: AppLocalizations.of(context).t('sound_button'),
                                onTap: () => _openSoundPicker(context),
                              ),
                              const SizedBox(height: 8),
                              _StatusPill(text: statusText),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(end: progress),
                                duration: const Duration(seconds: 1),
                                curve: Curves.linear,
                                builder: (context, value, child) {
                                  return ProgressRing(progress: value, size: 300);
                                },
                              ),
                              Column(
                                children: [
                                  Text(
                                    _controller.remainingSeconds.toMinutesSeconds(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 46,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    AppLocalizations.of(context).t('ready_when'),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Spacer(),
                        ],
                      );
                    },
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: widget.stats.isPremiumCached
                                ? _openCustomize
                                : () => _openUpgrade(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!widget.stats.isPremiumCached) ...[
                                  const Icon(
                                    CupertinoIcons.lock_fill,
                                    size: 16,
                                    color: Color(0xFFC2C4E6),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  AppLocalizations.of(context).t('customize_timer'),
                                  style: TextStyle(
                                    color: widget.stats.isPremiumCached
                                        ? const Color(0xFFF5F6FF)
                                        : const Color(0xFFC2C4E6),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                          child: PrimaryButton(
                            label: _controller.isRunning
                                ? AppLocalizations.of(context).t('end')
                                : AppLocalizations.of(context).t('start'),
                            onPressed: _controller.isRunning
                                ? _endSession
                                : _controller.start,
                            icon: _controller.isRunning
                                ? Icons.stop_rounded
                                : Icons.play_arrow_rounded,
                            height: 64,
                            fontSize: 24,
                            iconSize: 24,
                            fullWidth: true,
                            backgroundImage: 'assets/ButtonBackgroundDarkBlue.png',
                            backgroundScale: const Offset(1.1, 1),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSoundPicker(BuildContext context) async {
    if (!widget.stats.isPremiumCached) {
      _openPaywall(context);
      return;
    }

    final loc = AppLocalizations.of(context);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AnimatedBuilder(
          animation: _noise,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.t('focus_sounds'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...WhiteNoiseController.sounds.map((sound) {
                    final selected = _noise.selectedSoundId == sound.id;
                    return _SoundTile(
                      title: _soundTitle(loc, sound.id),
                      selected: selected,
                      playing: selected && _noise.isPlaying,
                      onTap: () => _noise.play(sound.id),
                    );
                  }).toList(),
                  const SizedBox(height: 12),
                  Text(loc.t('volume'),
                      style: Theme.of(context).textTheme.bodyMedium),
                  Slider(
                    value: _noise.volume,
                    min: 0,
                    max: 1,
                    onChanged: (value) => _noise.setVolume(value),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(loc.t('auto_play'),
                          style: Theme.of(context).textTheme.bodyMedium),
                      Switch(
                        value: _noise.autoPlay,
                        onChanged: (value) => _noise.setAutoPlay(value),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openPresetSelector(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AnimatedBuilder(
          animation: widget.presetsController,
          builder: (context, _) {
            final presets = widget.presetsController.presets;
            return SafeArea(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                shrinkWrap: true,
                itemCount: presets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final preset = presets[index];
                  final locked = widget.presetsController.isLocked(preset);
                  final selected = preset.id == _controller.preset.id;
                  return ListTile(
                    tileColor: selected ? const Color(0xFFF1F2FD) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(preset.displayName(loc)),
                    subtitle: Text(preset.displaySubtitle(loc)),
                    trailing: locked
                        ? const Icon(CupertinoIcons.lock_fill,
                            size: 18, color: Color(0xFF9AA0C8))
                        : selected
                            ? const Icon(CupertinoIcons.check_mark_circled_solid,
                                color: Color(0xFF4B55C9))
                            : const Icon(CupertinoIcons.chevron_right,
                                color: Color(0xFF9AA0C8)),
                    onTap: () async {
                      if (locked) {
                        _openPaywall(context);
                        return;
                      }
                      if (_controller.isRunning) {
                        final shouldReset = await _confirmPresetReset(context);
                        if (!shouldReset) return;
                      }
                      await _applyPreset(preset);
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _confirmPresetReset(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(loc.t('change_preset_title')),
          content: Text(loc.t('change_preset_body')),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(loc.t('cancel')),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(loc.t('reset')),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _applyPreset(FocusPreset preset) async {
    await widget.presetsController.selectPreset(preset);
    _controller.applyPreset(preset);
  }

  void _openReminders(BuildContext context) {
    if (!widget.stats.isPremiumCached) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UpgradeScreen()),
      );
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

  String _soundTitle(AppLocalizations loc, String id) {
    switch (id) {
      case 'rain':
        return loc.t('sound_rain');
      case 'ocean':
        return loc.t('sound_ocean');
      case 'forest':
        return loc.t('sound_forest');
      case 'fire':
        return loc.t('sound_fire');
      default:
        return loc.t('sound_white');
    }
  }

  Future<void> _openCustomize() async {
    if (!widget.stats.isPremiumCached) {
      _openPaywall(context);
      return;
    }
    final loc = AppLocalizations.of(context);
    final preset = _controller.preset.copyWith(
      name: _controller.preset.displayName(loc),
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditPresetScreen(
          presetsController: widget.presetsController,
          preset: preset,
          createFromPreset: preset.isBuiltIn,
        ),
      ),
    );
    if (!mounted) return;
    final updated = widget.presetsController.selectedPreset;
    if (updated.id != _controller.preset.id ||
        updated.focusSeconds != _controller.focusSeconds ||
        updated.breakSeconds != _controller.breakSeconds ||
        updated.name != _controller.preset.name) {
      _controller.applyPreset(updated);
    }
  }

  void _openPaywall(BuildContext context) {
    widget.stats.markPaywallShown();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
  }

  void _openUpgrade(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UpgradeScreen()),
    );
  }

  Future<void> _handleSessionComplete() async {
    if (_dialogVisible) return;
    _dialogVisible = true;

    await widget.reminderController.rescheduleOnSession();

    if (widget.stats.shouldShowPaywallAndMark()) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
    }

    final startAgain = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).t('nice_again')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context).t('back_home')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context).t('start_again')),
            ),
          ],
        );
      },
    );

    _dialogVisible = false;

    if (startAgain == true) {
      _controller.restart();
    } else {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _endSession() {
    _controller.stop();
    _noise.stop();
  }

  String _titleForPreset(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return _controller.preset.displayName(loc);
  }
}

class _TimerAppBar extends StatelessWidget {
  const _TimerAppBar({required this.title, required this.onBellTap});

  final String title;
  final VoidCallback onBellTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(CupertinoIcons.back, color: Colors.white70),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: onBellTap,
            icon: const Icon(CupertinoIcons.bell, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
      ),
    );
  }
}

class _PresetPill extends StatelessWidget {
  const _PresetPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.slider_horizontal_3,
                color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              CupertinoIcons.chevron_down,
              size: 12,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundButton extends StatelessWidget {
  const _SoundButton({
    required this.isPremium,
    required this.onTap,
    required this.label,
  });

  final bool isPremium;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.headphones, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isPremium ? Colors.white70 : Colors.white38,
                fontSize: 12,
              ),
            ),
            if (!isPremium) ...[
              const SizedBox(width: 6),
              const Icon(CupertinoIcons.lock_fill,
                  color: Colors.white38, size: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _SoundTile extends StatelessWidget {
  const _SoundTile({
    required this.title,
    required this.selected,
    required this.playing,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEDEEFE) : const Color(0xFFF7F7FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF6F78E8) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              playing ? CupertinoIcons.equal : CupertinoIcons.music_note_2,
              size: 18,
              color: selected ? const Color(0xFF6F78E8) : const Color(0xFF6B6F8C),
            ),
            const SizedBox(width: 10),
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
