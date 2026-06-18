import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../theme/colorblind.dart';
import '../pdac_game.dart';

/// Draws a targeting reticle on the enemy the equipped weapon is currently
/// auto-firing at, colored to show whether the weapon's category MATCHES the
/// target - the core "swap to the right color" feedback the combat was
/// missing. It reads the per-frame target snapshot the [WeaponController]
/// publishes on [PdacGame] (position/radius/matched/category), so it never
/// holds a reference to a mob that might die mid-frame.
///
/// Added directly to the game (not a child of a positioned component), so its
/// canvas is world space and it can draw at the target's absolute position.
class ReticleComponent extends Component with HasGameReference<PdacGame> {
  static final Paint _ring = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  static final Paint _tick = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round;

  /// Neutral grey used for a mismatched target - reads as "wrong tool" without
  /// being alarming for the young audience.
  static const Color _mismatchColor = Color(0xFF9AA3B2);

  @override
  void render(Canvas canvas) {
    if (!game.hasAimTarget || game.phase.value != RoundPhase.playing) return;

    final mode = game.settings.value.colorblindMode;
    final matched = game.aimTargetMatched;
    final color = matched
        ? colorblindCategoryColor(game.aimTargetCategory, mode)
        : _mismatchColor;

    final center = Offset(game.aimTargetPosition.x, game.aimTargetPosition.y);
    final r = game.aimTargetRadius + 6;

    // Matched: a full bright ring (clear "right tool" confirmation).
    // Mismatched: a dimmer segmented ring that reads as "wrong color, swap".
    _ring.color = color.withValues(alpha: matched ? 0.95 : 0.6);
    if (matched) {
      canvas.drawCircle(center, r, _ring);
    } else {
      _drawSegmentedRing(canvas, center, r);
    }

    // Scope-style corner ticks frame the target.
    _tick.color = color.withValues(alpha: matched ? 0.95 : 0.55);
    const tickLength = 5.0;
    for (var i = 0; i < 4; i++) {
      final a = pi / 4 + i * (pi / 2);
      final dir = Offset(cos(a), sin(a));
      canvas.drawLine(
        center + dir * (r + 2),
        center + dir * (r + 2 + tickLength),
        _tick,
      );
    }
  }

  void _drawSegmentedRing(Canvas canvas, Offset center, double r) {
    const segments = 8;
    const segmentSweep = (2 * pi / segments) * 0.55;
    final rect = Rect.fromCircle(center: center, radius: r);
    for (var i = 0; i < segments; i++) {
      canvas.drawArc(rect, i * (2 * pi / segments), segmentSweep, false, _ring);
    }
  }
}
