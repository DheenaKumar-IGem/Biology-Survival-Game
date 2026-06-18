import 'package:flutter/foundation.dart';

/// Short presentation shown when a round begins. It is intentionally small
/// and data-only so the Flutter overlay can animate it without reaching back
/// into game systems.
class RoundIntroData {
  const RoundIntroData({
    required this.roundNumber,
    required this.biomeName,
    required this.objective,
    required this.threatNames,
    required this.isBossRound,
  });

  final int roundNumber;
  final String biomeName;
  final String objective;
  final List<String> threatNames;
  final bool isBossRound;
}

/// Post-boss science debrief. Boss fights are dramatic, so this connects
/// the fight back to PDAC progression and saliva-detection research before
/// the normal upgrade/lesson loop resumes.
class BossRecapData {
  const BossRecapData({
    required this.roundNumber,
    required this.bossName,
    required this.stageLabel,
    required this.fightTakeaway,
    required this.scienceConnection,
    required this.nextStep,
  });

  final int roundNumber;
  final String bossName;
  final String stageLabel;
  final String fightTakeaway;
  final String scienceConnection;
  final String nextStep;
}

/// Big warning shown when the player keeps firing a weapon at the wrong-color
/// (mismatched) targets and the mob population starts resisting it.
class ResistanceAlertData {
  const ResistanceAlertData({
    required this.weaponName,
    required this.tier,
    required this.share,
    required this.warningOnly,
    required this.eventId,
  });

  final String weaponName;
  final int tier;

  /// Fraction (0-1) of this weapon's hits that landed on the wrong category.
  final double share;
  final bool warningOnly;

  /// Monotonic id so the overlay re-animates even when a repeat event carries
  /// the same weapon/tier/ratio.
  final int eventId;
}

/// [ValueNotifier]-based bridge between [GameState]/[PdacGame] and the
/// Flutter HUD overlay. Keeping these as small notifiers (rather than
/// rebuilding the whole HUD on every game tick) lets `hud_overlay.dart`
/// use targeted `ValueListenableBuilder`s for each stat.
class HudData {
  final ValueNotifier<double> hp = ValueNotifier(100);
  final ValueNotifier<double> maxHp = ValueNotifier(100);
  final ValueNotifier<int> gold = ValueNotifier(0);
  final ValueNotifier<int> round = ValueNotifier(1);
  final ValueNotifier<int> kills = ValueNotifier(0);

  /// Display name of the current map/biome (e.g. "The Bloodstream Sea"),
  /// updated at the start of each round. Shown in the HUD under the round.
  final ValueNotifier<String?> biomeName = ValueNotifier(null);

  /// Round-start mission presentation. [RoundIntroOverlay] clears this after
  /// a short animation.
  final ValueNotifier<RoundIntroData?> roundIntro = ValueNotifier(null);

  /// Optional boss-clear debrief shown after rounds 3 and 6.
  final ValueNotifier<BossRecapData?> bossRecap = ValueNotifier(null);

  /// Loud, centered combat warning for weapon-specific mob resistance.
  final ValueNotifier<ResistanceAlertData?> resistanceAlert = ValueNotifier(
    null,
  );

  /// 0.0-1.0 progress toward clearing the current round. Reaches 1.0 only
  /// when every enemy (including mitosis-split children) has been cleared -
  /// see [PdacGame].
  final ValueNotifier<double> roundProgress = ValueNotifier(0);

  /// Number of enemies still alive in the arena right now. Drives the
  /// "germs remaining" readout so the round never *looks* stuck.
  final ValueNotifier<int> enemiesRemaining = ValueNotifier(0);

  /// True once every scheduled spawn wave has finished spawning, so the
  /// only thing left to do is clear the remaining enemies.
  final ValueNotifier<bool> allWavesSpawned = ValueNotifier(false);

  /// Ids of weapons currently owned this run, in display order.
  final ValueNotifier<List<String>> ownedWeapons = ValueNotifier(const []);

  /// Index into [ownedWeapons] of the currently equipped weapon.
  final ValueNotifier<int> equippedWeaponIndex = ValueNotifier(0);

  /// 0-1 "heat" of the equipped weapon toward its next resistance warning from
  /// accumulated wrong-color hits. Drives a pre-warning glow on the weapon chip
  /// so the full resistance banner never feels like it came out of nowhere.
  final ValueNotifier<double> equippedWeaponHeat = ValueNotifier(0);

  /// 0.0-1.0 readiness of the player's dash. 1.0 means dash is ready.
  final ValueNotifier<double> dashCharge = ValueNotifier(1);

  /// Hidden diagnostics toggled with F3 during development/playtesting.
  final ValueNotifier<bool> performanceOverlayEnabled = ValueNotifier(false);
  final ValueNotifier<double> fps = ValueNotifier(60);
  final ValueNotifier<int> activeMobCount = ValueNotifier(0);
  final ValueNotifier<int> activeBulletCount = ValueNotifier(0);
  final ValueNotifier<int> activeParticleCount = ValueNotifier(0);
  final ValueNotifier<int> activeCoinCount = ValueNotifier(0);
  final ValueNotifier<int> activeCloudCount = ValueNotifier(0);

  /// Set to a short educational message when a noteworthy in-game event
  /// occurs (e.g. an enemy gains a KRAS resistance tier). [ContextTipOverlay]
  /// shows this as a transient banner, then clears it back to null.
  final ValueNotifier<String?> contextTip = ValueNotifier(null);

  /// Display name of the active boss, or null if no boss is active this
  /// round (see [PdacGame.activeBoss]).
  final ValueNotifier<String?> bossName = ValueNotifier(null);

  /// 0.0-1.0 health fraction of the active boss, or null if no boss is
  /// active this round.
  final ValueNotifier<double?> bossHealthFraction = ValueNotifier(null);

  void dispose() {
    hp.dispose();
    maxHp.dispose();
    gold.dispose();
    round.dispose();
    kills.dispose();
    biomeName.dispose();
    roundIntro.dispose();
    bossRecap.dispose();
    resistanceAlert.dispose();
    roundProgress.dispose();
    enemiesRemaining.dispose();
    allWavesSpawned.dispose();
    ownedWeapons.dispose();
    equippedWeaponIndex.dispose();
    equippedWeaponHeat.dispose();
    dashCharge.dispose();
    performanceOverlayEnabled.dispose();
    fps.dispose();
    activeMobCount.dispose();
    activeBulletCount.dispose();
    activeParticleCount.dispose();
    activeCoinCount.dispose();
    activeCloudCount.dispose();
    contextTip.dispose();
    bossName.dispose();
    bossHealthFraction.dispose();
  }
}
