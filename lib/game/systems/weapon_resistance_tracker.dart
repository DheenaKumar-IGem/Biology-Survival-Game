import 'dart:math';

/// Maximum resistance tiers a round's mob population can gain against a
/// weapon the player keeps firing at the WRONG-category targets.
const int maxWeaponResistanceTier = 3;

/// Per-tier multiplier against the resisted weapon.
/// Tier 1 => 0.72x, tier 2 => 0.518x, tier 3 => 0.373x.
const double weaponResistanceTierMultiplier = 0.72;

/// Number of wrong-category (mismatched) hits a single weapon must rack up
/// before the mob population first *warns* about adapting to it. Matched hits
/// never count - this is purely a "you keep firing the wrong color" signal.
const int mismatchHitsToWarn = 12;

/// Additional mismatched hits with the same weapon, after a prior
/// warning/tier, before the next resistance tier lands.
const int mismatchHitsToEscalate = 12;

class WeaponResistanceEvent {
  const WeaponResistanceEvent({
    required this.weaponId,
    required this.tier,
    required this.share,
    required this.warningOnly,
  });

  final String weaponId;
  final int tier;

  /// Fraction (0-1) of this weapon's hits that landed on the wrong category -
  /// i.e. how badly the player is mis-targeting with it. Displayed by the
  /// resistance alert. (Field kept as `share` so [ResistanceAlertData] and the
  /// overlay key don't need to change.)
  final double share;
  final bool warningOnly;
}

/// Tracks, per current round, how often each weapon is fired at the WRONG
/// immune-category target. Matched (correct-color) hits never build
/// resistance; only excessive mismatched hits do. When one weapon crosses the
/// mismatch threshold the mob population starts resisting that weapon, nudging
/// the player to swap to the matching color.
class WeaponResistanceTracker {
  /// Mismatched-hit count in the current escalation window, per weapon. Reset
  /// to 0 each time that weapon triggers a warning/tier.
  final Map<String, int> _mismatchHits = {};

  /// Lifetime (this-round) matched-hit count per weapon, used only to compute
  /// the displayed wrong-target ratio. Never reset on a trigger.
  final Map<String, int> _matchedHits = {};

  final Map<String, int> _activeTiers = {};
  final Set<String> _warnedWeapons = {};

  Map<String, int> get activeTiers => Map.unmodifiable(_activeTiers);

  int tierFor(String weaponId) => _activeTiers[weaponId] ?? 0;

  double multiplierFor(String weaponId) =>
      pow(weaponResistanceTierMultiplier, tierFor(weaponId)).toDouble();

  /// Fraction (0-1) of the way [weaponId] is toward its next resistance
  /// warning/tier from accumulated wrong-color hits. Drives a pre-warning HUD
  /// cue so a resistance surge never feels like it came out of nowhere.
  double mismatchProgressFor(String weaponId) {
    final mismatch = _mismatchHits[weaponId] ?? 0;
    final threshold = _warnedWeapons.contains(weaponId)
        ? mismatchHitsToEscalate
        : mismatchHitsToWarn;
    if (threshold <= 0) return 0;
    return (mismatch / threshold).clamp(0.0, 1.0);
  }

  /// Record a single connecting hit. [matched] is whether the bullet's
  /// category matched the target's category. Matched hits are counted only for
  /// the display ratio and can NEVER build resistance; mismatched hits push the
  /// weapon toward a resistance tier. Returns an event when a warning or new
  /// tier is reached.
  WeaponResistanceEvent? recordHit(String weaponId, {required bool matched}) {
    if (weaponId.trim().isEmpty) return null;

    if (matched) {
      _matchedHits[weaponId] = (_matchedHits[weaponId] ?? 0) + 1;
      return null;
    }

    _mismatchHits[weaponId] = (_mismatchHits[weaponId] ?? 0) + 1;
    return _checkForResistance(weaponId);
  }

  void resetForRound() {
    _mismatchHits.clear();
    _matchedHits.clear();
    _activeTiers.clear();
    _warnedWeapons.clear();
  }

  WeaponResistanceEvent? _checkForResistance(String weaponId) {
    final mismatch = _mismatchHits[weaponId] ?? 0;
    final warned = _warnedWeapons.contains(weaponId);
    final threshold = warned ? mismatchHitsToEscalate : mismatchHitsToWarn;
    if (mismatch < threshold) return null;

    final matched = _matchedHits[weaponId] ?? 0;
    final wrongTargetRatio = mismatch / (matched + mismatch);
    final nextTier = (_activeTiers[weaponId] ?? 0) + 1;

    // Start a fresh window for this weapon (matched count stays for the ratio).
    _mismatchHits[weaponId] = 0;

    // Already maxed out - keep nudging via the live banner, but no new tier.
    if (nextTier > maxWeaponResistanceTier) return null;

    if (!warned) {
      // First crossing is a warning only: no mechanical damage reduction yet,
      // giving the player a chance to swap before the population adapts.
      _warnedWeapons.add(weaponId);
      return WeaponResistanceEvent(
        weaponId: weaponId,
        tier: nextTier,
        share: wrongTargetRatio,
        warningOnly: true,
      );
    }

    _activeTiers[weaponId] = nextTier;
    return WeaponResistanceEvent(
      weaponId: weaponId,
      tier: nextTier,
      share: wrongTargetRatio,
      warningOnly: false,
    );
  }
}
