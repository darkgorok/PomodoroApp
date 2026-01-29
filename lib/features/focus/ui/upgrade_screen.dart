import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/ui/back_swipe.dart';
import '../components/primary_button.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('upgrade')),
      ),
      body: BackSwipe(
        onBack: () => Navigator.of(context).maybePop(),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/AppBackground.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF3D4BC8), Color(0xFF7C6EE6)],
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
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x33FFFFFF),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).t('unlock_deep_focus'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context).t('upgrade_subtitle'),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PerkTile(
            icon: Icons.tune,
            title: AppLocalizations.of(context).t('custom_timers'),
            subtitle: AppLocalizations.of(context).t('custom_timers_subtitle'),
            color: const Color(0xFF5B68FF),
          ),
          const SizedBox(height: 12),
          _PerkTile(
            icon: Icons.bar_chart,
            title: AppLocalizations.of(context).t('stats_streaks'),
            subtitle: AppLocalizations.of(context).t('stats_streaks_subtitle'),
            color: const Color(0xFFFF8A7A),
          ),
          const SizedBox(height: 12),
          _PerkTile(
            icon: Icons.graphic_eq,
            title: AppLocalizations.of(context).t('white_noise'),
            subtitle: AppLocalizations.of(context).t('white_noise_subtitle'),
            color: const Color(0xFF58C3A5),
          ),
          const SizedBox(height: 12),
          _PerkTile(
            icon: Icons.notifications_active,
            title: AppLocalizations.of(context).t('smart_reminders'),
            subtitle: AppLocalizations.of(context).t('smart_reminders_subtitle'),
            color: const Color(0xFF8C6BFF),
          ),
          const SizedBox(height: 18),
          _PlanCard(
            title: AppLocalizations.of(context).t('weekly'),
            price: AppLocalizations.of(context).t('price_weekly'),
            badge: AppLocalizations.of(context).t('most_popular'),
            icon: Icons.bolt,
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: AppLocalizations.of(context).t('yearly'),
            price: AppLocalizations.of(context).t('price_yearly'),
            badge: AppLocalizations.of(context).t('best_value'),
            icon: Icons.stars,
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: AppLocalizations.of(context).t('continue'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: AppLocalizations.of(context).t('not_now'),
            onPressed: () => Navigator.of(context).pop(),
            isOutlined: true,
          ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerkTile extends StatelessWidget {
  const _PerkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.badge,
    required this.icon,
  });

  final String title;
  final String price;
  final String badge;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0F1FE),
            ),
            child: Icon(icon, color: const Color(0xFF5B68FF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(price, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Color(0xFF5B68FF),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




