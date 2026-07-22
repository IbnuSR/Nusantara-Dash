import 'package:flutter/material.dart';
import 'package:nusantara_dash/game/data/museum_item_model.dart';

/// Reusable Modern Progress Bar untuk Museum.
///
/// Fitur:
/// - Animasi transisi value yang halus (250ms).
/// - Sudut membulat modern dengan pembatas track yang tegas.
/// - Pilihan warna gradient atau solid.
class MuseumProgressBar extends StatelessWidget {
  final MuseumProgress progress;
  final Color activeColor;
  final Color? backgroundColor;
  final double height;
  final bool showGlow;

  const MuseumProgressBar({
    super.key,
    required this.progress,
    required this.activeColor,
    this.backgroundColor,
    this.height = 10.0,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final double targetRatio = progress.percentage.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: activeColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0.0, end: targetRatio),
          builder: (context, value, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      activeColor,
                      activeColor.withOpacity(0.85),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
