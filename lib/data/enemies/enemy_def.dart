import 'dart:ui';

import '../categories.dart';

/// Identifies which [MobBehavior] (see `mob_behaviors.dart`) a given
/// [EnemyDef] uses. Kept as an enum (rather than embedding behavior objects
/// directly) so [EnemyDef] stays a simple `const` data class.
enum EnemyBehaviorId {
  /// No special behavior.
  none,

  /// Splits into two smaller copies of itself on death (Virus).
  mitosis,

  /// Has a regenerating shield that absorbs damage first (Bacteria).
  biofilmShield,

  /// Leaves a lingering damage cloud where it dies (Fungal Spore).
  sporeCloud,

  /// Speeds up once badly wounded (Parasite).
  enrage,

  /// Slowly regenerates health when left undamaged (Dysplastic Cell).
  regeneration,

  /// Fast biomarker carrier that releases a signal pulse on death.
  biomarkerSignal,

  /// Tumor-support cell that heals and shields nearby allies.
  stromalSupport,

  /// Leaves small mucin hazards behind as it advances.
  mucinTrail,

  /// Weak decoy whose main job is to distract auto-targeting.
  decoySignal,
}

/// Static definition of an enemy ("germ") archetype.
class EnemyDef {
  const EnemyDef({
    required this.id,
    required this.displayName,
    required this.category,
    required this.baseHealth,
    required this.baseSpeed,
    required this.baseRadius,
    required this.coinValue,
    required this.behavior,
    required this.primaryColor,
    required this.accentColor,
    this.description = '',
    this.contactDamagePerSecond = 8,
    this.mismatchMultiplier = mismatchedDamageMultiplier,
  });

  final String id;
  final String displayName;
  final String description;

  /// The immune-response category this germ is vulnerable/resistant to via
  /// the category match system.
  final ImmuneCategory category;

  final double baseHealth;

  /// Movement speed toward the player, in pixels/second.
  final double baseSpeed;

  /// Base blob radius in pixels (before any wobble).
  final double baseRadius;

  /// Damage dealt to the player per second while this germ is in contact
  /// with them (applied continuously in [MobComponent.update]).
  final double contactDamagePerSecond;

  /// Damage multiplier applied to MISMATCHED-category fire against this enemy,
  /// overriding the global [mismatchedDamageMultiplier]. Lower values force
  /// the player to swap to the matching immune response (0 = effectively
  /// immune to wrong-color fire); the global default keeps most early/trivial
  /// enemies forgiving.
  final double mismatchMultiplier;

  /// Gold value of a dropped coin.
  final int coinValue;

  final EnemyBehaviorId behavior;

  /// Core/fill color of the blob.
  final Color primaryColor;

  /// Accent color (membrane, nucleus, rim light).
  final Color accentColor;
}
