import 'dart:ui';
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
    groundY = size.y - 100;

    await _loadBackground();
    add(LevelBuilder(groundY: groundY));

    player = Player(size: Vector2(62.5, 150.0), groundY: groundY)
      ..position = Vector2(200, groundY - 150);
    add(player);

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
    add(joystick);
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

  // ✅ KAMERA TRACKING YANG PASTI JALAN
  @override
  void update(double dt) {
    super.update(dt);
    if (paused) return;

    // Langsung set posisi kamera ke posisi player
    // Ini cara paling simple & dijamin bekerja
    camera.viewfinder.position.x = player.position.x;
    camera.viewfinder.position.y = size.y / 2;

    // Clamp agar tidak keluar map
    double minCamX = size.x / 2;
    double maxCamX = SumatraLevelData.levelLength - size.x / 2;
    camera.viewfinder.position.x = camera.viewfinder.position.x.clamp(
      minCamX,
      maxCamX,
    );
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
      'assets/images/background/bg_${islandName.toLowerCase()}.png',
      'assets/images/background/bg_${islandName.toLowerCase()}.jpg',
    ];
    for (final p in paths) {
      try {
        final img = await images.load(p);
        add(
          SpriteComponent(sprite: Sprite(img), size: Vector2(size.x, size.y))
            ..priority = -10,
        );
        return;
      } catch (_) {}
    }
    add(
      RectangleComponent(
        size: Vector2(size.x, size.y),
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
