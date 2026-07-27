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
}