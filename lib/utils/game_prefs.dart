import 'package:shared_preferences/shared_preferences.dart';

class GamePrefs {
  static const String _prologueKey = 'has_watched_prologue';
  static const String _controlTypeKey = 'control_type'; // 'analog' atau 'arrow'
  static const String _musicVolumeKey = 'music_volume';
  static const String _coinsKey = 'nusantara_coins';
  static const String _unlockedIslandsKey = 'nusantara_unlocked_islands';

  // Prologue
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

  // ✅ CONTROL TYPE: 'analog' atau 'arrow'
  static Future<String> getControlType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_controlTypeKey) ?? 'analog';
  }

  static Future<void> setControlType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_controlTypeKey, type);
  }

  // ✅ MUSIC VOLUME: 0.0 - 1.0
  static Future<double> getMusicVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_musicVolumeKey) ?? 0.5;
  }

  static Future<void> setMusicVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_musicVolumeKey, volume);
  }

  // Coins
  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinsKey) ?? 0;
  }

  static Future<void> saveCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, coins);
  }

  static Future<void> addCoins(int amount) async {
    final current = await getCoins();
    await saveCoins(current + amount);
  }

  // Unlocked Islands
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
