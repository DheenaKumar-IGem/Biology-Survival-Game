import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/services/save_data.dart';
import 'package:pdac_immune_defense/services/settings_service.dart';

void main() {
  test('checkpoint data round-trips run resume fields', () {
    final checkpoint = CheckpointData(
      roundNumber: 4,
      playerHp: 72.5,
      goldThisRun: 31,
      equippedWeapons: const ['pistol', 'shotgun', 'rifle'],
      runUpgradeCounts: const {'pistol': 2, 'smg': 1},
      equippedWeaponIndex: 2,
      totalQuizCorrect: 7,
      totalQuizQuestions: 9,
    );

    final restored = CheckpointData.fromJson(checkpoint.toJson());

    expect(restored.roundNumber, 4);
    expect(restored.playerHp, 72.5);
    expect(restored.goldThisRun, 31);
    expect(restored.equippedWeapons, ['pistol', 'shotgun', 'rifle']);
    expect(restored.runUpgradeCounts, {'pistol': 2, 'smg': 1});
    expect(restored.equippedWeaponIndex, 2);
    expect(restored.totalQuizCorrect, 7);
    expect(restored.totalQuizQuestions, 9);
  });

  test('old minimal checkpoints still load with safe defaults', () {
    final restored = CheckpointData.fromJson({
      'roundNumber': 99,
      'playerHp': 50,
      'goldThisRun': 12,
    });

    expect(restored.roundNumber, CheckpointData.maxRound);
    expect(restored.playerHp, 50);
    expect(restored.goldThisRun, 12);
    expect(restored.equippedWeapons, isEmpty);
    expect(restored.runUpgradeCounts, isEmpty);
    expect(restored.equippedWeaponIndex, 0);
    expect(restored.totalQuizCorrect, 0);
    expect(restored.totalQuizQuestions, 0);
  });

  test(
    'save loading salvages valid fields when nested sections are corrupt',
    () {
      final restored = SaveData.fromJson({
        'goldCoins': 123,
        'highestRoundReached': 6,
        'totalRunsCompleted': 2,
        'gunUpgrades': {
          'pistol': 'bad nested weapon data',
          'rifle': {
            'statLevel': '4',
            'unlockedTraits': ['ricochet'],
          },
        },
        'settings': 'bad settings data',
        'checkpoint': 'bad checkpoint data',
        'unlockedEnemyEntries': ['virus', 42, 'fungus'],
        'targetingLevel': '3',
        'smartAimUnlocked': true,
        'ownedWeapons': ['pistol', 99, 'rifle'],
      });

      expect(restored.goldCoins, 123);
      expect(restored.highestRoundReached, 6);
      expect(restored.totalRunsCompleted, 2);
      expect(restored.gunUpgrades['pistol']?.statLevel, 0);
      expect(restored.gunUpgrades['rifle']?.statLevel, 4);
      expect(restored.settings, SettingsData.defaults);
      expect(restored.checkpoint, isNull);
      expect(restored.unlockedEnemyEntries, {'virus', 'fungus'});
      expect(restored.targetingLevel, 3);
      expect(restored.smartAimUnlocked, isTrue);
      expect(restored.ownedWeapons, ['pistol', 'rifle']);
    },
  );
}
