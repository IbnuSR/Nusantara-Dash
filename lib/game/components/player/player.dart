import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../level_builder.dart'; // ✅ Path pasti ke folder provinces

class Player extends SpriteAnimationComponent
    with HasGameRef, CollisionCallbacks {
  final double groundY;
  final VoidCallback onCoinCollected;
  final VoidCallback onPlayerDied;

  // ✅ SOLUSI KUNCI: Variabel umum yang bisa menerima perintah dari Joystick Analog maupun Tombol Panah
  Vector2 currentInputDelta = Vector2.zero();

  double speed = 400;
  double jumpVelocity = 0;
  bool _isOnGround = false;
  bool isDead = false;

  final double gravity = 2000;
  final double jumpStrength = -700;

  static const int totalFrames = 14;

  Player({
    required super.size,
    required this.groundY,
    required this.onCoinCollected,
    required this.onPlayerDied,
  });

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
      final double frameWidth = spriteSheetImage.width / totalFrames;
      final double frameHeight = spriteSheetImage.height.toDouble();

      animation = SpriteAnimation.fromFrameData(
        spriteSheetImage,
        SpriteAnimationData.sequenced(
          amount: totalFrames,
          stepTime: 0.1,
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
    if (_isOnGround && !isDead) {
      jumpVelocity = jumpStrength;
      _isOnGround = false;
    }
  }

  void die() {
    if (isDead) return;
    isDead = true;
    onPlayerDied();
  }

  void respawn() {
    isDead = false;
    position.setValues(100, groundY - size.y - 20);
    jumpVelocity = 0;
    _isOnGround = false;
    currentInputDelta = Vector2.zero(); // Reset gerak saat hidup kembali
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.paused || isDead) return;

    // ✅ MEMBACA NILAI GERAK DARI SUPIR MANAPUN YANG SEDANG AKTIF (Analog / Panah)
    double input = currentInputDelta.x;

    if (input.abs() > 10) {
      double normalizedInput = (input / 70.0).clamp(-1.0, 1.0);
      position.x += normalizedInput * speed * dt;
      scale = Vector2(normalizedInput > 0 ? 1 : -1, 1);
    }

    if (!_isOnGround) {
      jumpVelocity += gravity * dt;
      position.y += jumpVelocity * dt;
    }

    if (position.y > 800) {
      die();
    }
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    if (isDead) return;

    if (other is CoinItem) {
      if (!other.isCollected) {
        other.isCollected = true;
        other.removeFromParent();
        onCoinCollected();
      }
      return;
    }

    if (other is RedObstacle) {
      die();
      return;
    }

    if (other is GroundPlatform) {
      double playerBottom = position.y + size.y;
      double playerRight = position.x + size.x;
      double platformTop = other.position.y;
      double platformLeft = other.position.x;
      double platformRight = other.position.x + other.size.x;

      if (jumpVelocity >= 0 &&
          playerBottom >= platformTop - 15 &&
          playerBottom <= platformTop + 30 &&
          position.y + size.y / 2 < platformTop) {
        position.y = platformTop - size.y + 0.1;
        jumpVelocity = 0;
        _isOnGround = true;
      } else if (playerBottom > platformTop + 10) {
        if (position.x < platformLeft && playerRight > platformLeft) {
          position.x = platformLeft - size.x;
        } else if (position.x > platformLeft && position.x < platformRight) {
          position.x = platformRight;
        }
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is GroundPlatform) {
      _isOnGround = false;
    }
  }

  @override
  void render(Canvas canvas) {
    if (animation == null) return;

    double input = currentInputDelta.x.abs();
    bool moving = input > 10;

    if ((moving || !_isOnGround) && !isDead) {
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
