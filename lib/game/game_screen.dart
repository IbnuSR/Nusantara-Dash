import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nusantara_dash/game/nusantara_dash_game.dart';
import 'package:nusantara_dash/utils/game_prefs.dart';
import 'package:nusantara_dash/utils/audio_manager.dart';
import 'package:nusantara_dash/screens/battle_screen.dart';

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
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    AudioManager.instance.playBGM('audio/bgm/main_menu.mp3');
    super.dispose();
  }

  Future<void> _loadInventory() async {
    _totalLives = await GamePrefs.getExtraLives();
    _game.updateLives(_totalLives);
    if (mounted) setState(() {});
  }

  void _initGame() {
    _game = NusantaraDashGame(
      islandName: widget.islandName,
      onCoinsUpdated: (coins) {
        if (mounted) setState(() => _sessionCoins = coins);
      },
      onGameOver: _showFinalGameOverDialog,
      onLevelComplete: _showLevelCompleteDialog,
      onBossEncounter: _showBossBattle,
      onPlayerDied: _handlePlayerDeath,
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

  Future<void> _handlePlayerDeath() async {
    await GamePrefs.useExtraLife();
    int remainingLives = await GamePrefs.getExtraLives();

    if (mounted) {
      setState(() => _totalLives = remainingLives);
      _game.updateLives(_totalLives);
    }

    if (_totalLives > 0) {
      _showContinueDialog();
    } else {
      _showFinalGameOverDialog();
    }
  }

  void _showContinueDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A0000),
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.red, width: 3),
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('💀 KAMU MATI!',
                style:
                    GoogleFonts.pressStart2p(color: Colors.red, fontSize: 16)),
            const SizedBox(height: 15),
            Text('Sisa Nyawa: $_totalLives\nLanjut dari Checkpoint?',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _game.player.respawn();
                _game.resumeEngine();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('LANJUT (-1 Nyawa)'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _saveDataAndExit(false);
              },
              child: const Text('MENYERAH & KELUAR',
                  style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }

  void _showFinalGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A0000),
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.red, width: 3),
            borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('💀 GAME OVER',
                  style: GoogleFonts.pressStart2p(
                      color: Colors.red, fontSize: 16)),
              const SizedBox(height: 15),
              const Text('Nyawa Habis!', style: TextStyle(color: Colors.white)),
              Text('Koin Terkumpul: 🪙 $_sessionCoins',
                  style: GoogleFonts.pressStart2p(
                      color: Colors.amber, fontSize: 14)),
              const SizedBox(height: 20),
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
                    minimumSize: const Size(double.infinity, 40)),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _saveDataAndExit(false);
                },
                child: const Text('KELUAR KE PETA',
                    style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBossBattle() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('⚔️ BOSS ZONE',
                  style: GoogleFonts.pressStart2p(
                      fontSize: 32,
                      color: Colors.red,
                      shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
              const SizedBox(height: 30),
              const CircularProgressIndicator(color: Colors.amber),
              const SizedBox(height: 20),
              Text('Memasuki arena pertempuran...',
                  style: GoogleFonts.pressStart2p(
                      fontSize: 12, color: Colors.white)),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BattleScreen(
              islandName: widget.islandName,
              currentLives: _totalLives,
              onBattleWin: () {
                Navigator.pop(context); // Tutup layar battle
                _showVictoryDialog();
              },
              // 🔥 INI KUNCINYA: Saat kalah kuis, reset sensor bos & perlakukan seperti mati rintangan!
              onBattleLose: () {
                Navigator.pop(context); // Tutup layar battle
                _game.resetBossTrigger(); // Reset zona bos & mundurkan Satria
                _handlePlayerDeath(); // Tampilkan pop-up "Lanjut dari Checkpoint?"
              },
              onExit: () {
                Navigator.pop(context);
                _saveDataAndExit(false);
              },
            ),
          ),
        );
      }
    });
  }

  // ✅ HELPER DINAMIS: NAMA SENJATA PER PULAU
  String _getWeaponName(String island) {
    switch (island.toUpperCase()) {
      case 'JAWA':
        return '🗡️ Keris Pusaka';
      case 'KALIMANTAN':
        return '🗡️ Mandau Sakti';
      case 'SULAWESI':
        return '🗡️ Badik Keramat';
      case 'PAPUA':
        return '🏹 Busur Kasuari';
      default:
        return '🗡️ Rencong Suci';
    }
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A237E),
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.amber, width: 3),
            borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🏆 MINI BOSS DIKALAHKAN!',
                  style: GoogleFonts.pressStart2p(
                      color: Colors.amber, fontSize: 14)),
              const SizedBox(height: 15),
              const Text('Selamat! Kamu mendapatkan:',
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              // 🔥 UPDATE DINAMIS: Teks senjata mengikuti nama pulau
              Text(_getWeaponName(widget.islandName),
                  style: GoogleFonts.pressStart2p(
                      color: Colors.amber, fontSize: 14)),
              Text('🪙 +500 Koin',
                  style: GoogleFonts.pressStart2p(
                      color: Colors.greenAccent, fontSize: 14)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(
                      context); // Balik ke Peta (mengaktifkan .then refresh)
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 40)),
                child: const Text('KEMBALI KE PETA'),
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
            borderRadius: BorderRadius.circular(20)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎉 LEVEL SELESAI!',
                  style: GoogleFonts.pressStart2p(
                      color: Colors.amber, fontSize: 14)),
              const SizedBox(height: 15),
              const Text('Koin Dikumpulkan:',
                  style: TextStyle(color: Colors.white)),
              Text('🪙 $_sessionCoins',
                  style: GoogleFonts.pressStart2p(
                      color: Colors.amber, fontSize: 16)),
              const SizedBox(height: 10),
              const Text('Bonus Level:', style: TextStyle(color: Colors.white)),
              Text('🪙 +200',
                  style: GoogleFonts.pressStart2p(
                      color: Colors.greenAccent, fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 40)),
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
          SizedBox.expand(child: GameWidget(key: ValueKey(_game), game: _game)),
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
                          border: Border.all(color: Colors.amber, width: 2)),
                      child: const Icon(Icons.settings,
                          color: Colors.amber, size: 28),
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
                        border: Border.all(color: Colors.amber, width: 3)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⚙️ PENGATURAN',
                            style: TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        _buildStatRow(Icons.favorite, 'Nyawa', '$_totalLives',
                            Colors.redAccent),
                        _buildStatRow(Icons.monetization_on, 'Koin Sesi',
                            '$_sessionCoins', Colors.amber),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _toggleSettings,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('LANJUTKAN'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 40)),
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
                              minimumSize: const Size(double.infinity, 40)),
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
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white))
          ]),
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
