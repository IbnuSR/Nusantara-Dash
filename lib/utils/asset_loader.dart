import 'package:flame/flame.dart';
import 'dart:ui' as ui;

class AssetLoader {
  /// Load image dengan mencoba ekstensi .png dulu, lalu .jpg
  static Future<ui.Image> loadImage(String path) async {
    try {
      final pngPath = path.endsWith('.png') ? path : '$path.png';
      return await Flame.images.load(pngPath);
    } catch (e) {
      try {
        final jpgPath = path.endsWith('.jpg') || path.endsWith('.jpeg')
            ? path
            : '$path.jpg';
        return await Flame.images.load(jpgPath);
      } catch (e2) {
        throw Exception(
          'Failed to load image: $path (neither PNG nor JPG found)',
        );
      }
    }
  }

  /// ✅ PERBAIKAN: Hapus awalan 'assets/images/'
  static Future<ui.Image> loadSprite(String filename) async {
    return await loadImage(filename);
  }

  static Future<bool> fileExists(String path) async {
    try {
      await Flame.images.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<ui.Image> loadPixelArtImage(String path) async {
    final image = await loadImage(path);
    return image;
  }
}
