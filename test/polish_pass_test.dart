import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/data/lessons/lesson_catalog.dart';
import 'package:pdac_immune_defense/data/maps/biome_catalog.dart';
import 'package:pdac_immune_defense/data/rounds/round_catalog.dart';
import 'package:pdac_immune_defense/data/weapons/weapon_catalog.dart';
import 'package:pdac_immune_defense/data/weapons/weapon_def.dart';
import 'package:pdac_immune_defense/game/pdac_game.dart';

/// Regression coverage for the polish pass: weapon-DPS rebalance, round-7
/// decoy smoothing, the saliva-narrative reconnection in the mid-game lessons,
/// the cancer-cells-are-not-germs terminology fix, and the quiz distractor
/// corrections. These are all pure-data assertions, so they pin the intent
/// without a Flame harness.
void main() {
  double baseDps(WeaponDef w) => w.baseDamage * w.pelletCount * w.baseFireRate;

  group('weapon DPS band', () {
    test('all weapons sit within a tight matched-DPS band (<2x spread)', () {
      final dps = WeaponCatalog.all.values.map(baseDps).toList();
      final maxDps = dps.reduce((a, b) => a > b ? a : b);
      final minDps = dps.reduce((a, b) => a < b ? a : b);
      // Before the rebalance the spread was ~3.4x (enzyme_sprayer vs
      // macrophage_launcher). Keep every weapon competitive.
      expect(maxDps / minDps, lessThan(2.0));
    });

    test('macrophage_launcher is no longer the worst weapon', () {
      final macrophage = baseDps(WeaponCatalog.all['macrophage_launcher']!);
      final minDps = WeaponCatalog.all.values
          .map(baseDps)
          .reduce((a, b) => a < b ? a : b);
      expect(macrophage, greaterThan(minDps));
    });

    test('enzyme_sprayer is no longer a runaway best weapon', () {
      final enzyme = baseDps(WeaponCatalog.all['enzyme_sprayer']!);
      final maxDps = WeaponCatalog.all.values
          .map(baseDps)
          .reduce((a, b) => a > b ? a : b);
      // It may still be at the top of the band, but only marginally.
      expect(enzyme, lessThanOrEqualTo(maxDps));
      expect(enzyme, lessThan(baseDps(WeaponCatalog.all['pistol']!) * 2));
    });
  });

  group('round 7 decoy smoothing', () {
    int decoyCount(List spawnWaves) => spawnWaves
        .where((w) => w.enemyId == 'decoy_signal')
        .fold<int>(0, (sum, w) => sum + (w.count as int));

    test('base round 7 has decoys as a clear minority of spawns', () {
      final waves = RoundCatalog.round7.spawnWaves;
      final total = waves.fold<int>(0, (sum, w) => sum + w.count);
      final decoys = decoyCount(waves);
      expect(decoys / total, lessThan(0.30));
    });

    test('round 7 final wave is a real threat, not decoy clutter', () {
      // The swarm-scaling remainder lands on the last wave, so it must not be
      // a decoy or the decoy share re-inflates.
      expect(
        RoundCatalog.round7.spawnWaves.last.enemyId,
        isNot('decoy_signal'),
      );
    });

    test('scaled round 7 still keeps decoys a minority', () {
      final waves = RoundCatalog.all[7]!.spawnWaves;
      final total = waves.fold<int>(0, (sum, w) => sum + w.count);
      final decoys = decoyCount(waves);
      expect(decoys / total, lessThan(0.30));
    });
  });

  group('saliva narrative reconnection (mid-game lessons)', () {
    bool mentionsDetection(String text) {
      final lower = text.toLowerCase();
      return lower.contains('saliva') ||
          lower.contains('biomarker') ||
          lower.contains('detect');
    }

    test('units 5, 6, and 7 each tie back to the detection arc', () {
      for (final id in ['lesson_round_5', 'lesson_round_6', 'lesson_round_7']) {
        expect(
          mentionsDetection(LessonCatalog.all[id]!.readingText),
          isTrue,
          reason: '$id should reconnect to the saliva-detection spine',
        );
      }
    });
  });

  group('terminology: cancer cells are not germs', () {
    test(
      'pancreas biome intro clarifies these are the player\'s own cells',
      () {
        expect(
          BiomeCatalog.pancreas.intro.toLowerCase(),
          contains('not germs'),
        );
      },
    );
  });

  group('quiz distractor corrections', () {
    Iterable<String> allOptions() sync* {
      for (final lesson in LessonCatalog.all.values) {
        for (final q in lesson.questions) {
          yield* q.options;
        }
      }
    }

    test('no implausible "Exactly 0%" KRAS distractor remains', () {
      expect(allOptions(), isNot(contains('Exactly 0%')));
    });

    test('no carotenemia-ambiguous jaundice distractor remains', () {
      expect(
        allOptions(),
        isNot(contains('A person eats too many vegetables')),
      );
    });
  });

  group('resistance slow-motion hit-stop curve', () {
    const total = 0.8, hold = 0.3, target = 0.35;
    double f(double remaining) => resistanceSlowMotionFactor(
      remaining: remaining,
      total: total,
      hold: hold,
      target: target,
    );

    test('full speed outside the window', () {
      expect(f(0), 1.0);
      expect(f(-1), 1.0);
    });

    test('snaps to the slow target and holds at the start', () {
      expect(f(total), closeTo(target, 1e-9)); // instant snap
      expect(f(0.55), closeTo(target, 1e-9)); // still in the hold zone
      expect(f(total - hold), closeTo(target, 1e-9)); // hold boundary
    });

    test('eases back toward full speed and is monotonic in the tail', () {
      // remaining 0.5 -> 0 maps to factor target -> 1.0, strictly increasing.
      var prev = f(0.5);
      for (var r = 0.45; r > 0; r -= 0.05) {
        final cur = f(r);
        expect(cur, greaterThan(prev));
        prev = cur;
      }
      expect(f(0.0001), greaterThan(0.95)); // nearly back to full speed
    });

    test('is always bounded in [target, 1.0], never NaN', () {
      for (var r = -0.2; r <= 1.0; r += 0.02) {
        final v = f(r);
        expect(v.isNaN, isFalse);
        expect(v, greaterThanOrEqualTo(target - 1e-9));
        expect(v, lessThanOrEqualTo(1.0 + 1e-9));
      }
    });

    test(
      'degenerate hold>=total just returns the target inside the window',
      () {
        expect(
          resistanceSlowMotionFactor(
            remaining: 0.4,
            total: 0.5,
            hold: 0.6,
            target: 0.35,
          ),
          closeTo(0.35, 1e-9),
        );
      },
    );
  });
}
