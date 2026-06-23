import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class GameHud extends Component with HasGameRef {
  final Function(Vector2) onJoystickUpdate;
  final VoidCallback onJumpPressed;

  late JoystickComponent joystick;
  late ButtonComponent jumpButton;

  GameHud({required this.onJoystickUpdate, required this.onJumpPressed});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ✅ JOYSTICK (Kiri Bawah) - Syntax Flame Terbaru
    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 30,
        paint: Paint()..color = Colors.amber.withOpacity(0.9),
      ),
      background: CircleComponent(
        radius: 70,
        paint: Paint()..color = Colors.white.withOpacity(0.3),
      ),
      margin: const EdgeInsets.only(left: 60, bottom: 60),
    );
    add(joystick);

    // ✅ TOMBOL LOMPAT (Kanan Bawah)
    jumpButton = ButtonComponent(
      button: CircleComponent(
        radius: 45,
        paint: Paint()..color = Colors.amber.withOpacity(0.9),
      ),
      buttonDown: CircleComponent(
        radius: 45,
        paint: Paint()..color = Colors.orange.withOpacity(0.9),
      ),
      position: Vector2(gameRef.size.x - 105, gameRef.size.y - 105),
      anchor: Anchor.center,
      onPressed: onJumpPressed,
    );

    // Icon panah di tombol
    jumpButton.add(
      TextComponent(
        text: '▲',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
      ),
    );
    add(jumpButton);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // ✅ Kirim delta joystick ke player (sesuai tutorial Gemini)
    if (!joystick.delta.isZero()) {
      onJoystickUpdate(joystick.delta);
    } else {
      onJoystickUpdate(Vector2.zero());
    }
  }
}
