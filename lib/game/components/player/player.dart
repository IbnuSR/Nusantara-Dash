import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class Player extends SpriteAnimationComponent with HasGameRef {
  double speed = 200;
  bool isMoving = false;
  bool isJumping = false;
  double jumpVelocity = 0;
  final double gravity = 800;
  final double jumpHeight = -300;

  // ✅ TERIMA PARAMETER SIZE DARI LUAR
  Player({super.size});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadWalkAnimation();
  }

  Future<void> _loadWalkAnimation() async {
    try {
      final spriteSheet = await gameRef.images.load('player/satria_run.png');
      
      animation = SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.15,
          // ⚠️ SESUAIKAN dengan ukuran hasil crop kamu
          // Kalau belum crop: pakai Vector2(126, 661)
          // Kalau sudah crop (misal 375x300): pakai Vector2(125, 300)
          textureSize: Vector2(125, 300),
          amountPerRow: 3,
        ),
      );
      
      animation?.loop = true;
      debugPrint('✅ Player animation loaded successfully');
    } catch (e) {
      debugPrint('❌ Error loading player animation: $e');
    }
  }

  void jump() {
    if (!isJumping) {
      isJumping = true;
      jumpVelocity = jumpHeight;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isJumping) {
      position.y += jumpVelocity * dt;
      jumpVelocity += gravity * dt;

      // Ground collision
      if (position.y >= 230) {
        position.y = 230;
        isJumping = false;
        jumpVelocity = 0;
      }
    }

    if (isMoving) {
      position.x += speed * dt;
    }
  }
}