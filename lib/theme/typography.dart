import 'package:flutter/material.dart';
import 'palette.dart';

/// Shared text styles. Kept simple (system font) so the project has no
/// external font asset dependencies, but with consistent weight/spacing
/// choices so the UI reads as a cohesive "sci-bio" interface.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Roboto';

  /// Big end-screen / hero title. Sized to the value actually used at call
  /// sites (the home hero applies its own responsive size + letter-spacing on
  /// top, which is a deliberate special case, not a per-call override of a
  /// fictional scale).
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 38,
    fontWeight: FontWeight.w800,
    color: AppPalette.textPrimary,
    letterSpacing: 0,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppPalette.textPrimary,
    letterSpacing: 0,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppPalette.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppPalette.textSecondary,
    height: 1.4,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppPalette.textPrimary,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppPalette.textMuted,
    letterSpacing: 0,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppPalette.textPrimary,
    letterSpacing: 0,
  );
}
