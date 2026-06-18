import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'nusantara_dash_game.dart';

class GameScreen extends StatefulWidget {
  final String islandName;

  const GameScreen({super.key, required this.islandName});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late NusantaraDashGame _game;
  int _coins = 0;
  int _lives = 3;
  double _distance = 0;
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _game = NusantaraDashGame(islandName: widget.islandName);

    // KUNCI LANDSCAPE SAAT MASUK GAME
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _toggleSettings() {
    setState(() {
      _showSettings = !_showSettings;
      if (_showSettings) {
        _game.pauseEngine();
      } else {
        _game.resumeEngine();
      }
    });
  }

  void _gameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0000),
        title: const Text(
          '💀 GAME OVER',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Koin: $_coins', style: const TextStyle(color: Colors.amber)),
            Text(
              'Jarak: ${_distance.toInt()}m',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartGame();
            },
            child: const Text(
              'COBA LAGI',
              style: TextStyle(color: Colors.amber),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'KEMBALI',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _coins = 0;
      _lives = 3;
      _distance = 0;
      _showSettings = false;
      _game = NusantaraDashGame(islandName: widget.islandName);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // ✅ FIX: LayoutBuilder nunggu sampai constraint-nya benar-benar
      // landscape (lebar > tinggi) sebelum GameWidget di-mount.
      // Sebelumnya GameWidget langsung mount walau device belum
      // selesai rotasi, jadi Flame ngambil "size" yang masih salah
      // (tinggi portrait) buat hitung groundY -> player tenggelam.
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscapeReady = constraints.maxWidth > constraints.maxHeight;

          if (!isLandscapeReady) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            );
          }

          return Stack(
            children: [
              // GAME FULL SCREEN
              SizedBox.expand(child: GameWidget(game: _game)),

              // Top Bar - Settings Button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _toggleSettings,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber, width: 2),
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.amber,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Settings Menu
              if (_showSettings)
                Container(
                  color: Colors.black.withOpacity(0.85),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(40),
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A237E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber, width: 3),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '⚙️ PENGATURAN',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildStatRow(
                            Icons.monetization_on,
                            'Koin',
                            '$_coins',
                            Colors.amber,
                          ),
                          const SizedBox(height: 15),
                          _buildStatRow(
                            Icons.route,
                            'Jarak',
                            '${_distance.toInt()}m',
                            Colors.blue,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: _toggleSettings,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('LANJUTKAN GAME'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton.icon(
                            onPressed: _restartGame,
                            icon: const Icon(Icons.replay),
                            label: const Text('MAIN ULANG'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.exit_to_app),
                            label: const Text('KELUAR KE MENU'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
