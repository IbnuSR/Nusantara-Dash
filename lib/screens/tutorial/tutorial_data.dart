import 'package:flutter/material.dart';

/// Direction enum for arrow / callout placement
enum CalloutDirection { top, bottom, left, right, topLeft, topRight, bottomLeft, bottomRight }

/// Model untuk item overlay penunjuk (callout / panah)
class TutorialOverlayItemModel {
  final double x; // Relatif 0.0 - 1.0 dari lebar layar
  final double y; // Relatif 0.0 - 1.0 dari tinggi layar
  final String label;
  final CalloutDirection direction;
  final IconData? icon;
  final Color color;

  const TutorialOverlayItemModel({
    required this.x,
    required this.y,
    required this.label,
    this.direction = CalloutDirection.top,
    this.icon,
    this.color = const Color(0xFFFFD700), // Default Emas
  });
}

/// Model untuk data per halaman Tutorial
class TutorialPageModel {
  final int pageIndex;
  final String title;
  final String? subtitle;
  final String description;
  final String bgImage;
  final List<TutorialOverlayItemModel> overlays;

  const TutorialPageModel({
    required this.pageIndex,
    required this.title,
    this.subtitle,
    required this.description,
    required this.bgImage,
    required this.overlays,
  });
}

/// Repository data statis untuk 6 Halaman Buku Penjelajah Nusantara (Background Ilustrasi Bersih & Fokus)
class TutorialData {
  TutorialData._();

  static const List<TutorialPageModel> pages = [
    // =========================================================
    // PAGE 1: SELAMAT DATANG (Opening - Tidak Ada Callout)
    // =========================================================
    TutorialPageModel(
      pageIndex: 0,
      title: 'Selamat Datang',
      subtitle: 'Buku Penjelajah Nusantara',
      description:
          'Selamat datang di Nusantara Dash. Jelajahi Indonesia, kumpulkan artefak budaya, kalahkan Guardian setiap pulau, dan selamatkan warisan Nusantara.',
      bgImage: 'assets/images/tutorial/page1_menu.png',
      overlays: [],
    ),

    // =========================================================
    // PAGE 2: KONTROL PERMAINAN
    // =========================================================
    TutorialPageModel(
      pageIndex: 1,
      title: 'Kontrol Permainan',
      subtitle: 'Panduan HUD & Tombol Navigasi',
      description:
          'Gunakan Joystick untuk bergerak lincah dan tombol Lompat untuk melompati obstacle. Pantau Nyawa, Coin, dan Kunci Nusantara pada HUD.',
      bgImage: 'assets/images/tutorial/page2_control.png',
      overlays: [
        TutorialOverlayItemModel(
          x: 0.08,
          y: 0.10,
          label: 'Pengaturan',
          direction: CalloutDirection.bottomRight,
          icon: Icons.settings,
        ),
        TutorialOverlayItemModel(
          x: 0.16,
          y: 0.10,
          label: 'Bantuan',
          direction: CalloutDirection.bottomRight,
          icon: Icons.help_outline,
        ),
        TutorialOverlayItemModel(
          x: 0.40,
          y: 0.10,
          label: 'Kunci Nusantara',
          direction: CalloutDirection.bottom,
          icon: Icons.vpn_key,
        ),
        TutorialOverlayItemModel(
          x: 0.65,
          y: 0.10,
          label: 'Coin',
          direction: CalloutDirection.bottomLeft,
          icon: Icons.monetization_on,
        ),
        TutorialOverlayItemModel(
          x: 0.85,
          y: 0.10,
          label: 'Nyawa',
          direction: CalloutDirection.bottomLeft,
          icon: Icons.favorite,
        ),
        TutorialOverlayItemModel(
          x: 0.22,
          y: 0.50,
          label: 'Karakter',
          direction: CalloutDirection.topRight,
          icon: Icons.person,
        ),
        TutorialOverlayItemModel(
          x: 0.12,
          y: 0.72,
          label: 'Joystick',
          direction: CalloutDirection.topRight,
          icon: Icons.control_camera,
        ),
        TutorialOverlayItemModel(
          x: 0.88,
          y: 0.72,
          label: 'Tombol Lompat',
          direction: CalloutDirection.topLeft,
          icon: Icons.arrow_upward,
        ),
      ],
    ),

    // =========================================================
    // PAGE 3: JELAJAHI PULAU
    // =========================================================
    TutorialPageModel(
      pageIndex: 2,
      title: 'Jelajahi Pulau',
      subtitle: 'Eksplorasi & Koleksi Artefak',
      description:
          'Kumpulkan Coin di sepanjang jalan. Temukan Mystery Item tersembunyi. Hindari rintangan bahaya dan pijak platform dengan aman!',
      bgImage: 'assets/images/tutorial/page3_explore.png',
      overlays: [
        TutorialOverlayItemModel(
          x: 0.25,
          y: 0.35,
          label: 'Mystery Item',
          direction: CalloutDirection.topRight,
          icon: Icons.card_giftcard,
        ),
        TutorialOverlayItemModel(
          x: 0.50,
          y: 0.30,
          label: 'Coin',
          direction: CalloutDirection.top,
          icon: Icons.stars,
        ),
        TutorialOverlayItemModel(
          x: 0.45,
          y: 0.68,
          label: 'Obstacle',
          direction: CalloutDirection.topRight,
          icon: Icons.warning_amber,
        ),
        TutorialOverlayItemModel(
          x: 0.75,
          y: 0.65,
          label: 'Platform',
          direction: CalloutDirection.topLeft,
          icon: Icons.layers,
        ),
      ],
    ),

    // =========================================================
    // PAGE 4: QUIZ BATTLE
    // =========================================================
    TutorialPageModel(
      pageIndex: 3,
      title: 'Quiz Battle',
      subtitle: 'Pertarungan Wawasan Nusantara',
      description:
          'Jawaban Benar ➔ HP Boss Berkurang. Jawaban Salah ➔ HP Player Berkurang. Gunakan wawasan budayamu untuk menaklukkan Guardian!',
      bgImage: 'assets/images/tutorial/page4_battle.png',
      overlays: [
        TutorialOverlayItemModel(
          x: 0.20,
          y: 0.12,
          label: 'HP Player',
          direction: CalloutDirection.bottomRight,
          icon: Icons.favorite,
        ),
        TutorialOverlayItemModel(
          x: 0.80,
          y: 0.12,
          label: 'HP Boss',
          direction: CalloutDirection.bottomLeft,
          icon: Icons.shield,
        ),
        TutorialOverlayItemModel(
          x: 0.50,
          y: 0.40,
          label: 'Pertanyaan',
          direction: CalloutDirection.bottom,
          icon: Icons.quiz,
        ),
        TutorialOverlayItemModel(
          x: 0.50,
          y: 0.75,
          label: 'Pilihan Jawaban',
          direction: CalloutDirection.top,
          icon: Icons.touch_app,
        ),
      ],
    ),

    // =========================================================
    // PAGE 5: MUSEUM NUSANTARA
    // =========================================================
    TutorialPageModel(
      pageIndex: 4,
      title: 'Museum Nusantara',
      subtitle: 'Galeri Warisan Budaya Bangsa',
      description:
          'Semua artefak yang ditemukan akan otomatis tersimpan di Museum Nusantara. Pantau progres koleksimu dari tingkat Pulau hingga Indonesia!',
      bgImage: 'assets/images/tutorial/page5_museum.png',
      overlays: [
        TutorialOverlayItemModel(
          x: 0.25,
          y: 0.35,
          label: 'Kategori Pulau',
          direction: CalloutDirection.bottomRight,
          icon: Icons.map,
        ),
        TutorialOverlayItemModel(
          x: 0.50,
          y: 0.15,
          label: 'Progress Indonesia',
          direction: CalloutDirection.bottom,
          icon: Icons.flag,
        ),
        TutorialOverlayItemModel(
          x: 0.75,
          y: 0.35,
          label: 'Progress Pulau',
          direction: CalloutDirection.bottomLeft,
          icon: Icons.bar_chart,
        ),
        TutorialOverlayItemModel(
          x: 0.50,
          y: 0.65,
          label: 'Kartu Artefak',
          direction: CalloutDirection.top,
          icon: Icons.style,
        ),
      ],
    ),

    // =========================================================
    // PAGE 6: SACRED WEAPON
    // =========================================================
    TutorialPageModel(
      pageIndex: 5,
      title: 'Sacred Weapon',
      subtitle: 'Senjata Pusaka Nusantara',
      description:
          'Kalahkan Guardian di setiap pulau, jawab Quiz dengan sempurna, dan dapatkan Sacred Weapon legendaris untuk memperkuat petualanganmu!',
      bgImage: 'assets/images/tutorial/page6_weapon.png',
      overlays: [
        TutorialOverlayItemModel(
          x: 0.50,
          y: 0.20,
          label: 'Kategori Pulau',
          direction: CalloutDirection.bottom,
          icon: Icons.explore,
        ),
        TutorialOverlayItemModel(
          x: 0.30,
          y: 0.45,
          label: 'Senjata Pusaka',
          direction: CalloutDirection.topRight,
          icon: Icons.auto_awesome,
        ),
        TutorialOverlayItemModel(
          x: 0.70,
          y: 0.45,
          label: 'Status Unlock',
          direction: CalloutDirection.topLeft,
          icon: Icons.lock_open,
        ),
      ],
    ),
  ];
}
