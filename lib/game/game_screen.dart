import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'nusantara_dash_game.dart';
import 'package:nusantara_dash/utils/coin_manager.dart'; // Jalur import absolut yang benar

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

  Future<void> _loadInventory() async {
    _totalLives = await CoinManager.getExtraLives();
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

  // ✅ KELUAR ATAU RESET PERMAINAN SECARA BERSIH
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
        Navigator.pop(context); // Kembali ke MapScreen secara langsung
      }
    }
  }

  Future<void> _useExtraLife() async {
    await CoinManager.useExtraLife();
    setState(() => _totalLives--);
    _game.updateLives(_totalLives);

    Navigator.pop(context);
    _game.player.respawn();
    _game.resumeEngine();
  }

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
        title: Text(
          '💀 GAME OVER',
          style: GoogleFonts.pressStart2p(color: Colors.red, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Koin Terkumpul Sesi Ini:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              '🪙 $_sessionCoins',
              style: GoogleFonts.pressStart2p(
                color: Colors.amber,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),

            if (_totalLives > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  'Kamu punya $_totalLives Nyawa Cadangan.\nMau pakai untuk lanjut?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            else
              const Text(
                'Nyawa cadangan habis.\nBeli di toko untuk lanjut!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            children: [
              if (_totalLives > 0)
                ElevatedButton.icon(
                  onPressed: _useExtraLife,
                  icon: const Icon(Icons.favorite),
                  label: const Text('PAKAI NYAWA (-1)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
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
                  minimumSize: const Size(double.infinity, 45),
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
        ],
      ),
    );
  }

  // ✅ KETIKA LEVEL FINISH
  void _showLevelCompleteDialog() async {
    // Tambahkan bonus tamat level senilai 200 koin langsung ke saldo utama storage
    await CoinManager.addCoins(200);

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
        title: Text(
          '🎉 LEVEL SELESAI!',
          style: GoogleFonts.pressStart2p(color: Colors.amber, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const Text(
              'Bonus Selesai Level:',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              '🪙 +200',
              style: GoogleFonts.pressStart2p(
                color: Colors.greenAccent,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Boss Area - Segera Hadir!',
              style: TextStyle(
                color: Colors.orangeAccent,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: const Text('KEMBALI KE PETA'),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscapeReady = constraints.maxWidth > constraints.maxHeight;

          if (!isLandscapeReady) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          return Stack(
            children: [
              // ✅ FIX KUNCI: Menambahkan 'key: ValueKey(_game)' agar Flutter menghapus instansiasme lama engine secara total saat reload
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
                            Icons.favorite,
                            'Nyawa',
                            '$_totalLives',
                            Colors.redAccent,
                          ),
                          const SizedBox(height: 15),
                          _buildStatRow(
                            Icons.monetization_on,
                            'Koin Sesi Ini',
                            '$_sessionCoins',
                            Colors.amber,
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
                            onPressed: () {
                              _toggleSettings();
                              _saveDataAndExit(false);
                            },
                            icon: const Icon(Icons.exit_to_app),
                            label: const Text('SIMPAN & KELUAR'),
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
