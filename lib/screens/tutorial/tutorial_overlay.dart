import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'tutorial_data.dart';

/// Widget overlay penunjuk presisi (Panah pendek 100-120px, Target Dot 10-12px Pulse, & Label Modern)
class TutorialOverlay extends StatefulWidget {
  final TutorialOverlayItemModel item;
  final Size screenSize;

  const TutorialOverlay({
    super.key,
    required this.item,
    required this.screenSize,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Pulse animation scale 1.0 -> 1.15 -> 1.0 (loop)
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
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
    final double targetX = widget.item.x * widget.screenSize.width;
    final double targetY = widget.item.y * widget.screenSize.height;

    // Hitung posisi label pada ruang kosong terdekat (Panah maks 100-120px)
    double labelOffsetX = 0;
    double labelOffsetY = 0;
    const double distance = 26.0;

    switch (widget.item.direction) {
      case CalloutDirection.top:
        labelOffsetY = -(distance + 28);
        break;
      case CalloutDirection.bottom:
        labelOffsetY = distance + 6;
        break;
      case CalloutDirection.left:
        labelOffsetX = -(distance + 82);
        break;
      case CalloutDirection.right:
        labelOffsetX = distance + 8;
        break;
      case CalloutDirection.topLeft:
        labelOffsetX = -(distance + 70);
        labelOffsetY = -(distance + 24);
        break;
      case CalloutDirection.topRight:
        labelOffsetX = distance + 8;
        labelOffsetY = -(distance + 24);
        break;
      case CalloutDirection.bottomLeft:
        labelOffsetX = -(distance + 70);
        labelOffsetY = distance + 6;
        break;
      case CalloutDirection.bottomRight:
        labelOffsetX = distance + 8;
        labelOffsetY = distance + 6;
        break;
    }

    final double labelX = (targetX + labelOffsetX).clamp(8.0, widget.screenSize.width - 150.0);
    final double labelY = (targetY + labelOffsetY).clamp(12.0, widget.screenSize.height - 70.0);

    return Stack(
      children: [
        // 1. Panah Pendek Garis Emas Tipis & Target Dot 10-12px Pulse
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return CustomPaint(
              size: widget.screenSize,
              painter: _ShortGoldArrowPainter(
                targetPoint: Offset(targetX, targetY),
                labelPoint: Offset(labelX + 40.0, labelY + 14.0),
                color: widget.item.color,
                pulseScale: _pulseAnimation.value,
              ),
            );
          },
        ),

        // 2. Container Label Nusantara Style (Dark Brown #2C1B18, Border Gold #FFD700, Radius 20)
        Positioned(
          left: labelX,
          top: labelY,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: const Color(0xFF2C1B18).withOpacity(0.95),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: widget.item.color, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 6.0,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: widget.item.color.withOpacity(0.2),
                  blurRadius: 8.0,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.item.icon != null) ...[
                  Icon(widget.item.icon, color: widget.item.color, size: 14.0),
                  const SizedBox(width: 5.0),
                ],
                Text(
                  widget.item.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.9),
                        blurRadius: 3.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter untuk panah pendek garis emas tipis dengan target dot (diameter 10-12px)
class _ShortGoldArrowPainter extends CustomPainter {
  final Offset targetPoint;
  final Offset labelPoint;
  final Color color;
  final double pulseScale;

  _ShortGoldArrowPainter({
    required this.targetPoint,
    required this.labelPoint,
    required this.color,
    required this.pulseScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Target Dot (Diameter 10-12px -> Radius 5.5px * pulseScale)
    final double radius = 5.5 * pulseScale;

    // Glow Circle Ring
    final glowPaint = Paint()
      ..color = color.withOpacity((0.35 / pulseScale).clamp(0.1, 0.6))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(targetPoint, radius + 3.0, glowPaint);

    // Center Gold Dot
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(targetPoint, radius, dotPaint);

    // 2. Panah Pendek Garis Emas Tipis (Maks 100-120px)
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(labelPoint.dx, labelPoint.dy);

    final double controlX = (labelPoint.dx + targetPoint.dx) / 2 + 6;
    final double controlY = (labelPoint.dy + targetPoint.dy) / 2 - 6;
    path.quadraticBezierTo(controlX, controlY, targetPoint.dx, targetPoint.dy);

    canvas.drawPath(path, linePaint);

    // 3. Arrow Head Kecil
    final double angle = math.atan2(targetPoint.dy - controlY, targetPoint.dx - controlX);
    const double arrowSize = 6.0;

    final arrowPath = Path();
    arrowPath.moveTo(targetPoint.dx, targetPoint.dy);
    arrowPath.lineTo(
      targetPoint.dx - arrowSize * math.cos(angle - math.pi / 6),
      targetPoint.dy - arrowSize * math.sin(angle - math.pi / 6),
    );
    arrowPath.lineTo(
      targetPoint.dx - arrowSize * math.cos(angle + math.pi / 6),
      targetPoint.dy - arrowSize * math.sin(angle + math.pi / 6),
    );
    arrowPath.close();

    canvas.drawPath(arrowPath, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _ShortGoldArrowPainter oldDelegate) {
    return oldDelegate.targetPoint != targetPoint ||
        oldDelegate.labelPoint != labelPoint ||
        oldDelegate.color != color ||
        oldDelegate.pulseScale != pulseScale;
  }
}
