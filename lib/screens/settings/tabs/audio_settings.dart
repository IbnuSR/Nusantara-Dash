import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../../utils/game_prefs.dart';

class AudioSettings extends StatefulWidget {
  const AudioSettings({super.key});

  @override
  State<AudioSettings> createState() => _AudioSettingsState();
}

class _AudioSettingsState extends State<AudioSettings> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _musicVolume = 0.5;

  @override
  void initState() {
    super.initState();
    _loadMusicVolume();
  }

  Future<void> _loadMusicVolume() async {
    final volume = await GamePrefs.getMusicVolume();
    setState(() => _musicVolume = volume);
  }

  Future<void> _updateMusicVolume(double volume) async {
    await GamePrefs.setMusicVolume(volume);
    setState(() => _musicVolume = volume);
    await _audioPlayer.setVolume(volume);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎵 VOLUME MUSIK',
            style: GoogleFonts.pressStart2p(fontSize: 14, color: Colors.amber),
          ),
          const SizedBox(height: 8),
          Text(
            'Atur volume BGM (Background Music):',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2845),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFB300), width: 2),
            ),
            child: Column(
              children: [
                Icon(
                  _musicVolume == 0
                      ? Icons.volume_off
                      : _musicVolume < 0.5
                      ? Icons.volume_down
                      : Icons.volume_up,
                  color: Colors.amber,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  '${(_musicVolume * 100).round()}%',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 24,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 24),
                Slider(
                  value: _musicVolume,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  activeColor: const Color(0xFFFFB300),
                  inactiveColor: Colors.white24,
                  onChanged: (value) => _updateMusicVolume(value),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickVolumeButton('MUTE', 0),
                    _buildQuickVolumeButton('50%', 0.5),
                    _buildQuickVolumeButton('100%', 1.0),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickVolumeButton(String label, double value) {
    return ElevatedButton(
      onPressed: () => _updateMusicVolume(value),
      style: ElevatedButton.styleFrom(
        backgroundColor: _musicVolume == value
            ? const Color(0xFFFFB300)
            : const Color(0xFF1A237E),
        foregroundColor: _musicVolume == value ? Colors.black : Colors.white,
      ),
      child: Text(label, style: GoogleFonts.pressStart2p(fontSize: 10)),
    );
  }
}
