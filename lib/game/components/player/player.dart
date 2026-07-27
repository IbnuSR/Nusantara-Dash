import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../level_builder.dart';

class Player extends SpriteAnimationComponent
    with HasGameRef, CollisionCallbacks {
  final double groundY;
  final VoidCallback onCoinCollected;
  final VoidCallback onPlayerDied;
  final VoidCallback? onPlayerLanded;

  Vector2 currentInputDelta = Vector2.zero();

  double speed = 400;
  double jumpVelocity = 0;
  bool _isOnGround = false;
  bool _wasInAir = false;
  bool isDead = false;

  final double gravity = 2000;
  final double jumpStrength = -700;
  static const int totalFrames = 14;

  late Vector2 _checkpointPosition;

  Player({
    required super.size,
    required this.groundY,
    required this.onCoinCollected,
    required this.onPlayerDied,
    this.onPlayerLanded,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadAnimation();

    _checkpointPosition = position.clone();

    add(
      RectangleHitbox(
        size: Vector2(28, 96),
        position: Vector2(18, 0),
        collisionType: CollisionType.active,
      ),
    );
  }

  Future<void> _loadAnimation() async {
    try {
      final spriteSheetImage =
          await gameRef.images.load('player/satria_run.png');
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
      _wasInAir = true;
    }
  }

  void die() {
    if (isDead) return;
    isDead = true;
    onPlayerDied();
  }

  // 🔥 PERBAIKAN FINAL: Respawn PERSIS di koordinat x mendarat yang aman (TANPA -120px!)
  // Dijatuhkan ringan dari 10px di atas tanah agar fisika berpijak dengan sempurna.
  void respawn() {
    isDead = false;

    double safeX = _checkpointPosition.x;
    double safeY = _checkpointPosition.y - 10;

    position.setValues(safeX, safeY);
    jumpVelocity = 0;
    _isOnGround = false;
    _wasInAir =
        false; // ✅ PENTING: Jangan anggap sedang lompat agar tidak merusak posisi checkpoint saat mendarat
    currentInputDelta = Vector2.zero();
    debugPrint(
        '✨ Satria bangkit di tanah aman: x=${position.x.toInt()}, y=${position.y.toInt()}');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.paused || isDead) return;

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

    if (position.y > groundY + 150) {
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
      double bodyLeft = position.x + 18;
      double bodyRight = position.x + 46;

      double platformTop = other.position.y;
      double platformLeft = other.position.x;
      double platformRight = other.position.x + other.size.x;

      if (jumpVelocity >= 0 &&
          playerBottom >= platformTop - 20 &&
          playerBottom <= platformTop + 35 &&
          position.y + size.y / 2 < platformTop) {
        position.y = platformTop - size.y + 0.1;
        jumpVelocity = 0;

        if (_wasInAir) {
          onPlayerLanded?.call();
          _wasInAir = false;

          // ✅ Rekam Checkpoint HANYA saat pertama kali mendarat dari udara!
          _checkpointPosition = Vector2(position.x, position.y);
        }
        _isOnGround = true;
      } else if (playerBottom > platformTop + 15) {
        if (bodyLeft < platformLeft && bodyRight > platformLeft) {
          position.x = platformLeft - 46;
        } else if (bodyLeft > platformLeft && bodyLeft < platformRight) {
          position.x = platformRight - 18;
        }
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is GroundPlatform) {
      _isOnGround = false;
      _wasInAir = true;
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
