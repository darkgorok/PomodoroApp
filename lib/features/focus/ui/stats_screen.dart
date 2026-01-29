import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/ui/app_background.dart';
import '../../../core/ui/back_swipe.dart';
import '../controller/stats_controller.dart';
import '../data/stats_repository.dart';
import 'paywall_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.stats});

  final StatsController stats;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(loc.t('your_progress')),
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
              animation: stats,
              builder: (context, _) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                  _SectionTitle(title: loc.t('today_section')),
                  _Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _Metric(
                          label: loc.t('focused_label'),
                          value: '${stats.todayFocusedMinutes} ${loc.t('minutes_short')}',
                        ),
                        _Metric(
                          label: loc.t('sessions_label'),
                          value: stats.sessionsToday.toString(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: loc.t('streaks_section')),
                  _Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _Metric(
                          label: loc.t('current_streak'),
                          value: '${stats.currentStreak} ${loc.t('days_short')}',
                        ),
                        _Metric(
                          label: loc.t('best_streak'),
                          value: stats.isPremiumCached
                              ? '${stats.bestStreak} ${loc.t('days_short')}'
                              : '—',
                          locked: !stats.isPremiumCached,
                          onTap: stats.isPremiumCached
                              ? null
                              : () => _openPaywall(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: loc.t('weekly_overview')),
                  _PremiumBlock(
                    unlocked: stats.isPremiumCached,
                    lockLabel: loc.t('unlock_stats'),
                    onLockedTap: () => _openPaywall(context),
                    child: _WeeklyChart(data: stats.weeklyStats),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: loc.t('calendar_heatmap')),
                  _PremiumBlock(
                    unlocked: stats.isPremiumCached,
                    lockLabel: loc.t('premium_feature'),
                    onLockedTap: () => _openPaywall(context),
                    child: _CalendarHeatmap(data: stats.calendarStats),
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
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

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
      child: child,
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.locked = false,
    this.onTap,
  });

  final String label;
  final String value;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: locked ? const Color(0xFF9AA0C8) : null,
                  ),
            ),
            if (locked) ...[
              const SizedBox(width: 6),
              const Icon(Icons.lock_outline, size: 16, color: Color(0xFF9AA0C8)),
            ],
          ],
        ),
      ],
    );

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}

class _PremiumBlock extends StatelessWidget {
  const _PremiumBlock({
    required this.unlocked,
    required this.child,
    required this.onLockedTap,
    required this.lockLabel,
  });

  final bool unlocked;
  final Widget child;
  final VoidCallback onLockedTap;
  final String lockLabel;

  @override
  Widget build(BuildContext context) {
    if (unlocked) return child;
    return GestureDetector(
      onTap: onLockedTap,
      child: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: child,
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  lockLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.data});

  final List<DayFocusStat> data;

  @override
  Widget build(BuildContext context) {
    final maxMinutes = data.isEmpty
        ? 1
        : data.map((d) => d.focusedMinutes).reduce((a, b) => a > b ? a : b);

    return _Card(
      child: SizedBox(
        height: 140,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.map((day) {
            final height = maxMinutes == 0
                ? 4.0
                : (day.focusedMinutes / maxMinutes) * 80 + 4;
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: height,
                    width: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6F78E8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    day.date.substring(8, 10),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1E2138),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CalendarHeatmap extends StatelessWidget {
  const _CalendarHeatmap({required this.data});

  final List<DayFocusStat> data;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final minutes = data[index].focusedMinutes;
          return Container(
            decoration: BoxDecoration(
              color: _heatColor(minutes),
              borderRadius: BorderRadius.circular(6),
            ),
          );
        },
      ),
    );
  }

  Color _heatColor(int minutes) {
    if (minutes == 0) return const Color(0xFFE3E5F2);
    if (minutes < 15) return const Color(0xFFC7CBF4);
    if (minutes < 45) return const Color(0xFF9BA2F0);
    return const Color(0xFF6F78E8);
  }
}
