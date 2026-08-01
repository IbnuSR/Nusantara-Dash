import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nusantara_dash/game/nusantara_dash_game.dart';
import 'package:nusantara_dash/game/data/museum_item_model.dart';
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
  int _totalLives = 3;
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
    if (_totalLives <= 0) _totalLives = 3;
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
      onCulturalItemUnlocked: _showCulturalItemRewardDialog,
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
              Text('Koin Terkumpul: $_sessionCoins',
                  style: GoogleFonts.pressStart2p(
                      color: Colors.amber, fontSize: 12)),
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

  void _showCulturalItemRewardDialog(CulturalItem item) {
    AudioManager.instance.playSFX('sfx_coin.mp3');
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
                '🏛️ ITEM BUDAYA DITEMUKAN!',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  color: Colors.amber,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber, width: 1),
                ),
                child: Text(
                  '📍 ${item.province.toUpperCase()} - ${item.island.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.amberAccent, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  item.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.account_balance_outlined,
                      color: Colors.amber,
                      size: 50,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _game.resumeEngine();
                },
                icon: const Icon(Icons.museum_outlined),
                label: const Text('SIMPAN KE MUSEUM'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                      shadows: [
                        const Shadow(color: Colors.black, blurRadius: 10)
                      ])),
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
                Navigator.pop(context);
                _showVictoryDialog();
              },
              onBattleLose: () {
                Navigator.pop(context);
                _game.resetBossTrigger();
                _handlePlayerDeath();
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
              Text('$_sessionCoins',
                  style: GoogleFonts.pressStart2p(
                      color: Colors.amber, fontSize: 16)),
              const SizedBox(height: 10),
              const Text('Bonus Level:', style: TextStyle(color: Colors.white)),
              Text('+200',
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
      if (_showSettings) {
        _game.pauseEngine();
      } else {
        _game.resumeEngine();
      }
    });
  }

  // --- WIDGET HELPER HUD RETRO ---

  Widget _buildPixelCoinHUD() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/battle/coin.png',
          width: 32,
          height: 32,
          errorBuilder: (ctx, err, stack) =>
              Image.asset('assets/images/battle/ui_coin_box.png', width: 32),
        ),
        const SizedBox(width: 8),
        Text(
          '$_sessionCoins',
          style: GoogleFonts.pressStart2p(
            color: Colors.amber,
            fontSize: 14,
            shadows: [
              const Shadow(
                  color: Colors.black, offset: Offset(2, 2), blurRadius: 2)
            ],
          ),
        ),
      ],
    );
  }

  // 🔥 PERBAIKAN: HUD NYAWA KINI HANYA 1 GAMBAR HATI + TEKS JUMLAH NYAWA
  Widget _buildPixelHeartsHUD() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/battle/heart_full.png',
          width: 30,
          height: 30,
          errorBuilder: (ctx, err, stack) => const Icon(
            Icons.favorite,
            color: Colors.red,
            size: 28,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'x $_totalLives',
          style: GoogleFonts.pressStart2p(
            color: Colors.white,
            fontSize: 14,
            shadows: [
              const Shadow(
                color: Colors.black,
                offset: Offset(2, 2),
                blurRadius: 2,
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Layer Game Engine
          SizedBox.expand(child: GameWidget(key: ValueKey(_game), game: _game)),

          // --- LAYER HUD KIRI ATAS ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.landscape,
                          color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        widget.islandName.toUpperCase(),
                        style: GoogleFonts.pressStart2p(
                          color: Colors.white,
                          fontSize: 14,
                          shadows: [
                            const Shadow(
                                color: Colors.black,
                                offset: Offset(2, 2),
                                blurRadius: 4)
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildPixelCoinHUD(),
                  const SizedBox(height: 10),
                  _buildPixelHeartsHUD(), // ⬅️ Memanggil HUD Nyawa yang baru
                ],
              ),
            ),
          ),

          // --- LAYER TOMBOL SETTING (KANAN ATAS) ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _toggleSettings,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.brown[800],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFD4AF37), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 4)
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/battle/btn_settings.png',
                        width: 32,
                        height: 32,
                        errorBuilder: (ctx, err, stack) => const Icon(
                            Icons.settings,
                            color: Colors.amber,
                            size: 28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // OVERLAY PENGATURAN
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
                        Text('⚙️ PENGATURAN',
                            style: GoogleFonts.pressStart2p(
                                color: Colors.amber, fontSize: 16)),
                        const SizedBox(height: 20),
                        _buildStatRow(Icons.favorite, 'Sisa Nyawa',
                            '$_totalLives', Colors.redAccent),
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
