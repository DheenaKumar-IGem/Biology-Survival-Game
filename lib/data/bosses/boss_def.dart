import 'dart:ui';

import '../categories.dart';
import '../enemies/enemy_def.dart';
import 'boss_balance.dart';

enum BossAttackStyle { krasClonePulse, stromalFortress, metastaticStorm }

/// Static definition of a boss encounter (rounds 3, 6, 9).
///
/// Boss sizing ([BossBalance]) is computed on demand via [balance] rather
/// than stored, so tuning [calculateBossBalance] automatically updates every
/// boss. [addArchetype] is the minion type spawned at each health threshold
/// in [addThresholdsPercent].
class BossDef {
  const BossDef({
    required this.roundNumber,
    required this.id,
    required this.displayName,
    required this.educationalBlurb,
    required this.category,
    required this.addArchetype,
    required this.addThresholdsPercent,
    required this.chargeTelegraphSeconds,
    required this.chargeCooldownBaseSeconds,
    required this.baseRadius,
    required this.primaryColor,
    required this.accentColor,
    required this.attackStyle,
    this.phaseAddArchetypes = const [],
  });

  final int roundNumber;
  final String id;
  final String displayName;

  /// Shown in the post-fight lesson - ties the encounter to real PDAC
  /// progression / KRAS biology.
  final String educationalBlurb;

  /// The immune-response category this boss is primarily vulnerable to.
  final ImmuneCategory category;

  /// Minion archetype spawned as "adds" at each threshold in
  /// [addThresholdsPercent].
  final EnemyDef addArchetype;

  /// Health-percent thresholds (descending) at which the boss spawns adds.
  final List<int> addThresholdsPercent;

  /// How long the boss's charge attack is telegraphed before it fires.
  final double chargeTelegraphSeconds;

  /// Base cooldown between charge attacks.
  final double chargeCooldownBaseSeconds;

  final double baseRadius;
  final Color primaryColor;
  final Color accentColor;

  /// Controls the boss's phase-specific attack patterns.
  final BossAttackStyle attackStyle;

  /// Extra archetypes available to phase attacks, separate from threshold
  /// adds. Keeps each boss's identity distinct without hard-coding enemy ids.
  final List<EnemyDef> phaseAddArchetypes;

  /// Computed sizing for this boss at [roundNumber].
  BossBalance get balance => calculateBossBalance(roundNumber);
}
