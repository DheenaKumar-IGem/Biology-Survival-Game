import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../data/bosses/boss_def.dart';
import '../../data/categories.dart';
import '../../services/audio_service.dart';
import '../../services/settings_service.dart';
import '../../theme/colorblind.dart';
import '../../ui/widgets/blob_painter.dart';
import '../pdac_game.dart';
import '../systems/gameplay_safe_area.dart';
import '../systems/spawner.dart';
import 'boss_projectile_component.dart';

int bossPhaseForHealthFraction(double healthFraction) {
  final normalized = healthFraction.isFinite
      ? healthFraction.clamp(0.0, 1.0).toDouble()
      : 1.0;
  if (normalized <= 0.33) return 3;
  if (normalized <= 0.66) return 2;
  return 1;
}

double bossChargeCooldownForPhase({
  required double baseSeconds,
  required double healthFraction,
  required int phase,
}) {
  final normalizedHealth = healthFraction.isFinite
      ? healthFraction.clamp(0.0, 1.0).toDouble()
      : 1.0;
  final normalizedPhase = phase.clamp(1, 3).toInt();
  return baseSeconds *
      (0.74 + normalizedHealth * 0.26) *
      (1 - (normalizedPhase - 1) * 0.08);
}

int bossChargeAftershockCount(BossAttackStyle style, int phase) {
  final normalizedPhase = phase.clamp(1, 3).toInt();
  if (normalizedPhase <= 1) return 0;
  return switch (style) {
    BossAttackStyle.krasClonePulse => normalizedPhase - 1,
    BossAttackStyle.stromalFortress => normalizedPhase,
    BossAttackStyle.metastaticStorm => normalizedPhase + 1,
  };
}

/// Boss encounter for rounds 3, 6, and 9 (see `data/bosses/boss_catalog.dart`).
///
/// Sizing comes from [BossDef.balance]. The boss slowly advances on the
/// player, deals continuous contact damage, and periodically telegraphs a
/// locked charge lane before lunging. Later phases leave brief aftershock
/// hazards in that lane so boss fights require repositioning, not only
/// shooting. Crossing each health threshold in
/// [BossDef.addThresholdsPercent] spawns [BossBalance.addSpawnCount] copies
/// of [BossDef.addArchetype] as "adds".
class BossComponent extends PositionComponent with HasGameReference<PdacGame> {
  BossComponent({required this.def, required Vector2 position})
    : maxHealth = def.balance.maxHealth,
      _remainingThresholds = List.of(def.addThresholdsPercent),
      _chargeCooldown = def.chargeCooldownBaseSeconds,
      super(
        position: position,
        size: Vector2.all(def.baseRadius * 2),
        anchor: Anchor.center,
      ) {
    health = maxHealth;
    _hazardCooldown = _nextHazardCooldown();
  }

  /// Slow, steady approach speed (pixels/second) - the boss is a looming
  /// threat, not a fast one.
  static const double approachSpeed = 22;

  /// Speed (pixels/second) while lunging during a charge attack.
  static const double chargeSpeed = 200;

  /// How long the fast lunge itself lasts, after the telegraph.
  static const double chargeDurationSeconds = 0.6;

  final BossDef def;
  final double maxHealth;
  double health = 0;

  final KrasResistanceState resistance = KrasResistanceState();

  bool isDead = false;

  /// Health-percent thresholds (descending) still pending an "adds" spawn.
  final List<int> _remainingThresholds;

  double _chargeCooldown;
  double _hazardCooldown = 0;
  double _projectileCooldown = 2.5;
  double _phaseAddCooldown = 7.0;
  double _telegraph = 0;
  double _chargeTimer = 0;
  bool _charging = false;
  bool _chargeHasHit = false;
  final Vector2 _chargeDirection = Vector2.zero();
  final Vector2 _chargeStartPosition = Vector2.zero();
  int _lastPhase = 1;

  late BlobShapeSpec _spec;
  final FillShaderCache _fillCache = FillShaderCache();
  double _time = 0;
  double _hitFlash = 0;

  double get radius => size.x / 2;

  @override
  Future<void> onLoad() async {
    _spec = BlobShapeSpec.generate(
      rng: Random(hashCode),
      baseRadius: radius,
      quality: game.settings.value.animationQuality,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;
    _time += dt;
    if (_hitFlash > 0) _hitFlash = max(0, _hitFlash - dt * 4);

    final player = game.player;
    final toPlayer = player.position - position;

    if (_telegraph > 0) {
      _telegraph -= dt;
      // Keep tracking the player during the telegraph, then lock the lane in
      // for the final ~0.3s. That commit window is long enough to read and
      // dodge (0.15s was below a new player's reaction time, so the charge felt
      // like it homed), while still defeating a lazy perpendicular sidestep.
      if (_telegraph > 0.3 && toPlayer.length2 > 1) {
        _chargeDirection.setFrom(toPlayer.normalized());
      }
      if (_telegraph <= 0) {
        _charging = true;
        _chargeHasHit = false;
        _chargeTimer = chargeDurationSeconds;
      }
    } else if (_charging) {
      position += _chargeDirection * chargeSpeed * dt;
      _clampToArena();
      _chargeTimer -= dt;
      if (_chargeTimer <= 0) {
        _charging = false;
        _spawnChargeAftershocks();
        _chargeCooldown = _nextChargeCooldown();
      }
    } else {
      if (toPlayer.length2 > 1) {
        position += toPlayer.normalized() * approachSpeed * dt;
        _clampToArena();
      }
      _updateHazardAttack(dt);
      _updateProjectileAttack(dt);
      _updatePhaseAdds(dt);
      _chargeCooldown -= dt;
      if (_chargeCooldown <= 0) {
        _startChargeTelegraph(toPlayer);
      }
    }

    // Continuous contact damage, plus a one-time burst when the charge
    // attack connects.
    final contactDistance = radius + player.size.x / 2;
    final contactVector = player.position - position;
    if (contactVector.length <= contactDistance) {
      player.takeDamage(
        def.balance.contactDps * dt * game.enemyDamageMultiplier,
      );
      if (_charging && !_chargeHasHit) {
        player.takeDamage(
          def.balance.chargeDamage * game.enemyDamageMultiplier,
        );
        game.triggerShake(14, 0.35);
        _chargeHasHit = true;
      }
    }
  }

  /// True while the charge attack is telegraphing (about to lunge) - used
  /// to render a warning glow.
  bool get isTelegraphing => _telegraph > 0;

  double get _healthFraction => maxHealth == 0 ? 1.0 : health / maxHealth;

  int get _phase => bossPhaseForHealthFraction(_healthFraction);

  double _nextChargeCooldown() {
    return bossChargeCooldownForPhase(
      baseSeconds: def.chargeCooldownBaseSeconds,
      healthFraction: _healthFraction,
      phase: _phase,
    );
  }

  void _startChargeTelegraph(Vector2 toPlayer) {
    _telegraph = def.chargeTelegraphSeconds;
    _chargeStartPosition.setFrom(position);
    if (toPlayer.length2 > 1) {
      _chargeDirection.setFrom(toPlayer.normalized());
    } else if (_chargeDirection.length2 <= 1) {
      _chargeDirection.setValues(1, 0);
    }
    AudioService.instance.playSfx('sfx/boss_charge.wav');
    game.hud.contextTip.value = switch (def.attackStyle) {
      BossAttackStyle.krasClonePulse =>
        'Charge lane locked: sidestep the red assay beam before the lunge.',
      BossAttackStyle.stromalFortress =>
        'Stromal charge locked: dash through the gap before the wall follow-up.',
      BossAttackStyle.metastaticStorm =>
        'Metastatic surge locked: move early, then dodge the aftershocks.',
    };
  }

  double _nextHazardCooldown() {
    final base = switch (def.roundNumber) {
      3 => 6.0,
      6 => 5.0,
      9 => 4.2,
      _ => 5.5,
    };
    return base * (0.75 + _healthFraction * 0.25) * (1 - (_phase - 1) * 0.12);
  }

  double _nextProjectileCooldown() {
    return switch (def.attackStyle) {
      BossAttackStyle.krasClonePulse => 4.2 - _phase * 0.45,
      BossAttackStyle.stromalFortress => 4.6 - _phase * 0.35,
      BossAttackStyle.metastaticStorm => 3.8 - _phase * 0.45,
    };
  }

  void _updateHazardAttack(double dt) {
    _hazardCooldown -= dt;
    if (_hazardCooldown > 0) return;
    _spawnHazardPattern();
    _hazardCooldown = _nextHazardCooldown();
  }

  void _spawnHazardPattern() {
    switch (def.attackStyle) {
      case BossAttackStyle.krasClonePulse:
        _spawnPlayerHazardCluster(baseRadius: 42, count: _phase);
      case BossAttackStyle.stromalFortress:
        _spawnHazardWall();
      case BossAttackStyle.metastaticStorm:
        _spawnPlayerHazardCluster(baseRadius: 46, count: _phase + 1);
        if (_phase >= 2) _spawnEdgeHazards();
    }
  }

  void _spawnPlayerHazardCluster({
    required double baseRadius,
    required int count,
  }) {
    final playerPosition = game.player.position.clone();
    final baseAngle = game.rng.nextDouble() * 2 * pi;
    final zoneRadius = baseRadius + _phase * 7;
    final damagePerSecond = max(3.0, def.balance.contactDps * 0.8);

    for (var i = 0; i < count; i++) {
      final offset = i == 0
          ? Vector2.zero()
          : Vector2(
                  cos(baseAngle + i * 2 * pi / count),
                  sin(baseAngle + i * 2 * pi / count),
                ) *
                (70 + _phase * 16);
      final position = playerPosition + offset;
      _clampPositionToArena(position, zoneRadius);
      game.spawnDamageCloud(
        position: position,
        radius: zoneRadius,
        damagePerSecond: damagePerSecond,
        duration: 1.35 + _phase * 0.25,
        warningSeconds: 0.85,
      );
    }
  }

  void _spawnHazardWall() {
    final playerPosition = game.player.position.clone();
    final toPlayer = playerPosition - position;
    final dir = toPlayer.length2 > 1 ? toPlayer.normalized() : Vector2(1, 0);
    final side = Vector2(-dir.y, dir.x);
    final center = position + dir * min(160, toPlayer.length * 0.55);
    final count = 2 + _phase;
    const spacing = 54.0;
    for (var i = 0; i < count; i++) {
      final offsetIndex = i - (count - 1) / 2;
      final hazardPosition = center + side * (offsetIndex * spacing);
      _clampPositionToArena(hazardPosition, 46);
      game.spawnDamageCloud(
        position: hazardPosition,
        radius: 44 + _phase * 4,
        damagePerSecond: max(3.0, def.balance.contactDps),
        duration: 1.8 + _phase * 0.2,
        warningSeconds: 0.9,
      );
    }
  }

  void _spawnEdgeHazards() {
    final count = _phase;
    for (var i = 0; i < count; i++) {
      final edge = game.rng.nextInt(4);
      final arena = game.arenaSize;
      final position = switch (edge) {
        0 => Vector2(game.rng.nextDouble() * arena.x, 42),
        1 => Vector2(game.rng.nextDouble() * arena.x, arena.y - 42),
        2 => Vector2(42, game.rng.nextDouble() * arena.y),
        _ => Vector2(arena.x - 42, game.rng.nextDouble() * arena.y),
      };
      game.spawnDamageCloud(
        position: position,
        radius: 46,
        damagePerSecond: max(3.5, def.balance.contactDps * 0.9),
        duration: 2.1,
        warningSeconds: 0.7,
      );
    }
  }

  void _updateProjectileAttack(double dt) {
    _projectileCooldown -= dt;
    if (_projectileCooldown > 0) return;
    _spawnProjectilePattern();
    _projectileCooldown = _nextProjectileCooldown();
  }

  void _spawnProjectilePattern() {
    switch (def.attackStyle) {
      case BossAttackStyle.krasClonePulse:
        _spawnRadialProjectiles(5 + _phase * 2, speed: 160 + _phase * 18);
      case BossAttackStyle.stromalFortress:
        _spawnAimedFan(3 + _phase, spreadRadians: 0.45 + _phase * 0.08);
      case BossAttackStyle.metastaticStorm:
        _spawnRadialProjectiles(7 + _phase * 3, speed: 175 + _phase * 22);
        _spawnAimedFan(2 + _phase, spreadRadians: 0.32 + _phase * 0.06);
    }
  }

  void _spawnRadialProjectiles(int count, {required double speed}) {
    final startAngle = game.rng.nextDouble() * 2 * pi;
    for (var i = 0; i < count; i++) {
      final angle = startAngle + i * 2 * pi / count;
      _spawnProjectile(Vector2(cos(angle), sin(angle)), speed: speed);
    }
  }

  void _spawnAimedFan(int count, {required double spreadRadians}) {
    final toPlayer = game.player.position - position;
    final baseAngle = toPlayer.length2 > 1
        ? atan2(toPlayer.y, toPlayer.x)
        : game.rng.nextDouble() * 2 * pi;
    final midpoint = (count - 1) / 2;
    for (var i = 0; i < count; i++) {
      final angle =
          baseAngle + (i - midpoint) * spreadRadians / max(1, count - 1);
      _spawnProjectile(
        Vector2(cos(angle), sin(angle)),
        speed: 190 + _phase * 16,
      );
    }
  }

  /// Distinct "environmental hazard" hue for boss projectiles. Deliberately not
  /// an immune-category color (cyan/violet/red) - which would falsely imply a
  /// category interaction on a pure dodge hazard - and not coin gold, so it
  /// can't be confused with coins / gold numbers / the dash-ready button.
  static const Color _projectileHazardColor = Color(0xFFFF7A29);

  void _spawnProjectile(Vector2 direction, {required double speed}) {
    game.spawnBossProjectile(
      BossProjectileComponent(
        position: position.clone(),
        direction: direction,
        speed: speed,
        damage: max(5.0, def.balance.chargeDamage * 0.40),
        color: _projectileHazardColor,
        radius: 7.0 + _phase,
      ),
    );
  }

  void _spawnChargeAftershocks() {
    final count = bossChargeAftershockCount(def.attackStyle, _phase);
    if (count <= 0) return;

    final trail = position - _chargeStartPosition;
    if (trail.length2 <= 1) return;

    final zoneRadius = 30.0 + _phase * 5;
    final damagePerSecond = max(2.5, def.balance.contactDps * 0.65);
    final duration = 0.95 + _phase * 0.18;

    for (var i = 1; i <= count; i++) {
      final fraction = i / (count + 1);
      final hazardPosition = _chargeStartPosition + trail * fraction;
      _clampPositionToArena(hazardPosition, zoneRadius);
      game.spawnDamageCloud(
        position: hazardPosition,
        radius: zoneRadius,
        damagePerSecond: damagePerSecond,
        duration: duration,
        warningSeconds: 0.2,
      );
    }
  }

  void _updatePhaseAdds(double dt) {
    if (def.phaseAddArchetypes.isEmpty || _phase == 1) return;
    _phaseAddCooldown -= dt;
    if (_phaseAddCooldown > 0 ||
        game.activeMobs.length >= game.currentActiveMobCap) {
      return;
    }
    final count = def.attackStyle == BossAttackStyle.metastaticStorm
        ? _phase
        : 1;
    for (var i = 0; i < count; i++) {
      final archetypeIndex = (i + _phase - 2)
          .clamp(0, def.phaseAddArchetypes.length - 1)
          .toInt();
      final archetype = def.phaseAddArchetypes[archetypeIndex];
      final angle = game.rng.nextDouble() * 2 * pi;
      final spawnPos =
          position + Vector2(cos(angle), sin(angle)) * (radius + 42);
      _clampPositionToArena(spawnPos, archetype.baseRadius + 4);
      game.spawnMob(createMobComponent(archetype, spawnPos));
    }
    _phaseAddCooldown = 8.0 - _phase;
  }

  void _clampToArena() {
    _clampPositionToArena(position, radius);
  }

  void _clampPositionToArena(Vector2 target, double margin) {
    clampPointToArena(target, game.arenaSize, margin);
    pushPointOutsideTopLeftHudBlock(target, game.arenaSize, margin);
    clampPointToArena(target, game.arenaSize, margin);
  }

  /// Applies [rawAmount] of damage of [sourceCategory], already adjusted for
  /// category match + resistance multipliers by `CollisionResolver`.
  double applyDamage(double rawAmount, ImmuneCategory sourceCategory) {
    if (isDead) return 0;
    _hitFlash = 1;
    resistance.recordDamage(sourceCategory, rawAmount);

    final before = health;
    health = (health - rawAmount).clamp(0, maxHealth);
    final actuallyDealt = before - health;

    _checkPhaseChange();
    _checkAddThresholds();
    if (health <= 0) die();
    return actuallyDealt;
  }

  void _checkPhaseChange() {
    final phase = _phase;
    if (phase <= _lastPhase) return;
    _lastPhase = phase;
    _hazardCooldown = min(_hazardCooldown, 1.2);
    _projectileCooldown = min(_projectileCooldown, 1.0);
    game.hud.contextTip.value = switch (def.attackStyle) {
      BossAttackStyle.krasClonePulse =>
        'KRAS pulse rising: watch the warning zones and dash after the flash.',
      BossAttackStyle.stromalFortress =>
        'Tumor stroma thickening: support cells and hazard walls are protecting the boss.',
      BossAttackStyle.metastaticStorm =>
        'Metastatic storm: false signals and biomarker carriers are spreading outward.',
    };
  }

  /// Spawns [BossBalance.addSpawnCount] copies of [BossDef.addArchetype]
  /// each time health drops below the next entry in [_remainingThresholds].
  void _checkAddThresholds() {
    if (_remainingThresholds.isEmpty || maxHealth == 0) return;
    final percent = (health / maxHealth) * 100;
    while (_remainingThresholds.isNotEmpty &&
        percent <= _remainingThresholds.first) {
      _remainingThresholds.removeAt(0);
      for (var i = 0; i < def.balance.addSpawnCount; i++) {
        // Honor the per-round active-mob cap (as _updatePhaseAdds does) so a big
        // AoE hit crossing several thresholds at once can't balloon the live
        // count past what the round was tuned for on lower-end devices.
        if (game.activeMobs.length >= game.currentActiveMobCap) break;
        final angle = game.rng.nextDouble() * 2 * pi;
        final spawnPos =
            position + Vector2(cos(angle), sin(angle)) * (radius + 30);
        game.spawnMob(createMobComponent(def.addArchetype, spawnPos));
      }
    }
  }

  void die() {
    if (isDead) return;
    isDead = true;
    game.triggerShake(10, 0.4);
    game.onBossDefeated(this);
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    if (isTelegraphing || _charging) {
      _paintChargeLane(canvas, center);
    }

    final flashColor = isTelegraphing || _charging
        ? const Color(0xFFFF4D4D)
        : const Color(0xFFFFFFFF);
    final flashAmount = isTelegraphing
        ? 0.3 + 0.3 * sin(_time * 20).abs()
        : _hitFlash * 0.6;

    // Experimental sprite path (keeps the charge-lane telegraph above).
    final mode = game.settings.value.colorblindMode;
    if (game.useSprites) {
      final img = game.spritePack.boss();
      if (img != null) {
        final paint = Paint()..filterQuality = FilterQuality.none;
        if (mode != ColorblindMode.none) {
          paint.colorFilter = ColorFilter.mode(
            colorblindCategoryColor(def.category, mode),
            BlendMode.color,
          );
        } else if (flashAmount > 0) {
          paint.colorFilter = ColorFilter.mode(
            flashColor.withValues(alpha: flashAmount.clamp(0.0, 1.0)),
            BlendMode.srcATop,
          );
        }
        canvas.drawImageRect(
          img,
          Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          Rect.fromLTWH(0, 0, size.x, size.y),
          paint,
        );
        canvas.drawCircle(
          center,
          radius * 0.95,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = colorblindCategoryColor(
              def.category,
              mode,
            ).withValues(alpha: 0.85),
        );
        return;
      }
    }

    final primary = flashAmount > 0
        ? Color.lerp(def.primaryColor, flashColor, flashAmount)!
        : def.primaryColor;

    BlobPainter.paint(
      canvas,
      spec: _spec,
      center: center,
      time: game.settings.value.reduceMotion ? 0 : _time,
      primaryColor: primary,
      accentColor: def.accentColor,
      quality: game.settings.value.animationQuality,
      resistanceTier: resistance.totalResistanceTier,
      rimColor: colorblindCategoryColor(def.category, mode),
      fillCache: _fillCache,
    );
  }

  void _paintChargeLane(Canvas canvas, Offset center) {
    if (_chargeDirection.length2 <= 0) return;

    final laneLength = max(game.arenaSize.x, game.arenaSize.y) * 1.25;
    final dir = Offset(_chargeDirection.x, _chargeDirection.y);
    final end = center + dir * laneLength;
    final pulse = isTelegraphing ? 0.55 + 0.45 * sin(_time * 18).abs() : 0.38;
    final baseColor = def.accentColor;

    final glowPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.16 * pulse)
      ..strokeWidth = radius * 0.7
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawLine(center, end, glowPaint);

    final lanePaint = Paint()
      ..color = baseColor.withValues(alpha: 0.42 * pulse)
      ..strokeWidth = max(8.0, radius * 0.18)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, end, lanePaint);

    final corePaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.34 * pulse)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, end, corePaint);
  }
}
