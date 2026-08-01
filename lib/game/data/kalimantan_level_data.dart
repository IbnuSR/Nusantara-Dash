class KalimantanLevelData {
  // ✅ PANJANG LEVEL TETAP 6000px
  static const double levelLength = 6000;

  static final List<Map<String, double>> platforms = [
    // 🟢 SECTION 1: Tutorial (0 - 1050)
    {'x': 0, 'y': 0, 'w': 600, 'h': 100},
    {'x': 680, 'y': -70, 'w': 220, 'h': 30},
    {'x': 950, 'y': -140, 'w': 180, 'h': 30},

    // 🟡 SECTION 2: Medium Jump (1150 - 2500)
    {'x': 1150, 'y': -50, 'w': 400, 'h': 100},
    {'x': 1600, 'y': -100, 'w': 200, 'h': 30},
    {'x': 1850, 'y': -160, 'w': 220, 'h': 30},
    {'x': 2150, 'y': -80, 'w': 300, 'h': 30},

    // 🔵 SECTION 3: Gap & Tantangan Santai (2550 - 4000)
    {'x': 2550, 'y': 0, 'w': 400, 'h': 100},
    {'x': 3000, 'y': -80, 'w': 180, 'h': 30},
    {'x': 3250, 'y': -150, 'w': 180, 'h': 30},
    {'x': 3500, 'y': -220, 'w': 220, 'h': 30},
    {'x': 3800, 'y': -120, 'w': 250, 'h': 100},

    // 🔴 SECTION 4: Precision Jump (4100 - 5400)
    {'x': 4100, 'y': -70, 'w': 200, 'h': 30},
    {'x': 4350, 'y': -130, 'w': 200, 'h': 30},
    {'x': 4600, 'y': -60, 'w': 280, 'h': 100},
    {'x': 4950, 'y': -140, 'w': 220, 'h': 30},
    {'x': 5200, 'y': -60, 'w': 250, 'h': 100},

    // ⚔️ SECTION 5: Boss Arena (5500 - 6000)
    {'x': 5500, 'y': 0, 'w': 500, 'h': 100},
  ];

  // ✅ PERBAIKAN: Rintangan di TENGAH platform, memberi ruang aman mendarat
  static final List<Map<String, double>> obstacles = [
    {
      'x': 300,
      'y': -40,
      'w': 40,
      'h': 40
    }, // Wilayah 1: Di tengah platform 0..600
    {
      'x': 1320,
      'y': -90,
      'w': 40,
      'h': 40
    }, // Wilayah 2: Di tengah platform 1150..1550
    {
      'x': 2730,
      'y': -40,
      'w': 40,
      'h': 40
    }, // Wilayah 3: Di tengah platform 2550..2950
    {
      'x': 4720,
      'y': -100,
      'w': 40,
      'h': 40
    }, // Wilayah 4: Di tengah platform 4600..4880
    {
      'x': 5310,
      'y': -100,
      'w': 40,
      'h': 40
    }, // Wilayah 5: Di tengah platform 5200..5450
  ];

  // ✅ KOIN MELIMPAH
  static final List<Map<String, double>> coins = [
    // Section 1
    {'x': 200, 'y': -160}, {'x': 250, 'y': -160}, {'x': 300, 'y': -160},
    {'x': 750, 'y': -120}, {'x': 800, 'y': -120},
    {'x': 1000, 'y': -190},
    // Section 2
    {'x': 1250, 'y': -210}, {'x': 1300, 'y': -210}, {'x': 1350, 'y': -210},
    {'x': 1680, 'y': -150}, {'x': 1730, 'y': -150},
    {'x': 1930, 'y': -210}, {'x': 1980, 'y': -210},
    {'x': 2250, 'y': -130}, {'x': 2300, 'y': -130},
    // Section 3
    {'x': 2680, 'y': -160}, {'x': 2730, 'y': -160},
    {'x': 3080, 'y': -130}, {'x': 3130, 'y': -130},
    {'x': 3330, 'y': -200}, {'x': 3380, 'y': -200},
    {'x': 3580, 'y': -270}, {'x': 3630, 'y': -270},
    {'x': 3900, 'y': -170}, {'x': 3950, 'y': -170},
    // Section 4
    {'x': 4180, 'y': -120}, {'x': 4230, 'y': -120},
    {'x': 4430, 'y': -180}, {'x': 4480, 'y': -180},
    {'x': 4720, 'y': -220}, {'x': 4770, 'y': -220},
    {'x': 5030, 'y': -190}, {'x': 5080, 'y': -190},
    {'x': 5300, 'y': -110}, {'x': 5350, 'y': -110},
    // Section 5 (Boss Area)
    {'x': 5600, 'y': -160}, {'x': 5650, 'y': -160},
    {'x': 5750, 'y': -160}, {'x': 5800, 'y': -160},
  ];

  // ======================================================================
  // 🏛️ HIDDEN CULTURAL ITEM — All 8 Kalimantan Items & Safe Spawn Points
  // ======================================================================

  /// 8 Item Budaya Baku Pulau Kalimantan (1 Item per Provinsi/Kawasan)
  static const List<String> hiddenItemIds = [
    'kalbar_001', // Tugu Khatulistiwa (Kalimantan Barat)
    'kalteng_001', // Rumah Betang (Kalimantan Tengah)
    'kaltim_001', // Burung Enggang (Kalimantan Timur)
    'kalsel_001', // Pasar Apung (Kalimantan Selatan)
    'kaltara_001', // Sape (Kalimantan Utara)
    'kalimantan_001', // Orangutan (Hutan Kalimantan)
    'kalimantan_002', // Batik Dayak (Seni Dayak)
    'kalimantan_003', // Soto Banjar (Kuliner Kalimantan)
  ];

  /// 12 Safe Spawn Candidate Locations
  ///
  /// Setiap lokasi divalidasi presisi di atas platform padat dengan margin
  /// standing area aman di kiri & kanan, jauh dari jurang dan obstacle.
  static final List<Map<String, double>> hiddenItemSpawnCandidates = [
    // 🟢 Section 1
    {'x': 180, 'y': -60}, // Ground 1 (x:0..600, y:0)
    {'x': 770, 'y': -130}, // Platform 2 (x:680..900, y:-70)

    // 🟡 Section 2
    {'x': 1220, 'y': -110}, // Ground 4 (x:1150..1550, y:-50)
    {'x': 1680, 'y': -160}, // Platform 5 (x:1600..1800, y:-100)
    {'x': 1940, 'y': -220}, // Platform 6 (x:1850..2070, y:-160)
    {'x': 2280, 'y': -140}, // Platform 7 (x:2150..2450, y:-80)

    // 🔵 Section 3
    {'x': 2630, 'y': -60}, // Ground 8 (x:2550..2950, y:0)
    {'x': 3320, 'y': -210}, // Platform 10 (x:3250..3430, y:-150)
    {'x': 3590, 'y': -280}, // Platform 11 (x:3500..3720, y:-220)
    {'x': 3900, 'y': -180}, // Ground 12 (x:3800..4050, y:-120)

    // 🔴 Section 4
    {'x': 4180, 'y': -130}, // Platform 13 (x:4100..4300, y:-70)
    {'x': 5040, 'y': -200}, // Platform 16 (x:4950..5170, y:-140)
  ];

  // =========================================================================
  // 🗡️ WEAPON DATA - KALIMANTAN
  // =========================================================================
  static final List<Map<String, String>> weapons = [
    {
      'id': 'mandau_kalimantan', // ✅ ID HARUS SAMA DENGAN WeaponData
      'name': 'Mandau Dayak Suci',
    },
  ];

  static final List<Map<String, double>> weaponSpawnPoints = [
    {'x': 5200.0, 'y': -110.0}, // Tepat sebelum Boss Arena
  ];
}
