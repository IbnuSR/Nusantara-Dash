import 'package:shared_preferences/shared_preferences.dart';

class GamePrefs {
  // ===== 🔑 KEYS PENYIMPANAN =====
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
  static const String _museumUnlockedKey = 'museum_item_unlocked_list';

  // ==========================================
  // 🎬 1. PROLOGUE & TUTORIAL
  // ==========================================
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

  // ==========================================
  // 🎮 2. KONTROL
  // ==========================================
  static Future<String> getControlType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_controlTypeKey) ?? 'analog';
  }

  static Future<void> setControlType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_controlTypeKey, type);
  }

  // ==========================================
  // 🎵 3. PENGATURAN AUDIO
  // ==========================================
  static Future<double> getMusicVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_musicVolumeKey) ?? 1.0;
  }

  static Future<void> setMusicVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_musicVolumeKey, volume);
  }

  static Future<double> getSFXVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_sfxVolumeKey) ?? 1.0;
  }

  static Future<void> setSFXVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sfxVolumeKey, volume);
  }

  static Future<bool> isMusicEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_musicEnabledKey) ?? true;
  }

  static Future<void> setMusicEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicEnabledKey, enabled);
  }

  static Future<bool> isSFXEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sfxEnabledKey) ?? true;
  }

  static Future<void> setSFXEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sfxEnabledKey, enabled);
  }

  static Future<void> resetAudioSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_musicVolumeKey, 1.0);
    await prefs.setDouble(_sfxVolumeKey, 1.0);
    await prefs.setBool(_musicEnabledKey, true);
    await prefs.setBool(_sfxEnabledKey, true);
  }

  // ==========================================
  // 🪙 4. EKONOMI (KOIN)
  // ==========================================
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

  // ==========================================
  // ❤️ 5. NYAWA (LIVES)
  // ==========================================
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

  // ==========================================
  // 💡 6. CLUE / PETUNJUK
  // ==========================================
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

  // ==========================================
  // 🏝️ 7. PULAU (ISLANDS)
  // ==========================================
  static Future<List<String>> getUnlockedIslands() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_unlockedIslandsKey) ?? ['SUMATRA'];
  }

  static Future<void> unlockIsland(String islandCode) async {
    final prefs = await SharedPreferences.getInstance();
    final islands = await getUnlockedIslands();
    final code = islandCode.trim().toUpperCase();
    if (!islands.contains(code)) {
      islands.add(code);
      await prefs.setStringList(_unlockedIslandsKey, islands);
      print('💾 Tersimpan ke database HP! Daftar pulau terbuka: $islands');
    }
  }

  // 🔥 UPDATE: Buka pulau berikutnya (Anti-Gagal & Ada Log Terminal)
  static Future<void> unlockNextIsland(String currentIsland) async {
    String nextIsland = '';
    String current = currentIsland.trim().toUpperCase();

    if (current == 'SUMATRA')
      nextIsland = 'JAWA';
    else if (current == 'JAWA')
      nextIsland = 'KALIMANTAN';
    else if (current == 'KALIMANTAN')
      nextIsland = 'SULAWESI';
    else if (current == 'SULAWESI') nextIsland = 'PAPUA';

    if (nextIsland.isNotEmpty) {
      await unlockIsland(nextIsland);
      print('🎉 BERHASIL! Pulau $nextIsland resmi terbuka di database!');
    } else {
      print('⚠️ Semua pulau sudah terbuka atau pulau tidak dikenali: $current');
    }
  }

  // ==========================================
  // 👹 8. PROGRESS BOSS
  // ==========================================
  static Future<bool> isBossDefeated(String island) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('boss_defeated_${island.trim().toUpperCase()}') ??
        false;
  }

  static Future<void> markBossDefeated(String island) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('boss_defeated_${island.trim().toUpperCase()}', true);
  }

  // ==========================================
  // 🗡️ 9. SENJATA (WEAPONS)
  // ==========================================
  static Future<List<String>> getUnlockedWeapons() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('unlocked_weapons') ?? ['tangan_kosong'];
  }

  static Future<void> unlockWeapon(String weaponId) async {
    final prefs = await SharedPreferences.getInstance();
    final weapons = await getUnlockedWeapons();
    if (!weapons.contains(weaponId)) {
      weapons.add(weaponId);
      await prefs.setStringList('unlocked_weapons', weapons);
    }
  }

  static Future<bool> isWeaponUnlocked(String weaponId) async {
    final weapons = await getUnlockedWeapons();
    return weapons.contains(weaponId);
  }

  // ==========================================
  // 🏛️ 10. MUSEUM
  // ==========================================
  static Future<List<String>> getUnlockedMuseumItems() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_museumUnlockedKey) ?? [];
  }

  static Future<void> unlockMuseumItem(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_museumUnlockedKey) ?? [];
    if (!current.contains(itemId)) {
      current.add(itemId);
      await prefs.setStringList(_museumUnlockedKey, current);
    }
  }

  static Future<bool> isMuseumItemUnlocked(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_museumUnlockedKey) ?? [];
    return current.contains(itemId);
  }
}
