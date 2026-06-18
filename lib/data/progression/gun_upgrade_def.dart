/// Which stat a [GunUpgradeOption] (end-of-round choice) or persistent shop
/// upgrade modifies.
enum WeaponStat { damage, fireRate, bulletSpeed }

/// A single end-of-round "pick one gun to upgrade" option.
///
/// This is **run-scoped** progression (kept in [GameState], not persisted)
/// - separate from the persistent gold shop. Each weapon has one
/// predefined upgrade so the round-end screen can show a simple card per
/// owned weapon.
class GunUpgradeOption {
  const GunUpgradeOption({
    required this.weaponId,
    required this.stat,
    required this.amount,
    required this.description,
  });

  final String weaponId;
  final WeaponStat stat;
  final double amount;
  final String description;
}

/// One upgrade option per weapon, offered at the end of every round for
/// weapons the player currently owns.
class GunUpgradeCatalog {
  GunUpgradeCatalog._();

  static const Map<String, GunUpgradeOption> all = {
    'pistol': GunUpgradeOption(
      weaponId: 'pistol',
      stat: WeaponStat.damage,
      amount: 1,
      description: '+1 damage per shot',
    ),
    'shotgun': GunUpgradeOption(
      weaponId: 'shotgun',
      stat: WeaponStat.fireRate,
      amount: 0.3,
      description: '+0.3 shots per second',
    ),
    'smg': GunUpgradeOption(
      weaponId: 'smg',
      // Damage, not bullet speed: an SMG round already flies at 560, so a speed
      // bump is imperceptible - the pick should be felt as a real DPS boost.
      stat: WeaponStat.damage,
      amount: 0.5,
      description: '+0.5 damage per shot',
    ),
    'rifle': GunUpgradeOption(
      weaponId: 'rifle',
      stat: WeaponStat.damage,
      amount: 2,
      description: '+2 damage per shot',
    ),
    'enzyme_sprayer': GunUpgradeOption(
      weaponId: 'enzyme_sprayer',
      stat: WeaponStat.fireRate,
      amount: 0.35,
      description: '+0.35 sprays per second',
    ),
    'macrophage_launcher': GunUpgradeOption(
      weaponId: 'macrophage_launcher',
      stat: WeaponStat.damage,
      amount: 1.5,
      description: '+1.5 damage per burst',
    ),
    'saliva_scanner': GunUpgradeOption(
      weaponId: 'saliva_scanner',
      // Damage rather than an imperceptible speed bump on an already-620 pulse.
      stat: WeaponStat.damage,
      amount: 0.4,
      description: '+0.4 damage per pulse',
    ),
  };
}
