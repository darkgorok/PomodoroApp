import 'package:flutter/material.dart';

import '../components/primary_button.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unlock Deep Focus'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Unlock Deep Focus',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const _Bullet(text: 'Custom timers'),
            const _Bullet(text: 'Focus stats & streaks'),
            const _Bullet(text: 'White noise'),
            const _Bullet(text: 'Smart reminders'),
            const Spacer(),
            PrimaryButton(
              label: 'Continue',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Not now',
              onPressed: () => Navigator.of(context).pop(),
              isOutlined: true,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Restore'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 18),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
