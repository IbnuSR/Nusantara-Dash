import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'nusantara_dash_game.dart';
import 'package:nusantara_dash/utils/game_prefs.dart';
import 'package:nusantara_dash/utils/audio_manager.dart';

class GameScreen extends StatefulWidget {
  final String islandName;

  const GameScreen({super.key, required this.islandName});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late NusantaraDashGame _game;
  int _sessionCoins = 0;
  int _totalLives = 0;
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _initGame();
    _loadInventory();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

// 🔥 TAMBAHKAN FUNGSI DISPOSE INI:
  @override
  void dispose() {
    // Ketika pemain keluar dari layar level (kembali ke Peta/Menu),
    // otomatis putar kembali musik BGM Menu Utama!
    AudioManager.instance.playBGM('audio/bgm/bgm_menu.mp3');
    super.dispose();
  }

  Future<void> _loadInventory() async {
    _totalLives = await GamePrefs.getExtraLives();
    _game.updateLives(_totalLives);
    setState(() {});
  }

  void _initGame() {
    _game = NusantaraDashGame(
      islandName: widget.islandName,
      onCoinsUpdated: (coins) {
        setState(() => _sessionCoins = coins);
      },
      onGameOver: _showGameOverDialog,
      onLevelComplete: _showLevelCompleteDialog,
    );
  }

  void _saveDataAndExit(bool restart) {
    if (mounted) {
      if (restart) {
        setState(() {
          _sessionCoins = 0;
          _showSettings = false;
        });
        _initGame();
        _loadInventory();
      } else {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _useExtraLife() async {
    await GamePrefs.useExtraLife();
    setState(() => _totalLives--);
    _game.updateLives(_totalLives);

    Navigator.pop(context);
    _game.player.respawn();
    _game.resumeEngine();
  }

  // ✅ FIX: Dialog dibungkus ScrollView agar tidak Overflow
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A0000),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.red, width: 3),
          borderRadius: BorderRadius.circular(20),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '💀 GAME OVER',
                style: GoogleFonts.pressStart2p(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Koin Terkumpul:',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                '🪙 $_sessionCoins',
                style: GoogleFonts.pressStart2p(
                  color: Colors.amber,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 15),

              if (_totalLives > 0)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Sisa $_totalLives Nyawa Cadangan.\nMau lanjut?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 15),

              // Tombol dipindah ke sini agar bisa di-scroll
              if (_totalLives > 0)
                ElevatedButton.icon(
                  onPressed: _useExtraLife,
                  icon: const Icon(Icons.favorite),
                  label: const Text('PAKAI NYAWA (-1)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _saveDataAndExit(true);
                },
                icon: const Icon(Icons.replay),
                label: const Text('ULANG DARI AWAL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _saveDataAndExit(false);
                },
                child: const Text(
                  'SIMPAN & KELUAR',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLevelCompleteDialog() async {
    await GamePrefs.addCoins(200);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A237E),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.amber, width: 3),
          borderRadius: BorderRadius.circular(20),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎉 LEVEL SELESAI!',
                style: GoogleFonts.pressStart2p(
                  color: Colors.amber,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Koin Dikumpulkan:',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                '🪙 $_sessionCoins',
                style: GoogleFonts.pressStart2p(
                  color: Colors.amber,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Bonus Level:', style: TextStyle(color: Colors.white)),
              Text(
                '🪙 +200',
                style: GoogleFonts.pressStart2p(
                  color: Colors.greenAccent,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text('KEMBALI KE PETA'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSettings() {
    setState(() {
      _showSettings = !_showSettings;
      if (_showSettings)
        _game.pauseEngine();
      else
        _game.resumeEngine();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox.expand(
            child: GameWidget(key: ValueKey(_game), game: _game),
          ),
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
          if (_showSettings)
            Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    constraints: const BoxConstraints(maxWidth: 400),
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildStatRow(
                          Icons.favorite,
                          'Nyawa',
                          '$_totalLives',
                          Colors.redAccent,
                        ),
                        _buildStatRow(
                          Icons.monetization_on,
                          'Koin Sesi',
                          '$_sessionCoins',
                          Colors.amber,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _toggleSettings,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('LANJUTKAN'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            _toggleSettings();
                            _saveDataAndExit(false);
                          },
                          icon: const Icon(Icons.exit_to_app),
                          label: const Text('KELUAR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
