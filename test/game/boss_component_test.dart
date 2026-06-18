import 'package:flutter_test/flutter_test.dart';

import 'package:pdac_immune_defense/data/bosses/boss_def.dart';
import 'package:pdac_immune_defense/game/components/boss_component.dart';

void main() {
  test('boss phase helper maps health fraction into three phases', () {
    expect(bossPhaseForHealthFraction(1), 1);
    expect(bossPhaseForHealthFraction(0.67), 1);
    expect(bossPhaseForHealthFraction(0.66), 2);
    expect(bossPhaseForHealthFraction(0.50), 2);
    expect(bossPhaseForHealthFraction(0.33), 3);
    expect(bossPhaseForHealthFraction(0), 3);
    expect(bossPhaseForHealthFraction(double.nan), 1);
  });

  test('boss charge cooldown gets faster in later phases', () {
    final fullHealth = bossChargeCooldownForPhase(
      baseSeconds: 10,
      healthFraction: 1,
      phase: 1,
    );
    final midHealth = bossChargeCooldownForPhase(
      baseSeconds: 10,
      healthFraction: 0.5,
      phase: 2,
    );
    final lowHealth = bossChargeCooldownForPhase(
      baseSeconds: 10,
      healthFraction: 0,
      phase: 3,
    );

    expect(fullHealth, closeTo(10, 1e-9));
    expect(midHealth, lessThan(fullHealth));
    expect(lowHealth, lessThan(midHealth));
    expect(lowHealth, closeTo(10 * 0.74 * 0.84, 1e-9));
  });

  test('boss charge aftershocks scale by attack style and phase', () {
    for (final style in BossAttackStyle.values) {
      expect(bossChargeAftershockCount(style, 1), 0);
    }

    expect(bossChargeAftershockCount(BossAttackStyle.krasClonePulse, 2), 1);
    expect(bossChargeAftershockCount(BossAttackStyle.krasClonePulse, 3), 2);

    expect(bossChargeAftershockCount(BossAttackStyle.stromalFortress, 2), 2);
    expect(bossChargeAftershockCount(BossAttackStyle.stromalFortress, 3), 3);

    expect(bossChargeAftershockCount(BossAttackStyle.metastaticStorm, 2), 3);
    expect(bossChargeAftershockCount(BossAttackStyle.metastaticStorm, 3), 4);
  });
}
