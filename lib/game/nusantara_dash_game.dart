import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/camera.dart';
import 'package:flame/input.dart';
import 'components/player/player.dart';

class NusantaraDashGame extends FlameGame with KeyboardEvents {
  final String islandName;
  late Player player;

  final double groundY = 380;
  final double groundHeight = 70;

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

    camera.viewport = FixedResolutionViewport(resolution: Vector2(800, 450));

    // 1. Load Background
    await _loadBackground();

    // 2. Ground
    final groundColor = islandThemes[islandName] ?? Colors.brown;
    add(
      RectangleComponent(
        position: Vector2(0, groundY),
        size: Vector2(800, groundHeight),
        paint: Paint()..color = groundColor,
      )..priority = -5,
    );

    // 3. ✅ Player dengan ukuran PROPORSIONAL (tidak cemet!)
    // Aspect ratio texture: 125x300 = 1 : 2.4
    // Kita pakai tinggi 150px → lebar = 150 / 2.4 = 62.5px
    final playerWidth = 62.5;
    final playerHeight = 150.0;

    player = Player(size: Vector2(playerWidth, playerHeight))
      ..position = Vector2(100, groundY - playerHeight);
    add(player);

    // 4. Mini Boss
    add(
      RectangleComponent(
        position: Vector2(-150, groundY - 100),
        size: Vector2(80, 100),
        paint: Paint()..color = Colors.purple[900]!,
      )..add(
        TextComponent(
          text: 'BOSS',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        )..position = Vector2(15, -15),
      ),
    );

    // 5. Info Pulau
    add(
      TextComponent(
        text: '🏝️ $islandName',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
      )..position = Vector2(20, 20),
    );

    // 6. Instruksi
    add(
      TextComponent(
        text: '← → : Gerak | SPACE : Lompat',
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      )..position = Vector2(20, 420),
    );
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        player.isMoving = true;
        player.scale.x = 1;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        player.isMoving = true;
        player.scale.x = -1;
      }

      if (event.logicalKey == LogicalKeyboardKey.space) {
        player.jump();
      }
    }

    if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (!keysPressed.contains(LogicalKeyboardKey.arrowRight) &&
            !keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
          player.isMoving = false;
        }
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
            size: Vector2(800, 450),
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
        size: Vector2(800, 450),
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
