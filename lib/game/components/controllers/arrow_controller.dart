import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class ArrowController extends Component with HasGameRef {
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

    // 1. TOMBOL KIRI
    leftButton = ButtonComponent(
      button: CircleComponent(
        radius: 60,
        paint: Paint()..color = Colors.blue.withOpacity(0.8),
      ),
      buttonDown: CircleComponent(
        radius: 60,
        paint: Paint()..color = Colors.blue,
      ),
      position: Vector2(120, 600),
      anchor: Anchor.center,
      onPressed: () {
        _isLeftPressed = true;
        _isRightPressed = false;
      },
      onReleased: () => _isLeftPressed = false,
    );

    leftButton.add(
      PolygonComponent([
        Vector2(78, 38),
        Vector2(78, 88),
        Vector2(41, 63),
      ], paint: Paint()..color = Colors.black.withOpacity(0.4)),
    );
    leftButton.add(
      PolygonComponent([
        Vector2(75, 35),
        Vector2(75, 85),
        Vector2(38, 60),
      ], paint: Paint()..color = Colors.white),
    );
    add(leftButton);

    // 2. TOMBOL KANAN
    rightButton = ButtonComponent(
      button: CircleComponent(
        radius: 60,
        paint: Paint()..color = Colors.blue.withOpacity(0.8),
      ),
      buttonDown: CircleComponent(
        radius: 60,
        paint: Paint()..color = Colors.blue,
      ),
      position: Vector2(280, 600),
      anchor: Anchor.center,
      onPressed: () {
        _isRightPressed = true;
        _isLeftPressed = false;
      },
      onReleased: () => _isRightPressed = false,
    );

    rightButton.add(
      PolygonComponent([
        Vector2(48, 38),
        Vector2(48, 88),
        Vector2(85, 63),
      ], paint: Paint()..color = Colors.black.withOpacity(0.4)),
    );
    rightButton.add(
      PolygonComponent([
        Vector2(45, 35),
        Vector2(45, 85),
        Vector2(82, 60),
      ], paint: Paint()..color = Colors.white),
    );
    add(rightButton);

    // 3. TOMBOL LOMPAT (Lingkaran Kuning + Segitiga Hitam)
    jumpButton = ButtonComponent(
      button: CircleComponent(
        radius: 60,
        paint: Paint()..color = Colors.amber.withOpacity(0.9),
      ),
      buttonDown: CircleComponent(
        radius: 60,
        paint: Paint()..color = Colors.orange.withOpacity(0.9),
      ),
      position: Vector2(1160, 600),
      anchor: Anchor.center,
      onPressed: onJumpPressed,
    );

    // ✅ UBAH: Bayangan dihapus, Segitiga langsung Hitam Legam!
    jumpButton.add(
      PolygonComponent([
        Vector2(60, 32),
        Vector2(35, 78),
        Vector2(85, 78),
      ], paint: Paint()..color = Colors.black),
    );
    add(jumpButton);
  }

  @override
  void update(double dt) {
    super.update(dt);
    Vector2 simulatedDelta = Vector2.zero();
    if (_isLeftPressed && !_isRightPressed)
      simulatedDelta = Vector2(-70, 0);
    else if (_isRightPressed && !_isLeftPressed)
      simulatedDelta = Vector2(70, 0);
    onJoystickUpdate(simulatedDelta);
  }
}
