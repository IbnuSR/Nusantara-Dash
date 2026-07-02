import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../prologue_screen.dart';
import '../../game/game_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late AnimationController _fadeInController;
  late Animation<double> _fadeInAnimation;

  // ✅ WIDGET ANIMASI BERDETAK (PULSE) DITAMBAHKAN
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final double _mapWidth = 1672.0;
  final double _mapHeight = 941.0;

  final List<Map<String, dynamic>> _islands = [
    {
      'name': 'SUMATRA',
      'subtitle': 'Rimba Harimau',
      'icon': '🐯',
      'boss': 'Sang Belang',
      'weapon': 'Rencong Suci',
      'color': const Color(0xFF4CAF50),
      'accentColor': const Color(0xFF81C784),
      'unlocked': true, // 🟢 Terbuka: Akan berdetak!
      'description': 'Hutan lebat penuh misteri, tempat Sang Belang mengaum',
      'x': 0.17,
      'y': 0.40,
      'size': 260.0,
      'image_path': 'assets/images/ui/sumatra_active.png',
    },
    {
      'name': 'JAWA',
      'subtitle': 'Tanah Raksasa',
      'icon': '👹',
      'boss': 'Buto Amuka',
      'weapon': 'Keris Pusaka',
      'color': const Color(0xFF2196F3),
      'accentColor': const Color(0xFF64B5F6),
      'unlocked': false, // 🔴 Terkunci: Diam saja
      'description': 'Gunung berapi yang mengamuk, rumah Buto Amuka',
      'x': 0.34,
      'y': 0.60,
      'size': 240.0,
      'image_path': 'assets/images/ui/jawa_locked.png',
    },
    {
      'name': 'KALIMANTAN',
      'subtitle': 'Hutan Terkutuk',
      'icon': '🦅',
      'boss': 'Enggang Gading',
      'weapon': 'Mandau Sakti',
      'color': const Color(0xFF9C27B0),
      'accentColor': const Color(0xFFBA68C8),
      'unlocked': false,
      'description': 'Hutan belantara tempat Enggang Gading menebar racun',
      'x': 0.46,
      'y': 0.38,
      'size': 240.0,
      'image_path': 'assets/images/ui/kalimantan_locked.png',
    },
    {
      'name': 'SULAWESI',
      'subtitle': 'Samudra Gelap',
      'icon': '🌊',
      'boss': 'Naga Phinisi',
      'weapon': 'Badik Keramat',
      'color': const Color(0xFFFF9800),
      'accentColor': const Color(0xFFFFB74D),
      'unlocked': false,
      'description': 'Perairan luas tempat Naga Phinisi menguasai lautan',
      'x': 0.65,
      'y': 0.46,
      'size': 240.0,
      'image_path': 'assets/images/ui/sulawesi_locked.png',
    },
    {
      'name': 'PAPUA',
      'subtitle': 'Puncak Ilusi',
      'icon': '🦜',
      'boss': 'Sang Cendrawasih',
      'weapon': 'Busur Kasuari',
      'color': const Color(0xFFE91E63),
      'accentColor': const Color(0xFFF06292),
      'unlocked': false,
      'description': 'Puncak Jayawijaya tempat Sang Cendrawasih menebar ilusi',
      'x': 0.85,
      'y': 0.45,
      'size': 240.0,
      'image_path': 'assets/images/ui/papua_locked.png',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Animasi muncul perlahan
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.easeIn),
    );
    _fadeInController.forward();

    // ✅ Inisialisasi animasi detak jantung berulang (Looping)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true); // Bergerak bolak-balik tanpa henti

    // Efek skala: membesar sedikit (1.05) dan mengecil (0.95)
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  void _tontonUlangPrologue() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrologueScreen()),
    );
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _pulseController.dispose(); // ✅ Jangan lupa dibuang agar tidak bocor memori
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
                        children: _islands.map((island) {
                          return _buildIslandMarker(island);
                        }).toList(),
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

    // Tombol dasarnya
    Widget islandButton = BouncyImageButton(
      width: size,
      height: size,
      imagePath: imagePath,
      onPressed: () => _showIslandDetail(island),
    );

    return Positioned(
      left: x - size / 2,
      top: y - size / 2,
      // ✅ LOGIKA KUNCI: Jika pulau terbuka, bungkus tombol dengan efek detak jantung!
      child: isUnlocked
          ? ScaleTransition(
              scale: _pulseAnimation,
              child: islandButton,
            )
          : islandButton, // Kalau terkunci, biarkan diam.
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
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
            ),
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
                      Shadow(color: Colors.black, offset: Offset(2, 2)),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                border: Border.all(color: const Color(0xFF81C784), width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                ],
              ),
              child: Text(
                '$pulauSelesai/5 SELESAI',
                style: GoogleFonts.pressStart2p(
                  color: Colors.white,
                  fontSize: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIslandDetail(Map<String, dynamic> island) {
    final isUnlocked = island['unlocked'] as bool;
    final color = island['color'] as Color;
    final accentColor = island['accentColor'] as Color;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final safeAreaTop = MediaQuery.of(context).padding.top;
        final safeAreaBottom = MediaQuery.of(context).padding.bottom;
        final availableHeight = screenHeight - safeAreaTop - safeAreaBottom;
        final maxModalHeight = availableHeight * 0.85;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxModalHeight),
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isUnlocked
                      ? color.withOpacity(0.95)
                      : Colors.grey[800]!.withOpacity(0.95),
                  isUnlocked
                      ? color.withOpacity(0.7)
                      : Colors.grey[900]!.withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: isUnlocked ? Colors.amber : Colors.grey[600]!,
                  width: 3),
              boxShadow: [
                BoxShadow(
                    color: (isUnlocked ? color : Colors.black).withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 3),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3),
                      border: Border.all(
                          color: isUnlocked ? Colors.amber : Colors.grey[600]!,
                          width: 3),
                    ),
                    child: Text(island['icon'] as String,
                        style: const TextStyle(fontSize: 56)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    island['name'] as String,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.white : Colors.grey[400],
                      letterSpacing: 3,
                      shadows: const [
                        Shadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 5)
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    island['subtitle'] as String,
                    style: TextStyle(
                        fontSize: 14,
                        color: isUnlocked ? accentColor : Colors.grey[500],
                        fontStyle: FontStyle.italic,
                        letterSpacing: 2),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    island['description'] as String,
                    style: TextStyle(
                        fontSize: 15,
                        color: isUnlocked ? Colors.white : Colors.grey[400],
                        height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                          '⚔️ BOSS', island['boss'] as String, isUnlocked),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildInfoItem('🗡️ SENJATA', island['weapon'] as String,
                          isUnlocked),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (isUnlocked)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GameScreen(
                                    islandName: island['name'] as String)));
                      },
                      icon: const Icon(Icons.play_arrow, size: 28),
                      label: const Text('MULAI PETUALANGAN',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red, width: 2)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, color: Colors.red, size: 24),
                          SizedBox(width: 10),
                          Text('PULAU TERKUNCI',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2)),
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

  Widget _buildInfoItem(String label, String value, bool isUnlocked) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: isUnlocked ? Colors.white70 : Colors.grey[500],
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 15,
                color: isUnlocked ? Colors.white : Colors.grey[400],
                fontWeight: FontWeight.bold)),
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
            fit: BoxFit.contain, // Menampilkan seluruh foto tanpa crop
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
