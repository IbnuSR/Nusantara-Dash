import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class ArrowController extends Component with HasGameRef {
  final Function(Vector2) onJoystickUpdate;
  final VoidCallback onJumpPressed;

  late ButtonComponent leftButton;
  late ButtonComponent rightButton;
  late ButtonComponent jumpButton;

  // ✅ State internal untuk simulasi joystick delta
  bool _isLeftPressed = false;
  bool _isRightPressed = false;

  ArrowController({
    required this.onJoystickUpdate,
    required this.onJumpPressed,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ✅ TOMBOL KIRI (Kiri Bawah)
    leftButton = ButtonComponent(
      button: CircleComponent(
        radius: 45,
        paint: Paint()..color = Colors.blue.withOpacity(0.8),
      ),
      buttonDown: CircleComponent(
        radius: 45,
        paint: Paint()..color = Colors.blue,
      ),
      position: Vector2(80, gameRef.size.y - 105),
      anchor: Anchor.center,
      onPressed: () {
        _isLeftPressed = true;
        _isRightPressed = false;
      },
      onReleased: () {
        _isLeftPressed = false;
      },
    );

    leftButton.add(
      TextComponent(
        text: '◀',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
      ),
    );
    add(leftButton);

    // ✅ TOMBOL KANAN (Kiri Bawah, di samping kiri)
    rightButton = ButtonComponent(
      button: CircleComponent(
        radius: 45,
        paint: Paint()..color = Colors.blue.withOpacity(0.8),
      ),
      buttonDown: CircleComponent(
        radius: 45,
        paint: Paint()..color = Colors.blue,
      ),
      position: Vector2(200, gameRef.size.y - 105),
      anchor: Anchor.center,
      onPressed: () {
        _isRightPressed = true;
        _isLeftPressed = false;
      },
      onReleased: () {
        _isRightPressed = false;
      },
    );

    rightButton.add(
      TextComponent(
        text: '▶',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
      ),
    );
    add(rightButton);

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

    // ✅ Simulasi joystick delta dari tombol panah
    // Nilai -70 / 70 (sama dengan max delta joystick) supaya kompatibel dengan player.dart
    Vector2 simulatedDelta = Vector2.zero();

    if (_isLeftPressed && !_isRightPressed) {
      simulatedDelta = Vector2(-70, 0); // Kiri full
    } else if (_isRightPressed && !_isLeftPressed) {
      simulatedDelta = Vector2(70, 0); // Kanan full
    }
    // Kalau kedua tombol ditekan bersamaan → diam (Vector2.zero())

    onJoystickUpdate(simulatedDelta);
  }
}
