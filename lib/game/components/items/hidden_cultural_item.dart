import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Komponen Hidden Cultural Item — Mystery Collectible tersembunyi di level gameplay.
///
/// ## Visual (Mystery Collectible Final)
/// - Pulsing Golden Aura (Denyut cahaya emas)
/// - Golden Sphere/Badge utama dengan border emas terang
/// - Teks retro ikonik "?" di tengah
/// - Floating Sinusoidal Animation (gerakan naik-turun halus ±6px)
/// - Sparkle decorative accents
///
/// ## Tanggung Jawab & Scope
/// - Visual Mystery Collectible (tanpa file image eksternal)
/// - Animasi idle: floating ±6px vertikal dan pulsing glow
/// - State internal: [isCollected] flag anti-duplikat
/// - Lifecycle Flame: [onLoad], [update]
///
/// Semua gameplay logic (collision, audio, unlock) ditambahkan dari luar
/// melalui [onCollected] callback dan [whenCollected].
class HiddenCulturalItemComponent extends PositionComponent
    with CollisionCallbacks {
  // ── Warna Tema Emas (Nusantara Gold) ─────────────────────────────────
  static const Color _goldPrimary = Color(0xFFFFB300);
  static const Color _goldLight = Color(0xFFFFE082);

  /// Radius lingkaran glow. Menentukan ukuran total komponen (diameter = 48px).
  static const double _glowRadius = 24.0;

  /// Radius badge emas utama.
  static const double _badgeRadius = 16.0;

  /// Ukuran hitbox collision (24×24px).
  static const double _hitboxSize = 24.0;

  // ── Konstanta Animasi ────────────────────────────────────────────────
  /// Angular frequency animasi: periode T ~1.67 detik.
  static const double _animOmega = pi * 1.2;

  /// Amplitudo floating vertikal badge (±6px dari posisi tengah).
  static const double _floatAmplitude = 6.0;

  /// Titik tengah opacity glow (range 0.15 - 0.45).
  static const double _opacityMid = 0.30;
  static const double _opacityAmp = 0.15;

  // ── External API ─────────────────────────────────────────────────────
  /// ID provinsi asal item ini.
  final String provinceId;

  /// Callback yang dipanggil saat item berhasil diambil pemain.
  final VoidCallback? onCollected;

  /// Flag anti-duplikat pickup.
  bool isCollected = false;

  // ── State Animasi (Private) ──────────────────────────────────────────
  double _elapsedTime = 0.0;

  // ── Referensi Components & Paints (Re-used untuk Performa 60 FPS) ───
  late CircleComponent _glowCircle;
  late PositionComponent _badgeContainer;
  late TextComponent _questionMarkText;
  late CircleComponent _sparkle1;
  late CircleComponent _sparkle2;

  final Paint _glowPaint = Paint()
    ..color = _goldPrimary.withValues(alpha: _opacityMid);

  final Paint _badgePaint = Paint()..color = _goldPrimary;
  final Paint _badgeInnerPaint = Paint()..color = _goldLight;
  final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5
    ..color = Colors.white;

  final Paint _sparklePaint = Paint()..color = Colors.white;

  // ── Constructor ──────────────────────────────────────────────────────
  HiddenCulturalItemComponent({
    required this.provinceId,
    required Vector2 position,
    this.onCollected,
    int priority = 0,
  }) : super(
          position: position,
          size: Vector2(_glowRadius * 2, _glowRadius * 2),
          anchor: Anchor.center,
          priority: priority,
        );

  // ── Lifecycle ────────────────────────────────────────────────────────
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    const double cx = _glowRadius; // 24.0
    const double cy = _glowRadius; // 24.0

    // ── 1. Pulsing Golden Glow Aura ────────────────────────────────────
    _glowCircle = CircleComponent(
      radius: _glowRadius,
      position: Vector2(cx, cy),
      anchor: Anchor.center,
      paint: _glowPaint,
    );
    add(_glowCircle);

    // ── 2. Badge Container (Batu Emas Mengambang) ──────────────────────
    _badgeContainer = PositionComponent(
      position: Vector2(cx, cy),
      size: Vector2(_badgeRadius * 2, _badgeRadius * 2),
      anchor: Anchor.center,
    );

    // Outer Badge Circle
    _badgeContainer.add(
      CircleComponent(
        radius: _badgeRadius,
        position: Vector2(_badgeRadius, _badgeRadius),
        anchor: Anchor.center,
        paint: _badgePaint,
      ),
    );

    // Inner Shiny Circle
    _badgeContainer.add(
      CircleComponent(
        radius: _badgeRadius - 3.0,
        position: Vector2(_badgeRadius, _badgeRadius),
        anchor: Anchor.center,
        paint: _badgeInnerPaint,
      ),
    );

    // Bright White Gold Border
    _badgeContainer.add(
      CircleComponent(
        radius: _badgeRadius,
        position: Vector2(_badgeRadius, _badgeRadius),
        anchor: Anchor.center,
        paint: _borderPaint,
      ),
    );

    // ── 3. Question Mark Icon (?) Retro Pixel Style ────────────────────
    _questionMarkText = TextComponent(
      text: '?',
      textRenderer: TextPaint(
        style: GoogleFonts.pressStart2p(
          fontSize: 14,
          color: const Color(0xFF3E2723), // Dark mahogany gold accent
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: Colors.white, blurRadius: 2, offset: Offset(0, 0)),
          ],
        ),
      ),
      position: Vector2(_badgeRadius, _badgeRadius + 1.0),
      anchor: Anchor.center,
    );
    _badgeContainer.add(_questionMarkText);

    // ── 4. Sparkle Decorative Accents ─────────────────────────────────
    _sparkle1 = CircleComponent(
      radius: 2.2,
      position: Vector2(_badgeRadius - 10, _badgeRadius - 9),
      anchor: Anchor.center,
      paint: _sparklePaint,
    );
    _sparkle2 = CircleComponent(
      radius: 1.8,
      position: Vector2(_badgeRadius + 10, _badgeRadius + 8),
      anchor: Anchor.center,
      paint: _sparklePaint,
    );
    _badgeContainer.add(_sparkle1);
    _badgeContainer.add(_sparkle2);

    add(_badgeContainer);

    // ── 5. Hitbox (Passive) ────────────────────────────────────────────
    add(
      RectangleHitbox(
        size: Vector2(_hitboxSize, _hitboxSize),
        position: Vector2(cx - _hitboxSize / 2, cy - _hitboxSize / 2),
        collisionType: CollisionType.passive,
      ),
    );
  }

  // ── Game Loop ────────────────────────────────────────────────────────
  @override
  void update(double dt) {
    super.update(dt);

    _elapsedTime += dt;
    final double sinVal = sin(_animOmega * _elapsedTime);

    // Floating animation vertikal ±6px
    _badgeContainer.position.y = _glowRadius + sinVal * _floatAmplitude;

    // Pulsing aura opacity (0.15 - 0.45)
    final double opacity = (_opacityMid + sinVal * _opacityAmp).clamp(0.0, 1.0);
    _glowPaint.color = _goldPrimary.withValues(alpha: opacity);

    // Pulsing sparkle opacity
    final double sparkleOpacity = (0.5 + sinVal * 0.5).clamp(0.1, 1.0);
    _sparklePaint.color = Colors.white.withValues(alpha: sparkleOpacity);
  }

  // ── Public API ───────────────────────────────────────────────────────
  void whenCollected() {
    if (isCollected) return;
    isCollected = true;
    onCollected?.call();
    removeFromParent();
  }
}
