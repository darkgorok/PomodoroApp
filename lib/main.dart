import 'package:flutter/material.dart';
import 'app.dart';
import 'core/storage/prefs.dart';
import 'features/focus/controller/stats_controller.dart';
import 'features/settings/locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  final stats = StatsController();
  await stats.init();
  final localeController = LocaleController();
  await localeController.init();
  runApp(App(stats: stats, localeController: localeController));
}
