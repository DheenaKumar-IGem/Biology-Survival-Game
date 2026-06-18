import 'package:flutter/material.dart';

import '../../data/categories.dart';
import '../../services/settings_service.dart';
import '../../theme/category_glyph.dart';
import '../../theme/colorblind.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// A small pill showing an [ImmuneCategory]'s glyph, short label, and
/// signature color. Used on weapon cards, enemy tooltips, and lesson UI.
///
/// Colors come from [categoryDisplayColor] (so colorblind assist recolors the
/// menus, not just the arena) and the glyph is the shared diamond/ring/triangle
/// shape language, so it matches what the player sees in combat. Rebuilds live
/// when the colorblind setting changes.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({
    super.key,
    required this.category,
    this.compact = false,
  });

  final ImmuneCategory category;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SettingsData>(
      valueListenable: SettingsService.instance,
      builder: (context, settings, _) {
        final color = categoryDisplayColor(category);
        final labelColor = settings.colorblindMode == ColorblindMode.none
            ? color
            : AppPalette.textPrimary;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 12,
            vertical: compact ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CategoryGlyph(
                category: category,
                color: color,
                size: compact ? 14 : 16,
              ),
              const SizedBox(width: 6),
              Text(
                category.shortLabel,
                style: AppTypography.label.copyWith(
                  color: labelColor,
                  fontSize: compact ? 11 : 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A small neutral pill showing a weapon's archetype role (e.g. "Rapid",
/// "Heavy AoE"), so weapons sharing a category read as distinct tools rather
/// than redundant duplicates. Neutral-colored so it never competes with the
/// category color (which carries the load-bearing match meaning).
class WeaponRoleTag extends StatelessWidget {
  const WeaponRoleTag({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    if (role.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppPalette.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppPalette.textMuted.withValues(alpha: 0.45)),
      ),
      child: Text(
        role,
        style: AppTypography.label.copyWith(
          color: AppPalette.textSecondary,
          fontSize: 11,
        ),
      ),
    );
  }
}
