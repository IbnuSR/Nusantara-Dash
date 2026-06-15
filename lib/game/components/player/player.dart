import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Player extends SpriteAnimationComponent
    with HasGameRef, CollisionCallbacks {
  final double groundY;
  late JoystickComponent joystick;

  // ✅ SPEED DIPERCEPAT (400 = cepat tapi terkontrol)
  double speed = 400;
  double jumpVelocity = 0;
  bool _isOnGround = false;

  final double gravity = 2000;
  final double jumpStrength = -700;

  Player({required super.size, required this.groundY});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadAnimation();
    // ✅ HITBOX WAJIB untuk collision
    add(RectangleHitbox());
  }

  Future<void> _loadAnimation() async {
    try {
      final spriteSheet = await gameRef.images.load('player/satria_run.png');
      animation = SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.12,
          textureSize: Vector2(125, 300),
          amountPerRow: 3,
        ),
      );
      animation?.loop = true;
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void jump() {
    if (_isOnGround) {
      jumpVelocity = jumpStrength;
      _isOnGround = false;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.paused) return;

    // ✅ INPUT LANGSUNG dari joystick (tanpa normalisasi ribet)
    double input = joystick.delta.x;

    // Deadzone kecil
    if (input.abs() > 10) {
      // Normalisasi sederhana: max delta biasanya 70px
      double normalizedInput = (input / 70.0).clamp(-1.0, 1.0);
      position.x += normalizedInput * speed * dt;
      scale = Vector2(normalizedInput > 0 ? 1 : -1, 1);
    }

    // ✅ GRAVITY & JUMP
    if (!_isOnGround) {
      jumpVelocity += gravity * dt;
      position.y += jumpVelocity * dt;
    }

    // ✅ GROUND DETECTION
    if (position.y >= groundY - size.y) {
      position.y = groundY - size.y;
      jumpVelocity = 0;
      _isOnGround = true;
    }

    // Respawn kalau jatuh
    if (position.y > groundY + 500) {
      position.setValues(200, groundY - size.y);
      jumpVelocity = 0;
      _isOnGround = false;
    }
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);

    // ✅ COLLISION DENGAN PLATFORM
    if (other is RectangleComponent && jumpVelocity > 0) {
      double playerBottom = position.y + size.y;
      double platformTop = other.position.y;

      // Cek apakah player jatuh KE ATAS platform
      if (playerBottom >= platformTop - 10 &&
          playerBottom <= platformTop + 30 &&
          position.y + size.y / 2 < platformTop) {
        position.y = platformTop - size.y;
        jumpVelocity = 0;
        _isOnGround = true;
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    // Jangan langsung set false, biarkan gravity yang handle
  }

  @override
  void render(Canvas canvas) {
    if (animation == null) return;

    double input = joystick.delta.x.abs();
    bool moving = input > 10;

    if (moving || !_isOnGround) {
      super.render(canvas);
    } else {
      animation!.frames.first.sprite.render(
        canvas,
        position: Vector2.zero(),
        size: size,
      );
    }
  }
}
