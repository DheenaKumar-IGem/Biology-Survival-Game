import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../theme/palette.dart';
import '../pdac_game.dart';

/// Lightweight boss projectile that uses a manual distance check instead of
/// Flame collision callbacks. Boss patterns can spawn several of these
/// without adding much collision-system pressure.
class BossProjectileComponent extends PositionComponent
    with HasGameReference<PdacGame> {
  BossProjectileComponent({
    required Vector2 position,
    required Vector2 direction,
    required this.damage,
    required this.color,
    this.speed = 190,
    this.radius = 8,
    this.lifespan = 3.2,
  }) : velocity = direction.normalized() * speed,
       super(
         position: position,
         size: Vector2.all(radius * 2),
         anchor: Anchor.center,
       );

  final Vector2 velocity;
  final double damage;
  final Color color;
  final double speed;
  final double radius;
  final double lifespan;

  double _age = 0;
  bool _hit = false;

  @override
  void onRemove() {
    game.onBossProjectileRemoved();
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= lifespan) {
      removeFromParent();
      return;
    }

    position += velocity * dt;
    final arena = game.arenaSize;
    if (position.x < -40 ||
        position.y < -40 ||
        position.x > arena.x + 40 ||
        position.y > arena.y + 40) {
      removeFromParent();
      return;
    }

    final player = game.player;
    if (!_hit &&
        position.distanceTo(player.position) <= radius + player.size.x / 2) {
      _hit = true;
      player.takeDamage(damage * game.enemyDamageMultiplier);
      game.triggerShake(6, 0.16);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final pulse = 0.8 + sin(_age * 10) * 0.2;
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(center, radius * 1.9 * pulse, glowPaint);

    final paint = Paint()..color = color;
    canvas.drawCircle(center, radius, paint);

    final corePaint = Paint()
      ..color = AppPalette.textPrimary.withValues(alpha: 0.75);
    canvas.drawCircle(center, radius * 0.42, corePaint);
  }
}
