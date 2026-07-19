import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_prefs.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  static AudioManager get instance => _instance;

  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();

  // ✅ KUNCI SOLUSI: Menggunakan Map AudioPool khusus untuk SFX
  final Map<String, AudioPool> _sfxPools = {};

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

      // ✅ PRE-LOAD MENGGUNAKAN AUDIO POOL (Anti-Macet)
      // maxPlayers menentukan berapa suara maksimal yang bisa bunyi bersamaan.
      // Koin diset 5 agar kalau karaktermu ambil banyak koin sekaligus, suaranya bertumpuk natural!
      _sfxPools['sfx_coin.mp3'] =
          await FlameAudio.createPool('sfx/sfx_coin.mp3', maxPlayers: 5);
      _sfxPools['sfx_jump.mp3'] =
          await FlameAudio.createPool('sfx/sfx_jump.mp3', maxPlayers: 3);
      _sfxPools['sfx_land.mp3'] =
          await FlameAudio.createPool('sfx/sfx_land.mp3', maxPlayers: 3);
      _sfxPools['sfx_gameover.mp3'] =
          await FlameAudio.createPool('sfx/sfx_gameover.mp3', maxPlayers: 1);
      _sfxPools['sfx_level_complete.mp3'] = await FlameAudio.createPool(
          'sfx/sfx_level_complete.mp3',
          maxPlayers: 1);

      print('✅ Audio Manager initialized & AudioPool Ready (Anti-Macet)!');
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

  // ===== SFX CONTROLS (✅ EKSEKUSI INSTAN DARI AUDIO POOL) =====
  Future<void> playSFX(String fileName) async {
    if (!_sfxEnabled || _sfxVolume == 0.0) return;

    try {
      // Jika file sfx ada di dalam Pool RAM kita, langsung tembak!
      if (_sfxPools.containsKey(fileName)) {
        _sfxPools[fileName]!.start(volume: _sfxVolume);
      } else {
        // Fallback (cadangan) kalau kamu lupa nambahin nama file ke inisialisasi di atas
        FlameAudio.play('sfx/$fileName', volume: _sfxVolume);
      }
    } catch (e) {
      print('❌ Error playing SFX $fileName: $e');
    }
  }

  void dispose() {
    _bgmPlayer.dispose();
    // Bersihkan pool memori saat aplikasi ditutup agar RAM tidak bocor
    for (var pool in _sfxPools.values) {
      pool.dispose();
    }
    _sfxPools.clear();
  }
}
