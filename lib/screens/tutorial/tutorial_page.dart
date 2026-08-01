import 'dart:async';
import 'package:flutter/material.dart';
import 'tutorial_data.dart';
import 'tutorial_overlay.dart';

/// Widget yang merender 1 Halaman Tutorial lengkap (Background Asset Final FIKS, Callout, & Bottom Description)
class TutorialPage extends StatefulWidget {
  final TutorialPageModel page;

  const TutorialPage({
    super.key,
    required this.page,
  });

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  int _visibleOverlayCount = 0;
  Timer? _staggerTimer;

  @override
  void initState() {
    super.initState();
    _startStaggeredAnimation();
  }

  @override
  void didUpdateWidget(covariant TutorialPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.pageIndex != widget.page.pageIndex) {
      _startStaggeredAnimation();
    }
  }

  void _startStaggeredAnimation() {
    _staggerTimer?.cancel();
    setState(() {
      _visibleOverlayCount = 0;
    });

    if (widget.page.overlays.isEmpty) return;

    int current = 0;
    _staggerTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      current++;
      setState(() {
        _visibleOverlayCount = current;
      });
      if (current >= widget.page.overlays.length) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _staggerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // 1. Background Image Asset FIKS Full Screen (BoxFit.cover, No stretch)
        Positioned.fill(
          child: Image.asset(
            widget.page.bgImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF1E100D),
                child: const Center(
                  child: Icon(Icons.gamepad, color: Colors.amber, size: 64),
                ),
              );
            },
          ),
        ),

        // 2. Dark Overlay semi-transparan (Opacity 0.35) agar callout & gameplay jernih
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.35),
          ),
        ),

        // 3. Callout Overlays dengan Animasi Staggered Entrance
        for (int i = 0; i < widget.page.overlays.length; i++)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: i < _visibleOverlayCount ? 1.0 : 0.0,
            curve: Curves.easeOutCubic,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: i < _visibleOverlayCount ? 1.0 : 0.85,
              curve: Curves.easeOutBack,
              child: TutorialOverlay(
                item: widget.page.overlays[i],
                screenSize: screenSize,
              ),
            ),
          ),

        // 4. Top Title Banner dengan Text Shadow Kontras
        Positioned(
          left: 16.0,
          right: 16.0,
          top: 18.0,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.9, end: 1.0),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 7.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A231D).withOpacity(0.92),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.6),
                              blurRadius: 10.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.page.title.toUpperCase(),
                              style: TextStyle(
                                color: const Color(0xFFFFD700),
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.9),
                                    blurRadius: 4.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.page.subtitle != null) ...[
                              const SizedBox(height: 2.0),
                              Text(
                                widget.page.subtitle!,
                                style: TextStyle(
                                  color: Colors.amber.shade200,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // 5. Bottom Description Panel (Lebar 85%, Maksimal 2 Baris, Centered)
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: Container(
              width: screenSize.width * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: const Color(0xFF2C1B18).withOpacity(0.90),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.85), width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.55),
                    blurRadius: 10.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.page.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
