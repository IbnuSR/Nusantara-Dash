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

class NusantaraDashGame extends FlameGame
    with KeyboardEvents, HasCollisionDetection {
  final String islandName;
  late Player player;
  late JoystickComponent joystick;
  late double groundY;

  // ✅ TAMBAHAN: Variabel Penyimpan Koin & UI Teks
  int collectedCoins = 0;
  late TextComponent coinText;

  static const double virtualWidth = 1280;
  static const double virtualHeight = 720;

  final Map<String, Color> islandThemes = {
    'SUMATRA': const Color(0xFF2E7D32),
    'JAWA': const Color(0xFFE65100),
    'KALIMANTAN': const Color(0xFF1B5E20),
    'SULAWESI': const Color(0xFF0277BD),
    'PAPUA': const Color(0xFF4E342E),
  };

  NusantaraDashGame({required this.islandName});

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

    // ✅ UPDATE: Player ditambahkan fungsi pelapor koin
    player =
        Player(
            size: Vector2(64, 96),
            groundY: groundY,
            onCoinCollected: () {
              collectedCoins++; // Tambah skor
              coinText.text = '🪙 $collectedCoins'; // Perbarui tulisan di UI
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

    // ✅ TAMBAHAN: UI Teks Koin di Kiri Atas
    coinText = TextComponent(
      text: '🪙 $collectedCoins',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      position: Vector2(20, 55), // Berada pas di bawah nama pulau
    );
    camera.viewport.add(coinText);
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
        paint: Paint()..color = _getSkyColor(),
      ),
    );
  }

  Color _getSkyColor() {
    switch (islandName) {
      case 'SUMATRA':
        return const Color(0xFF81D4FA);
      case 'JAWA':
        return const Color(0xFFFFCC80);
      case 'KALIMANTAN':
        return const Color(0xFFA5D6A7);
      case 'SULAWESI':
        return const Color(0xFF4FC3F7);
      case 'PAPUA':
        return const Color(0xFFB0BEC5);
      default:
        return Colors.blue[300]!;
    }
  }
}
