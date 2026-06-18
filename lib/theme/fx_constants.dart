import 'package:flutter/animation.dart';

/// Shared timing/easing/visual-effect constants so animations feel
/// consistent across the whole game (menus + gameplay).
class FxConstants {
  FxConstants._();

  // Generic UI motion
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600);

  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;

  // Glow / blur radii (scaled down by AnimationQuality at render time)
  static const double glowBlurHigh = 18.0;
  static const double glowBlurMedium = 10.0;
  static const double glowBlurLow = 0.0;

  // Blob wobble defaults
  static const double blobWobbleSpeed = 1.6; // rad/sec
  static const double blobWobbleAmplitudeFraction = 0.08; // * baseRadius

  // Pulse animation period for buttons / hero blob
  static const Duration pulsePeriod = Duration(milliseconds: 1800);

  /// Once this many mobs are alive at once, blobs drop their glow layer
  /// (the most expensive [BlobPainter] layer) regardless of
  /// [AnimationQuality], so a crowded arena doesn't tank the frame rate.
  static const int highMobCountGlowCutoff = 18;
}
