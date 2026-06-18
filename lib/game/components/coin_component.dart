import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../theme/fx_constants.dart';
import '../../theme/palette.dart';
import '../pdac_game.dart';

/// A dropped gold coin. Slowly drifts/bobs in place; once the player's
/// pickup radius overlaps it, [PdacGame.collectCoin] is called (which updates the
/// persistent gold total and the HUD) and the coin removes itself.
class CoinComponent extends PositionComponent with HasGameReference<PdacGame> {
  CoinComponent({required Vector2 position, required this.value})
    : super(position: position, size: Vector2.all(14), anchor: Anchor.center);

  final int value;
  double _time = Random().nextDouble() * 10;
  bool _collected = false;

  // Pooled paints (coin colors are constant), reused across all coins.
  static final Paint _glowPaint = Paint()
    ..color = AppPalette.gold.withValues(alpha: 0.4)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  static final Paint _fillPaint = Paint()..color = AppPalette.gold;
  static final Paint _ringPaint = Paint()
    ..color = AppPalette.goldDeep
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    if (!_collected) {
      final player = game.player;
      final pickupRadius = size.x / 2 + player.size.x / 2;

      // Pickup magnet: once the player is within range, the coin accelerates
      // toward them (faster the closer it gets) so gold earned deep in a swarm
      // the player is correctly kiting away from still gets collected.
      final toPlayer = player.position - position;
      final distSq = toPlayer.length2;
      const magnetRadius = 130.0;
      if (distSq > 0.0001 && distSq <= magnetRadius * magnetRadius) {
        final pull = 1 - sqrt(distSq) / magnetRadius; // 0 at edge, ~1 at player
        final speed = 90 + 360 * pull; // px/s, ramps up near the player
        position += toPlayer.normalized() * speed * dt;
      }

      final touching =
          position.distanceToSquared(player.position) <=
          pickupRadius * pickupRadius;
      if (!touching) return;

      _collected = true;
      game.collectCoin(value);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final bob = sin(_time * 4) * 2;
    final center = Offset(size.x / 2, size.y / 2 + bob);

    // Glow blur is the most expensive raster op; skip it when the arena is
    // crowded (matching the mob glow cutoff) so 50 coins don't tank the frame.
    if (game.activeMobs.length < FxConstants.highMobCountGlowCutoff) {
      canvas.drawCircle(center, size.x / 2 + 2, _glowPaint);
    }
    canvas.drawCircle(center, size.x / 2, _fillPaint);
    canvas.drawCircle(center, size.x / 2 - 1.5, _ringPaint);
  }

  @override
  void onRemove() {
    game.onCoinRemoved();
    super.onRemove();
  }
}
