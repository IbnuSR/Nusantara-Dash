import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/audio_manager.dart';
import '../../../utils/game_prefs.dart';

class AudioSettings extends StatefulWidget {
  const AudioSettings({super.key});

  @override
  State<AudioSettings> createState() => _AudioSettingsState();
}

class _AudioSettingsState extends State<AudioSettings> {
  double _musicVolume = 0.5;
  double _sfxVolume = 0.7;
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // ✅ Ambil dari AudioManager (sudah sinkron dengan GamePrefs)
    setState(() {
      _musicVolume = AudioManager.instance.bgmVolume;
      _sfxVolume = AudioManager.instance.sfxVolume;
      _musicEnabled = AudioManager.instance.isBGMEnabled;
      _sfxEnabled = AudioManager.instance.isSFXEnabled;
      _isLoading = false;
    });
  }

  /// ✅ Update volume musik REAL-TIME
  Future<void> _updateMusicVolume(double volume) async {
    setState(() => _musicVolume = volume);

    // ✅ Langsung update AudioManager (real-time)
    await AudioManager.instance.setBGMVolume(volume);

    // ✅ Update state enabled
    if (volume > 0 && !_musicEnabled) {
      setState(() => _musicEnabled = true);
    }
  }

  /// ✅ Update volume SFX REAL-TIME
  Future<void> _updateSFXVolume(double volume) async {
    setState(() => _sfxVolume = volume);

    // ✅ Langsung update AudioManager (real-time)
    await AudioManager.instance.setSFXVolume(volume);

    if (volume > 0 && !_sfxEnabled) {
      setState(() => _sfxEnabled = true);
    }
  }

  /// ✅ Toggle musik
  Future<void> _toggleMusic() async {
    await AudioManager.instance.toggleBGM();
    setState(() => _musicEnabled = AudioManager.instance.isBGMEnabled);
  }

  /// ✅ Toggle SFX
  Future<void> _toggleSFX() async {
    await AudioManager.instance.toggleSFX();
    setState(() => _sfxEnabled = AudioManager.instance.isSFXEnabled);
  }

  /// ✅ Test SFX
  void _testSFX(String path) {
    AudioManager.instance.playSFX(path);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎵 MUSIC VOLUME
          _buildSectionHeader(
            '🎵 VOLUME MUSIK',
            'Atur volume Background Music',
          ),
          const SizedBox(height: 16),
          _buildVolumeCard(
            title: 'Music',
            volume: _musicVolume,
            enabled: _musicEnabled,
            onVolumeChanged: _updateMusicVolume,
            onToggle: _toggleMusic,
            quickValues: const [
              ('MUTE', 0.0),
              ('25%', 0.25),
              ('50%', 0.5),
              ('75%', 0.75),
              ('100%', 1.0),
            ],
          ),

          const SizedBox(height: 32),

          // 🔊 SFX VOLUME
          _buildSectionHeader('🔊 VOLUME SFX', 'Atur volume Sound Effect'),
          const SizedBox(height: 16),
          _buildVolumeCard(
            title: 'SFX',
            volume: _sfxVolume,
            enabled: _sfxEnabled,
            onVolumeChanged: _updateSFXVolume,
            onToggle: _toggleSFX,
            quickValues: const [('MUTE', 0.0), ('50%', 0.5), ('100%', 1.0)],
          ),

          const SizedBox(height: 32),

          // 🎮 TEST AUDIO
          _buildSectionHeader(
            '🎮 TEST AUDIO',
            'Tes suara untuk memastikan setting bekerja',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2845),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFB300), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _testSFX('audio/sfx/coin.mp3'),
                  icon: const Icon(Icons.monetization_on),
                  label: const Text('COIN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _testSFX('audio/sfx/jump.mp3'),
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('JUMP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.pressStart2p(fontSize: 14, color: Colors.amber),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildVolumeCard({
    required String title,
    required double volume,
    required bool enabled,
    required Function(double) onVolumeChanged,
    required VoidCallback onToggle,
    required List<(String, double)> quickValues,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2845),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB300), width: 2),
      ),
      child: Column(
        children: [
          // Header dengan icon & switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                !enabled
                    ? Icons.volume_off
                    : volume == 0
                    ? Icons.volume_mute
                    : volume < 0.5
                    ? Icons.volume_down
                    : Icons.volume_up,
                color: enabled ? Colors.amber : Colors.grey,
                size: 60,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 12,
                      color: enabled ? Colors.amber : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Switch(
                    value: enabled,
                    onChanged: (_) => onToggle(),
                    activeColor: Colors.amber,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Persentase
          Text(
            '${(volume * 100).round()}%',
            style: GoogleFonts.pressStart2p(
              fontSize: 24,
              color: enabled ? Colors.amber : Colors.grey,
            ),
          ),

          const SizedBox(height: 24),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: enabled ? const Color(0xFFFFB300) : Colors.grey,
              inactiveTrackColor: Colors.white24,
              thumbColor: enabled ? const Color(0xFFFFB300) : Colors.grey,
              overlayColor: (enabled ? Colors.amber : Colors.grey).withOpacity(
                0.2,
              ),
              trackHeight: 6,
            ),
            child: Slider(
              value: volume,
              min: 0,
              max: 1,
              divisions: 20,
              onChanged: enabled ? (value) => onVolumeChanged(value) : null,
            ),
          ),

          const SizedBox(height: 16),

          // Quick buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: quickValues.map((item) {
              final label = item.$1;
              final value = item.$2;
              final isActive = (volume * 100).round() == (value * 100).round();

              return ElevatedButton(
                onPressed: () => onVolumeChanged(value),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive
                      ? const Color(0xFFFFB300)
                      : const Color(0xFF1A237E),
                  foregroundColor: isActive ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  side: BorderSide(
                    color: isActive ? Colors.amber : Colors.white24,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.pressStart2p(fontSize: 10),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
