import 'package:shared_preferences/shared_preferences.dart';

class GamePrefs {
  static const String _prologueKey = 'has_watched_prologue';
  static const String _controlTypeKey = 'control_type'; // 'analog' atau 'arrow'
  static const String _musicVolumeKey = 'music_volume';
  static const String _coinsKey = 'nusantara_dash_coins';
  static const String _livesKey =
      'nusantara_dash_lives'; // ✅ Kunci penyimpanan nyawa
  static const String _cluesKey =
      'nusantara_dash_clues'; // ✅ Kunci penyimpanan clue
  static const String _unlockedIslandsKey = 'nusantara_dash_unlocked';

  // 🎬 Prologue
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

  // 🎮 CONTROL TYPE: 'analog' atau 'arrow'
  static Future<String> getControlType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_controlTypeKey) ?? 'analog';
  }

  static Future<void> setControlType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_controlTypeKey, type);
  }

  // 🎵 MUSIC VOLUME: 0.0 - 1.0
  static Future<double> getMusicVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_musicVolumeKey) ?? 0.5;
  }

  static Future<void> setMusicVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_musicVolumeKey, volume);
  }

  // 🪙 Koin
  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinsKey) ??
        500; // ✅ Modal awal 500 koin untuk testing toko
  }

  static Future<void> saveCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, coins);
  }

  static Future<void> addCoins(int amount) async {
    final current = await getCoins();
    await saveCoins(current + amount);
  }

  // ✅ FUNGSI BARU: Untuk memotong koin saat belanja di Toko
  static Future<bool> spendCoins(int amount) async {
    final current = await getCoins();
    if (current >= amount) {
      await saveCoins(current - amount);
      return true;
    }
    return false;
  }

  // ❤️ Nyawa Cadangan (Lives) - ✅ INI YANG BIKIN ERROR TADI!
  static Future<int> getExtraLives() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_livesKey) ?? 3; // ✅ Default dikasih 3 nyawa
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

  // 💡 Bantuan Kuis (Clues) - ✅ DISIAPKAN UNTUK TOKO
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

  // 🏝️ Unlocked Islands
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
