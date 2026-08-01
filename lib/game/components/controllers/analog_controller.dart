import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 🔥 IMPORT KELAS GAME UTAMA UNTUK MENGAMBIL DYNAMIC WIDTH
import '../../nusantara_dash_game.dart';

class AnalogController extends PositionComponent
    with HasGameRef<NusantaraDashGame> {
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

    // 🔥 KUNCI MUTLAK: Ambil ukuran pasti dari variabel di NusantaraDashGame!
    final gameWidth = gameRef.dynamicWidth;
    final gameHeight = NusantaraDashGame.virtualHeight; // Pasti 720

    size = Vector2(gameWidth, gameHeight);
    position = Vector2.zero();

    // 1. 🔥 JOYSTICK ANALOG
    final knobPaint = Paint()..color = const Color(0xFFFFB300);
    final knobBorderPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final bgPaint = Paint()..color = const Color(0x77000000);
    final bgBorderPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 35,
        paint: knobPaint,
        children: [CircleComponent(radius: 35, paint: knobBorderPaint)],
      ),
      background: CircleComponent(
        radius: 80,
        paint: bgPaint,
        children: [CircleComponent(radius: 80, paint: bgBorderPaint)],
      ),
      // 🔥 Paku posisi joystick di kiri bawah menggunakan koordinat pasti!
      position: Vector2(140, gameHeight - 120),
    );
    add(joystick);

    // 2. 🔥 TOMBOL LOMPAT KAYU
    PositionComponent jumpNormalSprite;
    PositionComponent jumpDownSprite;

    try {
      final woodImage = await Flame.images.load('battle/ui_wood_btn.png');
      jumpNormalSprite =
          SpriteComponent(sprite: Sprite(woodImage), size: Vector2(100, 100));
      jumpDownSprite =
          SpriteComponent(sprite: Sprite(woodImage), size: Vector2(92, 92));
    } catch (_) {
      jumpNormalSprite = CircleComponent(
          radius: 50, paint: Paint()..color = Colors.brown[700]!);
      jumpDownSprite = CircleComponent(
          radius: 46, paint: Paint()..color = Colors.brown[900]!);
    }

    jumpNormalSprite.add(TextComponent(
      text: '▲',
      textRenderer: TextPaint(
        style: GoogleFonts.pressStart2p(
          color: const Color(0xFFFFD700),
          fontSize: 28,
          shadows: [
            const Shadow(color: Colors.black, offset: Offset(3, 3)),
            const Shadow(color: Colors.black, offset: Offset(-1, -1)),
          ],
        ),
      ),
      position: Vector2(50, 52),
      anchor: Anchor.center,
    ));

    jumpButton = ButtonComponent(
      button: jumpNormalSprite,
      buttonDown: jumpDownSprite,
      // 🔥 Paku posisi tombol lompat di kanan bawah menggunakan dynamicWidth!
      position: Vector2(gameWidth - 120, gameHeight - 120),
      anchor: Anchor.center,
      onPressed: onJumpPressed,
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
