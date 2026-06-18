const int maxLiveMobHardCap = 112;

/// How a wave enters the arena. These patterns create pressure without
/// needing huge live enemy counts.
enum SpawnPattern {
  /// Each enemy picks a fresh random edge point.
  randomEdge,

  /// A burst enters from one edge in a tight cluster.
  edgeCluster,

  /// A burst splits between two opposite edges.
  pincer,

  /// A burst surrounds the arena from evenly spaced edge positions.
  ring,
}

/// A single scheduled spawn within a round: [count] copies of enemy
/// [enemyId] are spawned starting at [delay] seconds into the round.
///
/// [burstSize] controls how many enemies appear at once, while [interval]
/// controls the gap between bursts. [maxAliveGate] can temporarily pause
/// this wave while the arena is crowded, keeping harder rounds playable on
/// slower devices.
class SpawnWave {
  const SpawnWave({
    required this.delay,
    required this.enemyId,
    required this.count,
    required this.interval,
    this.healthMultiplier = 1.0,
    this.pattern = SpawnPattern.randomEdge,
    this.burstSize = 1,
    this.maxAliveGate,
  });

  /// Seconds after round start before this wave begins spawning.
  final double delay;

  /// Key into [EnemyCatalog.all].
  final String enemyId;

  /// Number of enemies to spawn in this wave.
  final int count;

  /// Seconds between each burst within the wave.
  final double interval;

  /// Scales the enemy's base health for this wave (1.0 = unchanged). Used
  /// to escalate difficulty in later rounds without changing the base
  /// [EnemyDef].
  final double healthMultiplier;

  /// Shape of this wave's entry into the arena.
  final SpawnPattern pattern;

  /// Number of enemies to spawn each time this wave ticks.
  final int burstSize;

  /// Optional live-enemy cap for this wave. If omitted, the round's
  /// [RoundDef.activeMobCap] is used.
  final int? maxAliveGate;
}

/// Static definition of a single round's pacing.
class RoundDef {
  const RoundDef({
    required this.roundNumber,
    required this.sectionIndex,
    required this.durationSeconds,
    required this.spawnWaves,
    required this.isBossRound,
    required this.lessonId,
    this.activeMobCap = 36,
    this.allowsExtraMobTypes = false,
    this.eliteBudget = 0,
  });

  /// 1-9.
  final int roundNumber;

  /// 1-3 (each section is 3 rounds).
  final int sectionIndex;

  /// Soft duration cap - the round also ends once all spawned enemies
  /// (and the boss, if any) are defeated.
  final double durationSeconds;

  final List<SpawnWave> spawnWaves;

  /// True for rounds 3, 6, and 9.
  final bool isBossRound;

  /// Key into [LessonCatalog.all] shown after this round.
  final String lessonId;

  /// Soft performance budget for regular mobs. Waves wait while this many
  /// mobs are alive; mitosis children and boss adds can temporarily exceed
  /// it, but scheduled waves will not keep piling on.
  final int activeMobCap;

  /// When true this round may use more than 3 distinct enemy types - boss
  /// rounds and intentionally-marked "hard" rounds. Regular rounds keep the
  /// mix to at most 3 (ideally one per immune category) so the
  /// color -> category read stays clear and a 3-weapon loadout always has a
  /// matched answer.
  final bool allowsExtraMobTypes;

  /// Number of scheduled spawns that should become elite mobs this round.
  /// Elites are spread deterministically across the round's total spawn count.
  final int eliteBudget;

  /// The distinct enemy ids referenced by this round's waves.
  Set<String> get distinctEnemyIds => {
    for (final wave in spawnWaves) wave.enemyId,
  };

  /// Total number of enemies this round will spawn (sum of all wave
  /// counts). Does not include mitosis-split children, which are spawned
  /// dynamically at runtime.
  int get totalSpawnCount =>
      spawnWaves.fold(0, (sum, wave) => sum + wave.count);

  /// Memoization side-table for [eliteSpawnIndexes]. [RoundDef] is a `const`
  /// (canonicalized, immutable) type, so the cache can't be a `late final`
  /// field - it lives off to the side keyed by the instance. The computed set
  /// is identical to evaluating [_computeEliteSpawnIndexes] directly; this just
  /// avoids rebuilding it on every [isEliteSpawnIndex] call (one per spawn).
  static final Expando<Set<int>> _eliteSpawnIndexCache =
      Expando<Set<int>>('eliteSpawnIndexes');

  Set<int> get eliteSpawnIndexes =>
      _eliteSpawnIndexCache[this] ??= _computeEliteSpawnIndexes();

  Set<int> _computeEliteSpawnIndexes() {
    final total = totalSpawnCount;
    final budget = eliteBudget.clamp(0, total).toInt();
    if (budget <= 0 || total <= 0) return const {};

    final indexes = <int>{};
    for (var i = 0; i < budget; i++) {
      var candidate = (((i + 1) * (total + 1)) / (budget + 1))
          .round()
          .clamp(1, total)
          .toInt();
      while (indexes.contains(candidate) && candidate < total) {
        candidate++;
      }
      while (indexes.contains(candidate) && candidate > 1) {
        candidate--;
      }
      indexes.add(candidate);
    }
    return indexes;
  }

  bool isEliteSpawnIndex(int spawnIndex) =>
      eliteSpawnIndexes.contains(spawnIndex);
}
