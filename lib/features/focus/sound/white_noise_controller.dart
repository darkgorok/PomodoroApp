import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/storage/prefs.dart';

class SoundOption {
  const SoundOption({
    required this.id,
    required this.title,
    required this.assetPath,
  });

  final String id;
  final String title;
  final String assetPath;
}

class WhiteNoiseController extends ChangeNotifier {
  WhiteNoiseController() : _player = AudioPlayer();

  static const List<SoundOption> sounds = [
    SoundOption(id: 'rain', title: 'Rain', assetPath: 'assets/sounds/rain.mp3'),
    SoundOption(id: 'ocean', title: 'Ocean', assetPath: 'assets/sounds/ocean.mp3'),
    SoundOption(id: 'forest', title: 'Forest', assetPath: 'assets/sounds/forest.mp3'),
    SoundOption(id: 'fire', title: 'Fireplace', assetPath: 'assets/sounds/fire.mp3'),
    SoundOption(id: 'white', title: 'White Noise', assetPath: 'assets/sounds/white.mp3'),
  ];

  final AudioPlayer _player;
  final Map<String, String> _cachedFiles = {};

  String? selectedSoundId;
  double volume = 0.7;
  bool autoPlay = false;
  bool isPlaying = false;
  String? lastError;

  Future<void> loadPrefs() async {
    selectedSoundId = Prefs.getSelectedSoundId();
    volume = Prefs.getSoundVolume() ?? 0.7;
    autoPlay = Prefs.getAutoPlayEnabled() ?? false;
    await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(volume);
    notifyListeners();
  }

  SoundOption? get selectedSound {
    final id = selectedSoundId;
    if (id == null) return null;
    return sounds.firstWhere((s) => s.id == id, orElse: () => sounds.first);
  }

  Future<bool> play(String soundId) async {
    final sound = sounds.firstWhere((s) => s.id == soundId);
    selectedSoundId = soundId;
    await Prefs.setSelectedSoundId(soundId);
    try {
      final filePath = await _ensureAssetFile(sound.assetPath, sound.id);
      await _player.setAudioSource(AudioSource.file(filePath));
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(volume);
      await _player.play();
      isPlaying = true;
      lastError = null;
      notifyListeners();
      return true;
    } catch (e) {
      isPlaying = false;
      lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> stop() async {
    if (!_player.playing) {
      isPlaying = false;
      notifyListeners();
      return;
    }
    await _player.stop();
    isPlaying = false;
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    volume = value;
    await Prefs.setSoundVolume(value);
    await _player.setVolume(value);
    notifyListeners();
  }

  Future<void> setAutoPlay(bool value) async {
    autoPlay = value;
    await Prefs.setAutoPlayEnabled(value);
    notifyListeners();
  }

  Future<void> handleFocusStart() async {
    if (!autoPlay) return;
    final sound = selectedSound ?? sounds.first;
    await play(sound.id);
  }

  Future<void> handleFocusEnd() async {
    await stop();
  }

  Future<String> _ensureAssetFile(String assetPath, String id) async {
    final cached = _cachedFiles[assetPath];
    if (cached != null && File(cached).existsSync()) {
      return cached;
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/sound_$id.mp3');
    if (!file.existsSync()) {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    }
    _cachedFiles[assetPath] = file.path;
    return file.path;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
