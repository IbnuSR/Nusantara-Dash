import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreditSection extends StatelessWidget {
  const CreditSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏆 CREDIT GAME',
            style: GoogleFonts.pressStart2p(fontSize: 14, color: Colors.amber),
          ),
          const SizedBox(height: 24),

          _buildCreditCard(
            title: 'NUSANTARA DASH',
            subtitle: 'Guardians of the Archipelago',
            icon: Icons.gamepad,
            color: const Color(0xFFFFB300),
          ),
          const SizedBox(height: 16),

          _buildCreditCard(
            title: 'Game Design & Development',
            subtitle: 'Tim Pengembang Nusantara Dash',
            icon: Icons.code,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 16),

          _buildCreditCard(
            title: 'Pixel Art & Assets',
            subtitle: 'Sprite Character, Tileset, Obstacle',
            icon: Icons.palette,
            color: const Color(0xFF9C27B0),
          ),
          const SizedBox(height: 16),

          _buildCreditCard(
            title: 'Music & Sound Effects',
            subtitle: 'BGM & SFX Original',
            icon: Icons.music_note,
            color: const Color(0xFF2196F3),
          ),
          const SizedBox(height: 16),

          _buildCreditCard(
            title: 'Cultural Research',
            subtitle: 'Data Budaya 5 Pulau Indonesia',
            icon: Icons.menu_book,
            color: const Color(0xFFFF5722),
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2845),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Terima kasih telah bermain!\nGame ini dibuat untuk melestarikan budaya Indonesia melalui media interaktif.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2845),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
