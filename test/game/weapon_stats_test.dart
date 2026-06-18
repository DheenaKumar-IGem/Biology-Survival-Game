import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/data/weapons/weapon_catalog.dart';
import 'package:pdac_immune_defense/game/components/weapon_controller.dart';
import 'package:pdac_immune_defense/services/save_data.dart';

/// Covers the pure stat-composition function the combat loop relies on
/// (previously untested).
void main() {
  final pistol = WeaponCatalog.all['pistol']!;

  test('persistent stat levels add the per-level bonus to damage', () {
    final base = computeEffectiveStats(
      base: pistol,
      persistent: GunPersistentState(statLevel: 0),
      runUpgradeCount: 0,
    );
    final upgraded = computeEffectiveStats(
      base: pistol,
      persistent: GunPersistentState(statLevel: 2),
      runUpgradeCount: 0,
    );
    // Pistol's persistent track adds 0.5 damage per level.
    expect(upgraded.damage - base.damage, closeTo(2 * 0.5, 1e-9));
  });

  test('the global fire-rate multiplier scales fire rate', () {
    final stats = computeEffectiveStats(
      base: pistol,
      persistent: GunPersistentState(),
      runUpgradeCount: 0,
      globalFireRateMultiplier: 2.0,
    );
    expect(stats.fireRate, closeTo(pistol.baseFireRate * 2.0, 1e-9));
  });

  test('a run upgrade changes at least one stat', () {
    final base = computeEffectiveStats(
      base: pistol,
      persistent: GunPersistentState(),
      runUpgradeCount: 0,
    );
    final withRun = computeEffectiveStats(
      base: pistol,
      persistent: GunPersistentState(),
      runUpgradeCount: 3,
    );
    expect(
      withRun.damage != base.damage ||
          withRun.fireRate != base.fireRate ||
          withRun.bulletSpeed != base.bulletSpeed,
      isTrue,
    );
  });
}
