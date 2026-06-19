import 'dart:ui';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/input.dart';
import 'components/player/player.dart';
import 'components/level_builder.dart';
import 'data/sumatra_level_data.dart';
import 'package:nusantara_dash/utils/coin_manager.dart'; // ✅ Pastikan import ini benar

class NusantaraDashGame extends FlameGame
    with KeyboardEvents, HasCollisionDetection {
  final String islandName;
  final VoidCallback onGameOver;
  final VoidCallback onLevelComplete;
  final Function(int) onCoinsUpdated;

  late Player player;
  late JoystickComponent joystick;
  late double groundY;

  int collectedCoins = 0; // Koin sesi berjalan
  int totalWalletCoins =
      0; // ✅ Tambah variabel penampung saldo total koin storage
  int currentLives = 0;
  late TextComponent coinText;
  TextComponent? livesText;
  bool isLevelFinished = false;

  static const double virtualWidth = 1280;
  static const double virtualHeight = 720;

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

    groundY = virtualHeight * 0.75;
    await _loadBackground();

    // ✅ Muat saldo total koin terkini dari storage saat level dimulai
    totalWalletCoins = await CoinManager.getCoins();

    player =
        Player(
            size: Vector2(64, 96),
            groundY: groundY,
            onCoinCollected: () async {
              collectedCoins++;
              totalWalletCoins++; // Sinkronisasikan penambahan koin langsung ke saldo utama

              // ✅ FIX UTAMA: Simpan penambahan koin secara instan dan real-time ke SharedPreferences
              await CoinManager.saveCoins(totalWalletCoins);

              // Update teks HUD permainan langsung dengan jumlah saldo koin terbaru milik user
              coinText.text = '🪙 $totalWalletCoins';
              onCoinsUpdated(collectedCoins);
            },
            onPlayerDied: () {
              pauseEngine();
              onGameOver();
            },
          )
          ..position = Vector2(100, groundY - 96)
          ..priority = 100;
    world.add(player);

    world.add(LevelBuilder(groundY: groundY));

    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 30,
        paint: Paint()..color = Colors.amber.withOpacity(0.9),
      ),
      background: CircleComponent(
        radius: 70,
        paint: Paint()..color = Colors.white.withOpacity(0.3),
      ),
      margin: const EdgeInsets.only(left: 60, bottom: 60),
    );
    camera.viewport.add(joystick);
    player.joystick = joystick;

    final jumpButton = ButtonComponent(
      button: CircleComponent(
        radius: 45,
        paint: Paint()..color = Colors.amber.withOpacity(0.9),
      ),
      buttonDown: CircleComponent(
        radius: 45,
        paint: Paint()..color = Colors.orange.withOpacity(0.9),
      ),
      position: Vector2(virtualWidth - 105, virtualHeight - 105),
      anchor: Anchor.center,
      onPressed: () => player.jump(),
    );

    jumpButton.add(
      TextComponent(
        text: '▲',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
      ),
    );
    camera.viewport.add(jumpButton);

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

    // Menampilkan saldo koin terkini di layar game secara real-time
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

    double minCamX = virtualWidth / 2;
    double maxCamX = SumatraLevelData.levelLength - (virtualWidth / 2);

    if (maxCamX > minCamX) {
      camera.viewfinder.position.x = camera.viewfinder.position.x.clamp(
        minCamX,
        maxCamX,
      );
    } else {
      camera.viewfinder.position.x = minCamX;
    }

    if (player.position.x >= SumatraLevelData.levelLength - 150 &&
        !isLevelFinished) {
      isLevelFinished = true;
      pauseEngine();
      onLevelComplete();
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      player.jump();
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
