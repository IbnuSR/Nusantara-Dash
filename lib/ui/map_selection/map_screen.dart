import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../prologue_screen.dart';
import '../../game/game_screen.dart';
import 'package:nusantara_dash/utils/audio_manager.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late AnimationController _fadeInController;
  late Animation<double> _fadeInAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final double _mapWidth = 1672.0;
  final double _mapHeight = 941.0;

  // ✅ DITAMBAHKAN: 'boss_image' untuk menggantikan emoticon
  final List<Map<String, dynamic>> _islands = [
    {
      'name': 'SUMATRA',
      'subtitle': 'Rimba Harimau',
      'icon': '🐯', // Sebagai cadangan (fallback) jika gambar belum ada
      'boss': 'Sang Belang',
      'weapon': 'Rencong Suci',
      'unlocked': true,
      'description': 'Hutan lebat penuh misteri, tempat Sang Belang mengaum',
      'x': 0.17,
      'y': 0.40,
      'size': 260.0,
      'image_path': 'assets/images/ui/sumatra_active.png',
      'boss_image': 'assets/images/ui/avatar_sumatra.png', // Aset baru
    },
    {
      'name': 'JAWA',
      'subtitle': 'Tanah Raksasa',
      'icon': '👹',
      'boss': 'Buto Amuka',
      'weapon': 'Keris Pusaka',
      'unlocked': false,
      'description': 'Gunung berapi yang mengamuk, rumah Buto Amuka',
      'x': 0.34,
      'y': 0.60,
      'size': 240.0,
      'image_path': 'assets/images/ui/jawa_locked.png',
      'boss_image': 'assets/images/ui/avatar_jawa.png', // Aset baru
    },
    {
      'name': 'KALIMANTAN',
      'subtitle': 'Hutan Terkutuk',
      'icon': '🦅',
      'boss': 'Enggang Gading',
      'weapon': 'Mandau Sakti',
      'unlocked': false,
      'description': 'Hutan belantara tempat Enggang Gading menebar racun',
      'x': 0.46,
      'y': 0.38,
      'size': 240.0,
      'image_path': 'assets/images/ui/kalimantan_locked.png',
      'boss_image': 'assets/images/ui/avatar_kalimantan.png', // Aset baru
    },
    {
      'name': 'SULAWESI',
      'subtitle': 'Samudra Gelap',
      'icon': '🌊',
      'boss': 'Naga Phinisi',
      'weapon': 'Badik Keramat',
      'unlocked': false,
      'description': 'Perairan luas tempat Naga Phinisi menguasai lautan',
      'x': 0.65,
      'y': 0.46,
      'size': 240.0,
      'image_path': 'assets/images/ui/sulawesi_locked.png',
      'boss_image': 'assets/images/ui/avatar_sulawesi.png', // Aset baru
    },
    {
      'name': 'PAPUA',
      'subtitle': 'Puncak Ilusi',
      'icon': '🦜',
      'boss': 'Sang Cendrawasih',
      'weapon': 'Busur Kasuari',
      'unlocked': false,
      'description': 'Puncak Jayawijaya tempat Sang Cendrawasih menebar ilusi',
      'x': 0.85,
      'y': 0.45,
      'size': 240.0,
      'image_path': 'assets/images/ui/papua_locked.png',
      'boss_image': 'assets/images/ui/avatar_papua.png', // Aset baru
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.easeIn),
    );
    _fadeInController.forward();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  void _tontonUlangPrologue() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const PrologueScreen()));
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031525),
      body: Stack(
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              child: SizedBox(
                width: _mapWidth,
                height: _mapHeight,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/ui/indonesia_map_pixel.png',
                      width: _mapWidth,
                      height: _mapHeight,
                      fit: BoxFit.fill,
                    ),
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: Stack(
                        children: _islands
                            .map((island) => _buildIslandMarker(island))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeader(),
                _buildBottomInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIslandMarker(Map<String, dynamic> island) {
    final x = (island['x'] as double) * _mapWidth;
    final y = (island['y'] as double) * _mapHeight;
    final size = island['size'] as double;
    final imagePath = island['image_path'] as String;
    final isUnlocked = island['unlocked'] as bool;

    Widget islandButton = BouncyImageButton(
      width: size,
      height: size,
      imagePath: imagePath,
      onPressed: () => _showIslandDetail(island),
    );

    return Positioned(
      left: x - size / 2,
      top: y - size / 2,
      child: isUnlocked
          ? ScaleTransition(scale: _pulseAnimation, child: islandButton)
          : islandButton,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BouncyImageButton(
            width: 45,
            height: 45,
            imagePath: 'assets/images/ui/btn_back.png',
            onPressed: () => Navigator.pop(context),
          ),
          Image.asset(
            'assets/images/ui/title_peta.png',
            height: 40,
            fit: BoxFit.contain,
          ),
          BouncyImageButton(
            width: 120,
            height: 40,
            imagePath: 'assets/images/ui/btn_prologue.png',
            onPressed: _tontonUlangPrologue,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo() {
    int pulauSelesai = 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          border: Border.all(color: const Color(0xFFD4AF37), width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.touch_app, color: Colors.amber, size: 20),
                const SizedBox(width: 10),
                Text(
                  'TAP PULAU',
                  style: GoogleFonts.pressStart2p(
                      color: Colors.white,
                      fontSize: 10,
                      shadows: const [
                        Shadow(color: Colors.black, offset: Offset(2, 2))
                      ]),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                border: Border.all(color: const Color(0xFF81C784), width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(2, 2))
                ],
              ),
              child: Text(
                '$pulauSelesai/5 SELESAI',
                style:
                    GoogleFonts.pressStart2p(color: Colors.white, fontSize: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

// ✅ MODAL DIROMBAK TOTAL MENJADI TEMA DARK RETRO RPG
  void _showIslandDetail(Map<String, dynamic> island) {
    final isUnlocked = island['unlocked'] as bool;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final availableHeight = MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: availableHeight * 0.85),
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // ✅ TEMA GELAP: Gradasi Biru Dongker ke Hitam (seperti dasar laut/malam)
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isUnlocked
                    ? [const Color(0xFF0F172A), const Color(0xFF020617)]
                    : [Colors.grey[900]!, Colors.black],
              ),
              // Sudut kotak tegas khas pixel art
              borderRadius: BorderRadius.circular(0),
              // Bingkai emas (Amber) jika terbuka, abu-abu jika terkunci
              border: Border.all(
                color: isUnlocked ? const Color(0xFFD4AF37) : Colors.grey[700]!,
                width: 4,
              ),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black,
                    offset: Offset(8, 8)), // Hard shadow khas retro
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // WADAH GAMBAR BOS/IKON
                  Container(
                    width: 90,
                    height: 90,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      border: Border.all(
                        color: isUnlocked
                            ? const Color(0xFFD4AF37)
                            : Colors.grey[600]!,
                        width: 3,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                      ],
                    ),
                    child: Image.asset(
                      island['boss_image'] as String,
                      fit: BoxFit
                          .contain, // ✅ Menampilkan seluruh foto tanpa crop
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(island['icon'] as String,
                            style: const TextStyle(fontSize: 40)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // NAMA PULAU (Warna Emas)
                  Text(
                    island['name'] as String,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 20,
                      color: isUnlocked ? Colors.amber : Colors.grey[400],
                      shadows: const [
                        Shadow(color: Colors.black, offset: Offset(3, 3))
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // SUBTITLE (Warna Abu-abu Terang)
                  Text(
                    island['subtitle'] as String,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: isUnlocked ? Colors.white70 : Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // DESKRIPSI (Warna Putih)
                  Text(
                    island['description'] as String,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 9,
                      color: isUnlocked ? Colors.white : Colors.grey[500],
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // INFO BOSS & SENJATA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _buildInfoItem(
                              'BOSS', island['boss'] as String, isUnlocked)),
                      Container(
                          width: 2,
                          height: 30,
                          color: isUnlocked
                              ? Colors.amber.withOpacity(0.5)
                              : Colors.grey[800]),
                      Expanded(
                          child: _buildInfoItem('SENJATA',
                              island['weapon'] as String, isUnlocked)),
                    ],
                  ),
                  const SizedBox(height: 35),

                  // TOMBOL MULAI (Warna Emas dengan Teks Hitam agar mencolok)
                  if (isUnlocked)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GameScreen(
                                    islandName: island['name'] as String)));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.amber, // Tombol emas
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black, offset: Offset(4, 4))
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_arrow,
                                color: Colors.black, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'MULAI PETUALANGAN',
                              style: GoogleFonts.pressStart2p(
                                  fontSize: 10, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.red, width: 2),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.redAccent, offset: Offset(4, 4))
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock, color: Colors.red, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'PULAU TERKUNCI',
                            style: GoogleFonts.pressStart2p(
                                color: Colors.red, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// ✅ DESAIN INFO ITEM (TEKS BOSS & SENJATA)
  Widget _buildInfoItem(String label, String value, bool isUnlocked) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.pressStart2p(
            fontSize: 7,
            color: isUnlocked
                ? Colors.amber
                : Colors.grey[600], // Label warna emas
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: GoogleFonts.pressStart2p(
            fontSize: 9,
            color: isUnlocked
                ? Colors.white
                : Colors.grey[500], // Value warna putih
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// =====================================================================
// KELAS WIDGET: Efek Tombol Gambar Memantul (Bouncy Effect saat Ditekan)
// =====================================================================
class BouncyImageButton extends StatefulWidget {
  final double width;
  final double height;
  final String imagePath;
  final VoidCallback onPressed;

  const BouncyImageButton({
    super.key,
    required this.width,
    required this.height,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  State<BouncyImageButton> createState() => _BouncyImageButtonState();
}

class _BouncyImageButtonState extends State<BouncyImageButton>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.0,
      upperBound: 0.15,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _tapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _tapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;

    return GestureDetector(
      onTapDown: _tapDown,
      onTapUp: _tapUp,
      onTapCancel: _tapCancel,
      child: Transform.scale(
        scale: _scale,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Image.asset(
            widget.imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: const Center(
                  child:
                      Icon(Icons.broken_image, color: Colors.white, size: 24)),
            ),
          ),
        ),
      ),
    );
  }
}
