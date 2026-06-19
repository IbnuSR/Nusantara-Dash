import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'map_selection/map_screen.dart';
import 'prologue_screen.dart'; // ✅ Tetap dipakai untuk auto-play pertama kali
import '../utils/game_prefs.dart';
import 'package:nusantara_dash/game/features/shop/shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicPlaying = false;
  late AnimationController _titleController;
  late AnimationController _buttonController;
  late Animation<double> _titleAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _playBGM();
    _checkFirstTimeLaunch(); // ✅ CEK FIRST TIME SAAT HOME DIBUKA
  }

  // ✅ LOGIKA: Prologue auto-play HANYA pertama kali install
  Future<void> _checkFirstTimeLaunch() async {
    final hasWatched = await GamePrefs.hasWatchedPrologue();

    if (!hasWatched && mounted) {
      // First time → langsung push ke prologue setelah animasi selesai
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrologueScreen()),
          );
        }
      });
    }
    // Kedua kali & seterusnya → diam di HomeScreen
  }

  void _initAnimations() {
    // Title animation (fade in + scale)
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _titleAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      ],
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));

    _titleController.forward();

    // Button animation (staggered)
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _buttonController.forward();
    });
  }

  Future<void> _playBGM() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.5);
      await _audioPlayer.play(AssetSource('audio/bgm/main_menu.mp3'));
      setState(() => _isMusicPlaying = true);
    } catch (e) {
      print('Error playing BGM: $e');
    }
  }

  Future<void> _toggleMusic() async {
    if (_isMusicPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    setState(() => _isMusicPlaying = !_isMusicPlaying);
  }

  // ✅ MULAI → LANGSUNG KE MAP SCREEN (bukan prologue)
  void _handleStartGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _titleController.dispose();
    _buttonController.dispose();
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
            colors: [
              Color(0xFF1A237E), // Deep blue top
              Color(0xFF0D1B2A), // Navy bottom
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background image (peta Nusantara)
            Positioned.fill(
              child: Image.asset(
                'assets/images/ui/main_menu_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1A237E), Color(0xFF0D1B2A)],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Dark overlay untuk readability
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top bar dengan settings & music toggle
                  _buildTopBar(),

                  const Spacer(),

                  // Title
                  _buildTitle(),

                  const Spacer(),

                  // Buttons
                  _buildMenuButtons(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Settings button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan - Coming Soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFB300), width: 2),
              ),
              child: const Icon(
                Icons.settings,
                color: Color(0xFFFFB300),
                size: 28,
              ),
            ),
          ),

          // Music toggle
          GestureDetector(
            onTap: _toggleMusic,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFB300), width: 2),
              ),
              child: Icon(
                _isMusicPlaying ? Icons.music_note : Icons.music_off,
                color: const Color(0xFFFFB300),
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return FadeTransition(
      opacity: _titleAnimation,
      child: ScaleTransition(
        scale: _titleAnimation,
        child: Column(
          children: [
            // Main title
            Text(
              'NUSANTARA DASH',
              style: GoogleFonts.pressStart2p(
                fontSize: 32,
                color: const Color(0xFFFFB300),
                shadows: [
                  const Shadow(
                    color: Colors.black,
                    offset: Offset(3, 3),
                    blurRadius: 5,
                  ),
                  const Shadow(
                    color: Color(0xFFFF6F00),
                    offset: Offset(0, 0),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              'Guardians of the Archipelago',
              style: GoogleFonts.pressStart2p(
                fontSize: 12,
                color: Colors.white,
                shadows: [
                  const Shadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ UPDATED: Layout 2x2 (tanpa tombol PROLOGUE)
  Widget _buildMenuButtons() {
    return FadeTransition(
      opacity: _buttonAnimation,
      child: ScaleTransition(
        scale: _buttonAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Row 1: MULAI & MUSEUM
              Row(
                children: [
                  Expanded(
                    child: _buildMenuButton(
                      label: 'MULAI',
                      icon: Icons.play_arrow,
                      color: const Color(0xFF4CAF50),
                      onTap: _handleStartGame, // ✅ Langsung ke MapScreen
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMenuButton(
                      label: 'MUSEUM',
                      icon: Icons.menu_book,
                      color: const Color(0xFF2196F3),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Museum Budaya - Coming Soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Row 2: SENJATA & TOKO
              Row(
                children: [
                  Expanded(
                    child: _buildMenuButton(
                      label: 'SENJATA',
                      icon: Icons.gavel,
                      color: const Color(0xFF9C27B0),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gudang Senjata - Coming Soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMenuButton(
                      label: 'TOKO',
                      icon: Icons.shopping_cart,
                      color: const Color(0xFFFF9800),
                      onTap: () {
                        // ✅ Langsung pindah ke layar Toko
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShopScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.9), color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFB300), width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 14,
                color: Colors.white,
                shadows: [
                  const Shadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
