import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart' hide Image;
// ✅ 1. IMPORT SEMUA DATA PULAU DI SINI:
import 'package:nusantara_dash/game/data/sumatra_level_data.dart';
import 'package:nusantara_dash/game/data/jawa_level_data.dart';
import 'package:nusantara_dash/game/data/kalimantan_level_data.dart';
import 'package:nusantara_dash/game/data/sulawesi_level_data.dart';
import 'package:nusantara_dash/game/data/papua_level_data.dart';

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
  final String islandName; // ✅ 2. TAMBAHKAN PARAMETER NAMA PULAU

  // Efek gaya gravitasi menekan rumput
  static const double obstacleSinkOffset = 8.0;

  // ✅ Wajib menerima islandName saat dipanggil di NusantaraDashGame
  LevelBuilder({required this.groundY, required this.islandName});

  Future<Image> _safeLoad(String fileName) async {
    try {
      return await gameRef.images.load('obstacles/$fileName.png');
    } catch (_) {
      return await gameRef.images.load('obstacles/$fileName.jpg');
    }
  }

  // ==========================================
  // 🧠 3. FUNGSI HELPER PINTAR (PEMILIH DATA)
  // ==========================================
  List<Map<String, double>> _getPlatforms() {
    switch (islandName.toUpperCase()) {
      case 'JAWA':
        return JawaLevelData.platforms;
      case 'KALIMANTAN':
        return KalimantanLevelData.platforms;
      case 'SULAWESI':
        return SulawesiLevelData.platforms;
      case 'PAPUA':
        return PapuaLevelData.platforms;
      default:
        return SumatraLevelData.platforms;
    }
  }

  List<Map<String, double>> _getObstacles() {
    switch (islandName.toUpperCase()) {
      case 'JAWA':
        return JawaLevelData.obstacles;
      case 'KALIMANTAN':
        return KalimantanLevelData.obstacles;
      case 'SULAWESI':
        return SulawesiLevelData.obstacles;
      case 'PAPUA':
        return PapuaLevelData.obstacles;
      default:
        return SumatraLevelData.obstacles;
    }
  }

  List<Map<String, double>> _getCoins() {
    switch (islandName.toUpperCase()) {
      case 'JAWA':
        return JawaLevelData.coins;
      case 'KALIMANTAN':
        return KalimantanLevelData.coins;
      case 'SULAWESI':
        return SulawesiLevelData.coins;
      case 'PAPUA':
        return PapuaLevelData.coins;
      default:
        return SumatraLevelData.coins;
    }
  }

  double _getLevelLength() {
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
  // ==========================================

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
    // ✅ 4. GANTI SumatraLevelData DENGAN _getPlatforms()
    for (final p in _getPlatforms()) {
      double targetWidth = p['w']!;
      double targetHeight = p['h']!;
      Sprite spriteTerpilih;

      if (targetWidth >= 400) {
        spriteTerpilih = g1;
      } else if (targetWidth >= 200) {
        spriteTerpilih = g2;
      } else {
        spriteTerpilih = g3;
      }

      final platform = GroundPlatform(
        sprite: spriteTerpilih,
        position: Vector2(p['x']!, groundY + p['y']!),
        size: Vector2(targetWidth, targetHeight),
        anchor: Anchor.topLeft,
      );

      // 🔥 OPTIMASI HP KENTANG: Jadikan Passive! Tanah tidak usah cek tabrakan sesama tanah.
      platform.add(RectangleHitbox(collisionType: CollisionType.passive));
      add(platform);
    }
  }

  void _spawnObstacles(Sprite kayu, Sprite batu, Sprite oyot) {
    int urutan = 0;
    // ✅ 5. GANTI SumatraLevelData DENGAN _getObstacles()
    for (final o in _getObstacles()) {
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
        position: Vector2(o['x']!, groundY + o['y']! + obstacleSinkOffset),
        size: Vector2(lebarPresisi, patokanTinggi),
        anchor: Anchor.topLeft,
      );

      // 🔥 OPTIMASI HP KENTANG: Rintangan diam saja menunggu ditabrak pemain.
      obstacle.add(RectangleHitbox(collisionType: CollisionType.passive));
      add(obstacle);
      urutan++;
    }
  }

  void _spawnCoins() {
    // ✅ 6. GANTI SumatraLevelData DENGAN _getCoins()
    for (final c in _getCoins()) {
      final coin = CoinItem(
        position: Vector2(c['x']!, groundY + c['y']!),
        radius: 14,
        paint: Paint()..color = Colors.amber,
        anchor: Anchor.center,
      );

      // 🔥 OPTIMASI HP KENTANG: Koin diam saja menunggu diambil pemain.
      coin.add(CircleHitbox(collisionType: CollisionType.passive));
      add(coin);
    }
  }

  void _spawnBossMarker() {
    // ✅ 7. GANTI SumatraLevelData DENGAN _getLevelLength()
    final double totalLength = _getLevelLength();

    add(
      RectangleComponent(
        position: Vector2(totalLength - 250, groundY - 180),
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
        position: Vector2(totalLength - 200, groundY - 200),
      ),
    );
  }
}
