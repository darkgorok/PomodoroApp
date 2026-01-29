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
              CupertinoFormSection.insetGrouped(
                backgroundColor: Colors.transparent,
                margin: EdgeInsets.zero,
                children: [
                  CupertinoFormRow(
                    prefix: Text(loc.t('language')),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showLanguageSheet(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _languageLabel(
                              localeController.locale?.languageCode ?? 'en',
                            ),
                            style: const TextStyle(
                              color: CupertinoColors.activeBlue,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            CupertinoIcons.chevron_right,
                            size: 16,
                            color: CupertinoColors.systemGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (kDebugMode)
                CupertinoFormSection.insetGrouped(
                  backgroundColor: Colors.transparent,
                  margin: const EdgeInsets.only(top: 8),
                  children: [
                    CupertinoFormRow(
                      prefix: Text(loc.t('debug_premium')),
                      child: AnimatedBuilder(
                        animation: stats,
                        builder: (context, _) {
                          return CupertinoSwitch(
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
                ),
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
