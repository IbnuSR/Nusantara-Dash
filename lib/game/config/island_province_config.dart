/// Konfigurasi mapping dari nama pulau ke provinceId yang aktif.
///
/// Digunakan oleh [NusantaraDashGame] untuk menentukan provinsi mana
/// yang mendapatkan Cultural Item unlock saat pemain bermain di pulau tersebut.
///
/// Desain:
/// - Nama pulau menggunakan format UPPERCASE — konsisten dengan konstanta
///   yang digunakan di [MapScreen] dan widget.islandName di [GameScreen].
/// - provinceId menggunakan format lowercase — konsisten dengan field `id`
///   di province_config.json dan semua Museum API.
/// - Satu pulau hanya memiliki satu provinsi aktif per sesi gameplay.
class IslandProvinceConfig {
  // Private constructor: class ini tidak boleh diinstansiasi.
  // Semua akses dilakukan melalui static method.
  IslandProvinceConfig._();

  /// Mapping dari nama pulau (UPPERCASE) ke provinceId default.
  ///
  /// Hanya SUMATRA yang aktif karena hanya level Sumatra yang
  /// sudah selesai diimplementasikan. Pulau lain dikomentari dan
  /// akan diisi seiring dengan implementasi level masing-masing pulau.
  static const Map<String, String> _defaultProvinceByIsland = {
    'SUMATRA': 'aceh',
    'JAWA': 'banten',
    // 'KALIMANTAN': 'kalimantan_barat', // Aktifkan saat level Kalimantan selesai
    // 'SULAWESI': 'sulawesi_selatan',   // Aktifkan saat level Sulawesi selesai
    // 'PAPUA': 'papua',                 // Aktifkan saat level Papua selesai
  };

  /// Mengembalikan provinceId untuk pulau yang diberikan.
  ///
  /// Parameter [islandName] bersifat case-insensitive:
  /// 'SUMATRA', 'Sumatra', dan 'sumatra' semuanya mengembalikan 'aceh'.
  ///
  /// Mengembalikan null jika pulau belum dikonfigurasi.
  /// Caller wajib menangani kasus null sebelum memanggil Museum API.
  static String? getProvinceId(String islandName) {
    return _defaultProvinceByIsland[islandName.toUpperCase()];
  }

  /// Mengembalikan true jika pulau sudah memiliki konfigurasi provinsi aktif.
  ///
  /// Berguna untuk mengecek kelayakan spawn Hidden Cultural Item
  /// sebelum membangun komponen yang tidak bisa di-trigger.
  static bool hasProvince(String islandName) {
    return _defaultProvinceByIsland.containsKey(islandName.toUpperCase());
  }
}
