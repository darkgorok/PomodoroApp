import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';
import 'features/focus/controller/stats_controller.dart';
import 'features/focus/controller/presets_controller.dart';
import 'features/focus/ui/home_screen.dart';
import 'features/reminders/reminder_controller.dart';
import 'features/settings/locale_controller.dart';
import 'features/settings/theme_controller.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.stats,
    required this.localeController,
    required this.reminderController,
    required this.presetsController,
    required this.themeController,
  });

  final StatsController stats;
  final LocaleController localeController;
  final ReminderController reminderController;
  final PresetsController presetsController;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    const fontFamily = 'NotoSans';
    final base = ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      platform: TargetPlatform.iOS,
      typography: Typography.material2018(platform: TargetPlatform.iOS),
      fontFamily: fontFamily,
    );

    final darkBase = ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      platform: TargetPlatform.iOS,
      typography: Typography.material2018(platform: TargetPlatform.iOS),
      fontFamily: fontFamily,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([localeController, themeController]),
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
          themeMode: themeController.mode,
          theme: base.copyWith(
            colorScheme: base.colorScheme.copyWith(
              primary: const Color(0xFF4B55C9),
              secondary: const Color(0xFF9A7BFF),
              surface: const Color(0xFFF6F7FB),
              onSurface: const Color(0xFF1E2138),
            ),
            scaffoldBackgroundColor: const Color(0xFFF3F4FA),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4B55C9),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4B55C9),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            appBarTheme: AppBarTheme(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: 44,
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
          darkTheme: darkBase.copyWith(
            colorScheme: darkBase.colorScheme.copyWith(
              primary: const Color(0xFF4B55C9),
              secondary: const Color(0xFF9A7BFF),
              surface: const Color(0xFF1A1B2E),
              onSurface: const Color(0xFFF2F3FF),
            ),
            scaffoldBackgroundColor: const Color(0xFF111221),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4B55C9),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4B55C9),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            appBarTheme: AppBarTheme(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: 44,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: fontFamily,
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            textTheme: darkBase.textTheme.copyWith(
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
          home: HomeScreen(
            stats: stats,
            localeController: localeController,
            reminderController: reminderController,
            presetsController: presetsController,
            themeController: themeController,
          ),
        );
      },
    );
  }
}
