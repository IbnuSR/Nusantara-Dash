import 'package:flame/flame.dart';
import 'package:flutter/material.dart' hide Image;
import 'dart:ui' as ui;

class AssetLoader {
  /// Load image dengan mencoba ekstensi .png dulu, lalu .jpg
  static Future<ui.Image> loadImage(String path) async {
    // Coba PNG dulu
    try {
      final pngPath = path.endsWith('.png') ? path : '$path.png';
      return await Flame.images.load(pngPath);
    } catch (e) {
      // Kalau PNG gagal, coba JPG
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

  /// Load sprite animation dengan support JPG/PNG
  static Future<ui.Image> loadSprite(String filename) async {
    return await loadImage('assets/images/$filename');
  }

  /// Cek apakah file exists (untuk debug)
  static Future<bool> fileExists(String path) async {
    try {
      await Flame.images.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load image dengan filter untuk pixel art (tidak blur)
  static Future<ui.Image> loadPixelArtImage(String path) async {
    final image = await loadImage(path);
    // If needed, set pixel-art-specific filtering here.
    // Note: setting filter mode depends on the Image implementation/version.
    return image;
  }
}
