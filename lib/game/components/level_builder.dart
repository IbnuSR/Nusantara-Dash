import 'dart:math';
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

// 🏛️ SPRINT 6.3: Hidden Cultural Item
import 'package:nusantara_dash/game/components/items/hidden_cultural_item.dart';

// 🗡️ WEAPON SYSTEM IMPORTS (Punya Kita)
import 'package:nusantara_dash/game/features/weapons/weapon_item.dart';
import 'package:nusantara_dash/game/components/player/player.dart'; // Diperlukan untuk collision placeholder

class GroundPlatform extends SpriteComponent {
  GroundPlatform({super.sprite, super.position, super.size, super.anchor});
}

class RedObstacle extends SpriteComponent {
  RedObstacle({super.sprite, super.position, super.size, super.anchor});
}

// 🔥 GABUNGAN: Pakai SpriteComponent (versi teman) TAPI tetap simpan isCollected (versi kita)
class CoinItem extends SpriteComponent with HasGameRef {
  bool isCollected =
      false; // ✅ WAJIB ADA agar player.dart bisa mendeteksi pengambilan

  CoinItem({super.position, super.size, super.anchor});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Muat gambar koin (pastikan file ada di assets/images/battle/coin.png)
    sprite = await gameRef.loadSprite('battle/coin.png');

    // 🔥 OPTIMASI HP KENTANG: Koin diam saja menunggu diambil pemain.
    add(CircleHitbox(collisionType: CollisionType.passive));
  }
}

class LevelBuilder extends PositionComponent with HasGameRef {
  final double groundY;
  final String islandName;

  // 🏛️ SPRINT 6.3: Callback Cultural Item
  final void Function(String provinceId)? onCulturalItemFound;

  // 🗡️ WEAPON SYSTEM: Callback Senjata (Punya Kita)
  final void Function(String weaponId, String weaponName)? onWeaponCollected;

  static const double obstacleSinkOffset = 8.0;

  LevelBuilder({
    required this.groundY,
    required this.islandName,
    this.onCulturalItemFound,
    this.onWeaponCollected, // ✅ Ditambahkan
  });

  Future<Image> _safeLoad(String fileName) async {
    try {
      return await gameRef.images.load('obstacles/$fileName.png');
    } catch (_) {
      return await gameRef.images.load('obstacles/$fileName.jpg');
    }
  }

  // ==========================================
  // 🧠 FUNGSI HELPER PINTAR (PEMILIH DATA)
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
    _spawnCoins(); // ✅ Menggunakan versi teman (Sprite)
    _spawnHiddenCulturalItem();
    _spawnWeapons(); // ✅ FITUR KITA: Spawn Senjata
    _spawnBossMarker();
  }

  void _spawnGroundAndPlatforms(Sprite g1, Sprite g2, Sprite g3) {
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

      platform.add(RectangleHitbox(collisionType: CollisionType.passive));
      add(platform);
    }
  }

  void _spawnObstacles(Sprite kayu, Sprite batu, Sprite oyot) {
    int urutan = 0;
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

      obstacle.add(RectangleHitbox(collisionType: CollisionType.passive));
      add(obstacle);
      urutan++;
    }
  }

  // ✅ MENGGUNAKAN VERSI TEMAN (LEBIH BAGUS VISUALNYA)
  void _spawnCoins() {
    for (final c in _getCoins()) {
      final coin = CoinItem(
        position: Vector2(c['x']!, groundY + c['y']!),
        size: Vector2(28, 28), // Sesuai dengan radius 14 sebelumnya
        anchor: Anchor.center,
      );
      add(coin);
    }
  }

  // =========================================================================
  // 🏛️ SPRINT 6.3: Hidden Cultural Item Spawning
  // =========================================================================
  List<Map<String, double>>? _getCandidatesForIsland() {
    switch (islandName.toUpperCase()) {
      case 'SUMATRA':
        return SumatraLevelData.hiddenItemSpawnCandidates;
      case 'JAWA':
        return JawaLevelData.hiddenItemSpawnCandidates;
      case 'KALIMANTAN':
        return KalimantanLevelData.hiddenItemSpawnCandidates;
      case 'SULAWESI':
        return SulawesiLevelData.hiddenItemSpawnCandidates;
      case 'PAPUA':
        return PapuaLevelData.hiddenItemSpawnCandidates;
      default:
        return null;
    }
  }

  List<String>? _getItemIdsForIsland() {
    switch (islandName.toUpperCase()) {
      case 'SUMATRA':
        return SumatraLevelData.hiddenItemIds;
      case 'JAWA':
        return JawaLevelData.hiddenItemIds;
      case 'KALIMANTAN':
        return KalimantanLevelData.hiddenItemIds;
      case 'SULAWESI':
        return SulawesiLevelData.hiddenItemIds;
      case 'PAPUA':
        return PapuaLevelData.hiddenItemIds;
      default:
        return null;
    }
  }

  void _spawnHiddenCulturalItem() {
    final List<Map<String, double>>? candidates = _getCandidatesForIsland();
    if (candidates == null || candidates.isEmpty) return;

    final List<String>? itemIds = _getItemIdsForIsland();
    if (itemIds == null || itemIds.isEmpty) return;

    final List<String> shuffledItemIds = List<String>.from(itemIds)..shuffle();
    final List<Map<String, double>> availableSpawns =
        List<Map<String, double>>.from(candidates)..shuffle();

    final int spawnCount = min(shuffledItemIds.length, availableSpawns.length);
    final List<Map<String, double>> chosenSpawns = availableSpawns
        .take(spawnCount)
        .toList()
      ..sort((a, b) => a['x']!.compareTo(b['x']!));

    for (int i = 0; i < spawnCount; i++) {
      final Map<String, double> spawn = chosenSpawns[i];
      final String itemId = shuffledItemIds[i];
      final Vector2 spawnPosition = Vector2(spawn['x']!, groundY + spawn['y']!);

      add(
        HiddenCulturalItemComponent(
          provinceId: itemId,
          position: spawnPosition,
          onCollected: onCulturalItemFound != null
              ? () => onCulturalItemFound!(itemId)
              : null,
        ),
      );
    }
  }

  // =========================================================================
  // 🗡️ WEAPON SYSTEM (PUNYA KITA - DITAMBAHKAN KE KODE TEMAN)
  // =========================================================================
  List<Map<String, double>>? _getWeaponSpawnPoints() {
    switch (islandName.toUpperCase()) {
      case 'SUMATRA':
        return SumatraLevelData.weaponSpawnPoints;
      case 'JAWA':
        return JawaLevelData.weaponSpawnPoints;
      case 'KALIMANTAN':
        return KalimantanLevelData.weaponSpawnPoints;
      case 'SULAWESI':
        return SulawesiLevelData.weaponSpawnPoints;
      case 'PAPUA':
        return PapuaLevelData.weaponSpawnPoints;
      default:
        return null;
    }
  }

  List<Map<String, String>>? _getWeaponsForIsland() {
    switch (islandName.toUpperCase()) {
      case 'SUMATRA':
        return SumatraLevelData.weapons;
      case 'JAWA':
        return JawaLevelData.weapons;
      case 'KALIMANTAN':
        return KalimantanLevelData.weapons;
      case 'SULAWESI':
        return SulawesiLevelData.weapons;
      case 'PAPUA':
        return PapuaLevelData.weapons;
      default:
        return null;
    }
  }

  void _spawnWeapons() async {
    final weaponSpawns = _getWeaponSpawnPoints();
    final weapons = _getWeaponsForIsland();

    if (weaponSpawns == null || weapons == null) return;
    if (weaponSpawns.isEmpty || weapons.isEmpty) return;

    Sprite? weaponSprite;
    try {
      final img = await _safeLoad('weapon_generic');
      weaponSprite = Sprite(img);
    } catch (e) {
      debugPrint(
          '⚠️ Sprite weapon_generic tidak ditemukan, pakai placeholder!');
    }

    for (int i = 0; i < weapons.length && i < weaponSpawns.length; i++) {
      final weaponData = weapons[i];
      final spawnPoint = weaponSpawns[i];
      final weaponId = weaponData['id']!;
      final weaponName = weaponData['name']!;
      final spawnPosition =
          Vector2(spawnPoint['x']!, groundY + spawnPoint['y']!);

      if (weaponSprite != null) {
        add(
          WeaponItem(
            weaponId: weaponId,
            weaponName: weaponName,
            islandOrigin: islandName,
            sprite: weaponSprite,
            position: spawnPosition,
            onCollected: () {
              onWeaponCollected?.call(weaponId, weaponName);
              debugPrint(
                  '🗡️ Weapon collected: $weaponName ($weaponId) from $islandName');
            },
          ),
        );
      } else {
        add(
          _WeaponPlaceholder(
            weaponId: weaponId,
            weaponName: weaponName,
            islandOrigin: islandName,
            position: spawnPosition,
            onCollected: () {
              onWeaponCollected?.call(weaponId, weaponName);
              debugPrint(
                  '🗡️ Weapon collected (placeholder): $weaponName ($weaponId) from $islandName');
            },
          ),
        );
      }
    }
  }

  // =========================================================================

  void _spawnBossMarker() {
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

// =========================================================================
// 🗡️ WEAPON PLACEHOLDER (PUNYA KITA - TETAP DIPERTAHANKAN)
// =========================================================================
class _WeaponPlaceholder extends PositionComponent
    with HasGameRef, CollisionCallbacks {
  final String weaponId;
  final String weaponName;
  final String islandOrigin;
  bool isCollected = false;
  final VoidCallback? onCollected;
  double _glowPhase = 0;

  _WeaponPlaceholder({
    required this.weaponId,
    required this.weaponName,
    required this.islandOrigin,
    required Vector2 position,
    this.onCollected,
  }) : super(position: position, size: Vector2(48, 48), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(
        size: Vector2(40, 40),
        position: Vector2(4, 4),
        collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _glowPhase += dt * 3;
    position.y += sin(_glowPhase) * 0.3;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.amber.withOpacity(0.8 + sin(_glowPhase) * 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(8)),
        paint);

    final borderPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(8)),
        borderPaint);

    final textPainter = TextPainter(
        text: const TextSpan(text: '⚔️', style: TextStyle(fontSize: 24)),
        textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset((size.x - textPainter.width) / 2,
            (size.y - textPainter.height) / 2));
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    if (isCollected) return;

    if (other is Player) {
      isCollected = true;
      onCollected?.call();
      removeFromParent();
    }
  }
}
