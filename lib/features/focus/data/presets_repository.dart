import 'dart:convert';

import '../../../core/storage/prefs.dart';
import '../model/presets.dart';

class PresetsRepository {
  static const String _userPresetsKey = 'user_presets';
  static const String _lastSelectedPresetKey = 'last_selected_preset_id';

  List<FocusPreset> getBuiltInPresets() {
    final hidden = Prefs.getHiddenBuiltInPresets().toSet();
    const presets = [
      FocusPreset(
        id: FocusPreset.idStartNow,
        name: 'Start Now',
        focusSeconds: 5 * 60,
        breakSeconds: 0,
        isBuiltIn: true,
        isPremium: false,
      ),
      FocusPreset(
        id: FocusPreset.idPomodoro,
        name: 'Pomodoro',
        focusSeconds: 25 * 60,
        breakSeconds: 5 * 60,
        isBuiltIn: true,
        isPremium: false,
      ),
      FocusPreset(
        id: FocusPreset.idDeepWork,
        name: 'Deep Work',
        focusSeconds: 50 * 60,
        breakSeconds: 10 * 60,
        isBuiltIn: true,
        isPremium: true,
      ),
      FocusPreset(
        id: FocusPreset.idStudy,
        name: 'Study',
        focusSeconds: 45 * 60,
        breakSeconds: 15 * 60,
        isBuiltIn: true,
        isPremium: true,
      ),
      FocusPreset(
        id: FocusPreset.idSprint,
        name: 'Sprint',
        focusSeconds: 15 * 60,
        breakSeconds: 5 * 60,
        isBuiltIn: true,
        isPremium: true,
      ),
      FocusPreset(
        id: FocusPreset.idLongFocus,
        name: 'Long Focus',
        focusSeconds: 90 * 60,
        breakSeconds: 20 * 60,
        isBuiltIn: true,
        isPremium: true,
      ),
    ];
    return presets.where((preset) => !hidden.contains(preset.id)).toList();
  }

  List<FocusPreset> getUserPresets() {
    final raw = Prefs.getString(_userPresetsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => FocusPreset.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveUserPresets(List<FocusPreset> presets) async {
    final encoded = jsonEncode(presets.map((p) => p.toJson()).toList());
    await Prefs.setString(_userPresetsKey, encoded);
  }

  String? getLastSelectedPresetId() {
    return Prefs.getString(_lastSelectedPresetKey);
  }

  Future<void> setLastSelectedPresetId(String id) async {
    await Prefs.setString(_lastSelectedPresetKey, id);
  }

  Future<void> addPreset(FocusPreset preset) async {
    final current = getUserPresets();
    current.add(preset);
    await saveUserPresets(current);
  }

  Future<void> updatePreset(FocusPreset preset) async {
    final current = getUserPresets();
    final index = current.indexWhere((p) => p.id == preset.id);
    if (index == -1) return;
    current[index] = preset;
    await saveUserPresets(current);
  }

  Future<void> deletePreset(String id) async {
    final builtInPreset = const [
      FocusPreset(
        id: FocusPreset.idStartNow,
        name: 'Start Now',
        focusSeconds: 5 * 60,
        breakSeconds: 0,
        isBuiltIn: true,
        isPremium: false,
      ),
      FocusPreset(
        id: FocusPreset.idPomodoro,
        name: 'Pomodoro',
        focusSeconds: 25 * 60,
        breakSeconds: 5 * 60,
        isBuiltIn: true,
        isPremium: false,
      ),
      FocusPreset(
        id: FocusPreset.idDeepWork,
        name: 'Deep Work',
        focusSeconds: 50 * 60,
        breakSeconds: 10 * 60,
        isBuiltIn: true,
        isPremium: true,
      ),
      FocusPreset(
        id: FocusPreset.idStudy,
        name: 'Study',
        focusSeconds: 45 * 60,
        breakSeconds: 15 * 60,
        isBuiltIn: true,
        isPremium: true,
      ),
      FocusPreset(
        id: FocusPreset.idSprint,
        name: 'Sprint',
        focusSeconds: 15 * 60,
        breakSeconds: 5 * 60,
        isBuiltIn: true,
        isPremium: true,
      ),
      FocusPreset(
        id: FocusPreset.idLongFocus,
        name: 'Long Focus',
        focusSeconds: 90 * 60,
        breakSeconds: 20 * 60,
        isBuiltIn: true,
        isPremium: true,
      ),
    ].where((p) => p.id == id).toList();

    if (builtInPreset.isNotEmpty) {
      final preset = builtInPreset.first;
      if (!preset.isPremium) {
        return;
      }
      final hidden = Prefs.getHiddenBuiltInPresets();
      if (!hidden.contains(id)) {
        hidden.add(id);
        await Prefs.setHiddenBuiltInPresets(hidden);
      }
      return;
    }

    final current = getUserPresets();
    current.removeWhere((p) => p.id == id);
    await saveUserPresets(current);
  }
}
