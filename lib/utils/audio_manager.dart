import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  static AudioManager get instance => _instance;

  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _bgmEnabled = true;
  bool _sfxEnabled = true;

  Future<void> initialize() async {
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(0.5); // Default volume 50%

      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
      await _sfxPlayer.setVolume(0.7); // SFX lebih keras

      print('✅ Audio Manager initialized successfully');
    } catch (e) {
      print('❌ Audio Manager initialization failed: $e');
    }
  }

  // ===== BGM CONTROLS =====

  Future<void> playBGM(String assetPath) async {
    if (!_bgmEnabled) return;

    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Error playing BGM: $e');
    }
  }

  Future<void> pauseBGM() async {
    await _bgmPlayer.pause();
  }

  Future<void> resumeBGM() async {
    if (_bgmEnabled) {
      await _bgmPlayer.resume();
    }
  }

  Future<void> stopBGM() async {
    await _bgmPlayer.stop();
  }

  void toggleBGM() {
    _bgmEnabled = !_bgmEnabled;
    if (_bgmEnabled) {
      _bgmPlayer.resume();
    } else {
      _bgmPlayer.pause();
    }
  }

  bool get isBGMEnabled => _bgmEnabled;

  // ===== SFX CONTROLS =====

  Future<void> playSFX(String assetPath) async {
    if (!_sfxEnabled) return;

    try {
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Error playing SFX: $e');
    }
  }

  void toggleSFX() {
    _sfxEnabled = !_sfxEnabled;
  }

  bool get isSFXEnabled => _sfxEnabled;

  // ===== VOLUME CONTROLS =====

  Future<void> setBGMVolume(double volume) async {
    await _bgmPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> setSFXVolume(double volume) async {
    await _sfxPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  // ===== DISPOSE =====

  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
