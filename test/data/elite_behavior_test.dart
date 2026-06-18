import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/data/enemies/enemy_catalog.dart';
import 'package:pdac_immune_defense/data/enemies/enemy_def.dart';
import 'package:pdac_immune_defense/data/enemies/mob_behaviors.dart';

void main() {
  group('elite species traits', () {
    test('every virus (elite included) splits into exactly one child', () {
      final mob = _FakeMob(def: EnemyCatalog.virus, isElite: true);

      const MitosisBehavior().onDeath(mob);

      expect(mob.children, hasLength(1));
      expect(mob.children.every((child) => child.generation == 1), isTrue);
      expect(mob.children.first.healthFraction, 0.5);
      expect(mob.children.first.radiusFraction, 0.75);
    });

    test('bacteria elites start with a stronger biofilm shield', () {
      final normal = _FakeMob(def: EnemyCatalog.bacteria, maxHealth: 10);
      final elite = _FakeMob(
        def: EnemyCatalog.bacteria,
        isElite: true,
        maxHealth: 10,
      );

      const BiofilmShieldBehavior().onSpawn(normal);
      const BiofilmShieldBehavior().onSpawn(elite);

      expect(normal.shield, closeTo(4, 1e-9));
      expect(elite.shield, closeTo(6.5, 1e-9));
    });

    test('fungal spore elites leave a stronger warning cloud', () {
      final mob = _FakeMob(def: EnemyCatalog.fungalSpore, isElite: true);

      const SporeCloudBehavior().onDeath(mob);

      expect(mob.clouds, hasLength(1));
      expect(mob.clouds.single.radius, closeTo(67.5, 1e-9));
      expect(mob.clouds.single.damagePerSecond, closeTo(3.5, 1e-9));
      expect(mob.clouds.single.duration, closeTo(3.6, 1e-9));
      expect(mob.clouds.single.warningSeconds, greaterThan(0));
    });

    test('parasite elites enrage earlier and faster', () {
      final normal = _FakeMob(
        def: EnemyCatalog.parasite,
        health: 70,
        maxHealth: 100,
      );
      final elite = _FakeMob(
        def: EnemyCatalog.parasite,
        isElite: true,
        health: 70,
        maxHealth: 100,
      );

      const EnrageBehavior().onTick(normal, 1);
      const EnrageBehavior().onTick(elite, 1);

      expect(normal.speedMultiplier, 1);
      expect(elite.speedMultiplier, closeTo(1.9, 1e-9));
    });

    test('dysplastic cell elites regenerate sooner and faster', () {
      final normal = _FakeMob(
        def: EnemyCatalog.dysplasticCell,
        health: 50,
        maxHealth: 100,
        timeSinceLastDamage: 2,
      );
      final elite = _FakeMob(
        def: EnemyCatalog.dysplasticCell,
        isElite: true,
        health: 50,
        maxHealth: 100,
        timeSinceLastDamage: 2,
      );

      const RegenerationBehavior().onTick(normal, 1);
      const RegenerationBehavior().onTick(elite, 1);

      expect(normal.health, 50);
      expect(elite.health, closeTo(57.5, 1e-9));
    });

    test('biomarker vesicle elites move faster and flare harder', () {
      final mob = _FakeMob(def: EnemyCatalog.biomarkerVesicle, isElite: true);

      const BiomarkerSignalBehavior().onSpawn(mob);
      const BiomarkerSignalBehavior().onDeath(mob);

      expect(mob.speedMultiplier, closeTo(1.35, 1e-9));
      expect(mob.clouds.single.radius, 46);
      expect(mob.clouds.single.damagePerSecond, 3.5);
    });

    test('stromal elites expand their support aura', () {
      final mob = _FakeMob(def: EnemyCatalog.stromalFibroblast, isElite: true);

      const StromalSupportBehavior().onTick(mob, 1);

      expect(mob.heals.single.radius, greaterThan(92));
      expect(mob.heals.single.amount, greaterThan(0.9));
      expect(mob.shields.single.amount, greaterThan(0.8));
      expect(mob.shields.single.maxShieldFraction, 0.3);
    });

    test('mucin elites drop larger sticky hazards more often', () {
      final mob = _FakeMob(
        def: EnemyCatalog.mucinBlob,
        isElite: true,
        timeSinceLastDamage: 0,
      );

      const MucinTrailBehavior().onTick(mob, 0.01);

      expect(mob.clouds.single.radius, closeTo(44.2, 1e-9));
      expect(mob.clouds.single.damagePerSecond, 2.6);
    });

    test('decoy elites split into one decoy', () {
      final mob = _FakeMob(def: EnemyCatalog.decoySignal, isElite: true);

      const DecoySignalBehavior().onDeath(mob);

      expect(mob.children, hasLength(1));
      expect(mob.children.first.generation, 1);
    });
  });
}

class _FakeMob implements MobController {
  _FakeMob({
    required this.def,
    this.isElite = false,
    this.health = 10,
    this.maxHealth = 10,
    this.timeSinceLastDamage = 999,
    Vector2? position,
  }) : position = position ?? Vector2.zero();

  @override
  final EnemyDef def;

  @override
  final bool isElite;

  @override
  double health;

  @override
  final double maxHealth;

  @override
  double shield = 0;

  @override
  final double timeSinceLastDamage;

  @override
  final int generation = 0;

  @override
  double behaviorIntensity = 1.0;

  @override
  final Vector2 position;

  @override
  final double radius = 10;

  @override
  double speedMultiplier = 1;

  final List<_ChildSpawn> children = [];
  final List<_CloudSpawn> clouds = [];
  final List<_SupportPulse> heals = [];
  final List<_SupportPulse> shields = [];

  @override
  void spawnChild({
    required double healthFraction,
    required double radiusFraction,
    required int generation,
  }) {
    children.add(
      _ChildSpawn(
        healthFraction: healthFraction,
        radiusFraction: radiusFraction,
        generation: generation,
      ),
    );
  }

  @override
  void spawnDamageCloud({
    required double radius,
    required double damagePerSecond,
    required double duration,
    double warningSeconds = 0,
  }) {
    clouds.add(
      _CloudSpawn(
        radius: radius,
        damagePerSecond: damagePerSecond,
        duration: duration,
        warningSeconds: warningSeconds,
      ),
    );
  }

  @override
  void healNearbyAllies({required double radius, required double amount}) {
    heals.add(_SupportPulse(radius: radius, amount: amount));
  }

  @override
  void shieldNearbyAllies({
    required double radius,
    required double amount,
    required double maxShieldFraction,
  }) {
    shields.add(
      _SupportPulse(
        radius: radius,
        amount: amount,
        maxShieldFraction: maxShieldFraction,
      ),
    );
  }
}

class _ChildSpawn {
  const _ChildSpawn({
    required this.healthFraction,
    required this.radiusFraction,
    required this.generation,
  });

  final double healthFraction;
  final double radiusFraction;
  final int generation;
}

class _CloudSpawn {
  const _CloudSpawn({
    required this.radius,
    required this.damagePerSecond,
    required this.duration,
    required this.warningSeconds,
  });

  final double radius;
  final double damagePerSecond;
  final double duration;
  final double warningSeconds;
}

class _SupportPulse {
  const _SupportPulse({
    required this.radius,
    required this.amount,
    this.maxShieldFraction,
  });

  final double radius;
  final double amount;
  final double? maxShieldFraction;
}
