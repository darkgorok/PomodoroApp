import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/ui/back_swipe.dart';
import '../../focus/controller/stats_controller.dart';
import '../../reminders/reminder_controller.dart';
import '../locale_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.localeController,
    required this.stats,
    required this.reminderController,
  });

  final LocaleController localeController;
  final StatsController stats;
  final ReminderController reminderController;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('settings')),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _SettingsCard(
                child: _SettingsRow(
                  title: loc.t('language'),
                  value: _languageLabel(
                    localeController.locale?.languageCode ?? 'en',
                  ),
                  onTap: () => _showLanguageSheet(context),
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 12),
                _SettingsCard(
                  child: AnimatedBuilder(
                    animation: stats,
                    builder: (context, _) {
                      return _SettingsSwitchRow(
                        title: loc.t('debug_premium'),
                        value: stats.isPremiumCached,
                        onChanged: (value) async {
                          await stats.setPremiumCached(value);
                          await reminderController.scheduleAll();
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(AppLocalizations.of(context).t('language')),
          actions: AppLocalizations.supportedLocales.map((locale) {
            final code = locale.languageCode;
            return CupertinoActionSheetAction(
              onPressed: () {
                localeController.setLocale(Locale(code));
                Navigator.of(context).pop();
              },
              child: Text(_languageLabel(code)),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).t('cancel')),
          ),
        );
      },
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

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: Ink(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF4B55C9),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Color(0xFF9AA0C8),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
