import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/camera.dart';

class NusantaraDashGame extends FlameGame {
  // Parameter pulau yang dipilih dari MapScreen
  final String islandName;

  // Warna tema per pulau (untuk ground & sky)
  final Map<String, Color> islandThemes = {
    'SUMATRA': const Color(0xFF2E7D32), // Hijau hutan
    'JAWA': const Color(0xFFE65100), // Oranye vulkanik
    'KALIMANTAN': const Color(0xFF1B5E20), // Hijau tua hutan
    'SULAWESI': const Color(0xFF0277BD), // Biru laut
    'PAPUA': const Color(0xFF4E342E), // Coklat pegunungan
  };

  NusantaraDashGame({required this.islandName});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set viewport
    camera.viewport = FixedResolutionViewport(resolution: Vector2(800, 450));

    // 1. Load Background (coba PNG dulu, lalu JPG)
    await _loadBackground();

    // 2. Tambah Ground (warna sesuai tema pulau)
    final groundColor = islandThemes[islandName] ?? Colors.brown;
    add(
      RectangleComponent(
        position: Vector2(0, 400),
        size: Vector2(800, 50),
        paint: Paint()..color = groundColor,
      ),
    );

    // 3. Placeholder Player (Satria) - Kotak Merah
    // Nanti diganti dengan sprite pixel art
    add(
      RectangleComponent(
        position: Vector2(100, 340),
        size: Vector2(40, 60),
        paint: Paint()..color = Colors.red,
      )..add(
        TextComponent(
          text: 'SATRIA',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        )..position = Vector2(0, -15),
      ),
    );

    // 4. Placeholder Mini Boss - Kotak Ungu (di belakang player)
    add(
      RectangleComponent(
        position: Vector2(-150, 320),
        size: Vector2(80, 100),
        paint: Paint()..color = Colors.purple[900]!,
      )..add(
        TextComponent(
          text: 'BOSS',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        )..position = Vector2(15, -15),
      ),
    );

    // 5. Info Pulau (di pojok kiri atas)
    add(
      TextComponent(
        text: '🏝️ $islandName',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
      )..position = Vector2(20, 20),
    );
  }

  /// Load background image dari folder sesuai pulau
  /// Support JPG dan PNG (coba PNG dulu, kalau gagal coba JPG)
  Future<void> _loadBackground() async {
    final islandLower = islandName.toLowerCase();
    final possiblePaths = [
      'assets/images/background/bg_$islandLower.png',
      'assets/images/background/bg_$islandLower.jpg',
      'assets/images/background/bg_$islandLower.jpeg',
    ];

    for (final path in possiblePaths) {
      try {
        final image = await images.load(path);
        // Tambahkan background sebagai SpriteComponent
        add(
          SpriteComponent(
            sprite: Sprite(image),
            size: Vector2(800, 450),
            position: Vector2(0, 0),
          )..priority = -10, // Di belakang semua komponen
        );
        debugPrint('✅ Background loaded: $path');
        return; // Berhasil, keluar dari loop
      } catch (e) {
        // Coba path berikutnya
        continue;
      }
    }

    // Jika semua gagal, pakai gradient warna sebagai fallback
    debugPrint('⚠️ Background tidak ditemukan, pakai gradient fallback');
    // Add fallback sky rectangle
    add(
      RectangleComponent(
        size: Vector2(800, 450),
        paint: Paint()..color = _getSkyColor(),
      )..priority = -20,
    );
  }

  /// Warna langit fallback jika background tidak ada
  Color _getSkyColor() {
    switch (islandName) {
      case 'SUMATRA':
        return const Color(0xFF81D4FA); // Biru muda
      case 'JAWA':
        return const Color(0xFFFFCC80); // Oranye pagi
      case 'KALIMANTAN':
        return const Color(0xFFA5D6A7); // Hijau muda
      case 'SULAWESI':
        return const Color(0xFF4FC3F7); // Biru laut
      case 'PAPUA':
        return const Color(0xFFB0BEC5); // Abu-abu berkabut
      default:
        return Colors.blue[300]!;
    }
  }
}
