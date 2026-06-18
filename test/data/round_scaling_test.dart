import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/data/enemies/enemy_catalog.dart';
import 'package:pdac_immune_defense/data/rounds/round_catalog.dart';

void main() {
  test('maximum swarm scaling exposes exact round totals and caps', () {
    const expectedTotals = {
      1: 28,
      2: 32,
      3: 24,
      4: 40,
      5: 48,
      6: 30,
      7: 56,
      8: 62,
      9: 40,
    };
    const expectedCaps = {
      1: 37,
      2: 46,
      3: 34,
      4: 64,
      5: 73,
      6: 44,
      7: 78,
      8: 76,
      9: 44,
    };
    const expectedEliteBudgets = {
      1: 0,
      2: 1,
      3: 1,
      4: 2,
      5: 2,
      6: 1,
      7: 3,
      8: 3,
      9: 2,
    };
    const expectedEliteIndexes = {
      1: <int>{},
      2: {17},
      3: {13},
      4: {14, 27},
      5: {16, 33},
      6: {16},
      7: {14, 29, 43},
      8: {16, 32, 47},
      9: {14, 27},
    };

    for (final entry in RoundCatalog.all.entries) {
      final round = entry.value;

      expect(round.totalSpawnCount, expectedTotals[entry.key]);
      expect(round.activeMobCap, expectedCaps[entry.key]);
      expect(maximumSwarmTargetTotal(entry.key), expectedTotals[entry.key]);
      expect(maximumSwarmActiveMobCap(entry.key), expectedCaps[entry.key]);
      expect(eliteBudgetForRound(entry.key), expectedEliteBudgets[entry.key]);
      expect(round.eliteBudget, expectedEliteBudgets[entry.key]);
      expect(round.eliteSpawnIndexes, expectedEliteIndexes[entry.key]);

      for (final wave in round.spawnWaves) {
        expect(
          EnemyCatalog.all.containsKey(wave.enemyId),
          isTrue,
          reason: 'Round ${round.roundNumber} references ${wave.enemyId}',
        );
        if (wave.maxAliveGate != null) {
          expect(wave.maxAliveGate, lessThanOrEqualTo(round.activeMobCap));
        }
      }
    }
  });

  test('every round\'s spawn schedule is compressed into the target window', () {
    // The last wave must start within targetSpawnWindowSeconds so a round
    // doesn't drag waiting on late spawns - this (plus the small totals) is what
    // keeps a typical clear near ~45s. Guards the scaleRoundForMaximumSwarm
    // schedule compression.
    for (final entry in RoundCatalog.all.entries) {
      final lastWaveStart = entry.value.spawnWaves.fold<double>(
        0,
        (m, w) => w.delay > m ? w.delay : m,
      );
      expect(
        lastWaveStart,
        lessThanOrEqualTo(targetSpawnWindowSeconds + 1e-6),
        reason: 'Round ${entry.key} last wave starts at ${lastWaveStart}s',
      );
    }
  });
}
