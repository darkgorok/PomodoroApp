import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
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

  String? selectedSoundId;
  double volume = 0.7;
  bool autoPlay = false;
  bool isPlaying = false;

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

  Future<void> play(String soundId) async {
    final sound = sounds.firstWhere((s) => s.id == soundId);
    selectedSoundId = soundId;
    await Prefs.setSelectedSoundId(soundId);
    await _player.setAudioSource(AudioSource.asset(sound.assetPath));
    await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(volume);
    await _player.play();
    isPlaying = true;
    notifyListeners();
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

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
