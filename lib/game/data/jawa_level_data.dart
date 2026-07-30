class JawaLevelData {
  // ✅ PANJANG LEVEL TETAP 6000px
  static const double levelLength = 6000;

  static final List<Map<String, double>> platforms = [
    // 🟢 SECTION 1: Tutorial / Pemanasan (0 - 1100)
    {'x': 0, 'y': 0, 'w': 650, 'h': 100},
    {'x': 750, 'y': -60, 'w': 200, 'h': 30},
    {'x': 1000, 'y': -120, 'w': 150, 'h': 30},

    // 🟡 SECTION 2: Medium Jump (1250 - 2500)
    {'x': 1250, 'y': 0, 'w': 450, 'h': 100},
    {'x': 1750, 'y': -80, 'w': 200, 'h': 30},
    {'x': 2000, 'y': -150, 'w': 200, 'h': 30},
    {'x': 2250, 'y': -70, 'w': 250, 'h': 30},

    // 🔵 SECTION 3: Gap & Tantangan Santai (2600 - 4000)
    {'x': 2600, 'y': 0, 'w': 350, 'h': 100},
    {'x': 3000, 'y': -70, 'w': 160, 'h': 30},
    {'x': 3250, 'y': -140, 'w': 160, 'h': 30},
    {'x': 3500, 'y': -200, 'w': 200, 'h': 30},
    {'x': 3800, 'y': -100, 'w': 250, 'h': 100},

    // 🔴 SECTION 4: Precision Jump (4150 - 5400)
    {'x': 4150, 'y': -60, 'w': 200, 'h': 30},
    {'x': 4400, 'y': -120, 'w': 180, 'h': 30},
    {'x': 4650, 'y': -60, 'w': 300, 'h': 100},
    {'x': 5000, 'y': -140, 'w': 200, 'h': 30},
    {'x': 5250, 'y': -60, 'w': 200, 'h': 100},

    // ⚔️ SECTION 5: Boss Arena (5550 - 6000)
    {'x': 5550, 'y': 0, 'w': 450, 'h': 100},
  ];

  // ✅ PERBAIKAN: 5 Rintangan diletakkan di TENGAH platform panjang
  static final List<Map<String, double>> obstacles = [
    {'x': 320, 'y': -40, 'w': 40, 'h': 40}, // Wilayah 1: Pas di tengah platform awal
    {'x': 1450, 'y': -40, 'w': 40, 'h': 40}, // Wilayah 2: Pas di tengah jalan datar
    {'x': 2750, 'y': -40, 'w': 40, 'h': 40}, // Wilayah 3: Di tengah platform ke-3
    {'x': 4780, 'y': -100, 'w': 40, 'h': 40}, // Wilayah 4: Di tengah platform dataran tinggi
    {'x': 5330, 'y': -100, 'w': 40, 'h': 40}, // Wilayah 5: Rintangan terakhir sebelum bos
  ];

  // ✅ KOIN MELIMPAH: Membentuk lengkungan di atas setiap lompatan
  static final List<Map<String, double>> coins = [
    // Section 1
    {'x': 250, 'y': -160}, {'x': 300, 'y': -160}, {'x': 350, 'y': -160},
    {'x': 800, 'y': -110}, {'x': 850, 'y': -110},
    {'x': 1050, 'y': -170},
    // Section 2
    {'x': 1350, 'y': -160}, {'x': 1400, 'y': -160}, {'x': 1450, 'y': -160},
    {'x': 1800, 'y': -130}, {'x': 1850, 'y': -130},
    {'x': 2050, 'y': -200}, {'x': 2100, 'y': -200},
    {'x': 2300, 'y': -120}, {'x': 2350, 'y': -120},
    // Section 3
    {'x': 2700, 'y': -160}, {'x': 2750, 'y': -160},
    {'x': 3050, 'y': -120}, {'x': 3100, 'y': -120},
    {'x': 3300, 'y': -190}, {'x': 3350, 'y': -190},
    {'x': 3550, 'y': -250}, {'x': 3600, 'y': -250},
    {'x': 3880, 'y': -150}, {'x': 3930, 'y': -150},
    // Section 4
    {'x': 4200, 'y': -110}, {'x': 4250, 'y': -110},
    {'x': 4450, 'y': -170}, {'x': 4500, 'y': -170},
    {'x': 4750, 'y': -120}, {'x': 4800, 'y': -120},
    {'x': 5050, 'y': -190}, {'x': 5100, 'y': -190},
    {'x': 5300, 'y': -110}, {'x': 5350, 'y': -110},
    // Section 5 (Boss Area)
    {'x': 5650, 'y': -160}, {'x': 5700, 'y': -160},
    {'x': 5800, 'y': -160}, {'x': 5850, 'y': -160},
  ];

  // ======================================================================
  // 🏛️ HIDDEN CULTURAL ITEM — All 8 Jawa Items & Safe Spawn Points
  // ======================================================================

  /// 8 Item Budaya Baku Pulau Jawa (1 Item per Provinsi/Wilayah)
  static const List<String> hiddenItemIds = [
    'banten_001', // Badak Jawa (Banten)
    'jabar_001', // Angklung (Jawa Barat)
    'jakarta_001', // Monumen Nasional (DKI Jakarta)
    'jateng_001', // Candi Borobudur (Jawa Tengah)
    'jogja_001', // Tugu Yogyakarta (DI Yogyakarta)
    'jatim_001', // Reog Ponorogo (Jawa Timur)
    'madura_001', // Karapan Sapi (Madura)
    'jawa_001', // Batik Parang (Pulau Jawa)
  ];

  /// 12 Safe Spawn Candidate Locations
  ///
  /// Setiap lokasi divalidasi presisi di atas platform padat dengan margin
  /// standing area aman di kiri & kanan, jauh dari jurang dan obstacle.
  static final List<Map<String, double>> hiddenItemSpawnCandidates = [
    // 🟢 Section 1
    {'x': 180, 'y': -60}, // Ground 1 (x:0..650, y:0)
    {'x': 825, 'y': -120}, // Platform 2 (x:750..950, y:-60)

    // 🟡 Section 2
    {'x': 1300, 'y': -60}, // Ground 4 (x:1250..1700, y:0)
    {'x': 1830, 'y': -140}, // Platform 5 (x:1750..1950, y:-80)
    {'x': 2080, 'y': -210}, // Platform 6 (x:2000..2200, y:-150)
    {'x': 2360, 'y': -130}, // Platform 7 (x:2250..2500, y:-70)

    // 🔵 Section 3
    {'x': 2660, 'y': -60}, // Ground 8 (x:2600..2950, y:0)
    {'x': 3320, 'y': -200}, // Platform 10 (x:3250..3410, y:-140)
    {'x': 3590, 'y': -260}, // Platform 11 (x:3500..3700, y:-200)
    {'x': 3925, 'y': -160}, // Ground 12 (x:3800..4050, y:-100)

    // 🔴 Section 4
    {'x': 4235, 'y': -120}, // Platform 13 (x:4150..4350, y:-60)
    {'x': 5080, 'y': -200}, // Platform 16 (x:5000..5200, y:-140)
  ];
}