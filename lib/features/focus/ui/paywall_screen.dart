import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/ui/back_swipe.dart';
import '../components/primary_button.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: BackSwipe(
        onBack: () => Navigator.of(context).maybePop(),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/AppBackground.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    children: [
                      const SizedBox(height: 8),
                      _GiftHero(),
                      const SizedBox(height: 20),
                      Text(
                        loc.t('paywall_title'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        loc.t('paywall_subtitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 18),
                      _PaywallPlanCard(
                        title: loc.t('weekly'),
                        price: loc.t('price_weekly'),
                        badge: loc.t('most_popular'),
                        highlighted: true,
                      ),
                      const SizedBox(height: 12),
                      _PaywallPlanCard(
                        title: loc.t('yearly'),
                        price: loc.t('price_yearly'),
                        badge: loc.t('save_50'),
                        highlighted: false,
                      ),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: loc.t('start_free_trial'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.t('trial_caption'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              loc.t('restore_purchase'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              loc.t('privacy_policy'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
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
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E315B), Color(0xFF4A3E8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            right: 28,
            child: _Sparkle(),
          ),
          Positioned(
            bottom: 22,
            left: 24,
            child: _Sparkle(),
          ),
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C5BD5).withOpacity(0.9),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.card_giftcard, color: Colors.white, size: 48),
            ),
          ),
        ],
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
    required this.highlighted,
  });

  final String title;
  final String price;
  final String badge;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final border = highlighted ? const Color(0xFF8C7DFF) : Colors.transparent;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.2),
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
