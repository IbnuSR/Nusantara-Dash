import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

class WeaponItem extends SpriteComponent with HasGameRef {
  final String weaponId;
  final String weaponName;
  final String islandOrigin;
  bool isCollected = false;
  final VoidCallback? onCollected;

  WeaponItem({
    required this.weaponId,
    required this.weaponName,
    required this.islandOrigin,
    required Sprite sprite,
    required Vector2 position,
    this.onCollected,
  }) : super(
          sprite: sprite,
          position: position,
          size: Vector2(48, 48),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      RectangleHitbox(
        size: Vector2(40, 40),
        position: Vector2(4, 4),
        collisionType: CollisionType.passive,
      ),
    );
  }

  void collect() {
    if (isCollected) return;
    isCollected = true;
    onCollected?.call();
    removeFromParent();
  }
}
