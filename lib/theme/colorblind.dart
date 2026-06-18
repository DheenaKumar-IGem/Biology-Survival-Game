import 'dart:ui';

import '../data/categories.dart';
import '../services/settings_service.dart';

/// Per-deficiency colorblind-safe category colors.
///
/// When colorblind assist is on, mob fills/rims and bullets use these instead
/// of the default category hues. Each mode picks a distinct triad from the
/// Okabe-Ito colorblind-safe palette, chosen to avoid that deficiency's
/// confusion lines — so the three modes genuinely differ (they are NOT a
/// placebo) and category stays readable by hue *and* by the shape glyphs.
/// The category's display color resolved against the *current* colorblind
/// setting. Use this in UI (badges, weapon chips, shop/loadout cards) so menus
/// match the arena's remap instead of staying on the default violet/red/blue
/// that the colorblind modes exist to replace.
Color categoryDisplayColor(ImmuneCategory category) =>
    colorblindCategoryColor(category, SettingsService.instance.value.colorblindMode);

Color colorblindCategoryColor(ImmuneCategory category, ColorblindMode mode) {
  switch (mode) {
    case ColorblindMode.none:
      return category.color;
    case ColorblindMode.deuteranopia:
      return switch (category) {
        ImmuneCategory.innate => const Color(0xFF56B4E9), // sky blue
        ImmuneCategory.antibody => const Color(0xFFE69F00), // orange
        ImmuneCategory.cytotoxic => const Color(0xFFCC79A7), // reddish purple
      };
    case ColorblindMode.protanopia:
      return switch (category) {
        ImmuneCategory.innate => const Color(0xFF0072B2), // blue
        ImmuneCategory.antibody => const Color(0xFFF0E442), // yellow
        ImmuneCategory.cytotoxic => const Color(0xFF009E73), // bluish green
      };
    case ColorblindMode.tritanopia:
      return switch (category) {
        ImmuneCategory.innate => const Color(0xFFD55E00), // vermillion
        ImmuneCategory.antibody => const Color(0xFF009E73), // bluish green
        ImmuneCategory.cytotoxic => const Color(0xFFCC79A7), // reddish purple
      };
  }
}
