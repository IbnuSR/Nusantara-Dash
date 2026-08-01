import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'map_selection/map_screen.dart';
import 'prologue_screen.dart';
import 'package:nusantara_dash/utils/game_prefs.dart';
import 'package:nusantara_dash/utils/audio_manager.dart';
import 'package:nusantara_dash/game/features/shop/shop_screen.dart';
import 'package:nusantara_dash/game/features/weapons/weapon_screen.dart';
import 'package:nusantara_dash/screens/settings/settings_screen.dart';
import 'package:nusantara_dash/screens/tutorial/tutorial_screen.dart';
import 'museum/museum_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
    _checkFirstLaunchTutorial();
  }

  Future<void> _checkFirstLaunchTutorial() async {
    final isCompleted = await GamePrefs.isTutorialCompleted();
    if (!isCompleted && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleOpenTutorial();
        }
      });
    }
  }

  void _initAnimations() {
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
      print(' Loading BGM...');
      await AudioManager.instance.playBGM('audio/bgm/main_menu.mp3');
      setState(() {
        _isMusicPlaying = AudioManager.instance.isBGMEnabled;
      });
      print('✅ BGM started via AudioManager');
    } catch (e) {
      print('❌ Error playing BGM: $e');
    }
  }

  Future<void> _toggleMusic() async {
    await AudioManager.instance.toggleBGM();
    setState(() {
      _isMusicPlaying = AudioManager.instance.isBGMEnabled;
    });
  }

  void _handleStartGame() async {
    bool hasWatched = await GamePrefs.hasWatchedPrologue();

    if (!mounted) return;

    if (hasWatched) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MapScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PrologueScreen()),
      );
    }
  }

  void _handleOpenSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    ).then((_) {
      if (mounted) {
        setState(() {
          _isMusicPlaying = AudioManager.instance.isBGMEnabled;
        });
      }
    });
  }

  void _handleOpenTutorial() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TutorialScreen()),
    );
  }

  void _handleOpenWeapons() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WeaponScreen()),
    );
  }

  void _handleOpenShop() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShopScreen()),
    );
  }

  @override
  void dispose() {
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
            colors: [Color(0xFF1A237E), Color(0xFF0D1B2A)],
          ),
        ),
        child: Stack(
          children: [
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
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  const Spacer(),
                  _buildTitle(),
                  const Spacer(),
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

  // ✅ WIDGET HELPER: Custom Icon TANPA border & TANPA warna tint
  // Ukuran bisa diatur bebas via parameter `size`
  Widget _buildCustomIcon({
    required String iconPath,
    required double size,
  }) {
    return Image.asset(
      iconPath,
      width: size,
      height: size,
      // ✅ Tidak ada parameter `color` → gambar tampil apa adanya
      errorBuilder: (context, error, stackTrace) {
        // ✅ Placeholder simple: cuma teks, tanpa border/box
        return SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text(
              'ini tombol apa',
              style: TextStyle(
                color: Colors.white54,
                fontSize: size * 0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ SETTINGS BUTTON
          GestureDetector(
            onTap: _handleOpenSettings,
            child: _buildCustomIcon(
              iconPath: 'assets/images/ui/buttons/pengaturan.png',
              size: 75, // ✅ Ubah ukuran sesuka kamu
            ),
          ),

          // ✅ RIGHT BUTTONS: Bantuan (Tutorial) & Music Toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ BANTUAN BUTTON
              GestureDetector(
                onTap: _handleOpenTutorial,
                child: _buildCustomIcon(
                  iconPath: 'assets/images/ui/buttons/bantuan.png',
                  size: 75,
                ),
              ),
              const SizedBox(width: 8.0),

              // ✅ MUSIC TOGGLE
              GestureDetector(
                onTap: _toggleMusic,
                child: _buildCustomIcon(
                  iconPath: _isMusicPlaying
                      ? 'assets/images/ui/buttons/audioOn.png'
                      : 'assets/images/ui/buttons/audioOff.png',
                  size: 75,
                ),
              ),
            ],
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
            Text(
              'NUSANTARA DASH',
              style: GoogleFonts.pressStart2p(
                fontSize: 32,
                color: const Color(0xFFFFB300),
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(3, 3),
                    blurRadius: 5,
                  ),
                  Shadow(
                    color: Color(0xFFFF6F00),
                    offset: Offset(0, 0),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Guardians of the Archipelago',
              style: GoogleFonts.pressStart2p(
                fontSize: 12,
                color: Colors.white,
                shadows: const [
                  Shadow(
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

  Widget _buildMenuButtons() {
    return FadeTransition(
      opacity: _buttonAnimation,
      child: ScaleTransition(
        scale: _buttonAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMenuButton(
                      label: 'MULAI',
                      iconPath: 'assets/images/ui/buttons/mulai.png',
                      iconSize: 50, // ✅ Ubah ukuran icon sesuka kamu
                      color: const Color(0xFF4CAF50),
                      onTap: _handleStartGame,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMenuButton(
                      label: 'MUSEUM',
                      iconPath: 'assets/images/ui/buttons/museum.png',
                      iconSize: 50,
                      color: const Color(0xFF2196F3),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MuseumHomeScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMenuButton(
                      label: 'SENJATA',
                      iconPath: 'assets/images/ui/buttons/senjata.png',
                      iconSize: 50,
                      color: const Color(0xFF9C27B0),
                      onTap: _handleOpenWeapons,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMenuButton(
                      label: 'TOKO',
                      iconPath: 'assets/images/ui/buttons/toko.png',
                      iconSize: 50,
                      color: const Color(0xFFFF9800),
                      onTap: _handleOpenShop,
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

  // ✅ _buildMenuButton dengan parameter `iconSize` yang bebas diatur
  Widget _buildMenuButton({
    required String label,
    required String iconPath,
    required double iconSize, // ✅ Parameter ukuran icon
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
            // ✅ Icon tanpa warna tint, ukuran bebas
            _buildCustomIcon(
              iconPath: iconPath,
              size: iconSize,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 14,
                color: Colors.white,
                shadows: const [
                  Shadow(
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
