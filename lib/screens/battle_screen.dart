import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nusantara_dash/utils/game_prefs.dart';
import 'package:nusantara_dash/utils/audio_manager.dart';
import 'package:nusantara_dash/game/features/weapons/weapon_manager.dart';
import 'package:nusantara_dash/game/data/sumatra_level_data.dart';

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

class _BattleScreenState extends State<BattleScreen> {
  // ✅ STATE BATTLE
  int playerHP = 100; // Dalam persen
  int bossHP = 100;
  int currentQuestionIndex = 0;
  int countdown = 3;
  bool isCountingDown = true;
  bool isQuizVisible = false;
  bool isAnswering = false;
  bool isBattleOver = false;

  // ✅ DATA KUIS (Diambil dari database budaya)
  final List<QuizQuestion> _questions = [
    QuizQuestion(
      question:
          'Apa nama rumah adat Minangkabau yang memiliki atap melengkung?',
      options: ['Rumah Gadang', 'Joglo', 'Rumah Betang', 'Rumah Gondang'],
      correctAnswer: 0,
    ),
    QuizQuestion(
      question:
          'Apa nama senjata tradisional Aceh yang bentuknya seperti huruf Bismillah?',
      options: ['Rencong', 'Keris', 'Golok', 'Pedang'],
      correctAnswer: 0,
    ),
    QuizQuestion(
      question:
          'Danau Toba di Sumatra Utara merupakan danau vulkanik terbesar di dunia. Apa asal letusannya?',
      options: [
        'Letusan supervolcano',
        'Letusan gunung berapi biasa',
        'Gempa bumi',
        'Tsunami'
      ],
      correctAnswer: 0,
    ),
    QuizQuestion(
      question: 'Apa nama pakaian adat wanita Minangkabau yang terkenal?',
      options: ['Baju Kurung', 'Kebaya', 'Baju Melayu', 'Baju Rantai'],
      correctAnswer: 0,
    ),
    QuizQuestion(
      question:
          'Apa nama tarian tradisional Minangkabau yang menggunakan payung?',
      options: ['Tari Piring', 'Tari Payung', 'Tari Randai', 'Tari Kecak'],
      correctAnswer: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    if (isBattleOver) return;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown <= 0) {
        timer.cancel();
        setState(() {
          isCountingDown = false;
          isQuizVisible = true;
          AudioManager.instance.playSFX('sfx_question.mp3');
        });
      } else {
        setState(() => countdown--);
      }
    });
  }

  void _handleAnswer(int selectedOption) {
    if (isAnswering || isBattleOver) return;

    setState(() => isAnswering = true);

    final correct =
        (selectedOption == _questions[currentQuestionIndex].correctAnswer);

    // ✅ LOGIKA HP
    if (correct) {
      // ✅ Benar: Boss kena damage
      setState(() => bossHP = bossHP > 0 ? bossHP - 20 : 0);
      AudioManager.instance.playSFX('sfx_boss_hit.mp3');

      // ✅ Cek kemenangan
      if (bossHP <= 0) {
        _battleWin();
        return;
      }
    } else {
      // ❌ Salah: Player kena damage
      setState(() => playerHP = playerHP > 0 ? playerHP - 15 : 0);
      AudioManager.instance.playSFX('sfx_hit_flesh.mp3');

      // ✅ Cek kekalahan
      if (playerHP <= 0) {
        _battleLose();
        return;
      }
    }

    // ✅ Lanjut ke pertanyaan berikutnya
    Future.delayed(const Duration(seconds: 1), () {
      if (currentQuestionIndex < _questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          isQuizVisible = false;
          isAnswering = false;
        });
        _startCountdown();
      } else {
        _battleWin(); // Jika semua pertanyaan selesai, menang
      }
    });
  }

  void _battleWin() {
    setState(() {
      isBattleOver = true;
      AudioManager.instance.playSFX('sfx_victory_fanfare.mp3');
    });

    // ✅ Simpan progress: Boss dikalahkan, dapat senjata suci
    Future.delayed(const Duration(seconds: 2), () {
      // Simpan progress di GamePrefs
      GamePrefs.markBossDefeated(widget.islandName);
      WeaponManager.addWeapon('rencong_sumatra');
      GamePrefs.addCoins(500);
      widget.onBattleWin();
    });
  }

  void _battleLose() {
    setState(() {
      isBattleOver = true;
      AudioManager.instance.playSFX('sfx_gameover.mp3');
    });

    // ✅ Tampilkan opsi: Gunakan kunci / Exit / Coba lagi
    Future.delayed(const Duration(seconds: 2), () {
      widget.onBattleLose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Stack(
        children: [
          // ✅ BACKGROUND (Bisa ganti dengan gambar boss)
          Container(color: const Color(0xFF1A237E)),

          // ✅ HP BARS
          _buildHPBars(),

          // ✅ COUNTDOWN
          if (isCountingDown && !isBattleOver) _buildCountdown(),

          // ✅ QUIZ POPUP
          if (isQuizVisible && !isBattleOver) _buildQuizPopup(),

          // ✅ BATTLE OVER SCREEN
          if (isBattleOver) _buildBattleOverScreen(),

          // ✅ INDIKATOR NYAWA
          _buildLivesIndicator(),
        ],
      ),
    );
  }

  Widget _buildHPBars() {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Boss HP
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Boss: ',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Expanded(
                  child: _buildHPBar(
                    hp: bossHP,
                    color: Colors.red,
                    label: 'Boss',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Player HP
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Satria: ',
                    style: GoogleFonts.pressStart2p(
                        color: Colors.amber, fontSize: 16)),
                Expanded(
                  child: _buildHPBar(
                    hp: playerHP,
                    color: Colors.green,
                    label: 'Satria',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHPBar(
      {required int hp, required Color color, required String label}) {
    return Column(
      children: [
        Text(
          '${hp}% $label',
          style: const TextStyle(color: Colors.white, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 20,
          child: LinearProgressIndicator(
            value: hp / 100,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildCountdown() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          '$countdown',
          style: GoogleFonts.pressStart2p(
            fontSize: 100,
            color: Colors.amber,
            shadows: const [
              Shadow(color: Colors.black, blurRadius: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizPopup() {
    final question = _questions[currentQuestionIndex];

    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2845),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFB300), width: 2),
        ),
        child: Column(
          children: [
            Text(
              question.question,
              style:
                  GoogleFonts.pressStart2p(fontSize: 16, color: Colors.amber),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ...question.options.map((option) => _buildOptionButton(option)),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option) {
    return ElevatedButton(
      onPressed: isAnswering
          ? null
          : () => _handleAnswer(
              _questions[currentQuestionIndex].options.indexOf(option)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.amber,
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: Color(0xFFFFB300), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        option,
        style: GoogleFonts.pressStart2p(fontSize: 16),
      ),
    );
  }

  Widget _buildBattleOverScreen() {
    return Positioned.fill(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2845),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFB300), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Kuis Selesai!',
                style:
                    GoogleFonts.pressStart2p(fontSize: 32, color: Colors.amber),
              ),
              const SizedBox(height: 20),
              Text(
                bossHP <= 0
                    ? 'Selamat! Kamu mengalahkan Mini Boss Sumatra!'
                    : 'Sayang sekali, kamu kalah!',
                style:
                    GoogleFonts.pressStart2p(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              if (bossHP <= 0)
                ElevatedButton(
                  onPressed: () => _proceedToNext(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                  ),
                  child: Text(
                    'Lanjutkan',
                    style: GoogleFonts.pressStart2p(fontSize: 16),
                  ),
                ),
              if (playerHP <= 0)
                Column(
                  children: [
                    Text(
                      'Kamu kehilangan nyawa. Ingin mencoba lagi?',
                      style: GoogleFonts.pressStart2p(
                          fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _useKey(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                      ),
                      child: Text(
                        'Gunakan Kunci (x${widget.currentLives})',
                        style: GoogleFonts.pressStart2p(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => widget.onExit(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                      ),
                      child: Text(
                        'Keluar ke Menu Utama',
                        style: GoogleFonts.pressStart2p(fontSize: 16),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _useKey() {
    if (widget.currentLives > 0) {
      // Gunakan kunci, reset HP
      GamePrefs.useExtraLife();
      setState(() {
        playerHP = 100;
        isBattleOver = false;
        currentQuestionIndex = 0;
        isQuizVisible = false;
        isCountingDown = true;
        countdown = 3;
      });
      _startCountdown();
    } else {
      // Tidak ada kunci, keluar
      widget.onExit();
    }
  }

  void _proceedToNext() {
    // Simpan progress di GamePrefs
    GamePrefs.markBossDefeated(widget.islandName);
    widget.onBattleWin();
  }

  Widget _buildLivesIndicator() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          '❤️ ${widget.currentLives}',
          style: GoogleFonts.pressStart2p(fontSize: 24, color: Colors.red),
        ),
      ),
    );
  }
}

// ✅ DATA KUIS
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
