import 'package:shared_preferences/shared_preferences.dart';

class CoinManager {
  static const String _coinKey = 'nusantara_dash_coins';
  static const String _livesKey = 'nusantara_dash_lives';
  static const String _cluesKey = 'nusantara_dash_clues';
  static const String _unlockedIslandsKey = 'nusantara_dash_unlocked';

  // ✅ Koin
  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    // Default 500 koin untuk modal awal testing (bisa diganti 0 nanti)
    return prefs.getInt(_coinKey) ?? 500; 
  }

  static Future<void> saveCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinKey, coins);
  }

  static Future<void> addCoins(int amount) async {
    final current = await getCoins();
    await saveCoins(current + amount);
  }

  static Future<bool> spendCoins(int amount) async {
    final current = await getCoins();
    if (current >= amount) {
      await saveCoins(current - amount);
      return true; // Berhasil beli
    }
    return false; // Koin tidak cukup
  }

  // ✅ Nyawa (Lives)
  static Future<int> getExtraLives() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_livesKey) ?? 3; // Default 3 nyawa
  }

  static Future<void> addExtraLife() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_livesKey) ?? 3;
    await prefs.setInt(_livesKey, current + 1);
  }

  static Future<void> useExtraLife() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_livesKey) ?? 3;
    if (current > 0) {
      await prefs.setInt(_livesKey, current - 1);
    }
  }

  // ✅ Bantuan Kuis (Clues)
  static Future<int> getClues() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_cluesKey) ?? 0;
  }

  static Future<void> addClue() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_cluesKey) ?? 0;
    await prefs.setInt(_cluesKey, current + 1);
  }

  static Future<void> useClue() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_cluesKey) ?? 0;
    if (current > 0) {
      await prefs.setInt(_cluesKey, current - 1);
    }
  }

  // ✅ Pulau Terbuka (Islands)
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