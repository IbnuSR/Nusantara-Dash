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
///
/// MuseumManager TIDAK:
///   - Membaca JSON langsung.
///   - Menggunakan rootBundle.
///   - Menggunakan SharedPreferences langsung.
class MuseumManager {
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
  /// Operasi ini didelegasikan sepenuhnya ke [GamePrefs].
  /// Tidak melakukan apa-apa jika item sudah terbuka sebelumnya.
  Future<void> unlockItem(String itemId) async {
    await GamePrefs.unlockMuseumItem(itemId);
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
