import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/game/systems/entity_budget.dart';
import 'package:pdac_immune_defense/game/systems/screen_shake.dart';
import 'package:pdac_immune_defense/services/settings_service.dart';

void main() {
  group('EntityBudget boss-projectile cap', () {
    test('acquires up to the cap, then refuses, and releases free a slot', () {
      final budget = EntityBudget();
      for (var i = 0; i < 3; i++) {
        expect(budget.tryAcquire(EntityBudget.bossProjectile, 3), isTrue);
      }
      // At cap: further spawns are refused (dropped) rather than uncapped.
      expect(budget.tryAcquire(EntityBudget.bossProjectile, 3), isFalse);
      expect(budget.count(EntityBudget.bossProjectile), 3);

      budget.release(EntityBudget.bossProjectile);
      expect(budget.tryAcquire(EntityBudget.bossProjectile, 3), isTrue);
      expect(budget.count(EntityBudget.bossProjectile), 3);
    });
  });

  group('GameDifficulty', () {
    test('assist < standard(1.0) < challenge for enemy damage', () {
      expect(GameDifficulty.standard.enemyDamageMultiplier, 1.0);
      expect(
        GameDifficulty.assist.enemyDamageMultiplier,
        lessThan(GameDifficulty.standard.enemyDamageMultiplier),
      );
      expect(
        GameDifficulty.challenge.enemyDamageMultiplier,
        greaterThan(GameDifficulty.standard.enemyDamageMultiplier),
      );
    });
  });

  group('SettingsData new fields', () {
    test('round-trip through json', () {
      const s = SettingsData(
        difficulty: GameDifficulty.assist,
        shapeLabels: false,
        muteAll: true,
      );
      final back = SettingsData.fromJson(s.toJson());
      expect(back.difficulty, GameDifficulty.assist);
      expect(back.shapeLabels, isFalse);
      expect(back.muteAll, isTrue);
    });

    test('safe defaults when keys are missing', () {
      final def = SettingsData.fromJson(const {});
      expect(def.difficulty, GameDifficulty.standard);
      expect(def.shapeLabels, isTrue); // on by default
      expect(def.muteAll, isFalse);
    });
  });

  group('ScreenShake refresh', () {
    test('a hit stronger than the CURRENT decayed strength refreshes it', () {
      final shake = ScreenShake(rng: Random(1));
      shake.trigger(12, 0.5);
      shake.update(0.4); // timer 0.1; current strength = 12 * 0.1/0.5 = 2.4

      // 5 > current 2.4 -> should refresh (without the fix this is < peak 12
      // and would be ignored, letting the shake die on the next update).
      shake.trigger(5, 0.3);
      shake.update(0.2); // timer would be -0.1 (dead) without the refresh
      expect(shake.isActive, isTrue);
    });

    test('a hit weaker than the current strength is still ignored', () {
      final shake = ScreenShake(rng: Random(1));
      shake.trigger(12, 0.5);
      shake.update(0.1); // current strength = 12 * 0.4/0.5 = 9.6
      shake.trigger(4, 0.1); // 4 < 9.6 -> ignored
      shake.update(0.2); // still inside the original 0.5s window
      expect(shake.isActive, isTrue);
    });
  });
}
