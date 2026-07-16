import 'package:shared_preferences/shared_preferences.dart';

class GamePrefs {
  // Keys
  static const String _prologueKey = 'has_watched_prologue';
  static const String _controlTypeKey = 'control_type';
  static const String _musicVolumeKey = 'music_volume';
  static const String _sfxVolumeKey = 'sfx_volume';
  static const String _musicEnabledKey = 'music_enabled';
  static const String _sfxEnabledKey = 'sfx_enabled';
  static const String _coinsKey = 'nusantara_dash_coins';
  static const String _livesKey = 'nusantara_dash_lives';
  static const String _cluesKey = 'nusantara_dash_clues';
  static const String _unlockedIslandsKey = 'nusantara_dash_unlocked';

  // ===== 🎬 PROLOGUE =====
  static Future<bool> hasWatchedPrologue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prologueKey) ?? false;
  }

  static Future<void> markPrologueWatched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prologueKey, true);
  }

  static Future<void> resetPrologue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prologueKey);
  }

  // ===== 🎮 CONTROL TYPE =====
  static Future<String> getControlType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_controlTypeKey) ?? 'analog';
  }

  static Future<void> setControlType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_controlTypeKey, type);
  }

  // ===== 🎵 MUSIC VOLUME =====
  static Future<double> getMusicVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_musicVolumeKey) ?? 1.0;
  }

  static Future<void> setMusicVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_musicVolumeKey, volume);
  }

  // ===== 🔊 SFX VOLUME =====
  static Future<double> getSFXVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_sfxVolumeKey) ?? 1.0;
  }

  static Future<void> setSFXVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sfxVolumeKey, volume);
  }

  // ===== 🎵 MUSIC ENABLED TOGGLE =====
  static Future<bool> isMusicEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_musicEnabledKey) ?? true;
  }

  static Future<void> setMusicEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicEnabledKey, enabled);
  }

  // ===== 🔊 SFX ENABLED TOGGLE =====
  static Future<bool> isSFXEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sfxEnabledKey) ?? true;
  }

  static Future<void> setSFXEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sfxEnabledKey, enabled);
  }

  // ===== 🔄 RESET AUDIO SETTINGS =====
  static Future<void> resetAudioSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_musicVolumeKey, 1.0);
    await prefs.setDouble(_sfxVolumeKey, 1.0);
    await prefs.setBool(_musicEnabledKey, true);
    await prefs.setBool(_sfxEnabledKey, true);
  }

  // ===== 🪙 KOIN =====
  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinsKey) ?? 500;
  }

  static Future<void> saveCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, coins);
  }

  static Future<void> addCoins(int amount) async {
    final current = await getCoins();
    await saveCoins(current + amount);
  }

  static Future<bool> spendCoins(int amount) async {
    final current = await getCoins();
    if (current >= amount) {
      await saveCoins(current - amount);
      return true;
    }
    return false;
  }

  // ===== ❤️ NYAWA =====
  static Future<int> getExtraLives() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_livesKey) ?? 3;
  }

  static Future<void> addExtraLife() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getExtraLives();
    await prefs.setInt(_livesKey, current + 1);
  }

  static Future<void> useExtraLife() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getExtraLives();
    if (current > 0) {
      await prefs.setInt(_livesKey, current - 1);
    }
  }

  // ===== 💡 CLUE =====
  static Future<int> getClues() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_cluesKey) ?? 0;
  }

  static Future<void> addClue() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getClues();
    await prefs.setInt(_cluesKey, current + 1);
  }

  static Future<void> useClue() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getClues();
    if (current > 0) {
      await prefs.setInt(_cluesKey, current - 1);
    }
  }

  // ===== 🏝️ UNLOCKED ISLANDS =====
  static Future<List<String>> getUnlockedIslands() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_unlockedIslandsKey) ?? ['SUMATRA'];
  }

  static Future<void> unlockIsland(String islandCode) async {
    final prefs = await SharedPreferences.getInstance();
    final islands = await getUnlockedIslands();
    if (!islands.contains(islandCode)) {
      islands.add(islandCode);
      await prefs.setStringList(_unlockedIslandsKey, islands);
    }
  }
}
