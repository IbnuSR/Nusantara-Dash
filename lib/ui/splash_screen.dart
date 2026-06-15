import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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
  bool _showGameLogo = false;
  bool _showTeamLogo = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequence();
  }

  void _initAnimations() {
    // Logo scale animation (bounce effect)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.95), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _logoFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    // Glow pulse animation (infinite loop)
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowPulse = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    // Transition animation
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _transitionFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut),
    );

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _particleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );
  }

  void _startSequence() {
    // Phase 1: Team Logo appears
    _logoController.forward();
    _particleController.forward();

    // Phase 2: Text appears
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _textController.forward();
    });

    // Phase 3: Transition to Game Logo
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

    // Phase 4: Navigate to Home
    Future.delayed(const Duration(milliseconds: 6500), () {
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
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildAnimatedBackground(),
          _buildParticles(),
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
            bottom: 40,
            left: 0,
            right: 0,
            child: _buildLoadingIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Colors.blue.shade900.withOpacity(
                  0.3 + (_glowPulse.value * 0.2),
                ),
                Colors.indigo.shade900.withOpacity(0.5),
                Colors.purple.shade900.withOpacity(0.7),
                Colors.black,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: List.generate(30, (index) {
            final random = Random(index);
            final delay = random.nextDouble() * 2;
            final size = 2.0 + random.nextDouble() * 4;
            final dx = (random.nextDouble() - 0.5) * 400;
            final dy = (random.nextDouble() - 0.5) * 600;

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
                      width: size * (1 + value),
                      height: size * (1 + value),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _showTeamLogo
                            ? Colors.amber.withOpacity(0.8)
                            : Colors.orange.withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_showTeamLogo ? Colors.amber : Colors.orange)
                                    .withOpacity(0.5 * (1 - value)),
                            blurRadius: 10,
                          ),
                        ],
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
        // Team Logo
        ScaleTransition(
          scale: _logoScale,
          child: FadeTransition(
            opacity: _logoFade,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5 * _glowPulse.value),
                        blurRadius: 30 * _glowPulse.value,
                        spreadRadius: 5 * _glowPulse.value,
                      ),
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3 * _glowPulse.value),
                        blurRadius: 50 * _glowPulse.value,
                        spreadRadius: 10 * _glowPulse.value,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/ui/team_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.red,
                          child: const Center(
                            child: Text('🔴', style: TextStyle(fontSize: 80)),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 30),

        // ✅ TEAM NAME - FIXED (pakai 2 Shadow untuk efek glow)
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(_textController),
          child: FadeTransition(
            opacity: _textFade,
            child: const Text(
              'RED UNION',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 36,
                letterSpacing: 5,
                shadows: [
                  // Shadow 1: Glow effect (blur besar)
                  Shadow(color: Colors.amber, blurRadius: 25),
                  // Shadow 2: Outline effect (blur kecil)
                  Shadow(color: Colors.amber, blurRadius: 5),
                  // Shadow 3: Dark outline
                  Shadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: Offset(3, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Tagline
        SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _textController,
                  curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                ),
              ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _textController,
                curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
              ),
            ),
            child: Text(
              'G A M E   S T U D I O',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                letterSpacing: 3,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Game Icon
        ScaleTransition(
          scale: _logoScale,
          child: FadeTransition(
            opacity: _logoFade,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber, width: 4),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.6 * _glowPulse.value),
                        blurRadius: 30 * _glowPulse.value,
                        spreadRadius: 5 * _glowPulse.value,
                      ),
                      BoxShadow(
                        color: Colors.orange.withOpacity(
                          0.4 * _glowPulse.value,
                        ),
                        blurRadius: 50 * _glowPulse.value,
                        spreadRadius: 10 * _glowPulse.value,
                      ),
                    ],
                  ),
                  child: const Text('🏃‍♂️', style: TextStyle(fontSize: 90)),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 40),

        // ✅ GAME TITLE - FIXED (pakai 2 Shadow untuk efek glow)
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.5),
            end: Offset.zero,
          ).animate(_textController),
          child: FadeTransition(
            opacity: _textFade,
            child: const Text(
              'NUSANTARA DASH',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
                shadows: [
                  // Shadow 1: Glow effect (blur besar)
                  Shadow(color: Colors.amber, blurRadius: 20),
                  // Shadow 2: Outline glow (blur kecil)
                  Shadow(color: Colors.amber, blurRadius: 5),
                  // Shadow 3: Dark outline
                  Shadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: Offset(3, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Subtitle
        SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _textController,
                  curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                ),
              ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _textController,
                curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
              ),
            ),
            child: Text(
              'Guardians of the Archipelago',
              style: TextStyle(
                fontSize: 16,
                color: Colors.amber.shade200,
                fontStyle: FontStyle.italic,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            strokeWidth: 3,
          ),
        ),
        const SizedBox(width: 15),
        Text(
          'Loading...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            letterSpacing: 2,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}
