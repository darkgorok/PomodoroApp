import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';
import 'features/focus/controller/stats_controller.dart';
import 'features/focus/ui/home_screen.dart';
import 'features/settings/locale_controller.dart';

class App extends StatelessWidget {
  const App({super.key, required this.stats, required this.localeController});

  final StatsController stats;
  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    const fontFamily = 'NotoSans';
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,
    );

    return AnimatedBuilder(
      animation: localeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Focus Timer',
          locale: localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: base.copyWith(
            colorScheme: base.colorScheme.copyWith(
              primary: const Color(0xFF4B55C9),
              secondary: const Color(0xFF9A7BFF),
              surface: const Color(0xFFF6F7FB),
              onSurface: const Color(0xFF1E2138),
            ),
            scaffoldBackgroundColor: const Color(0xFFF3F4FA),
            appBarTheme: AppBarTheme(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E2138),
                fontFamily: fontFamily,
              ),
              iconTheme: IconThemeData(color: Color(0xFF1E2138)),
            ),
            textTheme: base.textTheme.copyWith(
              headlineMedium: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E2138),
              ),
              titleLarge: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E2138),
              ),
              titleMedium: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E2138),
              ),
              bodyLarge: const TextStyle(
                fontSize: 15,
                color: Color(0xFF4B4E6D),
              ),
              bodyMedium: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B6F8C),
              ),
            ),
          ),
          home: HomeScreen(stats: stats, localeController: localeController),
        );
      },
    );
  }
}
