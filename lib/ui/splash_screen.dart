import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _logoController;
  late AnimationController _glowController;
  late AnimationController _textController;
  late AnimationController _transitionController;
  late AnimationController _particleController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _glowPulse;
  late Animation<double> _textFade;
  late Animation<double> _transitionFade;
  late Animation<double> _particleFade;

  // State
  // ignore: unused_field
  bool _showGameLogo = false;
  bool _showTeamLogo = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequence();
  }

  void _initAnimations() {
    // Efek mantul ala game retro
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.1), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.95), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _logoFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    // Glow pulse (Berkedip untuk loading)
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _glowPulse = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _transitionFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut),
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _particleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );
  }

  void _startSequence() {
    _logoController.forward();
    _particleController.forward();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        _transitionController.forward();
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _showTeamLogo = false;
              _showGameLogo = true;
            });
            _logoController.reset();
            _textController.reset();
            _particleController.reset();

            _logoController.forward();
            _textController.forward();
            _particleController.forward();
          }
        });
      }
    });

    // Pindah ke menu utama
    Future.delayed(const Duration(milliseconds: 7000), () {
      if (mounted) _navigateToHome();
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _textController.dispose();
    _transitionController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A), // Warna dasar dark retro
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildPixelGridBackground(),
          _buildPixelParticles(),
          Center(
            child: AnimatedBuilder(
              animation: _transitionController,
              builder: (context, child) {
                return Opacity(
                  opacity: _showTeamLogo ? _transitionFade.value : 1.0,
                  child: child,
                );
              },
              child: _showTeamLogo ? _buildTeamLogo() : _buildGameLogo(),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _buildBlinkingLoading(),
          ),
        ],
      ),
    );
  }

  // ✅ BACKGROUND: Garis ala scanline TV Tabung Retro
  Widget _buildPixelGridBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF000000),
            const Color(0xFF0B192C),
            const Color(0xFF1B2845),
          ],
        ),
      ),
    );
  }

  // ✅ PARTICLES: Diganti jadi kotak (Pixel) tajam tanpa blur!
  Widget _buildPixelParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: List.generate(40, (index) {
            final random = Random(index);
            final delay = random.nextDouble() * 2;
            final size = 4.0 + random.nextDouble() * 6; // Piksel lebih besar
            final dx = (random.nextDouble() - 0.5) * 600;
            final dy = (random.nextDouble() - 0.5) * 800;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 2000 + (delay * 1000).toInt()),
              builder: (context, value, child) {
                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 + dx * value,
                  top: MediaQuery.of(context).size.height / 2 + dy * value,
                  child: Opacity(
                    opacity: (1.0 - value) * _particleFade.value,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: _showTeamLogo
                            ? Colors.redAccent.withOpacity(0.8)
                            : Colors.amber.withOpacity(0.8),
                        border: Border.all(
                          color: Colors.white24,
                          width: 1,
                        ), // Garis pixel
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }

  Widget _buildTeamLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _logoScale,
          child: FadeTransition(
            opacity: _logoFade,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.black, // ✅ FIX: Diubah jadi hitam legam!
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ), // Bingkai tajam
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 1, 0, 0),
                    offset: Offset(4, 4), // Hard shadow ala pixel
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/ui/team_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      'R U',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(_textController),
          child: FadeTransition(
            opacity: _textFade,
            child: Text(
              'RED UNION',
              style: GoogleFonts.pressStart2p(
                color: Colors.white,
                fontSize: 20,
                shadows: const [
                  Shadow(color: Colors.red, offset: Offset(3, 3)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        FadeTransition(
          opacity: _textFade,
          child: Text(
            'G A M E   S T U D I O',
            style: GoogleFonts.pressStart2p(color: Colors.white70, fontSize: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildGameLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _logoScale,
          child: FadeTransition(
            opacity: _logoFade,
            child: Container(
              width: 320, // Diperbesar supaya art-nya kelihatan
              height: 320,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 6,
                ), // Bingkai pixel tajam
                boxShadow: const [
                  BoxShadow(
                    color: Colors.amber,
                    offset: Offset(8, 8), // Hard shadow arcade
                  ),
                ],
              ),
              // ✅ MEMANGGIL LOGO BARUMU:
              child: Image.asset(
                'assets/images/ui/nusantara_logo.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Text(
                        '❌ GAMBAR TIDAK DITEMUKAN',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(_textController),
          child: FadeTransition(
            opacity: _textFade,
            child: Text(
              'Guardians of the Archipelago',
              style: GoogleFonts.pressStart2p(
                fontSize: 10,
                color: Colors.amber.shade200,
                shadows: const [
                  Shadow(color: Colors.black, offset: Offset(2, 2)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ LOADING: Efek Berkedip ala "INSERT COIN" mesin Ding-dong
  Widget _buildBlinkingLoading() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Opacity(
          opacity: _glowPulse.value, // Membuat efek kelap-kelip
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _showTeamLogo ? 'LOADING...' : 'PRESS START...',
                style: GoogleFonts.pressStart2p(
                  color: Colors.white,
                  fontSize: 12,
                  letterSpacing: 2,
                  shadows: const [
                    Shadow(color: Colors.black, offset: Offset(2, 2)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
