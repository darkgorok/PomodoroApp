import 'package:flutter/material.dart';
import '../../core/storage/prefs.dart';
import '../../core/localization/app_localizations.dart';

class LocaleController extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> init() async {
    final stored = Prefs.getLanguageCode();
    if (stored != null && stored.isNotEmpty) {
      _locale = Locale(stored);
      return;
    }
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final supported = AppLocalizations.supportedLocales.firstWhere(
      (loc) => loc.languageCode == systemLocale.languageCode,
      orElse: () => const Locale('en'),
    );
    _locale = supported;
    await Prefs.setLanguageCode(_locale!.languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await Prefs.setLanguageCode(locale.languageCode);
    notifyListeners();
  }
}
