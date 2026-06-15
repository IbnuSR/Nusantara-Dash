import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/input.dart';
import 'components/player/player.dart';

class NusantaraDashGame extends FlameGame
    with KeyboardEvents, HasCollisionDetection {
  final String islandName;
  late Player player;
  late JoystickComponent joystick;
  late double groundY;

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

    // ✅ JANGAN SET VIEWPORT MANUAL - Biarkan auto-resize
    groundY = size.y - 100;

    // 1. Load Background
    await _loadBackground();

    // 2. Ground (Tanah)
    final groundColor = islandThemes[islandName] ?? Colors.brown;
    add(
      RectangleComponent(
        position: Vector2(0, groundY),
        size: Vector2(size.x * 3, 100),
        paint: Paint()..color = groundColor,
      )..priority = -5,
    );

    // 3. Joystick (Kiri Bawah)
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

    // 4. Player - KIRIM JOYSTICK
    final playerWidth = 62.5;
    final playerHeight = 150.0;

    player = Player(
      size: Vector2(playerWidth, playerHeight),
      groundY: groundY,
      joystick: joystick, // ✅ WAJIB KIRIM JOYSTICK
    )..position = Vector2(100, groundY - playerHeight);
    add(player);

    // 5. Tambahkan Joystick ke Game
    add(joystick);

    // 6. Camera Follow Player
    camera.follow(player);

    // 7. Tombol Lompat (Kanan Bawah)
    final jumpButton = ButtonComponent(
      button: CircleComponent(
        radius: 45,
        paint: Paint()..color = Colors.amber.withOpacity(0.9),
      ),
      buttonDown: CircleComponent(
        radius: 45,
        paint: Paint()..color = Colors.orange.withOpacity(0.9),
      ),
      position: Vector2(size.x - 105, size.y - 105),
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
    add(jumpButton);

    // 8. Mini Boss
    add(
      RectangleComponent(
        position: Vector2(size.x * 2, groundY - 100),
        size: Vector2(80, 100),
        paint: Paint()..color = Colors.purple[900]!,
      )..add(
        TextComponent(
          text: 'BOSS',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        )..position = Vector2(15, -15),
      ),
    );

    // 9. Info Pulau
    add(
      TextComponent(
        text: '🏝️ $islandName',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
      )..position = Vector2(20, 20),
    );
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        player.position.x += 10;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        player.position.x -= 10;
      }
      if (event.logicalKey == LogicalKeyboardKey.space) {
        player.jump();
      }
    }
    return KeyEventResult.handled;
  }

  Future<void> _loadBackground() async {
    final islandLower = islandName.toLowerCase();
    final possiblePaths = [
      'assets/images/background/bg_$islandLower.png',
      'assets/images/background/bg_$islandLower.jpg',
      'assets/images/background/bg_$islandLower.jpeg',
    ];

    for (final path in possiblePaths) {
      try {
        final image = await images.load(path);
        add(
          SpriteComponent(
            sprite: Sprite(image),
            size: Vector2(size.x * 3, size.y),
            position: Vector2(0, 0),
          )..priority = -10,
        );
        debugPrint('✅ Background loaded: $path');
        return;
      } catch (e) {
        continue;
      }
    }

    debugPrint('⚠️ Background tidak ditemukan, pakai gradient fallback');
    add(
      RectangleComponent(
        size: Vector2(size.x * 3, size.y),
        paint: Paint()..color = _getSkyColor(),
      )..priority = -20,
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
