import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../pdac_game.dart';

/// A small fading spark used for hit sparks and death bursts. Spawning is
/// gated by [PdacGame.spawnParticles], which respects the player's
/// [ParticleDensity] setting (concurrent cap + per-event count multiplier).
///
/// Rendering adds cheap variety so a burst doesn't read as a clump of identical
/// dots: a per-particle size jitter, a warm->cool color and alpha ramp over its
/// lifetime, an additive ([BlendMode.plus]) glow, and - for faster particles -
/// a short elongated streak drawn back along the velocity vector. All of it is
/// derived from cached scalars, so the hot per-frame path stays a couple of
/// draw calls.
class ParticleComponent extends PositionComponent
    with HasGameReference<PdacGame> {
  ParticleComponent({
    required Vector2 position,
    required Vector2 velocity,
    required this.color,
    this.lifespan = 0.4,
    double size = 4,
    this.glow = true,
    this.streak = true,
  }) : velocity = velocity.clone(),
       // Deterministic per-particle jitter so each spark in a burst differs in
       // size without an extra RNG draw on the hot path.
       _sizeJitter = 0.7 + (position.x + position.y + size).abs() % 1.0 * 0.6,
       super(
         position: position,
         size: Vector2.all(size),
         anchor: Anchor.center,
       );

  final Vector2 velocity;
  final Color color;
  final double lifespan;

  /// Whether to draw the cheap additive glow halo behind the spark.
  final bool glow;

  /// Whether faster particles draw a short streak back along their velocity.
  final bool streak;

  final double _sizeJitter;
  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= lifespan) {
      removeFromParent();
      return;
    }
    position += velocity * dt;
    velocity.scale(0.9);
  }

  @override
  void onRemove() {
    game.onParticleRemoved();
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / lifespan).clamp(0.0, 1.0);
    final alpha = (1 - t).clamp(0.0, 1.0);
    if (alpha <= 0) return;
    final center = Offset(size.x / 2, size.y / 2);
    // Shrink + per-particle size jitter so a burst reads as varied debris.
    final radius = size.x / 2 * (1 - t * 0.5) * _sizeJitter;

    // Color ramp: a freshly-spawned spark flashes hotter (toward white) and
    // cools to its base color as it fades, giving the burst a little life.
    final hot = Color.lerp(const Color(0xFFFFFFFF), color, (t * 1.6).clamp(0.0, 1.0))!;
    final tint = hot.withValues(alpha: alpha);

    // Cheap additive glow halo behind the core.
    if (glow && radius > 0) {
      final glowPaint = Paint()
        ..color = tint.withValues(alpha: alpha * 0.35)
        ..blendMode = BlendMode.plus;
      canvas.drawCircle(center, radius * 1.9, glowPaint);
    }

    // A short streak back along the velocity for fast particles - turns round
    // dots into spark trails with one extra line per particle.
    final speed = velocity.length;
    if (streak && speed > 30) {
      final back = velocity.normalized() * -min(speed * 0.06, size.x * 1.8);
      final streakPaint = Paint()
        ..color = tint.withValues(alpha: alpha * 0.7)
        ..strokeWidth = max(1.0, radius * 0.9)
        ..strokeCap = StrokeCap.round
        ..blendMode = glow ? BlendMode.plus : BlendMode.srcOver;
      canvas.drawLine(center, center + Offset(back.x, back.y), streakPaint);
    }

    canvas.drawCircle(center, radius, Paint()..color = tint);
  }
}
