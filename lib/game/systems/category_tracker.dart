import '../../data/categories.dart';

/// Tracks how much damage the player has dealt with each [ImmuneCategory]
/// over the course of a run, on top of a single [KrasResistanceState] that
/// represents "the overall fight" for mutation purposes.
///
/// For the vertical slice (round 1, no boss), this mostly just accumulates
/// stats for display/debugging. Its real purpose is for future boss
/// rounds: [mostUsedCategory] is used to pre-seed a boss's resistance tier
/// ("the tumor mutated in response to your treatment strategy"), per the
/// boss balance design in `data/bosses/boss_balance.dart`.
class CategoryTracker {
  final KrasResistanceState overall = KrasResistanceState();

  /// Lifetime damage dealt per category (not reset between rounds) -
  /// used to compute [mostUsedCategory].
  final Map<ImmuneCategory, double> lifetimeDamage = {
    for (final c in ImmuneCategory.values) c: 0.0,
  };

  void recordDamage(ImmuneCategory category, double amount) {
    overall.recordDamage(category, amount);
    lifetimeDamage[category] = (lifetimeDamage[category] ?? 0) + amount;
  }

  /// Call at the end of a round. Returns true if a mutation/resistance
  /// tier was newly acquired this round (can be used to trigger a
  /// "mutation acquired" context tip).
  bool endRound() => overall.endRoundAndCheckMutation();

  /// The category the player has dealt the most lifetime damage with, or
  /// null if no damage has been dealt yet.
  ImmuneCategory? mostUsedCategory() {
    ImmuneCategory? best;
    var bestAmount = 0.0;
    for (final entry in lifetimeDamage.entries) {
      if (entry.value > bestAmount) {
        bestAmount = entry.value;
        best = entry.key;
      }
    }
    return best;
  }

  /// Fraction (0-1) of total lifetime damage dealt with the most-used
  /// category. Used to decide whether a boss should pre-seed KRAS resistance:
  /// only a genuinely over-relied-on response (the lesson's warning) earns it,
  /// so balanced matched play - now the default - isn't punished.
  double mostUsedCategoryShare() {
    var total = 0.0;
    var best = 0.0;
    for (final value in lifetimeDamage.values) {
      total += value;
      if (value > best) best = value;
    }
    return total <= 0 ? 0 : best / total;
  }
}
