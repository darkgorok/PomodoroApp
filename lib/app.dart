import 'package:flutter/material.dart';
import 'features/focus/controller/stats_controller.dart';
import 'features/focus/ui/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key, required this.stats});

  final StatsController stats;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Timer',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D32),
        useMaterial3: true,
      ),
      home: HomeScreen(stats: stats),
    );
  }
}
