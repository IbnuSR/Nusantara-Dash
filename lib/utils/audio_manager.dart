import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ IMPORT INI
import 'game_prefs.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  static AudioManager get instance => _instance;

  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _bgmEnabled = true;
  bool _sfxEnabled = true;
  double _bgmVolume = 1.0;
  double _sfxVolume = 1.0;

  String? _currentBGMPath;

  bool get isBGMEnabled => _bgmEnabled;
  bool get isSFXEnabled => _sfxEnabled;
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;

  Future<void> initialize() async {
    try {
      _bgmVolume = await GamePrefs.getMusicVolume();
      _sfxVolume = await GamePrefs.getSFXVolume();
      _bgmEnabled = await GamePrefs.isMusicEnabled();
      _sfxEnabled = await GamePrefs.isSFXEnabled();

      if (_bgmVolume == 0.0 && !await _hasMusicVolumeBeenSet()) {
        _bgmVolume = 1.0;
        await GamePrefs.setMusicVolume(1.0);
      }
      if (_sfxVolume == 0.0 && !await _hasSFXVolumeBeenSet()) {
        _sfxVolume = 1.0;
        await GamePrefs.setSFXVolume(1.0);
      }

      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(_bgmEnabled ? _bgmVolume : 0.0);

      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
      await _sfxPlayer.setVolume(_sfxEnabled ? _sfxVolume : 0.0);

      print(
        '✅ Audio Manager initialized - BGM: ${(_bgmVolume * 100).round()}%, SFX: ${(_sfxVolume * 100).round()}%',
      );
    } catch (e) {
      print('❌ Audio Manager initialization failed: $e');
    }
  }

  Future<bool> _hasMusicVolumeBeenSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('music_volume');
  }

  Future<bool> _hasSFXVolumeBeenSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('sfx_volume');
  }

  // ===== BGM CONTROLS =====
  Future<void> playBGM(String assetPath) async {
    _currentBGMPath = assetPath;
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.play(AssetSource(assetPath));
      await _bgmPlayer.setVolume(_bgmEnabled ? _bgmVolume : 0.0);
      print(
        '🎵 Playing BGM: $assetPath at volume ${(_bgmVolume * 100).round()}%',
      );
    } catch (e) {
      print('Error playing BGM: $e');
    }
  }

  Future<void> setBGMVolume(double volume) async {
    _bgmVolume = volume.clamp(0.0, 1.0);
    await _bgmPlayer.setVolume(_bgmEnabled ? _bgmVolume : 0.0);

    if (_currentBGMPath != null && _bgmEnabled) {
      print('🎵 BGM Volume updated to: ${(_bgmVolume * 100).round()}%');
    }

    await GamePrefs.setMusicVolume(_bgmVolume);

    if (_bgmVolume > 0 && !_bgmEnabled) {
      _bgmEnabled = true;
      await GamePrefs.setMusicEnabled(true);
    }
  }

  Future<void> setSFXVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _sfxPlayer.setVolume(_sfxEnabled ? _sfxVolume : 0.0);
    await GamePrefs.setSFXVolume(_sfxVolume);

    if (_sfxVolume > 0 && !_sfxEnabled) {
      _sfxEnabled = true;
      await GamePrefs.setSFXEnabled(true);
    }
  }

  Future<void> toggleBGM() async {
    _bgmEnabled = !_bgmEnabled;

    if (_bgmEnabled) {
      await _bgmPlayer.setVolume(_bgmVolume);
      if (_currentBGMPath != null) {
        await _bgmPlayer.resume();
      }
    } else {
      await _bgmPlayer.setVolume(0.0);
      await _bgmPlayer.pause();
    }

    await GamePrefs.setMusicEnabled(_bgmEnabled);
    print('🎵 BGM ${_bgmEnabled ? "enabled" : "disabled"}');
  }

  Future<void> pauseBGM() async => await _bgmPlayer.pause();

  Future<void> resumeBGM() async {
    if (_bgmEnabled && _currentBGMPath != null) {
      await _bgmPlayer.resume();
    }
  }

  Future<void> stopBGM() async {
    await _bgmPlayer.stop();
    _currentBGMPath = null;
  }

  // ===== SFX CONTROLS =====
  Future<void> playSFX(String assetPath) async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Error playing SFX: $e');
    }
  }

  Future<void> toggleSFX() async {
    _sfxEnabled = !_sfxEnabled;
    await GamePrefs.setSFXEnabled(_sfxEnabled);
  }

  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
