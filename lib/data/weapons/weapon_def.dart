import '../categories.dart';
import 'weapon_traits.dart';

/// How a weapon's bullets are drawn. Kept separate from gameplay stats so
/// the [BulletComponent] painter can switch on this without caring about
/// damage numbers.
enum BulletShape {
  /// Small rounded "antibody" dot.
  roundedDot,

  /// Wide pellet, used for shotgun-style spreads.
  pellet,

  /// Tiny fast dart, used for rapid-fire weapons.
  dart,

  /// Larger, slower slug for heavy-hitting weapons.
  slug,
}

/// Static definition of a weapon ("gun"). This is pure data - the
/// [WeaponController]/[BulletComponent] read these values at runtime and
/// combine them with run-scoped upgrades and persistent shop upgrades.
class WeaponDef {
  const WeaponDef({
    required this.id,
    required this.displayName,
    required this.description,
    required this.category,
    this.role = 'Standard',
    required this.baseDamage,
    required this.baseFireRate,
    required this.bulletSpeed,
    required this.bulletRadius,
    this.pelletCount = 1,
    this.spreadAngleDeg = 0,
    required this.bulletShape,
    this.availableTraits = const [],
    this.pierceCount = 0,
  });

  /// Stable identifier, used as a map key for save data / upgrade tracking.
  final String id;

  final String displayName;
  final String description;

  /// The immune-response category this weapon represents.
  final ImmuneCategory category;

  /// Short archetype label (e.g. "Rapid", "Heavy AoE", "Precision") shown on
  /// the shop/loadout cards, so weapons that share a category read as distinct
  /// roles rather than redundant duplicates.
  final String role;

  /// Damage dealt per bullet (per pellet, for multi-pellet weapons).
  final double baseDamage;

  /// Shots fired per second.
  final double baseFireRate;

  /// Bullet travel speed in pixels/second.
  final double bulletSpeed;

  /// Visual radius of a single bullet/pellet.
  final double bulletRadius;

  /// Number of pellets/bullets fired per shot (e.g. shotgun = 5).
  final int pelletCount;

  /// Total spread cone in degrees across all pellets. 0 = perfectly
  /// straight shot (with optional tiny jitter handled at fire time).
  final double spreadAngleDeg;

  final BulletShape bulletShape;

  /// Special traits that can be unlocked for this weapon via the
  /// persistent gold shop (see [WeaponTraitId] / [WeaponTraitDef]).
  final List<WeaponTraitId> availableTraits;

  /// Innate piercing: how many extra enemies each bullet passes through before
  /// stopping (0 = stops on first hit). The unlockable [WeaponTraitId.piercingShots]
  /// trait stacks on top of this. Used by the innate "Piercing Lance" starter.
  final int pierceCount;
}
