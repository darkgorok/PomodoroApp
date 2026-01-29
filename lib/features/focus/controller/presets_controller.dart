import 'package:flutter/foundation.dart';

import '../data/presets_repository.dart';
import '../model/presets.dart';
import 'stats_controller.dart';

class PresetsController extends ChangeNotifier {
  PresetsController({required this.repo, required this.stats});

  final PresetsRepository repo;
  final StatsController stats;

  List<FocusPreset> _presets = [];
  FocusPreset? _selected;

  List<FocusPreset> get presets => List.unmodifiable(_presets);
  FocusPreset get selectedPreset =>
      _selected ?? _presets.firstWhere((p) => p.id == FocusPreset.idStartNow);

  bool get isPremium => stats.isPremiumCached;

  Future<void> init() async {
    _presets = [...repo.getBuiltInPresets(), ...repo.getUserPresets()];
    final lastId = repo.getLastSelectedPresetId();
    _selected = _presets
        .cast<FocusPreset?>()
        .firstWhere((p) => p?.id == lastId, orElse: () => null);
    _selected ??= _presets.firstWhere((p) => p.id == FocusPreset.idStartNow);
    stats.addListener(_handleStatsUpdate);
    notifyListeners();
  }

  void _handleStatsUpdate() {
    notifyListeners();
  }

  bool isLocked(FocusPreset preset) {
    return preset.isPremium && !isPremium;
  }

  Future<void> selectPreset(FocusPreset preset) async {
    _selected = preset;
    await repo.setLastSelectedPresetId(preset.id);
    notifyListeners();
  }

  Future<void> refresh() async {
    _presets = [...repo.getBuiltInPresets(), ...repo.getUserPresets()];
    if (_selected != null) {
      _selected = _presets
          .cast<FocusPreset?>()
          .firstWhere((p) => p?.id == _selected!.id, orElse: () => null);
    }
    _selected ??= _presets.firstWhere((p) => p.id == FocusPreset.idStartNow);
    notifyListeners();
  }

  Future<void> createPreset(FocusPreset preset) async {
    await repo.addPreset(preset);
    await refresh();
    await selectPreset(preset);
  }

  Future<void> updatePreset(FocusPreset preset) async {
    await repo.updatePreset(preset);
    await refresh();
    await selectPreset(preset);
  }

  Future<void> deletePreset(String id) async {
    await repo.deletePreset(id);
    await refresh();
    if (_selected?.id == id) {
      await selectPreset(_presets.firstWhere((p) => p.id == FocusPreset.idStartNow));
    }
  }

  @override
  void dispose() {
    stats.removeListener(_handleStatsUpdate);
    super.dispose();
  }
}
