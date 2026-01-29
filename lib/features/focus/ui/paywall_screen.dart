import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/ui/back_swipe.dart';
import '../../../core/ui/app_background.dart';
import '../../../core/storage/prefs.dart';
import '../components/primary_button.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _monthlySelected = true;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF4B55C9);
    final secondaryColor = isDark ? Colors.white : const Color(0xFF8B8FA8);
    final showTrial = !Prefs.getTrialUsed();
    return Scaffold(
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
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        top: -100,
                        left: 0,
                        right: 0,
                        child: _GiftHero(),
                      ),
                      ListView(
                        padding: const EdgeInsets.fromLTRB(20, 220, 20, 20),
                        children: [
                          Text(
                            loc.t('paywall_title'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            loc.t('paywall_subtitle'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _PaywallPlanCard(
                            title: loc.t('weekly'),
                            price: loc.t('price_weekly'),
                            badge: loc.t('most_popular'),
                            selected: _monthlySelected,
                            onTap: () => setState(() => _monthlySelected = true),
                          ),
                          const SizedBox(height: 12),
                          _PaywallPlanCard(
                            title: loc.t('yearly'),
                            price: loc.t('price_yearly'),
                            badge: '',
                            selected: !_monthlySelected,
                            onTap: () => setState(() => _monthlySelected = false),
                          ),
                          const SizedBox(height: 18),
                          PrimaryButton(
                            label: loc.t('start_free_trial'),
                            onPressed: () async {
                              await Prefs.setTrialUsed(true);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          if (showTrial)
                            Text(
                              _monthlySelected
                                  ? loc.t('trial_caption_monthly')
                                  : loc.t('trial_caption_yearly'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 11,
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  loc.t('restore_purchase'),
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  loc.t('privacy_policy'),
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GiftHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/GiftIcon.png',
        width: 400,
        height: 400,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.star, color: Colors.white, size: 14),
    );
  }
}

class _PaywallPlanCard extends StatelessWidget {
  const _PaywallPlanCard({
    required this.title,
    required this.price,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String price;
  final String badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = selected ? const Color(0xFFFF8A7A) : Colors.transparent;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 2.2),
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
                child: const Icon(Icons.bolt, color: Color(0xFF6C6DDA), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E2138),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B6F8C),
                      ),
                    ),
                  ],
                ),
              ),
              if (badge.isNotEmpty)
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
        ),
      ),
    );
  }
}
