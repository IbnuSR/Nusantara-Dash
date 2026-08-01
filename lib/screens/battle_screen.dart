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
  final bool isTextInput;
  final String textAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.isTextInput = false,
    this.textAnswer = '',
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
      isTextInput: json['isTextInput'] ?? false,
      textAnswer: json['textAnswer']?.toString().toLowerCase() ?? '',
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

  int totalQuestions = 10;
  int countdown = 3;
  bool isCountingDown = false;
  bool isQuizVisible = false;
  bool isAnswering = false;
  bool isBattleOver = false;
  bool isLoadingQuestions = true;

  int _sessionCoins = 0;
  // 🔥 PERUBAHAN: Variable ini sekarang mewakili jumlah KUNCI
  int _localKeys = 0;

  bool _isCinematicPlaying = true;
  double _blackScreenOpacity = 1.0;
  int _cinematicStep = 0;
  String _cinematicText = "Memasuki Wilayah Terlarang...";

  late AnimationController _walkBobbingController;

  bool _isScreenFlashingRed = false;
  bool _isScreenFlashingWhite = false;
  bool _isSatriaAttacking = false;
  bool _showSlashEffect = false;

  List<QuizQuestion> _questions = [];

  TextEditingController _textAnswerController = TextEditingController();
  bool? _isLastAnswerCorrect;
  int? _selectedOptionIndex;

  late AnimationController _satriaAttackController;
  late AnimationController _bossAttackController;
  late Animation<double> _satriaAttackAnimation;
  late Animation<double> _bossAttackAnimation;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadQuestionsFromJson();

    _walkBobbingController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _satriaAttackController = AnimationController(
        duration: const Duration(milliseconds: 450), vsync: this);
    _bossAttackController = AnimationController(
        duration: const Duration(milliseconds: 450), vsync: this);

    _satriaAttackAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _satriaAttackController, curve: Curves.easeInCubic));
    _bossAttackAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _bossAttackController, curve: Curves.easeInCubic));

    _startCinematicIntro();
  }

  Future<void> _startCinematicIntro() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      _blackScreenOpacity = 0.0;
      _cinematicStep = 1;
      _cinematicText = "Satria melangkah maju menghadapi tantangan...";
    });

    _walkBobbingController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    setState(() {
      _cinematicStep = 2;
    });

    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    _walkBobbingController.stop();
    _walkBobbingController.reset();

    setState(() {
      _cinematicStep = 3;
      _cinematicText =
          "Menemukan Pusaka Legendaris Pulau ${_getIslandDisplayName(widget.islandName)}!";
    });

    try {
      AudioManager.instance.playSFX('sfx_coin.mp3');
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _cinematicStep = 4;
      _cinematicText = "Waspada! Penjaga wilayah telah muncul!";
    });

    try {
      AudioManager.instance.playSFX('sfx_boss_roar.mp3');
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _blackScreenOpacity = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    setState(() {
      _isCinematicPlaying = false;
      _blackScreenOpacity = 0.0;
    });

    _startCountdown();
  }

  String _getIslandDisplayName(String island) {
    switch (island.toUpperCase()) {
      case 'JAWA':
        return 'Jawa';
      case 'KALIMANTAN':
        return 'Kalimantan';
      case 'SULAWESI':
        return 'Sulawesi';
      case 'PAPUA':
        return 'Papua';
      default:
        return 'Sumatra';
    }
  }

  Future<void> _loadInitialData() async {
    int coins = await GamePrefs.getCoins();
    // 🔥 PERBAIKAN: Ambil variabel Kunci dari database, BUKAN Nyawa!
    int keys = await GamePrefs.getKeys();

    if (mounted) {
      setState(() {
        _sessionCoins = coins;
        _localKeys = keys;
      });
    }
  }

  Future<void> _loadQuestionsFromJson() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/quiz_data.json');
      final data = await json.decode(response);

      String islandKey = widget.islandName.toUpperCase();
      List<dynamic> islandQuestions = data[islandKey] ?? data['SUMATRA'] ?? [];

      List<QuizQuestion> loadedQuestions =
          islandQuestions.map((q) => QuizQuestion.fromJson(q)).toList();

      List<QuizQuestion> mcQuestions =
          loadedQuestions.where((q) => !q.isTextInput).toList();
      List<QuizQuestion> inputQuestions =
          loadedQuestions.where((q) => q.isTextInput).toList();

      mcQuestions.shuffle(Random());
      inputQuestions.shuffle(Random());

      List<QuizQuestion> mixedQuestions = [];
      int mcIndex = 0;
      int inputIndex = 0;
      int totalLoaded = mcQuestions.length + inputQuestions.length;

      for (int i = 0; i < totalLoaded; i++) {
        if (i % 2 == 0) {
          if (mcIndex < mcQuestions.length) {
            mixedQuestions.add(mcQuestions[mcIndex]);
            mcIndex++;
          } else if (inputIndex < inputQuestions.length) {
            mixedQuestions.add(inputQuestions[inputIndex]);
            inputIndex++;
          }
        } else {
          if (inputIndex < inputQuestions.length) {
            mixedQuestions.add(inputQuestions[inputIndex]);
            inputIndex++;
          } else if (mcIndex < mcQuestions.length) {
            mixedQuestions.add(mcQuestions[mcIndex]);
            mcIndex++;
          }
        }
      }

      setState(() {
        _questions = mixedQuestions;
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
    _textAnswerController.dispose();
    _walkBobbingController.dispose();
    _satriaAttackController.dispose();
    _bossAttackController.dispose();
    super.dispose();
  }

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

  String _getDynamicBossAsset(String island, double attackProgress) {
    String baseAsset = _getBossAsset(island);
    if (island.toUpperCase() != 'SUMATRA' || attackProgress == 0.0) {
      return baseAsset;
    }
    if (attackProgress < 0.25)
      return 'assets/images/battle/sang_belang_atk1.png';
    else if (attackProgress < 0.50)
      return 'assets/images/battle/sang_belang_atk2.png';
    else if (attackProgress < 0.75)
      return 'assets/images/battle/sang_belang_atk3.png';
    else
      return 'assets/images/battle/sang_belang_atk4.png';
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
    setState(() => isCountingDown = true);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown <= 0) {
        timer.cancel();
        if (mounted) {
          setState(() {
            isCountingDown = false;
            isQuizVisible = true;
          });
          AudioManager.instance.playSFX('sfx_question.mp3');

          try {
            AudioManager.instance.stopBGM();
            AudioManager.instance.playBGM('audio/bgm_battle.mp3');
          } catch (e) {
            print("Gagal mengganti BGM: $e");
          }
        }
      } else {
        if (mounted) setState(() => countdown--);
      }
    });
  }

  Future<void> _processAnswer(bool isCorrect, {int? selectedIndex}) async {
    if (isAnswering || isBattleOver || _questions.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      isAnswering = true;
      _isLastAnswerCorrect = isCorrect;
      _selectedOptionIndex = selectedIndex;
    });

    try {
      if (isCorrect) {
        AudioManager.instance.playSFX('sfx_coin.mp3');
      } else {
        AudioManager.instance.playSFX('sfx_hit_flesh.mp3');
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    setState(() {
      isQuizVisible = false;
      _isLastAnswerCorrect = null;
      _selectedOptionIndex = null;
      _textAnswerController.clear();
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

  Future<void> _performSatriaAttack() async {
    setState(() => _isSatriaAttacking = true);
    AudioManager.instance.playSFX('sfx_jump.mp3');

    await _satriaAttackController.forward();

    _triggerScreenFlashWhite();
    AudioManager.instance.playSFX('sfx_boss_hit.mp3');

    setState(() {
      _showSlashEffect = true;
      bossHP = (bossHP - 20).clamp(0, 100);
    });

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _showSlashEffect = false;
      });

      await _satriaAttackController.reverse();

      if (mounted) {
        setState(() => _isSatriaAttacking = false);
        _checkBattleStatus();
      }
    }
  }

  Future<void> _performBossAttack() async {
    AudioManager.instance.playSFX('sfx_boss_roar.mp3');

    await _bossAttackController.forward();

    _triggerScreenFlashRed();
    AudioManager.instance.playSFX('sfx_hit_flesh.mp3');

    setState(() {
      playerHP = (playerHP - 25).clamp(0, 100);
    });

    await Future.delayed(const Duration(milliseconds: 250));

    await _bossAttackController.reverse();

    if (mounted) {
      _checkBattleStatus();
    }
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
    try {
      AudioManager.instance.stopBGM();
    } catch (_) {}
    AudioManager.instance.playSFX('sfx_victory_fanfare.mp3');
  }

  void _battleLose() {
    setState(() => isBattleOver = true);
    try {
      AudioManager.instance.stopBGM();
    } catch (_) {}
    AudioManager.instance.playSFX('sfx_gameover.mp3');
  }

  Future<void> _reviveSatria() async {
    if (_localKeys > 0) {
      // 🔥 PERBAIKAN: Potong Kunci di database, bukan potong Nyawa!
      await GamePrefs.useKey();
      int remainingKeys = await GamePrefs.getKeys();

      if (mounted) {
        setState(() {
          _localKeys = remainingKeys;
          playerHP = 100;
          isBattleOver = false;

          currentQuestionIndex++;
          if (currentQuestionIndex >= _questions.length) {
            _questions.shuffle();
            currentQuestionIndex = 0;
          }
          isQuizVisible = true;
          isAnswering = false;
        });

        try {
          AudioManager.instance.playBGM('audio/bgm_battle.mp3');
        } catch (_) {}
      }
    }
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
                    try {
                      AudioManager.instance.stopBGM();
                    } catch (_) {}
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
    final screenWidth = MediaQuery.of(context).size.width;
    final attackDistance = screenWidth - 300;

    double satriaCinematicLeft = 50;
    if (_cinematicStep >= 2) {
      satriaCinematicLeft = (screenWidth * 0.48) - 40;
    }

    bool showBossInCinematic = (_cinematicStep >= 4 || !_isCinematicPlaying);

    String getSatriaSprite() {
      if (_isSatriaAttacking)
        return 'assets/images/battle/satria_attack_keris.png';
      if (_isCinematicPlaying && _cinematicStep < 3)
        return 'assets/images/battle/satria_unarmed_walk.png';
      return 'assets/images/battle/satria_idle.png';
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _getBgAsset(widget.islandName),
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => Image.asset(
                'assets/images/battle/bg_sumatra.png',
                fit: BoxFit.cover),
          ),
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
          if (_isCinematicPlaying &&
              (_cinematicStep == 1 || _cinematicStep == 2))
            Positioned(
              bottom: 80,
              left: screenWidth * 0.48,
              child: Image.asset(
                'assets/images/battle/${_getWeaponId(widget.islandName)}.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) =>
                    const Icon(Icons.flash_on, color: Colors.amber, size: 50),
              ),
            ),
          AnimatedBuilder(
            animation: Listenable.merge(
                [_walkBobbingController, _satriaAttackController]),
            builder: (context, child) {
              double walkBounce = (_isCinematicPlaying && _cinematicStep < 3)
                  ? sin(_walkBobbingController.value * pi * 2).abs() * 6
                  : 0.0;
              return AnimatedPositioned(
                duration: (_isCinematicPlaying && _cinematicStep >= 2)
                    ? const Duration(milliseconds: 2500)
                    : const Duration(milliseconds: 0),
                curve: Curves.linear,
                bottom: 60 + walkBounce,
                left: _isCinematicPlaying
                    ? satriaCinematicLeft
                    : (80 + (_satriaAttackAnimation.value * attackDistance)),
                child: Container(
                  height: 140,
                  width: 140,
                  alignment: Alignment.bottomLeft,
                  child: Image.asset(
                    getSatriaSprite(),
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => Image.asset(
                        'assets/images/battle/satria_idle.png',
                        fit: BoxFit.contain),
                  ),
                ),
              );
            },
          ),
          if (_showSlashEffect)
            Positioned(
              bottom: 90,
              right: 120,
              child: Image.asset(
                'assets/images/battle/fx_slash.png',
                height: 160,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) => const SizedBox.shrink(),
              ),
            ),
          AnimatedBuilder(
            animation: _bossAttackController,
            builder: (context, child) {
              double bossRightPos = showBossInCinematic ? 50 : -300;
              if (!_isCinematicPlaying)
                bossRightPos =
                    50 + (_bossAttackAnimation.value * attackDistance);
              return Positioned(
                bottom: 60,
                right: bossRightPos,
                child: Image.asset(
                  _getDynamicBossAsset(
                      widget.islandName, _bossAttackAnimation.value),
                  height: 250,
                  errorBuilder: (ctx, err, stack) => Image.asset(
                      'assets/images/battle/boss_sang_belang.png',
                      height: 250),
                ),
              );
            },
          ),
          if (_isScreenFlashingRed)
            Positioned.fill(
                child: Container(color: Colors.red.withOpacity(0.5))),
          if (_isScreenFlashingWhite)
            Positioned.fill(
                child: Container(color: Colors.white.withOpacity(0.6))),
          if (!_isCinematicPlaying)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                // 🔥 KOTAK KIRI ATAS INI SEKARANG MENAMPILKAN JUMLAH KUNCI
                                _buildAssetBox(
                                    'assets/images/battle/ui_key_box.png',
                                    '$_localKeys',
                                    isKeyBox: true),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildCustomHPBar(
                                'SATRIA',
                                playerHP,
                                'assets/images/battle/hp_frame_player.png',
                                true),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                _buildImageButton(
                                    'assets/images/battle/btn_settings.png',
                                    () => _showSettingsDialog()),
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
          if (_isCinematicPlaying)
            Positioned(
              bottom: 30,
              left: 40,
              right: 40,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.brown[900]?.withOpacity(0.9),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _cinematicText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pressStart2p(
                      color: Colors.amber, fontSize: 11, height: 1.5),
                ),
              ),
            ),
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
          if (isQuizVisible && !isBattleOver && !isLoadingQuestions)
            _buildWoodenQuizPopup(),
          if (isBattleOver) _buildEndScreen(),
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _blackScreenOpacity,
              duration: const Duration(milliseconds: 600),
              child: Container(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetBox(String assetPath, String text,
      {bool isKeyBox = false}) {
    return Container(
      width: 105,
      height: 35,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(assetPath), fit: BoxFit.fill, onError: (e, s) {}),
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
      ),
      alignment: isKeyBox ? Alignment.centerRight : Alignment.centerLeft,
      padding: isKeyBox
          ? const EdgeInsets.only(right: 15.0)
          : const EdgeInsets.only(left: 45.0),
      child: Text(text,
          style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10)),
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
              onError: (e, s) {}),
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
                                  alignment: Alignment.topCenter),
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

  Widget _buildWoodenQuizPopup() {
    if (_questions.isEmpty) return const SizedBox.shrink();

    final question = _questions[currentQuestionIndex];
    final letters = ['[A]', '[B]', '[C]', '[D]'];

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      top: bottomInset > 0 ? -(bottomInset / 1.5) : 0,
      bottom: bottomInset > 0 ? (bottomInset / 1.5) : 0,
      left: 0,
      right: 0,
      child: Center(
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
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 95, bottom: 35, left: 40, right: 40),
                child: Column(
                  children: [
                    Text(
                      'Pertanyaan ${(currentQuestionIndex + 1)}/$totalQuestions:',
                      style: GoogleFonts.pressStart2p(
                          fontSize: 11, color: Colors.amber),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Text(
                            question.question,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.pressStart2p(
                                fontSize: 13, color: Colors.white, height: 1.4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (question.isTextInput)
                      _buildTextInputArea(question)
                    else
                      SizedBox(
                        height: 105,
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 4.0,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          children:
                              List.generate(question.options.length, (index) {
                            bool isSelected = _selectedOptionIndex == index;

                            return GestureDetector(
                              onTap: () {
                                bool isCorrect =
                                    (index == question.correctAnswer);
                                _processAnswer(isCorrect, selectedIndex: index);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                padding: EdgeInsets.all(isSelected ? 3 : 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: const AssetImage(
                                          'assets/images/battle/ui_wood_btn.png'),
                                      fit: BoxFit.fill,
                                      colorFilter: isSelected
                                          ? const ColorFilter.mode(
                                              Colors.black54, BlendMode.darken)
                                          : null,
                                    ),
                                    color: Colors.brown[600],
                                    border: Border.all(
                                        color: isSelected
                                            ? Colors.amber
                                            : Colors.brown[900]!,
                                        width: isSelected ? 3 : 2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      Text(letters[index],
                                          style: GoogleFonts.pressStart2p(
                                              fontSize: 11,
                                              color: Colors.white)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          question.options[index],
                                          style: GoogleFonts.pressStart2p(
                                              fontSize: 10,
                                              color: Colors.white),
                                          maxLines: 2,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
              if (_isLastAnswerCorrect != null)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isLastAnswerCorrect!
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _isLastAnswerCorrect!
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            size: 60,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            _isLastAnswerCorrect!
                                ? 'JAWABAN BENAR!'
                                : 'JAWABAN SALAH!',
                            style: GoogleFonts.pressStart2p(
                              color: _isLastAnswerCorrect!
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontSize: 18,
                              shadows: const [
                                Shadow(color: Colors.black, blurRadius: 5)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInputArea(QuizQuestion question) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.brown[900],
            border: Border.all(color: Colors.amber, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: _textAnswerController,
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Ketik jawaban...",
                hintStyle: GoogleFonts.pressStart2p(
                    fontSize: 10, color: Colors.white54),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            String ans = _textAnswerController.text.trim().toLowerCase();
            if (ans.isEmpty) return;

            bool isCorrect = (ans == question.textAnswer);
            _processAnswer(isCorrect);
          },
          child: Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/battle/ui_wood_btn.png'),
                fit: BoxFit.fill,
              ),
              color: Colors.brown[600],
              border: Border.all(color: Colors.brown[900]!, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text("KIRIM",
                  style: GoogleFonts.pressStart2p(
                      fontSize: 11, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEndScreen() {
    String bossName = _getBossName(widget.islandName);
    bool isWin = bossHP <= 0;

    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isWin ? '$bossName DIKALAHKAN!' : 'SATRIA ROBOH!',
                style: GoogleFonts.pressStart2p(
                    fontSize: 18, color: isWin ? Colors.green : Colors.red)),
            const SizedBox(height: 20),
            if (!isWin && _localKeys > 0) ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  side: const BorderSide(color: Colors.amber, width: 2),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                onPressed: _reviveSatria,
                // 🔥 NAMA TOMBOL SUDAH MENGGUNAKAN VARIABEL _localKeys
                child: Text('GUNAKAN KUNCI ($_localKeys)',
                    style: GoogleFonts.pressStart2p(
                        fontSize: 10, color: Colors.white)),
              ),
              const SizedBox(height: 15),
            ],
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
                side: const BorderSide(color: Colors.white, width: 2),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              onPressed: () {
                if (isWin) {
                  _proceedToNext();
                } else {
                  widget.onBattleLose();
                }
              },
              child: Text(isWin ? 'LANJUTKAN' : 'MENYERAH & KEMBALI',
                  style: GoogleFonts.pressStart2p(
                      fontSize: 10, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
