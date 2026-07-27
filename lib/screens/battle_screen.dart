import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nusantara_dash/utils/game_prefs.dart';
import 'package:nusantara_dash/utils/audio_manager.dart';
import 'package:nusantara_dash/game/features/weapons/weapon_manager.dart';

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
  int playerHP = 100;
  int bossHP = 100;
  int currentQuestionIndex = 0;
  int countdown = 3;
  bool isCountingDown = true;
  bool isQuizVisible = false;
  bool isAnswering = false;
  bool isBattleOver = false;

  late List<QuizQuestion> _questions;

  @override
  void initState() {
    super.initState();
    // ✅ 1. AMBIL SOAL KUIS KHUSUS SESUAI PULAU YANG DIMAINKAN
    _questions = _getQuestionsByIsland(widget.islandName);
    _startCountdown();
  }

  // =========================================================================
  // 🧠 2. DATABASE SOAL KUIS DINAMIS KHUSUS KMIPN (EDUTAINMENT)
  // =========================================================================
  List<QuizQuestion> _getQuestionsByIsland(String island) {
    switch (island.toUpperCase()) {
      case 'JAWA':
        return [
          QuizQuestion(
            question:
                'Candi Budha terbesar di dunia yang terletak di Magelang, Jawa Tengah adalah?',
            options: [
              'Candi Borobudur',
              'Candi Prambanan',
              'Candi Mendut',
              'Candi Singosari'
            ],
            correctAnswer: 0,
          ),
          QuizQuestion(
            question:
                'Apa nama senjata tradisional khas masyarakat Jawa berlekuk yang diakui UNESCO?',
            options: ['Keris', 'Kujang', 'Celurit', 'Badik'],
            correctAnswer: 0,
          ),
          QuizQuestion(
            question:
                'Seni pertunjukan boneka kulit/kayu tradisional Jawa disebut?',
            options: ['Wayang Kulit', 'Ludruk', 'Lenong', 'Ketoprak'],
            correctAnswer: 0,
          ),
          QuizQuestion(
            question:
                'Alat musik pukul tradisional Jawa yang terbuat dari perunggu/besi adalah?',
            options: ['Gamelan', 'Angklung', 'Kolintang', 'Sasando'],
            correctAnswer: 0,
          ),
          QuizQuestion(
            question: 'Apa nama pakaian adat resmi pria Jawa Tengah?',
            options: ['Beskap & Blangkon', 'Baju Kurung', 'Ulos', 'Baju Bodo'],
            correctAnswer: 0,
          ),
        ];
      case 'KALIMANTAN':
        return [
          QuizQuestion(
            question:
                'Suku asli yang mendiami pedalaman pulau Kalimantan adalah suku?',
            options: ['Suku Dayak', 'Suku Asmat', 'Suku Bugis', 'Suku Minang'],
            correctAnswer: 0,
          ),
          QuizQuestion(
            question: 'Apa nama senjata tajam tradisional khas suku Dayak?',
            options: ['Mandau', 'Rencong', 'Badik', 'Keris'],
            correctAnswer: 0,
          ),
          QuizQuestion(
            question: 'Rumah adat panjang suku Dayak di Kalimantan disebut?',
            options: ['Rumah Betang', 'Rumah Gadang', 'Honai', 'Tongkonan'],
            correctAnswer: 0,
          ),
          QuizQuestion(
            question:
                'Hewan endemik Kalimantan yang terancam punah dan berbulu kemerahan adalah?',
            options: ['Orangutan', 'Komodo', 'Anoa', 'Harimau'],
            correctAnswer: 0,
          ),
          QuizQuestion(
            question:
                'Pasar tradisional unik di Banjarmasin yang bertransaksi di atas perahu disebut?',
            options: [
              'Pasar Terapung',
              'Pasar Beringharjo',
              'Pasar Triwindu',
              'Pasar Senen'
            ],
            correctAnswer: 0,
          ),
        ];
      case 'SULAWESI':
        return [
          QuizQuestion(
            question:
                'Perahu layar tradisional khas suku Bugis-Makassar yang terkenal tangguh adalah?',
            options: [
              'Perahu Phinisi',
              'Perahu Jukung',
              'Perahu Kora-kora',
              'Perahu Biduk'
            ],
            correctAnswer: 0,
          ),
          QuizQuestion(
            question:
                'Rumah adat suku Toraja dengan atap melengkung menyerupai perahu disebut?',
            options: ['Tongkonan', 'Baileo', 'Honai', 'Rumah Lamin'],
            correctAnswer: 0,
          ),
          QuizQuestion(
            question:
                'Apa nama senjata tradisional khas suku Bugis dan Makassar?',
            options: ['Badik', 'Mandau', 'Kujang', 'Siwar'],
            correctAnswer: 0,
          ),
          QuizQuestion(
            question:
                'Taman Nasional di Sulawesi Utara yang terkenal dengan keindahan terumbu karangnya?',
            options: ['Bunaken', 'Wakatobi', 'Raja Ampat', 'Baluran'],
            correctAnswer: 0,
          ),
          QuizQuestion(
            question:
                'Hewan endemik Sulawesi yang menyerupai gabungan babi dan rusa adalah?',
            options: ['Babirusa', 'Anoa', 'Tapir', 'Kuskus'],
            correctAnswer: 0,
          ),
        ];
      case 'PAPUA':
        return [
          QuizQuestion(
            question:
                'Rumah adat tradisional Papua yang berbentuk kerucut dan beratap jerami adalah?',
            options: ['Honai', 'Kariwari', 'Modaki', 'Lamin'],
            correctAnswer: 0,
          ),
          QuizQuestion(
            question:
                'Burung endemik Papua yang dijuluki sebagai "Bird of Paradise" adalah?',
            options: ['Cendrawasih', 'Jalak Bali', 'Maleo', 'Kakak Tua'],
            correctAnswer: 0,
          ),
          QuizQuestion(
            question:
                'Alat musik pukul tradisional khas Papua yang berbentuk seperti gendang adalah?',
            options: ['Tifa', 'Tifa Totobuang', 'Gendang Melayu', 'Rebana'],
            correctAnswer: 0,
          ),
          QuizQuestion(
            question:
                'Senjata tradisional Papua yang digunakan untuk berburu adalah?',
            options: ['Busur & Anak Panah', 'Sumpit', 'Tombak', 'Golok'],
            correctAnswer: 0,
          ),
          QuizQuestion(
            question:
                'Puncak tertinggi di Indonesia yang terletak di pegunungan Jayawijaya Papua adalah?',
            options: [
              'Puncak Jaya (Carstensz)',
              'Gunung Kerinci',
              'Gunung Rinjani',
              'Gunung Semeru'
            ],
            correctAnswer: 0,
          ),
        ];
      default: // SUMATRA
        return [
          QuizQuestion(
            question:
                'Apa nama rumah adat Minangkabau yang memiliki atap melengkung seperti tanduk kerbau?',
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
                'Apa nama tarian tradisional Minangkabau yang menggunakan piring sebagai properti?',
            options: [
              'Tari Piring',
              'Tari Payung',
              'Tari Randai',
              'Tari Kecak'
            ],
            correctAnswer: 0,
          ),
        ];
    }
  }

  // =========================================================================
  // 🗡️ 3. HELPER SENJATA DINAMIS PER PULAU
  // =========================================================================
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
        return '🏹 Busur Kasuari';
      default:
        return '🗡️ Rencong Suci';
    }
  }
  // =========================================================================

  void _startCountdown() {
    if (isBattleOver) return;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown <= 0) {
        timer.cancel();
        if (mounted) {
          setState(() {
            isCountingDown = false;
            isQuizVisible = true;
            AudioManager.instance.playSFX('sfx_question.mp3');
          });
        }
      } else {
        if (mounted) setState(() => countdown--);
      }
    });
  }

  void _handleAnswer(int selectedOption) {
    if (isAnswering || isBattleOver) return;

    setState(() => isAnswering = true);

    final correct =
        (selectedOption == _questions[currentQuestionIndex].correctAnswer);

    if (correct) {
      setState(() => bossHP = bossHP > 0 ? bossHP - 20 : 0);
      AudioManager.instance.playSFX('sfx_boss_hit.mp3');

      if (bossHP <= 0) {
        _battleWin();
        return;
      }
    } else {
      setState(() => playerHP = playerHP > 0 ? playerHP - 15 : 0);
      AudioManager.instance.playSFX('sfx_hit_flesh.mp3');

      if (playerHP <= 0) {
        _battleLose();
        return;
      }
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (currentQuestionIndex < _questions.length - 1) {
        if (mounted) {
          setState(() {
            currentQuestionIndex++;
            isQuizVisible = false;
            isAnswering = false;
          });
          _startCountdown();
        }
      } else {
        _battleWin();
      }
    });
  }

  // 🔥 VERSI FINAL: Hapus auto-timer, biarkan pemain baca & klik tombol "Lanjutkan"!
  void _battleWin() {
    setState(() {
      isBattleOver = true;
      AudioManager.instance.playSFX('sfx_victory_fanfare.mp3');
    });
    // ❌ Future.delayed DIHAPUS agar layar tidak tertutup otomatis!
  }

  // 🔥 VERSI FINAL: Hapus auto-timer, biarkan pemain memilih tombol saat kalah!
  void _battleLose() {
    setState(() {
      isBattleOver = true;
      AudioManager.instance.playSFX('sfx_gameover.mp3');
    });
    // ❌ Future.delayed DIHAPUS agar pemain bisa menekan "Kembali ke Checkpoint"!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Stack(
        children: [
          Container(color: const Color(0xFF1A237E)),
          _buildHPBars(),
          if (isCountingDown && !isBattleOver) _buildCountdown(),
          if (isQuizVisible && !isBattleOver) _buildQuizPopup(),
          if (isBattleOver) _buildBattleOverScreen(),
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
          '$hp% $label',
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
              style: GoogleFonts.pressStart2p(
                  fontSize: 14, color: Colors.amber, height: 1.5),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        onPressed: isAnswering
            ? null
            : () => _handleAnswer(
                _questions[currentQuestionIndex].options.indexOf(option)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          side: const BorderSide(color: Color(0xFFFFB300), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Text(
          option,
          style: GoogleFonts.pressStart2p(fontSize: 12),
          textAlign: TextAlign.center,
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
            border: Border.all(color: const Color(0xFFFFB300), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Kuis Selesai!',
                style:
                    GoogleFonts.pressStart2p(fontSize: 24, color: Colors.amber),
              ),
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
                  onPressed: () => _proceedToNext(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                  ),
                  child: Text(
                    'Lanjutkan ke Peta',
                    style: GoogleFonts.pressStart2p(fontSize: 14),
                  ),
                ),
              if (playerHP <= 0)
                Column(
                  children: [
                    Text(
                      'Kamu kehilangan nyawa. Ingin mencoba lagi?',
                      style: GoogleFonts.pressStart2p(
                          fontSize: 12, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    if (widget.currentLives > 0)
                      ElevatedButton(
                        onPressed: () => _useKey(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        child: Text(
                          'Gunakan Kunci (x${widget.currentLives})',
                          style: GoogleFonts.pressStart2p(fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      // 🔥 KOREKSI FINISHING: Memanggil onBattleLose agar kembali ke checkpoint & reset sensor bos!
                      onPressed: () => widget.onBattleLose(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: Text(
                        'Kembali ke Checkpoint',
                        style: GoogleFonts.pressStart2p(fontSize: 12),
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
      widget.onExit();
    }
  }

  void _proceedToNext() async {
    await GamePrefs.markBossDefeated(widget.islandName);
    await GamePrefs.unlockNextIsland(widget.islandName);
    WeaponManager.addWeapon(_getWeaponId(widget.islandName));
    if (mounted) widget.onBattleWin();
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
