import 'dart:ui';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/input.dart';

import 'components/player/player.dart';
import 'components/level_builder.dart';
import 'components/controllers/analog_controller.dart';
import 'components/controllers/arrow_controller.dart';

// ✅ 1. IMPORT SEMUA DATA LEVEL PULAU
import 'data/sumatra_level_data.dart';
import 'data/jawa_level_data.dart';
import 'data/kalimantan_level_data.dart';
import 'data/sulawesi_level_data.dart';
import 'data/papua_level_data.dart';

import 'package:nusantara_dash/utils/game_prefs.dart';
import 'package:nusantara_dash/utils/audio_manager.dart';
import 'package:nusantara_dash/game/data/museum_item_model.dart';
// 🏛️ SPRINT 6.4: Museum integration via bridge
import 'package:nusantara_dash/game/managers/museum_gameplay_bridge.dart';

class NusantaraDashGame extends FlameGame
    with KeyboardEvents, HasCollisionDetection {
  final String islandName;
  final VoidCallback onGameOver;
  final VoidCallback onLevelComplete;
  final Function(int) onCoinsUpdated;
  final VoidCallback onBossEncounter;
  final VoidCallback onPlayerDied; // ✅ WAJIB ADA
  final void Function(CulturalItem item)? onCulturalItemUnlocked; // 🏛️ SPRINT 6.5

  late Player player;
  late double groundY;

  int collectedCoins = 0;
  int totalWalletCoins = 0;
  int currentLives = 3;
  late TextComponent coinText;
  TextComponent? livesText;
  bool isLevelFinished = false;
  bool _hasEnteredBossZone = false;
  bool _hasDefeatedBoss = false;

  static const double virtualWidth = 1280;
  static const double virtualHeight = 720;
  static const double cameraZoom = 1.35;

  NusantaraDashGame({
    required this.islandName,
    required this.onGameOver,
    required this.onLevelComplete,
    required this.onCoinsUpdated,
    required this.onBossEncounter,
    required this.onPlayerDied,
    this.onCulturalItemUnlocked,
  });

  void updateLives(int lives) {
    currentLives = lives;
    if (livesText != null) {
      livesText!.text = '❤️ $currentLives';
    }
  }

  // ==========================================================
  // 🧠 2. HELPER PINTAR: AMBIL PANJANG MAP DINAMIS PER PULAU
  // ==========================================================
  double getLevelLength() {
    switch (islandName.toUpperCase()) {
      case 'JAWA':
        return JawaLevelData.levelLength;
      case 'KALIMANTAN':
        return KalimantanLevelData.levelLength;
      case 'SULAWESI':
        return SulawesiLevelData.levelLength;
      case 'PAPUA':
        return PapuaLevelData.levelLength;
      default:
        return SumatraLevelData.levelLength;
    }
  }

  // 🔥 METHOD BARU: Reset zona bos kalau pemain kalah kuis
  void resetBossTrigger() {
    _hasEnteredBossZone = false;
    // Mundurkan Satria 600px ke belakang (ke daerah aman sebelum kotak ungu)
    player.position.x = getLevelLength() - 600;
    print('🔄 Boss Zone di-reset! Satria dimundurkan siap lawan bos lagi.');
  }
  // ==========================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(virtualWidth, virtualHeight),
    );
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2(virtualWidth / 2, virtualHeight / 2);
    camera.viewfinder.zoom = cameraZoom;

    groundY = virtualHeight * 0.75;
    await _loadBackground();

    String bgmFile = 'audio/bgm/bgm_${islandName.toLowerCase()}.mp3';
    AudioManager.instance.playBGM(bgmFile);

    totalWalletCoins = await GamePrefs.getCoins();
    currentLives = await GamePrefs.getExtraLives();
    _hasDefeatedBoss = await GamePrefs.isBossDefeated(islandName);
    updateLives(currentLives);

    player = Player(
      size: Vector2(64, 96),
      groundY: groundY,
      onCoinCollected: () async {
        collectedCoins += 10;
        totalWalletCoins += 10;
        await GamePrefs.saveCoins(totalWalletCoins);
        coinText.text = '🪙 $totalWalletCoins';
        onCoinsUpdated(collectedCoins);
        AudioManager.instance.playSFX('sfx_coin.mp3');
      },
      onPlayerDied: () {
        pauseEngine();
        AudioManager.instance.playSFX('sfx_gameover.mp3');
        onPlayerDied(); // ✅ Panggil callback ke GameScreen
      },
      onPlayerLanded: () {
        AudioManager.instance.playSFX('sfx_land.mp3');
      },
    )
      ..position = Vector2(100, groundY - 96)
      ..priority = 100;
    world.add(player);

    // ✅ Lempar nama pulau ke LevelBuilder agar rintangan menyesuaikan
    // 🏛️ SPRINT 6.4: onCulturalItemFound terhubung ke MuseumGameplayBridge.
    world.add(LevelBuilder(
      groundY: groundY,
      islandName: islandName,
      onCulturalItemFound: (_) {
        // Jalankan async — tidak perlu await di Flame game loop.
        // MuseumManager.notifyListeners() dipanggil secara internal oleh
        // tryUnlockItem(), sehingga semua Museum screen terupdate otomatis.
        // 🏛️ SPRINT REFACTOR 2: Unlock sekuensial tingkat pulau (Sumatra: Aceh -> Bengkulu -> Jambi -> Lampung -> Sumut -> Sumbar -> Sumsel -> Riau)
        MuseumGameplayBridge.unlockNextItemInIsland(islandName.toLowerCase()).then((result) {
          if (result.hasNewItem && result.item != null) {
            debugPrint(
              '🏛️ [Museum] Item baru terbuka! '
              '${result.item!.name} (${result.item!.province} - ${result.item!.island})',
            );
            pauseEngine(); // 🏛️ SPRINT 6.5: Pause gameplay saat popup muncul
            onCulturalItemUnlocked?.call(result.item!);
          } else {
            debugPrint(
              '🏛️ [Museum] islandName=$islandName — '
              'semua item di pulau ini sudah terbuka atau item tidak ditemukan.',
            );
          }
        });
      },
    ));


    String controlType = await GamePrefs.getControlType();
    if (controlType == 'analog') {
      final analog = AnalogController(
        onJoystickUpdate: (delta) => player.currentInputDelta = delta,
        onJumpPressed: () {
          player.jump();
          AudioManager.instance.playSFX('sfx_jump.mp3');
        },
      );
      camera.viewport.add(analog);
    } else {
      final arrow = ArrowController(
        onJoystickUpdate: (delta) => player.currentInputDelta = delta,
        onJumpPressed: () {
          player.jump();
          AudioManager.instance.playSFX('sfx_jump.mp3');
        },
      );
      camera.viewport.add(arrow);
    }

    final islandText = TextComponent(
      text: '🏝️ $islandName',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      position: Vector2(20, 20),
    );
    camera.viewport.add(islandText);

    coinText = TextComponent(
      text: '🪙 $totalWalletCoins',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      position: Vector2(20, 55),
    );
    camera.viewport.add(coinText);

    livesText = TextComponent(
      text: '❤️ $currentLives',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      position: Vector2(20, 90),
    );
    camera.viewport.add(livesText!);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (paused) return;

    final targetX = player.position.x + player.size.x / 2;
    final targetY = virtualHeight / 2;

    camera.viewfinder.position = Vector2(
      camera.viewfinder.position.x +
          (targetX - camera.viewfinder.position.x) * 0.1,
      camera.viewfinder.position.y +
          (targetY - camera.viewfinder.position.y) * 0.1,
    );

    // ✅ 3. AMBIL PANJANG LEVEL SECARA DINAMIS
    final double totalLength = getLevelLength();
    double visibleWorldWidth = virtualWidth / cameraZoom;
    double minCamX = visibleWorldWidth / 2;
    double maxCamX = totalLength - (visibleWorldWidth / 2);

    if (maxCamX > minCamX) {
      camera.viewfinder.position.x =
          camera.viewfinder.position.x.clamp(minCamX, maxCamX);
    } else {
      camera.viewfinder.position.x = minCamX;
    }

    // 🔥 PRIORITAS 1: BOSS ZONE TRIGGER (Koordinat pas di kotak ungu, tanpa syarat !_hasDefeatedBoss)
    if (player.position.x >= totalLength - 280 &&
        player.position.x < totalLength - 100 &&
        !_hasEnteredBossZone) {
      print('🔥🔥 BOSS ZONE TRIGGERED! Posisi: ${player.position.x.toInt()}');
      _hasEnteredBossZone = true;
      pauseEngine();
      onBossEncounter();
      return;
    }

    // ✅ PRIORITAS 2: Level Complete (Di ujung map)
    if (player.position.x >= totalLength - 100 && !isLevelFinished) {
      print('✅ LEVEL COMPLETE!');
      isLevelFinished = true;
      pauseEngine();
      AudioManager.instance.playSFX('sfx_level_complete.mp3');
      onLevelComplete();
      return;
    }

    // ⛔ PRIORITAS 3: Player mencoba finish TANPA mengalahkan boss
    if (player.position.x >= totalLength - 50 &&
        !isLevelFinished &&
        !_hasDefeatedBoss) {
      print(
        '⛔ ACCESS DENIED! Player di x=${player.position.x.toInt()} tapi boss belum dikalahkan!',
      );
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      player.jump();
      AudioManager.instance.playSFX('sfx_jump.mp3');
    }
    return KeyEventResult.handled;
  }

  Future<void> _loadBackground() async {
    final paths = [
      'background/bg_${islandName.toLowerCase()}.png',
      'background/bg_${islandName.toLowerCase()}.jpg',
    ];
    for (final p in paths) {
      try {
        final img = await images.load(p);
        camera.backdrop.add(
          SpriteComponent(
            sprite: Sprite(img),
            size: Vector2(virtualWidth, virtualHeight),
          ),
        );
        return;
      } catch (_) {}
    }
    camera.backdrop.add(
      RectangleComponent(
        size: Vector2(virtualWidth, virtualHeight),
        paint: Paint()..color = Colors.blue[300]!,
      ),
    );
  }

  @override
  void onRemove() {
    AudioManager.instance.stopBGM();
    super.onRemove();
  }
}
