import 'package:flutter/material.dart';

import '../components/primary_button.dart';
import '../components/session_card.dart';
import '../controller/stats_controller.dart';
import '../model/presets.dart';
import 'paywall_screen.dart';
import 'timer_screen.dart';
import 'upgrade_screen.dart';

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
        title: const Text('Start Now'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.stats,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _SummaryCard(
                focusedMinutes: widget.stats.todayFocusedMinutes,
                sessionsCompleted: widget.stats.completedSessionsTotal,
              ),
              const SizedBox(height: 16),
              SessionCard(
                title: FocusPreset.startNow.title,
                subtitle: 'Anti-procrastination',
                icon: Icons.play_arrow_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B68FF), Color(0xFF8FA0FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                backgroundImage: 'assets/ButtonBackground.png',
                backgroundScale: const Offset(1.1, 1),
                onTap: () => _openTimer(FocusPreset.startNow),
              ),
              const SizedBox(height: 12),
              SessionCard(
                title: FocusPreset.pomodoro.title,
                subtitle: 'Focus + break',
                icon: Icons.timer_outlined,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8A7A), Color(0xFFFFB08A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                backgroundImage: 'assets/PomodoroBtnBackground.png',
                backgroundScale: const Offset(1.1, 1),
                onTap: () => _openTimer(FocusPreset.pomodoro),
              ),
              const SizedBox(height: 12),
              _LockedCard(
                title: 'Customize',
                subtitle: 'Presets & white noise',
                onTap: _openUpgrade,
              ),
              const SizedBox(height: 16),
              _TipCard(
                title: 'Small rule',
                text: "If you can't start, do 5 minutes. Starting is the win.",
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: PrimaryButton(
          label: 'Customize (Premium)',
          onPressed: _openUpgrade,
          isOutlined: true,
        ),
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

  void _openUpgrade() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UpgradeScreen()),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.focusedMinutes,
    required this.sessionsCompleted,
  });

  final int focusedMinutes;
  final int sessionsCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF4B55C9), Color(0xFF6C6DDA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today focused',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$focusedMinutes min',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Sessions completed: $sessionsCompleted',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LockedCard extends StatelessWidget {
  const _LockedCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF2E2F4C), Color(0xFF3C3F66)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
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
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
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
    );
  }
}
