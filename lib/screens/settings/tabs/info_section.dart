import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoSection extends StatelessWidget {
  const InfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Tim Developer di balik Nusantara Dash',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Logo Red Union
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2845),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE53935), width: 3),
            ),
            child: Column(
              children: [
                // Logo Image atau Icon
                ClipOval(
                  child: Image.asset(
                    'assets/images/team/dev_logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback ke icon kalau gambar tidak ada
                      return Container(
                        width: 100,
                        height: 100,
                        color: const Color(0xFFE53935),
                        child: const Icon(
                          Icons.shield,
                          size: 60,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'RED UNION',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 16,
                    color: const Color(0xFFE53935),
                    shadows: [
                      Shadow(color: const Color(0xFFE53935), blurRadius: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Game Development Team',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(
            '👨‍ ANGGOTA TIM',
            style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.amber),
          ),
          const SizedBox(height: 16),

          // Member 1
          _buildTeamMember(
            name: 'M. Masrukhin Ferdian',
            role: 'Lead Developer',
            instagram: '@ffrrrr__',
            photoAsset: 'assets/images/team/member2.jpeg',
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 16),

          // Member 2
          _buildTeamMember(
            name: 'Ibnu Sabilul Rosad',
            role: 'UI/UX Designer',
            instagram: '@ibnu_s.r',
            photoAsset: 'assets/images/team/member1.jpeg',
            color: const Color(0xFF2196F3),
          ),
          const SizedBox(height: 16),

          // Member 3
          _buildTeamMember(
            name: 'M. Iqbal Rakha',
            role: 'Game Artist',
            instagram: '@iqbalrakha',
            photoAsset: 'assets/images/team/member3.jpeg',
            color: const Color(0xFF9C27B0),
          ),

          const SizedBox(height: 32),

          Text(
            'TENTANG GAME',
            style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.amber),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2845),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoText('🎮 Genre: 2D Runner Platformer'),
                _buildInfoText('🎯 Target: Edukasi Budaya Indonesia'),
                _buildInfoText('🏝️ Fitur: 5 Pulau, Kuis, Boss Fight'),
                _buildInfoText('📱 Platform: Android'),
                _buildInfoText('🔧 Engine: Flutter + Flame'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2845),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4CAF50), width: 2),
            ),
            child: Column(
              children: [
                Text(
                  'VERSI GAME',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 10,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'v1.0.0',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember({
    required String name,
    required String role,
    required String instagram,
    required String photoAsset,
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
          // Photo/Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              photoAsset,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback ke icon kalau gambar tidak ada
                return Container(
                  width: 70,
                  height: 70,
                  color: color.withOpacity(0.3),
                  child: Icon(Icons.person, size: 40, color: color),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.photo_camera, size: 14, color: Colors.pink),
                    const SizedBox(width: 4),
                    Text(
                      instagram,
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }
}
