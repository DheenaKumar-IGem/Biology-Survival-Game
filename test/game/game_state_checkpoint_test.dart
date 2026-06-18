import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdac_immune_defense/game/game_state.dart';
import 'package:pdac_immune_defense/services/persistence_service.dart';
import 'package:pdac_immune_defense/services/save_data.dart';

void main() {
  test('game state restores playable run fields from checkpoint', () async {
    // Persistent pool owns smg (bought in a prior session), so an equipped
    // smg survives restore; an unknown weapon is dropped.
    SharedPreferences.setMockInitialValues({
      'save_data_v1': jsonEncode(
        SaveData(
          ownedWeapons: const ['pistol', 'shotgun', 'rifle', 'smg'],
        ).toJson(),
      ),
    });
    final persistence = await PersistenceService.init();

    final state = GameState(
      persistence: persistence,
      checkpoint: CheckpointData(
        roundNumber: 5,
        playerHp: 64,
        goldThisRun: 22,
        equippedWeapons: const ['pistol', 'unknown_weapon', 'smg'],
        runUpgradeCounts: const {'pistol': 2, 'unknown_weapon': 3, 'smg': 1},
        equippedWeaponIndex: 4,
        totalQuizCorrect: 6,
        totalQuizQuestions: 9,
      ),
    );

    expect(state.currentRound, 5);
    expect(state.goldThisRun, 22);
    // Persistent pool is unchanged; equipped is filtered to owned+valid.
    expect(state.ownedWeapons, ['pistol', 'shotgun', 'rifle', 'smg']);
    expect(state.equippedWeapons, ['pistol', 'smg']);
    expect(state.equippedWeaponIndex, 1);
    expect(state.runUpgradeCounts, {'pistol': 2, 'smg': 1});
    expect(state.totalQuizCorrect, 6);
    expect(state.totalQuizQuestions, 9);
  });
}
