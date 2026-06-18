import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/data/categories.dart';
import 'package:pdac_immune_defense/data/enemies/enemy_catalog.dart';
import 'package:pdac_immune_defense/data/enemies/enemy_def.dart';
import 'package:pdac_immune_defense/data/enemies/mob_behaviors.dart';
import 'package:pdac_immune_defense/game/systems/collision_resolver.dart';

void main() {
  group('applyCategoryMultiplier', () {
    test('matched fire gets the matched bonus', () {
      expect(
        applyCategoryMultiplier(
          10,
          ImmuneCategory.innate,
          ImmuneCategory.innate,
        ),
        closeTo(10 * matchedDamageMultiplier, 1e-9),
      );
    });

    test('mismatched fire uses the global penalty by default', () {
      expect(
        applyCategoryMultiplier(
          10,
          ImmuneCategory.innate,
          ImmuneCategory.cytotoxic,
        ),
        closeTo(10 * mismatchedDamageMultiplier, 1e-9),
      );
    });

    test('a per-enemy mismatch override makes wrong-color fire weaker', () {
      expect(
        applyCategoryMultiplier(
          10,
          ImmuneCategory.innate,
          ImmuneCategory.cytotoxic,
          mismatchMultiplier: 0.1,
        ),
        closeTo(1.0, 1e-9),
      );
    });

    test('the matched bonus is a pinned, real reward over the penalty', () {
      // The whole point: swapping to the right color must be a felt reward,
      // not merely break-even. Pin the value so a silent downgrade is caught.
      expect(matchedDamageMultiplier, 1.4);
      expect(matchedDamageMultiplier, greaterThan(mismatchedDamageMultiplier));
    });

    test('a match keeps its bonus even against a hostile mismatch override', () {
      // The per-enemy override must only affect MISMATCHED hits - a matched
      // hit still gets the full bonus even if the enemy zeroes mismatches.
      expect(
        applyCategoryMultiplier(
          10,
          ImmuneCategory.innate,
          ImmuneCategory.innate,
          mismatchMultiplier: 0,
        ),
        closeTo(10 * matchedDamageMultiplier, 1e-9),
      );
    });

    test('a null (environmental) source is unmodified', () {
      expect(applyCategoryMultiplier(10, ImmuneCategory.innate, null), 10);
    });

    test('gated enemies define a stricter-than-default mismatch multiplier', () {
      for (final id in ['bacteria', 'dysplastic_cell', 'stromal_fibroblast']) {
        expect(
          EnemyCatalog.all[id]!.mismatchMultiplier,
          lessThan(mismatchedDamageMultiplier),
          reason: '$id should punish wrong-color fire more than the default',
        );
      }
    });

    test('every enemy mismatch multiplier is within [0, 1]', () {
      for (final enemy in EnemyCatalog.all.values) {
        expect(enemy.mismatchMultiplier, inInclusiveRange(0, 1));
      }
    });
  });

  group('biofilm shield resists mismatched fire', () {
    test('matched fire strips the shield 1:1; mismatched barely dents it', () {
      const behavior = BiofilmShieldBehavior();

      final matchedMob = _FakeMob(EnemyCatalog.bacteria);
      behavior.onSpawn(matchedMob);
      final shield0 = matchedMob.shield;
      expect(shield0, greaterThan(0));

      // Matched (antibody) fire reduces the shield by the full amount and lets
      // nothing through to health while the shield holds.
      final passedMatched = behavior.onDamaged(
        matchedMob,
        1.0,
        ImmuneCategory.antibody,
      );
      expect(passedMatched, 0);
      expect(matchedMob.shield, closeTo(shield0 - 1.0, 1e-9));

      // The same amount of mismatched fire removes far less of the shield and
      // still passes nothing through.
      final mismatchMob = _FakeMob(EnemyCatalog.bacteria);
      behavior.onSpawn(mismatchMob);
      final passedMismatch = behavior.onDamaged(
        mismatchMob,
        1.0,
        ImmuneCategory.cytotoxic,
      );
      expect(passedMismatch, 0);
      expect(mismatchMob.shield, greaterThan(shield0 - 1.0));
      expect(mismatchMob.shield, lessThan(shield0));
    });

    test('once the shield is gone, damage passes to health again', () {
      const behavior = BiofilmShieldBehavior();
      final mob = _FakeMob(EnemyCatalog.bacteria)..shield = 0;
      expect(behavior.onDamaged(mob, 3.0, ImmuneCategory.cytotoxic), 3.0);
    });
  });

  group('resolveCategoryDamage (resolver wiring)', () {
    test('a mob applies its per-enemy mismatch override', () {
      final bacteria = EnemyCatalog.bacteria; // antibody, mismatch 0.2
      final dealt = resolveCategoryDamage(
        base: 10,
        target: bacteria.category,
        source: ImmuneCategory.innate, // mismatched
        mismatchMultiplier: bacteria.mismatchMultiplier,
        resistanceMultiplier: 1,
      );
      expect(dealt, closeTo(10 * bacteria.mismatchMultiplier, 1e-9));
      expect(dealt, lessThan(10 * mismatchedDamageMultiplier));
    });

    test('the boss path stays on the global mismatch default', () {
      final dealt = resolveCategoryDamage(
        base: 10,
        target: ImmuneCategory.antibody,
        source: ImmuneCategory.innate, // mismatched
        mismatchMultiplier: mismatchedDamageMultiplier,
        resistanceMultiplier: 1,
      );
      expect(dealt, closeTo(10 * mismatchedDamageMultiplier, 1e-9));
    });

    test('matched fire composes the bonus with KRAS resistance', () {
      final dealt = resolveCategoryDamage(
        base: 10,
        target: ImmuneCategory.innate,
        source: ImmuneCategory.innate, // matched
        mismatchMultiplier: 0.2,
        resistanceMultiplier: 0.6,
      );
      expect(dealt, closeTo(10 * matchedDamageMultiplier * 0.6, 1e-9));
    });
  });
}

/// Minimal [MobController] stand-in for exercising [MobBehavior] hooks without
/// the Flame component machinery.
class _FakeMob implements MobController {
  _FakeMob(this.def);

  @override
  final EnemyDef def;
  @override
  bool isElite = false;
  @override
  double health = 8;
  @override
  double maxHealth = 8;
  @override
  double shield = 0;
  @override
  double timeSinceLastDamage = 0;
  @override
  int generation = 0;
  @override
  double behaviorIntensity = 1.0;
  @override
  Vector2 position = Vector2.zero();
  @override
  double radius = 10;
  @override
  double speedMultiplier = 1;

  @override
  void spawnChild({
    required double healthFraction,
    required double radiusFraction,
    required int generation,
  }) {}

  @override
  void spawnDamageCloud({
    required double radius,
    required double damagePerSecond,
    required double duration,
    double warningSeconds = 0,
  }) {}

  @override
  void healNearbyAllies({required double radius, required double amount}) {}

  @override
  void shieldNearbyAllies({
    required double radius,
    required double amount,
    required double maxShieldFraction,
  }) {}
}
