import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/data/weapons/weapon_catalog.dart';
import 'package:pdac_immune_defense/services/save_data.dart';

/// Verifies that v1 saves (which predate the global Targeting track and
/// persistent weapon ownership) upgrade cleanly to the current shape.
void main() {
  test('v1 save without v2 keys loads with safe defaults', () {
    // A v1 blob: no targetingLevel/smartAimUnlocked/ownedWeapons, and settings
    // without smartAimEnabled.
    final v1 = <String, dynamic>{
      'version': 1,
      'goldCoins': 250,
      'gunUpgrades': <String, dynamic>{},
      'highestRoundReached': 5,
      'totalRunsCompleted': 2,
      'settings': <String, dynamic>{'musicVolume': 0.4},
      'checkpoint': null,
      'unlockedEnemyEntries': <String>[],
    };

    final save = SaveData.fromJson(v1);

    // Preserved.
    expect(save.goldCoins, 250);
    expect(save.highestRoundReached, 5);
    expect(save.settings.musicVolume, 0.4);

    // New v2 fields default cleanly.
    expect(save.targetingLevel, 0);
    expect(save.smartAimUnlocked, isFalse);
    // Smart Aim is opt-in: off by default even before it's unlocked.
    expect(save.settings.smartAimEnabled, isFalse);
    expect(save.ownedWeapons, WeaponCatalog.startingLoadout);
  });

  test('empty ownedWeapons list falls back to the base trio', () {
    final save = SaveData.fromJson({'ownedWeapons': <String>[]});
    expect(save.ownedWeapons, WeaponCatalog.startingLoadout);
  });

  test('v1 checkpoint legacy ownedWeapons key maps to equippedWeapons', () {
    // v1 checkpoints stored the loadout under "ownedWeapons".
    final restored = CheckpointData.fromJson({
      'roundNumber': 4,
      'playerHp': 80,
      'goldThisRun': 10,
      'ownedWeapons': ['pistol', 'rifle'],
      'equippedWeaponIndex': 1,
    });

    expect(restored.equippedWeapons, ['pistol', 'rifle']);
    expect(restored.equippedWeaponIndex, 1);
  });

  test('v2 fields round-trip through toJson/fromJson', () {
    final original = SaveData(
      goldCoins: 99,
      targetingLevel: 3,
      smartAimUnlocked: true,
      ownedWeapons: const ['pistol', 'shotgun', 'rifle', 'saliva_scanner'],
    );

    final restored = SaveData.fromJson(original.toJson());

    expect(restored.targetingLevel, 3);
    expect(restored.smartAimUnlocked, isTrue);
    expect(restored.ownedWeapons, [
      'pistol',
      'shotgun',
      'rifle',
      'saliva_scanner',
    ]);
  });
}
