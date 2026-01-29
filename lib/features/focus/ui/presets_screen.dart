import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/ui/back_swipe.dart';
import '../components/preset_tile.dart';
import '../controller/presets_controller.dart';
import '../controller/stats_controller.dart';
import '../model/presets.dart';
import 'edit_preset_screen.dart';
import 'paywall_screen.dart';
import 'timer_screen.dart';
import '../../reminders/reminder_controller.dart';

class PresetsScreen extends StatelessWidget {
  const PresetsScreen({
    super.key,
    required this.presetsController,
    required this.stats,
    required this.reminderController,
  });

  final PresetsController presetsController;
  final StatsController stats;
  final ReminderController reminderController;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('presets')),
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
          child: AnimatedBuilder(
            animation: Listenable.merge([presetsController, stats]),
            builder: (context, _) {
              final allPresets = presetsController.presets;
              final free = allPresets
                  .where((p) => !p.isPremium)
                  .toList(growable: false);
              final premium = allPresets
                  .where((p) => p.isPremium)
                  .toList(growable: false);

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _SectionLabel(title: loc.t('free')),
                  ...free.map((preset) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PresetTile(
                          title: preset.displayName(loc),
                          subtitle: preset.displaySubtitle(loc),
                          locked: false,
                          onTap: () => _openPreset(context, preset),
                        ),
                      )),
                  const SizedBox(height: 4),
                  _SectionLabel(title: loc.t('premium')),
                  ...premium.map((preset) {
                    final locked = presetsController.isLocked(preset);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PresetTile(
                        title: preset.displayName(loc),
                        subtitle: preset.displaySubtitle(loc),
                        locked: locked,
                        onTap: () => locked
                            ? _openPaywall(context)
                            : _openPreset(context, preset),
                        onLongPress: (!locked && !preset.isBuiltIn)
                            ? () => _openEditPreset(context, preset)
                            : null,
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                  CupertinoButton(
                    onPressed: stats.isPremiumCached
                        ? () => _openCreatePreset(context)
                        : () => _openPaywall(context),
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(loc.t('create_preset')),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _openPreset(BuildContext context, FocusPreset preset) {
    presetsController.selectPreset(preset);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TimerScreen(
          preset: preset,
          stats: stats,
          reminderController: reminderController,
          presetsController: presetsController,
        ),
      ),
    );
  }

  void _openCreatePreset(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditPresetScreen(
          presetsController: presetsController,
        ),
      ),
    );
  }

  void _openEditPreset(BuildContext context, FocusPreset preset) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditPresetScreen(
          presetsController: presetsController,
          preset: preset,
        ),
      ),
    );
  }

  void _openPaywall(BuildContext context) {
    stats.markPaywallShown();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
