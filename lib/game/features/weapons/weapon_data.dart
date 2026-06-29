import 'package:flutter/material.dart';
import 'weapon_model.dart';

class WeaponData {
  static final List<Weapon> allWeapons = [
    // ✅ 5 SENJATA SUCI DARI 5 PULAU

    // 1. SUMATRA - Rencong
    Weapon(
      id: 'rencong_sumatra',
      name: 'Rencong Suci',
      description:
          'Senjata tradisional Aceh yang dianggap suci dan memiliki kekuatan spiritual tinggi. Bentuknya melengkung seperti huruf Bismillah.',
      history:
          'Rencong telah digunakan sejak zaman Kesultanan Aceh Darussalam (abad ke-13). Senjata ini menjadi simbol perlawanan terhadap penjajah Portugis dan Belanda. Para pejuang Aceh percaya rencong memiliki kekuatan mistis yang melindungi pemakainya. Setiap rencong dibuat dengan doa dan ritual khusus oleh pandai besi tradisional.',
      iconPath: 'assets/images/weapons/rencong.png',
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
          'Keris legendaris dengan bilah bergelombang (luk) yang dipercaya memiliki kekuatan supranatural. Dihuni oleh roh leluhur yang melindungi pemakainya.',
      history:
          'Keris Mpu Gandring berasal dari legenda Kerajaan Singhasari (abad ke-13). Dibuat oleh Empu Gandring, keris ini terkenal karena kutukannya yang menyebabkan kematian Raja Ken Arok dan turunannya. Keris Jawa dianggap sebagai pusaka keramat yang memiliki "semangat" atau "dhomit". Pembuatannya melibatkan ritual spiritual dan puasa selama berhari-hari.',
      iconPath: 'assets/images/weapons/keris.png',
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
          'Pedang tradisional suku Dayak dengan ukiran rumit yang melambangkan hubungan dengan roh leluhur dan alam. Bilahnya terbuat dari besi meteorit.',
      history:
          'Mandau adalah senjata sakral suku Dayak di Kalimantan yang telah ada sejak ribuan tahun lalu. Setiap mandau dibuat dengan ritual khusus dan dipercaya memiliki kekuatan spiritual. Ukiran pada mandau menggambarkan burung enggang (hornbill) yang dianggap sebagai utusan dewa. Para pejuang Dayak membawa mandau dalam perang adat dan upacara keagamaan. Mandau yang asli dibuat dari besi meteorit yang jatuh dari langit.',
      iconPath: 'assets/images/weapons/mandau.png',
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
          'Senjata tradisional Sulawesi Selatan dengan bentuk asimetris yang unik. Dipercaya memiliki kekuatan untuk melindungi dari roh jahat dan membawa keberuntungan.',
      history:
          'Badik berasal dari Kerajaan Bugis dan Makassar di Sulawesi Selatan (abad ke-14). Senjata ini menjadi simbol status sosial dan keberanian. Setiap badik memiliki nama dan cerita tersendiri. Para pelaut Bugis membawa badik dalam perjalanan mereka ke seluruh Nusantara. Badik dianggap sebagai "saudara" yang melindungi pemakainya dari bahaya dan roh jahat. Pembuatan badik melibatkan ritual dan doa dari dukun atau bissu (pendeta tradisional).',
      iconPath: 'assets/images/weapons/badik.png',
      damage: 48,
      price: 1050,
      isLocked: true,
      rarity: 'legendary',
      origin: 'Sulawesi (Bugis-Makassar)',
      isSacred: true,
    ),

    // 5. PAPUA - Pisau Belati Asmat
    Weapon(
      id: 'belati_papua',
      name: 'Belati Asmat Suci',
      description:
          'Pisau tradisional suku Asmat dari Papua yang terbuat dari tulang kasuari. Dihiasi ukiran yang melambangkan hubungan dengan roh leluhur dan alam Papua.',
      history:
          'Belati suku Asmat di Papua telah digunakan selama ribuan tahun. Terbuat dari tulang kaki burung kasuari yang tajam dan kuat, belati ini menjadi simbol kedewasaan dan keberanian pria Asmat. Setiap belati dibuat dengan ukiran yang menceritakan kisah leluhur atau roh pelindung. Suku Asmat percaya bahwa belati memiliki kekuatan spiritual yang menghubungkan pemakainya dengan dunia roh. Belati digunakan dalam upacara inisiasi, perang adat, dan ritual keagamaan.',
      iconPath: 'assets/images/weapons/belati.png',
      damage: 50,
      price: 1000,
      isLocked: true,
      rarity: 'legendary',
      origin: 'Papua (Asmat)',
      isSacred: true,
    ),

    // ✅ 1 SENJATA GABUNGAN (UNLOCK JIKA KE-5 SENJATA SUCI DIMILIKI)
    Weapon(
      id: 'nusantara_blade',
      name: 'Nusantara Blade',
      description:
          'Senjata legendaris yang menggabungkan kekuatan spiritual dari 5 senjata suci Nusantara. Hanya bisa diperoleh oleh Guardian yang telah menguasai semua senjata suci.',
      history:
          'Nusantara Blade adalah senjata mitologis yang hanya muncul dalam legenda kuno Nusantara. Dikatakan bahwa senjata ini diciptakan oleh para dewa untuk melindungi kepulauan Nusantara dari ancaman besar. Senjata ini hanya muncul ketika seorang pejuang telah membuktikan keberanian dan kebijaksanaannya dengan menguasai 5 senjata suci dari 5 pulau utama. Nusantara Blade memiliki kekuatan untuk menyatukan energi spiritual dari seluruh Nusantara dan memberikan kekuatan maksimal kepada pemakainya.',
      iconPath: 'assets/images/weapons/nusantara_blade.png',
      damage: 100,
      price: 0, // GRATIS jika sudah punya 5 senjata suci
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

  // ✅ METHOD BARU: Cek apakah semua senjata suci sudah dimiliki
  static bool hasAllSacredWeapons(List<String> ownedWeapons) {
    final sacredWeapons =
        allWeapons.where((w) => w.isSacred && !w.isCombined).toList();
    return sacredWeapons.every((w) => ownedWeapons.contains(w.id));
  }

  // ✅ METHOD BARU: Dapatkan senjata gabungan
  static Weapon? getCombinedWeapon() {
    try {
      return allWeapons.firstWhere((w) => w.isCombined);
    } catch (e) {
      return null;
    }
  }
}
