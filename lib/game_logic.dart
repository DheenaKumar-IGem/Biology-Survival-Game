import 'dart:convert';
import 'dart:math' as math;

enum RunMode {
  normal,
  developer,
  tutorial,
}

enum GameDifficulty {
  easy,
  normal,
  hard,
}

enum GraphicsQualityPreset {
  low,
  medium,
  high,
}

extension GameDifficultyPresentation on GameDifficulty {
  String get title => switch (this) {
        GameDifficulty.easy => 'Easy',
        GameDifficulty.normal => 'Normal',
        GameDifficulty.hard => 'Hard',
      };
}

extension GraphicsQualityPresetPresentation on GraphicsQualityPreset {
  String get title => switch (this) {
        GraphicsQualityPreset.low => 'Low',
        GraphicsQualityPreset.medium => 'Medium',
        GraphicsQualityPreset.high => 'High',
      };

  String get description => switch (this) {
        GraphicsQualityPreset.low =>
          'Prioritizes 60 FPS with fewer effects, lower caps, and simpler enemy art.',
        GraphicsQualityPreset.medium =>
          'Balanced visuals with adaptive scaling for web and mobile.',
        GraphicsQualityPreset.high =>
          'Richer visuals and higher caps, with emergency scaling if FPS drops.',
      };
}

enum CharacterFrame {
  bioSquare(
    title: 'Bio Square',
    description: 'Balanced classroom starter frame.',
    unlockCost: 0,
    speedMultiplier: 1.0,
    bonusLives: 0,
    startingShields: 0,
    sampleMagnetBonus: 0,
  ),
  lymphocyteScout(
    title: 'Lymphocyte Scout',
    description: 'Moves faster and pulls samples from slightly farther away.',
    unlockCost: 12,
    speedMultiplier: 1.08,
    bonusLives: 0,
    startingShields: 0,
    sampleMagnetBonus: 24,
  ),
  macrophageGuard(
    title: 'Macrophage Guard',
    description: 'Starts with more survivability for safer boss attempts.',
    unlockCost: 32,
    speedMultiplier: 0.97,
    bonusLives: 1,
    startingShields: 1,
    sampleMagnetBonus: 0,
  ),
  signalPrism(
    title: 'Signal Prism',
    description: 'A late-run support frame with speed, range, and a shield.',
    unlockCost: 64,
    speedMultiplier: 1.05,
    bonusLives: 1,
    startingShields: 1,
    sampleMagnetBonus: 36,
  );

  const CharacterFrame({
    required this.title,
    required this.description,
    required this.unlockCost,
    required this.speedMultiplier,
    required this.bonusLives,
    required this.startingShields,
    required this.sampleMagnetBonus,
  });

  final String title;
  final String description;
  final int unlockCost;
  final double speedMultiplier;
  final int bonusLives;
  final int startingShields;
  final double sampleMagnetBonus;
}

enum LauncherEntryStatus {
  available,
  comingSoon,
}

enum LauncherGameId {
  squareShooter,
  bloodDefense,
}

class LauncherEntry {
  const LauncherEntry({
    required this.title,
    required this.description,
    required this.status,
    this.gameId,
    this.credit,
  });

  final String title;
  final String description;
  final LauncherEntryStatus status;
  final LauncherGameId? gameId;
  final String? credit;
}

class DesignInterviewChoice {
  const DesignInterviewChoice({
    required this.id,
    required this.label,
    required this.description,
  });

  final String id;
  final String label;
  final String description;
}

class DesignInterviewQuestion {
  const DesignInterviewQuestion({
    required this.id,
    required this.title,
    required this.prompt,
    required this.whyItMatters,
    required this.recommendedChoiceId,
    required this.recommendation,
    required this.choices,
  });

  final String id;
  final String title;
  final String prompt;
  final String whyItMatters;
  final String recommendedChoiceId;
  final String recommendation;
  final List<DesignInterviewChoice> choices;
}

const List<DesignInterviewQuestion> designInterviewQuestions = [
  DesignInterviewQuestion(
    id: 'mid_round_progression',
    title: 'Question 1',
    prompt:
        'To make combat feel more like Vampire Survivors, should each round have its own in-combat XP or sample meter that grants level-up choices before the lesson screen?',
    whyItMatters:
        'The current game only spikes in power between rounds. That means each combat segment can feel flat even when the build system is good.',
    recommendedChoiceId: 'yes_samples',
    recommendation:
        'Recommended: yes. Keep coins for the education/shop loop, but add a separate in-round XP or sample meter so every round has 2 to 4 exciting power spikes.',
    choices: [
      DesignInterviewChoice(
        id: 'yes_samples',
        label: 'Yes, add samples',
        description:
            'Best Survivor-style fit. Gives each round momentum and real-time build decisions without removing lessons.',
      ),
      DesignInterviewChoice(
        id: 'small_orbs_only',
        label: 'Yes, but light-touch',
        description:
            'Adds a small amount of in-round growth, but keeps most power in the round-end shop.',
      ),
      DesignInterviewChoice(
        id: 'no_samples',
        label: 'No, keep current structure',
        description:
            'Safer scope, but combat may stay less dynamic because progression still happens almost entirely after a round ends.',
      ),
    ],
  ),
  DesignInterviewQuestion(
    id: 'round_density',
    title: 'Question 2',
    prompt:
        'Once in-round progression exists, what should be the main source of entertainment inside a wave: huge enemy density, dangerous elites, or objective-style moments?',
    whyItMatters:
        'This decides whether the game feels like a horde survival lawnmower, a tactical arena with priority targets, or a more event-driven survival game.',
    recommendedChoiceId: 'density_plus_elites',
    recommendation:
        'Recommended: huge density plus occasional elites. That is the closest match to Survivor-style excitement while still fitting the existing auto-fire and boss framework.',
    choices: [
      DesignInterviewChoice(
        id: 'density_plus_elites',
        label: 'Density + elites',
        description:
            'Large swarms with occasional high-value threats. Strongest fit for a Vampire Survivors-like feel.',
      ),
      DesignInterviewChoice(
        id: 'mostly_elites',
        label: 'Mostly elites',
        description: 'More tactical and readable, but less horde-spectacle.',
      ),
      DesignInterviewChoice(
        id: 'objective_moments',
        label: 'Objective moments',
        description:
            'Adds variety with escort, zone, or survival tasks, but moves farther from the pure Survivor formula.',
      ),
    ],
  ),
  DesignInterviewQuestion(
    id: 'power_choice_style',
    title: 'Question 3',
    prompt:
        'When the player levels up during combat, should the choices mostly improve existing weapons, add new passive effects, or introduce temporary power spikes?',
    whyItMatters:
        'This determines whether the game becomes a build-crafting run, a spectacle engine, or a burst-heavy arcade game.',
    recommendedChoiceId: 'mostly_weapon_growth',
    recommendation:
        'Recommended: mostly improve existing weapons plus a few passives. It builds clear synergies and keeps the player learning one run at a time.',
    choices: [
      DesignInterviewChoice(
        id: 'mostly_weapon_growth',
        label: 'Mostly weapon growth',
        description:
            'Best for synergy, clarity, and satisfying “my build is coming online” moments.',
      ),
      DesignInterviewChoice(
        id: 'mostly_passives',
        label: 'Mostly passives',
        description:
            'Cleaner to balance, but less immediately exciting than visible weapon changes.',
      ),
      DesignInterviewChoice(
        id: 'temporary_spikes',
        label: 'Temporary spikes',
        description:
            'Very flashy, but can make runs feel swingy instead of steadily stronger.',
      ),
    ],
  ),
  DesignInterviewQuestion(
    id: 'optimization_priority',
    title: 'Question 4',
    prompt:
        'While we make the game more entertaining, should the first technical optimization pass focus on performance during dense waves or on readability and bug-proofing first?',
    whyItMatters:
        'The code currently does repeated full-scene scans for collisions, target search, and area damage. That is fine now, but it will start to matter once enemy counts climb.',
    recommendedChoiceId: 'performance_first',
    recommendation:
        'Recommended: performance during dense waves first. Survivor-style fun depends on supporting more enemies, more effects, and more projectiles without the game getting mushy.',
    choices: [
      DesignInterviewChoice(
        id: 'performance_first',
        label: 'Performance first',
        description:
            'Lets us safely raise enemy counts and effect density after the audit.',
      ),
      DesignInterviewChoice(
        id: 'readability_first',
        label: 'Readability first',
        description:
            'Safer refactor path, but delays the big horde-feel upgrades.',
      ),
      DesignInterviewChoice(
        id: 'balanced_pass',
        label: 'Balanced pass',
        description:
            'Split effort between cleanup and performance, but progress on both will be slower.',
      ),
    ],
  ),
];

enum WeaponType {
  standard(
    title: 'Starter Blaster',
    description: 'Fast single shots. Reliable and simple.',
    purchaseCost: 0,
  ),
  scatter(
    title: 'Scatter Shot',
    description: 'Fires a cone of pellets for close-range crowd clearing.',
    purchaseCost: 48,
  ),
  homing(
    title: 'Homing Shot',
    description: 'Seeker rounds bend toward enemies.',
    purchaseCost: 62,
  ),
  heavy(
    title: 'Heavy Shot',
    description: 'Huge cannon rounds with strong damage and knockback feel.',
    purchaseCost: 72,
  ),
  twin(
    title: 'Twin Shot',
    description: 'Two side-by-side bullets every attack.',
    purchaseCost: 58,
  ),
  burst(
    title: 'Burst Cannon',
    description: 'Fires a tight burst of quick bullets.',
    purchaseCost: 64,
  ),
  pierce(
    title: 'Pierce Rifle',
    description: 'Rail-like shots pass through multiple enemies.',
    purchaseCost: 78,
  ),
  sniper(
    title: 'Sniper Lance',
    description: 'Very fast, very hard-hitting precision shots.',
    purchaseCost: 90,
  ),
  nova(
    title: 'Nova Ring',
    description:
        'Shoots a circular burst around the player like a survivor arena weapon.',
    purchaseCost: 96,
  );

  const WeaponType({
    required this.title,
    required this.description,
    required this.purchaseCost,
  });

  final String title;
  final String description;
  final int purchaseCost;
}

enum BossType {
  stalkerApex(
    title: 'Apex Striker',
    subtitle: 'Agile hunter that dodges shots and bursts through open lanes.',
  ),
  splitterQueen(
    title: 'Splitter Broodmother',
    subtitle: 'Summons brood waves and collapses the arena at low health.',
  ),
  chargerBrute(
    title: 'Charger Brute',
    subtitle: 'Heavy lane charges that split into three mitosis fragments.',
  );

  const BossType({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}

enum PickupType {
  shield(
    title: 'Shield Membrane',
    description: 'Absorbs the next hit.',
  ),
  magnet(
    title: 'Magnet Pulse',
    description: 'Retired pickup.',
  );

  const PickupType({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

enum MiniWeaponType {
  sentryPod(
    unlockCost: 32,
  ),
  burstBeacon(
    unlockCost: 34,
  ),
  lineDrive(
    unlockCost: 36,
  ),
  snapPrism(
    unlockCost: 34,
  ),
  rhythmRing(
    unlockCost: 38,
  ),
  crossCadence(
    unlockCost: 40,
  );

  const MiniWeaponType({
    required this.unlockCost,
  });

  final int unlockCost;
}

// Edit these values to rename every mini weapon in one place.
final Map<MiniWeaponType, String> miniWeaponTitles = <MiniWeaponType, String>{
  MiniWeaponType.sentryPod: 'Turret',
  MiniWeaponType.burstBeacon: 'Burst Turret',
  MiniWeaponType.lineDrive: 'Beam',
  MiniWeaponType.snapPrism: 'Fan Burst',
  MiniWeaponType.rhythmRing: 'Pulse Ring',
  MiniWeaponType.crossCadence: 'Cross',
};

final Map<MiniWeaponType, String> miniWeaponDescriptions =
    <MiniWeaponType, String>{
  MiniWeaponType.sentryPod:
      'Drops a defensive turret that quickly covers nearby threats.',
  MiniWeaponType.burstBeacon: 'Retired prototype weapon.',
  MiniWeaponType.lineDrive:
      'Carves a forward beam lane that pushes enemies back.',
  MiniWeaponType.snapPrism: 'Movement changes release forgiving fan bursts.',
  MiniWeaponType.rhythmRing: 'Emits panic-clearing rings around you.',
  MiniWeaponType.crossCadence:
      'Fires dependable crossfire that covers the arena.',
};

const List<MiniWeaponType> availableMiniWeaponTypes = <MiniWeaponType>[
  MiniWeaponType.sentryPod,
  MiniWeaponType.lineDrive,
  MiniWeaponType.snapPrism,
  MiniWeaponType.rhythmRing,
  MiniWeaponType.crossCadence,
];

const int miniWeaponSlotCap = 4;
const int miniWeaponLevelCap = 8;
const int miniWeaponBranchUnlockLevel = 3;
const int miniWeaponEvolutionLevel = 8;

extension MiniWeaponTypeDisplay on MiniWeaponType {
  String get title => miniWeaponTitles[this] ?? name;
  String get description => miniWeaponDescriptions[this] ?? '';
}

enum SpecialOfferKind {
  mainWeaponUnlock,
  mainWeaponUpgrade,
  miniWeaponUnlock,
  miniWeaponUpgrade,
}

class SpecialOffer {
  const SpecialOffer._({
    required this.kind,
    this.weapon,
    this.miniWeapon,
    required this.cost,
  });

  factory SpecialOffer.mainWeaponUnlock(WeaponType weapon) {
    return SpecialOffer._(
      kind: SpecialOfferKind.mainWeaponUnlock,
      weapon: weapon,
      cost: weapon.purchaseCost,
    );
  }

  factory SpecialOffer.mainWeaponUpgrade(WeaponType weapon, int currentLevel) {
    return SpecialOffer._(
      kind: SpecialOfferKind.mainWeaponUpgrade,
      weapon: weapon,
      cost: specialWeaponUpgradeCost(weapon, currentLevel),
    );
  }

  factory SpecialOffer.miniWeaponUnlock(MiniWeaponType miniWeapon) {
    return SpecialOffer._(
      kind: SpecialOfferKind.miniWeaponUnlock,
      miniWeapon: miniWeapon,
      cost: miniWeapon.unlockCost,
    );
  }

  factory SpecialOffer.miniWeaponUpgrade(
      MiniWeaponType miniWeapon, int currentLevel) {
    return SpecialOffer._(
      kind: SpecialOfferKind.miniWeaponUpgrade,
      miniWeapon: miniWeapon,
      cost: miniWeaponUpgradeCost(miniWeapon, currentLevel),
    );
  }

  final SpecialOfferKind kind;
  final WeaponType? weapon;
  final MiniWeaponType? miniWeapon;
  final int cost;

  String get title {
    switch (kind) {
      case SpecialOfferKind.mainWeaponUnlock:
        return weapon!.title;
      case SpecialOfferKind.mainWeaponUpgrade:
        return '${weapon!.title} Amplify';
      case SpecialOfferKind.miniWeaponUnlock:
      case SpecialOfferKind.miniWeaponUpgrade:
        return miniWeapon!.title;
    }
  }

  String get description {
    switch (kind) {
      case SpecialOfferKind.mainWeaponUnlock:
        return weapon!.description;
      case SpecialOfferKind.mainWeaponUpgrade:
        return 'Boosts ${weapon!.title} special power for the next fights.';
      case SpecialOfferKind.miniWeaponUnlock:
        return miniWeapon!.description;
      case SpecialOfferKind.miniWeaponUpgrade:
        return 'Improves ${miniWeapon!.title} to its next tier.';
    }
  }
}

int specialWeaponUpgradeCost(WeaponType weapon, int currentLevel) {
  return 30 + weapon.index * 10 + currentLevel * 22;
}

int miniWeaponUpgradeCost(MiniWeaponType type, int currentLevel) {
  return type.unlockCost + 12 + currentLevel * 20;
}

PickupType bossRewardPickupForIndex(int bossRewardsGranted) {
  return PickupType.shield;
}

List<SpecialOffer> buildSpecialRoundOffers({
  required math.Random rng,
  required bool weaponPathLocked,
  required Set<WeaponType> unlockedWeapons,
  required WeaponType activeWeapon,
  required Map<WeaponType, int> weaponSpecialLevels,
  required Map<MiniWeaponType, int> miniWeaponLevels,
  required Set<MiniWeaponType> equippedMiniWeapons,
}) {
  if (!weaponPathLocked) {
    final candidates = WeaponType.values
        .where((weapon) =>
            weapon != WeaponType.standard && !unlockedWeapons.contains(weapon))
        .toList()
      ..shuffle(rng);
    return [
      for (final weapon in candidates.take(math.min(3, candidates.length)))
        SpecialOffer.mainWeaponUnlock(weapon),
    ];
  }

  final offers = <SpecialOffer>[
    SpecialOffer.mainWeaponUpgrade(
      activeWeapon,
      weaponSpecialLevels[activeWeapon] ?? 0,
    ),
  ];
  final unlockedMiniWeapons = miniWeaponLevels.entries
      .where((entry) => entry.value > 0)
      .map((entry) => entry.key)
      .toSet();

  void addMiniUnlocks() {
    final unlocks = availableMiniWeaponTypes
        .where((type) => !unlockedMiniWeapons.contains(type))
        .toList()
      ..shuffle(rng);
    for (final type in unlocks) {
      if (offers.length >= 4) {
        return;
      }
      offers.add(SpecialOffer.miniWeaponUnlock(type));
    }
  }

  void addMiniUpgrades() {
    final upgrades = <MiniWeaponType>[
      ...equippedMiniWeapons,
      ...availableMiniWeaponTypes.where(
        (type) =>
            !equippedMiniWeapons.contains(type) &&
            (miniWeaponLevels[type] ?? 0) > 0,
      ),
    ]
        .where((type) =>
            (miniWeaponLevels[type] ?? 0) > 0 &&
            (miniWeaponLevels[type] ?? 0) < 3)
        .toList()
      ..shuffle(rng);
    for (final type in upgrades) {
      if (offers.length >= 4) {
        return;
      }
      if (offers.any((offer) => offer.miniWeapon == type)) {
        continue;
      }
      offers.add(
          SpecialOffer.miniWeaponUpgrade(type, miniWeaponLevels[type] ?? 1));
    }
  }

  if (equippedMiniWeapons.length < 3) {
    addMiniUnlocks();
    if (offers.length < 4) {
      addMiniUpgrades();
    }
  } else {
    addMiniUpgrades();
  }

  return offers;
}

class QuizResolution {
  const QuizResolution({
    required this.discountMultiplier,
    required this.coinFee,
    required this.triggersFrenzy,
    required this.scoreBonus,
    required this.title,
    required this.summary,
  });

  final double discountMultiplier;
  final int coinFee;
  final bool triggersFrenzy;
  final int scoreBonus;
  final String title;
  final String summary;
}

QuizResolution resolveQuizResolution({
  required int correctCount,
  required int currentCredits,
}) {
  if (correctCount >= 3) {
    return const QuizResolution(
      discountMultiplier: 0.50,
      coinFee: 0,
      triggersFrenzy: false,
      scoreBonus: 120,
      title: '3 / 3 correct',
      summary: 'Great round. Shop prices are 50% off before the next wave.',
    );
  }
  if (correctCount == 2) {
    return const QuizResolution(
      discountMultiplier: 0.80,
      coinFee: 0,
      triggersFrenzy: false,
      scoreBonus: 70,
      title: '2 / 3 correct',
      summary: 'Solid round. Shop prices are 20% off before the next wave.',
    );
  }
  if (correctCount == 1) {
    return const QuizResolution(
      discountMultiplier: 1.0,
      coinFee: 0,
      triggersFrenzy: true,
      scoreBonus: 20,
      title: '1 / 3 correct',
      summary: 'No discount. The next wave gets stronger for 12 seconds.',
    );
  }
  final fee = currentCredits <= 0
      ? 0
      : math.min(math.max(5, (currentCredits * 0.2).ceil()), currentCredits);
  return QuizResolution(
    discountMultiplier: 1.0,
    coinFee: fee,
    triggersFrenzy: true,
    scoreBonus: -20,
    title: '0 / 3 correct',
    summary:
        'No discount. The next wave gets stronger for 12 seconds and you lose $fee coins.',
  );
}

class RunScoreInputs {
  const RunScoreInputs({
    required this.kills,
    required this.bossesDefeated,
    required this.roundsCleared,
    required this.quizPerfectRounds,
    required this.quizSolidRounds,
    required this.quizWeakRounds,
    required this.survivalSeconds,
    required this.masteryMode,
  });

  final int kills;
  final int bossesDefeated;
  final int roundsCleared;
  final int quizPerfectRounds;
  final int quizSolidRounds;
  final int quizWeakRounds;
  final double survivalSeconds;
  final bool masteryMode;
}

int calculateRunScore(RunScoreInputs inputs) {
  final masteryBonus = inputs.masteryMode ? inputs.roundsCleared * 25 : 0;
  return (inputs.kills * 12) +
      (inputs.bossesDefeated * 220) +
      (inputs.roundsCleared * 70) +
      (inputs.quizPerfectRounds * 120) +
      (inputs.quizSolidRounds * 70) -
      (inputs.quizWeakRounds * 25) +
      inputs.survivalSeconds.floor() +
      masteryBonus;
}

List<BossType> unlockedBossPool(int bossRoundsSeen) {
  if (bossRoundsSeen <= 1) {
    return <BossType>[BossType.stalkerApex];
  }
  if (bossRoundsSeen == 2) {
    return <BossType>[BossType.stalkerApex, BossType.splitterQueen];
  }
  return <BossType>[
    BossType.stalkerApex,
    BossType.splitterQueen,
    BossType.chargerBrute,
  ];
}

BossType pickBossType({
  required math.Random rng,
  required int bossRoundsSeen,
  required BossType? lastBossType,
}) {
  if (bossRoundsSeen == 1) {
    return BossType.stalkerApex;
  }
  if (bossRoundsSeen == 2) {
    return BossType.splitterQueen;
  }
  if (bossRoundsSeen == 3) {
    return BossType.chargerBrute;
  }
  final pool = unlockedBossPool(bossRoundsSeen);
  if (pool.length <= 1 ||
      lastBossType == null ||
      !pool.contains(lastBossType)) {
    return pool[rng.nextInt(pool.length)];
  }
  final filtered = pool.where((boss) => boss != lastBossType).toList();
  return filtered[rng.nextInt(filtered.length)];
}

T? enumByNameOrNull<T extends Enum>(Iterable<T> values, String? name) {
  if (name == null || name.isEmpty) {
    return null;
  }
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return null;
}

class PersistedCheckpointSnapshot {
  const PersistedCheckpointSnapshot({
    required this.round,
    required this.lessonCursor,
    required this.masteryMode,
    required this.difficultyName,
    required this.credits,
    required this.kills,
    required this.lives,
    required this.totalCoinsCollected,
    required this.survivalTime,
    required this.roundsCleared,
    required this.bossesDefeated,
    required this.quizPerfectRounds,
    required this.quizSolidRounds,
    required this.quizWeakRounds,
    required this.enemyFrenzyTimer,
    required this.activeWeaponName,
    required this.lockedWeaponName,
    required this.upgradeLevels,
    required this.weaponUnlocks,
    required this.weaponSpecialLevels,
    required this.weaponBranchIds,
    required this.miniWeaponLevels,
    required this.miniWeaponBranchIds,
    required this.equippedMiniWeapons,
    required this.passiveLevels,
    required this.shieldCharges,
    required this.bossRoundsSeen,
    required this.lastBossTypeName,
    required this.activeWeaponEvolved,
    this.evolvedMiniWeapons = const <String>[],
    required this.bankedBossSamples,
    required this.nextRoundPressureLevel,
  });

  final int round;
  final int lessonCursor;
  final bool masteryMode;
  final String difficultyName;
  final int credits;
  final int kills;
  final int lives;
  final int totalCoinsCollected;
  final double survivalTime;
  final int roundsCleared;
  final int bossesDefeated;
  final int quizPerfectRounds;
  final int quizSolidRounds;
  final int quizWeakRounds;
  final double enemyFrenzyTimer;
  final String activeWeaponName;
  final String? lockedWeaponName;
  final Map<String, int> upgradeLevels;
  final Map<String, bool> weaponUnlocks;
  final Map<String, int> weaponSpecialLevels;
  final Map<String, String> weaponBranchIds;
  final Map<String, int> miniWeaponLevels;
  final Map<String, String> miniWeaponBranchIds;
  final List<String> equippedMiniWeapons;
  final Map<String, int> passiveLevels;
  final int shieldCharges;
  final int bossRoundsSeen;
  final String? lastBossTypeName;
  final bool activeWeaponEvolved;
  final List<String> evolvedMiniWeapons;
  final int bankedBossSamples;
  final int nextRoundPressureLevel;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'round': round,
      'lessonCursor': lessonCursor,
      'masteryMode': masteryMode,
      'difficultyName': difficultyName,
      'credits': credits,
      'kills': kills,
      'lives': lives,
      'totalCoinsCollected': totalCoinsCollected,
      'survivalTime': survivalTime,
      'roundsCleared': roundsCleared,
      'bossesDefeated': bossesDefeated,
      'quizPerfectRounds': quizPerfectRounds,
      'quizSolidRounds': quizSolidRounds,
      'quizWeakRounds': quizWeakRounds,
      'enemyFrenzyTimer': enemyFrenzyTimer,
      'activeWeaponName': activeWeaponName,
      'lockedWeaponName': lockedWeaponName,
      'upgradeLevels': upgradeLevels,
      'weaponUnlocks': weaponUnlocks,
      'weaponSpecialLevels': weaponSpecialLevels,
      'weaponBranchIds': weaponBranchIds,
      'miniWeaponLevels': miniWeaponLevels,
      'miniWeaponBranchIds': miniWeaponBranchIds,
      'equippedMiniWeapons': equippedMiniWeapons,
      'passiveLevels': passiveLevels,
      'shieldCharges': shieldCharges,
      'bossRoundsSeen': bossRoundsSeen,
      'lastBossTypeName': lastBossTypeName,
      'activeWeaponEvolved': activeWeaponEvolved,
      'evolvedMiniWeapons': evolvedMiniWeapons,
      'bankedBossSamples': bankedBossSamples,
      'nextRoundPressureLevel': nextRoundPressureLevel,
    };
  }

  factory PersistedCheckpointSnapshot.fromJson(Map<String, dynamic> json) {
    Map<String, int> readIntMap(Object? value) {
      if (value is! Map) {
        return <String, int>{};
      }
      return value.map<String, int>((key, dynamic mapValue) =>
          MapEntry(key.toString(), (mapValue as num).toInt()));
    }

    Map<String, bool> readBoolMap(Object? value) {
      if (value is! Map) {
        return <String, bool>{};
      }
      return value.map<String, bool>((key, dynamic mapValue) =>
          MapEntry(key.toString(), mapValue == true));
    }

    Map<String, String> readStringMap(Object? value) {
      if (value is! Map) {
        return <String, String>{};
      }
      return value.map<String, String>(
        (key, dynamic mapValue) =>
            MapEntry(key.toString(), mapValue.toString()),
      );
    }

    return PersistedCheckpointSnapshot(
      round: (json['round'] as num?)?.toInt() ?? 1,
      lessonCursor: (json['lessonCursor'] as num?)?.toInt() ?? 0,
      masteryMode: json['masteryMode'] == true,
      difficultyName:
          json['difficultyName'] as String? ?? GameDifficulty.normal.name,
      credits: (json['credits'] as num?)?.toInt() ?? 0,
      kills: (json['kills'] as num?)?.toInt() ?? 0,
      lives: (json['lives'] as num?)?.toInt() ?? 3,
      totalCoinsCollected: (json['totalCoinsCollected'] as num?)?.toInt() ?? 0,
      survivalTime: (json['survivalTime'] as num?)?.toDouble() ?? 0,
      roundsCleared: (json['roundsCleared'] as num?)?.toInt() ?? 0,
      bossesDefeated: (json['bossesDefeated'] as num?)?.toInt() ?? 0,
      quizPerfectRounds: (json['quizPerfectRounds'] as num?)?.toInt() ?? 0,
      quizSolidRounds: (json['quizSolidRounds'] as num?)?.toInt() ?? 0,
      quizWeakRounds: (json['quizWeakRounds'] as num?)?.toInt() ?? 0,
      enemyFrenzyTimer: (json['enemyFrenzyTimer'] as num?)?.toDouble() ?? 0,
      activeWeaponName:
          json['activeWeaponName'] as String? ?? WeaponType.standard.name,
      lockedWeaponName: json['lockedWeaponName'] as String?,
      upgradeLevels: readIntMap(json['upgradeLevels']),
      weaponUnlocks: readBoolMap(json['weaponUnlocks']),
      weaponSpecialLevels: readIntMap(json['weaponSpecialLevels']),
      weaponBranchIds: readStringMap(json['weaponBranchIds']),
      miniWeaponLevels: readIntMap(json['miniWeaponLevels']),
      miniWeaponBranchIds: readStringMap(json['miniWeaponBranchIds']),
      equippedMiniWeapons: [
        for (final dynamic value
            in (json['equippedMiniWeapons'] as List<dynamic>? ??
                const <dynamic>[]))
          value.toString(),
      ],
      passiveLevels: readIntMap(json['passiveLevels']),
      shieldCharges: (json['shieldCharges'] as num?)?.toInt() ?? 0,
      bossRoundsSeen: (json['bossRoundsSeen'] as num?)?.toInt() ?? 0,
      lastBossTypeName: json['lastBossTypeName'] as String?,
      activeWeaponEvolved: json['activeWeaponEvolved'] == true,
      evolvedMiniWeapons: [
        for (final dynamic value
            in (json['evolvedMiniWeapons'] as List<dynamic>? ??
                const <dynamic>[]))
          value.toString(),
      ],
      bankedBossSamples: (json['bankedBossSamples'] as num?)?.toInt() ?? 0,
      nextRoundPressureLevel:
          (json['nextRoundPressureLevel'] as num?)?.toInt() ?? 0,
    );
  }
}

class PersistedMetaState {
  const PersistedMetaState({
    required this.tutorialSeen,
    required this.courseCompleted,
    required this.bestCourseScore,
    required this.bestMasteryScore,
    required this.researchPoints,
    required this.selectedCharacterName,
    required this.unlockedCharacterNames,
    required this.biologyResourcePackEnabled,
    required this.graphicsQualityPresetName,
    required this.vSyncPacingEnabled,
    required this.autoPerformanceScalingEnabled,
    required this.reducedEffectsEnabled,
    required this.fpsMeterVisible,
    required this.checkpoint,
  });

  final bool tutorialSeen;
  final bool courseCompleted;
  final int bestCourseScore;
  final int bestMasteryScore;
  final int researchPoints;
  final String selectedCharacterName;
  final List<String> unlockedCharacterNames;
  final bool biologyResourcePackEnabled;
  final String graphicsQualityPresetName;
  final bool vSyncPacingEnabled;
  final bool autoPerformanceScalingEnabled;
  final bool reducedEffectsEnabled;
  final bool fpsMeterVisible;
  final PersistedCheckpointSnapshot? checkpoint;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'tutorialSeen': tutorialSeen,
      'courseCompleted': courseCompleted,
      'bestCourseScore': bestCourseScore,
      'bestMasteryScore': bestMasteryScore,
      'researchPoints': researchPoints,
      'selectedCharacterName': selectedCharacterName,
      'unlockedCharacterNames': unlockedCharacterNames,
      'biologyResourcePackEnabled': biologyResourcePackEnabled,
      'graphicsQualityPresetName': graphicsQualityPresetName,
      'vSyncPacingEnabled': vSyncPacingEnabled,
      'autoPerformanceScalingEnabled': autoPerformanceScalingEnabled,
      'reducedEffectsEnabled': reducedEffectsEnabled,
      'fpsMeterVisible': fpsMeterVisible,
      'checkpoint': checkpoint?.toJson(),
    };
  }

  String encode() => jsonEncode(toJson());

  factory PersistedMetaState.fromEncoded(String? encoded) {
    if (encoded == null || encoded.isEmpty) {
      return const PersistedMetaState(
        tutorialSeen: false,
        courseCompleted: false,
        bestCourseScore: 0,
        bestMasteryScore: 0,
        researchPoints: 0,
        selectedCharacterName: 'bioSquare',
        unlockedCharacterNames: ['bioSquare'],
        biologyResourcePackEnabled: false,
        graphicsQualityPresetName: 'medium',
        vSyncPacingEnabled: true,
        autoPerformanceScalingEnabled: true,
        reducedEffectsEnabled: false,
        fpsMeterVisible: true,
        checkpoint: null,
      );
    }
    try {
      final raw = jsonDecode(encoded);
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Expected map');
      }
      return PersistedMetaState(
        tutorialSeen: raw['tutorialSeen'] == true,
        courseCompleted: raw['courseCompleted'] == true,
        bestCourseScore: (raw['bestCourseScore'] as num?)?.toInt() ?? 0,
        bestMasteryScore: (raw['bestMasteryScore'] as num?)?.toInt() ?? 0,
        researchPoints: (raw['researchPoints'] as num?)?.toInt() ?? 0,
        selectedCharacterName:
            raw['selectedCharacterName'] as String? ?? 'bioSquare',
        unlockedCharacterNames: <String>{
          'bioSquare',
          for (final dynamic value
              in (raw['unlockedCharacterNames'] as List<dynamic>? ??
                  const <dynamic>[]))
            value.toString(),
        }.toList(),
        biologyResourcePackEnabled: raw['biologyResourcePackEnabled'] == true,
        graphicsQualityPresetName:
            raw['graphicsQualityPresetName'] as String? ?? 'medium',
        vSyncPacingEnabled: raw['vSyncPacingEnabled'] is bool
            ? raw['vSyncPacingEnabled'] as bool
            : true,
        autoPerformanceScalingEnabled:
            raw['autoPerformanceScalingEnabled'] is bool
                ? raw['autoPerformanceScalingEnabled'] as bool
                : true,
        reducedEffectsEnabled: raw['reducedEffectsEnabled'] == true,
        fpsMeterVisible: raw['fpsMeterVisible'] is bool
            ? raw['fpsMeterVisible'] as bool
            : true,
        checkpoint: raw['checkpoint'] is Map<String, dynamic>
            ? PersistedCheckpointSnapshot.fromJson(
                raw['checkpoint'] as Map<String, dynamic>)
            : null,
      );
    } catch (_) {
      return const PersistedMetaState(
        tutorialSeen: false,
        courseCompleted: false,
        bestCourseScore: 0,
        bestMasteryScore: 0,
        researchPoints: 0,
        selectedCharacterName: 'bioSquare',
        unlockedCharacterNames: ['bioSquare'],
        biologyResourcePackEnabled: false,
        graphicsQualityPresetName: 'medium',
        vSyncPacingEnabled: true,
        autoPerformanceScalingEnabled: true,
        reducedEffectsEnabled: false,
        fpsMeterVisible: true,
        checkpoint: null,
      );
    }
  }
}
