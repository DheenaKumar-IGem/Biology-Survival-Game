import 'dart:math';

import 'package:flame/components.dart';

import '../../data/categories.dart';
import '../../data/progression/gun_upgrade_def.dart';
import '../../data/progression/persistent_shop_def.dart';
import '../../data/progression/targeting_upgrade_def.dart';
import '../../data/weapons/weapon_catalog.dart';
import '../../data/weapons/weapon_def.dart';
import '../../data/weapons/weapon_traits.dart';
import '../../services/audio_service.dart';
import '../../services/save_data.dart';
import '../pdac_game.dart';
import 'bullet_component.dart';
import 'mob_component.dart';

/// Fully-resolved stats for a weapon at a point in time, combining its
/// base [WeaponDef] values with persistent (gold shop) upgrades and
/// run-scoped (end-of-round pick) upgrades.
class EffectiveWeaponStats {
  const EffectiveWeaponStats({
    required this.damage,
    required this.fireRate,
    required this.bulletSpeed,
    required this.traitMagnitudes,
  });

  final double damage;
  final double fireRate;
  final double bulletSpeed;
  final Map<WeaponTraitId, double> traitMagnitudes;
}

/// Combines [WeaponDef] base stats + [GunPersistentState] (persistent
/// gold-shop upgrades) + [runUpgradeCount] (end-of-round picks, this run
/// only) into the stats actually used when firing.
EffectiveWeaponStats computeEffectiveStats({
  required WeaponDef base,
  required GunPersistentState persistent,
  required int runUpgradeCount,
  double globalFireRateMultiplier = 1.0,
}) {
  var damage = base.baseDamage;
  var fireRate = base.baseFireRate;
  var bulletSpeed = base.bulletSpeed;

  void applyBonus(WeaponStat stat, double bonus) {
    switch (stat) {
      case WeaponStat.damage:
        damage += bonus;
      case WeaponStat.fireRate:
        fireRate += bonus;
      case WeaponStat.bulletSpeed:
        bulletSpeed += bonus;
    }
  }

  final persistentUpgrade = PersistentShopCatalog.statUpgrades[base.id];
  if (persistentUpgrade != null) {
    applyBonus(
      persistentUpgrade.primaryStat,
      persistentUpgrade.bonusPerLevel * persistent.statLevel,
    );
  }

  final runUpgrade = GunUpgradeCatalog.all[base.id];
  if (runUpgrade != null && runUpgradeCount > 0) {
    applyBonus(runUpgrade.stat, runUpgrade.amount * runUpgradeCount);
  }

  final traitMagnitudes = <WeaponTraitId, double>{};
  if (persistent.unlockedTraits.isNotEmpty) {
    final unlocksForWeapon = PersistentShopCatalog.traitUnlocksFor(base.id);
    for (final traitId in persistent.unlockedTraits) {
      double magnitude = weaponTraitCatalog[traitId]!.defaultMagnitude;
      for (final unlock in unlocksForWeapon) {
        if (unlock.traitId == traitId && unlock.effectMagnitude != null) {
          magnitude = unlock.effectMagnitude!;
          break;
        }
      }
      traitMagnitudes[traitId] = magnitude;
    }
  }

  return EffectiveWeaponStats(
    damage: damage,
    // Clamp to a small positive floor so a future near-zero/negative base or
    // upgrade can never produce an infinite (never fires) or negative (fires
    // every frame) cooldown via the 1/fireRate division in update().
    fireRate: max(0.01, fireRate * globalFireRateMultiplier),
    bulletSpeed: bulletSpeed,
    traitMagnitudes: traitMagnitudes,
  );
}

/// Auto-fires the player's currently equipped weapon at the nearest enemy.
///
/// Added as a child of [PlayerComponent]. Reads the equipped weapon id and
/// effective stats from [PdacGame.gameState] each frame so weapon switches
/// and upgrades take effect immediately.
class WeaponController extends Component with HasGameReference<PdacGame> {
  double _cooldown = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _cooldown -= dt;

    final state = game.gameState;
    final weaponId = state.equippedWeaponId;
    final weaponDef = WeaponCatalog.all[weaponId];
    if (weaponDef == null) {
      game.clearAimTarget();
      return;
    }

    final targeting = state.targetingEffects;

    // Resolve the aim target every frame (even while on cooldown) so the
    // reticle tracks the current target smoothly between shots.
    final targetPosition = _resolveAimTarget(weaponDef);
    if (targetPosition == null) return;
    if (_cooldown > 0) return;

    final stats = computeEffectiveStats(
      base: weaponDef,
      persistent: state.persistentGunState(weaponId),
      runUpgradeCount: state.runUpgradeCount(weaponId),
      globalFireRateMultiplier: targeting.fireRateMultiplier,
    );

    _fire(weaponDef, stats, targetPosition, targeting);
    _cooldown = 1 / stats.fireRate;
  }

  /// Resolves where to fire this frame and publishes the reticle target.
  ///
  /// Manual aim (desktop opt-in): snap to a mob near the cursor (aim assist),
  /// else fire toward the cursor if enemies exist, else HOLD FIRE so it
  /// doesn't spray bullets into an empty arena. Auto-aim otherwise targets the
  /// nearest enemy regardless of colour (threat-priority) - the player swaps to
  /// bring the matching colour to bear.
  Vector2? _resolveAimTarget(WeaponDef weaponDef) {
    if (game.manualAimActive) {
      final cursor = game.mouseWorldPosition;
      final nearCursor = game.nearestMob(cursor, radius: 90);
      if (nearCursor != null) {
        _publishMobTarget(nearCursor, weaponDef.category);
        return nearCursor.position;
      }
      game.clearAimTarget();
      if (game.activeBoss != null ||
          game.nearestMob(game.player.position) != null) {
        return cursor;
      }
      return null;
    }
    return _findNearestTargetPosition(weaponDef.category);
  }

  void _publishMobTarget(MobComponent mob, ImmuneCategory weaponCategory) {
    game.publishAimTarget(
      mob.position,
      mob.radius,
      weaponCategory == mob.def.category,
      weaponCategory,
    );
  }

  /// Nearest aimable target's position, or null when there's nothing to shoot.
  ///
  /// Aim is THREAT-PRIORITY for every weapon: it targets the nearest enemy
  /// regardless of colour (the boss takes priority when it is closer). The
  /// player must SWAP to the weapon whose colour matches that enemy to land
  /// matched (bonus) damage - the swap button is the core skill.
  Vector2? _findNearestTargetPosition(ImmuneCategory weaponCategory) {
    final player = game.player;
    final nearestAny = game.nearestMob(player.position);
    var nearestDist = double.infinity;
    if (nearestAny != null) {
      nearestDist = nearestAny.position.distanceToSquared(player.position);
    }

    final boss = game.activeBoss;
    if (boss != null) {
      final dist = boss.position.distanceToSquared(player.position);
      if (dist < nearestDist) {
        game.publishAimTarget(
          boss.position,
          boss.radius,
          weaponCategory == boss.def.category,
          weaponCategory,
        );
        return boss.position;
      }
    }

    if (nearestAny != null) {
      game.publishAimTarget(
        nearestAny.position,
        nearestAny.radius,
        weaponCategory == nearestAny.def.category,
        weaponCategory,
      );
      return nearestAny.position;
    }

    game.clearAimTarget();
    return null;
  }

  void _fire(
    WeaponDef weaponDef,
    EffectiveWeaponStats stats,
    Vector2 targetPosition,
    TargetingEffects targeting,
  ) {
    final player = game.player;

    final baseDirection = (targetPosition - player.position).normalized();
    final baseAngle = atan2(baseDirection.y, baseDirection.x);
    player.aimToward(baseDirection);
    player.flashMuzzle();

    final pellets = weaponDef.pelletCount;
    final spreadRad = weaponDef.spreadAngleDeg * (pi / 180);

    var anySpawned = false;
    for (var i = 0; i < pellets; i++) {
      double offset = 0;
      if (pellets > 1) {
        offset = spreadRad * ((i / (pellets - 1)) - 0.5);
      } else if (spreadRad > 0) {
        // Small single-shot jitter (e.g. SMG).
        offset = spreadRad * (game.rng.nextDouble() - 0.5);
      }

      anySpawned |= _spawnBulletAtAngle(
        weaponDef,
        stats,
        baseAngle + offset,
        targeting,
      );
    }

    // Global Targeting "Replication": chance to emit one extra projectile at
    // a slight offset. spawnBullet already enforces the live-bullet cap, so
    // this can't blow the budget.
    if (targeting.duplicateChance > 0 &&
        game.rng.nextDouble() < targeting.duplicateChance) {
      final jitter = (game.rng.nextDouble() - 0.5) * 0.18;
      anySpawned |= _spawnBulletAtAngle(
        weaponDef,
        stats,
        baseAngle + jitter,
        targeting,
      );
    }

    // Only play the shoot SFX if a projectile actually spawned, so a shot
    // dropped at the bullet cap doesn't produce sound with no bullet.
    if (anySpawned) {
      AudioService.instance.playSfx('sfx/shoot.wav');
    }
  }

  /// Spawns one bullet; returns true if it was actually added (false at cap).
  bool _spawnBulletAtAngle(
    WeaponDef weaponDef,
    EffectiveWeaponStats stats,
    double angle,
    TargetingEffects targeting,
  ) {
    final dir = Vector2(cos(angle), sin(angle));
    return game.spawnBullet(
      BulletComponent(
        position: game.player.position.clone(),
        direction: dir,
        damage: stats.damage,
        weaponId: weaponDef.id,
        category: weaponDef.category,
        shape: weaponDef.bulletShape,
        speed: stats.bulletSpeed,
        bulletRadius: weaponDef.bulletRadius,
        traitMagnitudes: stats.traitMagnitudes,
        baseHomingTurnRate: targeting.homingTurnRate,
        basePierce: weaponDef.pierceCount,
      ),
    );
  }
}
