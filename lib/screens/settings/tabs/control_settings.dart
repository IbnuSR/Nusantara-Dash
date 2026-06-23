import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/game_prefs.dart';

class ControlSettings extends StatefulWidget {
  const ControlSettings({super.key});

  @override
  State<ControlSettings> createState() => _ControlSettingsState();
}

class _ControlSettingsState extends State<ControlSettings> {
  String _currentControlType = 'analog';

  @override
  void initState() {
    super.initState();
    _loadControlType();
  }

  Future<void> _loadControlType() async {
    final type = await GamePrefs.getControlType();
    setState(() => _currentControlType = type);
  }

  Future<void> _updateControlType(String type) async {
    await GamePrefs.setControlType(type);
    setState(() => _currentControlType = type);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Tipe kontrol diubah ke: ${type.toUpperCase()}'),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎮 TIPE KONTROL',
            style: GoogleFonts.pressStart2p(fontSize: 14, color: Colors.amber),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih tipe kontrol yang kamu suka:',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),

          _buildControlOption(
            title: 'ANALOG',
            description: 'Joystick virtual untuk gerakan smooth',
            icon: Icons.gamepad,
            color: const Color(0xFF4CAF50),
            isSelected: _currentControlType == 'analog',
            onTap: () => _updateControlType('analog'),
          ),
          const SizedBox(height: 16),

          _buildControlOption(
            title: 'PANAH',
            description: 'Tombol kiri & kanan untuk gerakan presisi',
            icon: Icons.keyboard_arrow_left,
            color: const Color(0xFF2196F3),
            isSelected: _currentControlType == 'arrow',
            onTap: () => _updateControlType('arrow'),
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2845),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFB300), width: 2),
            ),
            child: Column(
              children: [
                Text(
                  'PREVIEW',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 12,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 16),
                _currentControlType == 'analog'
                    ? _buildAnalogPreview()
                    : _buildArrowPreview(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlOption({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : const Color(0xFF1B2845),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 12,
                      color: isSelected ? color : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.green, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalogPreview() {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.3),
      ),
      child: Center(
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber.withOpacity(0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildArrowPreview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_left, color: Colors.white, size: 40),
        ),
        const SizedBox(width: 40),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_right, color: Colors.white, size: 40),
        ),
      ],
    );
  }
}
