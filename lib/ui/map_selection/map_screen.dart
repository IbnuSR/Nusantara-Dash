import 'package:flutter/material.dart';
import '../prologue_screen.dart';
import '../../game/game_screen.dart'; // ✅ TAMBAHKAN IMPORT INI

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeInController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeInAnimation;

  // Data 5 Pulau dengan posisi relatif di peta Indonesia
  final List<Map<String, dynamic>> _islands = [
    {
      'name': 'SUMATRA',
      'subtitle': 'Rimba Harimau',
      'icon': '🐯',
      'boss': 'Sang Belang',
      'weapon': 'Rencong Suci',
      'color': const Color(0xFF4CAF50),
      'accentColor': const Color(0xFF81C784),
      'unlocked': true,
      'completed': false,
      'description': 'Hutan lebat penuh misteri, tempat Sang Belang mengaum',
      'x': 0.18,
      'y': 0.40,
      'size': 90.0,
    },
    {
      'name': 'JAWA',
      'subtitle': 'Tanah Raksasa',
      'icon': '👹',
      'boss': 'Buto Amuka',
      'weapon': 'Keris Pusaka',
      'color': const Color(0xFF2196F3),
      'accentColor': const Color(0xFF64B5F6),
      'unlocked': false,
      'completed': false,
      'description': 'Gunung berapi yang mengamuk, rumah Buto Amuka',
      'x': 0.35,
      'y': 0.68,
      'size': 75.0,
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
      'completed': false,
      'description': 'Hutan belantara tempat Enggang Gading menebar racun',
      'x': 0.48,
      'y': 0.38,
      'size': 95.0,
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
      'completed': false,
      'description': 'Perairan luas tempat Naga Phinisi menguasai lautan',
      'x': 0.65,
      'y': 0.48,
      'size': 80.0,
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
      'completed': false,
      'description': 'Puncak Jayawijaya tempat Sang Cendrawasih menebar ilusi',
      'x': 0.83,
      'y': 0.45,
      'size': 90.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeInController, curve: Curves.easeIn));
    _fadeInController.forward();
  }

  void _tontonUlangPrologue() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrologueScreen()),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1929), Color(0xFF0D2847), Color(0xFF0A1929)],
          ),
        ),
        child: Stack(
          children: [
            _buildMapBackground(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeInAnimation,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              _buildIndonesiaMap(constraints),
                              ..._islands.map(
                                (island) => _buildIslandHotspot(
                                  island,
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  _buildBottomInfo(),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [Color(0xFF1A3A5C), Color(0xFF0A1929)],
            ),
          ),
        ),
        CustomPaint(size: Size.infinite, painter: _OceanPatternPainter()),
        ...List.generate(20, (index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(seconds: 3 + (index % 5)),
            builder: (context, value, child) {
              return Positioned(
                left:
                    (index * 137) %
                    MediaQuery.of(context).size.width.toDouble(),
                top:
                    (index * 89 + value * 100) %
                    MediaQuery.of(context).size.height.toDouble(),
                child: Opacity(
                  opacity: 0.2 + (value * 0.3),
                  child: Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withOpacity(0.6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildIndonesiaMap(BoxConstraints constraints) {
    return Positioned.fill(child: CustomPaint(painter: _IndonesiaMapPainter()));
  }

  Widget _buildIslandHotspot(
    Map<String, dynamic> island,
    double screenWidth,
    double screenHeight,
  ) {
    final isUnlocked = island['unlocked'] as bool;
    final x = (island['x'] as double) * screenWidth;
    final y = (island['y'] as double) * screenHeight;
    final size = island['size'] as double;
    final color = island['color'] as Color;
    final accentColor = island['accentColor'] as Color;

    return Positioned(
      left: x - size / 2,
      top: y - size / 2,
      child: GestureDetector(
        onTap: () => _showIslandDetail(island),
        child: isUnlocked
            ? _buildUnlockedIsland(island, size, color, accentColor)
            : _buildLockedIsland(island, size),
      ),
    );
  }

  Widget _buildUnlockedIsland(
    Map<String, dynamic> island,
    double size,
    Color color,
    Color accentColor,
  ) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _pulseAnimation.value, child: child);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [accentColor.withOpacity(0.9), color.withOpacity(0.7)],
              ),
              border: Border.all(color: Colors.amber, width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.8),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                island['icon'] as String,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber, width: 1.5),
            ),
            child: Text(
              island['name'] as String,
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedIsland(Map<String, dynamic> island, double size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.grey[700]!.withOpacity(0.8),
                Colors.grey[900]!.withOpacity(0.9),
              ],
            ),
            border: Border.all(color: Colors.grey[600]!, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.4,
                child: Text(
                  island['icon'] as String,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.lock, color: Colors.red, size: 24),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[600]!, width: 1.5),
          ),
          child: Text(
            island['name'] as String,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.amber,
                size: 28,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.2),
                  Colors.orange.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 15),
              ],
            ),
            child: const Text(
              'PETA NUSANTARA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _tontonUlangPrologue,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withOpacity(0.3),
                    Colors.orange.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.replay, color: Colors.amber, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'PROLOGUE',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.touch_app, color: Colors.amber, size: 20),
          const SizedBox(width: 10),
          const Text(
            'Tap pulau untuk melihat detail',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green, width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 14),
                SizedBox(width: 4),
                Text(
                  '1/5 Selesai',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        // ✅ Ambil tinggi layar yang tersedia (dikurangi area aman/notch)
        final screenHeight = MediaQuery.of(context).size.height;
        final safeAreaTop = MediaQuery.of(context).padding.top;
        final safeAreaBottom = MediaQuery.of(context).padding.bottom;
        final availableHeight = screenHeight - safeAreaTop - safeAreaBottom;

        // ✅ Modal maksimal 85% dari tinggi layar yang tersedia,
        // sehingga selalu ada ruang & tidak pernah overflow di HP manapun.
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
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isUnlocked ? color : Colors.black).withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            // ✅ KUNCI PERBAIKAN: bungkus isi dengan scroll view
            // supaya kalau kontennya lebih tinggi dari layar,
            // user bisa scroll alih-alih konten kepotong/overflow.
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
                        width: 3,
                      ),
                    ),
                    child: Text(
                      island['icon'] as String,
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    island['name'] as String,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.white : Colors.grey[400],
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 5,
                        ),
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
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    island['description'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      color: isUnlocked ? Colors.white : Colors.grey[400],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                        '⚔️ BOSS',
                        island['boss'] as String,
                        isUnlocked,
                      ),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildInfoItem(
                        '🗡️ SENJATA',
                        island['weapon'] as String,
                        isUnlocked,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ✅ TOMBOL INI YANG DIUBAH
                  if (isUnlocked)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Tutup modal

                        // ✅ Navigate ke GameScreen dengan nama pulau
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameScreen(
                              islandName:
                                  island['name']
                                      as String, // 'SUMATRA', 'JAWA', dll
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow, size: 28),
                      label: const Text(
                        'MULAI PETUALANGAN',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, color: Colors.red, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'PULAU TERKUNCI',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
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

  Widget _buildInfoItem(String label, String value, bool isUnlocked) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isUnlocked ? Colors.white70 : Colors.grey[500],
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: isUnlocked ? Colors.white : Colors.grey[400],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Custom Painter untuk pattern ombak laut
class _OceanPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 10; i++) {
      final path = Path();
      final y = (size.height / 10) * i;
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += 20) {
        path.quadraticBezierTo(
          x + 10,
          y + 5 * (i % 2 == 0 ? 1 : -1),
          x + 20,
          y,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter untuk outline peta Indonesia (simplified)
class _IndonesiaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    _drawIslandOutline(canvas, paint, fillPaint, size, [
      Offset(0.10, 0.30),
      Offset(0.22, 0.25),
      Offset(0.25, 0.45),
      Offset(0.20, 0.55),
      Offset(0.12, 0.50),
    ]);

    _drawIslandOutline(canvas, paint, fillPaint, size, [
      Offset(0.28, 0.65),
      Offset(0.42, 0.63),
      Offset(0.43, 0.72),
      Offset(0.30, 0.73),
    ]);

    _drawIslandOutline(canvas, paint, fillPaint, size, [
      Offset(0.40, 0.25),
      Offset(0.55, 0.22),
      Offset(0.58, 0.40),
      Offset(0.52, 0.52),
      Offset(0.42, 0.48),
    ]);

    _drawIslandOutline(canvas, paint, fillPaint, size, [
      Offset(0.60, 0.35),
      Offset(0.70, 0.32),
      Offset(0.72, 0.50),
      Offset(0.65, 0.55),
      Offset(0.62, 0.45),
    ]);

    _drawIslandOutline(canvas, paint, fillPaint, size, [
      Offset(0.75, 0.35),
      Offset(0.90, 0.32),
      Offset(0.92, 0.50),
      Offset(0.85, 0.58),
      Offset(0.77, 0.52),
    ]);
  }

  void _drawIslandOutline(
    Canvas canvas,
    Paint strokePaint,
    Paint fillPaint,
    Size size,
    List<Offset> points,
  ) {
    final path = Path();
    final scaledPoints = points
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    path.moveTo(scaledPoints.first.dx, scaledPoints.first.dy);
    for (int i = 1; i < scaledPoints.length; i++) {
      path.lineTo(scaledPoints[i].dx, scaledPoints[i].dy);
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
