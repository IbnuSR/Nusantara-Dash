import 'package:flutter/foundation.dart';

import '../data/museum_item_model.dart';
import '../repository/museum_repository.dart';
import 'package:nusantara_dash/utils/game_prefs.dart';

/// Business Logic Layer untuk Museum Nusantara.
///
/// MuseumManager bertindak sebagai satu-satunya pintu masuk bagi UI
/// ke seluruh data dan state Museum.
///
/// Tanggung jawab:
///   - Memuat dan men-cache data island dari [MuseumRepository].
///   - Menghitung progress pada tiga level (Indonesia, Pulau, Provinsi).
///   - Mendelegasikan operasi unlock ke [GamePrefs].
///   - Menyediakan lookup (island, province, item) untuk UI.
///   - Memberitahu semua listener aktif (UI Screens) ketika terjadi perubahan
///     unlock melalui [ChangeNotifier].
///
/// MuseumManager TIDAK:
///   - Membaca JSON langsung.
///   - Menggunakan rootBundle.
///   - Menggunakan SharedPreferences langsung.
class MuseumManager with ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Singleton
  // ---------------------------------------------------------------------------

  static final MuseumManager _instance = MuseumManager._internal();

  /// Akses singleton MuseumManager.
  static MuseumManager get instance => _instance;

  MuseumManager._internal();

  // ---------------------------------------------------------------------------
  // Internal cache
  // ---------------------------------------------------------------------------

  /// Cache island yang sudah di-load. Null berarti belum pernah di-load.
  List<MuseumIsland>? _islands;

  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  /// Memuat seluruh data Museum dari [MuseumRepository] dan menyimpannya
  /// ke cache internal.
  ///
  /// Aman dipanggil berkali-kali — loading hanya terjadi sekali.
  /// Panggil ini saat aplikasi membuka Museum pertama kali.
  Future<void> loadMuseum() async {
    _islands ??= await MuseumRepository.instance.getAllIslands();
  }

  /// Memastikan data sudah di-load sebelum diakses.
  /// Dipanggil secara internal oleh semua method yang membutuhkan _islands.
  Future<List<MuseumIsland>> _ensureLoaded() async {
    if (_islands == null) await loadMuseum();
    return _islands!;
  }

  // ---------------------------------------------------------------------------
  // Read — Island, Province, Item
  // ---------------------------------------------------------------------------

  /// Mengembalikan seluruh daftar [MuseumIsland].
  Future<List<MuseumIsland>> getAllIslands() async {
    return _ensureLoaded();
  }

  /// Mengembalikan [MuseumIsland] berdasarkan [id].
  /// Mengembalikan null jika tidak ditemukan.
  Future<MuseumIsland?> getIsland(String id) async {
    final islands = await _ensureLoaded();
    try {
      return islands.firstWhere((island) => island.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Mengembalikan [MuseumProvince] berdasarkan [id] di seluruh pulau.
  /// Mengembalikan null jika tidak ditemukan.
  Future<MuseumProvince?> getProvince(String id) async {
    final islands = await _ensureLoaded();
    for (final island in islands) {
      for (final province in island.provinces) {
        if (province.id == id) return province;
      }
    }
    return null;
  }

  /// Mengembalikan [CulturalItem] berdasarkan [id] di seluruh pulau dan provinsi.
  /// Mengembalikan null jika tidak ditemukan.
  Future<CulturalItem?> getItem(String id) async {
    final islands = await _ensureLoaded();
    for (final island in islands) {
      for (final province in island.provinces) {
        for (final item in province.items) {
          if (item.id == id) return item;
        }
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Progress — 3 Level
  // ---------------------------------------------------------------------------

  /// Level 1 — Progress Indonesia (global).
  ///
  /// Menghitung berapa Cultural Item dari seluruh Indonesia yang sudah
  /// di-unlock oleh pemain.
  Future<MuseumProgress> getIndonesiaProgress() async {
    final islands = await _ensureLoaded();
    final allItems = islands.expand((island) => island.allItems).toList();
    final unlockedIds = await GamePrefs.getUnlockedMuseumItems();

    final collected =
        allItems.where((item) => unlockedIds.contains(item.id)).length;

    return MuseumProgress(collected: collected, total: allItems.length);
  }

  /// Level 2 — Progress Pulau.
  ///
  /// Menghitung berapa Cultural Item dari pulau [islandId] yang sudah
  /// di-unlock oleh pemain.
  /// Mengembalikan progress 0/0 jika pulau tidak ditemukan.
  Future<MuseumProgress> getIslandProgress(String islandId) async {
    final island = await getIsland(islandId);
    if (island == null) return const MuseumProgress(collected: 0, total: 0);

    final allItems = island.allItems;
    final unlockedIds = await GamePrefs.getUnlockedMuseumItems();

    final collected =
        allItems.where((item) => unlockedIds.contains(item.id)).length;

    return MuseumProgress(collected: collected, total: allItems.length);
  }

  /// Level 3 — Progress Provinsi.
  ///
  /// Menghitung berapa Cultural Item dari provinsi [provinceId] yang sudah
  /// di-unlock oleh pemain.
  /// Mengembalikan progress 0/0 jika provinsi tidak ditemukan.
  Future<MuseumProgress> getProvinceProgress(String provinceId) async {
    final province = await getProvince(provinceId);
    if (province == null) return const MuseumProgress(collected: 0, total: 0);

    final unlockedIds = await GamePrefs.getUnlockedMuseumItems();

    final collected =
        province.items.where((item) => unlockedIds.contains(item.id)).length;

    return MuseumProgress(collected: collected, total: province.items.length);
  }

  // ---------------------------------------------------------------------------
  // Unlock
  // ---------------------------------------------------------------------------

  /// Membuka (unlock) satu Cultural Item berdasarkan [itemId].
  ///
  /// Setelah item berhasil disimpan ke [GamePrefs], [notifyListeners] dipanggil
  /// sehingga semua Museum Screen yang aktif dapat memperbarui tampilan secara
  /// real-time tanpa restart.
  ///
  /// Tidak melakukan apa-apa jika item sudah terbuka sebelumnya.
  Future<void> unlockItem(String itemId) async {
    await GamePrefs.unlockMuseumItem(itemId);
    notifyListeners();
  }

  /// Membuka item dengan aman dan mengembalikan apakah item tersebut
  /// merupakan unlock baru (belum pernah terbuka sebelumnya).
  ///
  /// - Mengembalikan `true` jika item berhasil dibuka untuk pertama kali.
  /// - Mengembalikan `false` jika item sudah pernah terbuka atau tidak ditemukan.
  ///
  /// Ini adalah method yang direkomendasikan untuk dipanggil dari Gameplay,
  /// karena return value-nya dapat digunakan untuk menampilkan popup reward.
  Future<bool> tryUnlockItem(String itemId) async {
    // Pastikan item ada dalam data Museum
    final item = await getItem(itemId);
    if (item == null) return false;

    // Jika sudah terbuka, kembalikan false tanpa melakukan apa-apa
    final alreadyUnlocked = await GamePrefs.isMuseumItemUnlocked(itemId);
    if (alreadyUnlocked) return false;

    // Lakukan unlock dan broadcast perubahan ke UI
    await GamePrefs.unlockMuseumItem(itemId);
    notifyListeners();
    return true;
  }

  /// Mengembalikan true jika [itemId] sudah di-unlock oleh pemain.
  Future<bool> isItemUnlocked(String itemId) async {
    return GamePrefs.isMuseumItemUnlocked(itemId);
  }

  /// Mengembalikan daftar ID dari seluruh item yang sudah di-unlock.
  Future<List<String>> getUnlockedItems() async {
    return GamePrefs.getUnlockedMuseumItems();
  }

  // ---------------------------------------------------------------------------
  // Gameplay Helper Methods
  // ---------------------------------------------------------------------------

  /// Mengembalikan Cultural Item pertama yang BELUM terbuka di provinsi [provinceId].
  ///
  /// Digunakan oleh Gameplay untuk menentukan item mana yang akan di-unlock
  /// ketika pemain menyelesaikan level di provinsi tersebut.
  ///
  /// Mengembalikan null jika semua item sudah terbuka atau provinsi tidak ditemukan.
  Future<CulturalItem?> getFirstLockedItemInProvince(String provinceId) async {
    final province = await getProvince(provinceId);
    if (province == null) return null;

    final unlockedIds = await GamePrefs.getUnlockedMuseumItems();
    try {
      return province.items
          .firstWhere((item) => !unlockedIds.contains(item.id));
    } catch (_) {
      return null; // Semua item sudah terbuka
    }
  }

  /// Mengembalikan Cultural Item pertama yang BELUM terbuka di pulau [islandId].
  ///
  /// Iterasi dimulai dari provinsi pertama hingga ditemukan item terkunci.
  /// Mengembalikan null jika semua item di pulau sudah terbuka.
  Future<CulturalItem?> getFirstLockedItemInIsland(String islandId) async {
    final island = await getIsland(islandId);
    if (island == null) return null;

    final unlockedIds = await GamePrefs.getUnlockedMuseumItems();
    for (final province in island.provinces) {
      for (final item in province.items) {
        if (!unlockedIds.contains(item.id)) return item;
      }
    }
    return null; // Semua item sudah terbuka
  }

  // ---------------------------------------------------------------------------
  // Cache management
  // ---------------------------------------------------------------------------

  /// Mengosongkan cache internal secara manual.
  ///
  /// Tidak diperlukan dalam kondisi normal karena data Museum bersifat statis.
  /// Tersedia untuk keperluan testing atau hot reload.
  void clearCache() {
    _islands = null;
  }
}
