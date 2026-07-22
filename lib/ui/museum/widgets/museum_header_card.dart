import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nusantara_dash/game/data/museum_item_model.dart';
import 'museum_progress_bar.dart';

/// Reusable Header Card untuk menampilkan rangkuman Progres Museum.
///
/// Digunakan di:
/// - Museum HomeScreen (Progress Indonesia)
/// - Museum IslandScreen (Progress Pulau)
/// - Museum ProvinceScreen (Progress Provinsi)
class MuseumHeaderCard extends StatelessWidget {
  final String title;
  final String iconEmoji;
  final MuseumProgress progress;
  final Color accentColor;

  const MuseumHeaderCard({
    super.key,
    required this.title,
    required this.iconEmoji,
    required this.progress,
    this.accentColor = const Color(0xFFFFB300),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.25),
            const Color(0xFF1A237E).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.pressStart2p(
                          color: accentColor,
                          fontSize: 9,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                MuseumProgressBar(
                  progress: progress,
                  activeColor: accentColor,
                  height: 10,
                  showGlow: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withOpacity(0.4), width: 1),
                ),
                child: Text(
                  progress.label,
                  style: GoogleFonts.pressStart2p(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Item Terkumpul',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
