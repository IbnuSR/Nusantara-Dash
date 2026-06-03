import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/camera.dart';

class NusantaraDashGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set viewport dengan named parameter
    camera.viewport = FixedResolutionViewport(resolution: Vector2(800, 450));

    // Tambah ground (tanah)
    add(
      RectangleComponent(
        position: Vector2(0, 400),
        size: Vector2(800, 50),
        paint: Paint()..color = Colors.brown[400]!,
      ),
    );
  }
}
