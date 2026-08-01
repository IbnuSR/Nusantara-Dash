import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

// 🔥 PASTIKAN CLASS INI EXTENDS SpriteComponent, bukan PositionComponent biasa
class Coin extends SpriteComponent with HasGameRef {
  
  Coin({super.position, super.size});

  @override
  Future<void> onLoad() async {
    // 1. 🔥 GANTI LINGKARAN KUNING DENGAN GAMBAR COIN.PNG MILIKMU
    // Ingat: Flame otomatis membaca dari folder 'assets/images/'
    sprite = await gameRef.loadSprite('battle/coin.png');
    
    // 2. Atur ukuran koin agar pas (misal 32x32 pixel)
    if (size.x == 0) {
      size = Vector2(32, 32); 
    }

    // 3. Tambahkan Hitbox agar koin bisa diambil Satria saat disentuh
    add(CircleHitbox(collisionType: CollisionType.passive));
  }
}