import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../data/categories.dart';
import '../../data/enemies/elite_tuning.dart';
import '../../data/enemies/enemy_def.dart';
import '../../data/enemies/mob_behaviors.dart';
import '../../services/audio_service.dart';
import '../../services/settings_service.dart';
import '../../theme/category_glyph.dart';
import '../../theme/colorblind.dart';
import '../../theme/fx_constants.dart';
import '../../theme/palette.dart';
import '../../ui/widgets/blob_painter.dart';
import '../pdac_game.dart';
import '../systems/gameplay_safe_area.dart';
import '../systems/weapon_resistance_tracker.dart';

/// A "germ" enemy. Generic across all [EnemyDef]s - the specific
/// behavior (mitosis, biofilm shield, spore cloud, ...) comes from
/// [MobBehavior] (resolved from [EnemyDef.behavior] via
/// `mobBehaviorCatalog`). Thin subclasses in `mob_components/` exist for
/// readability/construction convenience but don't add logic.
class MobComponent extends PositionComponent
    with HasGameReference<PdacGame>
    implements MobController {
  MobComponent({
    required this.def,
    required Vector2 position,
    this.generation = 0,
    this.isElite = false,
    double? healthOverride,
    double? radiusOverride,
  }) : maxHealth = healthOverride ?? def.baseHealth,
       super(
         position: position,
         size: Vector2.all((radiusOverride ?? def.baseRadius) * 2),
         anchor: Anchor.center,
       ) {
    health = maxHealth;
  }

  @override
  final EnemyDef def;

  @override
  final int generation;

  @override
  final bool isElite;

  @override
  double health = 0;

  @override
  final double maxHealth;

  @override
  double shield = 0;

  double _timeSinceLastDamage = 999;
  @override
  double get timeSinceLastDamage => _timeSinceLastDamage;

  /// Per-mob KRAS resistance state. For short-lived round-1 mobs this
  /// rarely accumulates tiers, but bosses (built on the same
  /// [MobController] interface in a later pass) rely on this for the
  /// mutation mechanic.
  final KrasResistanceState resistance = KrasResistanceState();
  final Map<String, int> _weaponResistanceTier = {};

  int get weaponResistanceTotalTier =>
      _weaponResistanceTier.values.fold(0, (sum, tier) => sum + tier);

  double weaponResistanceMultiplierFor(String weaponId) => pow(
    weaponResistanceTierMultiplier,
    _weaponResistanceTier[weaponId] ?? 0,
  ).toDouble();

  bool isDead = false;

  /// Movement speed multiplier applied by [WeaponTraitId.cytotoxicSlow]
  /// ("Fever Response") and [EnrageBehavior]. Decays back to 1.0 once
  /// [_slowTimer] elapses.
  @override
  double speedMultiplier = 1.0;
  double _slowTimer = 0;

  /// Round-scaled behavior intensity (see [MobController.behaviorIntensity]).
  /// Set by the spawner from the round number; mitosis children inherit it.
  @override
  double behaviorIntensity = 1.0;

  late MobBehavior _behavior;
  // Built lazily on the first blob render. Crowded-arena mobs (mitosis children,
  // tiny mobs) take the simple-circle fast path and never touch these, so we
  // avoid the Catmull-Rom generation + shader-cache cost for them at spawn.
  BlobShapeSpec? _specCache;
  FillShaderCache? _fillCacheLazy;
  double _time = 0;
  double _hitFlash = 0;

  BlobShapeSpec get _spec => _specCache ??= BlobShapeSpec.generate(
    rng: Random(hashCode),
    baseRadius: radius,
    quality: game.settings.value.animationQuality,
  );

  FillShaderCache get _fillCache => _fillCacheLazy ??= FillShaderCache();

  /// Whether to draw the category shape glyph: in colorblind mode, or whenever
  /// the on-by-default Shape Labels setting is enabled.
  bool get _showGlyph {
    final s = game.settings.value;
    return s.shapeLabels || s.colorblindMode != ColorblindMode.none;
  }

  @override
  double get radius => size.x / 2;

  @override
  Future<void> onLoad() async {
    _behavior = mobBehaviorCatalog[def.behavior] ?? const NoneBehavior();
    _behavior.onSpawn(this);
    if (isElite) {
      // Telegraph the tougher elite on spawn with a gold burst so it doesn't
      // silently blend into the wave, and surface a one-time explainer tip.
      game.spawnParticles(
        position: position.clone(),
        color: AppPalette.gold,
        count: 10,
      );
      game.notifyEliteSpawned();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;
    _time += dt;
    _timeSinceLastDamage += dt;
    if (_hitFlash > 0) _hitFlash = max(0, _hitFlash - dt * 4);

    if (_slowTimer > 0) {
      _slowTimer -= dt;
      if (_slowTimer <= 0) speedMultiplier = 1.0;
    }

    _behavior.onTick(this, dt);

    // Move toward the player.
    final player = game.player;
    final direction = (player.position - position);
    if (direction.length2 > 1) {
      position +=
          direction.normalized() *
          def.baseSpeed *
          (isElite ? eliteSpeedMultiplier : 1) *
          speedMultiplier *
          dt;
    }
    pushPointOutsideTopLeftHudBlock(position, game.arenaSize, radius);

    // Deal continuous contact damage while overlapping the player.
    final contactDistance = radius + player.size.x / 2;
    if (position.distanceToSquared(player.position) <=
        contactDistance * contactDistance) {
      player.takeDamage(
        def.contactDamagePerSecond *
            (isElite ? eliteContactDamageMultiplier : 1) *
            game.enemyDamageMultiplier *
            dt,
      );
    }
  }

  /// Applies a temporary speed reduction (clamped to >= 10% of normal
  /// speed), used by [WeaponTraitId.cytotoxicSlow].
  void applySlow(double fraction, double duration) {
    speedMultiplier = (1 - fraction).clamp(0.1, 1.0);
    _slowTimer = duration;
  }

  void setWeaponResistanceTiers(Map<String, int> tiers) {
    _weaponResistanceTier
      ..clear()
      ..addEntries(
        tiers.entries
            .where((entry) => entry.value > 0)
            .map(
              (entry) => MapEntry(
                entry.key,
                entry.value.clamp(0, maxWeaponResistanceTier).toInt(),
              ),
            ),
      );
  }

  void setWeaponResistanceTier(String weaponId, int tier) {
    if (weaponId.trim().isEmpty || tier <= 0) return;
    final next = tier.clamp(0, maxWeaponResistanceTier).toInt();
    _weaponResistanceTier[weaponId] = max(
      _weaponResistanceTier[weaponId] ?? 0,
      next,
    );
  }

  /// Applies [rawAmount] of damage of [sourceCategory] (already adjusted
  /// for category match + resistance multipliers by
  /// `CollisionResolver`). Returns the amount actually removed from
  /// [health] (after shield absorption via [MobBehavior.onDamaged]).
  double applyDamage(double rawAmount, ImmuneCategory sourceCategory) {
    if (isDead) return 0;
    _timeSinceLastDamage = 0;
    _hitFlash = 1;
    resistance.recordDamage(sourceCategory, rawAmount);

    final toHealth = _behavior.onDamaged(this, rawAmount, sourceCategory);
    final before = health;
    health = (health - toHealth).clamp(0, maxHealth);
    final actuallyDealt = before - health;

    if (health <= 0) {
      die();
    }
    return actuallyDealt;
  }

  void die() {
    if (isDead) return;
    isDead = true;
    AudioService.instance.playSfx('sfx/death.wav');
    _behavior.onDeath(this);
    game.onMobDefeated(this);
    removeFromParent();
  }

  @override
  void spawnChild({
    required double healthFraction,
    required double radiusFraction,
    required int generation,
  }) {
    game.spawnMobChild(
      def: def,
      position: position.clone(),
      health: (isElite ? def.baseHealth : maxHealth) * healthFraction,
      radius: (isElite ? def.baseRadius : radius) * radiusFraction,
      generation: generation,
      behaviorIntensity: behaviorIntensity,
    );
  }

  @override
  void spawnDamageCloud({
    required double radius,
    required double damagePerSecond,
    required double duration,
    double warningSeconds = 0,
  }) {
    game.spawnDamageCloud(
      position: position.clone(),
      radius: radius,
      damagePerSecond: damagePerSecond,
      duration: duration,
      warningSeconds: warningSeconds,
    );
  }

  @override
  void healNearbyAllies({required double radius, required double amount}) {
    if (amount <= 0) return;
    for (final mob in game.nearbyMobs(position, radius)) {
      if (mob == this || mob.isDead) continue;
      mob.health = (mob.health + amount).clamp(0, mob.maxHealth);
    }
  }

  @override
  void shieldNearbyAllies({
    required double radius,
    required double amount,
    required double maxShieldFraction,
  }) {
    if (amount <= 0 || maxShieldFraction <= 0) return;
    for (final mob in game.nearbyMobs(position, radius)) {
      if (mob == this || mob.isDead) continue;
      final maxShield = mob.maxHealth * maxShieldFraction;
      // Never shrink a shield that's already larger than this aura's ceiling
      // (e.g. a biofilm shield at 0.4/0.65 vs a 0.3 support aura).
      mob.shield = max(
        mob.shield,
        (mob.shield + amount).clamp(0, maxShield).toDouble(),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final membraneFraction = shield > 0
        ? (shield / (maxHealth * 0.4)).clamp(0.0, 1.0)
        : 0.0;

    // Category color, remapped to a colorblind-safe hue when assist is on.
    final mode = game.settings.value.colorblindMode;
    final catColor = colorblindCategoryColor(def.category, mode);
    final primary = _hitFlash > 0
        ? Color.lerp(catColor, const Color(0xFFFFFFFF), _hitFlash * 0.6)!
        : catColor;

    // Experimental sprite render path (falls back to procedural if missing).
    if (game.useSprites) {
      final img = game.spritePack.enemy(def.id);
      if (img != null) {
        _drawSprite(canvas, img, catColor, mode != ColorblindMode.none);
        // Realistic-colored sprite bodies don't encode category by fill, so a
        // category-colored ring keeps the match mechanic readable.
        _drawCategoryRing(canvas, center, catColor);
        _paintResistanceRing(canvas, center);
        if (isElite) _paintEliteRing(canvas, center);
        if (_showGlyph) _paintCategoryGlyph(canvas, center);
        return;
      }
    }

    final highMobCount =
        game.activeMobs.length >= FxConstants.highMobCountGlowCutoff;
    if (highMobCount && (generation > 0 || radius <= 13)) {
      _paintSimpleMob(canvas, center, primary, catColor);
      return;
    }

    var quality = game.settings.value.animationQuality;
    if (highMobCount) {
      quality = AnimationQuality.low;
    }

    BlobPainter.paint(
      canvas,
      spec: _spec,
      center: center,
      time: game.settings.value.reduceMotion ? 0 : _time,
      primaryColor: primary,
      accentColor: def.accentColor,
      quality: quality,
      membraneFraction: membraneFraction,
      resistanceTier:
          resistance.totalResistanceTier + weaponResistanceTotalTier,
      rimColor: catColor,
      fillCache: _fillCache,
    );
    if (isElite) {
      _paintEliteRing(canvas, center);
    }
    if (_showGlyph) {
      _paintCategoryGlyph(canvas, center);
    }
  }

  static final Paint _spritePaint = Paint()..filterQuality = FilterQuality.none;

  void _drawSprite(Canvas canvas, Image img, Color catColor, bool colorblind) {
    ColorFilter? filter;
    if (colorblind) {
      // Recolor the baked sprite to the colorblind-safe category hue (keeps the
      // sprite's luminance/shading via BlendMode.color), so sprite mode keeps
      // the hue-AND-shape dual encoding the procedural path provides.
      filter = ColorFilter.mode(catColor, BlendMode.color);
    } else if (_hitFlash > 0) {
      filter = ColorFilter.mode(
        const Color(
          0xFFFFFFFF,
        ).withValues(alpha: (_hitFlash * 0.7).clamp(0.0, 1.0)),
        BlendMode.srcATop,
      );
    }
    _spritePaint.colorFilter = filter;
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      Rect.fromLTWH(0, 0, size.x, size.y),
      _spritePaint,
    );
  }

  static final Paint _ringGlow = Paint()..style = PaintingStyle.stroke;
  static final Paint _ringSolid = Paint()..style = PaintingStyle.stroke;

  /// Draws the category-colored ring used around sprite-mode bodies.
  void _drawCategoryRing(Canvas canvas, Offset center, Color color) {
    _ringGlow
      ..color = color.withValues(alpha: 0.28)
      ..strokeWidth = 4;
    _ringSolid
      ..color = color.withValues(alpha: 0.9)
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.98, _ringGlow);
    canvas.drawCircle(center, radius * 0.98, _ringSolid);
  }

  // Pooled paints for the crowded-arena fast path (this is the renderer most
  // mobs use under load, so allocating here would defeat the point).
  static final Paint _simpleFill = Paint();
  static final Paint _simpleRim = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  static final Paint _simpleCore = Paint();

  void _paintSimpleMob(
    Canvas canvas,
    Offset center,
    Color primary,
    Color rimColor,
  ) {
    _simpleFill.color = primary.withValues(alpha: 0.9);
    _simpleRim.color = rimColor.withValues(alpha: 0.75);
    _simpleCore.color = def.accentColor.withValues(alpha: 0.7);

    canvas.drawCircle(center, radius, _simpleFill);
    canvas.drawCircle(center, radius, _simpleRim);
    canvas.drawCircle(center, radius * 0.38, _simpleCore);
    _paintResistanceRing(canvas, center);
    if (isElite) {
      _paintEliteRing(canvas, center);
    }
    if (_showGlyph) {
      _paintCategoryGlyph(canvas, center);
    }
  }

  /// A distinct white shape per category (diamond / ring / triangle), drawn for
  /// everyone when Shape Labels is on (default) and always in colorblind mode,
  /// so the immune category can be read by shape and not by hue alone. Mirrors
  /// the badge icons used elsewhere in the UI.
  void _paintCategoryGlyph(Canvas canvas, Offset center) {
    _glyphStroke.strokeWidth = max(1.6, radius * 0.16);
    drawCategoryGlyph(
      canvas,
      def.category,
      center,
      radius * 0.5,
      _glyphFill,
      _glyphStroke,
    );
  }

  static final Paint _eliteGlow = Paint()
    ..style = PaintingStyle.stroke
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  static final Paint _eliteRing = Paint()..style = PaintingStyle.stroke;
  static final Paint _resistanceGlow = Paint()
    ..style = PaintingStyle.stroke
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
  static final Paint _resistanceRing = Paint()..style = PaintingStyle.stroke;
  static final Paint _glyphFill = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _glyphStroke = Paint()
    ..style = PaintingStyle.stroke
    ..color = const Color(0xFFFFFFFF);

  void _paintResistanceRing(Canvas canvas, Offset center) {
    final tier = resistance.totalResistanceTier + weaponResistanceTotalTier;
    if (tier <= 0) return;
    final pulse = game.settings.value.reduceMotion
        ? 1.0
        : 0.65 + sin(_time * 6).abs() * 0.35;
    final ringRadius = radius * (1.06 + tier * 0.03);
    _resistanceGlow
      ..color = AppPalette.mutationRing.withValues(alpha: 0.16 * pulse)
      ..strokeWidth = max(5, radius * 0.22 + tier);
    _resistanceRing
      ..color = AppPalette.mutationRing.withValues(alpha: 0.78 * pulse)
      ..strokeWidth = max(2.5, radius * 0.11 + tier * 0.75);
    canvas.drawCircle(center, ringRadius, _resistanceGlow);
    canvas.drawCircle(center, ringRadius, _resistanceRing);
  }

  void _paintEliteRing(Canvas canvas, Offset center) {
    final pulse = 0.75 + sin(_time * 5).abs() * 0.25;
    final ringRadius = radius * 0.92;
    _eliteGlow
      ..color = AppPalette.gold.withValues(alpha: 0.24 * pulse)
      ..strokeWidth = max(5, radius * 0.24);
    _eliteRing
      ..color = AppPalette.gold.withValues(alpha: 0.92)
      ..strokeWidth = max(3, radius * 0.16);
    canvas.drawCircle(center, ringRadius, _eliteGlow);
    canvas.drawCircle(center, ringRadius, _eliteRing);
  }
}
