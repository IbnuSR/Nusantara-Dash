import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nusantara_dash/utils/game_prefs.dart';
import 'package:nusantara_dash/utils/audio_manager.dart';

enum QuestionType {
  singleChoice,
  multipleChoice,
  essay,
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final List<int> correctAnswers;
  final QuestionType type;
  final String? essayAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswers,
    this.type = QuestionType.singleChoice,
    this.essayAnswer,
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
  int correctAnswersCount = 0;
  final int targetCorrectAnswers = 5;

  int _keysUsedInSession = 0;
  int currentQuestionIndex = 0;

  int countdown = 3;
  bool isCountingDown = true;
  bool isQuizVisible = true;
  bool isAnswering = false;
  bool isBattleOver = false;

  late AnimationController _satriaAttackController;
  late AnimationController _bossAttackController;
  late Animation<double> _satriaAttackAnimation;
  late Animation<double> _bossAttackAnimation;

  bool _isSatriaAttacking = false;
  bool _isBossAttacking = false;

  final TextEditingController _essayController = TextEditingController();
  List<int> _selectedOptions = [];

  late List<QuizQuestion> _questions;

  @override
  void initState() {
    super.initState();

    _satriaAttackController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bossAttackController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _satriaAttackAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _satriaAttackController, curve: Curves.easeOut),
    );
    _bossAttackAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bossAttackController, curve: Curves.easeOut),
    );

    _initializeBattle();
  }

  @override
  void dispose() {
    _satriaAttackController.dispose();
    _bossAttackController.dispose();
    _essayController.dispose();
    super.dispose();
  }

  void _initializeBattle() {
    _questions = _getQuestionsByIsland(widget.islandName);
    _questions.shuffle(Random());

    setState(() {
      playerHP = 100;
      bossHP = 100;
      correctAnswersCount = 0;
      _keysUsedInSession = 0;
      currentQuestionIndex = 0;
      countdown = 3;
      isCountingDown = true;
      isQuizVisible = true;
      isAnswering = false;
      isBattleOver = false;
      _isSatriaAttacking = false;
      _isBossAttacking = false;
      _selectedOptions.clear();
    });

    _startCountdown();
  }

  List<QuizQuestion> _getQuestionsByIsland(String island) {
    switch (island.toUpperCase()) {
      case 'JAWA':
        return [
          QuizQuestion(
            question:
                'Candi Budha terbesar di dunia yang terletak di Magelang adalah?',
            options: ['Candi Borobudur', 'Candi Prambanan', 'Candi Mendut'],
            correctAnswers: [0],
            type: QuestionType.singleChoice,
          ),
          QuizQuestion(
            question:
                'Manakah yang termasuk senjata tradisional Jawa? (Pilih 2)',
            options: ['Keris', 'Mandau', 'Kujang', 'Rencong'],
            correctAnswers: [0, 2],
            type: QuestionType.multipleChoice,
          ),
          QuizQuestion(
            question: 'Sebutkan nama tarian tradisional Jawa yang terkenal!',
            options: [],
            correctAnswers: [],
            type: QuestionType.essay,
            essayAnswer: 'wayang',
          ),
        ];

      case 'KALIMANTAN':
        return [
          QuizQuestion(
            question: 'Suku asli yang mendiami pedalaman Kalimantan adalah?',
            options: ['Suku Dayak', 'Suku Asmat', 'Suku Bugis'],
            correctAnswers: [0],
            type: QuestionType.singleChoice,
          ),
          QuizQuestion(
            question: 'Manakah yang termasuk rumah adat Kalimantan? (Pilih 2)',
            options: ['Rumah Betang', 'Rumah Gadang', 'Honai', 'Rumah Lamin'],
            correctAnswers: [0, 3],
            type: QuestionType.multipleChoice,
          ),
        ];

      case 'SULAWESI':
        return [
          QuizQuestion(
            question: 'Perahu layar tradisional khas Bugis-Makassar adalah?',
            options: ['Perahu Phinisi', 'Perahu Jukung', 'Perahu Biduk'],
            correctAnswers: [0],
            type: QuestionType.singleChoice,
          ),
        ];

      case 'PAPUA':
        return [
          QuizQuestion(
            question: 'Rumah adat Papua yang berbentuk kerucut adalah?',
            options: ['Honai', 'Kariwari', 'Lamin'],
            correctAnswers: [0],
            type: QuestionType.singleChoice,
          ),
        ];

      default:
        return [
          QuizQuestion(
            question:
                'Rumah adat Minangkabau yang memiliki atap melengkung adalah?',
            options: ['Rumah Gadang', 'Joglo', 'Rumah Betang'],
            correctAnswers: [0],
            type: QuestionType.singleChoice,
          ),
          QuizQuestion(
            question:
                'Manakah yang termasuk senjata tradisional Sumatra? (Pilih 2)',
            options: ['Rencong', 'Mandau', 'Badik', 'Keris'],
            correctAnswers: [0, 2],
            type: QuestionType.multipleChoice,
          ),
          QuizQuestion(
            question: 'Sebutkan nama danau vulkanik terbesar di Sumatra!',
            options: [],
            correctAnswers: [],
            type: QuestionType.essay,
            essayAnswer: 'toba',
          ),
        ];
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

  String _getWeaponName(String island) {
    switch (island.toUpperCase()) {
      case 'JAWA':
        return '🗡️ Keris Pusaka';
      case 'KALIMANTAN':
        return '🗡️ Mandau Sakti';
      case 'SULAWESI':
        return '🗡️ Badik Keramat';
      case 'PAPUA':
        return ' Busur Kasuari';
      default:
        return '🗡️ Rencong Suci';
    }
  }

  void _startCountdown() {
    if (isBattleOver) return;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown <= 0) {
        timer.cancel();
        if (mounted) {
          setState(() {
            isCountingDown = false;
          });
        }
      } else {
        if (mounted) setState(() => countdown--);
      }
    });
  }

  void _checkAnswer() {
    if (isAnswering || isBattleOver) return;
    setState(() => isAnswering = true);

    final currentQ = _questions[currentQuestionIndex];
    bool isCorrect = false;

    if (currentQ.type == QuestionType.singleChoice) {
      isCorrect = _selectedOptions.isNotEmpty &&
          _selectedOptions[0] == currentQ.correctAnswers[0];
    } else if (currentQ.type == QuestionType.multipleChoice) {
      _selectedOptions.sort();
      List<int> sortedCorrect = List.from(currentQ.correctAnswers)..sort();
      isCorrect = _selectedOptions.toString() == sortedCorrect.toString();
    } else if (currentQ.type == QuestionType.essay) {
      String userAnswer = _essayController.text.toLowerCase().trim();
      String correctAnswer = (currentQ.essayAnswer ?? '').toLowerCase();
      isCorrect = userAnswer.contains(correctAnswer) ||
          correctAnswer.contains(userAnswer);
    }

    setState(() {
      isQuizVisible = false;
      _selectedOptions.clear();
      _essayController.clear();
    });

    if (isCorrect) {
      AudioManager.instance.playSFX('sfx_boss_hit.mp3');
      _performSatriaAttack();
    } else {
      AudioManager.instance.playSFX('sfx_hit_flesh.mp3');
      _performBossAttack();
    }
  }

  void _performSatriaAttack() async {
    setState(() {
      _isSatriaAttacking = true;
    });

    _satriaAttackController.forward().then((_) {
      setState(() {
        correctAnswersCount++;
        bossHP = (100 - (correctAnswersCount * 20)).clamp(0, 100);
        _isSatriaAttacking = false;
      });

      _satriaAttackController.reset();

      if (correctAnswersCount >= targetCorrectAnswers) {
        _battleWin();
      } else {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !isBattleOver) {
            setState(() {
              currentQuestionIndex++;
              if (currentQuestionIndex >= _questions.length) {
                _questions.shuffle(Random());
                currentQuestionIndex = 0;
              }
              isQuizVisible = true;
              isAnswering = false;
            });
          }
        });
      }
    });
  }

  void _performBossAttack() async {
    setState(() {
      _isBossAttacking = true;
    });

    _bossAttackController.forward().then((_) {
      setState(() {
        playerHP = (playerHP - 25).clamp(0, 100);
        _isBossAttacking = false;
      });

      _bossAttackController.reset();

      if (playerHP <= 0) {
        _showDeathDialog();
      } else {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !isBattleOver) {
            setState(() {
              currentQuestionIndex++;
              if (currentQuestionIndex >= _questions.length) {
                _questions.shuffle(Random());
                currentQuestionIndex = 0;
              }
              isQuizVisible = true;
              isAnswering = false;
            });
          }
        });
      }
    });
  }

  void _battleWin() {
    setState(() => isBattleOver = true);
    AudioManager.instance.playSFX('sfx_victory_fanfare.mp3');
  }

  void _showDeathDialog() {
    setState(() => isBattleOver = true);
    AudioManager.instance.playSFX('sfx_gameover.mp3');

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
              Text('💀 SATRIA ROBOH!',
                  style: GoogleFonts.pressStart2p(
                      color: Colors.red, fontSize: 16)),
              const SizedBox(height: 15),
              Text('Kunci Terpakai: $_keysUsedInSession / 3',
                  style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (widget.currentLives > 0 && _keysUsedInSession < 3) ...[
                const Text('Gunakan 1 Kunci untuk memulihkan 50% HP!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white)),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _useKeyAndContinue();
                  },
                  icon: const Icon(Icons.vpn_key),
                  label: const Text('PAKAI KUNCI (+50% HP)'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 40)),
                ),
                const SizedBox(height: 10),
              ] else ...[
                Text(
                  _keysUsedInSession >= 3
                      ? 'Batas penggunaan Kunci (3x) tercapai!'
                      : 'Nyawa cadangan habis!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
              ],
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _initializeBattle();
                },
                icon: const Icon(Icons.replay),
                label: const Text('ULANG KUIS DARI AWAL'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40)),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onExit();
                },
                child: const Text('MENYERAH & KELUAR',
                    style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _useKeyAndContinue() async {
    await GamePrefs.useExtraLife();

    setState(() {
      _keysUsedInSession++;
      playerHP = (playerHP + 50).clamp(0, 100);
      isBattleOver = false;
      isAnswering = false;

      currentQuestionIndex++;
      if (currentQuestionIndex >= _questions.length) {
        _questions.shuffle(Random());
        currentQuestionIndex = 0;
      }
      isQuizVisible = true;
    });
  }

  void _proceedToNext() async {
    await GamePrefs.markBossDefeated(widget.islandName);

    if (widget.islandName.toUpperCase() == 'SUMATRA') {
      await GamePrefs.unlockIsland('JAWA');
      print('🔓 PULAU JAWA TELAH DIBUKA!');
    } else if (widget.islandName.toUpperCase() == 'JAWA') {
      await GamePrefs.unlockIsland('KALIMANTAN');
      print('🔓 PULAU KALIMANTAN TELAH DIBUKA!');
    }

    await GamePrefs.unlockWeapon(_getWeaponId(widget.islandName));
    await GamePrefs.addCoins(500);

    if (mounted) {
      widget.onBattleWin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Stack(
        children: [
          Container(color: const Color(0xFF1A237E)),
          _buildBattleArena(),
          if (isCountingDown && !isBattleOver) _buildCountdown(),
          if (isQuizVisible && !isBattleOver) _buildQuizPopup(),
          if (isBattleOver) _buildBattleOverScreen(),
          _buildLivesIndicator(),
        ],
      ),
    );
  }

  Widget _buildBattleArena() {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('SATRIA',
                          style: GoogleFonts.pressStart2p(
                              color: Colors.greenAccent, fontSize: 12)),
                      const SizedBox(height: 5),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                              height: 24,
                              decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12))),
                          FractionallySizedBox(
                            widthFactor: playerHP / 100,
                            child: Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: playerHP > 50
                                    ? Colors.green
                                    : (playerHP > 25
                                        ? Colors.orange
                                        : Colors.red),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text('$playerHP%',
                          style: GoogleFonts.pressStart2p(
                              color: Colors.white, fontSize: 10)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      Text('BOSS',
                          style: GoogleFonts.pressStart2p(
                              color: Colors.red, fontSize: 12)),
                      const SizedBox(height: 5),
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Container(
                              height: 24,
                              decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12))),
                          FractionallySizedBox(
                            widthFactor: bossHP / 100,
                            child: Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text('$bossHP%',
                          style: GoogleFonts.pressStart2p(
                              color: Colors.white, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnimatedBuilder(
                animation: _satriaAttackAnimation,
                builder: (context, child) {
                  double attackOffset = _satriaAttackAnimation.value * 50;
                  return Transform.translate(
                    offset: Offset(attackOffset, 0),
                    child: _buildCharacter(
                        'SATRIA', Colors.greenAccent, _isSatriaAttacking),
                  );
                },
              ),
              Text('VS',
                  style: GoogleFonts.pressStart2p(
                      color: Colors.amber, fontSize: 24)),
              AnimatedBuilder(
                animation: _bossAttackAnimation,
                builder: (context, child) {
                  double attackOffset = -(_bossAttackAnimation.value * 50);
                  return Transform.translate(
                    offset: Offset(attackOffset, 0),
                    child:
                        _buildCharacter('BOSS', Colors.red, _isBossAttacking),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
              'Target: $correctAnswersCount / $targetCorrectAnswers Jawaban Benar',
              style:
                  GoogleFonts.pressStart2p(color: Colors.amber, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildCharacter(String name, Color color, bool isAttacking) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 3),
          ),
          child: Icon(
            isAttacking ? Icons.gavel : Icons.person,
            color: color,
            size: 50,
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: GoogleFonts.pressStart2p(color: color, fontSize: 10)),
      ],
    );
  }

  Widget _buildCountdown() {
    return Positioned.fill(
      child: Center(
        child: Text('$countdown',
            style: GoogleFonts.pressStart2p(
                fontSize: 120,
                color: Colors.amber,
                shadows: const [Shadow(color: Colors.black, blurRadius: 10)])),
      ),
    );
  }

  Widget _buildQuizPopup() {
    if (currentQuestionIndex >= _questions.length) {
      return const SizedBox.shrink();
    }

    final question = _questions[currentQuestionIndex];

    return Positioned(
      top: 250,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFF1B2845),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFB300), width: 2)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(question.question,
                style: GoogleFonts.pressStart2p(
                    fontSize: 12, color: Colors.amber, height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            if (question.type == QuestionType.essay)
              TextField(
                controller: _essayController,
                style:
                    GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ketik jawabanmu...',
                  hintStyle: GoogleFonts.pressStart2p(
                      fontSize: 10, color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1A237E),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            if (question.type != QuestionType.essay)
              ...question.options.asMap().entries.map((entry) {
                int idx = entry.key;
                String opt = entry.value;
                bool isSelected = _selectedOptions.contains(idx);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: isAnswering
                        ? null
                        : () {
                            setState(() {
                              if (question.type ==
                                  QuestionType.multipleChoice) {
                                if (isSelected) {
                                  _selectedOptions.remove(idx);
                                } else {
                                  _selectedOptions.add(idx);
                                }
                              } else {
                                _selectedOptions = [idx];
                              }
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? Colors.amber : const Color(0xFF1A237E),
                      foregroundColor: isSelected ? Colors.black : Colors.amber,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 10),
                      side: BorderSide(
                          color: isSelected
                              ? Colors.amber
                              : const Color(0xFFFFB300),
                          width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        if (question.type == QuestionType.multipleChoice)
                          Icon(
                              isSelected
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 16),
                        if (question.type == QuestionType.multipleChoice)
                          const SizedBox(width: 8),
                        Expanded(
                            child: Text(opt,
                                style: GoogleFonts.pressStart2p(fontSize: 10),
                                textAlign: TextAlign.center)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isAnswering ||
                      (_selectedOptions.isEmpty &&
                          question.type != QuestionType.essay)
                  ? null
                  : _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child:
                  Text('JAWAB', style: GoogleFonts.pressStart2p(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattleOverScreen() {
    return Positioned.fill(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: const Color(0xFF1B2845),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFB300), width: 2)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Kuis Selesai!',
                  style: GoogleFonts.pressStart2p(
                      fontSize: 24, color: Colors.amber)),
              const SizedBox(height: 20),
              Text(
                bossHP <= 0
                    ? 'Selamat! Kamu mengalahkan Mini Boss ${widget.islandName}!\n\nMendapatkan:\n${_getWeaponName(widget.islandName)}\n🪙 +500 Koin'
                    : 'Sayang sekali, kamu kalah!',
                style: GoogleFonts.pressStart2p(
                    fontSize: 12, color: Colors.white, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              if (bossHP <= 0)
                ElevatedButton(
                  onPressed: _proceedToNext,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 20)),
                  child: Text('Lanjutkan ke Peta',
                      style: GoogleFonts.pressStart2p(fontSize: 14)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLivesIndicator() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Text('❤️ ${widget.currentLives}',
            style: GoogleFonts.pressStart2p(fontSize: 24, color: Colors.red)),
      ),
    );
  }
}
