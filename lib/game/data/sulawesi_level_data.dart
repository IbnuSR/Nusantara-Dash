class SulawesiLevelData {
  // ✅ PANJANG LEVEL TETAP 6000px
  static const double levelLength = 6000;

  static final List<Map<String, double>> platforms = [
    // 🟢 SECTION 1: Tutorial (0 - 1100)
    {'x': 0, 'y': 0, 'w': 650, 'h': 100},
    {'x': 720, 'y': -60, 'w': 200, 'h': 30},
    {'x': 980, 'y': -110, 'w': 180, 'h': 30},

    // 🟡 SECTION 2: Medium Jump (1200 - 2500)
    {'x': 1200, 'y': 0, 'w': 450, 'h': 100},
    {'x': 1700, 'y': -90, 'w': 200, 'h': 30},
    {'x': 1950, 'y': -160, 'w': 220, 'h': 30},
    {'x': 2250, 'y': -90, 'w': 280, 'h': 30},

    // 🔵 SECTION 3: Gap & Tantangan Santai (2600 - 4000)
    {'x': 2600, 'y': 0, 'w': 380, 'h': 100},
    {'x': 3050, 'y': -70, 'w': 180, 'h': 30},
    {'x': 3300, 'y': -140, 'w': 180, 'h': 30},
    {'x': 3550, 'y': -200, 'w': 200, 'h': 30},
    {'x': 3850, 'y': -100, 'w': 250, 'h': 100},

    // 🔴 SECTION 4: Precision Jump (4150 - 5400)
    {'x': 4150, 'y': -50, 'w': 200, 'h': 30},
    {'x': 4400, 'y': -110, 'w': 180, 'h': 30},
    {'x': 4650, 'y': -50, 'w': 300, 'h': 100},
    {'x': 5000, 'y': -130, 'w': 200, 'h': 30},
    {'x': 5250, 'y': -50, 'w': 220, 'h': 100},

    // ⚔️ SECTION 5: Boss Arena (5550 - 6000)
    {'x': 5550, 'y': 0, 'w': 450, 'h': 100},
  ];

  // ✅ PERBAIKAN: Posisi rintangan persis di TENGAH, bebas jebakan
  static final List<Map<String, double>> obstacles = [
    {'x': 320, 'y': -40, 'w': 40, 'h': 40}, // Wilayah 1
    {'x': 1400, 'y': -40, 'w': 40, 'h': 40}, // Wilayah 2
    {'x': 2770, 'y': -40, 'w': 40, 'h': 40}, // Wilayah 3
    {'x': 4780, 'y': -90, 'w': 40, 'h': 40}, // Wilayah 4
    {'x': 5350, 'y': -90, 'w': 40, 'h': 40}, // Wilayah 5
  ];

  // ✅ KOIN MELIMPAH
  static final List<Map<String, double>> coins = [
    // Section 1
    {'x': 220, 'y': -160}, {'x': 270, 'y': -160}, {'x': 320, 'y': -160},
    {'x': 780, 'y': -110}, {'x': 830, 'y': -110},
    {'x': 1050, 'y': -160},
    // Section 2
    {'x': 1300, 'y': -160}, {'x': 1350, 'y': -160}, {'x': 1400, 'y': -160},
    {'x': 1780, 'y': -140}, {'x': 1830, 'y': -140},
    {'x': 2030, 'y': -210}, {'x': 2080, 'y': -210},
    {'x': 2350, 'y': -140}, {'x': 2400, 'y': -140},
    // Section 3
    {'x': 2730, 'y': -160}, {'x': 2780, 'y': -160},
    {'x': 3120, 'y': -120}, {'x': 3170, 'y': -120},
    {'x': 3370, 'y': -190}, {'x': 3420, 'y': -190},
    {'x': 3630, 'y': -250}, {'x': 3680, 'y': -250},
    {'x': 3930, 'y': -150}, {'x': 3980, 'y': -150},
    // Section 4
    {'x': 4220, 'y': -100}, {'x': 4270, 'y': -100},
    {'x': 4470, 'y': -160}, {'x': 4520, 'y': -160},
    {'x': 4780, 'y': -210}, {'x': 4830, 'y': -210},
    {'x': 5080, 'y': -180}, {'x': 5130, 'y': -180},
    {'x': 5330, 'y': -100}, {'x': 5380, 'y': -100},
    // Section 5 (Boss Area)
    {'x': 5650, 'y': -160}, {'x': 5700, 'y': -160},
    {'x': 5800, 'y': -160}, {'x': 5850, 'y': -160},
  ];

  // ======================================================================
  // 🏛️ HIDDEN CULTURAL ITEM — All 8 Sulawesi Items & Safe Spawn Points
  // ======================================================================

  /// 8 Item Budaya Baku Pulau Sulawesi (1 Item per Provinsi/Wilayah)
  static const List<String> hiddenItemIds = [
    'gorontalo_001', // Benteng Otanaha (Gorontalo)
    'sulbar_001', // Anjungan Pantai Manakarra (Sulawesi Barat)
    'sulsel_001', // Kapal Pinisi (Sulawesi Selatan)
    'sulteng_001', // Rumah Tambi (Sulawesi Tengah)
    'sultra_001', // Tari Lulo (Sulawesi Tenggara)
    'sulut_001', // Tarsius (Sulawesi Utara)
    'sulawesi_001', // Es Pisang Ijo (Kuliner Sulawesi)
    'sulawesi_002', // Kain Tenun (Tenun Sulawesi)
  ];

  /// 12 Safe Spawn Candidate Locations
  ///
  /// Setiap lokasi divalidasi presisi di atas platform padat dengan margin
  /// standing area aman di kiri & kanan, jauh dari jurang dan obstacle.
  static final List<Map<String, double>> hiddenItemSpawnCandidates = [
    // 🟢 Section 1
    {'x': 180, 'y': -60}, // Ground 1 (x:0..650, y:0)
    {'x': 800, 'y': -120}, // Platform 2 (x:720..920, y:-60)

    // 🟡 Section 2
    {'x': 1280, 'y': -60}, // Ground 4 (x:1200..1650, y:0)
    {'x': 1780, 'y': -150}, // Platform 5 (x:1700..1900, y:-90)
    {'x': 2040, 'y': -220}, // Platform 6 (x:1950..2170, y:-160)
    {'x': 2360, 'y': -150}, // Platform 7 (x:2250..2530, y:-90)

    // 🔵 Section 3
    {'x': 2680, 'y': -60}, // Ground 8 (x:2600..2980, y:0)
    {'x': 3370, 'y': -200}, // Platform 10 (x:3300..3480, y:-140)
    {'x': 3630, 'y': -260}, // Platform 11 (x:3550..3750, y:-200)
    {'x': 3950, 'y': -160}, // Ground 12 (x:3850..4100, y:-100)

    // 🔴 Section 4
    {'x': 4230, 'y': -110}, // Platform 13 (x:4150..4350, y:-50)
    {'x': 5080, 'y': -190}, // Platform 16 (x:5000..5200, y:-130)
  ];

  // =========================================================================
  // 🗡️ WEAPON DATA - SULAWESI
  // =========================================================================
  static final List<Map<String, String>> weapons = [
    {
      'id': 'badik_sulawesi', // ✅ ID HARUS SAMA DENGAN WeaponData
      'name': 'Badik Bugis Suci',
    },
  ];

  static final List<Map<String, double>> weaponSpawnPoints = [
    {'x': 5250.0, 'y': -100.0}, // Tepat sebelum Boss Arena
  ];
}
