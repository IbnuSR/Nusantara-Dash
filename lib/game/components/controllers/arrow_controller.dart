import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

// 🔥 IMPORT KELAS GAME UTAMA
import '../../nusantara_dash_game.dart';

class ArrowController extends PositionComponent
    with HasGameRef<NusantaraDashGame> {
  final Function(Vector2) onJoystickUpdate;
  final VoidCallback onJumpPressed;

  late ButtonComponent leftButton;
  late ButtonComponent rightButton;
  late ButtonComponent jumpButton;

  bool _isLeftPressed = false;
  bool _isRightPressed = false;

  ArrowController({
    required this.onJoystickUpdate,
    required this.onJumpPressed,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 🔥 KUNCI MUTLAK: Ambil ukuran pasti dari variabel di NusantaraDashGame!
    final gameWidth = gameRef.dynamicWidth;
    final gameHeight = NusantaraDashGame.virtualHeight; // Pasti 720

    size = Vector2(gameWidth, gameHeight);
    position = Vector2.zero();

    // 1. 🔥 TOMBOL KIRI (◄)
    final leftBtnNormal = CircleComponent(
      radius: 45,
      paint: Paint()..color = const Color(0x66FFB300),
      children: [
        CircleComponent(
            radius: 45,
            paint: Paint()
              ..color = const Color(0xFFFFD700)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.5)
      ],
    );
    leftBtnNormal.add(PolygonComponent(
        [Vector2(45, 25), Vector2(45, 65), Vector2(20, 45)],
        paint: Paint()..color = const Color(0xFF1A0000)));

    leftButton = ButtonComponent(
      button: leftBtnNormal,
      buttonDown: CircleComponent(
          radius: 43, paint: Paint()..color = const Color(0xAAFF8F00)),
      anchor: Anchor.center,
      // 🔥 Paku di Kiri Bawah
      position: Vector2(120, gameHeight - 120),
      onPressed: () => _isLeftPressed = true,
      onReleased: () => _isLeftPressed = false,
    );
    add(leftButton);

    // 2. 🔥 TOMBOL KANAN (►)
    final rightBtnNormal = CircleComponent(
      radius: 45,
      paint: Paint()..color = const Color(0x66FFB300),
      children: [
        CircleComponent(
            radius: 45,
            paint: Paint()
              ..color = const Color(0xFFFFD700)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.5)
      ],
    );
    rightBtnNormal.add(PolygonComponent(
        [Vector2(45, 25), Vector2(45, 65), Vector2(70, 45)],
        paint: Paint()..color = const Color(0xFF1A0000)));

    rightButton = ButtonComponent(
      button: rightBtnNormal,
      buttonDown: CircleComponent(
          radius: 43, paint: Paint()..color = const Color(0xAAFF8F00)),
      anchor: Anchor.center,
      // 🔥 Paku di Sebelah Kiri Bawah
      position: Vector2(250, gameHeight - 120),
      onPressed: () => _isRightPressed = true,
      onReleased: () => _isRightPressed = false,
    );
    add(rightButton);

    // 3. 🔥 TOMBOL LOMPAT (▲)
    final jumpBtnNormal = CircleComponent(
      radius: 50,
      paint: Paint()..color = const Color(0x66FFB300),
      children: [
        CircleComponent(
            radius: 50,
            paint: Paint()
              ..color = const Color(0xFFFFD700)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.5)
      ],
    );
    jumpBtnNormal.add(PolygonComponent(
        [Vector2(50, 22), Vector2(28, 58), Vector2(72, 58)],
        paint: Paint()..color = const Color(0xFF1A0000)));

    jumpButton = ButtonComponent(
      button: jumpBtnNormal,
      buttonDown: CircleComponent(
          radius: 48, paint: Paint()..color = const Color(0xAAFF8F00)),
      anchor: Anchor.center,
      // 🔥 Paku di Kanan Bawah menggunakan Lebar Dinamis
      position: Vector2(gameWidth - 120, gameHeight - 120),
      onPressed: onJumpPressed,
    );
    add(jumpButton);
  }

  @override
  void update(double dt) {
    super.update(dt);
    Vector2 simulatedDelta = Vector2.zero();
    if (_isLeftPressed && !_isRightPressed) {
      simulatedDelta = Vector2(-70, 0);
    } else if (_isRightPressed && !_isLeftPressed) {
      simulatedDelta = Vector2(70, 0);
    }
    onJoystickUpdate(simulatedDelta);
  }
}
