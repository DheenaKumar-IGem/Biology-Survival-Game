import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/data/rounds/round_catalog.dart';
import 'package:pdac_immune_defense/data/weapons/weapon_catalog.dart';
import 'package:pdac_immune_defense/data/categories.dart';

/// Guards the cumulative-difficulty rework: enemy health and behavior intensity
/// grow monotonically across rounds (pressure does not reset), enemy COUNTS do
/// NOT grow (so rounds stay ~45s), and the innate starter is the Piercing Lance.
void main() {
  group('cumulative health growth', () {
    test('starts at 1.0 in round 1 and grows every round', () {
      expect(enemyHealthScaleForRound(1), 1.0);
      for (var r = 2; r <= 9; r++) {
        expect(
          enemyHealthScaleForRound(r),
          greaterThan(enemyHealthScaleForRound(r - 1)),
          reason: 'round $r health scale should exceed round ${r - 1}',
        );
      }
    });

    test('reaches the documented ~1.88x by round 9', () {
      expect(enemyHealthScaleForRound(9), closeTo(1.88, 1e-9));
    });

    test('the catalog applies the growth: R9 waves are tankier than R1', () {
      double avgHealthMult(int round) {
        final waves = RoundCatalog.all[round]!.spawnWaves;
        final sum = waves.fold<double>(0, (s, w) => s + w.healthMultiplier);
        return sum / waves.length;
      }

      expect(avgHealthMult(9), greaterThan(avgHealthMult(1)));
    });
  });

  group('behavior intensity growth', () {
    test('starts at 1.0 in round 1 and grows every round', () {
      expect(behaviorIntensityForRound(1), 1.0);
      for (var r = 2; r <= 9; r++) {
        expect(
          behaviorIntensityForRound(r),
          greaterThan(behaviorIntensityForRound(r - 1)),
        );
      }
    });
  });

  test('enemy counts are unchanged by the rework (rounds stay ~45s)', () {
    // Counts come from maximumSwarmTargetTotals only; the cumulative pressure
    // is HP + behavior, never count. Pin the totals so a future count-based
    // "escalation" can't silently re-lengthen rounds.
    const expectedTotals = [28, 32, 24, 40, 48, 30, 56, 62, 40];
    for (var r = 1; r <= 9; r++) {
      expect(RoundCatalog.all[r]!.totalSpawnCount, expectedTotals[r - 1]);
    }
  });

  group('innate starter is the Piercing Lance', () {
    test('pistol pierces innately and is the Piercer role', () {
      final pistol = WeaponCatalog.pistol;
      expect(pistol.category, ImmuneCategory.innate);
      expect(pistol.role, 'Piercer');
      expect(pistol.pierceCount, 2);
    });

    test('it stays viable on round 1 (DPS in a sane band)', () {
      final pistol = WeaponCatalog.pistol;
      final dps = pistol.baseDamage * pistol.pelletCount * pistol.baseFireRate;
      expect(dps, greaterThanOrEqualTo(11));
      expect(dps, lessThanOrEqualTo(16));
    });

    test('other weapons keep stops-on-first-hit by default', () {
      expect(WeaponCatalog.shotgun.pierceCount, 0);
      expect(WeaponCatalog.rifle.pierceCount, 0);
      expect(WeaponCatalog.smg.pierceCount, 0);
    });
  });
}
