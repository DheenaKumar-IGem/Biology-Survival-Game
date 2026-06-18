import '../weapons/weapon_traits.dart';
import 'gun_upgrade_def.dart';

/// Persistent (cross-session, gold-funded) upgrade track for a single
/// weapon's primary stat.
///
/// `statLevel` (stored in [SaveData.gunUpgrades]) ranges `0..maxLevel`.
/// Each level adds [bonusPerLevel] to [primaryStat] and costs
/// `costForLevel(level)` gold to purchase.
class WeaponPersistentUpgrade {
  const WeaponPersistentUpgrade({
    required this.weaponId,
    required this.primaryStat,
    required this.bonusPerLevel,
    required this.maxLevel,
    required this.baseCost,
    required this.costGrowthPerLevel,
  });

  final String weaponId;
  final WeaponStat primaryStat;
  final double bonusPerLevel;
  final int maxLevel;

  /// Gold cost to go from level 0 -> 1.
  final int baseCost;

  /// Additional gold cost added per subsequent level.
  final int costGrowthPerLevel;

  /// Gold cost to purchase the upgrade that takes the weapon from
  /// `currentLevel` to `currentLevel + 1`. Returns null if already at
  /// [maxLevel].
  int? costForNextLevel(int currentLevel) {
    if (currentLevel >= maxLevel) return null;
    return baseCost + costGrowthPerLevel * currentLevel;
  }
}

/// A persistent trait unlock offered in the gold shop for a specific
/// weapon. Becomes purchasable once that weapon's persistent stat level
/// reaches [unlockTierRequired].
class WeaponTraitUnlock {
  const WeaponTraitUnlock({
    required this.weaponId,
    required this.traitId,
    required this.unlockTierRequired,
    required this.goldCost,
    this.effectMagnitude,
  });

  final String weaponId;
  final WeaponTraitId traitId;

  /// Persistent stat level required before this trait can be purchased.
  final int unlockTierRequired;

  final int goldCost;

  /// Overrides [WeaponTraitDef.defaultMagnitude] for this weapon/trait
  /// combination, if provided.
  final double? effectMagnitude;
}

/// Catalog of persistent upgrades and trait unlocks for the weapons in the
/// vertical slice.
class PersistentShopCatalog {
  PersistentShopCatalog._();

  static const Map<String, WeaponPersistentUpgrade> statUpgrades = {
    'pistol': WeaponPersistentUpgrade(
      weaponId: 'pistol',
      primaryStat: WeaponStat.damage,
      bonusPerLevel: 0.5,
      maxLevel: 10,
      baseCost: 20,
      costGrowthPerLevel: 15,
    ),
    'shotgun': WeaponPersistentUpgrade(
      weaponId: 'shotgun',
      primaryStat: WeaponStat.damage,
      bonusPerLevel: 0.4,
      maxLevel: 10,
      baseCost: 25,
      costGrowthPerLevel: 18,
    ),
    'smg': WeaponPersistentUpgrade(
      weaponId: 'smg',
      primaryStat: WeaponStat.fireRate,
      bonusPerLevel: 0.4,
      maxLevel: 10,
      baseCost: 22,
      costGrowthPerLevel: 16,
    ),
    'rifle': WeaponPersistentUpgrade(
      weaponId: 'rifle',
      primaryStat: WeaponStat.damage,
      bonusPerLevel: 0.7,
      maxLevel: 10,
      baseCost: 30,
      costGrowthPerLevel: 20,
    ),
    'enzyme_sprayer': WeaponPersistentUpgrade(
      weaponId: 'enzyme_sprayer',
      primaryStat: WeaponStat.damage,
      bonusPerLevel: 0.35,
      maxLevel: 10,
      baseCost: 28,
      costGrowthPerLevel: 18,
    ),
    'macrophage_launcher': WeaponPersistentUpgrade(
      weaponId: 'macrophage_launcher',
      primaryStat: WeaponStat.damage,
      bonusPerLevel: 0.8,
      maxLevel: 10,
      baseCost: 34,
      costGrowthPerLevel: 22,
    ),
    'saliva_scanner': WeaponPersistentUpgrade(
      weaponId: 'saliva_scanner',
      primaryStat: WeaponStat.fireRate,
      bonusPerLevel: 0.35,
      maxLevel: 10,
      baseCost: 30,
      costGrowthPerLevel: 20,
    ),
  };

  static const List<WeaponTraitUnlock> traitUnlocks = [
    // Pistol
    WeaponTraitUnlock(
      weaponId: 'pistol',
      traitId: WeaponTraitId.explodingRounds,
      unlockTierRequired: 3,
      goldCost: 80,
    ),
    WeaponTraitUnlock(
      weaponId: 'pistol',
      traitId: WeaponTraitId.piercingShots,
      unlockTierRequired: 6,
      goldCost: 140,
      effectMagnitude: 2,
    ),
    // Shotgun
    WeaponTraitUnlock(
      weaponId: 'shotgun',
      traitId: WeaponTraitId.cytotoxicSlow,
      unlockTierRequired: 3,
      goldCost: 90,
      effectMagnitude: 0.3,
    ),
    WeaponTraitUnlock(
      weaponId: 'shotgun',
      traitId: WeaponTraitId.antibodyHoming,
      unlockTierRequired: 6,
      goldCost: 150,
      effectMagnitude: 0.26, // ~15deg/sec in radians
    ),
    // SMG
    WeaponTraitUnlock(
      weaponId: 'smg',
      traitId: WeaponTraitId.lifestealRounds,
      unlockTierRequired: 3,
      goldCost: 100,
      effectMagnitude: 0.05,
    ),
    WeaponTraitUnlock(
      weaponId: 'smg',
      traitId: WeaponTraitId.antibodyHoming,
      unlockTierRequired: 5,
      goldCost: 130,
      effectMagnitude: 2.5,
    ),
    // Rifle
    WeaponTraitUnlock(
      weaponId: 'rifle',
      traitId: WeaponTraitId.piercingShots,
      unlockTierRequired: 3,
      goldCost: 95,
      effectMagnitude: 3,
    ),
    WeaponTraitUnlock(
      weaponId: 'rifle',
      traitId: WeaponTraitId.explodingRounds,
      unlockTierRequired: 6,
      goldCost: 160,
      effectMagnitude: 0.45,
    ),
    // Enzyme Sprayer
    WeaponTraitUnlock(
      weaponId: 'enzyme_sprayer',
      traitId: WeaponTraitId.cytotoxicSlow,
      unlockTierRequired: 3,
      goldCost: 100,
      effectMagnitude: 0.38,
    ),
    WeaponTraitUnlock(
      weaponId: 'enzyme_sprayer',
      traitId: WeaponTraitId.lifestealRounds,
      unlockTierRequired: 6,
      goldCost: 170,
      effectMagnitude: 0.04,
    ),
    // Macrophage Launcher
    WeaponTraitUnlock(
      weaponId: 'macrophage_launcher',
      traitId: WeaponTraitId.explodingRounds,
      unlockTierRequired: 3,
      goldCost: 110,
      effectMagnitude: 0.65,
    ),
    WeaponTraitUnlock(
      weaponId: 'macrophage_launcher',
      traitId: WeaponTraitId.piercingShots,
      unlockTierRequired: 6,
      goldCost: 175,
      effectMagnitude: 2,
    ),
    // Saliva Scanner
    WeaponTraitUnlock(
      weaponId: 'saliva_scanner',
      traitId: WeaponTraitId.antibodyHoming,
      unlockTierRequired: 2,
      goldCost: 90,
      effectMagnitude: 3.2,
    ),
    WeaponTraitUnlock(
      weaponId: 'saliva_scanner',
      traitId: WeaponTraitId.piercingShots,
      unlockTierRequired: 5,
      goldCost: 150,
      effectMagnitude: 2,
    ),
  ];

  /// All trait unlocks available for [weaponId].
  static List<WeaponTraitUnlock> traitUnlocksFor(String weaponId) =>
      traitUnlocks.where((u) => u.weaponId == weaponId).toList();
}
