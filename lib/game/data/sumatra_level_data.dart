class SumatraLevelData {
  // ✅ PANJANG LEVEL TETAP 6000px
  static const double levelLength = 6000;

  // Platform & Tanah: x=pos horizontal, y=offset dari ground (negatif=atas), w=lebar, h=tinggi
  static final List<Map<String, double>> platforms = [
    // 🟢 SECTION 1: Tutorial / Pemanasan (0 - 1000)
    {'x': 0, 'y': 0, 'w': 600, 'h': 100},
    {'x': 700, 'y': -50, 'w': 200, 'h': 30},
    {'x': 950, 'y': -100, 'w': 150, 'h': 30},

    // 🟡 SECTION 2: Medium Jump (1200 - 2500)
    {'x': 1200, 'y': 0, 'w': 400, 'h': 100},
    {'x': 1700, 'y': -80, 'w': 180, 'h': 30},
    {'x': 1950, 'y': -150, 'w': 200, 'h': 30},
    {'x': 2250, 'y': -80, 'w': 250, 'h': 30},

    // 🔵 SECTION 3: Gap & Tantangan Santai (2600 - 4000)
    {'x': 2600, 'y': 0, 'w': 300, 'h': 100},
    {'x': 3000, 'y': -60, 'w': 150, 'h': 30},
    {'x': 3250, 'y': -120, 'w': 160, 'h': 30},
    {'x': 3500, 'y': -180, 'w': 200, 'h': 30},
    {'x': 3800, 'y': -100, 'w': 200, 'h': 100},

    // 🔴 SECTION 4: Precision Jump (4100 - 5400)
    {'x': 4100, 'y': -50, 'w': 180, 'h': 30},
    {'x': 4350, 'y': -110, 'w': 170, 'h': 30},
    {'x': 4600, 'y': -60, 'w': 250, 'h': 100},
    {'x': 4900, 'y': -130, 'w': 200, 'h': 30},
    {'x': 5200, 'y': -50, 'w': 200, 'h': 100},

    // ⚔️ SECTION 5: Boss Arena (5500 - 6000)
    {'x': 5500, 'y': 0, 'w': 500, 'h': 100},
  ];

  // ✅ PERBAIKAN: Rintangan dikurangi drastis, berjarak jarang-jarang, dan sangat ramah anak-anak
  static final List<Map<String, double>> obstacles = [
    {
      'x': 450,
      'y': -40,
      'w': 40,
      'h': 40,
    }, // Wilayah 1: Hanya ada 1 rintangan di awal untuk latihan melompat
    {
      'x': 1400,
      'y': -40,
      'w': 40,
      'h': 40,
    }, // Wilayah 2: Hanya ada 1 rintangan di area tengah jalan datar
    {
      'x': 2800,
      'y': -40,
      'w': 40,
      'h': 40,
    }, // Wilayah 3: Hanya ada 1 rintangan setelah melewati rintangan jurang
    {
      'x': 4700,
      'y': -100,
      'w': 40,
      'h': 40,
    }, // Wilayah 4: Hanya ada 1 rintangan di dataran tinggi
    {
      'x': 5700,
      'y': -40,
      'w': 40,
      'h': 40,
    }, // Wilayah 5: 1 rintangan terakhir sebelum memasuki area bos
  ];

  // ✅ KOIN TETAP MELIMPAH: Agar anak-anak senang mendapatkan banyak reward poin
  static final List<Map<String, double>> coins = [
    // Section 1
    {'x': 200, 'y': -160}, {'x': 250, 'y': -160}, {'x': 300, 'y': -160},
    {'x': 750, 'y': -100}, {'x': 800, 'y': -100},
    {'x': 1000, 'y': -150},
    // Section 2
    {'x': 1300, 'y': -160}, {'x': 1350, 'y': -160},
    {'x': 1750, 'y': -130}, {'x': 1800, 'y': -130},
    {'x': 2000, 'y': -200}, {'x': 2050, 'y': -200},
    {'x': 2300, 'y': -130}, {'x': 2350, 'y': -130},
    // Section 3
    {'x': 2700, 'y': -160}, {'x': 2750, 'y': -160},
    {'x': 3050, 'y': -110}, {'x': 3100, 'y': -110},
    {'x': 3300, 'y': -170}, {'x': 3350, 'y': -170},
    {'x': 3550, 'y': -230}, {'x': 3600, 'y': -230},
    {'x': 3850, 'y': -150}, {'x': 3900, 'y': -150},
    // Section 4
    {'x': 4150, 'y': -100}, {'x': 4200, 'y': -100},
    {'x': 4400, 'y': -160}, {'x': 4450, 'y': -160},
    {'x': 4650, 'y': -110}, {'x': 4700, 'y': -110},
    {'x': 4950, 'y': -180}, {'x': 5000, 'y': -180},
    {'x': 5250, 'y': -100}, {'x': 5300, 'y': -100},
    // Section 5 (Boss Area)
    {'x': 5600, 'y': -160}, {'x': 5650, 'y': -160},
    {'x': 5750, 'y': -160}, {'x': 5800, 'y': -160},
    {'x': 5900, 'y': -160}, {'x': 5950, 'y': -160},
  ];

  // ======================================================================
  // 🏛️ HIDDEN CULTURAL ITEM — All 8 Sumatra Items & Safe Spawn Points
  // ======================================================================

  /// 8 Item Budaya Baku Pulau Sumatra (1 Item per Provinsi)
  static const List<String> hiddenItemIds = [
    'aceh_001', // Tari Saman (Aceh)
    'bengkulu_001', // Rafflesia Arnoldii (Bengkulu)
    'jambi_001', // Candi Muaro Jambi (Jambi)
    'lampung_001', // Siger (Lampung)
    'medan_001', // Danau Toba (Sumatera Utara)
    'padang_001', // Rumah Gadang (Sumatera Barat)
    'palembang_001', // Pempek (Sumatera Selatan)
    'pekanbaru_001', // Zapin Melayu (Riau)
  ];

  /// 12 Safe Spawn Candidate Locations
  ///
  /// Setiap lokasi divalidasi presisi di atas platform padat dengan margin
  /// standing area aman di kiri & kanan, jauh dari jurang dan obstacle.
  static final List<Map<String, double>> hiddenItemSpawnCandidates = [
    // 🟢 Section 1
    {'x': 300, 'y': -60}, // Ground 1 (x:0..600, y:0)
    {'x': 820, 'y': -110}, // Platform 2 (x:700..900, y:-50)

    // 🟡 Section 2
    {'x': 1300, 'y': -60}, // Ground 4 (x:1200..1600, y:0)
    {'x': 1790, 'y': -140}, // Platform 5 (x:1700..1880, y:-80)
    {'x': 2050, 'y': -210}, // Platform 6 (x:1950..2150, y:-150)
    {'x': 2375, 'y': -140}, // Platform 7 (x:2250..2500, y:-80)

    // 🔵 Section 3
    {'x': 2680, 'y': -60}, // Ground 8 (x:2600..2900, y:0)
    {'x': 3330, 'y': -180}, // Platform 10 (x:3250..3410, y:-120)
    {'x': 3600, 'y': -240}, // Platform 11 (x:3500..3700, y:-180)
    {'x': 3900, 'y': -160}, // Ground 12 (x:3800..4000, y:-100)

    // 🔴 Section 4
    {'x': 4190, 'y': -110}, // Platform 13 (x:4100..4280, y:-50)
    {'x': 4990, 'y': -190}, // Platform 16 (x:4900..5100, y:-130)
  ];
}

