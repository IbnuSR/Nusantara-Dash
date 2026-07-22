import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nusantara_dash/game/data/museum_item_model.dart';
import 'museum_progress_bar.dart';

/// Reusable Province Card dengan efek tekan animasi & alignment rapi.
class ProvinceCard extends StatefulWidget {
  final MuseumProvince province;
  final MuseumProgress progress;
  final Color accentColor;
  final VoidCallback onTap;

  const ProvinceCard({
    super.key,
    required this.province,
    required this.progress,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<ProvinceCard> createState() => _ProvinceCardState();
}

class _ProvinceCardState extends State<ProvinceCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF162238).withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.accentColor.withOpacity(0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon provinsi
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.accentColor, width: 1.2),
                ),
                child: Icon(
                  Icons.location_city_rounded,
                  color: widget.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Title & Progress Bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            widget.province.name,
                            style: GoogleFonts.pressStart2p(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.progress.label,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.progress.isComplete) ...[
                              const SizedBox(width: 4),
                              const Text('✅', style: TextStyle(fontSize: 10)),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    MuseumProgressBar(
                      progress: widget.progress,
                      activeColor: widget.accentColor,
                      height: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Chevron Icon
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.4),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
