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
import 'package:nusantara_dash/utils/audio_manager.dart'; // ✅ IMPORT INI

class NusantaraDashGame extends FlameGame
    with KeyboardEvents, HasCollisionDetection {
  final String islandName;
  final VoidCallback onGameOver;
  final VoidCallback onLevelComplete;
  final Function(int) onCoinsUpdated;

  late Player player;
  late double groundY;

  int collectedCoins = 0;
  int totalWalletCoins = 0;
  int currentLives = 0;
  late TextComponent coinText;
  TextComponent? livesText;
  bool isLevelFinished = false;

  static const double virtualWidth = 1280;
  static const double virtualHeight = 720;

  // ✅ ANGKA SAKTI: Zoom kamera (1.35 artinya kamera 35% lebih dekat ke karakter)
  static const double cameraZoom = 1.35;

  NusantaraDashGame({
    required this.islandName,
    required this.onGameOver,
    required this.onLevelComplete,
    required this.onCoinsUpdated,
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
      resolution: Vector2(virtualWidth, virtualHeight),
    );
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2(virtualWidth / 2, virtualHeight / 2);

    // ✅ PASANG ZOOM KAMERA DI SINI:
    camera.viewfinder.zoom = cameraZoom;

    groundY = virtualHeight * 0.75;
    await _loadBackground();

    totalWalletCoins = await GamePrefs.getCoins();

    // ✅ INI BAGIAN PENTING: Colok SFX ke callback player
    // ✅ PATH DIPERBAIKI: 'audio/sfx/...' bukan 'sfx/...'
    player = Player(
      size: Vector2(64, 96),
      groundY: groundY,

      // 🔊 CALLBACK 1: Saat ambil koin → main SFX coin
      onCoinCollected: () async {
        collectedCoins += 10;
        totalWalletCoins += 10;
        await GamePrefs.saveCoins(totalWalletCoins);
        coinText.text = '🪙 $totalWalletCoins';
        onCoinsUpdated(collectedCoins);

        // 🔊 MAINKAN SFX KOIN (Cukup nama file saja)
        AudioManager.instance.playSFX('sfx_coin.mp3');
      },

      // 🔊 CALLBACK 2: Saat mati → main SFX game over
      onPlayerDied: () {
        pauseEngine();
        // 🔊 MAINKAN SFX GAME OVER (Cukup nama file saja)
        AudioManager.instance.playSFX('sfx_gameover.mp3');
      },

      // 🔊 CALLBACK 3: Saat mendarat → main SFX land
      onPlayerLanded: () {
        // 🔊 MAINKAN SFX LAND (Cukup nama file saja)
        AudioManager.instance.playSFX('sfx_land.mp3');
      },
    )
      ..position = Vector2(100, groundY - 96)
      ..priority = 100;
    world.add(player);

    world.add(LevelBuilder(groundY: groundY));

    // ✅ Controller dengan SFX jump
    String controlType = await GamePrefs.getControlType();
    if (controlType == 'analog') {
      final analog = AnalogController(
        onJoystickUpdate: (delta) => player.currentInputDelta = delta,
        onJumpPressed: () {
          player.jump();
          // 🔊 MAINKAN SFX LOMPAT (Cukup nama file saja)
          AudioManager.instance.playSFX('sfx_jump.mp3');
        },
      );
      camera.viewport.add(analog);
    } else {
      final arrow = ArrowController(
        onJoystickUpdate: (delta) => player.currentInputDelta = delta,
        onJumpPressed: () {
          player.jump();
          // 🔊 MAINKAN SFX LOMPAT (Cukup nama file saja)
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

    // ✅ RUMUS BATAS KAMERA BARU (Menyesuaikan zoom agar ujung kiri map tidak tembus keluar)
    double visibleWorldWidth = virtualWidth / cameraZoom;
    double minCamX = visibleWorldWidth / 2;
    double maxCamX = SumatraLevelData.levelLength - (visibleWorldWidth / 2);

    if (maxCamX > minCamX) {
      camera.viewfinder.position.x = camera.viewfinder.position.x.clamp(
        minCamX,
        maxCamX,
      );
    } else {
      camera.viewfinder.position.x = minCamX;
    }

    // ✅ Level complete dengan SFX
    if (player.position.x >= SumatraLevelData.levelLength - 150 &&
        !isLevelFinished) {
      isLevelFinished = true;
      pauseEngine();
      // 🔊 MAINKAN SFX LEVEL COMPLETE (Cukup nama file saja)
      AudioManager.instance.playSFX('sfx_level_complete.mp3');
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      player.jump();
      // 🔊 MAINKAN SFX LOMPAT (keyboard) (Cukup nama file saja)
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
}
