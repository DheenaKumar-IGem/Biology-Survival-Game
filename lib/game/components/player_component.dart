import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../theme/palette.dart';
import '../../ui/widgets/blob_painter.dart';
import '../pdac_game.dart';
import '../systems/gameplay_safe_area.dart';
import 'weapon_controller.dart';

/// The player's immune cell. Movement is keyboard-driven (WASD/arrows,
/// read from [PdacGame.pressedKeys]); firing is handled entirely by
/// [WeaponController], which auto-targets the nearest enemy.
class PlayerComponent extends PositionComponent
    with HasGameReference<PdacGame> {
  PlayerComponent({required Vector2 position})
    : super(position: position, size: Vector2.all(36), anchor: Anchor.center);

  static const double moveSpeed = 200;
  static const double dashDistance = 145;
  static const double dashDurationSeconds = 0.16;
  static const double dashCooldownSeconds = 1.1;
  // Lengthened from 0.08 so the dash i-frame window (~0.30s total) is long
  // enough to actually punch through a surround rather than ending mid-overlap.
  static const double dashInvulnerabilityBuffer = 0.14;
  // After any hit, briefly ignore further contact/regular damage so a cluster
  // of overlapping mobs can't delete the 100 HP pool in a fraction of a second
  // (cornering used to be instant death). Kept short so the player is never
  // effectively immortal - sustained pressure still wears HP down.
  static const double postHitGraceSeconds = 0.45;
  // How far the dash shoves nearby mobs, and the radius it reaches. The shove
  // is what actually breaks a surround; the i-frames just keep you alive while
  // it happens.
  static const double dashKnockback = 64;
  static const double dashKnockbackRadius = 64;
  // Slow out-of-combat regen: after this many seconds without taking damage,
  // HP trickles back at [regenPerSecond]. This is the late-round attrition
  // valve - it rewards disengaging/kiting (dash out, break line of sight) and
  // never triggers under sustained swarm contact, so it doesn't trivialize the
  // fight. Difficulty already scales incoming damage, which self-limits how
  // much regen a player can earn on harder settings.
  static const double regenDelaySeconds = 4.0;
  static const double regenPerSecond = 2.5;

  double maxHp = 100;
  double hp = 100;

  late WeaponController weaponController;
  late BlobShapeSpec _spec;
  final FillShaderCache _fillCache = FillShaderCache();
  double _time = 0;
  double _hitFlash = 0;
  double _dashTimer = 0;
  double _dashCooldownRemaining = 0;
  double _invulnerableTimer = 0;
  double _postHitGrace = 0;
  // Seconds since the player last took (or banked) damage. Drives the slow
  // out-of-combat regen valve; reset to 0 on any contact.
  double _timeSinceDamage = 0;
  // Damage that arrived during the post-hit grace window. It is not discarded
  // (that would make a single mob's contact DPS nearly free) - it is buffered
  // and flushed as one survivable "bite" when the grace expires, so a swarm
  // bleeds the player in ~0.45s pulses instead of an instantaneous wipe.
  double _bufferedDamage = 0;
  final Vector2 _lastMoveDirection = Vector2(1, 0);
  final Vector2 _dashDirection = Vector2.zero();
  final Vector2 _aimDirection = Vector2(1, 0);
  double _muzzleFlashTimer = 0;
  static final Paint _spritePaint = Paint()..filterQuality = FilterQuality.none;

  bool get isDashing => _dashTimer > 0;
  bool get canDash => _dashCooldownRemaining <= 0 && !isDashing;
  double get dashChargeFraction => _dashCooldownRemaining <= 0
      ? 1
      : (1 - _dashCooldownRemaining / dashCooldownSeconds).clamp(0.0, 1.0);

  @override
  Future<void> onLoad() async {
    _spec = BlobShapeSpec.generate(
      rng: Random(1),
      baseRadius: size.x / 2,
      quality: game.settings.value.animationQuality,
    );
    weaponController = WeaponController();
    add(weaponController);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    if (_hitFlash > 0) _hitFlash = max(0, _hitFlash - dt * 3);
    if (_muzzleFlashTimer > 0) {
      _muzzleFlashTimer = max(0, _muzzleFlashTimer - dt);
    }

    // Manual aim tracks the cursor live so facing stays smooth between shots.
    if (game.manualAimActive) {
      final toMouse = game.mouseWorldPosition - position;
      if (toMouse.length2 > 1) _aimDirection.setFrom(toMouse.normalized());
    }
    if (_dashCooldownRemaining > 0) {
      _dashCooldownRemaining = max(0, _dashCooldownRemaining - dt);
    }
    if (_invulnerableTimer > 0) {
      _invulnerableTimer = max(0, _invulnerableTimer - dt);
    }
    if (_postHitGrace > 0) {
      _postHitGrace = max(0, _postHitGrace - dt);
      // Grace just ended this frame with damage banked up: deliver it as one
      // bite (which re-arms the grace), keeping total throughput honest.
      if (_postHitGrace <= 0 && _bufferedDamage > 0) {
        // Cap the flushed pulse to a fraction of max HP so a dense surround
        // can't one-shot a low-HP player through banked damage.
        final bite = _bufferedDamage.clamp(0, maxHp * 0.34).toDouble();
        _bufferedDamage = 0;
        takeDamage(bite);
      }
    }

    // Out-of-combat regen valve: only ticks once the player has gone
    // [regenDelaySeconds] without contact, so it rewards disengaging rather
    // than tanking. No-op in the tutorial (player is already at full HP).
    if (!game.tutorial) {
      _timeSinceDamage += dt;
      if (_timeSinceDamage >= regenDelaySeconds && hp < maxHp) {
        heal(regenPerSecond * dt);
      }
    }

    final direction = Vector2.zero();
    final keys = game.pressedKeys;
    if (keys.contains(PdacKey.up)) direction.y -= 1;
    if (keys.contains(PdacKey.down)) direction.y += 1;
    if (keys.contains(PdacKey.left)) direction.x -= 1;
    if (keys.contains(PdacKey.right)) direction.x += 1;

    Vector2 moveVector = Vector2.zero();
    if (direction.length2 > 0) {
      moveVector = direction.normalized();
    } else {
      final joystick = game.joystick;
      if (joystick != null) {
        final joystickDelta = joystick.relativeDelta;
        if (joystickDelta.length2 > 0.01) {
          moveVector = joystickDelta;
        }
      }
    }

    if (moveVector.length2 > 0) {
      _lastMoveDirection.setFrom(moveVector.normalized());
    }

    if (isDashing) {
      position += _dashDirection * (dashDistance / dashDurationSeconds) * dt;
      _dashTimer = max(0, _dashTimer - dt);
    } else if (moveVector.length2 > 0) {
      position += moveVector * moveSpeed * dt;
    }

    final r = size.x / 2;
    clampPointToArena(position, game.arenaSize, r);
    pushPointOutsideTopLeftHudBlock(position, game.arenaSize, r);
    clampPointToArena(position, game.arenaSize, r);
  }

  /// Starts a short invulnerable dash in the last movement direction.
  /// Returns false if the dash is still on cooldown.
  bool tryDash() {
    if (!canDash) return false;
    _dashDirection.setFrom(_lastMoveDirection);
    if (_dashDirection.length2 <= 0.01) {
      _dashDirection.setValues(1, 0);
    } else {
      _dashDirection.normalize();
    }
    _dashTimer = dashDurationSeconds;
    _dashCooldownRemaining = dashCooldownSeconds;
    _invulnerableTimer = dashDurationSeconds + dashInvulnerabilityBuffer;
    _shoveNearbyMobs();
    game.triggerShake(4, 0.12);
    return true;
  }

  /// Pushes mobs within [dashKnockbackRadius] away from the player so a dash
  /// can actually break a surround instead of just sliding through it. The
  /// shove scales down with distance and is clamped inside the arena so a mob
  /// can't be punted into the HUD block or out of bounds.
  void _shoveNearbyMobs() {
    final reach = dashKnockbackRadius;
    for (final mob in game.activeMobs) {
      if (mob.isDead) continue;
      final away = mob.position - position;
      final dist = away.length;
      if (dist > reach || dist <= 0.0001) continue;
      final falloff = 1 - (dist / reach);
      mob.position += away.normalized() * (dashKnockback * falloff);
      clampPointToArena(mob.position, game.arenaSize, mob.radius);
      pushPointOutsideTopLeftHudBlock(mob.position, game.arenaSize, mob.radius);
      clampPointToArena(mob.position, game.arenaSize, mob.radius);
    }
  }

  /// Applies [amount] of incoming damage, clamped to >= 0 HP. Triggers
  /// [PdacGame.onPlayerDied] if HP reaches 0.
  void takeDamage(double amount) {
    if (amount <= 0) return;
    if (game.tutorial) return; // training arena: the player can't be hurt.
    // Dash i-frames make the hit a clean miss (damage is discarded outright).
    if (_invulnerableTimer > 0) return;
    // Any real contact (applied or banked) counts as "in combat" and resets the
    // out-of-combat regen delay.
    _timeSinceDamage = 0;
    // During the post-hit grace the player can't be chain-deleted by a cluster
    // of overlapping mobs - incoming damage is banked and flushed as one bite
    // when the grace expires (see update), so a single source's DPS is kept
    // honest while a swarm only lands one survivable pulse per window.
    if (_postHitGrace > 0) {
      _bufferedDamage += amount;
      return;
    }
    _hitFlash = 1;
    _postHitGrace = postHitGraceSeconds;
    hp = (hp - amount).clamp(0, maxHp);
    game.triggerShake((amount * 0.8).clamp(2, 12), 0.2);
    game.onPlayerDamaged();
    if (hp <= 0) {
      game.onPlayerDied();
    }
  }

  /// Heals [amount] HP, used by the lifesteal weapon trait.
  void heal(double amount) {
    if (amount <= 0) return;
    hp = (hp + amount).clamp(0, maxHp);
    game.onPlayerDamaged();
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    // Avatar is near-white, so a take-damage flash lerps toward damage-red
    // (a white-on-white flash would be invisible); dash still tints gold.
    final primary = _hitFlash > 0
        ? Color.lerp(
            AppPalette.avatarCore,
            AppPalette.healthLow,
            _hitFlash * 0.7,
          )!
        : isDashing
        ? Color.lerp(AppPalette.avatarCore, AppPalette.gold, 0.35)!
        : AppPalette.avatarCore;

    final shadowRing = Paint()
      ..color = AppPalette.backgroundDeep.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(center, size.x * 0.66, shadowRing);

    final spriteImg = game.useSprites ? game.spritePack.player() : null;
    if (spriteImg != null) {
      ColorFilter? filter;
      if (_hitFlash > 0) {
        filter = ColorFilter.mode(
          AppPalette.healthLow.withValues(
            alpha: (_hitFlash * 0.6).clamp(0.0, 1.0),
          ),
          BlendMode.srcATop,
        );
      } else if (isDashing) {
        filter = ColorFilter.mode(
          AppPalette.gold.withValues(alpha: 0.4),
          BlendMode.srcATop,
        );
      }
      _spritePaint.colorFilter = filter;
      canvas.drawImageRect(
        spriteImg,
        Rect.fromLTWH(
          0,
          0,
          spriteImg.width.toDouble(),
          spriteImg.height.toDouble(),
        ),
        Rect.fromLTWH(0, 0, size.x, size.y),
        _spritePaint,
      );
    } else {
      BlobPainter.paint(
        canvas,
        spec: _spec,
        center: center,
        time: game.settings.value.reduceMotion ? 0 : _time,
        primaryColor: primary,
        accentColor: AppPalette.avatarGlow,
        quality: game.settings.value.animationQuality,
        rimColor: AppPalette.avatarGlow,
        fillCache: _fillCache,
      );
    }

    // Facing tick + muzzle flash toward the current aim direction. The tick is
    // drawn only while actively aiming/firing (not idle), and extends past the
    // rim onto the dark background where it actually has contrast.
    final aiming = _muzzleFlashTimer > 0 || game.manualAimActive;
    if (aiming) {
      final aim = Offset(_aimDirection.x, _aimDirection.y);
      final muzzle = center + aim * (size.x * 0.62);
      final tickPaint = Paint()
        ..color = AppPalette.avatarGlow.withValues(alpha: 0.85)
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(center + aim * (size.x * 0.5), muzzle, tickPaint);
      if (_muzzleFlashTimer > 0) {
        final a = (_muzzleFlashTimer / 0.08).clamp(0.0, 1.0);
        final flashPaint = Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.9 * a)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(muzzle, size.x * 0.16, flashPaint);
      }
    }

    if (_invulnerableTimer > 0) {
      final ringPaint = Paint()
        ..color = AppPalette.gold.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(center, size.x * 0.68, ringPaint);
    }
  }

  /// Points the facing tick toward [direction] (any vector). Called each
  /// frame by [WeaponController] with the current aim/target direction.
  void aimToward(Vector2 direction) {
    if (direction.length2 > 0.0001) {
      _aimDirection.setFrom(direction.normalized());
    }
  }

  /// Triggers a brief muzzle flash; called by [WeaponController] on each shot.
  void flashMuzzle() {
    _muzzleFlashTimer = 0.08;
  }
}

/// Direction keys, abstracted from raw [LogicalKeyboardKey]s so
/// [PlayerComponent] doesn't need to import `flutter/services.dart`
/// directly. See [PdacGame.onKeyEvent] for the mapping (WASD + arrows).
enum PdacKey { up, down, left, right }
