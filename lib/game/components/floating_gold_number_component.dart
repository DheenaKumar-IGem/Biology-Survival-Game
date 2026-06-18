import 'dart:ui';

import 'package:flame/components.dart';

import '../../theme/palette.dart';
import '../pdac_game.dart';

/// A floating "+N" gold number that rises from a kill, showing the reward the
/// player just earned. Mirrors [FloatingDamageNumberComponent]: the paragraph
/// is built once and the fade is applied via a cheap layer alpha.
class FloatingGoldNumberComponent extends PositionComponent
    with HasGameReference<PdacGame> {
  FloatingGoldNumberComponent({required Vector2 position, required this.amount})
    : super(position: position, anchor: Anchor.center);

  final int amount;
  double _life = 0;
  static const double _maxLife = 0.85;
  static const double _layoutWidth = 140;

  Paragraph? _paragraph;

  Paragraph _build() {
    final scale = game.settings.value.textScale;
    final builder =
        ParagraphBuilder(
            ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: 15.0 * scale,
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
            ),
          )
          ..pushStyle(
            TextStyle(
              color: AppPalette.gold,
              shadows: const [Shadow(color: Color(0xFF04060A), blurRadius: 2)],
            ),
          )
          ..addText('+$amount');
    return builder.build()
      ..layout(const ParagraphConstraints(width: _layoutWidth));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _life += dt;
    position.y -= 34 * dt; // rise
    if (_life >= _maxLife) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final p = _paragraph ??= _build();
    final t = (_life / _maxLife).clamp(0.0, 1.0);
    final alpha = (1.0 - t).clamp(0.0, 1.0);
    final offset = Offset(-_layoutWidth / 2, -p.height / 2);
    if (alpha >= 0.999) {
      canvas.drawParagraph(p, offset);
    } else {
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, alpha));
      canvas.drawParagraph(p, offset);
      canvas.restore();
    }
  }

  @override
  void onRemove() {
    game.onGoldNumberRemoved();
    super.onRemove();
  }
}
