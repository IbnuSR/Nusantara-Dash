import 'package:shared_preferences/shared_preferences.dart';
import 'weapon_model.dart';
import 'weapon_data.dart';

class WeaponManager {
  static const String _ownedWeaponsKey = 'owned_weapons';
  static const String _equippedWeaponKey = 'equipped_weapon';

  static Future<List<String>> getOwnedWeapons() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_ownedWeaponsKey) ?? [];
  }

  static Future<void> saveOwnedWeapons(List<String> weaponIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_ownedWeaponsKey, weaponIds);
  }

  static Future<void> addWeapon(String weaponId) async {
    final owned = await getOwnedWeapons();
    if (!owned.contains(weaponId)) {
      owned.add(weaponId);
      await saveOwnedWeapons(owned);

      // ✅ CEK: Jika semua senjata suci sudah dimiliki, unlock senjata gabungan
      await _checkAndUnlockCombinedWeapon();
    }
  }

  static Future<bool> isWeaponOwned(String weaponId) async {
    final owned = await getOwnedWeapons();
    return owned.contains(weaponId);
  }

  static Future<String?> getEquippedWeapon() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_equippedWeaponKey);
  }

  static Future<void> equipWeapon(String weaponId) async {
    final owned = await getOwnedWeapons();
    if (owned.contains(weaponId)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_equippedWeaponKey, weaponId);
    }
  }

  static Future<int> getEquippedWeaponDamage() async {
    final equippedId = await getEquippedWeapon();
    if (equippedId == null) return 10;
    final weapon = WeaponData.getWeaponById(equippedId);
    return weapon?.damage ?? 10;
  }

  // ✅ METHOD BARU: Cek dan unlock senjata gabungan
  static Future<void> _checkAndUnlockCombinedWeapon() async {
    final owned = await getOwnedWeapons();

    // Cek apakah semua senjata suci sudah dimiliki
    if (WeaponData.hasAllSacredWeapons(owned)) {
      final combinedWeapon = WeaponData.getCombinedWeapon();
      if (combinedWeapon != null && !owned.contains(combinedWeapon.id)) {
        // Unlock senjata gabungan
        owned.add(combinedWeapon.id);
        await saveOwnedWeapons(owned);
      }
    }
  }

  // ✅ METHOD BARU: Beli senjata
  static Future<bool> buyWeapon(String weaponId, int userCoins) async {
    final weapon = WeaponData.getWeaponById(weaponId);
    if (weapon == null) return false;

    final owned = await getOwnedWeapons();
    if (owned.contains(weaponId)) return false;

    if (userCoins >= weapon.price) {
      await addWeapon(weaponId);
      return true;
    }

    return false;
  }
}
