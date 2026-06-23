import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart' hide Image;
import '../data/sumatra_level_data.dart';

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

  LevelBuilder({required this.groundY});

  // ✅ PERBAIKAN: Nama variabel diubah menjadi 'fileName' tanpa spasi
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

    // 1. Load Aset Tanah (Sesuai dimensi asli)
    final t1Img = await _safeLoad('tanah'); // Dimensi: 1664 x 509
    final t2Img = await _safeLoad('tanah2'); // Dimensi: 669 x 197
    final t3Img = await _safeLoad('tanah3'); // Dimensi: 1205 x 499

    // 2. Load Aset Rintangan (Sesuai dimensi asli)
    final kayuImg = await _safeLoad('kayu'); // Dimensi: 445 x 242
    final batuImg = await _safeLoad('batu'); // Dimensi: 546 x 329
    final oyotImg = await _safeLoad('oyot'); // Dimensi: 564 x 348

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

  // ✅ FUNGSI 1: MENGGAMBAR TANAH DENGAN DISTRIBUSI OTOMATIS
  void _spawnGroundAndPlatforms(Sprite g1, Sprite g2, Sprite g3) {
    for (final p in SumatraLevelData.platforms) {
      double targetWidth = p['w']!;
      double targetHeight = p['h']!;
      Sprite spriteTerpilih;

      // Pemilihan cerdas berdasarkan lebar pijakan:
      if (targetWidth >= 400) {
        spriteTerpilih = g1; // Tanah raksasa (tanah.png)
      } else if (targetWidth >= 200) {
        spriteTerpilih = g2; // Tanah jembatan sedang (tanah2.jpg)
      } else {
        spriteTerpilih = g3; // Pulau apung kecil (tanah3.png)
      }

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

  // ✅ FUNGSI 2: MENGGAMBAR RINTANGAN DENGAN RUMUS SKALA PRESISI
  void _spawnObstacles(Sprite kayu, Sprite batu, Sprite oyot) {
    int urutan = 0;
    for (final o in SumatraLevelData.obstacles) {
      Sprite spriteTerpilih;

      // Ambil tinggi patokan dari level data (misal 30px atau 40px)
      double patokanTinggi = o['h']!;
      double lebarPresisi;

      if (urutan % 3 == 0) {
        spriteTerpilih = kayu;
        // Aspek rasio kayu = 445 / 242
        lebarPresisi = patokanTinggi * (445.0 / 242.0);
      } else if (urutan % 3 == 1) {
        spriteTerpilih = batu;
        // Aspek rasio batu = 546 / 329
        lebarPresisi = patokanTinggi * (546.0 / 329.0);
      } else {
        spriteTerpilih = oyot;
        // Aspek rasio oyot = 564 / 348
        lebarPresisi = patokanTinggi * (564.0 / 348.0);
      }

      final obstacle = RedObstacle(
        sprite: spriteTerpilih,
        position: Vector2(o['x']!, groundY + o['y']!),
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
