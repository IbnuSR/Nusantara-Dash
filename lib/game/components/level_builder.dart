import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:nusantara_dash/game/data/sumatra_level_data.dart'; // ✅ Path absolut aman

class GroundPlatform extends SpriteComponent {
  GroundPlatform({super.sprite, super.position, super.size, super.anchor});
}

class RedObstacle extends SpriteComponent {
  RedObstacle({super.sprite, super.position, super.size, super.anchor});
}

class CoinItem extends CircleComponent {
  bool isCollected = false;
  CoinItem({super.position, super.radius, super.paint, super.anchor});
}

class LevelBuilder extends PositionComponent with HasGameRef {
  final double groundY;

  // ✅ ANGKA AMBLES: Efek gaya gravitasi menekan rumput (Bisa kamu utak-atik antara 6.0 sampai 10.0)
  static const double obstacleSinkOffset = 8.0;

  LevelBuilder({required this.groundY});

  Future<Image> _safeLoad(String fileName) async {
    try {
      return await gameRef.images.load('obstacles/$fileName.png');
    } catch (_) {
      return await gameRef.images.load('obstacles/$fileName.jpg');
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final t1Img = await _safeLoad('tanah');
    final t2Img = await _safeLoad('tanah2');
    final t3Img = await _safeLoad('tanah3');

    final kayuImg = await _safeLoad('kayu');
    final batuImg = await _safeLoad('batu');
    final oyotImg = await _safeLoad('oyot');

    final t1Sprite = Sprite(t1Img);
    final t2Sprite = Sprite(t2Img);
    final t3Sprite = Sprite(t3Img);

    final kayuSprite = Sprite(kayuImg);
    final batuSprite = Sprite(batuImg);
    final oyotSprite = Sprite(oyotImg);

    _spawnGroundAndPlatforms(t1Sprite, t2Sprite, t3Sprite);
    _spawnObstacles(kayuSprite, batuSprite, oyotSprite);
    _spawnCoins();
    _spawnBossMarker();
  }

  void _spawnGroundAndPlatforms(Sprite g1, Sprite g2, Sprite g3) {
    for (final p in SumatraLevelData.platforms) {
      double targetWidth = p['w']!;
      double targetHeight = p['h']!;
      Sprite spriteTerpilih;

      if (targetWidth >= 400)
        spriteTerpilih = g1;
      else if (targetWidth >= 200)
        spriteTerpilih = g2;
      else
        spriteTerpilih = g3;

      final platform = GroundPlatform(
        sprite: spriteTerpilih,
        position: Vector2(p['x']!, groundY + p['y']!),
        size: Vector2(targetWidth, targetHeight),
        anchor: Anchor.topLeft,
      );
      platform.add(RectangleHitbox());
      add(platform);
    }
  }

  void _spawnObstacles(Sprite kayu, Sprite batu, Sprite oyot) {
    int urutan = 0;
    for (final o in SumatraLevelData.obstacles) {
      Sprite spriteTerpilih;
      double patokanTinggi = o['h']!;
      double lebarPresisi;

      if (urutan % 3 == 0) {
        spriteTerpilih = kayu;
        lebarPresisi = patokanTinggi * (445.0 / 242.0);
      } else if (urutan % 3 == 1) {
        spriteTerpilih = batu;
        lebarPresisi = patokanTinggi * (546.0 / 329.0);
      } else {
        spriteTerpilih = oyot;
        lebarPresisi = patokanTinggi * (564.0 / 348.0);
      }

      final obstacle = RedObstacle(
        sprite: spriteTerpilih,
        // ✅ DI SINI TRIKNYA: Posisi Y kita dorong ke bawah sejauh +8 piksel!
        position: Vector2(o['x']!, groundY + o['y']! + obstacleSinkOffset),
        size: Vector2(lebarPresisi, patokanTinggi),
        anchor: Anchor.topLeft,
      );

      obstacle.add(RectangleHitbox());
      add(obstacle);
      urutan++;
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
