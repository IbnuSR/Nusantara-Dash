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
import 'data/sumatra_level_data.dart';
import 'package:nusantara_dash/utils/game_prefs.dart';
import 'package:nusantara_dash/utils/audio_manager.dart';

class NusantaraDashGame extends FlameGame
    with KeyboardEvents, HasCollisionDetection {
  final String islandName;
  final VoidCallback onGameOver;
  final VoidCallback onLevelComplete;
  final Function(int) onCoinsUpdated;
  final VoidCallback onBossEncounter;
  final VoidCallback onPlayerDied; // ✅ TAMBAHKAN INI

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
    required this.onPlayerDied, // ✅ WAJIB ADA
  });

  void updateLives(int lives) {
    currentLives = lives;
    if (livesText != null) {
      livesText!.text = '❤️ $currentLives';
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewport = FixedResolutionViewport(
        resolution: Vector2(virtualWidth, virtualHeight));
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
        onPlayerDied(); // ✅ Panggil callback ke GameScreen (BUKAN onGameOver langsung)
      },
      onPlayerLanded: () {
        AudioManager.instance.playSFX('sfx_land.mp3');
      },
    )
      ..position = Vector2(100, groundY - 96)
      ..priority = 100;
    world.add(player);

    world.add(LevelBuilder(groundY: groundY));

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
            shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
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
            shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
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
            shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
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

    double visibleWorldWidth = virtualWidth / cameraZoom;
    double minCamX = visibleWorldWidth / 2;
    double maxCamX = SumatraLevelData.levelLength - (visibleWorldWidth / 2);

    if (maxCamX > minCamX) {
      camera.viewfinder.position.x =
          camera.viewfinder.position.x.clamp(minCamX, maxCamX);
    } else {
      camera.viewfinder.position.x = minCamX;
    }

    // 🔥 PRIORITAS 1: BOSS ZONE TRIGGER
    if (player.position.x >= 5000 &&
        player.position.x < 5900 &&
        !_hasEnteredBossZone &&
        !_hasDefeatedBoss) {
      print('🔥🔥 BOSS ZONE TRIGGERED! Posisi: ${player.position.x.toInt()}');
      _hasEnteredBossZone = true;
      pauseEngine();
      onBossEncounter();
      return;
    }

    // ✅ PRIORITAS 2: Level Complete (HANYA jika boss sudah dikalahkan)
    if (player.position.x >= SumatraLevelData.levelLength - 100 &&
        !isLevelFinished &&
        _hasDefeatedBoss) {
      print('✅ LEVEL COMPLETE! Boss sudah dikalahkan.');
      isLevelFinished = true;
      pauseEngine();
      AudioManager.instance.playSFX('sfx_level_complete.mp3');
      onLevelComplete();
      return;
    }

    // ⛔ PRIORITAS 3: Player mencoba finish TANPA mengalahkan boss
    if (player.position.x >= SumatraLevelData.levelLength - 50 &&
        !isLevelFinished &&
        !_hasDefeatedBoss) {
      print(
          '⛔ ACCESS DENIED! Player di x=${player.position.x.toInt()} tapi boss belum dikalahkan!');
    }
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      player.jump();
      AudioManager.instance.playSFX('sfx_jump.mp3');
    }
    return KeyEventResult.handled;
  }

  Future<void> _loadBackground() async {
    final paths = [
      'background/bg_${islandName.toLowerCase()}.png',
      'background/bg_${islandName.toLowerCase()}.jpg'
    ];
    for (final p in paths) {
      try {
        final img = await images.load(p);
        camera.backdrop.add(SpriteComponent(
            sprite: Sprite(img), size: Vector2(virtualWidth, virtualHeight)));
        return;
      } catch (_) {}
    }
    camera.backdrop.add(RectangleComponent(
        size: Vector2(virtualWidth, virtualHeight),
        paint: Paint()..color = Colors.blue[300]!));
  }

  @override
  void onRemove() {
    AudioManager.instance.stopBGM();
    super.onRemove();
  }
}
