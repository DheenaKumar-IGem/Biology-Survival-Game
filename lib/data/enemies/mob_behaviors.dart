import 'package:flame/components.dart' show Vector2;

import '../categories.dart';
import 'enemy_def.dart';

/// Minimal interface a Flame mob component must implement so [MobBehavior]
/// hooks can read/mutate it without `data/` depending on Flame component
/// classes (and without `game/` components depending on each other in a
/// cycle).
abstract class MobController {
  EnemyDef get def;

  bool get isElite;

  double get health;
  set health(double value);
  double get maxHealth;

  /// Shield value (only meaningful for [BiofilmShieldBehavior]). Absorbs
  /// damage before [health] does.
  double get shield;
  set shield(double value);

  /// How long it has been since this mob last took damage, in seconds.
  /// Used by [BiofilmShieldBehavior] to know when to start regenerating.
  double get timeSinceLastDamage;

  /// Mitosis generation - 0 for an original spawn, incremented for each
  /// split. Capped by [MitosisBehavior.maxGenerations].
  int get generation;

  /// Round-scaled intensity (>= 1.0) applied to this mob's behavior knobs so
  /// characteristics (shields, clouds, regen, support) "shine" more in later
  /// rounds. 1.0 in round 1; set at spawn from the round number and inherited
  /// by mitosis children. Separate from health scaling.
  double get behaviorIntensity;

  Vector2 get position;
  double get radius;

  /// Movement speed multiplier (1.0 = normal). Used by [EnrageBehavior] to
  /// speed up low-health parasites, and by [WeaponTraitId.cytotoxicSlow] to
  /// temporarily slow a mob.
  double get speedMultiplier;
  set speedMultiplier(double value);

  /// Spawns a child mob of the same [EnemyDef] near this mob's position,
  /// used by [MitosisBehavior].
  void spawnChild({
    required double healthFraction,
    required double radiusFraction,
    required int generation,
  });

  /// Spawns a lingering area-damage cloud at this mob's position, used by
  /// [SporeCloudBehavior].
  void spawnDamageCloud({
    required double radius,
    required double damagePerSecond,
    required double duration,
    double warningSeconds = 0,
  });

  /// Heals nearby allied mobs over time, used by support archetypes.
  void healNearbyAllies({required double radius, required double amount});

  /// Adds temporary shield to nearby allied mobs, capped as a fraction of
  /// each target's max health.
  void shieldNearbyAllies({
    required double radius,
    required double amount,
    required double maxShieldFraction,
  });
}

/// Lifecycle hooks a mob archetype can implement to customize behavior.
/// All methods have empty default implementations so subclasses only
/// override what they need.
abstract class MobBehavior {
  const MobBehavior();

  /// Called once when the mob is spawned (including mitosis children).
  void onSpawn(MobController mob) {}

  /// Called every tick with the elapsed time [dt] in seconds.
  void onTick(MobController mob, double dt) {}

  /// Called when the mob takes [amount] of raw damage, before it's applied
  /// to health/shield. [source] is the immune category of the hit (null for
  /// environmental damage). Return the amount that should actually be applied
  /// to [MobController.health] (after any shield absorption).
  double onDamaged(MobController mob, double amount, ImmuneCategory? source) =>
      amount;

  /// Called when the mob's health reaches zero.
  void onDeath(MobController mob) {}
}

/// No special behavior - damage applies directly to health.
class NoneBehavior extends MobBehavior {
  const NoneBehavior();
}

/// Virus behavior: on death, if this mob hasn't reached [maxGenerations]
/// yet, splits into [splitCount] smaller copies at reduced health.
///
/// This mirrors viral replication/mitosis - destroying one virus can cause
/// it to "divide" into smaller copies before the population is fully wiped
/// out.
class MitosisBehavior extends MobBehavior {
  const MitosisBehavior({
    this.maxGenerations = 1,
    this.splitCount = 1,
    this.healthFraction = 0.5,
    this.radiusFraction = 0.75,
  });

  final int maxGenerations;
  final int splitCount;
  final double healthFraction;
  final double radiusFraction;

  @override
  void onDeath(MobController mob) {
    if (mob.generation >= maxGenerations) return;
    // Every enemy drops at most ONE child on death (elites included) so the
    // population - and the coin economy it feeds - can't balloon as later-round
    // counts and health grow.
    final childCount = splitCount;
    for (var i = 0; i < childCount; i++) {
      mob.spawnChild(
        healthFraction: healthFraction,
        radiusFraction: radiusFraction,
        generation: mob.generation + 1,
      );
    }
  }
}

/// Bacteria behavior: starts with a shield equal to [shieldFraction] of max
/// health. Shield absorbs damage first, and regenerates at
/// [regenPerSecond] (fraction of max health per second) after
/// [regenDelaySeconds] without taking damage.
///
/// Mirrors a biofilm - a protective layer bacteria build that has to be
/// worn down (and can regrow) before the bacteria itself is harmed.
class BiofilmShieldBehavior extends MobBehavior {
  const BiofilmShieldBehavior({
    this.shieldFraction = 0.4,
    this.regenPerSecond = 0.05,
    this.regenDelaySeconds = 2.0,
  });

  final double shieldFraction;
  final double regenPerSecond;
  final double regenDelaySeconds;

  /// The single source of truth for this mob's shield ceiling. Every shield
  /// mutation (spawn, regen, and the mismatched-fire chip path) clamps against
  /// this, so the shield can never exceed its intended fraction of max health.
  /// Elites carry a thicker biofilm (0.65) than the base [shieldFraction].
  double maxShieldFor(MobController mob) =>
      mob.maxHealth * (mob.isElite ? 0.65 : shieldFraction) * mob.behaviorIntensity;

  @override
  void onSpawn(MobController mob) {
    mob.shield = maxShieldFor(mob);
  }

  @override
  void onTick(MobController mob, double dt) {
    final delay = mob.isElite ? 1.4 : regenDelaySeconds;
    if (mob.timeSinceLastDamage < delay) return;
    final regenRate = mob.isElite ? 0.09 : regenPerSecond;
    final maxShield = maxShieldFor(mob);
    if (mob.shield < maxShield) {
      mob.shield = (mob.shield + mob.maxHealth * regenRate * dt).clamp(
        0,
        maxShield,
      );
    }
  }

  /// Fraction of MISMATCHED-category damage that actually wears the biofilm
  /// down. Wrong-color fire barely strips the shield (and never passes through
  /// it), so the player is strongly pushed to swap to the matching antibody
  /// response - but it is kept high enough that *sustained* wrong-color fire
  /// still out-paces shield regen (a base pistol chips ~0.72 shield/s, above
  /// the 0.4 shield/s regen), so a non-swapping player is only slowed, never
  /// permanently hard-walled.
  static const double _mismatchedShieldFactor = 0.30;

  @override
  double onDamaged(MobController mob, double amount, ImmuneCategory? source) {
    if (mob.shield <= 0) return amount;
    final matched = source == null || source == mob.def.category;
    if (matched) {
      if (mob.shield >= amount) {
        mob.shield -= amount;
        return 0;
      }
      final remainder = amount - mob.shield;
      mob.shield = 0;
      return remainder;
    }
    // Mismatched fire only slowly chips the shield and never reaches health
    // while the biofilm holds. Clamp against the shared shield ceiling (not
    // maxHealth) so the upper bound matches the spawn/regen paths.
    mob.shield = (mob.shield - amount * _mismatchedShieldFactor).clamp(
      0,
      maxShieldFor(mob),
    );
    return 0;
  }
}

/// Fungal Spore behavior: on death, leaves a lingering damage cloud that
/// the player must move away from.
///
/// Mirrors how fungal spores can disperse and continue to pose a hazard
/// even after the original organism is destroyed.
class SporeCloudBehavior extends MobBehavior {
  const SporeCloudBehavior({
    this.cloudRadius = 50,
    this.damagePerSecond = 2,
    this.duration = 3,
  });

  final double cloudRadius;
  final double damagePerSecond;
  final double duration;

  @override
  void onDeath(MobController mob) {
    final intensity = mob.behaviorIntensity;
    mob.spawnDamageCloud(
      radius: (mob.isElite ? cloudRadius * 1.35 : cloudRadius) * intensity,
      damagePerSecond:
          (mob.isElite ? damagePerSecond * 1.75 : damagePerSecond) * intensity,
      duration: mob.isElite ? duration * 1.2 : duration,
      warningSeconds: mob.isElite ? 0.35 : 0,
    );
  }
}

/// Parasite behavior: lunges faster once wounded, mirroring a parasite
/// making a desperate dash for a new host as its current one weakens.
///
/// Below [enrageHealthFraction] of max health, speed is boosted by
/// [speedBoost]; above it, speed is normal.
class EnrageBehavior extends MobBehavior {
  const EnrageBehavior({
    this.enrageHealthFraction = 0.5,
    this.speedBoost = 0.6,
  });

  final double enrageHealthFraction;
  final double speedBoost;

  @override
  void onTick(MobController mob, double dt) {
    final fraction = mob.maxHealth == 0 ? 1.0 : mob.health / mob.maxHealth;
    final threshold = mob.isElite ? 0.75 : enrageHealthFraction;
    final boost = (mob.isElite ? 0.9 : speedBoost) * mob.behaviorIntensity;
    mob.speedMultiplier = fraction <= threshold ? 1 + boost : 1.0;
  }
}

/// Dysplastic Cell behavior: slowly regenerates health when left undamaged,
/// mirroring how abnormal cells that evade the immune system keep growing
/// rather than dying off.
class RegenerationBehavior extends MobBehavior {
  const RegenerationBehavior({
    this.regenPerSecond = 0.04,
    this.regenDelaySeconds = 2.5,
  });

  /// Fraction of max health regenerated per second once [regenDelaySeconds]
  /// has passed without taking damage.
  final double regenPerSecond;
  final double regenDelaySeconds;

  @override
  void onTick(MobController mob, double dt) {
    final delay = mob.isElite ? 1.4 : regenDelaySeconds;
    if (mob.timeSinceLastDamage < delay) return;
    if (mob.health >= mob.maxHealth) return;
    final regenRate =
        (mob.isElite ? 0.075 : regenPerSecond) * mob.behaviorIntensity;
    mob.health = (mob.health + mob.maxHealth * regenRate * dt).clamp(
      0,
      mob.maxHealth,
    );
  }
}

/// Biomarker vesicles are fast courier-like targets. When destroyed they
/// release a short signal flare, teaching the player that biological clues
/// can keep spreading after the source is found.
class BiomarkerSignalBehavior extends MobBehavior {
  const BiomarkerSignalBehavior();

  @override
  void onSpawn(MobController mob) {
    mob.speedMultiplier = mob.isElite ? 1.35 : 1.2;
  }

  @override
  void onDeath(MobController mob) {
    final intensity = mob.behaviorIntensity;
    mob.spawnDamageCloud(
      radius: (mob.isElite ? 46 : 38) * intensity,
      damagePerSecond: (mob.isElite ? 3.5 : 2.5) * intensity,
      duration: mob.isElite ? 2.1 : 1.6,
      warningSeconds: mob.isElite ? 0.2 : 0.25,
    );
  }
}

/// Stromal cells represent the tumor microenvironment protecting PDAC. They
/// are not the biggest damage source, but they make nearby mobs much harder
/// to clear if ignored.
class StromalSupportBehavior extends MobBehavior {
  const StromalSupportBehavior({
    this.radius = 92,
    this.healPerSecond = 0.9,
    this.shieldPerSecond = 0.8,
  });

  final double radius;
  final double healPerSecond;
  final double shieldPerSecond;

  @override
  void onTick(MobController mob, double dt) {
    final intensity = mob.behaviorIntensity;
    final supportRadius = mob.isElite ? radius * 1.32 : radius;
    final healRate =
        (mob.isElite ? healPerSecond * 1.45 : healPerSecond) * intensity;
    final shieldRate =
        (mob.isElite ? shieldPerSecond * 1.5 : shieldPerSecond) * intensity;
    mob.healNearbyAllies(radius: supportRadius, amount: healRate * dt);
    mob.shieldNearbyAllies(
      radius: supportRadius,
      amount: shieldRate * dt,
      maxShieldFraction: 0.3,
    );
  }
}

/// Mucin blobs leave sticky, dangerous residue that turns positioning into a
/// real decision instead of a simple kite path.
class MucinTrailBehavior extends MobBehavior {
  const MucinTrailBehavior({
    this.dropIntervalSeconds = 1.15,
    this.cloudRadius = 34,
  });

  final double dropIntervalSeconds;
  final double cloudRadius;

  /// Per-mob elapsed-time accumulator. Behaviors are shared `const` singletons
  /// (see [mobBehaviorCatalog]), so per-instance state lives off to the side
  /// keyed by the mob rather than as a mutable field on the behavior. A null
  /// (never-ticked) entry is treated as "ready" so a fresh blob drops on its
  /// first tick, then on a true [dropIntervalSeconds] cadence after - the
  /// cadence no longer depends on damage timing (which reset the old phase) or
  /// world position.
  static final Expando<_MucinClock> _clocks = Expando<_MucinClock>('mucinClock');

  @override
  void onTick(MobController mob, double dt) {
    final interval = mob.isElite ? 0.82 : dropIntervalSeconds;
    final clock = _clocks[mob] ??= _MucinClock(interval);
    clock.acc += dt;
    if (clock.acc < interval) return;
    clock.acc -= interval;
    final intensity = mob.behaviorIntensity;
    mob.spawnDamageCloud(
      radius: (mob.isElite ? cloudRadius * 1.3 : cloudRadius) * intensity,
      damagePerSecond: (mob.isElite ? 2.6 : 1.8) * intensity,
      duration: mob.isElite ? 2.4 : 2.0,
    );
  }
}

/// Mutable per-mob drop clock for [MucinTrailBehavior]. Seeded at the drop
/// interval so the mob's very first tick drops a cloud, then accumulates real
/// elapsed time for a steady cadence.
class _MucinClock {
  _MucinClock(double interval) : acc = interval;
  double acc;
}

/// Decoys intentionally have no extra behavior; the threat is that they soak
/// targeting attention during mixed waves.
class DecoySignalBehavior extends MobBehavior {
  const DecoySignalBehavior();

  @override
  void onDeath(MobController mob) {
    if (!mob.isElite) return;
    // One decoy on death (was two) - keeps the elite decoy a nuisance without
    // multiplying the count/economy.
    mob.spawnChild(
      healthFraction: 1.0,
      radiusFraction: 0.85,
      generation: mob.generation + 1,
    );
  }
}

/// Resolves an [EnemyBehaviorId] to its [MobBehavior] implementation.
const Map<EnemyBehaviorId, MobBehavior> mobBehaviorCatalog = {
  EnemyBehaviorId.none: NoneBehavior(),
  EnemyBehaviorId.mitosis: MitosisBehavior(),
  EnemyBehaviorId.biofilmShield: BiofilmShieldBehavior(),
  EnemyBehaviorId.sporeCloud: SporeCloudBehavior(),
  EnemyBehaviorId.enrage: EnrageBehavior(),
  EnemyBehaviorId.regeneration: RegenerationBehavior(),
  EnemyBehaviorId.biomarkerSignal: BiomarkerSignalBehavior(),
  EnemyBehaviorId.stromalSupport: StromalSupportBehavior(),
  EnemyBehaviorId.mucinTrail: MucinTrailBehavior(),
  EnemyBehaviorId.decoySignal: DecoySignalBehavior(),
};
