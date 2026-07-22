import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nusantara_dash/game/data/museum_item_model.dart';

/// Reusable Cultural Item Card untuk Province Screen.
///
/// Mendukung tampilan Terbuka vs Terkunci dengan proporsi rapi, Hero animation,
/// dan efek tekan.
class CulturalItemCard extends StatefulWidget {
  final CulturalItem item;
  final bool isUnlocked;
  final VoidCallback onTap;

  const CulturalItemCard({
    super.key,
    required this.item,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  State<CulturalItemCard> createState() => _CulturalItemCardState();
}

class _CulturalItemCardState extends State<CulturalItemCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isUnlocked
                ? const Color(0xFF1B2845)
                : const Color(0xFF121B2A).withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isUnlocked
                  ? const Color(0xFFFFB300).withOpacity(0.8)
                  : Colors.white.withOpacity(0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isUnlocked
                    ? const Color(0xFFFFB300).withOpacity(0.15)
                    : Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Visual Box (Gambar / Lock Icon)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: Container(
                  width: 54,
                  height: double.infinity,
                  color: widget.isUnlocked
                      ? Colors.black26
                      : Colors.black.withOpacity(0.4),
                  child: widget.isUnlocked
                      ? Hero(
                          tag: 'item_img_${widget.item.id}',
                          child: Image.asset(
                            widget.item.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.museum_rounded,
                              color: Color(0xFFFFB300),
                              size: 24,
                            ),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_rounded,
                                color: Colors.white.withOpacity(0.35),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 8),

              // Title & Status Badge
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.isUnlocked ? widget.item.name : '???',
                        style: GoogleFonts.pressStart2p(
                          color: widget.isUnlocked
                              ? Colors.white
                              : Colors.white.withOpacity(0.35),
                          fontSize: 7.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.isUnlocked
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: widget.isUnlocked
                                ? Colors.green.withOpacity(0.4)
                                : Colors.red.withOpacity(0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          widget.isUnlocked ? 'TERBUKA' : 'TERKUNCI',
                          style: TextStyle(
                            color: widget.isUnlocked
                                ? Colors.greenAccent
                                : Colors.redAccent.shade100,
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
