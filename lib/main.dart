import 'package:flutter/material.dart';
import 'app.dart';
import 'core/storage/prefs.dart';
import 'features/focus/controller/stats_controller.dart';
import 'features/focus/controller/presets_controller.dart';
import 'features/focus/data/presets_repository.dart';
import 'features/reminders/reminder_controller.dart';
import 'features/reminders/reminder_repository.dart';
import 'features/settings/locale_controller.dart';
import 'features/settings/theme_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();

  final stats = StatsController();
  await stats.init();

  final localeController = LocaleController();
  await localeController.init();

  final themeController = ThemeController();
  await themeController.init();

  final presetsRepo = PresetsRepository();
  final presetsController = PresetsController(repo: presetsRepo, stats: stats);
  await presetsController.init();

  final notifications = FlutterLocalNotificationsPlugin();
  final reminderRepo = ReminderRepository(notifications);
  try {
    await reminderRepo.init().timeout(const Duration(seconds: 2));
  } catch (_) {
    // If notifications init fails, app should still start.
  }

  final reminderController = ReminderController(
    repo: reminderRepo,
    stats: stats,
  );
  await reminderController.init();

  runApp(App(
    stats: stats,
    localeController: localeController,
    reminderController: reminderController,
    presetsController: presetsController,
    themeController: themeController,
  ));
}
