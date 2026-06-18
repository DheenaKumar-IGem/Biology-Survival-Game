/// Global, weapon-independent "Targeting" upgrade track bought in the gold
/// shop. Unlike [PersistentShopCatalog] (which is per-weapon), this applies to
/// every weapon at once and represents the player's targeting/aim systems.
///
/// It is a single ordered track: each purchased level grants the next
/// [TargetingTier]. Effects are *not* summed - later tiers that set the same
/// field supersede earlier ones (e.g. Bio-Seeking II replaces Bio-Seeking I's
/// homing rate). See [effectiveTargeting].
///
/// Names are flavored around immunology so the shop keeps reinforcing the
/// lesson content (matching the convention in `weapon_traits.dart`).
class TargetingTier {
  const TargetingTier({
    required this.title,
    required this.description,
    required this.cost,
    this.homingTurnRate = 0,
    this.fireRateMultiplier = 1.0,
    this.duplicateChance = 0,
  });

  final String title;
  final String description;

  /// Gold cost to purchase this tier (before any quiz discount).
  final int cost;

  /// Baseline homing turn rate (radians/sec) applied to *all* bullets while
  /// this is the highest unlocked homing tier. 0 means "don't change it".
  final double homingTurnRate;

  /// Multiplier applied to every weapon's fire rate. 1.0 means "don't change".
  final double fireRateMultiplier;

  /// Per-shot chance (0-1) to emit one extra projectile. 0 means "don't
  /// change".
  final double duplicateChance;
}

/// Resolved, cumulative targeting effects for a given track level.
class TargetingEffects {
  const TargetingEffects({
    required this.homingTurnRate,
    required this.fireRateMultiplier,
    required this.duplicateChance,
  });

  final double homingTurnRate;
  final double fireRateMultiplier;
  final double duplicateChance;

  bool get hasHoming => homingTurnRate > 0;
}

class TargetingUpgradeCatalog {
  TargetingUpgradeCatalog._();

  /// Each entry is one purchasable level; index `i` corresponds to track
  /// level `i + 1`. Ordered as: gentle homing, then fire density, then
  /// bullet replication - matching the intended upgrade progression.
  static const List<TargetingTier> tiers = [
    TargetingTier(
      title: 'Bio-Seeking I',
      description:
          'All shots gently curve toward the nearest matching threat, like '
          'antibodies drifting toward a marked target.',
      cost: 60,
      homingTurnRate: 1.0,
    ),
    TargetingTier(
      title: 'Bio-Seeking II',
      description: 'Sharper homing - shots track threats more aggressively.',
      cost: 95,
      homingTurnRate: 1.7,
    ),
    TargetingTier(
      title: 'Saturation I',
      description: '+15% fire rate on every weapon (a denser response).',
      cost: 130,
      fireRateMultiplier: 1.15,
    ),
    TargetingTier(
      title: 'Saturation II',
      description: '+32% fire rate on every weapon.',
      cost: 175,
      fireRateMultiplier: 1.32,
    ),
    TargetingTier(
      title: 'Replication I',
      description:
          'Shots have a 15% chance to split into an extra projectile, like '
          'immune cells dividing to meet a threat.',
      cost: 220,
      duplicateChance: 0.15,
    ),
    TargetingTier(
      title: 'Replication II',
      description: 'Split chance rises to 28%.',
      cost: 300,
      duplicateChance: 0.28,
    ),
  ];

  static int get maxLevel => tiers.length;

  /// The tier that purchasing the next level would grant, or null if the
  /// track is already complete.
  static TargetingTier? nextTier(int currentLevel) {
    if (currentLevel >= tiers.length) return null;
    return tiers[currentLevel];
  }

  /// Resolves the cumulative effects for [level] (number of tiers owned).
  static TargetingEffects effectiveTargeting(int level) {
    var homing = 0.0;
    var fireRate = 1.0;
    var duplicate = 0.0;
    final owned = level.clamp(0, tiers.length);
    for (var i = 0; i < owned; i++) {
      final tier = tiers[i];
      if (tier.homingTurnRate > 0) homing = tier.homingTurnRate;
      if (tier.fireRateMultiplier != 1.0) fireRate = tier.fireRateMultiplier;
      if (tier.duplicateChance > 0) duplicate = tier.duplicateChance;
    }
    return TargetingEffects(
      homingTurnRate: homing,
      fireRateMultiplier: fireRate,
      duplicateChance: duplicate,
    );
  }

  /// Track level required before Smart Aim can be purchased.
  static const int smartAimUnlockTier = 2;

  /// Gold cost (before quiz discount) to unlock Smart Aim.
  static const int smartAimCost = 200;
}
