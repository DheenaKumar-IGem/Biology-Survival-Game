/// Special abilities that can be unlocked for a weapon via the persistent
/// gold shop, once that weapon's base stat level reaches a trait's
/// `unlockTierRequired` (see [WeaponTraitUnlock] in `persistent_shop_def.dart`).
///
/// Names are deliberately flavored around immunology/PDAC concepts so the
/// shop reinforces the lesson content:
/// - "Lytic" = cell lysis (bursting a cell open) -> exploding bullets.
/// - "Antibody tagging" -> homing toward a marked target.
/// - "Phagocytosis"-style pierce -> bullets pass through multiple targets.
enum WeaponTraitId {
  /// On-hit area-of-effect explosion ("lytic burst").
  explodingRounds,

  /// Bullets pass through multiple enemies before disappearing.
  piercingShots,

  /// On-hit, applies a temporary slow/"fever response" debuff.
  cytotoxicSlow,

  /// Bullets gently curve toward the nearest enemy of the weapon's
  /// matched category ("antibody tagging").
  antibodyHoming,

  /// A fraction of damage dealt is returned to the player as healing.
  lifestealRounds,
}

/// Describes a [WeaponTraitId] in player-facing terms. The numeric
/// `defaultMagnitude` is a sensible default; per-weapon overrides live in
/// `persistent_shop_def.dart`.
class WeaponTraitDef {
  const WeaponTraitDef({
    required this.id,
    required this.title,
    required this.description,
    required this.defaultMagnitude,
  });

  final WeaponTraitId id;
  final String title;
  final String description;

  /// Generic magnitude (meaning depends on trait: explosion radius
  /// fraction, pierce count, slow %, homing strength, lifesteal %).
  final double defaultMagnitude;
}

/// Catalog of all trait definitions, keyed by [WeaponTraitId].
const Map<WeaponTraitId, WeaponTraitDef> weaponTraitCatalog = {
  WeaponTraitId.explodingRounds: WeaponTraitDef(
    id: WeaponTraitId.explodingRounds,
    title: 'Lytic Burst',
    description:
        'On impact, bullets rupture in a small burst that damages nearby '
        'threats - just like how some immune cells cause infected cells to '
        'burst open (lysis).',
    defaultMagnitude: 0.5, // explosion deals 50% of bullet damage as AoE
  ),
  WeaponTraitId.piercingShots: WeaponTraitDef(
    id: WeaponTraitId.piercingShots,
    title: 'Piercing Shots',
    description:
        'Bullets pass through multiple threats in a line before fading, '
        'hitting everything in their path.',
    defaultMagnitude: 2, // pierce count
  ),
  WeaponTraitId.cytotoxicSlow: WeaponTraitDef(
    id: WeaponTraitId.cytotoxicSlow,
    title: 'Fever Response',
    description:
        'Hits leave threats sluggish for a moment, slowing them down - like '
        'a fever that makes it harder for pathogens to spread.',
    defaultMagnitude: 0.3, // 30% speed reduction
  ),
  WeaponTraitId.antibodyHoming: WeaponTraitDef(
    id: WeaponTraitId.antibodyHoming,
    title: 'Antibody Tagging',
    description:
        'Shots gently curve toward the nearest matching threat, like '
        'antibodies marking a specific target for the immune system.',
    defaultMagnitude: 2.5, // turn rate (radians/sec toward target)
  ),
  WeaponTraitId.lifestealRounds: WeaponTraitDef(
    id: WeaponTraitId.lifestealRounds,
    title: 'Regenerative Rounds',
    description:
        'A small portion of the damage you deal is converted into '
        'healing for your cell.',
    defaultMagnitude: 0.05, // 5% of damage dealt -> player HP
  ),
};
