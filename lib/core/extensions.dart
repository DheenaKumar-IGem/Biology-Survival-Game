import 'dart:ui';
import 'package:flame/components.dart';

extension Vector2Offset on Vector2 {
  Offset toOffset() => Offset(x, y);
}

extension OffsetVector2 on Offset {
  Vector2 toVector2() => Vector2(dx, dy);
}

extension ColorAlphaX on Color {
  /// Returns a copy of this color with [alpha] (0.0-1.0) applied.
  Color withOpacityFraction(double alpha) =>
      withValues(alpha: alpha.clamp(0.0, 1.0));
}

extension Vector2Utils on Vector2 {
  /// Returns this vector clamped to a maximum [length], preserving direction.
  Vector2 clampLength(double maxLength) {
    final len = length;
    if (len <= maxLength || len == 0) return clone();
    return (this / len) * maxLength;
  }
}
