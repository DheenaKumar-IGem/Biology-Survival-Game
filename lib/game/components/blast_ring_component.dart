import 'dart:ui';

import 'package:flame/components.dart';

import '../pdac_game.dart';

/// A one-shot expanding ring "blast" played when an enemy is destroyed, so a
/// kill reads as a satisfying pop. Short-lived (~0.28s) and capped by the game.
class BlastRingComponent extends PositionComponent
    with HasGameReference<PdacGame> {
  BlastRingComponent({
    required Vector2 position,
    required this.maxRadius,
    required this.color,
  }) : super(position: position, anchor: Anchor.center);

  final double maxRadius;
  final Color color;
  double _life = 0;
  static const double _maxLife = 0.28;
  static final Paint _paint = Paint()..style = PaintingStyle.stroke;

  @override
  void update(double dt) {
    super.update(dt);
    _life += dt;
    if (_life >= _maxLife) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_life / _maxLife).clamp(0.0, 1.0);
    final ease = 1 - (1 - t) * (1 - t); // ease-out expansion
    final r = maxRadius * (0.25 + 0.75 * ease);
    _paint
      ..color = color.withValues(alpha: (1 - t) * 0.7)
      ..strokeWidth = 1 + 3 * (1 - t);
    canvas.drawCircle(Offset.zero, r, _paint);
  }

  @override
  void onRemove() {
    game.onBlastRingRemoved();
    super.onRemove();
  }
}
