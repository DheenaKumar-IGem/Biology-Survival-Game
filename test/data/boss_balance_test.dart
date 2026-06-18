import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/data/bosses/boss_balance.dart';

void main() {
  group('estimatedPlayerDps', () {
    // REALIZED matched-fire DPS (~15 at round 1, auto-aim = ~full firing uptime)
    // with a flat +6%/round curve, so late bosses aren't HP sponges. HP is
    // sized directly off this.
    test('round 1 baseline is 15 DPS', () {
      expect(estimatedPlayerDps(1), closeTo(15, 1e-9));
    });

    test('grows by 6% per round', () {
      expect(estimatedPlayerDps(2), closeTo(15 * 1.06, 1e-9));
      expect(estimatedPlayerDps(3), closeTo(15 * 1.06 * 1.06, 1e-9));
    });
  });

  group('targetBossFightSeconds', () {
    test('returns the expected duration for each boss round', () {
      // Shortened so boss rounds fit the ~45s round target.
      expect(targetBossFightSeconds(3), 28);
      expect(targetBossFightSeconds(6), 30);
      expect(targetBossFightSeconds(9), 33);
    });
  });

  group('calculateBossBalance', () {
    test('round 3 boss is sized using the round-3 DPS estimate', () {
      final balance = calculateBossBalance(3);
      final expectedMaxHealth = estimatedPlayerDps(3) * targetBossFightSeconds(3);
      expect(balance.maxHealth, closeTo(expectedMaxHealth, 1e-6));
      expect(balance.fightSeconds, targetBossFightSeconds(3));
      expect(balance.addSpawnCount, 2);
    });

    test('add spawn count increases for later bosses', () {
      expect(calculateBossBalance(3).addSpawnCount, 2);
      expect(calculateBossBalance(6).addSpawnCount, 3);
      expect(calculateBossBalance(9).addSpawnCount, 4);
    });

    test('charge damage and contact DPS stay within sane bounds', () {
      for (final round in [3, 6, 9]) {
        final balance = calculateBossBalance(round);
        expect(balance.chargeDamage, greaterThanOrEqualTo(8.0));
        expect(balance.chargeDamage, lessThanOrEqualTo(35.0));
        expect(
          balance.contactDps,
          closeTo(
            (balance.chargeDamage / 6) * bossContactDamagePressureMultiplier,
            1e-9,
          ),
        );
      }
    });

    test('boss max health grows across sections', () {
      final round3 = calculateBossBalance(3);
      final round6 = calculateBossBalance(6);
      final round9 = calculateBossBalance(9);
      expect(round6.maxHealth, greaterThan(round3.maxHealth));
      expect(round9.maxHealth, greaterThan(round6.maxHealth));
    });
  });
}
