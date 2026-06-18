import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../data/categories.dart';
import '../../data/weapons/weapon_def.dart';
import '../../data/weapons/weapon_traits.dart';
import '../../services/settings_service.dart';
import '../../theme/category_glyph.dart';
import '../../theme/colorblind.dart';
import '../../theme/fx_constants.dart';
import '../pdac_game.dart';
import '../systems/collision_resolver.dart';
import 'mob_component.dart';

/// A single fired projectile.
///
/// Visuals are driven by [shape] (see [BulletShape]); gameplay behavior is
/// driven by [traitMagnitudes], a sparse map of unlocked
/// [WeaponTraitId]s -> their effect magnitude for the firing weapon:
/// - [WeaponTraitId.piercingShots]: magnitude = extra hits before removal.
/// - [WeaponTraitId.antibodyHoming]: magnitude = turn rate (rad/sec)
///   toward the nearest matching-category enemy.
/// - [WeaponTraitId.explodingRounds]: magnitude = AoE damage fraction.
/// - [WeaponTraitId.cytotoxicSlow]: magnitude = speed reduction fraction.
/// - [WeaponTraitId.lifestealRounds]: magnitude = fraction of damage
///   dealt returned to the player as healing.
class BulletComponent extends PositionComponent
    with HasGameReference<PdacGame> {
  BulletComponent({
    required Vector2 position,
    required Vector2 direction,
    required this.damage,
    required this.weaponId,
    required this.category,
    required this.shape,
    required double speed,
    required double bulletRadius,
    Map<WeaponTraitId, double> traitMagnitudes = const {},
    this.baseHomingTurnRate = 0,
    int basePierce = 0,
  }) : velocity = direction.normalized() * speed,
       traitMagnitudes = Map.of(traitMagnitudes),
       super(
         position: position,
         size: Vector2.all(bulletRadius * 2),
         anchor: Anchor.center,
       ) {
    _pierceRemaining =
        basePierce +
        (traitMagnitudes[WeaponTraitId.piercingShots] ?? 0).round();
    _canPierce = _pierceRemaining > 0;
  }

  final double damage;
  final String weaponId;
  final ImmuneCategory category;
  final BulletShape shape;
  final Vector2 velocity;
  final Map<WeaponTraitId, double> traitMagnitudes;

  /// Baseline homing turn rate (rad/sec) granted by the global Targeting
  /// track, applied to every bullet even without the per-weapon
  /// [WeaponTraitId.antibodyHoming] trait. 0 = no global homing.
  final double baseHomingTurnRate;

  late int _pierceRemaining;
  late bool _canPierce;
  double _life = 0;
  bool _hitBoss = false;
  final Set<MobComponent> _hitMobs = {};
  static const double _maxLife = 3.0;

  /// Innate (blue) weapons DRAW their bullets at this fraction of the collision
  /// radius so they look small and clean; antibody (purple) and cytotoxic (red)
  /// bullets render at their full default size. Collision still uses the full
  /// `size.x / 2` in every case (auto-aim relies on the real hit radius).
  static const double _innateVisualScale = 0.45;

  /// Drawn (visual) radius. Collision uses `size.x / 2` unchanged.
  double get _visualRadius =>
      size.x /
      2 *
      (category == ImmuneCategory.innate ? _innateVisualScale : 1.0);

  // Pooled paints reused across all bullets (render runs single-threaded), so
  // up to 180 live bullets don't allocate fresh Paints every frame.
  static final Paint _glowPaint = Paint();
  static final Paint _bodyPaint = Paint();
  static final Paint _corePaint = Paint();
  static final Paint _trailPaint = Paint();
  static final Paint _glyphFill = Paint()..color = const Color(0xF2070A10);
  static final Paint _glyphStroke = Paint()
    ..style = PaintingStyle.stroke
    ..color = const Color(0xF2070A10);

  @override
  Future<void> onLoad() async {
    angle = atan2(velocity.y, velocity.x);
  }

  bool get hasPiercing => _canPierce;
  bool get hasHoming =>
      traitMagnitudes.containsKey(WeaponTraitId.antibodyHoming) ||
      baseHomingTurnRate > 0;
  bool get hasExploding =>
      traitMagnitudes.containsKey(WeaponTraitId.explodingRounds);
  bool get hasSlow => traitMagnitudes.containsKey(WeaponTraitId.cytotoxicSlow);
  bool get hasLifesteal =>
      traitMagnitudes.containsKey(WeaponTraitId.lifestealRounds);

  @override
  void update(double dt) {
    super.update(dt);
    _life += dt;
    if (_life > _maxLife) {
      removeFromParent();
      return;
    }

    if (hasHoming) {
      _applyHoming(dt);
    }

    position += velocity * dt;
    angle = atan2(velocity.y, velocity.x);

    _resolveManualHit();
    if (!isMounted) return;

    final arena = game.arenaSize;
    if (position.x < -20 ||
        position.y < -20 ||
        position.x > arena.x + 20 ||
        position.y > arena.y + 20) {
      removeFromParent();
    }
  }

  void _applyHoming(double dt) {
    // Prefer the nearest matching-category target, but fall back to the nearest
    // target of ANY category in range so homing/replication bullets don't curve
    // away from an obvious point-blank enemy just because it's the wrong color.
    final nearest =
        game.nearestMob(
          position,
          category: category,
          radius: 260,
          excludeDecoys: true,
        ) ??
        game.nearestMob(position, radius: 260, excludeDecoys: true);
    if (nearest == null) return;
    final toTarget = (nearest.position - position).normalized();
    // Use the stronger of the per-weapon trait and the global Targeting
    // baseline, so the dedicated trait still feels better than the global one.
    final traitTurnRate = traitMagnitudes[WeaponTraitId.antibodyHoming];
    final turnRate = traitTurnRate != null
        ? max(traitTurnRate, baseHomingTurnRate)
        : baseHomingTurnRate;
    final currentDir = velocity.normalized();
    final blended = (currentDir + toTarget * (turnRate * dt)).normalized();
    velocity.setFrom(blended * velocity.length);
  }

  void _resolveManualHit() {
    final hitRadius = size.x / 2;

    final mob = game.mobHitByCircle(position, hitRadius, ignored: _hitMobs);
    if (mob != null && mob.isMounted && !mob.isDead) {
      _hitMobs.add(mob);
      CollisionResolver.resolveBulletHit(game, this, mob);
      _consumeHit();
      return;
    }

    final boss = game.activeBoss;
    if (boss == null || _hitBoss || boss.isDead || !boss.isMounted) return;

    final bossHitRadius = hitRadius + boss.radius;
    if (position.distanceToSquared(boss.position) <=
        bossHitRadius * bossHitRadius) {
      _hitBoss = true;
      CollisionResolver.resolveBulletHitBoss(game, this, boss);
      _consumeHit();
    }
  }

  void _consumeHit() {
    if (hasPiercing && _pierceRemaining > 0) {
      _pierceRemaining--;
      return;
    }
    removeFromParent();
  }

  @override
  void onRemove() {
    game.onBulletRemoved();
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final mode = game.settings.value.colorblindMode;
    final color = colorblindCategoryColor(category, mode);
    final vr = _visualRadius;
    switch (shape) {
      case BulletShape.roundedDot:
        _drawGlowCircle(canvas, center, vr, color);
      case BulletShape.pellet:
        _drawGlowCircle(canvas, center, vr * 0.9, color);
      case BulletShape.dart:
        _drawDart(canvas, center, color);
      case BulletShape.slug:
        _drawGlowCircle(canvas, center, vr * 1.2, color);
        _drawTrail(canvas, center, color);
    }
    // Colorblind assist: stamp a category shape on the projectile so it isn't
    // identifiable by hue alone (diamond=innate, ring=antibody, triangle=cyto).
    if (mode != ColorblindMode.none) {
      _paintBulletGlyph(canvas, center);
    }
  }

  void _paintBulletGlyph(Canvas canvas, Offset center) {
    // Keep a readability floor so the colorblind glyph still reads on the now
    // much smaller projectiles (a sub-pixel glyph would be invisible).
    final g = max(3.0, _visualRadius * 0.95);
    _glyphStroke.strokeWidth = max(1.8, _visualRadius * 0.36);
    drawCategoryGlyph(canvas, category, center, g, _glyphFill, _glyphStroke);
  }

  /// True when the arena is busy enough that per-bullet blur (the most
  /// expensive raster op) should be dropped - matching the mob glow cutoff.
  bool get _glowAllowed =>
      game.activeMobs.length < FxConstants.highMobCountGlowCutoff;

  void _drawGlowCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    if (_glowAllowed) {
      _glowPaint
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(center, radius * 1.8, _glowPaint);
    }

    _bodyPaint.color = color;
    canvas.drawCircle(center, radius, _bodyPaint);

    _corePaint.color = const Color(0xFFFFFFFF).withValues(alpha: 0.8);
    canvas.drawCircle(center, radius * 0.4, _corePaint);
  }

  void _drawDart(Canvas canvas, Offset center, Color color) {
    _bodyPaint.color = color;
    final v = _visualRadius;
    final halfWidth = v * (2 / 3);
    final path = Path()
      ..moveTo(center.dx + v, center.dy)
      ..lineTo(center.dx - v, center.dy - halfWidth)
      ..lineTo(center.dx - v, center.dy + halfWidth)
      ..close();
    canvas.drawPath(path, _bodyPaint);
  }

  void _drawTrail(Canvas canvas, Offset center, Color color) {
    if (!_glowAllowed) return;
    final v = _visualRadius;
    _trailPaint
      ..color = color.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center - Offset(v * 1.8, 0), v * 0.8, _trailPaint);
  }
}
