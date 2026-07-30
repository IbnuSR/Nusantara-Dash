/// Konfigurasi SFX untuk Hidden Cultural Item collectible.
///
/// Memisahkan nama file audio dari logika [HiddenCulturalItemComponent]
/// agar SFX dapat diganti tanpa menyentuh kode komponen.
///
/// Integrasi dengan AudioManager:
/// - [AudioManager.playSFX] secara otomatis mencari nama file di _sfxPools.
/// - Jika belum didaftarkan di [AudioManager.initialize()], playSFX akan
///   menggunakan fallback FlameAudio.play() yang tetap berfungsi namun
///   sedikit lebih lambat (acceptable untuk event yang jarang terjadi).
/// - Untuk performa optimal, daftarkan [collectSfx] di AudioManager.initialize()
///   saat file audio tersedia.
class CulturalItemSfxConfig {
  // Private constructor: class ini tidak boleh diinstansiasi.
  CulturalItemSfxConfig._();

  /// Nama file SFX yang diputar saat pemain mengambil Hidden Cultural Item.
  ///
  /// File harus tersedia di: assets/audio/sfx/sfx_cultural_item.mp3
  ///
  /// Jika file belum tersedia di aset, gunakan [fallbackSfx] sebagai
  /// pengganti sementara selama development.
  static const String collectSfx = 'sfx_cultural_item.mp3';

  /// Fallback SFX menggunakan suara koin yang sudah ada.
  ///
  /// Digunakan sebagai pengganti sementara jika [collectSfx] belum tersedia.
  /// Ganti dengan [collectSfx] setelah file audio final tersedia.
  static const String fallbackSfx = 'sfx_coin.mp3';
}
