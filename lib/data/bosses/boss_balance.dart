/// Damage-calculator formulas used to size boss encounters (rounds 3, 6, 9)
/// so they stay roughly proportional to the player's growing power without
/// needing per-round hand-tuning.
library;

const double bossChargeDamagePressureMultiplier = 1.15;
const double bossContactDamagePressureMultiplier = 1.20;

/// REALIZED effective player DPS into a boss at [round] - what a player who
/// does what the game teaches (swap to the boss's color) actually achieves.
/// ~15 at round 1 blends the matched single-weapon outputs (rifle ~21.6, shotgun
/// ~29 close, smg ~22) down for shotgun range falloff and weapon variety, but
/// crucially does NOT discount for "firing uptime while dodging": with auto-aim
/// the weapon fires continuously while the player moves, so uptime is ~full.
/// (An earlier 11.5 assumed dodging cut firing time, which is false for an
/// auto-aim game - it left section finales dying in ~25-30s vs their target.)
/// Grows +6%/round for upgrades. Because this is the *realized* figure, boss HP
/// is sized directly as dps x fightSeconds, and the KRAS pre-seed is conditional
/// (see `pdac_game._spawnBoss`) so it doesn't double-discount the matched player.
/// Difficulty scales damage-to-player (not boss HP), so a struggling learner on
/// Assist survives the slightly longer fight via reduced incoming damage.
double estimatedPlayerDps(int round) {
  return 15 * _pow(1.06, round - 1);
}

/// Target duration (seconds) for a boss fight at [round]. Only meaningful
/// for boss rounds (3, 6, 9); other rounds fall back to a 45s default.
double targetBossFightSeconds(int round) {
  switch (round) {
    // Sized so the boss dies in ~30s, leaving room for adds/spawn within a
    // ~45s round (boss HP auto-derives as estimatedPlayerDps * fightSeconds).
    case 3:
      return 28;
    case 6:
      return 30;
    case 9:
      return 33;
    default:
      return 45;
  }
}

/// All sizing numbers for a boss encounter at [round].
class BossBalance {
  const BossBalance({
    required this.maxHealth,
    required this.chargeDamage,
    required this.contactDps,
    required this.addSpawnCount,
    required this.fightSeconds,
  });

  /// Total boss HP, sized so the fight lasts roughly [fightSeconds] at the
  /// player's [estimatedPlayerDps] (which is already a realized figure, so no
  /// extra drag factor is applied).
  final double maxHealth;

  /// Damage dealt by the boss's telegraphed charge attack.
  final double chargeDamage;

  /// Damage per second dealt while the player is in contact with the boss.
  final double contactDps;

  /// Number of minion "adds" spawned at each health threshold.
  final int addSpawnCount;

  /// Target fight duration in seconds.
  final double fightSeconds;
}

/// Computes [BossBalance] for the boss encountered at [round] (expected to
/// be 3, 6, or 9).
BossBalance calculateBossBalance(int round) {
  final dps = estimatedPlayerDps(round);
  final fightSeconds = targetBossFightSeconds(round);

  // dps is already the realized effective figure, so HP is sized directly.
  final maxHealth = dps * fightSeconds;

  // Player max HP is a constant 100 (it does not scale per round), so size the
  // charge survival budget against the real pool rather than an assumed-growing
  // one. Longer late fights therefore spread that budget over more charge
  // windows (lower per-charge), which is correct - late bosses also bring more
  // contact, projectiles, and adds.
  const playerMaxHp = 100;
  const survivalBudget = playerMaxHp * 0.6;

  final baseChargeDamage = survivalBudget / (fightSeconds / 8);
  final chargeDamage = (baseChargeDamage * bossChargeDamagePressureMultiplier)
      .clamp(8.0, 35.0);
  final contactDps = (chargeDamage / 6) * bossContactDamagePressureMultiplier;

  // Boss index (0, 1, 2 for rounds 3, 6, 9) -> 2, 3, 4 adds per threshold.
  final bossIndex = (round ~/ 3) - 1;
  final addSpawnCount = 2 + bossIndex;

  return BossBalance(
    maxHealth: maxHealth,
    chargeDamage: chargeDamage,
    contactDps: contactDps,
    addSpawnCount: addSpawnCount,
    fightSeconds: fightSeconds,
  );
}

double _pow(double base, int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= base;
  }
  return result;
}
