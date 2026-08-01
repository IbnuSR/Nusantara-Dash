import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
    );
  }
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

  // Total soal yang ditampilkan
  int totalQuestions = 10;

  int countdown = 3;
  bool isCountingDown = true;
  bool isQuizVisible = false;
  bool isAnswering = false;
  bool isBattleOver = false;
  bool isLoadingQuestions = true;
  int _sessionCoins = 0;

  // Efek Layar Berkedip saat kena pukul
  bool _isScreenFlashingRed = false;
  bool _isScreenFlashingWhite = false;

  List<QuizQuestion> _questions = [];

  // Animasi Serangan
  late AnimationController _satriaAttackController;
  late AnimationController _bossAttackController;
  late Animation<double> _satriaAttackAnimation;
  late Animation<double> _bossAttackAnimation;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadQuestionsFromJson();

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

  // FUNGSI MEMBACA FILE JSON KUIS DINAMIS
  Future<void> _loadQuestionsFromJson() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/quiz_data.json');
      final data = await json.decode(response);

      String islandKey = widget.islandName.toUpperCase();
      List<dynamic> islandQuestions = data[islandKey] ?? data['SUMATRA'] ?? [];

      List<QuizQuestion> loadedQuestions =
          islandQuestions.map((q) => QuizQuestion.fromJson(q)).toList();

      loadedQuestions.shuffle(Random());

      setState(() {
        _questions = loadedQuestions;
        isLoadingQuestions = false;
      });
    } catch (e) {
      print("Error membaca JSON kuis: $e");
      setState(() {
        _questions = [
          QuizQuestion(
            question: 'Sebutkan rumah/pakaian adat tradisional!',
            options: ['Option A', 'Option B', 'Option C', 'Option D'],
            correctAnswer: 0,
          )
        ];
        isLoadingQuestions = false;
      });
    }
  }

  @override
  void dispose() {
    _satriaAttackController.dispose();
    _bossAttackController.dispose();
    super.dispose();
  }

  // --- 🔥 FUNGSI PEMBANTU ASSET DINAMIS PER PULAU ---
  String _getBgAsset(String island) {
    switch (island.toUpperCase()) {
      case 'JAWA':
        return 'assets/images/battle/bg_jawa.png';
      case 'KALIMANTAN':
        return 'assets/images/battle/bg_kalimantan.png';
      case 'SULAWESI':
        return 'assets/images/battle/bg_sulawesi.png';
      case 'PAPUA':
        return 'assets/images/battle/bg_papua.png';
      default:
        return 'assets/images/battle/bg_sumatra.png';
    }
  }

  String _getBossAsset(String island) {
    switch (island.toUpperCase()) {
      case 'JAWA':
        return 'assets/images/battle/boss_buto_amuka.png';
      case 'KALIMANTAN':
        return 'assets/images/battle/boss_kalimantan.png';
      case 'SULAWESI':
        return 'assets/images/battle/boss_sulawesi.png';
      case 'PAPUA':
        return 'assets/images/battle/boss_papua.png';
      default:
        return 'assets/images/battle/boss_sang_belang.png';
    }
  }

  // 🔥 ANIMASI FRAME SPRITE DINAMIS UNTUK SANG BELANG (SUMATRA)
  String _getDynamicBossAsset(String island, double attackProgress) {
    String baseAsset = _getBossAsset(island);

    // Jika bukan boss Sumatra atau sedang tidak menyerang, gunakan sprite diam
    if (island.toUpperCase() != 'SUMATRA' || attackProgress == 0.0) {
      return baseAsset;
    }

    // Pergantian frame berdasarkan seberapa dekat boss dengan Satria
    if (attackProgress < 0.25) {
      return 'assets/images/battle/sang_belang_atk1.png';
    } else if (attackProgress < 0.50) {
      return 'assets/images/battle/sang_belang_atk2.png';
    } else if (attackProgress < 0.75) {
      return 'assets/images/battle/sang_belang_atk3.png';
    } else {
      return 'assets/images/battle/sang_belang_atk4.png'; // Pukulan masuk
    }
  }

  String _getBossName(String island) {
    switch (island.toUpperCase()) {
      case 'JAWA':
        return 'BUTO AMUKA';
      case 'KALIMANTAN':
        return 'PANGUMA';
      case 'SULAWESI':
        return 'SOMBA';
      case 'PAPUA':
        return 'KASUARI SAKTI';
      default:
        return 'SANG BELANG';
    }
  }

  String _getBoardAsset(String island) {
    switch (island.toUpperCase()) {
      case 'JAWA':
        return 'assets/images/battle/ui_wooden_board_jawa.png';
      case 'KALIMANTAN':
        return 'assets/images/battle/ui_wooden_board_kalimantan.png';
      case 'SULAWESI':
        return 'assets/images/battle/ui_wooden_board_sulawesi.png';
      case 'PAPUA':
        return 'assets/images/battle/ui_wooden_board_papua.png';
      default:
        return 'assets/images/battle/ui_wooden_board.png';
    }
  }

  String _getBossFrameAsset(String island) {
    switch (island.toUpperCase()) {
      case 'JAWA':
        return 'assets/images/battle/hp_frame_boss_jawa.png';
      case 'KALIMANTAN':
        return 'assets/images/battle/hp_frame_boss_kalimantan.png';
      case 'SULAWESI':
        return 'assets/images/battle/hp_frame_boss_sulawesi.png';
      case 'PAPUA':
        return 'assets/images/battle/hp_frame_boss_papua.png';
      default:
        return 'assets/images/battle/hp_frame_boss.png';
    }
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
    if (isAnswering || isBattleOver || _questions.isEmpty) return;
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

  void _triggerScreenFlashRed() {
    setState(() => _isScreenFlashingRed = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isScreenFlashingRed = false);
    });
  }

  void _triggerScreenFlashWhite() {
    setState(() => _isScreenFlashingWhite = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isScreenFlashingWhite = false);
    });
  }

  void _performSatriaAttack() {
    AudioManager.instance.playSFX('sfx_jump.mp3');
    _satriaAttackController.forward().then((_) {
      // Saat Satria berada tepat di depan Bos (Flash Putih)
      _triggerScreenFlashWhite();
      AudioManager.instance.playSFX('sfx_boss_hit.mp3');

      _satriaAttackController.reverse();

      setState(() {
        bossHP = (bossHP - 20).clamp(0, 100);
      });

      _checkBattleStatus();
    });
  }

  void _performBossAttack() {
    AudioManager.instance.playSFX('sfx_boss_roar.mp3');
    _bossAttackController.forward().then((_) {
      // Saat Boss berada tepat di depan Satria & Pukulan masuk (Flash Merah)
      _triggerScreenFlashRed();
      AudioManager.instance.playSFX('sfx_hit_flesh.mp3');

      _bossAttackController.reverse();

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

  Future<void> _proceedToNext() async {
    await GamePrefs.markBossDefeated(widget.islandName);

    String currentIsland = widget.islandName.toUpperCase();
    if (currentIsland == 'SUMATRA') {
      await GamePrefs.unlockIsland('JAWA');
    } else if (currentIsland == 'JAWA') {
      await GamePrefs.unlockIsland('KALIMANTAN');
    } else if (currentIsland == 'KALIMANTAN') {
      await GamePrefs.unlockIsland('SULAWESI');
    } else if (currentIsland == 'SULAWESI') {
      await GamePrefs.unlockIsland('PAPUA');
    }

    await GamePrefs.unlockWeapon(_getWeaponId(widget.islandName));
    await GamePrefs.addCoins(500);

    if (mounted) {
      widget.onBattleWin();
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.brown[800],
              border: Border.all(color: const Color(0xFFD4AF37), width: 4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PENGATURAN',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.amber,
                    fontSize: 16,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onExit();
                  },
                  child: Text(
                    'MENYERAH & KELUAR',
                    style: GoogleFonts.pressStart2p(
                        fontSize: 10, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[600],
                    side: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'LANJUT BERTARUNG',
                    style: GoogleFonts.pressStart2p(
                        fontSize: 10, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. BACKGROUND DINAMIS SESUAI PULAU
          Image.asset(
            _getBgAsset(widget.islandName),
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => Image.asset(
              'assets/images/battle/bg_sumatra.png',
              fit: BoxFit.cover,
            ),
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

          // 3. KARAKTER SATRIA
          AnimatedBuilder(
            animation: _satriaAttackAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 60,
                left: 100 + (_satriaAttackAnimation.value * 200),
                child: Image.asset(
                  'assets/images/battle/satria_idle.png',
                  height: 120,
                  errorBuilder: (ctx, err, stack) =>
                      const Icon(Icons.person, size: 100, color: Colors.blue),
                ),
              );
            },
          ),

          // 4. KARAKTER BOSS DINAMIS (SPRITE SHEET FRAME SWAP)
          AnimatedBuilder(
            animation: _bossAttackAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 60,
                right: 50 + (_bossAttackAnimation.value * 200),
                child: Image.asset(
                  // Menggunakan fungsi Helper Sprite yang kita buat
                  _getDynamicBossAsset(
                      widget.islandName, _bossAttackAnimation.value),
                  height: 250,
                  errorBuilder: (ctx, err, stack) => Image.asset(
                    'assets/images/battle/boss_sang_belang.png',
                    height: 250,
                  ),
                ),
              );
            },
          ),

          // --- EFEK FLASH KETIKA TERKENA SERANGAN ---
          if (_isScreenFlashingRed)
            Positioned.fill(
              child: Container(color: Colors.red.withOpacity(0.5)),
            ),
          if (_isScreenFlashingWhite)
            Positioned.fill(
              child: Container(color: Colors.white.withOpacity(0.6)),
            ),

          // 5. HUD ATAS (Koin, Kunci, Nyawa Satria & Nyawa Bos)
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
                                  isKeyBox: false),
                              const SizedBox(width: 10),
                              _buildAssetBox(
                                  'assets/images/battle/ui_key_box.png',
                                  '${widget.currentLives}',
                                  isKeyBox: true),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildCustomHPBar('SATRIA', playerHP,
                              'assets/images/battle/hp_frame_player.png', true),
                        ],
                      ),

                      // KANAN: Tombol Setting & Nama Bos Dinamis
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              _buildImageButton(
                                'assets/images/battle/btn_settings.png',
                                () => _showSettingsDialog(),
                              ),
                              const SizedBox(width: 10),
                              _buildImageButton(
                                'assets/images/battle/btn_help.png',
                                () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildCustomHPBar(
                              _getBossName(widget.islandName),
                              bossHP,
                              _getBossFrameAsset(widget.islandName),
                              false),
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

          // 7. PAPAN KUIS (DESAIN PAPAN DINAMIS SESUAI PULAU)
          if (isQuizVisible && !isBattleOver && !isLoadingQuestions)
            _buildWoodenQuizPopup(),

          // 8. LAYAR GAME OVER / WIN
          if (isBattleOver) _buildEndScreen(),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildAssetBox(String assetPath, String text,
      {bool isKeyBox = false}) {
    return Container(
      width: 105,
      height: 35,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(assetPath),
          fit: BoxFit.fill,
          onError: (exception, stackTrace) {},
        ),
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
      ),
      alignment: isKeyBox ? Alignment.centerRight : Alignment.centerLeft,
      padding: isKeyBox
          ? const EdgeInsets.only(right: 15.0)
          : const EdgeInsets.only(left: 45.0),
      child: Text(
        text,
        style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10),
      ),
    );
  }

  Widget _buildImageButton(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
              Positioned.fill(
                child: Image.asset(
                  frameAsset,
                  fit: BoxFit.contain,
                  alignment:
                      isPlayer ? Alignment.centerLeft : Alignment.centerRight,
                  errorBuilder: (ctx, err, stack) {
                    if (!isPlayer) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.only(right: 2),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              border: Border.all(
                                  color: const Color(0xFFD4AF37), width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                _getBossAsset(widget.islandName),
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- DESAIN PAPAN KUIS ---
  Widget _buildWoodenQuizPopup() {
    if (_questions.isEmpty) return const SizedBox.shrink();

    final question = _questions[currentQuestionIndex];
    final letters = ['[A]', '[B]', '[C]', '[D]'];

    return Center(
      child: Container(
        width: 500,
        height: 350,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_getBoardAsset(widget.islandName)),
            fit: BoxFit.fill,
            onError: (err, stack) => const DecorationImage(
              image: AssetImage('assets/images/battle/ui_wooden_board.png'),
              fit: BoxFit.fill,
            ),
          ),
          color: Colors.brown[800],
          borderRadius: BorderRadius.circular(16),
        ),
        padding:
            const EdgeInsets.only(top: 115, bottom: 45, left: 45, right: 45),
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
    String bossName = _getBossName(widget.islandName);

    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(bossHP <= 0 ? '$bossName DIKALAHKAN!' : 'SATRIA ROBOH!',
                style: GoogleFonts.pressStart2p(
                    fontSize: 18,
                    color: bossHP <= 0 ? Colors.green : Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (bossHP <= 0) {
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
