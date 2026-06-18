import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../data/sumatra_level_data.dart';

class GroundPlatform extends RectangleComponent {
  GroundPlatform({super.position, super.size, super.paint, super.anchor});
}

class RedObstacle extends RectangleComponent {
  RedObstacle({super.position, super.size, super.paint, super.anchor});
}

// ✅ TAMBAHAN: Kita berikan flag 'isCollected'
class CoinItem extends CircleComponent {
  bool isCollected = false;
  CoinItem({super.position, super.radius, super.paint, super.anchor});
}

class LevelBuilder extends PositionComponent with HasGameRef {
  final double groundY;

  LevelBuilder({required this.groundY});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _spawnGroundAndPlatforms();
    _spawnObstacles();
    _spawnCoins();
    _spawnBossMarker();
  }

  void _spawnGroundAndPlatforms() {
    for (final p in SumatraLevelData.platforms) {
      final platform = GroundPlatform(
        position: Vector2(p['x']!, groundY + p['y']!),
        size: Vector2(p['w']!, p['h']!),
        paint: Paint()..color = const Color(0xFF2E7D32),
        anchor: Anchor.topLeft,
      );
      platform.add(RectangleHitbox());
      add(platform);
    }
  }

  void _spawnObstacles() {
    for (final o in SumatraLevelData.obstacles) {
      final obstacle = RedObstacle(
        position: Vector2(o['x']!, groundY + o['y']!),
        size: Vector2(o['w']!, o['h']!),
        paint: Paint()..color = Colors.red.shade800,
        anchor: Anchor.topLeft,
      );
      obstacle.add(RectangleHitbox());
      add(obstacle);
    }
  }

  void _spawnCoins() {
    for (final c in SumatraLevelData.coins) {
      final coin = CoinItem(
        position: Vector2(c['x']!, groundY + c['y']!),
        radius: 14,
        paint: Paint()..color = Colors.amber,
        anchor: Anchor.center,
      );
      coin.add(CircleHitbox());
      add(coin);
    }
  }

  void _spawnBossMarker() {
    add(
      RectangleComponent(
        position: Vector2(SumatraLevelData.levelLength - 250, groundY - 180),
        size: Vector2(200, 180),
        paint: Paint()..color = Colors.purple.withOpacity(0.25),
        anchor: Anchor.topLeft,
      ),
    );

    add(
      TextComponent(
        text: '⚔️ BOSS ZONE',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(SumatraLevelData.levelLength - 200, groundY - 200),
      ),
    );
  }
}
