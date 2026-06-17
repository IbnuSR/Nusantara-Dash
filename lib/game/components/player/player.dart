import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Player extends SpriteAnimationComponent
    with HasGameRef, CollisionCallbacks {
  final double groundY;
  late JoystickComponent joystick;

  double speed = 400;
  double jumpVelocity = 0;
  bool _isOnGround = false;

  final double gravity = 2000;
  final double jumpStrength = -700;

  // ✅ Jumlah frame yang BENAR sesuai sprite sheet (14, bukan 16)
  static const int totalFrames = 14;

  Player({required super.size, required this.groundY});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadAnimation();
    add(RectangleHitbox());
  }

  Future<void> _loadAnimation() async {
    try {
      final spriteSheetImage = await gameRef.images.load(
        'player/satria_run.png',
      );

      // ✅ KUNCI PERBAIKAN:
      // Hitung ukuran per frame OTOMATIS dari ukuran gambar asli,
      // bukan dari angka hardcode (96x128) yang bisa salah kalau
      // file gambar diganti/diresize.
      final double frameWidth = spriteSheetImage.width / totalFrames;
      final double frameHeight = spriteSheetImage.height.toDouble();

      animation = SpriteAnimation.fromFrameData(
        spriteSheetImage,
        SpriteAnimationData.sequenced(
          amount: totalFrames,
          stepTime: 0.2, // sedikit lebih cepat agar gerak terlihat mulus
          textureSize: Vector2(frameWidth, frameHeight),
          amountPerRow: totalFrames,
        ),
      );
      animation?.loop = true;
    } catch (e) {
      debugPrint('Error loading animation: $e');
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

    double input = joystick.delta.x;

    if (input.abs() > 10) {
      double normalizedInput = (input / 70.0).clamp(-1.0, 1.0);
      position.x += normalizedInput * speed * dt;
      scale = Vector2(normalizedInput > 0 ? 1 : -1, 1);
    }

    if (!_isOnGround) {
      jumpVelocity += gravity * dt;
      position.y += jumpVelocity * dt;
    }

    if (position.y >= groundY - size.y) {
      position.y = groundY - size.y;
      jumpVelocity = 0;
      _isOnGround = true;
    }

    if (position.y > groundY + 500) {
      position.setValues(200, groundY - size.y);
      jumpVelocity = 0;
      _isOnGround = false;
    }
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);

    if (other is RectangleComponent && jumpVelocity > 0) {
      double playerBottom = position.y + size.y;
      double platformTop = other.position.y;

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
