import 'dart:math';

import 'package:flame/components.dart';

/// Decaying screen-shake helper extracted from [PdacGame].
///
/// Tracks a magnitude that linearly decays to zero over a duration; [offset]
/// is the current per-frame translation to apply to the render. A stronger
/// in-progress shake is never shortened by a weaker request.
class ScreenShake {
  ScreenShake({Random? rng}) : _rng = rng ?? Random();

  final Random _rng;
  double _timer = 0;
  double _duration = 0;
  double _magnitude = 0;
  final Vector2 _offset = Vector2.zero();

  /// True while a shake is in progress (the render should translate).
  bool get isActive => _timer > 0;

  /// Current per-frame offset (zero when inactive).
  Vector2 get offset => _offset;

  /// Starts (or escalates) a shake of [magnitude] pixels over [duration]
  /// seconds. Ignored if a stronger shake is already running.
  void trigger(double magnitude, double duration) {
    // Compare against the CURRENT (decayed) strength, not the original peak, so
    // a fresh hit that's stronger than what's left of an old shake refreshes it
    // - rapid late-decay hits no longer feel mushy.
    if (_timer > 0) {
      final currentStrength = _magnitude * (_timer / _duration);
      if (magnitude < currentStrength) return;
    }
    _magnitude = magnitude;
    _duration = duration;
    _timer = duration;
  }

  /// Advances the shake by [dt], updating [offset] and decaying toward zero.
  void update(double dt) {
    if (_timer <= 0) return;
    _timer -= dt;
    if (_timer <= 0) {
      _timer = 0;
      _offset.setZero();
    } else {
      final strength = _magnitude * (_timer / _duration);
      _offset
        ..x = (_rng.nextDouble() * 2 - 1) * strength
        ..y = (_rng.nextDouble() * 2 - 1) * strength;
    }
  }
}
