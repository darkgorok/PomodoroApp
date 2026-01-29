import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/time/duration_ext.dart';
import '../../../core/ui/back_swipe.dart';
import '../components/primary_button.dart';
import '../components/progress_ring.dart';
import '../controller/stats_controller.dart';
import '../controller/timer_controller.dart';
import '../model/presets.dart';
import '../model/session_state.dart';
import 'paywall_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key, required this.preset, required this.stats});

  final FocusPreset preset;
  final StatsController stats;

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late final TimerController _controller;
  bool _dialogVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = TimerController(
      preset: widget.preset,
      stats: widget.stats,
      onSessionComplete: _handleSessionComplete,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                _TimerAppBar(title: _titleForPreset(context)),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final progress = _controller.segmentSeconds == 0
                          ? 0.0
                          : _controller.remainingSeconds / _controller.segmentSeconds;
                      final statusText = _controller.isBreak
                          ? AppLocalizations.of(context).t('break')
                          : AppLocalizations.of(context).t('focus');

                      return Column(
                        children: [
                          const SizedBox(height: 28),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusText,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                              ),
                            ),
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
                                  return ProgressRing(progress: value, size: 260);
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
                          const SizedBox(height: 32),
                          const Spacer(),
                        ],
                      );
                    },
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      child: PrimaryButton(
                        label: _controller.isRunning
                            ? AppLocalizations.of(context).t('end')
                            : AppLocalizations.of(context).t('start'),
                        onPressed:
                            _controller.isRunning ? _endSession : _controller.start,
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

  Future<void> _handleSessionComplete() async {
    if (_dialogVisible) return;
    _dialogVisible = true;

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
  }

  String _titleForPreset(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return widget.preset.mode == SessionMode.pomodoro
        ? loc.t('pomodoro')
        : loc.t('start_now');
  }
}

class _TimerAppBar extends StatelessWidget {
  const _TimerAppBar({required this.title});

  final String title;

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
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
