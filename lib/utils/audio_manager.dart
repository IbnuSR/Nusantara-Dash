import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_prefs.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  static AudioManager get instance => _instance;

  AudioManager._internal();

  // BGM tetap pakai AudioPlayer
  final AudioPlayer _bgmPlayer = AudioPlayer();

  // ✅ PERBAIKAN: Pakai AudioCache khusus untuk SFX (Jauh lebih stabil)
  // Prefix 'audio/sfx/' artinya kita cuma perlu panggil nama file saja nanti
  final AudioCache _sfxCache = AudioCache(prefix: 'audio/sfx/');

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

      // ✅ Pre-load semua SFX ke memori agar tidak ada delay saat diputar
      await _sfxCache.loadAll([
        'sfx_coin.mp3',
        'sfx_jump.mp3',
        'sfx_land.mp3',
        'sfx_gameover.mp3',
        'sfx_level_complete.mp3',
      ]);

      print('✅ Audio Manager initialized & SFX pre-loaded!');
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
    } catch (e) {
      print('Error playing BGM: $e');
    }
  }

  Future<void> setBGMVolume(double volume) async {
    _bgmVolume = volume.clamp(0.0, 1.0);
    await _bgmPlayer.setVolume(_bgmEnabled ? _bgmVolume : 0.0);
    await GamePrefs.setMusicVolume(_bgmVolume);
  }

  Future<void> setSFXVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await GamePrefs.setSFXVolume(_sfxVolume);
  }

  Future<void> toggleBGM() async {
    _bgmEnabled = !_bgmEnabled;
    if (_bgmEnabled) {
      await _bgmPlayer.setVolume(_bgmVolume);
      if (_currentBGMPath != null) await _bgmPlayer.resume();
    } else {
      await _bgmPlayer.setVolume(0.0);
      await _bgmPlayer.pause();
    }
    await GamePrefs.setMusicEnabled(_bgmEnabled);
  }

  Future<void> toggleSFX() async {
    _sfxEnabled = !_sfxEnabled;
    await GamePrefs.setSFXEnabled(_sfxEnabled);
  }

  // ===== SFX CONTROLS (✅ DIPERBAIKI TOTAL) =====
  Future<void> playSFX(String fileName) async {
    if (!_sfxEnabled || _sfxVolume == 0.0) return;

    try {
      final player = AudioPlayer();
      player.onPlayerComplete.listen((_) => player.dispose());
      await player.play(AssetSource('audio/sfx/$fileName'), volume: _sfxVolume);
    } catch (e) {
      print('❌ Error playing SFX $fileName: $e');
    }
  }

  void dispose() {
    _bgmPlayer.dispose();
    _sfxCache.clearAll(); // Bersihkan cache SFX
  }
}
