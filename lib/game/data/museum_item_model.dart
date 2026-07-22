/// Model data untuk Museum Nusantara.
///
/// Hierarki:
///   MuseumIsland → MuseumProvince → CulturalItem
///
/// [MuseumProgress] digunakan sebagai value object untuk data progres
/// di tiga level: Indonesia, Pulau, dan Provinsi.

// ---------------------------------------------------------------------------
// CulturalItem
// ---------------------------------------------------------------------------

class CulturalItem {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String province;
  final String island;

  /// Opsional — belum digunakan di UI tahap ini,
  /// tersedia untuk iterasi berikutnya tanpa perlu mengubah model.
  final String? category;

  const CulturalItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.province,
    required this.island,
    this.category,
  });

  factory CulturalItem.fromJson(Map<String, dynamic> json) {
    return CulturalItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imagePath: json['image'] as String,
      province: json['province'] as String,
      island: json['island'] as String,
      category: json['category'] as String?,
    );
  }
}

// ---------------------------------------------------------------------------
// MuseumProvince
// ---------------------------------------------------------------------------

class MuseumProvince {
  final String id;
  final String name;
  final String islandId;
  final List<CulturalItem> items;

  const MuseumProvince({
    required this.id,
    required this.name,
    required this.islandId,
    required this.items,
  });

  factory MuseumProvince.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return MuseumProvince(
      id: json['id'] as String,
      name: json['name'] as String,
      islandId: json['island_id'] as String,
      items: rawItems
          .map((e) => CulturalItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// MuseumIsland
// ---------------------------------------------------------------------------

class MuseumIsland {
  final String id;
  final String name;
  final List<MuseumProvince> provinces;

  const MuseumIsland({
    required this.id,
    required this.name,
    required this.provinces,
  });

  factory MuseumIsland.fromJson(Map<String, dynamic> json) {
    final rawProvinces = json['provinces'] as List<dynamic>? ?? [];
    return MuseumIsland(
      id: json['id'] as String,
      name: json['name'] as String,
      provinces: rawProvinces
          .map((e) => MuseumProvince.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Mengembalikan semua Cultural Item dari seluruh provinsi dalam pulau ini.
  List<CulturalItem> get allItems =>
      provinces.expand((p) => p.items).toList();
}

// ---------------------------------------------------------------------------
// MuseumProgress
// ---------------------------------------------------------------------------

/// Value object yang merepresentasikan data progres Museum pada satu level.
///
/// Digunakan untuk tiga level progres:
///   - Level 1: Progress Indonesia (global)
///   - Level 2: Progress per Pulau
///   - Level 3: Progress per Provinsi
class MuseumProgress {
  /// Jumlah item yang sudah di-unlock oleh pemain.
  final int collected;

  /// Total item yang tersedia pada level ini.
  final int total;

  const MuseumProgress({
    required this.collected,
    required this.total,
  });

  /// Persentase progres (0.0 – 1.0). Mengembalikan 0 jika total == 0.
  double get percentage => total == 0 ? 0.0 : collected / total;

  /// True jika semua item pada level ini sudah terkumpul.
  bool get isComplete => total > 0 && collected >= total;

  /// Representasi teks, misalnya "5 / 8".
  String get label => '$collected / $total';

  @override
  String toString() => 'MuseumProgress($label)';
}
