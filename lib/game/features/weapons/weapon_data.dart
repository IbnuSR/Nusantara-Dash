import 'package:flutter/material.dart';
import 'weapon_model.dart';

class WeaponData {
  static final List<Weapon> allWeapons = [
    // 1. SUMATRA - Rencong
    Weapon(
      id: 'rencong_sumatra',
      name: 'Rencong Suci',
      description:
          'Senjata tradisional Aceh yang dianggap suci dan memiliki kekuatan spiritual tinggi. Bentuknya melengkung seperti huruf Bismillah.',
      history:
          'Rencong telah digunakan sejak zaman Kesultanan Aceh Darussalam (abad ke-13). Senjata ini menjadi simbol perlawanan terhadap penjajah Portugis dan Belanda.',
      iconPath: 'assets/images/weapons/rencong.png', // ✅ Polosan (In-Game)
      menuIconPath:
          'assets/images/weapons/rencong_bg.png', // ✅ Ada Background (Menu)
      damage: 50,
      price: 1000,
      isLocked: true,
      rarity: 'legendary',
      origin: 'Sumatra (Aceh)',
      isSacred: true,
    ),

    // 2. JAWA - Keris
    Weapon(
      id: 'keris_jawa',
      name: 'Keris Mpu Gandring',
      description:
          'Keris legendaris dengan bilah bergelombang (luk) yang dipercaya memiliki kekuatan supranatural.',
      history:
          'Keris Mpu Gandring berasal dari legenda Kerajaan Singhasari (abad ke-13). Dibuat oleh Empu Gandring, keris ini terkenal karena kutukannya.',
      iconPath: 'assets/images/weapons/keris.png',
      menuIconPath: 'assets/images/weapons/keris_bg.png',
      damage: 55,
      price: 1200,
      isLocked: true,
      rarity: 'legendary',
      origin: 'Jawa (Singhasari)',
      isSacred: true,
    ),

    // 3. KALIMANTAN - Mandau
    Weapon(
      id: 'mandau_kalimantan',
      name: 'Mandau Dayak Suci',
      description:
          'Pedang tradisional suku Dayak dengan ukiran rumit yang melambangkan hubungan dengan roh leluhur dan alam.',
      history:
          'Mandau adalah senjata sakral suku Dayak di Kalimantan yang telah ada sejak ribuan tahun lalu. Dibuat dari besi meteorit.',
      iconPath: 'assets/images/weapons/mandau.png',
      menuIconPath: 'assets/images/weapons/mandau_bg.png',
      damage: 52,
      price: 1100,
      isLocked: true,
      rarity: 'legendary',
      origin: 'Kalimantan (Dayak)',
      isSacred: true,
    ),

    // 4. SULAWESI - Badik
    Weapon(
      id: 'badik_sulawesi',
      name: 'Badik Bugis Suci',
      description:
          'Senjata tradisional Sulawesi Selatan dengan bentuk asimetris yang unik. Dipercaya melindungi dari roh jahat.',
      history:
          'Badik berasal dari Kerajaan Bugis dan Makassar. Dianggap sebagai "saudara" yang melindungi pemakainya dari bahaya.',
      iconPath: 'assets/images/weapons/badik.png',
      menuIconPath: 'assets/images/weapons/badik_bg.png',
      damage: 48,
      price: 1050,
      isLocked: true,
      rarity: 'legendary',
      origin: 'Sulawesi (Bugis-Makassar)',
      isSacred: true,
    ),

    // 5. PAPUA - Belati Asmat
    Weapon(
      id: 'belati_papua',
      name: 'Belati Asmat Suci',
      description:
          'Pisau tradisional suku Asmat dari Papua yang terbuat dari tulang kasuari. Dihiasi ukiran leluhur.',
      history:
          'Terbuat dari tulang kaki burung kasuari yang tajam. Simbol kedewasaan dan keberanian pria Asmat.',
      iconPath: 'assets/images/weapons/belati.png',
      menuIconPath: 'assets/images/weapons/belati_bg.png',
      damage: 50,
      price: 1000,
      isLocked: true,
      rarity: 'legendary',
      origin: 'Papua (Asmat)',
      isSacred: true,
    ),

    // 6. SENJATA GABUNGAN
    Weapon(
      id: 'nusantara_blade',
      name: 'Nusantara Blade',
      description:
          'Senjata legendaris yang menggabungkan kekuatan spiritual dari 5 senjata suci Nusantara.',
      history:
          'Hanya muncul ketika seorang pejuang telah membuktikan keberanian dengan menguasai 5 senjata suci dari 5 pulau utama.',
      iconPath: 'assets/images/weapons/nusantara_blade.png',
      menuIconPath: 'assets/images/weapons/nusantara_blade_bg.png',
      damage: 100,
      price: 0,
      isLocked: true,
      rarity: 'legendary',
      origin: 'Nusantara (Gabungan)',
      isSacred: true,
      isCombined: true,
    ),
  ];

  static Weapon? getWeaponById(String id) {
    try {
      return allWeapons.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  static Color getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return const Color(0xFFB0BEC5);
      case 'rare':
        return const Color(0xFF42A5F5);
      case 'epic':
        return const Color(0xFFAB47BC);
      case 'legendary':
        return const Color(0xFFFFA726);
      default:
        return Colors.white;
    }
  }

  static bool hasAllSacredWeapons(List<String> ownedWeapons) {
    final sacredWeapons =
        allWeapons.where((w) => w.isSacred && !w.isCombined).toList();
    return sacredWeapons.every((w) => ownedWeapons.contains(w.id));
  }

  static Weapon? getCombinedWeapon() {
    try {
      return allWeapons.firstWhere((w) => w.isCombined);
    } catch (e) {
      return null;
    }
  }
}
