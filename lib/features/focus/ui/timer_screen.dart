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
      appBar: AppBar(
        title: Text(widget.preset.title),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = _controller.segmentSeconds == 0
              ? 0.0
              : _controller.remainingSeconds / _controller.segmentSeconds;
          final statusText = _controller.isBreak ? 'Break' : 'Focus';

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                ProgressRing(progress: progress),
                const SizedBox(height: 24),
                Text(
                  _controller.remainingSeconds.toMinutesSeconds(),
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                PrimaryButton(
                  label: _controller.isRunning ? 'Pause' : 'Start',
                  onPressed:
                      _controller.isRunning ? _controller.pause : _controller.start,
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'End Session',
                  onPressed: _endSession,
                  isOutlined: true,
                ),
              ],
            ),
          );
        },
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
