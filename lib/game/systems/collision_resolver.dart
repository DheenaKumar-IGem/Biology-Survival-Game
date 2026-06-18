import 'dart:ui';

import '../../data/categories.dart';
import '../../data/weapons/weapon_traits.dart';
import '../../services/audio_service.dart';
import '../../theme/colorblind.dart';
import '../components/boss_component.dart';
import '../components/bullet_component.dart';
import '../components/mob_component.dart';
import '../pdac_game.dart';

/// Pure per-hit damage formula shared by the mob and boss hit paths: applies
/// the category match/mismatch multiplier (with an optional per-target
/// mismatch override) and the target's KRAS resistance multiplier. Extracted
/// so the formula - and the deliberate difference between mobs (per-enemy
/// override) and bosses (global default) - is unit-testable without a Flame
/// harness.
double resolveCategoryDamage({
  required double base,
  required ImmuneCategory target,
  required ImmuneCategory source,
  required double mismatchMultiplier,
  required double resistanceMultiplier,
}) {
  final categoryAdjusted = applyCategoryMultiplier(
    base,
    target,
    source,
    mismatchMultiplier: mismatchMultiplier,
  );
  return categoryAdjusted * resistanceMultiplier;
}

/// Central place where a bullet-vs-mob hit is resolved: category
/// match/mismatch + KRAS resistance multipliers, damage tracking for the
/// mutation mechanic, hit particles, and trait side-effects (exploding
/// rounds, slow, lifesteal).
class CollisionResolver {
  const CollisionResolver._();

  /// Faint grey spark shown when a shot pings off the wrong-category target
  /// (and in the tutorial, off any mismatch). Signals "no effect" without the
  /// rewarding category-colored burst a matched hit gets.
  static const Color _noEffectSpark = Color(0x88AAB7C4);

  static void resolveBulletHit(
    PdacGame game,
    BulletComponent bullet,
    MobComponent mob,
  ) {
    // Tutorial gate: wrong-color fire does NOTHING to the threat, so the player
    // can only clear it by swapping to the matching weapon (the whole lesson).
    // A faint grey "no effect" spark shows the shot pinged off harmlessly.
    if (game.tutorial && bullet.category != mob.def.category) {
      game.spawnParticles(
        position: mob.position.clone(),
        color: _noEffectSpark,
        count: 2,
      );
      return;
    }

    final resisted = resolveCategoryDamage(
      base: bullet.damage,
      target: mob.def.category,
      source: bullet.category,
      mismatchMultiplier: mob.def.mismatchMultiplier,
      resistanceMultiplier:
          mob.resistance.multiplierFor(bullet.category) *
          mob.weaponResistanceMultiplierFor(bullet.weaponId),
    );

    final dealt = mob.applyDamage(resisted, bullet.category);
    final matched = bullet.category == mob.def.category;
    game.gameState.categoryTracker.recordDamage(bullet.category, dealt);
    // Resistance is driven by WRONG-color targeting: a connecting hit counts on
    // contact (even a shielded 0-damage chip) so firing the wrong weapon at a
    // mob builds resistance, while correctly-matched fire never does. Uses the
    // per-target [matched] flag, not whether damage got through.
    game.recordWeaponHit(
      bullet.weaponId,
      matched: matched,
      targetCategory: mob.def.category,
    );
    game.spawnDamageNumber(mob.position, dealt, matched);

    if (matched) {
      if (dealt > 0) {
        AudioService.instance.playSfx('sfx/hit.wav');
      }
      game.spawnParticles(
        position: mob.position.clone(),
        color: colorblindCategoryColor(
          bullet.category,
          game.settings.value.colorblindMode,
        ),
        count: 5,
      );
    } else {
      // Wrong category: no satisfying hit. A faint grey "no effect" spark and
      // no hit sound make the mismatch penalty felt, nudging a weapon swap
      // instead of rewarding ineffective fire (the core color-match lesson).
      game.spawnParticles(
        position: mob.position.clone(),
        color: _noEffectSpark,
        count: 3,
      );
    }

    if (bullet.hasSlow) {
      final fraction =
          bullet.traitMagnitudes[WeaponTraitId.cytotoxicSlow] ?? 0.3;
      mob.applySlow(fraction, 1.5);
    }

    if (bullet.hasLifesteal && dealt > 0) {
      final fraction =
          bullet.traitMagnitudes[WeaponTraitId.lifestealRounds] ?? 0.05;
      game.player.heal(dealt * fraction);
    }

    if (bullet.hasExploding) {
      _applyExplosion(game, bullet, mob);
    }
  }

  /// Same as [resolveBulletHit] but for a [BossComponent] target. Bosses
  /// don't have [MobBehavior] shields/splits, so this is a simpler
  /// damage + tracking + particle path. Trait side-effects (slow,
  /// lifesteal, exploding) still apply.
  static void resolveBulletHitBoss(
    PdacGame game,
    BulletComponent bullet,
    BossComponent boss,
  ) {
    final resisted = resolveCategoryDamage(
      base: bullet.damage,
      target: boss.def.category,
      source: bullet.category,
      // Bosses intentionally stay on the global mismatch default (BossDef has
      // no per-enemy override) and rely on their own KRAS resistance.
      mismatchMultiplier: mismatchedDamageMultiplier,
      resistanceMultiplier: boss.resistance.multiplierFor(bullet.category),
    );

    final dealt = boss.applyDamage(resisted, bullet.category);
    final matched = bullet.category == boss.def.category;
    game.gameState.categoryTracker.recordDamage(bullet.category, dealt);
    // Intentionally NEVER calls recordWeaponHit: the boss is not a
    // weapon-overuse source, so firing at it must not build weapon resistance.
    game.spawnDamageNumber(boss.position, dealt, matched);

    if (matched) {
      if (dealt > 0) {
        AudioService.instance.playSfx('sfx/hit.wav');
      }
      game.spawnParticles(
        position: boss.position.clone(),
        color: colorblindCategoryColor(
          bullet.category,
          game.settings.value.colorblindMode,
        ),
        count: 5,
      );
    } else {
      // Wrong category vs the boss: faint grey "no effect" spark, no hit sound.
      game.spawnParticles(
        position: boss.position.clone(),
        color: _noEffectSpark,
        count: 3,
      );
    }

    if (bullet.hasLifesteal && dealt > 0) {
      final fraction =
          bullet.traitMagnitudes[WeaponTraitId.lifestealRounds] ?? 0.05;
      game.player.heal(dealt * fraction);
    }
  }

  static void _applyExplosion(
    PdacGame game,
    BulletComponent bullet,
    MobComponent epicenter,
  ) {
    final fraction =
        bullet.traitMagnitudes[WeaponTraitId.explodingRounds] ?? 0.5;
    final aoeDamage = bullet.damage * fraction;
    const explosionRadius = 50.0;
    final radiusSquared = explosionRadius * explosionRadius;

    for (final mob in List<MobComponent>.of(
      game.nearbyMobs(epicenter.position, explosionRadius),
    )) {
      if (mob.isDead || mob == epicenter) continue;
      // Explicit distance guard so AoE correctness never depends on the spatial
      // grid being populated (e.g. a query before the first rebuild).
      if (mob.position.distanceToSquared(epicenter.position) > radiusSquared) {
        continue;
      }
      final resisted = resolveCategoryDamage(
        base: aoeDamage,
        target: mob.def.category,
        source: bullet.category,
        mismatchMultiplier: mob.def.mismatchMultiplier,
        resistanceMultiplier:
            mob.resistance.multiplierFor(bullet.category) *
            mob.weaponResistanceMultiplierFor(bullet.weaponId),
      );
      final dealt = mob.applyDamage(resisted, bullet.category);
      game.gameState.categoryTracker.recordDamage(bullet.category, dealt);
      // Note: explosion splash does NOT feed weapon resistance. The player
      // aimed at the epicenter (recorded above); collateral AoE onto adjacent
      // wrong-color mobs is geometry, not deliberate mis-targeting, so counting
      // it would let one rocket unfairly snap the mismatch counter.
    }

    game.spawnParticles(
      position: epicenter.position.clone(),
      color: const Color(0xFFFFA94D),
      count: 10,
    );
  }
}
