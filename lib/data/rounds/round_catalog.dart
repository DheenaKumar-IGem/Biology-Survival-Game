import 'dart:math';

import 'round_def.dart';

// Per-round total enemy counts, deliberately small so a typical player clears
// each round in ~45s (the round ends only when the arena is cleared - there is
// no timer). Starting points to tune against the PlaytestLogger's
// roundClear.durationSec; counts rise gently across the campaign as player power
// grows. This is a deliberate cut from the old dense-swarm tuning.
const List<int> maximumSwarmTargetTotals = [
  28,
  32,
  24,
  40,
  48,
  30,
  56,
  62,
  40,
];

// Scaled down in step with the lower totals so the smaller rounds aren't
// disproportionately elite-heavy.
const List<int> eliteBudgetsByRound = [0, 1, 1, 2, 2, 1, 3, 3, 2];

/// Every round's spawn schedule is compressed so its LAST wave starts no later
/// than this many seconds in (the base rounds stretch the final wave out to
/// ~50s+, which alone makes a round drag). Combined with the small enemy totals
/// this centers a typical clear near ~45s. Tune via roundClear.durationSec.
const double targetSpawnWindowSeconds = 30;

/// Per-round growth of the cumulative enemy-health multiplier. Pressure does
/// NOT reset each round: enemy HP climbs monotonically so it keeps pace with
/// the player's strengthening weapons. Because counts stay fixed and HP tracks
/// weapon power, time-to-kill (and thus the ~45s round length) stays roughly
/// constant while the challenge rises. Layered on top of each wave's own
/// healthMultiplier. Tune against roundClear.durationSec.
const double enemyHealthGrowthPerRound = 0.11;

/// Cumulative health multiplier for [roundNumber] (R1 = 1.0 … R9 ≈ 1.88).
double enemyHealthScaleForRound(int roundNumber) =>
    1 + (roundNumber.clamp(1, 9) - 1) * enemyHealthGrowthPerRound;

/// Per-round growth of the behavior-intensity multiplier, so enemy
/// characteristics (shields, clouds, regen, support auras, enrage) become more
/// pronounced as the campaign goes on. Gentler than the health curve. Applied
/// to each mob at spawn (and inherited by mitosis children).
const double behaviorIntensityGrowthPerRound = 0.06;

/// Behavior-intensity multiplier for [roundNumber] (R1 = 1.0 … R9 ≈ 1.48).
double behaviorIntensityForRound(int roundNumber) =>
    1 + (roundNumber.clamp(1, 9) - 1) * behaviorIntensityGrowthPerRound;

const Map<int, int> lateRoundActiveMobCaps = {7: 78, 8: 76};
const Map<int, int> bossRoundActiveMobCaps = {3: 34, 6: 44, 9: 44};

int maximumSwarmTargetTotal(int roundNumber) {
  if (roundNumber < 1 || roundNumber > maximumSwarmTargetTotals.length) {
    throw RangeError.range(roundNumber, 1, maximumSwarmTargetTotals.length);
  }
  return maximumSwarmTargetTotals[roundNumber - 1];
}

int eliteBudgetForRound(int roundNumber) {
  if (roundNumber < 1 || roundNumber > eliteBudgetsByRound.length) {
    throw RangeError.range(roundNumber, 1, eliteBudgetsByRound.length);
  }
  return eliteBudgetsByRound[roundNumber - 1];
}

int maximumSwarmActiveMobCap(int roundNumber) {
  final bossCap = bossRoundActiveMobCaps[roundNumber];
  if (bossCap != null) return bossCap;
  final lateCap = lateRoundActiveMobCaps[roundNumber];
  if (lateCap != null) return lateCap;
  return min(maxLiveMobHardCap, 28 + 9 * roundNumber);
}

RoundDef scaleRoundForMaximumSwarm(RoundDef baseRound) {
  final targetTotal = maximumSwarmTargetTotal(baseRound.roundNumber);
  final scale = targetTotal / baseRound.totalSpawnCount;
  final scaleRoot = sqrt(scale);
  final activeMobCap = maximumSwarmActiveMobCap(baseRound.roundNumber);
  final scaledCounts = _scaledWaveCounts(baseRound, targetTotal, scale);

  // Compress the whole schedule so the last wave starts within the target
  // window. <=1.0, applied to delays and intervals alike.
  final maxDelay = baseRound.spawnWaves.fold<double>(
    0,
    (m, w) => w.delay > m ? w.delay : m,
  );
  final scheduleScale = maxDelay <= targetSpawnWindowSeconds
      ? 1.0
      : targetSpawnWindowSeconds / maxDelay;

  // Cumulative, monotonic HP growth so later rounds stay hard against stronger
  // weapons without adding enemies (which would lengthen the round).
  final healthScale = enemyHealthScaleForRound(baseRound.roundNumber);

  return RoundDef(
    roundNumber: baseRound.roundNumber,
    sectionIndex: baseRound.sectionIndex,
    durationSeconds: baseRound.durationSeconds,
    isBossRound: baseRound.isBossRound,
    lessonId: baseRound.lessonId,
    activeMobCap: activeMobCap,
    allowsExtraMobTypes: baseRound.allowsExtraMobTypes,
    eliteBudget: eliteBudgetForRound(baseRound.roundNumber),
    spawnWaves: [
      for (var i = 0; i < baseRound.spawnWaves.length; i++)
        _scaleWave(
          baseRound.spawnWaves[i],
          count: scaledCounts[i],
          scaleRoot: scaleRoot,
          activeMobCap: activeMobCap,
          scheduleScale: scheduleScale,
          healthScale: healthScale,
        ),
    ],
  );
}

List<int> _scaledWaveCounts(RoundDef baseRound, int targetTotal, double scale) {
  final counts = [
    for (final wave in baseRound.spawnWaves)
      max(1, (wave.count * scale).round()),
  ];
  final currentTotal = counts.fold(0, (sum, count) => sum + count);
  counts[counts.length - 1] += targetTotal - currentTotal;

  if (counts.last < 1) {
    var needed = 1 - counts.last;
    counts[counts.length - 1] = 1;
    for (var i = counts.length - 2; i >= 0 && needed > 0; i--) {
      final reduction = min(counts[i] - 1, needed);
      counts[i] -= reduction;
      needed -= reduction;
    }
  }
  return counts;
}

SpawnWave _scaleWave(
  SpawnWave wave, {
  required int count,
  required double scaleRoot,
  required int activeMobCap,
  required double scheduleScale,
  required double healthScale,
}) {
  final scaledBurstSize = min(
    18,
    max(wave.burstSize + 1, (wave.burstSize * scaleRoot).round()),
  );
  final scaledGate = wave.maxAliveGate == null
      ? null
      : min(activeMobCap, max(wave.maxAliveGate!, activeMobCap - 8));

  return SpawnWave(
    delay: wave.delay * scheduleScale,
    enemyId: wave.enemyId,
    count: count,
    interval: max(0.3, wave.interval / scaleRoot * scheduleScale),
    healthMultiplier: wave.healthMultiplier * healthScale,
    pattern: wave.pattern,
    burstSize: scaledBurstSize,
    maxAliveGate: scaledGate,
  );
}

/// All round definitions (1-9), grouped into three sections of three.
/// Rounds 3, 6, and 9 are boss rounds - their regular spawn waves are
/// lighter since [BossDef] (see `data/bosses/boss_catalog.dart`) adds a
/// major encounter plus its own "adds" on top.
///
/// Difficulty escalates via: rising enemy counts, denser spawn intervals,
/// [SpawnWave.healthMultiplier] bumps, and new archetypes introduced over
/// time - [parasite] in round 4, [dysplasticCell] in round 7.
class RoundCatalog {
  RoundCatalog._();

  static const round1 = RoundDef(
    roundNumber: 1,
    sectionIndex: 1,
    durationSeconds: 65,
    isBossRound: false,
    lessonId: 'lesson_round_1',
    activeMobCap: 24,
    spawnWaves: [
      SpawnWave(
        delay: 4.5,
        enemyId: 'virus',
        count: 6,
        interval: 4.0,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 3,
      ),
      SpawnWave(
        delay: 11,
        enemyId: 'virus',
        count: 6,
        interval: 3.0,
        pattern: SpawnPattern.pincer,
        burstSize: 2,
      ),
      SpawnWave(delay: 20, enemyId: 'bacteria', count: 3, interval: 5.0),
      SpawnWave(delay: 30, enemyId: 'fungal_spore', count: 3, interval: 6.0),
      SpawnWave(
        delay: 39,
        enemyId: 'virus',
        count: 6,
        interval: 4.0,
        pattern: SpawnPattern.ring,
        burstSize: 3,
      ),
      SpawnWave(
        delay: 51,
        enemyId: 'bacteria',
        count: 4,
        interval: 4.5,
        pattern: SpawnPattern.pincer,
        burstSize: 2,
      ),
    ],
  );

  static const round2 = RoundDef(
    roundNumber: 2,
    sectionIndex: 1,
    durationSeconds: 75,
    isBossRound: false,
    lessonId: 'lesson_round_2',
    activeMobCap: 28,
    spawnWaves: [
      SpawnWave(
        delay: 0,
        enemyId: 'virus',
        count: 8,
        interval: 3.5,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 4,
      ),
      SpawnWave(
        delay: 8,
        enemyId: 'bacteria',
        count: 4,
        interval: 4.5,
        healthMultiplier: 1.1,
        pattern: SpawnPattern.pincer,
        burstSize: 2,
      ),
      SpawnWave(
        delay: 18,
        enemyId: 'fungal_spore',
        count: 4,
        interval: 5.0,
        healthMultiplier: 1.1,
      ),
      SpawnWave(
        delay: 28,
        enemyId: 'virus',
        count: 8,
        interval: 3.0,
        healthMultiplier: 1.1,
        pattern: SpawnPattern.ring,
        burstSize: 4,
      ),
      SpawnWave(
        delay: 42,
        enemyId: 'bacteria',
        count: 6,
        interval: 4.0,
        healthMultiplier: 1.15,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 2,
      ),
      SpawnWave(
        delay: 54,
        enemyId: 'virus',
        count: 8,
        interval: 2.8,
        healthMultiplier: 1.15,
        pattern: SpawnPattern.pincer,
        burstSize: 4,
      ),
    ],
  );

  /// Boss round (section 1 finale). Light regular spawns - the main
  /// challenge is the boss spawned alongside this round (see
  /// `data/bosses/boss_catalog.dart`).
  static const round3 = RoundDef(
    roundNumber: 3,
    sectionIndex: 1,
    durationSeconds: 90,
    isBossRound: true,
    lessonId: 'lesson_round_3',
    activeMobCap: 24,
    allowsExtraMobTypes: true,
    spawnWaves: [
      SpawnWave(
        delay: 0,
        enemyId: 'virus',
        count: 6,
        interval: 4.0,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 3,
        maxAliveGate: 18,
      ),
      SpawnWave(
        delay: 12,
        enemyId: 'bacteria',
        count: 4,
        interval: 5.0,
        pattern: SpawnPattern.pincer,
        burstSize: 2,
        maxAliveGate: 18,
      ),
      SpawnWave(
        delay: 24,
        enemyId: 'fungal_spore',
        count: 4,
        interval: 6.0,
        maxAliveGate: 18,
      ),
      SpawnWave(
        delay: 34,
        enemyId: 'biomarker_vesicle',
        count: 4,
        interval: 4.0,
        pattern: SpawnPattern.pincer,
        burstSize: 2,
        maxAliveGate: 20,
      ),
      SpawnWave(
        delay: 48,
        enemyId: 'virus',
        count: 6,
        interval: 4.0,
        healthMultiplier: 1.1,
        pattern: SpawnPattern.ring,
        burstSize: 3,
        maxAliveGate: 20,
      ),
    ],
  );

  /// Section 2 opener - introduces [EnemyCatalog.parasite].
  /// Mob trio (one per category): virus (innate) / parasite (antibody) /
  /// fungal_spore (cytotoxic).
  static const round4 = RoundDef(
    roundNumber: 4,
    sectionIndex: 2,
    durationSeconds: 85,
    isBossRound: false,
    lessonId: 'lesson_round_4',
    activeMobCap: 34,
    spawnWaves: [
      SpawnWave(
        delay: 0,
        enemyId: 'virus',
        count: 8,
        interval: 3.0,
        healthMultiplier: 1.2,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 4,
      ),
      SpawnWave(
        delay: 8,
        enemyId: 'parasite',
        count: 6,
        interval: 4.0,
        pattern: SpawnPattern.pincer,
        burstSize: 2,
      ),
      SpawnWave(
        delay: 20,
        enemyId: 'fungal_spore',
        count: 8,
        interval: 4.0,
        healthMultiplier: 1.2,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 2,
      ),
      SpawnWave(
        delay: 34,
        enemyId: 'parasite',
        count: 6,
        interval: 3.5,
        healthMultiplier: 1.1,
        pattern: SpawnPattern.ring,
        burstSize: 3,
      ),
      SpawnWave(
        delay: 42,
        enemyId: 'virus',
        count: 8,
        interval: 3.2,
        healthMultiplier: 1.1,
        pattern: SpawnPattern.pincer,
        burstSize: 4,
      ),
      SpawnWave(
        delay: 48,
        enemyId: 'virus',
        count: 10,
        interval: 2.8,
        healthMultiplier: 1.25,
        pattern: SpawnPattern.pincer,
        burstSize: 5,
      ),
      SpawnWave(
        delay: 60,
        enemyId: 'fungal_spore',
        count: 6,
        interval: 4.5,
        healthMultiplier: 1.2,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 2,
      ),
      SpawnWave(
        delay: 70,
        enemyId: 'parasite',
        count: 6,
        interval: 4.0,
        healthMultiplier: 1.25,
        pattern: SpawnPattern.pincer,
        burstSize: 2,
      ),
    ],
  );

  /// Mob trio (one per category): mucin_blob (innate) / bacteria (antibody) /
  /// stromal_fibroblast (cytotoxic) - a fresh rotation from round 4.
  static const round5 = RoundDef(
    roundNumber: 5,
    sectionIndex: 2,
    durationSeconds: 95,
    isBossRound: false,
    lessonId: 'lesson_round_5',
    activeMobCap: 38,
    spawnWaves: [
      SpawnWave(
        delay: 0,
        enemyId: 'bacteria',
        count: 8,
        interval: 3.5,
        pattern: SpawnPattern.pincer,
        burstSize: 4,
      ),
      SpawnWave(
        delay: 10,
        enemyId: 'mucin_blob',
        count: 10,
        interval: 2.8,
        healthMultiplier: 1.3,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 5,
      ),
      SpawnWave(
        delay: 24,
        enemyId: 'bacteria',
        count: 8,
        interval: 4.0,
        healthMultiplier: 1.3,
        pattern: SpawnPattern.pincer,
        burstSize: 2,
      ),
      SpawnWave(
        delay: 38,
        enemyId: 'stromal_fibroblast',
        count: 6,
        interval: 4.2,
        healthMultiplier: 1.3,
        pattern: SpawnPattern.ring,
        burstSize: 3,
      ),
      SpawnWave(
        delay: 48,
        enemyId: 'mucin_blob',
        count: 6,
        interval: 4.0,
        healthMultiplier: 1.15,
        pattern: SpawnPattern.pincer,
        burstSize: 2,
      ),
      SpawnWave(
        delay: 52,
        enemyId: 'bacteria',
        count: 10,
        interval: 3.0,
        healthMultiplier: 1.15,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 5,
      ),
      SpawnWave(
        delay: 66,
        enemyId: 'mucin_blob',
        count: 10,
        interval: 2.5,
        healthMultiplier: 1.35,
        pattern: SpawnPattern.pincer,
        burstSize: 5,
      ),
      SpawnWave(
        delay: 78,
        enemyId: 'bacteria',
        count: 8,
        interval: 3.8,
        healthMultiplier: 1.35,
        pattern: SpawnPattern.ring,
        burstSize: 4,
      ),
      SpawnWave(
        delay: 84,
        enemyId: 'stromal_fibroblast',
        count: 4,
        interval: 4.5,
        healthMultiplier: 1.15,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 2,
      ),
    ],
  );

  /// Boss round (section 2 finale).
  static const round6 = RoundDef(
    roundNumber: 6,
    sectionIndex: 2,
    durationSeconds: 100,
    isBossRound: true,
    lessonId: 'lesson_round_6',
    activeMobCap: 34,
    allowsExtraMobTypes: true,
    spawnWaves: [
      SpawnWave(
        delay: 0,
        enemyId: 'parasite',
        count: 8,
        interval: 4.0,
        healthMultiplier: 1.2,
        pattern: SpawnPattern.pincer,
        burstSize: 4,
        maxAliveGate: 24,
      ),
      SpawnWave(
        delay: 14,
        enemyId: 'bacteria',
        count: 8,
        interval: 4.5,
        healthMultiplier: 1.25,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 2,
        maxAliveGate: 24,
      ),
      SpawnWave(
        delay: 30,
        enemyId: 'virus',
        count: 8,
        interval: 3.0,
        healthMultiplier: 1.25,
        pattern: SpawnPattern.ring,
        burstSize: 4,
        maxAliveGate: 26,
      ),
      SpawnWave(
        delay: 40,
        enemyId: 'stromal_fibroblast',
        count: 4,
        interval: 5.0,
        healthMultiplier: 1.2,
        pattern: SpawnPattern.pincer,
        burstSize: 2,
        maxAliveGate: 24,
      ),
      SpawnWave(
        delay: 48,
        enemyId: 'fungal_spore',
        count: 6,
        interval: 5.0,
        healthMultiplier: 1.25,
        maxAliveGate: 24,
      ),
      SpawnWave(
        delay: 66,
        enemyId: 'parasite',
        count: 6,
        interval: 3.5,
        healthMultiplier: 1.3,
        pattern: SpawnPattern.pincer,
        burstSize: 3,
        maxAliveGate: 26,
      ),
    ],
  );

  /// Section 3 opener - introduces [EnemyCatalog.dysplasticCell].
  /// Mob trio (one per category): virus (innate) / decoy_signal (antibody) /
  /// dysplastic_cell (cytotoxic). The decoy-heavy mix fits the salivary
  /// "separate real signal from noise" theme and showcases Smart Aim.
  static const round7 = RoundDef(
    roundNumber: 7,
    sectionIndex: 3,
    durationSeconds: 110,
    isBossRound: false,
    lessonId: 'lesson_round_7',
    activeMobCap: 44,
    spawnWaves: [
      SpawnWave(
        delay: 0,
        enemyId: 'virus',
        count: 12,
        interval: 2.8,
        healthMultiplier: 1.4,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 6,
      ),
      SpawnWave(
        delay: 10,
        enemyId: 'dysplastic_cell',
        count: 5,
        interval: 5.0,
        pattern: SpawnPattern.pincer,
      ),
      // Decoy density was halved here (the first sustained decoy exposure used
      // to drown out the real threats before the player owns Smart Aim). The
      // mechanic is still taught - decoys arrive in clusters - just not as a
      // wall. The final wave is a real threat so the swarm-scaling remainder
      // (which lands on the last wave) inflates danger, not clutter.
      SpawnWave(
        delay: 22,
        enemyId: 'decoy_signal',
        count: 5,
        interval: 3.0,
        healthMultiplier: 1.3,
        pattern: SpawnPattern.ring,
        burstSize: 5,
      ),
      SpawnWave(
        delay: 38,
        enemyId: 'decoy_signal',
        count: 6,
        interval: 3.8,
        healthMultiplier: 1.4,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 2,
      ),
      SpawnWave(
        delay: 52,
        enemyId: 'dysplastic_cell',
        count: 10,
        interval: 4.5,
        healthMultiplier: 1.1,
        pattern: SpawnPattern.pincer,
        burstSize: 2,
      ),
      SpawnWave(
        delay: 60,
        enemyId: 'decoy_signal',
        count: 6,
        interval: 2.4,
        pattern: SpawnPattern.ring,
        burstSize: 6,
      ),
      SpawnWave(
        delay: 68,
        enemyId: 'dysplastic_cell',
        count: 12,
        interval: 3.6,
        healthMultiplier: 1.35,
        pattern: SpawnPattern.ring,
        burstSize: 5,
      ),
      SpawnWave(
        delay: 84,
        enemyId: 'virus',
        count: 12,
        interval: 2.4,
        healthMultiplier: 1.45,
        pattern: SpawnPattern.pincer,
        burstSize: 6,
      ),
      SpawnWave(
        delay: 90,
        enemyId: 'virus',
        count: 10,
        interval: 3.4,
        healthMultiplier: 1.25,
        pattern: SpawnPattern.pincer,
        burstSize: 4,
      ),
      SpawnWave(
        delay: 96,
        enemyId: 'dysplastic_cell',
        count: 9,
        interval: 2.8,
        healthMultiplier: 1.4,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 3,
      ),
    ],
  );

  /// Mob trio (one per category): mucin_blob (innate) / parasite (antibody) /
  /// dysplastic_cell (cytotoxic) - a rotation reprising mid-game archetypes.
  static const round8 = RoundDef(
    roundNumber: 8,
    sectionIndex: 3,
    durationSeconds: 130,
    isBossRound: false,
    lessonId: 'lesson_round_8',
    activeMobCap: 50,
    spawnWaves: [
      SpawnWave(
        delay: 0,
        enemyId: 'dysplastic_cell',
        count: 8,
        interval: 4.5,
        pattern: SpawnPattern.pincer,
        burstSize: 2,
      ),
      SpawnWave(
        delay: 14,
        enemyId: 'parasite',
        count: 12,
        interval: 2.8,
        healthMultiplier: 1.3,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 6,
      ),
      SpawnWave(
        delay: 28,
        enemyId: 'mucin_blob',
        count: 14,
        interval: 2.4,
        healthMultiplier: 1.5,
        pattern: SpawnPattern.ring,
        burstSize: 7,
      ),
      SpawnWave(
        delay: 44,
        enemyId: 'parasite',
        count: 12,
        interval: 3.5,
        healthMultiplier: 1.45,
        pattern: SpawnPattern.pincer,
        burstSize: 4,
      ),
      SpawnWave(
        delay: 54,
        enemyId: 'dysplastic_cell',
        count: 8,
        interval: 4.0,
        healthMultiplier: 1.3,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 2,
      ),
      SpawnWave(
        delay: 62,
        enemyId: 'mucin_blob',
        count: 12,
        interval: 3.4,
        healthMultiplier: 1.45,
        pattern: SpawnPattern.ring,
        burstSize: 6,
      ),
      SpawnWave(
        delay: 80,
        enemyId: 'dysplastic_cell',
        count: 10,
        interval: 4.0,
        healthMultiplier: 1.2,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 2,
      ),
      SpawnWave(
        delay: 96,
        enemyId: 'parasite',
        count: 12,
        interval: 2.6,
        healthMultiplier: 1.4,
        pattern: SpawnPattern.pincer,
        burstSize: 6,
      ),
      SpawnWave(
        delay: 104,
        enemyId: 'mucin_blob',
        count: 16,
        interval: 2.2,
        pattern: SpawnPattern.ring,
        burstSize: 8,
      ),
      SpawnWave(
        delay: 112,
        enemyId: 'mucin_blob',
        count: 10,
        interval: 2.4,
        healthMultiplier: 1.55,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 5,
      ),
    ],
  );

  /// Boss round (section 3 finale, final round).
  static const round9 = RoundDef(
    roundNumber: 9,
    sectionIndex: 3,
    durationSeconds: 140,
    isBossRound: true,
    lessonId: 'lesson_round_9',
    activeMobCap: 42,
    allowsExtraMobTypes: true,
    spawnWaves: [
      SpawnWave(
        delay: 0,
        enemyId: 'dysplastic_cell',
        count: 8,
        interval: 4.0,
        healthMultiplier: 1.3,
        pattern: SpawnPattern.pincer,
        burstSize: 2,
        maxAliveGate: 30,
      ),
      SpawnWave(
        delay: 15,
        enemyId: 'parasite',
        count: 12,
        interval: 3.0,
        healthMultiplier: 1.4,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 6,
        maxAliveGate: 32,
      ),
      SpawnWave(
        delay: 32,
        enemyId: 'virus',
        count: 12,
        interval: 2.6,
        healthMultiplier: 1.5,
        pattern: SpawnPattern.ring,
        burstSize: 6,
        maxAliveGate: 34,
      ),
      SpawnWave(
        delay: 50,
        enemyId: 'bacteria',
        count: 10,
        interval: 3.5,
        healthMultiplier: 1.5,
        pattern: SpawnPattern.pincer,
        burstSize: 4,
        maxAliveGate: 32,
      ),
      SpawnWave(
        delay: 72,
        enemyId: 'fungal_spore',
        count: 6,
        interval: 4.5,
        healthMultiplier: 1.55,
        pattern: SpawnPattern.ring,
        burstSize: 3,
        maxAliveGate: 30,
      ),
      SpawnWave(
        delay: 84,
        enemyId: 'biomarker_vesicle',
        count: 10,
        interval: 2.8,
        healthMultiplier: 1.45,
        pattern: SpawnPattern.pincer,
        burstSize: 5,
        maxAliveGate: 32,
      ),
      SpawnWave(
        delay: 96,
        enemyId: 'dysplastic_cell',
        count: 6,
        interval: 4.0,
        healthMultiplier: 1.45,
        pattern: SpawnPattern.edgeCluster,
        burstSize: 2,
        maxAliveGate: 32,
      ),
      SpawnWave(
        delay: 108,
        enemyId: 'decoy_signal',
        count: 14,
        interval: 2.4,
        pattern: SpawnPattern.ring,
        burstSize: 7,
        maxAliveGate: 34,
      ),
    ],
  );

  /// All rounds, indexed by round number (1-9).
  static final Map<int, RoundDef> all = {
    1: scaleRoundForMaximumSwarm(round1),
    2: scaleRoundForMaximumSwarm(round2),
    3: scaleRoundForMaximumSwarm(round3),
    4: scaleRoundForMaximumSwarm(round4),
    5: scaleRoundForMaximumSwarm(round5),
    6: scaleRoundForMaximumSwarm(round6),
    7: scaleRoundForMaximumSwarm(round7),
    8: scaleRoundForMaximumSwarm(round8),
    9: scaleRoundForMaximumSwarm(round9),
  };
}
