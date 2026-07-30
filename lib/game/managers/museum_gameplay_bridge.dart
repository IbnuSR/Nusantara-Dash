import 'package:nusantara_dash/game/data/museum_item_model.dart';
import 'package:nusantara_dash/game/managers/museum_manager.dart';

/// Hasil dari operasi unlock item.
///
/// Digunakan oleh Gameplay, Quiz, dan Boss untuk menentukan
/// apakah perlu menampilkan popup reward kepada pemain.
class MuseumUnlockResult {
  /// True jika item berhasil dibuka untuk pertama kali.
  /// False jika item sudah pernah terbuka sebelumnya, atau item tidak ditemukan.
  final bool wasNewUnlock;

  /// Cultural Item yang di-unlock (null jika item tidak ditemukan).
  final CulturalItem? item;

  const MuseumUnlockResult({
    required this.wasNewUnlock,
    this.item,
  });

  /// Shortcut: apakah ada item baru yang bisa ditampilkan ke pemain?
  bool get hasNewItem => wasNewUnlock && item != null;

  @override
  String toString() =>
      'MuseumUnlockResult(wasNewUnlock: $wasNewUnlock, item: ${item?.name})';
}

/// Jembatan antara Gameplay dan Museum.
///
/// Gunakan class ini dari Gameplay, Quiz Controller, maupun Boss
/// untuk memicu unlock Cultural Item tanpa perlu mengetahui
/// detail implementasi [MuseumManager] maupun [GamePrefs].
///
/// Semua method bersifat `static` — tidak perlu instansiasi.
///
/// === Cara Penggunaan dari Gameplay ===
///
/// ```dart
/// // Setelah pemain menyelesaikan level di Pulau Jawa:
/// final result = await MuseumGameplayBridge.unlockNextItemInProvince('yogyakarta');
///
/// if (result.hasNewItem) {
///   // Tampilkan popup kepada pemain
///   showMuseumItemFoundPopup(context, result.item!);
/// }
/// ```
///
/// ```dart
/// // Atau unlock item spesifik berdasarkan ID:
/// final result = await MuseumGameplayBridge.unlockItem('aceh_001');
/// ```
class MuseumGameplayBridge {
  // Private constructor — class ini murni static.
  MuseumGameplayBridge._();

  // ---------------------------------------------------------------------------
  // Primary API — Unlock Operations
  // ---------------------------------------------------------------------------

  /// Membuka Cultural Item spesifik berdasarkan [itemId].
  ///
  /// Mengembalikan [MuseumUnlockResult] yang berisi informasi apakah
  /// ini merupakan unlock baru, beserta detail item-nya.
  ///
  /// Aman dipanggil berkali-kali — tidak akan membuat duplikat unlock.
  static Future<MuseumUnlockResult> unlockItem(String itemId) async {
    final item = await MuseumManager.instance.getItem(itemId);

    if (item == null) {
      // Item tidak ditemukan dalam data Museum
      return const MuseumUnlockResult(wasNewUnlock: false, item: null);
    }

    final wasNewUnlock = await MuseumManager.instance.tryUnlockItem(itemId);

    return MuseumUnlockResult(
      wasNewUnlock: wasNewUnlock,
      item: wasNewUnlock ? item : null,
    );
  }

  /// Membuka Cultural Item berikutnya yang belum terbuka di provinsi [provinceId].
  ///
  /// Method ini direkomendasikan untuk dipanggil setelah pemain menyelesaikan
  /// satu level/sesi permainan di suatu provinsi.
  ///
  /// - Jika ada item terkunci → dibuka & return [MuseumUnlockResult] baru.
  /// - Jika semua item sudah terbuka → return `wasNewUnlock: false`.
  static Future<MuseumUnlockResult> unlockNextItemInProvince(
      String provinceId) async {
    final lockedItem =
        await MuseumManager.instance.getFirstLockedItemInProvince(provinceId);

    if (lockedItem == null) {
      // Semua item di provinsi ini sudah terbuka
      return const MuseumUnlockResult(wasNewUnlock: false, item: null);
    }

    final wasNewUnlock =
        await MuseumManager.instance.tryUnlockItem(lockedItem.id);

    return MuseumUnlockResult(
      wasNewUnlock: wasNewUnlock,
      item: wasNewUnlock ? lockedItem : null,
    );
  }

  /// Membuka Cultural Item berikutnya yang belum terbuka di pulau [islandId].
  ///
  /// Digunakan ketika Gameplay tidak mengetahui provinsi spesifik pemain.
  static Future<MuseumUnlockResult> unlockNextItemInIsland(
      String islandId) async {
    final lockedItem =
        await MuseumManager.instance.getFirstLockedItemInIsland(islandId);

    if (lockedItem == null) {
      return const MuseumUnlockResult(wasNewUnlock: false, item: null);
    }

    final wasNewUnlock =
        await MuseumManager.instance.tryUnlockItem(lockedItem.id);

    return MuseumUnlockResult(
      wasNewUnlock: wasNewUnlock,
      item: wasNewUnlock ? lockedItem : null,
    );
  }

  // ---------------------------------------------------------------------------
  // Query API — Status Checks
  // ---------------------------------------------------------------------------

  /// Mengembalikan `true` jika item dengan [itemId] sudah di-unlock.
  ///
  /// Digunakan oleh Quiz atau Boss untuk mengecek apakah reward sudah
  /// pernah diberikan sebelumnya.
  static Future<bool> isItemUnlocked(String itemId) async {
    return MuseumManager.instance.isItemUnlocked(itemId);
  }

  /// Mengembalikan progress Museum secara keseluruhan (level Indonesia).
  ///
  /// Digunakan untuk menampilkan statistik koleksi di layar Game Over
  /// atau layar Level Complete.
  static Future<MuseumProgress> getGlobalProgress() async {
    return MuseumManager.instance.getIndonesiaProgress();
  }

  /// Mengembalikan progress Museum untuk satu pulau.
  static Future<MuseumProgress> getIslandProgress(String islandId) async {
    return MuseumManager.instance.getIslandProgress(islandId);
  }
}
