import 'dart:ui';

import 'package:flame/components.dart';

import '../../theme/palette.dart';
import '../pdac_game.dart';

/// A short-lived floating damage number that drifts upward and fades.
///
/// Colored and sized by whether the shot matched the enemy's immune category,
/// so the match bonus / mismatch penalty is visible in the moment (matched fire
/// hits for 1.4x, mismatched for ~0.25x): a matched hit pops larger and GOLD
/// (reward), a mismatched hit is small and MUTED RED (weak). The [Paragraph] is
/// built once and the fade is applied via a cheap layer alpha, so heavy fire
/// doesn't re-shape text every frame.
class FloatingDamageNumberComponent extends PositionComponent
    with HasGameReference<PdacGame> {
  FloatingDamageNumberComponent({
    required Vector2 position,
    required this.amount,
    required this.matched,
  }) : super(position: position, anchor: Anchor.center);

  final double amount;
  final bool matched;
  double _life = 0;
  static const double _maxLife = 0.7;
  static const double _layoutWidth = 140;

  Paragraph? _paragraph;

  Paragraph _buildParagraph() {
    final scale = game.settings.value.textScale;
    // Gold = bonus/reward (not the green heal color); muted red = weak hit.
    final color = matched ? AppPalette.gold : const Color(0xFFD98A8A);
    final text = amount >= 10
        ? amount.round().toString()
        : amount.toStringAsFixed(1);
    final builder =
        ParagraphBuilder(
            ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: (matched ? 16.0 : 12.0) * scale,
              fontWeight: matched ? FontWeight.w800 : FontWeight.w700,
              fontFamily: 'Roboto',
            ),
          )
          ..pushStyle(
            TextStyle(
              color: color,
              shadows: const [
                Shadow(color: Color(0xFF04060A), blurRadius: 2),
              ],
            ),
          )
          ..addText(text);
    return builder.build()
      ..layout(const ParagraphConstraints(width: _layoutWidth));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _life += dt;
    position.y -= 28 * dt; // drift upward
    if (_life >= _maxLife) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final p = _paragraph ??= _buildParagraph();
    final t = (_life / _maxLife).clamp(0.0, 1.0);
    final alpha = (1.0 - t).clamp(0.0, 1.0);
    final offset = Offset(-_layoutWidth / 2, -p.height / 2);
    if (alpha >= 0.999) {
      canvas.drawParagraph(p, offset);
    } else {
      // Fade the cached paragraph via a layer alpha - no per-frame relayout.
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, alpha));
      canvas.drawParagraph(p, offset);
      canvas.restore();
    }
  }

  @override
  void onRemove() {
    game.onDamageNumberRemoved();
    super.onRemove();
  }
}
