import 'dart:math';

import 'package:flame/components.dart';

import '../../data/enemies/enemy_catalog.dart';
import '../../data/enemies/enemy_def.dart';
import '../../data/enemies/elite_tuning.dart';
import '../../data/rounds/round_catalog.dart';
import '../../data/rounds/round_def.dart';
import '../components/mob_components/bacteria_component.dart';
import '../components/mob_components/dysplastic_cell_component.dart';
import '../components/mob_components/parasite_component.dart';
import '../components/mob_components/spore_component.dart';
import '../components/mob_components/virus_component.dart';
import '../components/mob_component.dart';
import '../pdac_game.dart';
import 'gameplay_safe_area.dart';

/// Constructs the right [MobComponent] subclass for [def]. Used both by
/// [Spawner] (fresh spawns) and [PdacGame.spawnMobChild] (mitosis splits),
/// so both paths get the same per-archetype rendering/behavior wiring.
MobComponent createMobComponent(
  EnemyDef def,
  Vector2 position, {
  int generation = 0,
  double? healthOverride,
  double? radiusOverride,
  bool isElite = false,
}) {
  switch (def.id) {
    case 'virus':
      return VirusComponent(
        position: position,
        generation: generation,
        healthOverride: healthOverride,
        radiusOverride: radiusOverride,
        isElite: isElite,
      );
    case 'bacteria':
      return BacteriaComponent(
        position: position,
        generation: generation,
        healthOverride: healthOverride,
        radiusOverride: radiusOverride,
        isElite: isElite,
      );
    case 'fungal_spore':
      return SporeComponent(
        position: position,
        generation: generation,
        healthOverride: healthOverride,
        radiusOverride: radiusOverride,
        isElite: isElite,
      );
    case 'parasite':
      return ParasiteComponent(
        position: position,
        generation: generation,
        healthOverride: healthOverride,
        radiusOverride: radiusOverride,
        isElite: isElite,
      );
    case 'dysplastic_cell':
      return DysplasticCellComponent(
        position: position,
        generation: generation,
        healthOverride: healthOverride,
        radiusOverride: radiusOverride,
        isElite: isElite,
      );
    default:
      return MobComponent(
        def: def,
        position: position,
        generation: generation,
        healthOverride: healthOverride,
        radiusOverride: radiusOverride,
        isElite: isElite,
      );
  }
}

/// Drives a [RoundDef]'s [SpawnWave]s, spawning [MobComponent]s at the
/// scheduled times along the arena edges.
class Spawner extends Component with HasGameReference<PdacGame> {
  Spawner(this.roundDef);

  final RoundDef roundDef;

  double _elapsed = 0;

  /// Per-wave count of enemies already spawned.
  final List<int> _spawnedInWave = [];

  /// Per-wave timestamp of the next spawn (seconds since round start).
  final List<double> _nextSpawnAt = [];

  /// Total number of enemies spawned so far (excludes mitosis children).
  int spawnedCount = 0;

  bool get allWavesComplete => spawnedCount >= roundDef.totalSpawnCount;

  @override
  Future<void> onLoad() async {
    for (final wave in roundDef.spawnWaves) {
      _spawnedInWave.add(0);
      _nextSpawnAt.add(wave.delay);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    for (var i = 0; i < roundDef.spawnWaves.length; i++) {
      final wave = roundDef.spawnWaves[i];
      while (_spawnedInWave[i] < wave.count && _elapsed >= _nextSpawnAt[i]) {
        final spawned = _spawnBurst(wave, wave.count - _spawnedInWave[i]);
        if (spawned == 0) {
          // The arena is at its active-mob budget. Check again shortly
          // instead of letting this loop spin forever.
          _nextSpawnAt[i] = _elapsed + 0.25;
          break;
        }
        _spawnedInWave[i] += spawned;
        spawnedCount += spawned;
        _nextSpawnAt[i] += wave.interval;
      }
    }
  }

  int _spawnBurst(SpawnWave wave, int remainingInWave) {
    final def = EnemyCatalog.all[wave.enemyId];
    if (def == null) return 0;

    final cap = min(
      maxLiveMobHardCap,
      wave.maxAliveGate ?? roundDef.activeMobCap,
    );
    final openSlots = max(0, cap - game.activeMobs.length);
    if (openSlots == 0) return 0;

    final requested = wave.burstSize.clamp(1, remainingInWave).toInt();
    final spawnCount = min(requested, openSlots);
    final positions = _spawnPositions(wave.pattern, spawnCount, def.baseRadius);

    final intensity = behaviorIntensityForRound(roundDef.roundNumber);
    for (var i = 0; i < positions.length; i++) {
      final spawnIndex = spawnedCount + i + 1;
      final isElite = roundDef.isEliteSpawnIndex(spawnIndex);
      final mob = createMobComponent(
        def,
        positions[i],
        healthOverride:
            def.baseHealth *
            wave.healthMultiplier *
            (isElite ? eliteHealthMultiplier : 1),
        radiusOverride: isElite ? def.baseRadius * eliteRadiusMultiplier : null,
        isElite: isElite,
      );
      mob.behaviorIntensity = intensity;
      game.spawnMob(mob);
    }
    return spawnCount;
  }

  List<Vector2> _spawnPositions(
    SpawnPattern pattern,
    int count,
    double enemyRadius,
  ) {
    switch (pattern) {
      case SpawnPattern.randomEdge:
        return [
          for (var i = 0; i < count; i++) _edgeSpawnPosition(enemyRadius),
        ];
      case SpawnPattern.edgeCluster:
        return _clusteredEdgePositions(count, enemyRadius);
      case SpawnPattern.pincer:
        return _pincerPositions(count, enemyRadius);
      case SpawnPattern.ring:
        return _ringPositions(count, enemyRadius);
    }
  }

  /// A random point just outside the arena bounds, on one of the 4 edges.
  Vector2 _edgeSpawnPosition(double enemyRadius, [int? forcedEdge]) {
    final arena = game.arenaSize;
    final rng = game.rng;
    const margin = 30.0;
    final edge = _safeEdgeForSpawn(forcedEdge ?? rng.nextInt(4), enemyRadius);
    final hudBlock = topLeftHudBlockForArena(arena);

    switch (edge) {
      case 0: // top
        final minX = hudBlock.right + enemyRadius + hudSpawnEntryPadding;
        return Vector2(minX + rng.nextDouble() * (arena.x - minX), -margin);
      case 1: // bottom
        return Vector2(rng.nextDouble() * arena.x, arena.y + margin);
      case 2: // left
        final minY = hudBlock.bottom + enemyRadius + hudSpawnEntryPadding;
        return Vector2(-margin, minY + rng.nextDouble() * (arena.y - minY));
      default: // right
        return Vector2(arena.x + margin, rng.nextDouble() * arena.y);
    }
  }

  int _safeEdgeForSpawn(int requestedEdge, double enemyRadius) {
    final arena = game.arenaSize;
    final hudBlock = topLeftHudBlockForArena(arena);
    final topHasRoom =
        hudBlock.right + enemyRadius + hudSpawnEntryPadding < arena.x;
    final leftHasRoom =
        hudBlock.bottom + enemyRadius + hudSpawnEntryPadding < arena.y;

    if (requestedEdge == 0 && !topHasRoom) return game.rng.nextBool() ? 1 : 3;
    if (requestedEdge == 2 && !leftHasRoom) return game.rng.nextBool() ? 1 : 3;
    return requestedEdge;
  }

  List<Vector2> _clusteredEdgePositions(int count, double enemyRadius) {
    final rng = game.rng;
    final edge = _safeEdgeForSpawn(rng.nextInt(4), enemyRadius);
    final anchor = _edgeSpawnPosition(enemyRadius, edge);
    final along = edge <= 1 ? Vector2(1, 0) : Vector2(0, 1);
    final spacing = 22.0;
    final midpoint = (count - 1) / 2;
    return [
      for (var i = 0; i < count; i++)
        _sanitizedSpawnPosition(
          anchor +
              along * ((i - midpoint) * spacing + (rng.nextDouble() - 0.5) * 8),
          enemyRadius,
        ),
    ];
  }

  List<Vector2> _pincerPositions(int count, double enemyRadius) {
    final rng = game.rng;
    final firstEdge = _safeEdgeForSpawn(rng.nextInt(4), enemyRadius);
    final oppositeEdge = _safeEdgeForSpawn(firstEdge ^ 1, enemyRadius);
    return [
      for (var i = 0; i < count; i++)
        _edgeSpawnPosition(enemyRadius, i.isEven ? firstEdge : oppositeEdge),
    ];
  }

  List<Vector2> _ringPositions(int count, double enemyRadius) {
    final arena = game.arenaSize;
    final rng = game.rng;
    const margin = 35.0;
    final center = arena / 2;
    final radiusX = arena.x / 2 + margin;
    final radiusY = arena.y / 2 + margin;
    final startAngle = rng.nextDouble() * 2 * pi;
    return [
      for (var i = 0; i < count; i++)
        _sanitizedSpawnPosition(
          Vector2(
            center.x + cos(startAngle + i * 2 * pi / count) * radiusX,
            center.y + sin(startAngle + i * 2 * pi / count) * radiusY,
          ),
          enemyRadius,
        ),
    ];
  }

  Vector2 _sanitizedSpawnPosition(Vector2 position, double enemyRadius) {
    sanitizeSpawnPositionAgainstTopLeftHud(
      position,
      game.arenaSize,
      enemyRadius,
    );
    return position;
  }
}
