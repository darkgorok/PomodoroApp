import 'package:flutter/material.dart';

import '../components/primary_button.dart';
import '../components/session_card.dart';
import '../controller/stats_controller.dart';
import '../model/presets.dart';
import 'paywall_screen.dart';
import 'timer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.stats});

  final StatsController stats;

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
        title: const Text('Focus Timer'),
      ),
      body: AnimatedBuilder(
        animation: widget.stats,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SessionCard(
                  title: FocusPreset.startNow.title,
                  subtitle: FocusPreset.startNow.subtitle,
                  onTap: () => _openTimer(FocusPreset.startNow),
                ),
                const SizedBox(height: 12),
                SessionCard(
                  title: FocusPreset.pomodoro.title,
                  subtitle: FocusPreset.pomodoro.subtitle,
                  onTap: () => _openTimer(FocusPreset.pomodoro),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Customize (Locked)',
                  onPressed: _openPaywall,
                  isOutlined: true,
                ),
                const Spacer(),
                Text(
                  'Today focused: ${widget.stats.todayFocusedMinutes} min',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openTimer(FocusPreset preset) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TimerScreen(
          preset: preset,
          stats: widget.stats,
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
}
