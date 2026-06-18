import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/data/enemies/enemy_catalog.dart';
import 'package:pdac_immune_defense/data/rounds/round_catalog.dart';

/// Enforces the design rule: a regular (non-boss, non-marked) round shows at
/// most 3 distinct enemy types, so the color -> category read stays clear and
/// a 3-weapon loadout always has a matched answer. Boss rounds and rounds
/// flagged `allowsExtraMobTypes` are exempt.
void main() {
  test('regular rounds use at most 3 distinct enemy types', () {
    for (final entry in RoundCatalog.all.entries) {
      final round = entry.value;
      if (round.isBossRound || round.allowsExtraMobTypes) continue;
      expect(
        round.distinctEnemyIds.length,
        lessThanOrEqualTo(3),
        reason:
            'Round ${entry.key} has too many enemy types: '
            '${round.distinctEnemyIds}',
      );
    }
  });

  test('every wave references a valid enemy id', () {
    for (final entry in RoundCatalog.all.entries) {
      for (final id in entry.value.distinctEnemyIds) {
        expect(
          EnemyCatalog.all.containsKey(id),
          isTrue,
          reason: 'Round ${entry.key} references unknown enemy "$id"',
        );
      }
    }
  });

  test('regular round trios span all three immune categories', () {
    for (final entry in RoundCatalog.all.entries) {
      final round = entry.value;
      if (round.isBossRound || round.allowsExtraMobTypes) continue;
      final categories = {
        for (final id in round.distinctEnemyIds) EnemyCatalog.all[id]!.category,
      };
      expect(
        categories.length,
        3,
        reason:
            'Round ${entry.key} should cover all 3 categories but covers '
            '$categories',
      );
    }
  });
}
