import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nusantara_dash/utils/game_prefs.dart';
import 'package:nusantara_dash/utils/audio_manager.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}

class BattleScreen extends StatefulWidget {
  final String islandName;
  final VoidCallback onBattleWin;
  final VoidCallback onBattleLose;
  final VoidCallback onExit;
  final int currentLives;

  const BattleScreen({
    super.key,
    required this.islandName,
    required this.onBattleWin,
    required this.onBattleLose,
    required this.onExit,
    required this.currentLives,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with TickerProviderStateMixin {
  int playerHP = 100;
  int bossHP = 100;
  int currentQuestionIndex = 0;

  // Total soal yang ditampilkan (Sesuai gambar "Pertanyaan 1/10")
  int totalQuestions = 10;

  int countdown = 3;
  bool isCountingDown = true;
  bool isQuizVisible = false;
  bool isAnswering = false;
  bool isBattleOver = false;
  int _sessionCoins = 0;

  late List<QuizQuestion> _questions;

  // Animasi Serangan
  late AnimationController _satriaAttackController;
  late AnimationController _bossAttackController;
  late Animation<double> _satriaAttackAnimation;
  late Animation<double> _bossAttackAnimation;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _questions = _getSumatraQuestions();

    // Setup Animasi Serangan
    _satriaAttackController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _bossAttackController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _satriaAttackAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _satriaAttackController, curve: Curves.easeInOutBack));
    _bossAttackAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _bossAttackController, curve: Curves.easeInOutBack));

    _startCountdown();
  }

  Future<void> _loadInitialData() async {
    int coins = await GamePrefs.getCoins();
    setState(() {
      _sessionCoins = coins;
    });
  }

  @override
  void dispose() {
    _satriaAttackController.dispose();
    _bossAttackController.dispose();
    super.dispose();
  }

  // Khusus Sumatra sesuai permintaan
  List<QuizQuestion> _getSumatraQuestions() {
    List<QuizQuestion> allQuestions = [
      QuizQuestion(
        question:
            'Manakah di bawah ini yang merupakan senjata tradisional khas Aceh?',
        options: ['Rencong', 'Mandau', 'Keris', 'Badik'],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Rumah adat khas Minangkabau disebut?',
        options: ['Honai', 'Rumah Gadang', 'Joglo', 'Tongkonan'],
        correctAnswer: 1,
      ),
      QuizQuestion(
        question: 'Danau vulkanik terbesar di Sumatra Utara adalah?',
        options: [
          'Danau Singkarak',
          'Danau Maninjau',
          'Danau Toba',
          'Danau Ranau'
        ],
        correctAnswer: 2,
      ),
      QuizQuestion(
        question: 'Tari Saman yang sangat dinamis berasal dari daerah?',
        options: ['Sumatra Barat', 'Riau', 'Lampung', 'Aceh'],
        correctAnswer: 3,
      ),
      // Tambahkan soal lain hingga cukup...
    ];
    allQuestions.shuffle(Random());
    return allQuestions;
  }

  String _getWeaponId(String island) {
    switch (island.toUpperCase()) {
      case 'JAWA':
        return 'keris_jawa';
      case 'KALIMANTAN':
        return 'mandau_kalimantan';
      case 'SULAWESI':
        return 'badik_sulawesi';
      case 'PAPUA':
        return 'busur_papua';
      default:
        return 'rencong_sumatra';
    }
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown <= 0) {
        timer.cancel();
        if (mounted) {
          setState(() {
            isCountingDown = false;
            isQuizVisible = true;
          });
          AudioManager.instance.playSFX('sfx_question.mp3');
        }
      } else {
        if (mounted) setState(() => countdown--);
      }
    });
  }

  void _handleAnswer(int selectedIndex) {
    if (isAnswering || isBattleOver) return;
    setState(() => isAnswering = true);

    bool isCorrect =
        (selectedIndex == _questions[currentQuestionIndex].correctAnswer);

    setState(() {
      isQuizVisible = false;
    });

    if (isCorrect) {
      _performSatriaAttack();
    } else {
      _performBossAttack();
    }
  }

  void _performSatriaAttack() {
    AudioManager.instance.playSFX('sfx_jump.mp3'); // Suara dash
    _satriaAttackController.forward().then((_) {
      _satriaAttackController.reverse();
      AudioManager.instance.playSFX('sfx_boss_hit.mp3');

      setState(() {
        bossHP = (bossHP - 20).clamp(0, 100);
      });

      _checkBattleStatus();
    });
  }

  void _performBossAttack() {
    AudioManager.instance.playSFX('sfx_boss_roar.mp3'); // Suara harimau
    _bossAttackController.forward().then((_) {
      _bossAttackController.reverse();
      AudioManager.instance.playSFX('sfx_hit_flesh.mp3');

      setState(() {
        playerHP = (playerHP - 25).clamp(0, 100);
      });

      _checkBattleStatus();
    });
  }

  void _checkBattleStatus() {
    if (bossHP <= 0) {
      _battleWin();
    } else if (playerHP <= 0) {
      _battleLose();
    } else {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            currentQuestionIndex++;
            if (currentQuestionIndex >= _questions.length) {
              _questions.shuffle();
              currentQuestionIndex = 0;
            }
            isQuizVisible = true;
            isAnswering = false;
          });
        }
      });
    }
  }

  void _battleWin() {
    setState(() => isBattleOver = true);
    AudioManager.instance.playSFX('sfx_victory_fanfare.mp3');
  }

  void _battleLose() {
    setState(() => isBattleOver = true);
    AudioManager.instance.playSFX('sfx_gameover.mp3');
  }

  // --- 🔥 LOGIKA BARU: Menyimpan Progres dan Membuka Map Selanjutnya ---
  Future<void> _proceedToNext() async {
    // 1. Tandai bos di pulau ini sudah dikalahkan
    await GamePrefs.markBossDefeated(widget.islandName);

    // 2. Buka pulau selanjutnya secara berurutan
    String currentIsland = widget.islandName.toUpperCase();
    if (currentIsland == 'SUMATRA') {
      await GamePrefs.unlockIsland('JAWA');
      print('🔓 PULAU JAWA TELAH DIBUKA!');
    } else if (currentIsland == 'JAWA') {
      await GamePrefs.unlockIsland('KALIMANTAN');
      print('🔓 PULAU KALIMANTAN TELAH DIBUKA!');
    } else if (currentIsland == 'KALIMANTAN') {
      await GamePrefs.unlockIsland('SULAWESI');
      print('🔓 PULAU SULAWESI TELAH DIBUKA!');
    } else if (currentIsland == 'SULAWESI') {
      await GamePrefs.unlockIsland('PAPUA');
      print('🔓 PULAU PAPUA TELAH DIBUKA!');
    }

    // 3. Tambahkan senjata baru ke inventory
    await GamePrefs.unlockWeapon(_getWeaponId(widget.islandName));

    // 4. Berikan hadiah koin kemenangan
    await GamePrefs.addCoins(500);

    // 5. Memicu fungsi onBattleWin yang akan kembali ke MapScreen
    if (mounted) {
      widget.onBattleWin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. BACKGROUND (Gambar Pegunungan & Air Terjun)
          Image.asset(
            'assets/images/battle/bg_sumatra.png',
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) =>
                Container(color: const Color(0xFF4A86E8)),
          ),

          // 2. TANAH / GROUND
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/battle/ground_battle.png',
              fit: BoxFit.fitWidth,
              height: 80,
              errorBuilder: (ctx, err, stack) =>
                  Container(height: 80, color: const Color(0xFF5D4037)),
            ),
          ),

          // 3. KARAKTER SATRIA (Dengan Animasi Maju Mundur)
          AnimatedBuilder(
            animation: _satriaAttackAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 60,
                left: 100 +
                    (_satriaAttackAnimation.value *
                        200), // Maju 200px saat serang
                child: Image.asset(
                  'assets/images/battle/satria_idle.png',
                  height: 120,
                  errorBuilder: (ctx, err, stack) =>
                      const Icon(Icons.person, size: 100, color: Colors.blue),
                ),
              );
            },
          ),

          // 4. KARAKTER BOSS (SANG BELANG)
          AnimatedBuilder(
            animation: _bossAttackAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 60,
                right: 50 +
                    (_bossAttackAnimation.value *
                        200), // Maju ke kiri saat serang
                child: Image.asset(
                  'assets/images/battle/boss_sang_belang.png',
                  height: 250,
                  errorBuilder: (ctx, err, stack) =>
                      const Icon(Icons.pets, size: 150, color: Colors.red),
                ),
              );
            },
          ),

          // 5. HUD ATAS (Koin, Kunci, Nyawa, Tombol)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KIRI: Koin & Kunci & Nyawa Satria
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildAssetBox(
                                  'assets/images/battle/ui_coin_box.png',
                                  '$_sessionCoins',
                                  Icons.monetization_on,
                                  Colors.amber),
                              const SizedBox(width: 10),
                              _buildAssetBox(
                                  'assets/images/battle/ui_key_box.png',
                                  '${widget.currentLives}',
                                  Icons.vpn_key,
                                  Colors.amber),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildCustomHPBar('SATRIA', playerHP,
                              'assets/images/battle/hp_frame_player.png', true),
                        ],
                      ),

                      // KANAN: Tombol Setting & Nyawa Bos
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              _buildImageButton(
                                  'assets/images/battle/btn_settings.png',
                                  Icons.settings),
                              const SizedBox(width: 10),
                              _buildImageButton(
                                  'assets/images/battle/btn_help.png',
                                  Icons.help),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildCustomHPBar('SANG BELANG', bossHP,
                              'assets/images/battle/hp_frame_boss.png', false),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 6. COUNTDOWN MUNCUL DI TENGAH
          if (isCountingDown && !isBattleOver)
            Center(
              child: Text(
                '$countdown',
                style: GoogleFonts.pressStart2p(
                    fontSize: 100,
                    color: Colors.amber,
                    shadows: const [
                      Shadow(color: Colors.black, blurRadius: 10)
                    ]),
              ),
            ),

          // 7. PAPAN KUIS (MUNCUL DENGAN DESAIN KAYU)
          if (isQuizVisible && !isBattleOver) _buildWoodenQuizPopup(),

          // 8. LAYAR GAME OVER / WIN (Sementara pakai desain lama, bisa kamu ganti kotaknya nanti)
          if (isBattleOver) _buildEndScreen(),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildAssetBox(String assetPath, String text, IconData fallbackIcon,
      Color fallbackColor) {
    return Container(
      width: 100,
      height: 35,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(assetPath),
          fit: BoxFit.fill,
          onError: (exception,
              stackTrace) {}, // Hindari error merah jika gambar belum ada
        ),
        color: Colors.black54, // Fallback warna
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(fallbackIcon, color: fallbackColor, size: 16),
            const SizedBox(width: 5),
            Text(text,
                style: GoogleFonts.pressStart2p(
                    color: Colors.white, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageButton(String assetPath, IconData fallbackIcon) {
    return GestureDetector(
      onTap: () {}, // Isi fungsi pause/settings
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {},
          ),
          color: Colors.brown[700],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        ),
        child: Icon(fallbackIcon,
            color: Colors.amber, size: 24), // Tampil kalau gambar gak ada
      ),
    );
  }

  Widget _buildCustomHPBar(
      String name, int hp, String frameAsset, bool isPlayer) {
    return Column(
      crossAxisAlignment:
          isPlayer ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(name,
            style: GoogleFonts.pressStart2p(
                color: Colors.white,
                fontSize: 12,
                shadows: const [Shadow(color: Colors.black, blurRadius: 4)])),
        const SizedBox(height: 5),
        SizedBox(
          width: 200,
          height: 40,
          child: Stack(
            children: [
              // Bar Merah (Mengisi dari kiri ke kanan atau sebaliknya)
              Positioned(
                left: isPlayer ? 40 : 10,
                right: isPlayer ? 10 : 40,
                top: 10,
                bottom: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: hp / 100,
                    backgroundColor: Colors.black87,
                    valueColor: AlwaysStoppedAnimation<Color>(hp > 50
                        ? Colors.green
                        : (hp > 25 ? Colors.orange : Colors.red)),
                  ),
                ),
              ),
              // Bingkai Avatar & HP (Transparan di bagian bar)
              Positioned.fill(
                child: Image.asset(
                  frameAsset,
                  fit: BoxFit.contain,
                  alignment:
                      isPlayer ? Alignment.centerLeft : Alignment.centerRight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- DESAIN PAPAN KUIS BARU ---
  Widget _buildWoodenQuizPopup() {
    final question = _questions[currentQuestionIndex];
    final letters = ['[A]', '[B]', '[C]', '[D]'];

    return Center(
      child: Container(
        width: 500,
        height: 350, // Tetap 350 agar proporsi gambar background tidak berubah
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/battle/ui_wooden_board.png'),
            fit: BoxFit.fill,
          ),
          color: Colors.brown[800],
          borderRadius: BorderRadius.circular(16),
        ),
        padding:
            const EdgeInsets.only(top: 115, bottom: 30, left: 45, right: 45),
        child: Column(
          children: [
            Text(
              'Pertanyaan ${(currentQuestionIndex + 1)}/$totalQuestions:',
              style:
                  GoogleFonts.pressStart2p(fontSize: 10, color: Colors.amber),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Text(
                  question.question,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pressStart2p(
                      fontSize: 12, color: Colors.white, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // GRID BUTTONS 2x2
            SizedBox(
              height: 95,
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 4.5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(question.options.length, (index) {
                  return GestureDetector(
                    onTap: () => _handleAnswer(index),
                    child: Container(
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage(
                              'assets/images/battle/ui_wood_btn.png'),
                          fit: BoxFit.fill,
                        ),
                        color: Colors.brown[600],
                        border: Border.all(color: Colors.brown[900]!, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          Text(letters[index],
                              style: GoogleFonts.pressStart2p(
                                  fontSize: 10, color: Colors.white)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              question.options[index],
                              style: GoogleFonts.pressStart2p(
                                  fontSize: 9, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LAYAR SELESAI ---
  Widget _buildEndScreen() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(bossHP <= 0 ? 'SANG BELANG DIKALAHKAN!' : 'SATRIA ROBOH!',
                style: GoogleFonts.pressStart2p(
                    fontSize: 20,
                    color: bossHP <= 0 ? Colors.green : Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (bossHP <= 0) {
                  // 🔥 MODIFIKASI: Memanggil _proceedToNext() untuk membuka map selanjutnya
                  _proceedToNext();
                } else {
                  widget.onBattleLose();
                }
              },
              child: Text(bossHP <= 0 ? 'LANJUTKAN' : 'KEMBALI KE CHECKPOINT',
                  style: GoogleFonts.pressStart2p(fontSize: 12)),
            )
          ],
        ),
      ),
    );
  }
}
