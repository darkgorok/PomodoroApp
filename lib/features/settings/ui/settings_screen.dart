import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/ui/back_swipe.dart';
import '../locale_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.localeController});

  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('settings')),
      ),
      body: BackSwipe(
        onBack: () => Navigator.of(context).maybePop(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              loc.t('language'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: localeController.locale?.languageCode,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: AppLocalizations.supportedLocales.map((locale) {
                final code = locale.languageCode;
                return DropdownMenuItem<String>(
                  value: code,
                  child: Text(_languageLabel(code)),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                localeController.setLocale(Locale(value));
              },
            ),
          ],
        ),
      ),
    );
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'ru':
        return 'Русский';
      case 'uk':
        return 'Українська';
      default:
        return 'English';
    }
  }
}
