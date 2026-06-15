import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Player extends SpriteAnimationComponent with HasGameRef {
  final double groundY;
  final JoystickComponent joystick;

  double speed = 150;
  bool isJumping = false;
  double jumpVelocity = 0;
  bool _isMoving = false;

  final double gravity = 1000;
  final double jumpHeight = -500;

  Player({required super.size, required this.groundY, required this.joystick});

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

    if (gameRef.paused) return;

    final moveDirection = joystick.delta.x;
    _isMoving = moveDirection.abs() > 0.1;

    if (_isMoving) {
      final normalizedSpeed = moveDirection.clamp(-1.0, 1.0) * speed;
      position.x += normalizedSpeed * dt;

      // ✅ FLIP dengan scale (otomatis diterapkan saat render)
      if (moveDirection > 0) {
        scale = Vector2(1, 1); // Hadap kanan
      } else if (moveDirection < 0) {
        scale = Vector2(-1, 1); // Hadap kiri
      }
    }

    // Batas layar
    if (position.x < 0) position.x = 0;
    if (position.x > gameRef.size.x - size.x) {
      position.x = gameRef.size.x - size.x;
    }

    // Jump Physics
    if (isJumping) {
      position.y += jumpVelocity * dt;
      jumpVelocity += gravity * dt;

      if (position.y >= groundY - size.y) {
        position.y = groundY - size.y;
        isJumping = false;
        jumpVelocity = 0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (animation == null) return;

    if (_isMoving || isJumping) {
      // ✅ Animation play - scale otomatis handle flip
      super.render(canvas);
    } else {
      // ✅ Idle - render frame pertama
      // Scale otomatis diterapkan, tidak perlu flipHorizontally
      final firstFrame = animation!.frames.first;
      firstFrame.sprite.render(
        canvas,
        position: Vector2.zero(),
        size: size,
        // ✅ TIDAK ADA flipHorizontally
      );
    }
  }
}
