import 'dart:ui';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/input.dart';

import 'components/player/player.dart';
import 'components/level_builder.dart';
import 'components/controllers/analog_controller.dart';
import 'components/controllers/arrow_controller.dart';

// ✅ IMPORT DATA LEVEL PULAU
import 'data/sumatra_level_data.dart';
import 'data/jawa_level_data.dart';
import 'data/kalimantan_level_data.dart';
import 'data/sulawesi_level_data.dart';
import 'data/papua_level_data.dart';

import 'package:nusantara_dash/utils/game_prefs.dart';
import 'package:nusantara_dash/utils/audio_manager.dart';
import 'package:nusantara_dash/game/data/museum_item_model.dart';
import 'package:nusantara_dash/game/managers/museum_gameplay_bridge.dart';

// ✅ IMPORT WEAPON SYSTEM
import 'package:nusantara_dash/game/features/weapons/weapon_manager.dart';
import 'package:nusantara_dash/game/features/weapons/weapon_data.dart';

class NusantaraDashGame extends FlameGame
    with KeyboardEvents, HasCollisionDetection {
  final String islandName;
  final VoidCallback onGameOver;
  final VoidCallback onLevelComplete;
  final Function(int) onCoinsUpdated;
  final VoidCallback onBossEncounter;
  final VoidCallback onPlayerDied;
  final void Function(CulturalItem item)? onCulturalItemUnlocked;
  final void Function(String weaponId, String weaponName)? onWeaponCollected;

  late Player player;
  late double groundY;

  late double dynamicWidth;

  int collectedCoins = 0;
  int totalWalletCoins = 0;
  int currentLives = 3;

  bool isLevelFinished = false;
  bool _hasEnteredBossZone = false;
  bool _hasDefeatedBoss = false;

  static const double virtualWidth = 1280;
  static const double virtualHeight = 720;
  static const double cameraZoom = 1.35;

  NusantaraDashGame({
    required this.islandName,
    required this.onGameOver,
    required this.onLevelComplete,
    required this.onCoinsUpdated,
    required this.onBossEncounter,
    required this.onPlayerDied,
    this.onCulturalItemUnlocked,
    this.onWeaponCollected,
  });

  void updateLives(int lives) {
    currentLives = lives;
  }

  double getLevelLength() {
    switch (islandName.toUpperCase()) {
      case 'JAWA':
        return JawaLevelData.levelLength;
      case 'KALIMANTAN':
        return KalimantanLevelData.levelLength;
      case 'SULAWESI':
        return SulawesiLevelData.levelLength;
      case 'PAPUA':
        return PapuaLevelData.levelLength;
      default:
        return SumatraLevelData.levelLength;
    }
  }

  void resetBossTrigger() {
    _hasEnteredBossZone = false;
    player.position.x = getLevelLength() - 600;
    print('🔄 Boss Zone di-reset! Satria dimundurkan siap lawan bos lagi.');
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final double screenRatio = size.x / size.y;
    dynamicWidth = virtualHeight * screenRatio;

    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(dynamicWidth, virtualHeight),
    );
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2(dynamicWidth / 2, virtualHeight / 2);
    camera.viewfinder.zoom = cameraZoom;

    groundY = virtualHeight * 0.75;
    await _loadBackground();

    String bgmFile = 'audio/bgm/bgm_${islandName.toLowerCase()}.mp3';
    AudioManager.instance.playBGM(bgmFile);

    totalWalletCoins = await GamePrefs.getCoins();
    currentLives = await GamePrefs.getExtraLives();
    _hasDefeatedBoss = await GamePrefs.isBossDefeated(islandName);
    updateLives(currentLives);

    player = Player(
      size: Vector2(64, 96),
      groundY: groundY,
      onCoinCollected: () async {
        collectedCoins += 10;
        totalWalletCoins += 10;
        await GamePrefs.saveCoins(totalWalletCoins);
        onCoinsUpdated(totalWalletCoins); // 🪙 Update koin ke GameScreen
        AudioManager.instance.playSFX('sfx_coin.mp3');
      },
      onPlayerDied: () {
        pauseEngine();
        AudioManager.instance.playSFX('sfx_gameover.mp3');
        onPlayerDied();
      },
      onPlayerLanded: () {
        AudioManager.instance.playSFX('sfx_land.mp3');
      },
    )
      ..position = Vector2(100, groundY - 96)
      ..priority = 100;
    world.add(player);

    world.add(LevelBuilder(
      groundY: groundY,
      islandName: islandName,
      onCulturalItemFound: (itemIdOrProvinceId) {
        MuseumGameplayBridge.unlockItem(itemIdOrProvinceId).then((result) {
          if (result.hasNewItem && result.item != null) {
            pauseEngine();
            onCulturalItemUnlocked?.call(result.item!);
          } else {
            MuseumGameplayBridge.unlockNextItemInIsland(
                    islandName.toLowerCase())
                .then((fallbackResult) {
              if (fallbackResult.hasNewItem && fallbackResult.item != null) {
                pauseEngine();
                onCulturalItemUnlocked?.call(fallbackResult.item!);
              }
            });
          }
        });
      },
      onWeaponCollected: (weaponId, weaponName) async {
        print("🔵 1. Senjata diambil: $weaponName");

        pauseEngine();
        await WeaponManager.addWeapon(weaponId);
        print("🔵 2. Tersimpan ke database");

        final weapon = WeaponData.getWeaponById(weaponId);
        final isCombined = weapon?.isCombined ?? false;
        final description = weapon?.description ??
            'Senjata tradisional yang penuh kekuatan spiritual.';
        final origin = weapon?.origin ?? islandName;

        if (buildContext != null) {
          await showDialog(
            context: buildContext!,
            barrierDismissible: false,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFC107), width: 6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isCombined
                          ? '🏆 SENJATA LEGENDARIS DITEMUKAN!'
                          : '🗡️ SENJATA SUCI DITEMUKAN!',
                      style: const TextStyle(
                          color: Color(0xFFFFC107),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFFFFC107), width: 2),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('📍 $origin',
                          style: const TextStyle(
                              color: Color(0xFFFFC107),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace')),
                    ),
                    const SizedBox(height: 24),
                    Icon(isCombined ? Icons.star : Icons.shield,
                        size: 80, color: const Color(0xFFFFC107)),
                    const SizedBox(height: 16),
                    Text(weaponName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace'),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    Text(description,
                        style: const TextStyle(
                            color: Color(0xFFE0E0E0),
                            fontSize: 14,
                            fontFamily: 'monospace',
                            height: 1.4),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('🏛️ LANJUTKAN',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'monospace')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          print("🔵 3. Dialog ditutup, game dilanjutkan");
          resumeEngine();
        } else {
          print("⚠️ Context tidak tersedia, resume langsung");
          resumeEngine();
        }
      },
    ));

    // Kontrol Analog / Arrow
    String controlType = await GamePrefs.getControlType();
    if (controlType == 'analog') {
      final analog = AnalogController(
        onJoystickUpdate: (delta) => player.currentInputDelta = delta,
        onJumpPressed: () {
          player.jump();
          AudioManager.instance.playSFX('sfx_jump.mp3');
        },
      );
      camera.viewport.add(analog);
    } else {
      final arrow = ArrowController(
        onJoystickUpdate: (delta) => player.currentInputDelta = delta,
        onJumpPressed: () {
          player.jump();
          AudioManager.instance.playSFX('sfx_jump.mp3');
        },
      );
      camera.viewport.add(arrow);
    }

    // ❌ TEKS HUD LAMA (islandText, coinText, livesText) DIHAPUS DARI SINI
    // AGAR TIDAK BENTROK DENGAN UI FLUTTER DI GABUNGAN GAMETEAM/GAMESCREEN.
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (paused) return;

    final targetX = player.position.x + player.size.x / 2;
    final targetY = virtualHeight / 2;

    camera.viewfinder.position = Vector2(
      camera.viewfinder.position.x +
          (targetX - camera.viewfinder.position.x) * 0.1,
      camera.viewfinder.position.y +
          (targetY - camera.viewfinder.position.y) * 0.1,
    );

    final double totalLength = getLevelLength();
    double visibleWorldWidth = dynamicWidth / cameraZoom;
    double minCamX = visibleWorldWidth / 2;
    double maxCamX = totalLength - (visibleWorldWidth / 2);

    if (maxCamX > minCamX) {
      camera.viewfinder.position.x =
          camera.viewfinder.position.x.clamp(minCamX, maxCamX);
    } else {
      camera.viewfinder.position.x = minCamX;
    }

    // 🔥 PRIORITAS 1: BOSS ZONE TRIGGER
    if (player.position.x >= totalLength - 280 &&
        player.position.x < totalLength - 100 &&
        !_hasEnteredBossZone) {
      print('🔥 BOSS ZONE TRIGGERED! Posisi: ${player.position.x.toInt()}');
      _hasEnteredBossZone = true;
      pauseEngine();
      onBossEncounter();
      return;
    }

    // ✅ PRIORITAS 2: Level Complete
    if (player.position.x >= totalLength - 100 && !isLevelFinished) {
      print('✅ LEVEL COMPLETE!');
      isLevelFinished = true;
      pauseEngine();
      AudioManager.instance.playSFX('sfx_level_complete.mp3');
      onLevelComplete();
      return;
    }

    // ⛔ PRIORITAS 3: Access Denied
    if (player.position.x >= totalLength - 50 &&
        !isLevelFinished &&
        !_hasDefeatedBoss) {
      print(
          '⛔ ACCESS DENIED! Player di x=${player.position.x.toInt()} tapi boss belum dikalahkan!');
    }
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      player.jump();
      AudioManager.instance.playSFX('sfx_jump.mp3');
    }
    return KeyEventResult.handled;
  }

  Future<void> _loadBackground() async {
    final paths = [
      'background/bg_${islandName.toLowerCase()}.png',
      'background/bg_${islandName.toLowerCase()}.jpg',
    ];
    for (final p in paths) {
      try {
        final img = await images.load(p);
        camera.backdrop.add(
          SpriteComponent(
            sprite: Sprite(img),
            size: Vector2(dynamicWidth, virtualHeight),
          ),
        );
        return;
      } catch (_) {}
    }
    camera.backdrop.add(
      RectangleComponent(
        size: Vector2(dynamicWidth, virtualHeight),
        paint: Paint()..color = Colors.blue[300]!,
      ),
    );
  }

  @override
  void onRemove() {
    AudioManager.instance.stopBGM();
    super.onRemove();
  }
}
