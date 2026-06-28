import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class AnalogController extends PositionComponent with HasGameRef {
  final Function(Vector2) onJoystickUpdate;
  final VoidCallback onJumpPressed;

  late JoystickComponent joystick;
  late ButtonComponent jumpButton;

  AnalogController({
    required this.onJoystickUpdate,
    required this.onJumpPressed,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = Vector2(1280, 720);
    position = Vector2.zero();

    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 40,
        paint: Paint()..color = Colors.amber.withOpacity(0.9),
      ),
      background: CircleComponent(
        radius: 90,
        paint: Paint()..color = Colors.white.withOpacity(0.3),
      ),
      margin: const EdgeInsets.only(left: 50, bottom: 50),
    );
    add(joystick);

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

    // ✅ UBAH: Segitiga langsung Hitam Legam!
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
    if (!joystick.delta.isZero()) {
      onJoystickUpdate(joystick.delta);
    } else {
      onJoystickUpdate(Vector2.zero());
    }
  }
}
