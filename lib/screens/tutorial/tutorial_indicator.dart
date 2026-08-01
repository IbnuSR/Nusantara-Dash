import 'package:flutter/material.dart';

/// Widget indikator halaman (Dots) dengan animasi pulsing & glow emas untuk dot aktif, dan abu-abu untuk dot lain
class TutorialIndicator extends StatefulWidget {
  final int count;
  final int currentIndex;

  const TutorialIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  State<TutorialIndicator> createState() => _TutorialIndicatorState();
}

class _TutorialIndicatorState extends State<TutorialIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.count, (index) {
        final isActive = index == widget.currentIndex;

        if (isActive) {
          return AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  height: 10.0,
                  width: 24.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                      color: const Color(0xFFFFF099),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.7 * _pulseAnimation.value),
                        blurRadius: 10.0 * _pulseAnimation.value,
                        spreadRadius: 1.5,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 9.0,
          width: 9.0,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4.5),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.0,
            ),
          ),
        );
      }),
    );
  }
}
