import 'package:flutter/material.dart';

import '../../../core/time/duration_ext.dart';
import '../components/primary_button.dart';
import '../components/progress_ring.dart';
import '../controller/stats_controller.dart';
import '../controller/timer_controller.dart';
import '../model/presets.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E315B), Color(0xFF4A3E8A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TimerAppBar(title: widget.preset.title),
              Expanded(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final progress = _controller.segmentSeconds == 0
                        ? 0.0
                        : _controller.remainingSeconds / _controller.segmentSeconds;
                    final statusText = _controller.isBreak ? 'Break' : 'Focus';

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
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
                                const Text(
                                  'Ready when you are.',
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: _controller.isRunning ? 'End' : 'Start',
                          onPressed:
                              _controller.isRunning ? _endSession : _controller.start,
                          icon: _controller.isRunning
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          height: 46,
                        ),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
            ],
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
          title: const Text('Nice. Want to go again?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Back Home'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Start Again'),
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
    Navigator.of(context).pop();
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
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
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
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
