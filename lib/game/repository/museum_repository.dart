import 'dart:convert';
import 'package:flutter/services.dart';

import '../data/museum_item_model.dart';

/// Repository tunggal untuk data Museum Nusantara.
///
/// Tanggung jawab:
///   - Membaca [province_config.json] dari assets.
///   - Mem-parse JSON menjadi list [MuseumIsland].
///   - Men-cache hasil parsing agar JSON hanya dibaca **satu kali**.
///
/// Repository ini TIDAK mengakses GamePrefs atau SharedPreferences.
/// Logika unlock dan progress ada di [MuseumManager].
class MuseumRepository {
  // ---------------------------------------------------------------------------
  // Singleton
  // ---------------------------------------------------------------------------

  static final MuseumRepository _instance = MuseumRepository._internal();

  /// Akses singleton MuseumRepository.
  static MuseumRepository get instance => _instance;

  MuseumRepository._internal();

  // ---------------------------------------------------------------------------
  // Internal cache
  // ---------------------------------------------------------------------------

  static const String _assetPath = 'assets/data/province_config.json';

  /// Cache hasil parsing JSON. Null berarti belum pernah di-load.
  List<MuseumIsland>? _cachedIslands;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Mengembalikan seluruh daftar [MuseumIsland].
  ///
  /// JSON hanya dibaca dan di-parse **satu kali**. Pemanggilan berikutnya
  /// langsung mengembalikan data dari cache.
  Future<List<MuseumIsland>> getAllIslands() async {
    if (_cachedIslands != null) return _cachedIslands!;

    final String rawJson = await rootBundle.loadString(_assetPath);
    final List<dynamic> decoded = json.decode(rawJson) as List<dynamic>;

    _cachedIslands = decoded
        .map((e) => MuseumIsland.fromJson(e as Map<String, dynamic>))
        .toList();

    return _cachedIslands!;
  }

  /// Mengembalikan semua [CulturalItem] dari seluruh pulau dan provinsi
  /// dalam bentuk list flat.
  Future<List<CulturalItem>> getAllItems() async {
    final islands = await getAllIslands();
    return islands.expand((island) => island.allItems).toList();
  }

  /// Mencari [MuseumIsland] berdasarkan [id].
  /// Mengembalikan null jika tidak ditemukan.
  Future<MuseumIsland?> getIslandById(String id) async {
    final islands = await getAllIslands();
    try {
      return islands.firstWhere((island) => island.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Mencari [MuseumProvince] berdasarkan [id] di seluruh pulau.
  /// Mengembalikan null jika tidak ditemukan.
  Future<MuseumProvince?> getProvinceById(String id) async {
    final islands = await getAllIslands();
    for (final island in islands) {
      for (final province in island.provinces) {
        if (province.id == id) return province;
      }
    }
    return null;
  }

  /// Mencari [CulturalItem] berdasarkan [id] di seluruh pulau dan provinsi.
  /// Mengembalikan null jika tidak ditemukan.
  Future<CulturalItem?> getItemById(String id) async {
    final items = await getAllItems();
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Cache management
  // ---------------------------------------------------------------------------

  /// Mengosongkan cache secara manual.
  ///
  /// Tidak diperlukan dalam kondisi normal karena data Museum bersifat statis.
  /// Tersedia untuk keperluan testing.
  void clearCache() {
    _cachedIslands = null;
  }
}
