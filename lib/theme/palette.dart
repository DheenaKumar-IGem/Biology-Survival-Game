import 'package:flutter/material.dart';

/// Central color palette for PDAC Immune Defense.
///
/// The visual language is "inside the body": deep tissue blues/teals for
/// backgrounds, warm golds for currency, and three immune-category accent
/// colors that are reused everywhere (weapons, mobs, badges, UI accents) so
/// players learn to associate color with category.
class AppPalette {
  AppPalette._();

  // Background / tissue tones
  static const Color backgroundDeep = Color(0xFF071019);
  static const Color backgroundMid = Color(0xFF0E1E2E);
  static const Color backgroundTissue = Color(0xFF13283A);
  static const Color surface = Color(0xFF152A3D);
  static const Color surfaceLight = Color(0xFF1E3A52);

  // Text
  static const Color textPrimary = Color(0xFFEAF6FF);
  static const Color textSecondary = Color(0xFFA7C4D9);
  static const Color textMuted = Color(0xFF6C8AA0);

  // Player UI accent (buttons, progress bars, theme seed). Kept cyan.
  static const Color playerCore = Color(0xFF4FD1FF);
  static const Color playerGlow = Color(0xFF8FF0FF);

  // Player avatar (the in-arena creature + home hero mascot only).
  // Near-white body so the player never blends into innate-category cyan
  // enemies (#5DE0FF), paired with a steel-blue accent/rim so the cell still
  // has visible internal shading, nuclei, and a rim light (a pure-white accent
  // made all of those invisible white-on-white).
  static const Color avatarCore = Color(0xFFEDF4FB);
  static const Color avatarGlow = Color(0xFF9DB8D4);

  // Currency / health
  static const Color gold = Color(0xFFFFD166);
  static const Color goldDeep = Color(0xFFE0A93A);
  static const Color healthGood = Color(0xFF5BE37C);
  static const Color healthMid = Color(0xFFFFC857);
  static const Color healthLow = Color(0xFFFF6B6B);

  // Immune category accents
  static const Color innateColor = Color(0xFF5DE0FF); // cool blue
  static const Color antibodyColor = Color(0xFFB388FF); // violet
  static const Color cytotoxicColor = Color(0xFFFF6E6E); // red

  // Resistance / mutation
  static const Color mutationRing = Color(0xFFFFE08A);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDeep, backgroundMid, backgroundTissue],
  );

  static const RadialGradient heroGlow = RadialGradient(
    colors: [Color(0x664FD1FF), Color(0x00000000)],
    radius: 0.8,
  );
}
