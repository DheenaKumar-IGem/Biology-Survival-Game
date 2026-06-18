import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../theme/fx_constants.dart';
import '../../theme/palette.dart';
import '../pdac_game.dart';

/// A lingering area-damage hazard, spawned by [SporeCloudBehavior] when a
/// fungal spore dies. Damages the player continuously while they remain
/// inside [radius], for [duration] seconds.
class DamageCloudComponent extends PositionComponent
    with HasGameReference<PdacGame> {
  DamageCloudComponent({
    required Vector2 position,
    required double radius,
    required this.damagePerSecond,
    required this.duration,
    this.warningSeconds = 0,
  }) : super(
         position: position,
         size: Vector2.all(radius * 2),
         anchor: Anchor.center,
       );

  final double damagePerSecond;
  final double duration;
  final double warningSeconds;
  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    final activeAge = _age - warningSeconds;
    if (activeAge >= duration) {
      removeFromParent();
      return;
    }
    if (activeAge < 0) return;

    final player = game.player;
    final hitRadius = size.x / 2 + player.size.x / 2;
    if (player.position.distanceToSquared(position) <= hitRadius * hitRadius) {
      player.takeDamage(damagePerSecond * dt);
    }
  }

  @override
  void render(Canvas canvas) {
    final activeAge = (_age - warningSeconds).clamp(0.0, duration);
    final warningFraction = warningSeconds <= 0
        ? 1.0
        : (_age / warningSeconds).clamp(0.0, 1.0);
    final t = (activeAge / duration).clamp(0.0, 1.0);
    final pulse = 0.85 + sin(_age * 6) * 0.15;
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2 * pulse;

    if (_age < warningSeconds) {
      final warningPaint = Paint()
        ..color = AppPalette.healthLow.withValues(
          alpha: 0.25 + 0.25 * warningFraction,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + warningFraction * 3;
      canvas.drawCircle(
        center,
        size.x / 2 * (0.85 + warningFraction * 0.15),
        warningPaint,
      );
      return;
    }

    final crowded =
        game.hud.activeCloudCount.value > 8 ||
        game.activeMobs.length >= FxConstants.highMobCountGlowCutoff;
    if (!crowded) {
      final glowPaint = Paint()
        ..color = AppPalette.cytotoxicColor.withValues(
          alpha: 0.18 * (1 - t * 0.5),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(center, radius, glowPaint);
    }

    final ringPaint = Paint()
      ..color = AppPalette.cytotoxicColor.withValues(
        alpha: (crowded ? 0.32 : 0.4) * (1 - t),
      )
      ..style = crowded ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  void onRemove() {
    game.onDamageCloudRemoved();
    super.onRemove();
  }
}
