import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' show Icons, IconData;

import '../theme/palette.dart';

/// The three immune-response "categories" that every weapon and every germ
/// belongs to. This is the core teaching mechanic: matching a weapon's
/// category to an enemy's category deals bonus damage, mirroring how the
/// real immune system relies on different types of responses for different
/// threats.
enum ImmuneCategory {
  /// Fast, broad first responders (innate immunity).
  innate(
    title: 'Innate Immunity',
    shortLabel: 'Innate',
    description:
        'Your body\'s fast, general-purpose first responders. They attack '
        'almost any invader right away.',
    color: AppPalette.innateColor,
    icon: Icons.bolt,
  ),

  /// Precision, learned responses that "tag" a specific target (adaptive /
  /// antibody-mediated immunity).
  antibody(
    title: 'Antibody-Targeted',
    shortLabel: 'Antibody',
    description:
        'Precise defenders that learn to recognize one specific invader '
        'and mark it for destruction. In real biology antibodies mostly '
        'tag a target so other cells finish it off; in this game your '
        'antibody weapon stands in for that whole tag-and-destroy team - '
        'the tag plus the cells that do the killing - compressed into one '
        'shot.',
    color: AppPalette.antibodyColor,
    icon: Icons.gps_fixed,
  ),

  /// Heavy, sustained damage that destroys infected or abnormal cells
  /// directly (cytotoxic response).
  cytotoxic(
    title: 'Cytotoxic Response',
    shortLabel: 'Cytotoxic',
    description:
        'Heavy-hitting defenders that directly destroy infected or '
        'abnormal cells.',
    color: AppPalette.cytotoxicColor,
    icon: Icons.local_fire_department,
  );

  const ImmuneCategory({
    required this.title,
    required this.shortLabel,
    required this.description,
    required this.color,
    required this.icon,
  });

  final String title;
  final String shortLabel;
  final String description;
  final Color color;
  final IconData icon;
}

/// Damage multiplier applied when a weapon's category matches the target's
/// category. Set above 1 so picking the right immune response is a felt
/// reward, not merely the absence of the mismatch penalty.
const double matchedDamageMultiplier = 1.4;

/// Damage multiplier applied when a weapon's category does NOT match the
/// target's category - a quarter of normal damage, so using the wrong weapon
/// is a real penalty and swapping to the matching color clearly matters.
/// Individual enemies can be even stricter via [EnemyDef.mismatchMultiplier].
const double mismatchedDamageMultiplier = 0.25;

/// Applies the category match/mismatch multiplier to a base damage amount.
///
/// If [source] is null (e.g. an environmental effect with no category),
/// [amount] is returned unchanged.
double applyCategoryMultiplier(
  double amount,
  ImmuneCategory target,
  ImmuneCategory? source, {
  double mismatchMultiplier = mismatchedDamageMultiplier,
}) {
  if (source == null) return amount;
  final multiplier = source == target
      ? matchedDamageMultiplier
      : mismatchMultiplier;
  return max(0.0, amount * multiplier);
}

/// Maximum number of KRAS-style resistance tiers an enemy/boss can acquire
/// for a single category.
const int maxResistanceTier = 3;

/// Share of total damage (0-1) a single category must account for in a
/// round before it counts as "overused" against a target.
const double overuseShareThreshold = 0.70;

/// Number of consecutive rounds a category must be "overused" against a
/// target before it gains a resistance tier.
const int overuseRoundsToResist = 2;

/// Per-tier multiplier applied to damage from a resisted category.
/// Tier 1 => 0.6x, tier 2 => 0.36x, tier 3 => 0.216x.
const double resistanceTierMultiplier = 0.6;

/// Tracks per-category damage dealt to a single enemy/boss and evolves a
/// KRAS-style mutation/resistance state over time.
///
/// Narrative framing (selection, NOT adaptation): a tumor already contains
/// cells with driver mutations like KRAS from the start. When the player leans
/// almost entirely on one immune response for repeated rounds, the cells that
/// happen to shrug it off are the ones that survive and dominate, so that
/// response loses effectiveness - i.e. a varied defense works better. The
/// immune pressure does NOT create the resistance; it selects for pre-existing
/// resistant cells.
class KrasResistanceState {
  KrasResistanceState()
    : damageThisRound = {for (final c in ImmuneCategory.values) c: 0.0},
      consecutiveOveruse = {for (final c in ImmuneCategory.values) c: 0},
      resistanceTier = {for (final c in ImmuneCategory.values) c: 0};

  final Map<ImmuneCategory, double> damageThisRound;
  final Map<ImmuneCategory, int> consecutiveOveruse;
  final Map<ImmuneCategory, int> resistanceTier;

  /// Sum of all resistance tiers across categories. Used to size the
  /// "mutation ring" visual - more total tiers = thicker/brighter ring.
  int get totalResistanceTier => resistanceTier.values.fold(0, (a, b) => a + b);

  /// Multiplier to apply to damage of category [c] dealt to this target.
  double multiplierFor(ImmuneCategory c) =>
      pow(resistanceTierMultiplier, resistanceTier[c] ?? 0).toDouble();

  /// Record that [amount] of damage from category [c] was dealt this round.
  void recordDamage(ImmuneCategory c, double amount) {
    damageThisRound[c] = (damageThisRound[c] ?? 0) + amount;
  }

  /// Returns the category responsible for >= [overuseShareThreshold] of
  /// damage dealt this round, or null if no single category dominates.
  ImmuneCategory? dominantCategory() {
    final total = damageThisRound.values.fold(0.0, (a, b) => a + b);
    if (total <= 0) return null;
    for (final entry in damageThisRound.entries) {
      if (entry.value / total >= overuseShareThreshold) {
        return entry.key;
      }
    }
    return null;
  }

  /// Returns true if a new resistance tier was gained this round (useful
  /// for triggering a one-time "mutation acquired" context tip).
  bool endRoundAndCheckMutation() {
    final dominant = dominantCategory();
    var mutated = false;
    for (final category in ImmuneCategory.values) {
      if (category == dominant) {
        final streak = (consecutiveOveruse[category] ?? 0) + 1;
        consecutiveOveruse[category] = streak;
        if (streak >= overuseRoundsToResist &&
            (resistanceTier[category] ?? 0) < maxResistanceTier) {
          resistanceTier[category] = (resistanceTier[category] ?? 0) + 1;
          consecutiveOveruse[category] = 0;
          mutated = true;
        }
      } else {
        consecutiveOveruse[category] = 0;
      }
      damageThisRound[category] = 0;
    }
    return mutated;
  }

  /// Pre-seeds one resistance tier against [category]. Used by bosses to
  /// represent a tumor that already carries cells resistant to the player's
  /// most-used category from the prior section (pre-existing driver mutations,
  /// not resistance created by the player's attacks).
  void preSeedResistance(ImmuneCategory category, {int tiers = 1}) {
    resistanceTier[category] = ((resistanceTier[category] ?? 0) + tiers).clamp(
      0,
      maxResistanceTier,
    );
  }
}
