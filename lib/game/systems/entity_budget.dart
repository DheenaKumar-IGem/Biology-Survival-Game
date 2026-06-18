/// Tracks live counts of capped, pooled entities (bullets, coins, clouds,
/// damage/gold numbers, blast rings) so [PdacGame] can enforce hard ceilings
/// without a separate `int` field plus increment/decrement method per type.
///
/// Caps are passed at acquire time because some are dynamic (e.g. damage
/// clouds use a larger cap while they have a warning telegraph).
class EntityBudget {
  static const String bullet = 'bullet';
  static const String bossProjectile = 'bossProjectile';
  static const String coin = 'coin';
  static const String cloud = 'cloud';
  static const String damageNumber = 'damageNumber';
  static const String goldNumber = 'goldNumber';
  static const String blastRing = 'blastRing';

  final Map<String, int> _counts = {};

  /// Current live count for [key].
  int count(String key) => _counts[key] ?? 0;

  /// Tries to reserve one slot for [key] against [cap]. Returns true (and
  /// increments the count) on success, or false when already at [cap].
  bool tryAcquire(String key, int cap) {
    final current = _counts[key] ?? 0;
    if (current >= cap) return false;
    _counts[key] = current + 1;
    return true;
  }

  /// Releases one slot for [key] (never goes below zero).
  void release(String key) {
    final current = _counts[key] ?? 0;
    if (current > 0) _counts[key] = current - 1;
  }
}
