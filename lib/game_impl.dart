part of 'main.dart';

const String _saveKey = 'queen_city_igem_save_v6';

const List<LauncherEntry> launcherEntries = [
  LauncherEntry(
    title: 'Biology Game',
    description:
        'A biology-themed survivor arena with lessons, boss gates, and buildcrafting.',
    status: LauncherEntryStatus.available,
    gameId: LauncherGameId.squareShooter,
    credit: '-Dheena Kumar',
  ),
  LauncherEntry(
    title: 'Blood Vessel Defense',
    description:
        'A prototype tower defense where red blood cells march down a vessel and biological defenses stop them.',
    status: LauncherEntryStatus.available,
    gameId: LauncherGameId.bloodDefense,
    credit: '-Prototype',
  ),
  LauncherEntry(
    title: 'Coming Soon',
    description: 'Another future game slot is reserved here.',
    status: LauncherEntryStatus.comingSoon,
  ),
];

const List<String> designAuditFindings = [
  'Combat currently spikes between rounds, but power growth inside a round is still limited.',
  'Dense-wave performance will eventually be constrained by repeated full-scene scans for threats, bullets, and collisions.',
  'The game already has good build ingredients: auto-fire, bosses, mini-weapons, and round-end choices. The next step is making each wave feel more explosive.',
];

class InteractiveTutorialStep {
  const InteractiveTutorialStep({
    required this.title,
    required this.body,
    required this.goal,
  });

  final String title;
  final String body;
  final String goal;
}

const List<InteractiveTutorialStep> interactiveTutorialSteps =
    <InteractiveTutorialStep>[
  InteractiveTutorialStep(
    title: 'Move Around',
    body:
        'This is the arena. Move with WASD, arrow keys, or the on-screen joystick. Staying mobile is your main defense.',
    goal: 'Try circling the arena for a few seconds.',
  ),
  InteractiveTutorialStep(
    title: 'Dash To Reposition',
    body:
        'Dash with Space or the DASH button. Use it to slip through gaps, dodge boss lanes, or escape when enemies surround you.',
    goal: 'Dash once, then keep moving.',
  ),
  InteractiveTutorialStep(
    title: 'Mini-Weapons Attack For You',
    body:
        'Your tutorial run starts with Turret equipped. Mini-weapons fire automatically, so your job is positioning and choosing upgrades.',
    goal: 'Let the turret clear nearby enemies while you kite.',
  ),
  InteractiveTutorialStep(
    title: 'Samples Are XP',
    body:
        'Enemies drop green samples. Pick them up to fill the sample bar at the top-left and earn one in-wave upgrade choice.',
    goal: 'Collect samples until the bar fills.',
  ),
  InteractiveTutorialStep(
    title: 'Upgrade Choices',
    body:
        'When the sample bar fills, choose a mini-weapon upgrade. Upgrades should change how weapons behave, not just raise numbers.',
    goal: 'Pick an upgrade if the choice popup appears.',
  ),
  InteractiveTutorialStep(
    title: 'Read The HUD',
    body:
        'The compact HUD shows lives, round timer, sample progress, and boss health. Use it to know when to play safe.',
    goal: 'Watch the top-left during the wave.',
  ),
  InteractiveTutorialStep(
    title: 'Cleanup And Lessons',
    body:
        'When a wave ends, samples flicker during cleanup. Normal runs then show a lesson, quiz, and build draft.',
    goal: 'Stay alive until cleanup begins.',
  ),
  InteractiveTutorialStep(
    title: 'Boss Gates',
    body:
        'Every third normal round becomes a boss gate. Boss tips appear before the fight, and clearing the boss earns a premium reward.',
    goal: 'Press Finish when you are ready to return to the home page.',
  ),
];

enum RoundFlowPhase {
  idle,
  starterDraft,
  grace,
  normalWave,
  bossPrelude,
  bossFight,
  cleanup,
}

class UpgradeState {
  UpgradeState({
    required this.id,
    required this.title,
    required this.description,
    required this.baseCost,
    required this.costScale,
  });

  final String id;
  final String title;
  final String description;
  final int baseCost;
  final double costScale;
  int level = 0;
}

class WeaponState {
  WeaponState({required this.type, this.unlocked = false});

  final WeaponType type;
  bool unlocked;
  int specialLevel = 0;
  String? branchId;
}

class MiniWeaponState {
  MiniWeaponState({required this.type});

  final MiniWeaponType type;
  int level = 0;
  bool get unlocked => level > 0;
  bool equipped = false;
  String? branchId;
}

enum EnemyArchetype {
  swarm(
    label: 'Swarm',
    bodyColor: Color(0xFFE85D75),
    coreColor: Color(0xFFFFC2D1),
    baseHealth: 1,
    healthVariance: 1,
    baseSpeed: 136,
    speedVariance: 44,
    baseSize: 16,
    sizeVariance: 4,
    coinValue: 1,
  ),
  splitter(
    label: 'Splitter',
    bodyColor: Color(0xFF7AE582),
    coreColor: Color(0xFFD8F3DC),
    baseHealth: 5,
    healthVariance: 2,
    baseSpeed: 74,
    speedVariance: 16,
    baseSize: 28,
    sizeVariance: 6,
    coinValue: 1,
  ),
  rainbow(
    label: 'Rainbow',
    bodyColor: Color(0xFFFFFFFF),
    coreColor: Color(0xFFFFFFFF),
    baseHealth: 5,
    healthVariance: 2,
    baseSpeed: 118,
    speedVariance: 26,
    baseSize: 22,
    sizeVariance: 4,
    coinValue: 3,
  ),
  runner(
    label: 'Runner',
    bodyColor: Color(0xFFFFB703),
    coreColor: Color(0xFFFFE6A7),
    baseHealth: 2,
    healthVariance: 1,
    baseSpeed: 104,
    speedVariance: 30,
    baseSize: 22,
    sizeVariance: 6,
    coinValue: 1,
  ),
  tank(
    label: 'Tank',
    bodyColor: Color(0xFF9D4EDD),
    coreColor: Color(0xFFE0AAFF),
    baseHealth: 7,
    healthVariance: 3,
    baseSpeed: 62,
    speedVariance: 14,
    baseSize: 32,
    sizeVariance: 10,
    coinValue: 1,
  ),
  brute(
    label: 'Brute',
    bodyColor: Color(0xFFE76F51),
    coreColor: Color(0xFFFFE8D6),
    baseHealth: 10,
    healthVariance: 3,
    baseSpeed: 84,
    speedVariance: 18,
    baseSize: 30,
    sizeVariance: 8,
    coinValue: 2,
  ),
  stalker(
    label: 'Stalker',
    bodyColor: Color(0xFF00B4D8),
    coreColor: Color(0xFFCAF0F8),
    baseHealth: 4,
    healthVariance: 2,
    baseSpeed: 86,
    speedVariance: 18,
    baseSize: 24,
    sizeVariance: 7,
    coinValue: 1,
  );

  const EnemyArchetype({
    required this.label,
    required this.bodyColor,
    required this.coreColor,
    required this.baseHealth,
    required this.healthVariance,
    required this.baseSpeed,
    required this.speedVariance,
    required this.baseSize,
    required this.sizeVariance,
    required this.coinValue,
  });

  final String label;
  final Color bodyColor;
  final Color coreColor;
  final int baseHealth;
  final int healthVariance;
  final double baseSpeed;
  final double speedVariance;
  final double baseSize;
  final double sizeVariance;
  final int coinValue;
}

class SquareShooterGame extends FlameGame with KeyboardEvents {
  SquareShooterGame({SharedPreferences? preferences}) : _prefs = preferences;

  SharedPreferences? _prefs;
  final math.Random rng = math.Random();
  final ValueNotifier<int> uiTick = ValueNotifier<int>(0);
  final Set<LogicalKeyboardKey> _keysPressed = <LogicalKeyboardKey>{};
  final Map<MiniWeaponType, double> _miniWeaponTimers = {
    for (final type in MiniWeaponType.values) type: 0,
  };
  final Set<String> _shownTipIds = <String>{};
  final Map<CombatUpgradeKind, int> _combatStatLevels = {};
  final List<EnemyComponent> enemyRegistry = <EnemyComponent>[];
  final List<BossComponent> bossRegistry = <BossComponent>[];
  final List<BulletComponent> bulletRegistry = <BulletComponent>[];
  final List<EnemyProjectileComponent> enemyProjectileRegistry =
      <EnemyProjectileComponent>[];
  final List<CoinComponent> coinRegistry = <CoinComponent>[];
  final List<PickupComponent> pickupRegistry = <PickupComponent>[];
  final List<SampleComponent> sampleRegistry = <SampleComponent>[];
  final Map<math.Point<int>, List<EnemyComponent>> _enemyCollisionGrid =
      <math.Point<int>, List<EnemyComponent>>{};
  final Map<String, ui.Image> _weaponArtImages = <String, ui.Image>{};
  final Map<String, DateTime> _sfxCooldowns = <String, DateTime>{};
  final AudioCache _musicCache =
      FlameAudio.audioCacheFactory(prefix: _musicAssetPrefix);
  bool _audioEnabled = true;
  bool _audioPrimed = false;
  bool _musicSyncInProgress = false;
  bool _musicSyncQueued = false;
  AudioPlayer? _musicPlayer;
  String? _currentMusicAsset;
  String? _queuedMusicAsset;

  static const Map<MiniWeaponType, String> _miniWeaponArtPaths =
      <MiniWeaponType, String>{
    MiniWeaponType.sentryPod: 'assets/weapons/turret.png',
    MiniWeaponType.lineDrive: 'assets/weapons/beam.png',
    MiniWeaponType.snapPrism: 'assets/weapons/fan_burst.png',
    MiniWeaponType.rhythmRing: 'assets/weapons/pulse_ring.png',
    MiniWeaponType.crossCadence: 'assets/weapons/cross.png',
  };

  static const Map<String, String> _effectArtPaths = <String, String>{
    'beam': 'assets/effects/beam_blade.png',
    'arc': 'assets/effects/fan_arc.png',
    'ring': 'assets/effects/ring_wave.png',
    'mine': 'assets/effects/bio_mine.png',
    'orbit': 'assets/effects/orbit_cell.png',
  };

  static const Map<String, String> _sfxPaths = <String, String>{
    'ui': 'ui_click.wav',
    'draft': 'draft_pick.wav',
    'beam': 'beam_sweep.wav',
    'fan': 'fan_snap.wav',
    'ring': 'pulse_ring.wav',
    'turret': 'turret_ping.wav',
    'cross': 'cross_burst.wav',
    'boss': 'boss_spawn.wav',
    'hit': 'player_hit.wav',
    'pop': 'enemy_pop.wav',
    'level': 'level_up.wav',
    'quizRight': 'quiz_right.wav',
    'quizWrong': 'quiz_wrong.wav',
    'victory': 'victory_chime.wav',
  };
  static const String _sfxAssetPrefix = 'assets/sfx/';
  static const String _musicAssetPrefix = 'assets/music/';
  static const double _enemyCollisionCellSize = 96;
  static const Map<String, String> _musicPaths = <String, String>{
    'title': 'title_theme.wav',
    'arena': 'arena_theme.wav',
  };

  PlayerComponent? player;
  Vector2 touchDirection = Vector2.zero();

  final Map<String, UpgradeState> upgrades = {
    'moveSpeed': UpgradeState(
      id: 'moveSpeed',
      title: 'Movement Speed',
      description: 'Run faster so you can kite dense waves.',
      baseCost: 40,
      costScale: 1.56,
    ),
    'attackSpeed': UpgradeState(
      id: 'attackSpeed',
      title: 'Attack Speed',
      description: 'Lower your base time between attacks.',
      baseCost: 48,
      costScale: 1.60,
    ),
    'reloadSpeed': UpgradeState(
      id: 'reloadSpeed',
      title: 'Reload Speed',
      description: 'Reduce weapon downtime after its own firing pattern.',
      baseCost: 52,
      costScale: 1.64,
    ),
    'dashMastery': UpgradeState(
      id: 'dashMastery',
      title: 'Dash Mastery',
      description: 'Lower dash cooldown and extend the dash window.',
      baseCost: 58,
      costScale: 1.70,
    ),
  };

  final Map<WeaponType, WeaponState> weaponStates = {
    for (final weapon in WeaponType.values)
      weapon:
          WeaponState(type: weapon, unlocked: weapon == WeaponType.standard),
  };

  final Map<MiniWeaponType, MiniWeaponState> miniWeaponStates = {
    for (final miniWeapon in MiniWeaponType.values)
      miniWeapon: MiniWeaponState(type: miniWeapon),
  };
  final Map<PassiveType, int> passiveLevels = {
    for (final passive in PassiveType.values) passive: 0,
  };
  final Set<MiniWeaponType> evolvedMiniWeapons = <MiniWeaponType>{};

  int credits = 0;
  int kills = 0;
  int lives = 3;
  int currentRound = 1;
  int totalCoinsCollected = 0;
  int roundsCleared = 0;
  int defeatedBossCount = 0;
  int bossRewardsGranted = 0;
  int bossRoundsSeen = 0;
  int quizPerfectRounds = 0;
  int quizSolidRounds = 0;
  int quizWeakRounds = 0;
  int bestCourseScore = 0;
  int bestMasteryScore = 0;
  int researchPoints = 0;
  int researchPointsEarnedThisRun = 0;
  int shieldCharges = 0;
  int sampleCount = 0;
  int bankedBossSamples = 0;
  int combatLevelsThisRound = 0;
  int nextRoundPressureLevel = 0;
  int pendingOpeningPressureLevel = 0;

  double survivalTime = 0;
  double enemyFrenzyTimer = 0;
  double arenaVisualTime = 0;
  double currentFps = 0;
  double _fpsSampleTime = 0;
  int _fpsSampleFrames = 0;
  double bannerTimer = 0;
  double magnetTimer = 0;
  double _enemySpawnTimer = 0;
  double _clusterSpawnTimer = 0;
  double _enemySpawnInterval = 0.45;
  double _uiRefreshTimer = 0;
  double roundDuration = 0;
  double roundTimeRemaining = 0;
  double roundGraceRemaining = 0;
  double bossPreludeRemaining = 0;
  double cleanupRemaining = 0;
  double sampleCleanupFlicker = 0;

  String? bannerText;
  String? currentTipTitle;
  String? currentTipBody;

  int enemiesSpawnedThisRound = 0;
  int enemiesDefeatedThisRound = 0;
  int enemiesTargetThisRound = 18;
  bool roundBossRequired = false;
  bool roundBossSpawned = false;
  bool roundComplete = false;

  bool _initialized = false;
  bool onTitleScreen = true;
  bool runStarted = false;
  bool pausedForLevel = false;
  bool pausedForMenu = false;
  bool gameOver = false;
  bool tutorialSeen = false;
  bool startAfterTutorial = false;
  int interactiveTutorialStepIndex = 0;
  bool interactiveTutorialFinished = false;
  bool masteryMode = false;
  bool victoryPending = false;
  bool runWon = false;
  bool courseCompletedMeta = false;
  bool courseScoreRecorded = false;
  bool developerInvulnerable = false;
  bool biologyResourcePackEnabled = false;
  GraphicsQualityPreset graphicsQualityPreset = GraphicsQualityPreset.medium;
  bool vSyncPacingEnabled = true;
  bool autoPerformanceScalingEnabled = true;
  bool reducedEffectsEnabled = false;
  bool fpsMeterVisible = true;
  RunMode runMode = RunMode.normal;
  GameDifficulty selectedDifficulty = GameDifficulty.normal;
  GameDifficulty currentDifficulty = GameDifficulty.normal;
  CharacterFrame selectedCharacterFrame = CharacterFrame.bioSquare;
  Set<CharacterFrame> unlockedCharacterFrames = <CharacterFrame>{
    CharacterFrame.bioSquare,
  };
  RoundFlowPhase roundPhase = RoundFlowPhase.idle;
  bool starterDraftActive = false;
  bool pausedForCombatLevel = false;
  bool cleanupCollectOnly = false;
  bool softenNextRound = false;
  bool openingAnchorSuppressed = false;
  bool usedOpeningAnchor = false;
  bool usedFinalSpikeAnchor = false;
  bool starterDraftShown = false;
  bool chestPendingFromBoss = false;
  bool activeWeaponEvolved = false;
  bool stalkerMutationAnnounced = false;
  bool splitterMutationAnnounced = false;
  bool bruteMutationAnnounced = false;

  WeaponType activeWeapon = WeaponType.standard;
  WeaponType? lockedWeaponChoice;
  BossType? currentBossType;
  BossType? pendingBossType;
  BossType? lastBossType;
  PersistedCheckpointSnapshot? checkpointSnapshot;
  List<SpecialOffer> currentSpecialOffers = [];
  List<MiniWeaponType> currentStarterMiniWeaponOffers = <MiniWeaponType>[];
  List<CombatUpgradeOffer> currentCombatOffers = <CombatUpgradeOffer>[];

  LevelLessonSession? currentLessonSession;
  int lessonCursor = 0;
  final Map<String, String> designInterviewAnswers = <String, String>{};
  int designInterviewIndex = 0;
  bool _designInterviewOpenedFromPause = false;

  bool get isReady => player != null;
  bool get isDeveloperMode => runMode == RunMode.developer;
  bool get isTutorialMode => runMode == RunMode.tutorial;
  bool get enemyFrenzyActive => enemyFrenzyTimer > 0;
  bool get bossActive => activeBossComponent != null;
  bool get hasSavedCheckpoint => checkpointSnapshot != null;
  bool get currentRoundUsesWeaponShop => roundBossRequired;
  String get visualResourcePackLabel =>
      biologyResourcePackEnabled ? 'Biology Pack' : 'Classic Pack';
  String get graphicsQualityLabel => graphicsQualityPreset.title;
  String get framePacingLabel => vSyncPacingEnabled ? 'VSync paced' : 'Raw';
  bool get lowGraphicsMode =>
      graphicsQualityPreset == GraphicsQualityPreset.low;
  bool get highGraphicsMode =>
      graphicsQualityPreset == GraphicsQualityPreset.high;
  double get fpsProgress => (currentFps / 60).clamp(0.0, 1.0).toDouble();
  Color get fpsBarColor {
    if (currentFps >= 55) {
      return const Color(0xFF80FFDB);
    }
    if (currentFps >= 40) {
      return const Color(0xFFFFD166);
    }
    return const Color(0xFFEF476F);
  }

  String get difficultyLabel => currentDifficulty.title;
  int get maxMiniWeaponSlots => miniWeaponSlotCap;
  bool get isGameplayActive =>
      runStarted &&
      !onTitleScreen &&
      !pausedForLevel &&
      !pausedForMenu &&
      !pausedForCombatLevel &&
      !gameOver &&
      !victoryPending &&
      (roundPhase == RoundFlowPhase.grace ||
          roundPhase == RoundFlowPhase.normalWave ||
          roundPhase == RoundFlowPhase.bossPrelude ||
          roundPhase == RoundFlowPhase.bossFight ||
          roundPhase == RoundFlowPhase.cleanup);
  bool get canPlayerMove =>
      isGameplayActive &&
      (roundPhase == RoundFlowPhase.grace ||
          roundPhase == RoundFlowPhase.normalWave ||
          roundPhase == RoundFlowPhase.bossPrelude ||
          roundPhase == RoundFlowPhase.bossFight ||
          roundPhase == RoundFlowPhase.cleanup);
  bool get canPlayerAttack =>
      isGameplayActive &&
      (roundPhase == RoundFlowPhase.grace ||
          roundPhase == RoundFlowPhase.normalWave ||
          roundPhase == RoundFlowPhase.bossPrelude ||
          roundPhase == RoundFlowPhase.bossFight);
  bool get threatsActive =>
      isGameplayActive &&
      (roundPhase == RoundFlowPhase.normalWave ||
          roundPhase == RoundFlowPhase.bossPrelude ||
          roundPhase == RoundFlowPhase.bossFight);
  bool get weaponPathLocked => true;
  double get playAreaTop => 8;
  bool get _isConstrainedRuntime =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  bool get adaptivePerformanceActive {
    if (lowGraphicsMode) {
      return true;
    }
    if (!autoPerformanceScalingEnabled) {
      return false;
    }
    final fpsThreshold = highGraphicsMode ? 48 : 55;
    if (highGraphicsMode) {
      return currentFps > 0 && currentFps < fpsThreshold;
    }
    return _isConstrainedRuntime ||
        (currentFps > 0 && currentFps < fpsThreshold);
  }

  bool get criticalPerformanceActive {
    if (lowGraphicsMode) {
      return true;
    }
    final threshold = highGraphicsMode ? 38 : 42;
    return autoPerformanceScalingEnabled &&
        currentFps > 0 &&
        currentFps < threshold;
  }

  bool get reducedVisualLoad =>
      lowGraphicsMode ||
      adaptivePerformanceActive ||
      enemyRegistry.length >= (highGraphicsMode ? 58 : 42);
  bool get lowCostEnemyVisuals =>
      reducedVisualLoad ||
      (biologyResourcePackEnabled && enemyRegistry.length >= 30);
  bool get showEnemyHealthBars =>
      !lowGraphicsMode &&
      !adaptivePerformanceActive &&
      enemyRegistry.length < (highGraphicsMode ? 42 : 34);
  bool get reducedEffectsActive =>
      reducedEffectsEnabled || criticalPerformanceActive || lowGraphicsMode;
  bool get lowCostProjectileVisuals =>
      lowGraphicsMode ||
      criticalPerformanceActive ||
      bulletRegistry.length > 90;
  bool get showArenaGrid => !lowGraphicsMode && !criticalPerformanceActive;
  int get maxActiveEnemies {
    final bossAllowance = roundPhase == RoundFlowPhase.bossFight ||
            roundPhase == RoundFlowPhase.bossPrelude
        ? 8
        : 0;
    if (criticalPerformanceActive) {
      return (lowGraphicsMode ? 34 : 38) + bossAllowance;
    }
    if (adaptivePerformanceActive) {
      return (highGraphicsMode ? 58 : 50) + bossAllowance;
    }
    return (highGraphicsMode ? 84 : 68) + bossAllowance;
  }

  int get maxActivePlayerProjectiles {
    if (criticalPerformanceActive) {
      return lowGraphicsMode ? 68 : 80;
    }
    if (adaptivePerformanceActive) {
      return highGraphicsMode ? 148 : 120;
    }
    return highGraphicsMode ? 230 : 180;
  }

  int get maxActiveEnemyProjectiles {
    if (criticalPerformanceActive) {
      return lowGraphicsMode ? 34 : 42;
    }
    if (adaptivePerformanceActive) {
      return highGraphicsMode ? 76 : 64;
    }
    return highGraphicsMode ? 124 : 96;
  }

  double get enemySpeedMultiplier => enemyFrenzyActive ? 1.16 : 1.0;
  int get enemyHealthBonus => enemyFrenzyActive ? 1 : 0;
  double get sampleMagnetRadius =>
      110 + selectedCharacterFrame.sampleMagnetBonus;
  double get sampleMagnetStrength => 180;
  double get _difficultySpawnIntervalMultiplier => switch (currentDifficulty) {
        GameDifficulty.easy => 1.18,
        GameDifficulty.normal => 1.0,
        GameDifficulty.hard => 0.88,
      };
  double get _difficultyEnemyHealthMultiplier => switch (currentDifficulty) {
        GameDifficulty.easy => 0.82,
        GameDifficulty.normal => 1.0,
        GameDifficulty.hard => 1.18,
      };
  double get _difficultyEnemySpeedMultiplier => switch (currentDifficulty) {
        GameDifficulty.easy => 0.92,
        GameDifficulty.normal => 1.0,
        GameDifficulty.hard => 1.08,
      };
  double get _difficultyBossHealthMultiplier => switch (currentDifficulty) {
        GameDifficulty.easy => 0.88,
        GameDifficulty.normal => 1.0,
        GameDifficulty.hard => 1.18,
      };
  double get _earlyWaveSpawnIntervalMultiplier => switch (currentRound) {
        <= 1 => 1.32,
        <= 2 => 1.20,
        <= 3 => 1.10,
        _ => 1.0,
      };
  double get _earlyWaveEnemyHealthMultiplier => switch (currentRound) {
        <= 1 => 0.72,
        <= 2 => 0.82,
        <= 3 => 0.90,
        _ => 1.0,
      };
  double get _earlyWaveEnemySpeedMultiplier => switch (currentRound) {
        <= 1 => 0.90,
        <= 2 => 0.94,
        <= 3 => 0.97,
        _ => 1.0,
      };
  double get _earlyBossHealthMultiplier => currentRound <= 3 ? 0.88 : 1.0;
  int get totalThreatsThisRound =>
      enemiesTargetThisRound + (roundBossRequired ? 1 : 0);
  int get roundProgressCount =>
      enemiesDefeatedThisRound.clamp(0, totalThreatsThisRound).toInt();
  bool get stalkerUnlocked => masteryMode || defeatedBossCount >= 1;
  bool get splitterUnlocked => masteryMode || defeatedBossCount >= 2;
  bool get bruteUnlocked => masteryMode || defeatedBossCount >= 3;
  bool get runnerDashUnlocked => masteryMode;
  bool get stalkerWeaveUnlocked => stalkerUnlocked;
  bool get splitterBurstUnlocked => splitterUnlocked;
  double get bossHealthFraction {
    if (bossRegistry.isEmpty) {
      return 1.0;
    }
    final currentHealth =
        bossRegistry.fold<int>(0, (sum, boss) => sum + boss.health);
    final maxHealth =
        bossRegistry.fold<int>(0, (sum, boss) => sum + boss.maxHealth);
    if (maxHealth <= 0) {
      return 1.0;
    }
    return (currentHealth / maxHealth).clamp(0.0, 1.0);
  }

  double get levelProgress {
    if (roundBossRequired) {
      if (roundPhase == RoundFlowPhase.bossPrelude) {
        final total = currentBossPreludeDuration;
        return total <= 0
            ? 0
            : 1 - (bossPreludeRemaining / total).clamp(0.0, 1.0);
      }
      if (bossRegistry.isNotEmpty) {
        return bossHealthFraction;
      }
      return 1;
    }
    if (roundDuration <= 0) {
      return 0;
    }
    return 1 - (roundTimeRemaining / roundDuration).clamp(0.0, 1.0);
  }

  String get scoreLabel =>
      (isDeveloperMode || isTutorialMode) ? 'Score (Unranked)' : 'Score';
  LessonContent get currentCourseLesson {
    if (lessonSequence.isEmpty) {
      return unavailableLessonContent;
    }
    return lessonSequence[lessonCursor.clamp(0, lessonSequence.length - 1)];
  }

  List<WeaponType> get unlockedWeapons => weaponStates.values
      .where((state) => state.unlocked)
      .map((state) => state.type)
      .toList();
  List<MiniWeaponType> get equippedMiniWeapons => miniWeaponStates.values
      .where((state) => state.equipped && state.unlocked)
      .map((state) => state.type)
      .toList();
  WeaponState get activeWeaponState => weaponStates[activeWeapon]!;
  Set<MiniWeaponType> get branchedMiniWeapons => miniWeaponStates.entries
      .where((entry) => entry.value.branchId != null)
      .map((entry) => entry.key)
      .toSet();
  bool get activeWeaponBranched => activeWeaponState.branchId != null;
  bool get activeWeaponNeedsBranch =>
      activeWeaponState.specialLevel >= miniWeaponBranchUnlockLevel &&
      !activeWeaponBranched;
  String? get activeWeaponBranchTitle =>
      primaryBranchTitle(activeWeapon, activeWeaponState.branchId);
  int get supportWeaponSlotsUsed =>
      miniWeaponStates.values.where((state) => state.level > 0).length;
  int get passiveSlotsUsed =>
      passiveLevels.values.where((level) => level > 0).length;
  int get totalWeaponSlotsUsed => 1 + supportWeaponSlotsUsed;
  int get combatVacuumLevel => 0;
  bool get unlimitedCombatLevels => false;
  int get currentCombatLevelCap => roundBossRequired ? 2 : 1;
  String get combatLevelCapLabel =>
      unlimitedCombatLevels ? '8' : '$currentCombatLevelCap';
  double get currentBossPreludeDuration =>
      currentRound <= 6 && !masteryMode ? 18 : 16;
  DesignInterviewQuestion get currentDesignInterviewQuestion =>
      designInterviewQuestions[
          designInterviewIndex.clamp(0, designInterviewQuestions.length - 1)];
  bool get hasNextDesignInterviewQuestion =>
      designInterviewIndex < designInterviewQuestions.length - 1;
  bool get hasPreviousDesignInterviewQuestion => designInterviewIndex > 0;
  bool get designInterviewComplete =>
      designInterviewAnswers.length >= designInterviewQuestions.length;
  String? get selectedDesignInterviewChoiceId =>
      designInterviewAnswers[currentDesignInterviewQuestion.id];
  DesignInterviewChoice? get selectedDesignInterviewChoice {
    final selectedId = selectedDesignInterviewChoiceId;
    if (selectedId == null) {
      return null;
    }
    for (final choice in currentDesignInterviewQuestion.choices) {
      if (choice.id == selectedId) {
        return choice;
      }
    }
    return null;
  }

  BossComponent? get activeBossComponent {
    for (final boss in bossRegistry) {
      return boss;
    }
    return null;
  }

  int get currentScore => calculateRunScore(
        RunScoreInputs(
          kills: kills,
          bossesDefeated: defeatedBossCount,
          roundsCleared: roundsCleared,
          quizPerfectRounds: quizPerfectRounds,
          quizSolidRounds: quizSolidRounds,
          quizWeakRounds: quizWeakRounds,
          survivalSeconds: survivalTime,
          masteryMode: masteryMode,
        ),
      );

  String get checkpointSummary {
    final snapshot = checkpointSnapshot;
    if (snapshot == null) {
      return 'No boss gate saved yet.';
    }
    final difficulty =
        enumByNameOrNull(GameDifficulty.values, snapshot.difficultyName) ??
            GameDifficulty.normal;
    if (snapshot.masteryMode) {
      return 'Saved mastery boss gate: Round ${snapshot.round} (${difficulty.title}).';
    }
    if (lessonSequence.isEmpty) {
      return 'Saved boss gate: Round ${snapshot.round} (${difficulty.title}). Lesson content is unavailable.';
    }
    final lesson = lessonSequence[
        snapshot.lessonCursor.clamp(0, lessonSequence.length - 1)];
    return 'Saved boss gate: Round ${snapshot.round}, Unit ${lesson.unitNumber} - ${lesson.unitTitle} (${difficulty.title}).';
  }

  String get modeLabel {
    if (isDeveloperMode) {
      return 'Developer';
    }
    if (isTutorialMode) {
      return 'Tutorial';
    }
    return masteryMode ? 'Mastery' : 'Course';
  }

  String get roundTypeLabel {
    if (roundBossRequired) {
      return roundPhase == RoundFlowPhase.bossFight
          ? 'Boss Fight'
          : 'Boss Gate';
    }
    return 'Timed Wave';
  }

  int get currentSampleThreshold =>
      14 + (6 * math.pow(1.85, combatLevelsThisRound)).round();
  bool get samplesCappedThisRound =>
      combatLevelsThisRound >= currentCombatLevelCap;

  double get sampleProgressFraction => currentSampleThreshold <= 0
      ? 0
      : (sampleCount / currentSampleThreshold).clamp(0.0, 1.0);

  String get timerLabel {
    switch (roundPhase) {
      case RoundFlowPhase.grace:
        return 'Grace ${roundGraceRemaining.toStringAsFixed(1)}s';
      case RoundFlowPhase.normalWave:
        return 'Wave ${roundTimeRemaining.toStringAsFixed(1)}s';
      case RoundFlowPhase.bossPrelude:
        return 'Prelude ${bossPreludeRemaining.toStringAsFixed(1)}s';
      case RoundFlowPhase.bossFight:
        return 'Boss fight';
      case RoundFlowPhase.cleanup:
        return 'Cleanup ${cleanupRemaining.toStringAsFixed(1)}s';
      case RoundFlowPhase.idle:
      case RoundFlowPhase.starterDraft:
        return 'Paused';
    }
  }

  bool isWeaponShopRound(int roundNumber) => roundNumber % 3 == 0;

  int miniWeaponLevel(MiniWeaponType type) => miniWeaponStates[type]!.level;
  int passiveLevel(PassiveType type) => passiveLevels[type] ?? 0;
  bool isMiniWeaponEvolved(MiniWeaponType type) =>
      evolvedMiniWeapons.contains(type);

  String passiveSummary(PassiveType type) {
    final level = passiveLevel(type);
    return 'Lv.$level - ${type.description}';
  }

  bool miniWeaponNeedsBranch(MiniWeaponType type) {
    final state = miniWeaponStates[type]!;
    return state.level >= miniWeaponBranchUnlockLevel && state.branchId == null;
  }

  String miniWeaponSummary(MiniWeaponType type) {
    final level = miniWeaponLevel(type);
    final state = miniWeaponStates[type]!;
    final branchTitle = supportBranchTitle(type, state.branchId);
    final branchTag = branchTitle == null ? '' : ' Branch: $branchTitle.';
    final branchReadyTag =
        state.level >= miniWeaponBranchUnlockLevel && state.branchId == null
            ? ' Branch ready.'
            : '';
    final evolvedTag = isMiniWeaponEvolved(type) ? ' Evolved form active.' : '';
    switch (type) {
      case MiniWeaponType.sentryPod:
        return 'Lv.$level defensive turret that quickly covers nearby threats.$branchTag$branchReadyTag$evolvedTag';
      case MiniWeaponType.burstBeacon:
        return 'Retired prototype weapon.';
      case MiniWeaponType.lineDrive:
        return 'Lv.$level forward beam that carves a lane and pushes enemies back.$branchTag$branchReadyTag$evolvedTag';
      case MiniWeaponType.snapPrism:
        return 'Lv.$level forgiving fan burst that rewards movement changes.$branchTag$branchReadyTag$evolvedTag';
      case MiniWeaponType.rhythmRing:
        return 'Lv.$level panic ring that clears space around you.$branchTag$branchReadyTag$evolvedTag';
      case MiniWeaponType.crossCadence:
        return 'Lv.$level steady crossfire that covers fixed lanes.$branchTag$branchReadyTag$evolvedTag';
    }
  }

  MiniWeaponType? get nextEvolvableMiniWeapon {
    final eligible = miniWeaponStates.entries
        .where((entry) {
          final matchingPassive = evolutionPassiveForMiniWeapon(entry.key);
          return entry.value.level >= miniWeaponEvolutionLevel &&
              !evolvedMiniWeapons.contains(entry.key) &&
              matchingPassive != null &&
              (passiveLevels[matchingPassive] ?? 0) > 0;
        })
        .map((entry) => entry.key)
        .toList();
    return eligible.isEmpty ? null : eligible[rng.nextInt(eligible.length)];
  }

  void _retireRemovedMiniWeapons() {
    final retired = miniWeaponStates[MiniWeaponType.burstBeacon];
    if (retired != null) {
      retired.level = 0;
      retired.equipped = false;
      retired.branchId = null;
    }
    evolvedMiniWeapons.remove(MiniWeaponType.burstBeacon);
  }

  String weaponSpecialSummary(WeaponType weapon) {
    final state = weaponStates[weapon]!;
    final level = state.specialLevel;
    final branchTitle = primaryBranchTitle(weapon, state.branchId);
    final branchTag = branchTitle == null ? '' : ' Branch: $branchTitle.';
    final branchReadyTag =
        level >= miniWeaponBranchUnlockLevel && state.branchId == null
            ? ' Branch ready.'
            : '';
    switch (weapon) {
      case WeaponType.standard:
        return 'Lv.$level steady front-lane shots with a clean fallback profile.$branchTag$branchReadyTag';
      case WeaponType.scatter:
        return 'Lv.$level cone volleys that can specialize into wall coverage or rear spores.$branchTag$branchReadyTag';
      case WeaponType.homing:
        return 'Lv.$level seeker rounds that can split wider or tighten into hunter missiles.$branchTag$branchReadyTag';
      case WeaponType.heavy:
        return 'Lv.$level crushing slugs that can specialize into impact or splinter pressure.$branchTag$branchReadyTag';
      case WeaponType.twin:
        return 'Lv.$level paired lanes that can tighten into rails or widen into mirror sweeps.$branchTag$branchReadyTag';
      case WeaponType.burst:
        return 'Lv.$level burst volleys that can compress into needles or bloom into petals.$branchTag$branchReadyTag';
      case WeaponType.pierce:
        return 'Lv.$level rail shots that can become a lance or fork into a second line.$branchTag$branchReadyTag';
      case WeaponType.sniper:
        return 'Lv.$level precision shots that can harden into pinpoint hits or echo a second round.$branchTag$branchReadyTag';
      case WeaponType.nova:
        return 'Lv.$level radial bursts that can densify forward or spin a second orbiting ring.$branchTag$branchReadyTag';
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _prefs ??= await SharedPreferences.getInstance();
    await _loadWeaponArt();
    await _loadSoundEffects();
    final runningWidgetTest = WidgetsBinding.instance.runtimeType
        .toString()
        .contains('TestWidgetsFlutterBinding');
    await LessonContentRepository(preferences: _prefs!).load(
      refreshFromDatabase: !runningWidgetTest,
      loadAssetCache: !runningWidgetTest,
    );
    _restorePersistedState(_prefs!);
  }

  ui.Image? miniWeaponArt(MiniWeaponType type) =>
      _weaponArtImages[_miniWeaponArtPaths[type]];

  ui.Image? effectArt(String key) => _weaponArtImages[_effectArtPaths[key]];

  void _primeMiniWeapon(MiniWeaponType type) {
    _miniWeaponTimers[type] = 999;
  }

  Future<void> _loadWeaponArt() async {
    final paths = <String>{
      ..._miniWeaponArtPaths.values,
      ..._effectArtPaths.values,
    };
    for (final path in paths) {
      try {
        _weaponArtImages[path] = await _readUiImage(path);
      } catch (_) {
        // Fall back to vector rendering if an asset is missing.
      }
    }
  }

  Future<void> _loadSoundEffects() async {
    try {
      FlameAudio.updatePrefix(_sfxAssetPrefix);
      await FlameAudio.audioCache.loadAll(_sfxPaths.values.toList());
      await _musicCache.loadAll(_musicPaths.values.toList());
    } catch (_) {
      _audioEnabled = false;
    }
  }

  String? get _desiredMusicAsset {
    if (onTitleScreen || gameOver) {
      return _musicPaths['title'];
    }
    if (runStarted) {
      return _musicPaths['arena'];
    }
    return null;
  }

  void _primeAudioSession() {
    if (!_audioEnabled) {
      return;
    }
    _audioPrimed = true;
    _refreshMusicForState();
  }

  void _refreshMusicForState() {
    if (!_audioEnabled || !_audioPrimed) {
      return;
    }
    _queuedMusicAsset = _desiredMusicAsset;
    _musicSyncQueued = true;
    if (_musicSyncInProgress) {
      return;
    }
    unawaited(_drainMusicSyncQueue());
  }

  Future<void> _drainMusicSyncQueue() async {
    _musicSyncInProgress = true;
    try {
      while (_musicSyncQueued) {
        final desiredAsset = _queuedMusicAsset;
        _musicSyncQueued = false;
        await _syncMusicForAsset(desiredAsset);
      }
    } finally {
      _musicSyncInProgress = false;
      if (_musicSyncQueued && _audioEnabled && _audioPrimed) {
        _refreshMusicForState();
      }
    }
  }

  Future<void> _syncMusicForAsset(String? desiredAsset) async {
    if (!_audioEnabled || !_audioPrimed) {
      return;
    }
    if (desiredAsset == null) {
      await _stopMusic();
      return;
    }
    if (_musicPlayer != null && _currentMusicAsset == desiredAsset) {
      return;
    }
    await _stopMusic();
    try {
      final player = AudioPlayer()..audioCache = _musicCache;
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(
        AssetSource(desiredAsset),
        volume: desiredAsset == _musicPaths['title'] ? 0.24 : 0.18,
        mode: PlayerMode.mediaPlayer,
      );
      _musicPlayer = player;
      _currentMusicAsset = desiredAsset;
    } catch (_) {
      _audioEnabled = false;
      await _stopMusic();
    }
  }

  Future<void> _stopMusic() async {
    final player = _musicPlayer;
    _musicPlayer = null;
    _currentMusicAsset = null;
    if (player == null) {
      return;
    }
    try {
      await player.stop();
    } catch (_) {
      // Ignore stop errors when the web backend has already torn down.
    }
    try {
      await player.dispose();
    } catch (_) {
      // Ignore dispose errors when the player is already gone.
    }
  }

  Future<ui.Image> _readUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(
      data.buffer.asUint8List(),
      (image) => completer.complete(image),
    );
    return completer.future;
  }

  void drawSpriteRect(
    Canvas canvas,
    ui.Image image,
    Rect destination, {
    double alpha = 1,
  }) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      ),
      destination,
      Paint()
        ..filterQuality = FilterQuality.medium
        ..colorFilter = ColorFilter.mode(
          Colors.white.withValues(alpha: alpha),
          BlendMode.modulate,
        ),
    );
  }

  void playSfx(
    String key, {
    double volume = 1.0,
    Duration minGap = Duration.zero,
  }) {
    if (!_audioEnabled) {
      return;
    }
    final asset = _sfxPaths[key];
    if (asset == null) {
      return;
    }
    _primeAudioSession();
    final now = DateTime.now();
    final cooldownUntil = _sfxCooldowns[key];
    if (cooldownUntil != null && now.isBefore(cooldownUntil)) {
      return;
    }
    if (minGap > Duration.zero) {
      _sfxCooldowns[key] = now.add(minGap);
    }
    unawaited(_playSfxAsset(asset, volume: volume));
  }

  Future<void> _playSfxAsset(String asset, {required double volume}) async {
    try {
      await FlameAudio.play(asset, volume: volume);
    } catch (_) {
      _audioEnabled = false;
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!_initialized && size.x > 0 && size.y > 0) {
      _initialized = true;
      _resetRunState(showTitle: true, checkpoint: checkpointSnapshot);
    }
  }

  @override
  void render(Canvas canvas) {
    final baseColor = biologyResourcePackEnabled
        ? (enemyFrenzyActive
            ? const Color(0xFF230A13)
            : const Color(0xFF07120F))
        : masteryMode
            ? const Color(0xFF061012)
            : enemyFrenzyActive
                ? const Color(0xFF200B13)
                : const Color(0xFF07131A);
    canvas.drawColor(baseColor, BlendMode.srcOver);
    final arenaHeight = math.max(0.0, size.y - playAreaTop);
    final arenaRect = Rect.fromLTWH(0, playAreaTop, size.x, arenaHeight);
    if (arenaRect.height > 0 && arenaRect.width > 0) {
      canvas.drawRect(
        arenaRect,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, playAreaTop),
            Offset(size.x, size.y),
            [
              const Color(0xFF0C2E2A).withValues(alpha: 0.28),
              const Color(0xFF061016).withValues(alpha: 0.08),
              const Color(0xFF12361E).withValues(alpha: 0.18),
            ],
            [0.0, 0.58, 1.0],
          ),
      );
      final pressureGlow = Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.x * 0.52, playAreaTop + arenaHeight * 0.46),
          math.max(size.x, arenaHeight) * 0.58,
          [
            (enemyFrenzyActive
                    ? const Color(0xFFEF476F)
                    : const Color(0xFF2EC4B6))
                .withValues(alpha: enemyFrenzyActive ? 0.18 : 0.12),
            Colors.transparent,
          ],
        );
      canvas.drawRect(arenaRect, pressureGlow);

      final laneCount = criticalPerformanceActive
          ? 1
          : adaptivePerformanceActive
              ? 2
              : 3;
      for (var lane = 0; lane < laneCount; lane++) {
        final y = playAreaTop + arenaHeight * (0.22 + lane * 0.27);
        final wave = 38.0 + lane * 9;
        final path = Path()
          ..moveTo(-90, y)
          ..cubicTo(
            size.x * 0.25,
            y - wave,
            size.x * 0.58,
            y + wave,
            size.x + 90,
            y - wave * 0.35,
          );
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFF9AF4DE).withValues(alpha: 0.045)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 26
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFE6FFF7).withValues(alpha: 0.08)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..strokeCap = StrokeCap.round,
        );
      }
      final ambientCellCount = lowGraphicsMode
          ? 4
          : criticalPerformanceActive
              ? 6
              : adaptivePerformanceActive
                  ? 12
                  : highGraphicsMode
                      ? 34
                      : 28;
      for (var i = 0; i < ambientCellCount; i++) {
        final seed = i * 37.0;
        final drift = arenaVisualTime * (10 + (i % 5) * 2.7);
        final x = (seed * 13 + drift) % (size.x + 80) - 40;
        final baseY =
            playAreaTop + ((seed * 7) % math.max(1.0, arenaHeight - 20)) + 10;
        final y = baseY + math.sin(arenaVisualTime * 0.8 + i) * 9;
        final radius = 3.4 + (i % 4) * 1.7;
        final cellColor =
            i % 6 == 0 ? const Color(0xFFFFD166) : const Color(0xFFB8F7E7);
        canvas.drawCircle(
          Offset(x, y),
          radius + 4,
          Paint()..color = cellColor.withValues(alpha: 0.035),
        );
        canvas.drawCircle(
          Offset(x, y),
          radius,
          Paint()
            ..color = cellColor.withValues(alpha: i % 6 == 0 ? 0.13 : 0.08),
        );
      }
      if (biologyResourcePackEnabled && !criticalPerformanceActive) {
        final slideRing = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFB8F7E7).withValues(alpha: 0.07);
        final slideRingCount = adaptivePerformanceActive
            ? 4
            : highGraphicsMode
                ? 11
                : 9;
        for (var i = 0; i < slideRingCount; i++) {
          final seed = i * 53.0;
          final x =
              (seed * 9 + arenaVisualTime * (5 + i)) % (size.x + 120) - 60;
          final y = playAreaTop +
              ((seed * 11) % math.max(1.0, arenaHeight - 36)) +
              18 +
              math.sin(arenaVisualTime * 0.45 + i) * 11;
          final radius = 18.0 + (i % 4) * 9;
          canvas.drawCircle(Offset(x, y), radius, slideRing);
          canvas.drawCircle(
            Offset(x - radius * 0.18, y + radius * 0.08),
            radius * 0.24,
            Paint()..color = const Color(0xFFFFD166).withValues(alpha: 0.055),
          );
        }
        final virionPaint = Paint()
          ..color = const Color(0xFFEF476F).withValues(alpha: 0.10)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
        final virionCount = adaptivePerformanceActive
            ? 5
            : highGraphicsMode
                ? 17
                : 14;
        for (var i = 0; i < virionCount; i++) {
          final seed = i * 41.0;
          final drift = arenaVisualTime * (8 + (i % 4) * 1.6);
          final x = (seed * 17 - drift) % (size.x + 100) - 50;
          final y = playAreaTop +
              ((seed * 5) % math.max(1.0, arenaHeight - 20)) +
              10 +
              math.cos(arenaVisualTime * 0.7 + i) * 8;
          final center = Offset(x, y);
          final radius = 5.0 + (i % 3) * 2.0;
          canvas.drawCircle(center, radius, virionPaint);
          for (var spike = 0; spike < 6; spike++) {
            final angle = spike * math.pi / 3 + i * 0.2;
            canvas.drawLine(
              center.translate(
                  math.cos(angle) * radius, math.sin(angle) * radius),
              center.translate(math.cos(angle) * (radius + 4),
                  math.sin(angle) * (radius + 4)),
              virionPaint,
            );
          }
        }
      }
      canvas.drawRect(
        arenaRect,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset(size.x * 0.50, playAreaTop + arenaHeight * 0.48),
            math.max(size.x, arenaHeight) * 0.78,
            [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.28),
            ],
          ),
      );
    }
    if (showArenaGrid) {
      final gridPaint = Paint()
        ..color = const Color(0xFF1B4332).withValues(alpha: 0.18);
      const gridSize = 34.0;
      for (double x = 0; x <= size.x; x += gridSize) {
        canvas.drawRect(Rect.fromLTWH(x, 0, 1, size.y), gridPaint);
      }
      for (double y = playAreaTop; y <= size.y; y += gridSize) {
        canvas.drawRect(Rect.fromLTWH(0, y, size.x, 1), gridPaint);
      }
    }
    super.render(canvas);
  }

  @override
  void update(double dt) {
    final fpsChanged = _recordFrameTiming(dt);
    final frameDt = _applyFramePacing(dt);
    arenaVisualTime += frameDt;
    if (enemyFrenzyTimer > 0) {
      enemyFrenzyTimer = math.max(0.0, enemyFrenzyTimer - frameDt);
    }
    if (bannerTimer > 0) {
      bannerTimer = math.max(0.0, bannerTimer - frameDt);
      if (bannerTimer <= 0) {
        bannerText = null;
      }
    }
    if (magnetTimer > 0) {
      magnetTimer = math.max(0.0, magnetTimer - frameDt);
    }

    if (isGameplayActive) {
      survivalTime += frameDt;
      _uiRefreshTimer += frameDt;
      _updateRoundFlow(frameDt);
      _rebuildEnemyCollisionGrid();
      _updateMiniWeaponSystems(frameDt);
      _handleManualCollisions(rebuildGrid: false);

      if (_uiRefreshTimer >= 0.1 || fpsChanged) {
        _uiRefreshTimer = 0;
        notifyUi();
      }
    } else if (fpsChanged && !onTitleScreen) {
      notifyUi();
    }

    super.update(frameDt);
  }

  double _applyFramePacing(double dt) {
    if (dt <= 0) {
      return 0;
    }
    final safetyClamp = lowGraphicsMode ? 1 / 24 : 1 / 20;
    if (!vSyncPacingEnabled) {
      return dt.clamp(0.0, safetyClamp).toDouble();
    }
    return dt.clamp(0.0, 1 / 30).toDouble();
  }

  bool _recordFrameTiming(double dt) {
    if (dt <= 0) {
      return false;
    }
    _fpsSampleTime += dt;
    _fpsSampleFrames += 1;
    if (_fpsSampleTime < 0.5) {
      return false;
    }
    currentFps =
        (_fpsSampleFrames / _fpsSampleTime).clamp(0.0, 999.0).toDouble();
    _fpsSampleTime = 0;
    _fpsSampleFrames = 0;
    return true;
  }

  void _updateRoundFlow(double dt) {
    switch (roundPhase) {
      case RoundFlowPhase.grace:
        roundGraceRemaining = math.max(0.0, roundGraceRemaining - dt);
        if (roundGraceRemaining <= 0) {
          roundPhase = roundBossRequired
              ? RoundFlowPhase.bossPrelude
              : RoundFlowPhase.normalWave;
          _refreshMusicForState();
        }
        break;
      case RoundFlowPhase.normalWave:
        roundTimeRemaining = math.max(0.0, roundTimeRemaining - dt);
        _directorSpawnNormalWave(dt);
        if (roundTimeRemaining <= 0) {
          _beginCleanup();
        }
        break;
      case RoundFlowPhase.bossPrelude:
        bossPreludeRemaining = math.max(0.0, bossPreludeRemaining - dt);
        _directorSpawnBossPrelude(dt);
        if (bossPreludeRemaining <= 0) {
          _startBossFightFromPrelude();
        }
        break;
      case RoundFlowPhase.bossFight:
        if (bossRegistry.isEmpty && !roundComplete) {
          _beginCleanup(fromBoss: true);
        }
        break;
      case RoundFlowPhase.cleanup:
        cleanupRemaining = math.max(0.0, cleanupRemaining - dt);
        sampleCleanupFlicker += dt * 10;
        if (cleanupRemaining <= 0) {
          _openRoundSummary();
        }
        break;
      case RoundFlowPhase.idle:
      case RoundFlowPhase.starterDraft:
        break;
    }
  }

  void _directorSpawnNormalWave(double dt) {
    _enemySpawnTimer += dt;
    final elapsedTime = math.max(0.0, roundDuration - roundTimeRemaining);
    if (elapsedTime >= 10) {
      softenNextRound = false;
      nextRoundPressureLevel = 0;
    }
    if (elapsedTime >= 27) {
      _clusterSpawnTimer = 0;
      return;
    }
    final openingSoftener = softenNextRound && elapsedTime < 10 ? 0.12 : 0.0;
    final pressurePenalty =
        math.max(0, nextRoundPressureLevel - (softenNextRound ? 1 : 0));
    final openingPressure = elapsedTime < 10 ? pressurePenalty * 0.06 : 0.0;
    final intervalBase = switch (elapsedTime) {
      < 10 => 0.92 - 0.24 * (elapsedTime / 10).clamp(0.0, 1.0),
      < 22 => 0.60 - 0.08 * ((elapsedTime - 10) / 12).clamp(0.0, 1.0),
      _ => 0.66 + 0.22 * ((elapsedTime - 22) / 5).clamp(0.0, 1.0),
    };
    final masteryPressure = masteryMode ? 0.90 : 1.0;
    _enemySpawnInterval = math.max(
      0.09,
      (intervalBase +
              openingSoftener -
              openingPressure -
              math.max(0, currentRound - 5) * 0.008) *
          masteryPressure *
          _difficultySpawnIntervalMultiplier *
          _earlyWaveSpawnIntervalMultiplier,
    );
    while (_enemySpawnTimer >= _enemySpawnInterval) {
      _enemySpawnTimer -= _enemySpawnInterval;
      enemiesSpawnedThisRound += spawnEnemy();
    }
    if (!usedOpeningAnchor &&
        nextRoundPressureLevel > 0 &&
        elapsedTime >= 6 &&
        elapsedTime < 10 &&
        !softenNextRound) {
      usedOpeningAnchor = true;
      enemiesSpawnedThisRound += _spawnTacticalPack(3);
    }
    if (elapsedTime >= 10 && elapsedTime < 22) {
      _clusterSpawnTimer += dt;
      final clusterInterval = math.max(
        2.8,
        (currentRound <= 2
                ? 5.0
                : currentRound <= 4
                    ? 4.3
                    : 3.6) +
            (softenNextRound ? 0.6 : 0.0) -
            pressurePenalty * 0.35,
      );
      final tunedClusterInterval = clusterInterval *
          _difficultySpawnIntervalMultiplier *
          (currentRound <= 3 ? 1.12 : 1.0);
      while (_clusterSpawnTimer >= tunedClusterInterval) {
        _clusterSpawnTimer -= tunedClusterInterval;
        enemiesSpawnedThisRound += _spawnClusterPhasePack();
      }
    } else {
      _clusterSpawnTimer = 0;
    }
  }

  void _directorSpawnBossPrelude(double dt) {
    _enemySpawnTimer += dt;
    final preludeTotal = currentBossPreludeDuration;
    final progress = preludeTotal <= 0
        ? 1.0
        : 1 - (bossPreludeRemaining / preludeTotal).clamp(0.0, 1.0);
    _enemySpawnInterval = (progress < 0.45 ? 0.56 : 0.42) *
        _difficultySpawnIntervalMultiplier *
        _earlyWaveSpawnIntervalMultiplier;
    while (_enemySpawnTimer >= _enemySpawnInterval) {
      _enemySpawnTimer -= _enemySpawnInterval;
      enemiesSpawnedThisRound += spawnEnemy();
    }
  }

  void _startBossFightFromPrelude() {
    _thinFieldForBossEntry();
    roundBossSpawned = true;
    _spawnBoss();
    roundPhase = RoundFlowPhase.bossFight;
    softenNextRound = false;
    nextRoundPressureLevel = 0;
    _refreshMusicForState();
    notifyUi();
  }

  void _thinFieldForBossEntry() {
    if (enemyRegistry.length <= 4) {
      return;
    }
    final keep = enemyRegistry.take(4).toSet();
    for (final enemy in enemyRegistry.toList()) {
      if (!keep.contains(enemy)) {
        enemy.removeFromParent();
      }
    }
  }

  void _beginCleanup({bool fromBoss = false}) {
    if (roundPhase == RoundFlowPhase.cleanup) {
      return;
    }
    if (fromBoss) {
      _clearBossSpawnedEnemies();
    }
    roundComplete = true;
    roundsCleared += 1;
    cleanupCollectOnly = true;
    roundPhase = RoundFlowPhase.cleanup;
    cleanupRemaining = 2.5;
    sampleCleanupFlicker = 0;
    chestPendingFromBoss = fromBoss;
    softenNextRound = false;
    nextRoundPressureLevel = 0;
    showBanner(
        fromBoss
            ? 'Boss clear - sweep the field'
            : 'Round clear - collect quickly',
        duration: 1.8);
    notifyUi();
  }

  void _clearBossSpawnedEnemies() {
    for (final enemy in enemyRegistry.toList()) {
      if (enemy.spawnedByBoss) {
        enemy.removeFromParent();
      }
    }
  }

  void _restorePersistedState(SharedPreferences prefs) {
    final meta = PersistedMetaState.fromEncoded(prefs.getString(_saveKey));
    tutorialSeen = meta.tutorialSeen;
    courseCompletedMeta = meta.courseCompleted;
    bestCourseScore = meta.bestCourseScore;
    bestMasteryScore = meta.bestMasteryScore;
    researchPoints = meta.researchPoints;
    biologyResourcePackEnabled = meta.biologyResourcePackEnabled;
    graphicsQualityPreset = enumByNameOrNull(
            GraphicsQualityPreset.values, meta.graphicsQualityPresetName) ??
        GraphicsQualityPreset.medium;
    vSyncPacingEnabled = meta.vSyncPacingEnabled;
    autoPerformanceScalingEnabled = meta.autoPerformanceScalingEnabled;
    reducedEffectsEnabled = meta.reducedEffectsEnabled;
    fpsMeterVisible = meta.fpsMeterVisible;
    unlockedCharacterFrames = {
      CharacterFrame.bioSquare,
      for (final name in meta.unlockedCharacterNames)
        if (enumByNameOrNull(CharacterFrame.values, name) case final frame?)
          frame,
    };
    selectedCharacterFrame =
        enumByNameOrNull(CharacterFrame.values, meta.selectedCharacterName) ??
            CharacterFrame.bioSquare;
    if (!isCharacterFrameUnlocked(selectedCharacterFrame)) {
      selectedCharacterFrame = CharacterFrame.bioSquare;
    }
    checkpointSnapshot = meta.checkpoint;
    if (_initialized && onTitleScreen) {
      notifyUi();
    }
  }

  void _persistState() {
    final prefs = _prefs;
    if (prefs == null || isDeveloperMode || isTutorialMode) {
      return;
    }
    final meta = PersistedMetaState(
      tutorialSeen: tutorialSeen,
      courseCompleted: courseCompletedMeta,
      bestCourseScore: bestCourseScore,
      bestMasteryScore: bestMasteryScore,
      researchPoints: researchPoints,
      selectedCharacterName: selectedCharacterFrame.name,
      unlockedCharacterNames: [
        for (final frame in unlockedCharacterFrames) frame.name,
      ],
      biologyResourcePackEnabled: biologyResourcePackEnabled,
      graphicsQualityPresetName: graphicsQualityPreset.name,
      vSyncPacingEnabled: vSyncPacingEnabled,
      autoPerformanceScalingEnabled: autoPerformanceScalingEnabled,
      reducedEffectsEnabled: reducedEffectsEnabled,
      fpsMeterVisible: fpsMeterVisible,
      checkpoint: checkpointSnapshot,
    );
    unawaited(prefs.setString(_saveKey, meta.encode()));
  }

  void _resetRunState({
    required bool showTitle,
    PersistedCheckpointSnapshot? checkpoint,
    RunMode runMode = RunMode.normal,
    GameDifficulty difficulty = GameDifficulty.normal,
  }) {
    for (final component in children.toList()) {
      component.removeFromParent();
    }
    for (final timer in _miniWeaponTimers.keys) {
      _miniWeaponTimers[timer] = 0;
    }
    enemyRegistry.clear();
    bossRegistry.clear();
    bulletRegistry.clear();
    enemyProjectileRegistry.clear();
    pickupRegistry.clear();
    sampleRegistry.clear();
    for (final key in _combatStatLevels.keys) {
      _combatStatLevels[key] = 0;
    }

    final snapshot = checkpoint;
    this.runMode = runMode;
    currentDifficulty =
        enumByNameOrNull(GameDifficulty.values, snapshot?.difficultyName) ??
            difficulty;
    if (showTitle) {
      selectedDifficulty = currentDifficulty;
    }
    credits = 0;
    kills = snapshot?.kills ?? 0;
    lives = snapshot?.lives ??
        (3 + (showTitle ? 0 : selectedCharacterFrame.bonusLives));
    currentRound = snapshot?.round ?? 1;
    totalCoinsCollected = 0;
    researchPointsEarnedThisRun = 0;
    roundsCleared = snapshot?.roundsCleared ?? 0;
    defeatedBossCount = snapshot?.bossesDefeated ?? 0;
    bossRewardsGranted = snapshot?.bossesDefeated ?? 0;
    bossRoundsSeen = snapshot?.bossRoundsSeen ?? 0;
    quizPerfectRounds = snapshot?.quizPerfectRounds ?? 0;
    quizSolidRounds = snapshot?.quizSolidRounds ?? 0;
    quizWeakRounds = snapshot?.quizWeakRounds ?? 0;
    survivalTime = snapshot?.survivalTime ?? 0;
    enemyFrenzyTimer = snapshot?.enemyFrenzyTimer ?? 0;
    bannerTimer = 0;
    bannerText = null;
    magnetTimer = 0;
    shieldCharges = snapshot?.shieldCharges ??
        (showTitle ? 0 : selectedCharacterFrame.startingShields);
    sampleCount = 0;
    bankedBossSamples = snapshot?.bankedBossSamples ?? 0;
    combatLevelsThisRound = 0;
    nextRoundPressureLevel = snapshot?.nextRoundPressureLevel ?? 0;
    pendingOpeningPressureLevel = snapshot?.nextRoundPressureLevel ?? 0;
    _enemySpawnTimer = 0;
    _clusterSpawnTimer = 0;
    _enemySpawnInterval = 0.45;
    _uiRefreshTimer = 0;
    roundDuration = 0;
    roundTimeRemaining = 0;
    roundGraceRemaining = 0;
    bossPreludeRemaining = 0;
    cleanupRemaining = 0;
    sampleCleanupFlicker = 0;
    enemiesSpawnedThisRound = 0;
    enemiesDefeatedThisRound = 0;
    enemiesTargetThisRound = 18;
    roundBossRequired = false;
    roundBossSpawned = false;
    roundComplete = false;
    currentBossType = null;
    pendingBossType = null;
    lastBossType =
        enumByNameOrNull(BossType.values, snapshot?.lastBossTypeName);
    currentSpecialOffers = [];
    currentLessonSession = null;
    currentTipTitle = null;
    currentTipBody = null;
    pausedForLevel = false;
    pausedForMenu = false;
    gameOver = false;
    victoryPending = false;
    runWon = false;
    courseScoreRecorded = false;
    masteryMode = snapshot?.masteryMode ?? false;
    developerInvulnerable = false;
    pausedForCombatLevel = false;
    roundPhase = RoundFlowPhase.idle;
    starterDraftActive = false;
    cleanupCollectOnly = false;
    softenNextRound = false;
    openingAnchorSuppressed = false;
    usedOpeningAnchor = false;
    usedFinalSpikeAnchor = false;
    chestPendingFromBoss = false;
    activeWeaponEvolved = false;
    stalkerMutationAnnounced = false;
    splitterMutationAnnounced = false;
    bruteMutationAnnounced = false;
    lessonCursor = snapshot?.lessonCursor ?? 0;
    runStarted = !showTitle;
    onTitleScreen = showTitle;
    startAfterTutorial = false;
    touchDirection = Vector2.zero();
    _keysPressed.clear();
    _shownTipIds.clear();

    activeWeapon =
        enumByNameOrNull(WeaponType.values, snapshot?.activeWeaponName) ??
            WeaponType.standard;
    lockedWeaponChoice = WeaponType.standard;

    for (final upgrade in upgrades.values) {
      upgrade.level = snapshot?.upgradeLevels[upgrade.id] ?? 0;
    }
    for (final state in weaponStates.values) {
      state.unlocked = snapshot?.weaponUnlocks[state.type.name] ??
          state.type == WeaponType.standard;
      state.specialLevel = snapshot?.weaponSpecialLevels[state.type.name] ?? 0;
      state.branchId = snapshot?.weaponBranchIds[state.type.name];
    }
    for (final state in miniWeaponStates.values) {
      state.level = snapshot?.miniWeaponLevels[state.type.name] ?? 0;
      state.equipped =
          snapshot?.equippedMiniWeapons.contains(state.type.name) ?? false;
      state.branchId = snapshot?.miniWeaponBranchIds[state.type.name];
    }
    evolvedMiniWeapons
      ..clear()
      ..addAll(
        [
          for (final name in snapshot?.evolvedMiniWeapons ?? const <String>[])
            if (enumByNameOrNull(MiniWeaponType.values, name) case final value?)
              value,
        ],
      );
    for (final passive in PassiveType.values) {
      passiveLevels[passive] = snapshot?.passiveLevels[passive.name] ?? 0;
    }
    _retireRemovedMiniWeapons();

    player = PlayerComponent(
      position: Vector2(size.x / 2 - 14, size.y / 2 - 14),
    );
    add(player!);
    _applyUpgradeLevelsToPlayer();
    refreshMiniWeaponAttachments();

    overlays.remove(LevelOverlay.id);
    overlays.remove(PauseOverlay.id);
    overlays.remove(DesignInterviewOverlay.id);
    overlays.remove(TutorialOverlay.id);
    overlays.remove(InteractiveTutorialOverlay.id);
    overlays.remove(ContextTipOverlay.id);
    overlays.remove(VictoryOverlay.id);
    overlays.remove(GameOverOverlay.id);
    overlays.remove(StarterDraftOverlay.id);
    overlays.remove(CombatLevelOverlay.id);
    if (!overlays.isActive(HudOverlay.id)) {
      overlays.add(HudOverlay.id);
    }
    if (showTitle) {
      if (!overlays.isActive(TitleOverlay.id)) {
        overlays.add(TitleOverlay.id);
      }
    } else {
      overlays.remove(TitleOverlay.id);
    }

    _prepareRound(currentRound);
    if (!showTitle) {
      if (equippedMiniWeapons.isEmpty) {
        _openStarterDraft();
      } else {
        _beginRoundFlow();
      }
    }
    _refreshMusicForState();
    notifyUi();
  }

  void _applyUpgradeLevelsToPlayer() {
    final currentPlayer = player;
    if (currentPlayer == null) {
      return;
    }
    currentPlayer.baseSpeed = 210;
    currentPlayer.dashSpeed = 540;
    currentPlayer.dashCooldown = 2.0;
    currentPlayer.dashDuration = 0.16;
    currentPlayer.fireCooldown = 0.34;
    currentPlayer.reloadMultiplier = 1.0;
    currentPlayer.bulletDamage = 1;
    currentPlayer.baseSpeed *= selectedCharacterFrame.speedMultiplier;
    currentPlayer.dashSpeed *= selectedCharacterFrame.speedMultiplier;

    for (int i = 0; i < upgrades['attackSpeed']!.level; i++) {
      currentPlayer.fireCooldown =
          math.max(0.10, currentPlayer.fireCooldown * 0.90);
    }
    for (int i = 0; i < upgrades['dashMastery']!.level; i++) {
      currentPlayer.dashCooldown =
          math.max(0.72, currentPlayer.dashCooldown * 0.90);
      currentPlayer.dashDuration += 0.015;
    }
  }

  void _prepareRound(int roundNumber) {
    enemiesSpawnedThisRound = 0;
    enemiesDefeatedThisRound = 0;
    enemiesTargetThisRound = 0;
    roundComplete = false;
    roundBossSpawned = false;
    roundBossRequired = isWeaponShopRound(roundNumber);
    _enemySpawnTimer = 0;
    _clusterSpawnTimer = 0;
    currentBossType = null;
    pendingBossType = roundBossRequired
        ? pickBossType(
            rng: rng,
            bossRoundsSeen: bossRoundsSeen + 1,
            lastBossType: lastBossType,
          )
        : null;
    sampleCount = bankedBossSamples;
    bankedBossSamples = 0;
    combatLevelsThisRound = 0;
    cleanupCollectOnly = false;
    openingAnchorSuppressed = false;
    usedOpeningAnchor = false;
    usedFinalSpikeAnchor = false;
    chestPendingFromBoss = false;
    roundGraceRemaining = 2.5;
    cleanupRemaining = 0;
    bossPreludeRemaining = roundBossRequired ? currentBossPreludeDuration : 0;
    roundDuration = 30;
    roundTimeRemaining = roundDuration;
    roundPhase = RoundFlowPhase.idle;
    if (roundBossRequired && runStarted && !onTitleScreen) {
      _saveBossGateCheckpoint();
    }
    showBanner(
        roundBossRequired
            ? 'Round $roundNumber boss gate'
            : 'Round $roundNumber start',
        duration: 2.1);
    if (runStarted && !onTitleScreen && equippedMiniWeapons.isNotEmpty) {
      _beginRoundFlow();
    }
  }

  void _beginRoundFlow() {
    roundPhase = RoundFlowPhase.grace;
    roundGraceRemaining = 2.5;
    showBanner(
      _consumeEnemyMutationBanner() ??
          (roundBossRequired ? 'Prepare for the gate' : 'Prepare for the wave'),
      duration: 2.3,
    );
    if (roundBossRequired) {
      _showBossPreludeTip();
    }
    _refreshMusicForState();
    notifyUi();
  }

  void _showBossPreludeTip() {
    final bossType = pendingBossType;
    if (bossType == null) {
      return;
    }
    final body = switch (bossType) {
      BossType.stalkerApex =>
        'The Apex Striker is quick, dodges incoming shots, and can call enhanced weavers. Keep moving across its dash lane and use wide, persistent weapons.',
      BossType.splitterQueen =>
        'The Splitter Broodmother floods the arena with brood waves. Clear space early and save room for its low-health surge.',
      BossType.chargerBrute =>
        'The Charger Brute announces straight-line charges with arrows. Watch the lane, sidestep hard, and prepare for mitosis fragments.',
    };
    showContextTipOnce(
      id: 'boss_prelude_${currentRound}_${bossType.name}',
      title: 'Boss Incoming: ${bossType.title}',
      body: body,
    );
  }

  String? _consumeEnemyMutationBanner() {
    final mutations = <String>[];
    if (stalkerUnlocked && !stalkerMutationAnnounced) {
      stalkerMutationAnnounced = true;
      mutations.add('stalkers enter the field');
    }
    if (splitterUnlocked && !splitterMutationAnnounced) {
      splitterMutationAnnounced = true;
      mutations.add('splitters burst into brood');
    }
    if (bruteUnlocked && !bruteMutationAnnounced) {
      bruteMutationAnnounced = true;
      mutations.add('tanks have mutated into brutes');
    }
    if (mutations.isEmpty) {
      return null;
    }
    if (mutations.length == 1) {
      return 'The enemies have mutated - ${mutations.first}.';
    }
    if (mutations.length == 2) {
      return 'The enemies have mutated - ${mutations.first} and ${mutations.last}.';
    }
    return 'The enemies have mutated - ${mutations[0]}, ${mutations[1]}, and ${mutations[2]}.';
  }

  void _openStarterDraft() {
    if (overlays.isActive(StarterDraftOverlay.id)) {
      return;
    }
    starterDraftActive = true;
    pausedForMenu = true;
    currentStarterMiniWeaponOffers = buildStarterMiniWeaponChoices(rng);
    overlays.add(StarterDraftOverlay.id);
    notifyUi();
  }

  void chooseStarterMiniWeapon(MiniWeaponType miniWeapon) {
    activeWeapon = WeaponType.standard;
    lockedWeaponChoice = null;
    for (final state in weaponStates.values) {
      state.unlocked = false;
      state.specialLevel = 0;
      state.branchId = null;
    }
    for (final state in miniWeaponStates.values) {
      state.level = state.type == miniWeapon ? 1 : 0;
      state.equipped = state.type == miniWeapon;
      state.branchId = null;
    }
    evolvedMiniWeapons.clear();
    _primeMiniWeapon(miniWeapon);
    refreshMiniWeaponAttachments();
    playSfx('draft', volume: 0.75, minGap: const Duration(milliseconds: 120));
    overlays.remove(StarterDraftOverlay.id);
    starterDraftActive = false;
    pausedForMenu = false;
    showBanner('${miniWeapon.title} selected', duration: 1.6);
    _beginRoundFlow();
    notifyUi();
  }

  void _saveBossGateCheckpoint() {
    if (isDeveloperMode || isTutorialMode) {
      return;
    }
    final snapshot = PersistedCheckpointSnapshot(
      round: currentRound,
      lessonCursor: lessonCursor,
      masteryMode: masteryMode,
      difficultyName: currentDifficulty.name,
      credits: 0,
      kills: kills,
      lives: lives,
      totalCoinsCollected: 0,
      survivalTime: survivalTime,
      roundsCleared: roundsCleared,
      bossesDefeated: defeatedBossCount,
      quizPerfectRounds: quizPerfectRounds,
      quizSolidRounds: quizSolidRounds,
      quizWeakRounds: quizWeakRounds,
      enemyFrenzyTimer: enemyFrenzyTimer,
      activeWeaponName: activeWeapon.name,
      lockedWeaponName: lockedWeaponChoice?.name,
      upgradeLevels: {
        for (final entry in upgrades.entries) entry.key: entry.value.level,
      },
      weaponUnlocks: {
        for (final entry in weaponStates.entries)
          entry.key.name: entry.value.unlocked,
      },
      weaponSpecialLevels: {
        for (final entry in weaponStates.entries)
          entry.key.name: entry.value.specialLevel,
      },
      weaponBranchIds: {
        for (final entry in weaponStates.entries)
          if (entry.value.branchId != null)
            entry.key.name: entry.value.branchId!,
      },
      miniWeaponLevels: {
        for (final entry in miniWeaponStates.entries)
          entry.key.name: entry.value.level,
      },
      miniWeaponBranchIds: {
        for (final entry in miniWeaponStates.entries)
          if (entry.value.branchId != null)
            entry.key.name: entry.value.branchId!,
      },
      equippedMiniWeapons: [
        for (final type in equippedMiniWeapons) type.name,
      ],
      passiveLevels: {
        for (final entry in passiveLevels.entries) entry.key.name: entry.value,
      },
      shieldCharges: shieldCharges,
      bossRoundsSeen: bossRoundsSeen,
      lastBossTypeName: lastBossType?.name,
      activeWeaponEvolved: activeWeaponEvolved,
      evolvedMiniWeapons: [
        for (final type in evolvedMiniWeapons) type.name,
      ],
      bankedBossSamples: bankedBossSamples,
      nextRoundPressureLevel: nextRoundPressureLevel,
    );
    checkpointSnapshot = snapshot;
    _persistState();
  }

  void _clearCheckpoint() {
    if (isDeveloperMode) {
      return;
    }
    checkpointSnapshot = null;
    _persistState();
  }

  void startFromTitle({bool freshCourse = false}) {
    _primeAudioSession();
    if (freshCourse || checkpointSnapshot == null) {
      _resetRunState(
        showTitle: false,
        runMode: RunMode.normal,
        difficulty: selectedDifficulty,
      );
      return;
    }
    _resetRunState(
        showTitle: false,
        checkpoint: checkpointSnapshot,
        runMode: RunMode.normal);
  }

  void startFreshCourse() {
    _primeAudioSession();
    _clearCheckpoint();
    _resetRunState(
      showTitle: false,
      runMode: RunMode.normal,
      difficulty: selectedDifficulty,
    );
  }

  void startDeveloperMode() {
    _primeAudioSession();
    _resetRunState(
      showTitle: false,
      runMode: RunMode.developer,
      difficulty: selectedDifficulty,
    );
  }

  void startInteractiveTutorial() {
    _primeAudioSession();
    interactiveTutorialStepIndex = 0;
    interactiveTutorialFinished = false;
    _resetRunState(
      showTitle: false,
      runMode: RunMode.tutorial,
      difficulty: GameDifficulty.easy,
    );
    chooseStarterMiniWeapon(MiniWeaponType.sentryPod);
    shieldCharges = math.max(shieldCharges, 1);
    player?.invulnerableRemaining = 1.2;
    showBanner('Interactive tutorial started', duration: 1.8);
    if (!overlays.isActive(InteractiveTutorialOverlay.id)) {
      overlays.add(InteractiveTutorialOverlay.id);
    }
    notifyUi();
  }

  void nextInteractiveTutorialStep() {
    if (!isTutorialMode) {
      return;
    }
    if (interactiveTutorialStepIndex < interactiveTutorialSteps.length - 1) {
      interactiveTutorialStepIndex += 1;
      playSfx('ui', volume: 0.42, minGap: const Duration(milliseconds: 80));
      notifyUi();
      return;
    }
    finishInteractiveTutorial();
  }

  void previousInteractiveTutorialStep() {
    if (!isTutorialMode || interactiveTutorialStepIndex <= 0) {
      return;
    }
    interactiveTutorialStepIndex -= 1;
    playSfx('ui', volume: 0.32, minGap: const Duration(milliseconds: 80));
    notifyUi();
  }

  void finishInteractiveTutorial() {
    tutorialSeen = true;
    interactiveTutorialFinished = true;
    overlays.remove(InteractiveTutorialOverlay.id);
    _resetRunState(
      showTitle: true,
      runMode: RunMode.normal,
      difficulty: selectedDifficulty,
    );
    _persistState();
    notifyUi();
  }

  void setSelectedDifficulty(GameDifficulty difficulty) {
    if (selectedDifficulty == difficulty) {
      return;
    }
    selectedDifficulty = difficulty;
    playSfx('ui', volume: 0.55, minGap: const Duration(milliseconds: 60));
    notifyUi();
  }

  void setBiologyResourcePackEnabled(bool enabled) {
    if (biologyResourcePackEnabled == enabled) {
      return;
    }
    biologyResourcePackEnabled = enabled;
    playSfx('ui', volume: 0.50, minGap: const Duration(milliseconds: 60));
    _persistState();
    notifyUi();
  }

  void setGraphicsQualityPreset(GraphicsQualityPreset preset) {
    if (graphicsQualityPreset == preset) {
      return;
    }
    graphicsQualityPreset = preset;
    playSfx('ui', volume: 0.50, minGap: const Duration(milliseconds: 60));
    _persistState();
    notifyUi();
  }

  void setVSyncPacingEnabled(bool enabled) {
    if (vSyncPacingEnabled == enabled) {
      return;
    }
    vSyncPacingEnabled = enabled;
    playSfx('ui', volume: 0.46, minGap: const Duration(milliseconds: 60));
    _persistState();
    notifyUi();
  }

  void setAutoPerformanceScalingEnabled(bool enabled) {
    if (autoPerformanceScalingEnabled == enabled) {
      return;
    }
    autoPerformanceScalingEnabled = enabled;
    playSfx('ui', volume: 0.46, minGap: const Duration(milliseconds: 60));
    _persistState();
    notifyUi();
  }

  void setReducedEffectsEnabled(bool enabled) {
    if (reducedEffectsEnabled == enabled) {
      return;
    }
    reducedEffectsEnabled = enabled;
    playSfx('ui', volume: 0.46, minGap: const Duration(milliseconds: 60));
    _persistState();
    notifyUi();
  }

  void setFpsMeterVisible(bool enabled) {
    if (fpsMeterVisible == enabled) {
      return;
    }
    fpsMeterVisible = enabled;
    playSfx('ui', volume: 0.46, minGap: const Duration(milliseconds: 60));
    _persistState();
    notifyUi();
  }

  bool isCharacterFrameUnlocked(CharacterFrame frame) =>
      unlockedCharacterFrames.contains(frame);

  bool canPurchaseCharacterFrame(CharacterFrame frame) =>
      !isCharacterFrameUnlocked(frame) && researchPoints >= frame.unlockCost;

  void purchaseCharacterFrame(CharacterFrame frame) {
    if (isCharacterFrameUnlocked(frame)) {
      selectCharacterFrame(frame);
      return;
    }
    if (researchPoints < frame.unlockCost) {
      showBanner('${frame.title} needs ${frame.unlockCost} Research Points',
          duration: 1.8);
      notifyUi();
      return;
    }
    researchPoints -= frame.unlockCost;
    unlockedCharacterFrames.add(frame);
    selectedCharacterFrame = frame;
    playSfx('draft', volume: 0.52, minGap: const Duration(milliseconds: 100));
    showBanner('${frame.title} unlocked', duration: 1.8);
    _persistState();
    notifyUi();
  }

  void selectCharacterFrame(CharacterFrame frame) {
    if (!isCharacterFrameUnlocked(frame)) {
      purchaseCharacterFrame(frame);
      notifyUi();
      return;
    }
    selectedCharacterFrame = frame;
    playSfx('ui', volume: 0.55, minGap: const Duration(milliseconds: 60));
    _persistState();
    notifyUi();
  }

  void openDesignInterview({bool fromPause = false}) {
    if (overlays.isActive(DesignInterviewOverlay.id)) {
      return;
    }
    _designInterviewOpenedFromPause = fromPause;
    if (fromPause) {
      overlays.remove(PauseOverlay.id);
    }
    if (!onTitleScreen) {
      pausedForMenu = true;
    }
    overlays.add(DesignInterviewOverlay.id);
    notifyUi();
  }

  void closeDesignInterview() {
    overlays.remove(DesignInterviewOverlay.id);
    if (_designInterviewOpenedFromPause &&
        !onTitleScreen &&
        !gameOver &&
        !pausedForLevel &&
        !victoryPending) {
      overlays.add(PauseOverlay.id);
      pausedForMenu = true;
    } else if (!onTitleScreen &&
        !overlays.isActive(TutorialOverlay.id) &&
        !overlays.isActive(ContextTipOverlay.id) &&
        !victoryPending) {
      pausedForMenu = false;
    }
    _designInterviewOpenedFromPause = false;
    notifyUi();
  }

  void answerDesignInterview(String choiceId) {
    final question = currentDesignInterviewQuestion;
    designInterviewAnswers[question.id] = choiceId;
    if (hasNextDesignInterviewQuestion) {
      designInterviewIndex += 1;
    }
    notifyUi();
  }

  void previousDesignInterviewQuestion() {
    if (!hasPreviousDesignInterviewQuestion) {
      return;
    }
    designInterviewIndex -= 1;
    notifyUi();
  }

  void nextDesignInterviewQuestion() {
    if (!hasNextDesignInterviewQuestion) {
      return;
    }
    designInterviewIndex += 1;
    notifyUi();
  }

  void resetDesignInterview() {
    designInterviewAnswers.clear();
    designInterviewIndex = 0;
    notifyUi();
  }

  void handleTitleStart() {
    _primeAudioSession();
    startFromTitle();
  }

  void restartGame() {
    if (isDeveloperMode) {
      _resetRunState(
        showTitle: false,
        runMode: RunMode.developer,
        difficulty: currentDifficulty,
      );
    } else if (isTutorialMode) {
      startInteractiveTutorial();
    } else if (checkpointSnapshot != null) {
      _resetRunState(
          showTitle: false,
          checkpoint: checkpointSnapshot,
          runMode: RunMode.normal);
    } else {
      _resetRunState(
        showTitle: false,
        runMode: RunMode.normal,
        difficulty: currentDifficulty,
      );
    }
  }

  void returnToTitle() {
    _resetRunState(
        showTitle: true,
        checkpoint: checkpointSnapshot,
        runMode: RunMode.normal);
  }

  Vector2 get moveInput {
    final keyboard = Vector2.zero();
    if (_keysPressed.contains(LogicalKeyboardKey.keyA) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      keyboard.x -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyD) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      keyboard.x += 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyW) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      keyboard.y -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyS) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      keyboard.y += 1;
    }
    final combined = keyboard + touchDirection;
    if (combined.length2 > 1) {
      combined.normalize();
    }
    return combined;
  }

  void setTouchDirection(Vector2 direction) {
    touchDirection = direction;
  }

  void triggerDash() {
    if (isGameplayActive) {
      player?.tryDash();
      notifyUi();
    }
  }

  double gameYSpawn(double entitySize) {
    final minY = playAreaTop;
    final maxY = math.max(minY, size.y - entitySize);
    return minY + rng.nextDouble() * math.max(1.0, maxY - minY);
  }

  EnemyArchetype get _heavyFrontlinerArchetype =>
      bruteUnlocked ? EnemyArchetype.brute : EnemyArchetype.tank;

  EnemyArchetype _pickEnemyArchetype() {
    final midgamePressure = math.max(0, currentRound - 4);
    final weights = <EnemyArchetype, int>{
      EnemyArchetype.swarm: currentRound <= 3
          ? 38 - math.max(0, currentRound - 1) * 2
          : math.max(12, 30 - midgamePressure * 3),
      EnemyArchetype.runner:
          currentRound <= 3 ? 22 + currentRound : 24 + midgamePressure * 2,
      EnemyArchetype.stalker: stalkerUnlocked
          ? currentRound <= 1
              ? 8
              : currentRound == 2
                  ? 10
                  : currentRound == 3
                      ? 12
                      : 18 + midgamePressure * 3
          : 0,
      EnemyArchetype.tank: bruteUnlocked
          ? 0
          : currentRound <= 1
              ? 4
              : currentRound == 2
                  ? 6
                  : currentRound == 3
                      ? 8
                      : 10 + midgamePressure * 4,
      EnemyArchetype.brute:
          bruteUnlocked ? 8 + currentRound + midgamePressure * 4 : 0,
      EnemyArchetype.splitter: splitterUnlocked ? 4 + midgamePressure * 3 : 0,
      EnemyArchetype.rainbow: defeatedBossCount >= 4 && currentRound >= 8
          ? 2 + currentRound ~/ 5
          : 0,
    }..removeWhere((_, weight) => weight <= 0);
    final totalWeight =
        weights.values.fold<int>(0, (sum, weight) => sum + weight);
    var roll = rng.nextInt(totalWeight);
    for (final entry in weights.entries) {
      if (roll < entry.value) {
        return entry.key;
      }
      roll -= entry.value;
    }
    return EnemyArchetype.swarm;
  }

  int spawnEnemy() {
    final remainingThreats = enemiesTargetThisRound - enemiesSpawnedThisRound;
    if (_shouldSpawnTacticalPack(remainingThreats)) {
      return _spawnTacticalPack(math.min(remainingThreats, 3));
    }
    return _spawnEnemyFromArchetype(_pickEnemyArchetype()) ? 1 : 0;
  }

  bool _shouldSpawnTacticalPack(int remainingThreats) {
    if (remainingThreats < 3 || currentRound < 5) {
      return false;
    }
    final cadence = currentRound <= 6
        ? math.max(5, 10 - currentRound ~/ 3)
        : math.max(4, 8 - currentRound ~/ 3);
    return enemiesSpawnedThisRound > 0 &&
        enemiesSpawnedThisRound % cadence == 0;
  }

  int _spawnTacticalPack(int maxCount) {
    if (maxCount < 3) {
      return _spawnEnemyFromArchetype(_pickEnemyArchetype()) ? 1 : 0;
    }
    final packBuilders = <int Function()>[
      _spawnRunnerPincerPack,
      if (stalkerUnlocked) _spawnStalkerClampPack,
      if (splitterUnlocked) _spawnSplitterScreenPack,
    ];
    return packBuilders[rng.nextInt(packBuilders.length)]();
  }

  int _spawnClusterPhasePack() {
    if (currentRound <= 3) {
      return _spawnRunnerPincerPack();
    }
    if (currentRound <= 5 || !stalkerUnlocked) {
      return rng.nextBool()
          ? _spawnRunnerPincerPack()
          : _spawnStalkerClampPack();
    }
    return _spawnTacticalPack(3);
  }

  Vector2 _edgeSpawnPosition({
    required int edge,
    required double entitySize,
    double? laneY,
    double? laneX,
  }) {
    final margin = entitySize + 8;
    switch (edge) {
      case 0:
        return Vector2(
            -margin,
            (laneY ?? gameYSpawn(entitySize))
                .clamp(playAreaTop, size.y - entitySize)
                .toDouble());
      case 1:
        return Vector2(
            size.x + margin,
            (laneY ?? gameYSpawn(entitySize))
                .clamp(playAreaTop, size.y - entitySize)
                .toDouble());
      case 2:
        return Vector2(
          (laneX ?? (rng.nextDouble() * math.max(1.0, size.x - entitySize)))
              .clamp(0.0, size.x - entitySize)
              .toDouble(),
          playAreaTop - margin,
        );
      default:
        return Vector2(
          (laneX ?? (rng.nextDouble() * math.max(1.0, size.x - entitySize)))
              .clamp(0.0, size.x - entitySize)
              .toDouble(),
          size.y + margin,
        );
    }
  }

  int _spawnRunnerPincerPack() {
    final playerCenter = player?.center ?? Vector2(size.x / 2, size.y / 2);
    final laneY =
        playerCenter.y.clamp(playAreaTop + 28, size.y - 28).toDouble();
    var spawned = 0;
    if (_spawnEnemyFromArchetype(
      EnemyArchetype.runner,
      forcedPosition:
          _edgeSpawnPosition(edge: 0, entitySize: 22, laneY: laneY - 26),
      forcedHealth: 2 + currentRound ~/ 4,
      forcedSpeed: 134 + currentRound * 2.1,
    )) {
      spawned += 1;
    }
    if (_spawnEnemyFromArchetype(
      EnemyArchetype.runner,
      forcedPosition:
          _edgeSpawnPosition(edge: 1, entitySize: 22, laneY: laneY + 26),
      forcedHealth: 2 + currentRound ~/ 4,
      forcedSpeed: 134 + currentRound * 2.1,
    )) {
      spawned += 1;
    }
    if (_spawnEnemyFromArchetype(
      stalkerUnlocked ? EnemyArchetype.stalker : _heavyFrontlinerArchetype,
      forcedPosition: _edgeSpawnPosition(
        edge: rng.nextBool() ? 2 : 3,
        entitySize: stalkerUnlocked ? 24 : 30,
        laneX: playerCenter.x,
      ),
      forcedHealth: (stalkerUnlocked ? 4 : 7) + currentRound ~/ 4,
      forcedSpeed: (stalkerUnlocked ? 98 : 78) + currentRound * 1.7,
    )) {
      spawned += 1;
    }
    return spawned;
  }

  int _spawnStalkerClampPack() {
    if (!stalkerUnlocked) {
      return _spawnRunnerPincerPack();
    }
    final playerCenter = player?.center ?? Vector2(size.x / 2, size.y / 2);
    final leftX = (playerCenter.x - 58).clamp(24.0, size.x - 24).toDouble();
    final rightX = (playerCenter.x + 58).clamp(24.0, size.x - 24).toDouble();
    var spawned = 0;
    if (_spawnEnemyFromArchetype(
      EnemyArchetype.stalker,
      forcedPosition: _edgeSpawnPosition(edge: 2, entitySize: 24, laneX: leftX),
      forcedHealth: 4 + currentRound ~/ 4,
      forcedSpeed: 96 + currentRound * 1.6,
    )) {
      spawned += 1;
    }
    if (_spawnEnemyFromArchetype(
      EnemyArchetype.stalker,
      forcedPosition:
          _edgeSpawnPosition(edge: 3, entitySize: 24, laneX: rightX),
      forcedHealth: 4 + currentRound ~/ 4,
      forcedSpeed: 96 + currentRound * 1.6,
    )) {
      spawned += 1;
    }
    if (_spawnEnemyFromArchetype(
      _heavyFrontlinerArchetype,
      forcedPosition: _edgeSpawnPosition(
        edge: rng.nextBool() ? 0 : 1,
        entitySize: 30,
        laneY: playerCenter.y,
      ),
      forcedHealth: (bruteUnlocked ? 11 : 8) + currentRound ~/ 3,
      forcedSpeed: (bruteUnlocked ? 98 : 72) + currentRound * 1.3,
    )) {
      spawned += 1;
    }
    return spawned;
  }

  int _spawnSplitterScreenPack() {
    final playerCenter = player?.center ?? Vector2(size.x / 2, size.y / 2);
    var spawned = 0;
    if (_spawnEnemyFromArchetype(
      EnemyArchetype.splitter,
      forcedPosition: _edgeSpawnPosition(
        edge: rng.nextBool() ? 2 : 3,
        entitySize: 26,
        laneX: playerCenter.x,
      ),
      forcedHealth: 5 + currentRound ~/ 3,
      forcedSpeed: 88 + currentRound * 1.2,
    )) {
      spawned += 1;
    }
    if (_spawnEnemyFromArchetype(
      EnemyArchetype.runner,
      forcedPosition: _edgeSpawnPosition(
          edge: 0, entitySize: 20, laneY: playerCenter.y - 48),
      forcedHealth: 2 + currentRound ~/ 4,
      forcedSpeed: 136 + currentRound * 2.0,
    )) {
      spawned += 1;
    }
    if (_spawnEnemyFromArchetype(
      EnemyArchetype.runner,
      forcedPosition: _edgeSpawnPosition(
          edge: 1, entitySize: 20, laneY: playerCenter.y + 48),
      forcedHealth: 2 + currentRound ~/ 4,
      forcedSpeed: 136 + currentRound * 2.0,
    )) {
      spawned += 1;
    }
    return spawned;
  }

  bool _spawnEnemyFromArchetype(
    EnemyArchetype archetype, {
    Vector2? forcedPosition,
    double? forcedSize,
    int? forcedHealth,
    double? forcedSpeed,
    int? rewardCoins,
    bool canDropPickup = true,
    int splitGeneration = 0,
    bool enhancedWeaver = false,
    bool spawnedByBoss = false,
  }) {
    if (enemyRegistry.length >= maxActiveEnemies) {
      return false;
    }
    final enemySize = forcedSize ??
        (archetype.baseSize + rng.nextDouble() * archetype.sizeVariance);
    late Vector2 spawn;
    if (forcedPosition != null) {
      spawn = forcedPosition.clone();
    } else {
      final spawnMargin = enemySize + 8;
      switch (rng.nextInt(4)) {
        case 0:
          spawn = Vector2(-spawnMargin, gameYSpawn(enemySize));
          break;
        case 1:
          spawn = Vector2(size.x + spawnMargin, gameYSpawn(enemySize));
          break;
        case 2:
          spawn = Vector2(rng.nextDouble() * math.max(1.0, size.x - enemySize),
              playAreaTop - spawnMargin);
          break;
        default:
          spawn = Vector2(rng.nextDouble() * math.max(1.0, size.x - enemySize),
              size.y + spawnMargin);
          break;
      }
    }

    final effectiveSplitGeneration = splitGeneration > 0
        ? splitGeneration
        : (archetype == EnemyArchetype.splitter && splitterBurstUnlocked
            ? 1
            : 0);
    final baseHp = forcedHealth ??
        (archetype.baseHealth +
            rng.nextInt(archetype.healthVariance + 1) +
            enemyHealthBonus +
            currentRound ~/ 2 +
            math.max(0, currentRound - 6) ~/ 2 +
            (masteryMode ? 2 : 0));
    final hp = math.max(
      1,
      (baseHp *
              (enhancedWeaver ? 1.55 : 1.0) *
              1.58 *
              _difficultyEnemyHealthMultiplier *
              _earlyWaveEnemyHealthMultiplier)
          .round(),
    );
    final baseSpeed = forcedSpeed ??
        (archetype.baseSpeed +
            rng.nextDouble() * archetype.speedVariance +
            currentRound * (masteryMode ? 2.8 : 1.9) +
            math.max(0, currentRound - 5) * 0.8);
    final speed = baseSpeed *
        (enhancedWeaver ? 1.10 : 1.0) *
        _difficultyEnemySpeedMultiplier *
        _earlyWaveEnemySpeedMultiplier;
    add(
      EnemyComponent(
        archetype: archetype,
        position: spawn,
        size: Vector2.all(enemySize),
        baseSpeed: speed,
        health: hp,
        rewardCoins: rewardCoins ?? archetype.coinValue,
        canDropPickup: canDropPickup,
        splitGeneration: effectiveSplitGeneration,
        enhancedWeaver: enhancedWeaver,
        spawnedByBoss: spawnedByBoss,
      ),
    );
    return true;
  }

  void spawnEnhancedWeavers(Vector2 origin, int count) {
    if (enemyRegistry.length >= maxActiveEnemies) {
      return;
    }
    for (int i = 0; i < count; i++) {
      final angle =
          (math.pi * 2 * i) / math.max(1, count) + rng.nextDouble() * 0.45;
      final offset = Vector2(math.cos(angle), math.sin(angle)) *
          (42 + rng.nextDouble() * 26);
      if (_spawnEnemyFromArchetype(
        EnemyArchetype.stalker,
        forcedPosition: _clampPickupPosition(origin + offset, 28),
        forcedSize: 28,
        forcedHealth: 6 + currentRound ~/ 3,
        forcedSpeed: 116 + currentRound * 2.0,
        rewardCoins: 0,
        canDropPickup: false,
        enhancedWeaver: true,
        spawnedByBoss: true,
      )) {
        enemiesSpawnedThisRound += 1;
      }
    }
  }

  void spawnBossBrood(Vector2 origin, int count, {required bool heavySplit}) {
    for (int i = 0; i < count; i++) {
      final offsetAngle = (math.pi * 2 * i) / math.max(1, count);
      final offset = Vector2(math.cos(offsetAngle), math.sin(offsetAngle)) *
          (28 + rng.nextDouble() * 22);
      final archetype = heavySplit && i.isEven
          ? EnemyArchetype.splitter
          : EnemyArchetype.swarm;
      if (_spawnEnemyFromArchetype(
        archetype,
        forcedPosition: origin + offset,
        forcedSize: archetype == EnemyArchetype.splitter ? 22 : 15,
        forcedHealth: archetype == EnemyArchetype.splitter
            ? 3 + currentRound ~/ 4
            : 1 + currentRound ~/ 6,
        forcedSpeed: archetype == EnemyArchetype.splitter
            ? 92
            : 120 + currentRound * 1.2,
        rewardCoins: 0,
        canDropPickup: false,
        splitGeneration: archetype == EnemyArchetype.splitter ? 1 : 0,
        spawnedByBoss: true,
      )) {
        enemiesSpawnedThisRound += 1;
      }
    }
  }

  void spawnSplitterChildren(EnemyComponent enemy) {
    for (int i = 0; i < 2; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final offset = Vector2(math.cos(angle), math.sin(angle)) * 10;
      if (_spawnEnemyFromArchetype(
        EnemyArchetype.swarm,
        forcedPosition: enemy.center + offset,
        forcedSize: 12,
        forcedHealth: 1 + currentRound ~/ 8,
        forcedSpeed: 150 + currentRound * 1.2,
        rewardCoins: 0,
        canDropPickup: false,
        spawnedByBoss: enemy.spawnedByBoss,
      )) {
        enemiesSpawnedThisRound += 1;
      }
    }
  }

  void _spawnBoss() {
    bossRoundsSeen += 1;
    final bossType = pendingBossType ??
        pickBossType(
          rng: rng,
          bossRoundsSeen: bossRoundsSeen,
          lastBossType: lastBossType,
        );
    pendingBossType = null;
    _spawnSpecificBoss(bossType);
    playSfx('boss', volume: 0.82, minGap: const Duration(milliseconds: 600));
  }

  void _spawnSpecificBoss(BossType bossType) {
    currentBossType = bossType;
    lastBossType = bossType;
    final firstStalkerBoss =
        bossType == BossType.stalkerApex && bossRoundsSeen <= 1 && !masteryMode;

    final bossSize = switch (bossType) {
      BossType.stalkerApex => firstStalkerBoss ? 140.0 : 122.0,
      BossType.splitterQueen => 108.0,
      BossType.chargerBrute => 116.0,
    };
    late Vector2 spawn;
    switch (rng.nextInt(4)) {
      case 0:
        spawn = Vector2(-bossSize, gameYSpawn(bossSize));
        break;
      case 1:
        spawn = Vector2(size.x + bossSize, gameYSpawn(bossSize));
        break;
      case 2:
        spawn = Vector2(rng.nextDouble() * math.max(40.0, size.x - bossSize),
            playAreaTop - bossSize);
        break;
      default:
        spawn = Vector2(rng.nextDouble() * math.max(40.0, size.x - bossSize),
            size.y + bossSize);
        break;
    }
    final bossHealthMultiplier = switch (bossType) {
      BossType.stalkerApex => firstStalkerBoss ? 0.50 : 0.68,
      BossType.splitterQueen => 1.10,
      BossType.chargerBrute => 1.42,
    };
    final healthBase = ((56 + currentRound * 10 + (masteryMode ? 36 : 0)) *
            2 *
            bossHealthMultiplier *
            _difficultyBossHealthMultiplier *
            _earlyBossHealthMultiplier)
        .round();
    final speedBase = (76 + currentRound * 2.2 + (masteryMode ? 10 : 0)) *
        switch (bossType) {
          BossType.stalkerApex => firstStalkerBoss ? 1.03 : 1.18,
          BossType.splitterQueen => 1.0,
          BossType.chargerBrute => 1.0,
        };
    final boss = BossComponent(
      bossType: bossType,
      position: spawn,
      size: Vector2.all(bossSize),
      maxHealth: healthBase,
      health: healthBase,
      baseSpeed: speedBase,
      coinValue: 10 + currentRound * 2,
    );
    if (currentRound <= 6 && !masteryMode) {
      boss.introTimer = firstStalkerBoss ? 1.9 : 1.25;
    }
    add(boss);
  }

  void triggerChargerMitosis(BossComponent boss) {
    showBanner('${boss.bossType.title} undergoes mitosis', duration: 2.2);
    final childHealth = math.max(18, (boss.maxHealth * 0.25).round());
    final childSize = boss.size.x * 0.66;
    final offsets = <Vector2>[
      Vector2(-childSize * 0.55, -childSize * 0.15),
      Vector2(childSize * 0.55, -childSize * 0.15),
      Vector2(0, childSize * 0.60),
    ];
    for (final offset in offsets) {
      final spawn = _clampPickupPosition(
        boss.center + offset - Vector2.all(childSize / 2),
        childSize,
      );
      add(
        BossComponent(
          bossType: BossType.chargerBrute,
          position: spawn,
          size: Vector2.all(childSize),
          maxHealth: childHealth,
          health: childHealth,
          baseSpeed: boss.baseSpeed * 1.18,
          coinValue: 0,
          isMitosisChild: true,
        )..introTimer = 0.18,
      );
    }
  }

  void fireBossArtilleryBurst(BossComponent boss, {required bool phaseTwo}) {
    final total = phaseTwo ? 18 : 14;
    final safeStart = rng.nextInt(total);
    final gapSize = phaseTwo ? 3 : 2;
    for (int i = 0; i < total; i++) {
      final distance = (i - safeStart).abs();
      final wrappedDistance = math.min(distance, total - distance);
      if (wrappedDistance < gapSize) {
        continue;
      }
      final angle = (math.pi * 2 * i) / total;
      add(
        EnemyProjectileComponent(
          position: boss.center - Vector2.all(7),
          direction: Vector2(math.cos(angle), math.sin(angle)),
          speed: phaseTwo ? 228 : 190,
          tint: const Color(0xFF95D5B2),
          bulletSize: phaseTwo ? 14 : 12,
        ),
      );
    }
  }

  Vector2 _clampPickupPosition(Vector2 position, double entitySize) {
    return Vector2(
      position.x.clamp(0.0, math.max(0.0, size.x - entitySize)).toDouble(),
      position.y
          .clamp(playAreaTop, math.max(playAreaTop, size.y - entitySize))
          .toDouble(),
    );
  }

  void spawnCoin(Vector2 position, int value) {
    add(CoinComponent(
        position: _clampPickupPosition(position, 12), value: value));
  }

  void spawnPickup(Vector2 position, PickupType type) {
    add(PickupComponent(
        position: _clampPickupPosition(position, 18), pickupType: type));
  }

  void spawnSample(Vector2 position, int value,
      {required bool banksForNextRound}) {
    if (value <= 0) {
      return;
    }
    add(
      SampleComponent(
        position: _clampPickupPosition(position, 14),
        value: value,
        banksForNextRound: banksForNextRound,
      ),
    );
  }

  Vector2? nearestThreatCenterTo(Vector2 from,
      {double maxDistance = double.infinity}) {
    Vector2? best;
    double bestDistance =
        maxDistance.isFinite ? maxDistance * maxDistance : double.infinity;
    final enemyCandidates = maxDistance.isFinite
        ? _enemyCandidatesForRect(Rect.fromCircle(
            center: Offset(from.x, from.y), radius: maxDistance))
        : enemyRegistry;
    for (final enemy in enemyCandidates) {
      final distance = enemy.center.distanceToSquared(from);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = enemy.center;
      }
    }
    for (final boss in bossRegistry) {
      final distance = boss.center.distanceToSquared(from);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = boss.center;
      }
    }
    return best;
  }

  void awardKill(EnemyComponent enemy) {
    kills += 1;
    enemiesDefeatedThisRound += 1;
    if (enemy.archetype != EnemyArchetype.swarm) {
      playSfx('pop', volume: 0.22, minGap: const Duration(milliseconds: 45));
    }
    final sampleValue = _sampleValueForEnemy(enemy);
    final banksForNextRound = roundBossRequired && !enemy.enhancedWeaver;
    if (sampleValue > 0 && (banksForNextRound || !samplesCappedThisRound)) {
      spawnSample(
        enemy.center - Vector2.all(5),
        sampleValue,
        banksForNextRound: banksForNextRound,
      );
    }
    notifyUi();
    _maybeFinishRound();
  }

  void awardBossKill(BossComponent boss) {
    kills += 1;
    enemiesDefeatedThisRound += 1;
    final completedBossGate = !boss.isMitosisChild || bossRegistry.length <= 1;
    if (!completedBossGate) {
      notifyUi();
      return;
    }
    playSfx('victory', volume: 0.48, minGap: const Duration(milliseconds: 400));
    final rewardType = bossRewardPickupForIndex(bossRewardsGranted);
    bossRewardsGranted += 1;
    _grantPickup(
      rewardType,
      showBannerMessage: false,
      showTip: true,
    );
    defeatedBossCount += 1;
    showBanner(
      '${boss.bossType.title} defeated. ${rewardType.title} granted.',
      duration: 2.8,
    );
    notifyUi();
    if (roundPhase == RoundFlowPhase.bossFight) {
      _beginCleanup(fromBoss: true);
    }
  }

  int _sampleValueForEnemy(EnemyComponent enemy) {
    if (roundPhase == RoundFlowPhase.bossFight || enemy.spawnedByBoss) {
      return 0;
    }
    if (enemy.enhancedWeaver) {
      return 3;
    }
    switch (enemy.archetype) {
      case EnemyArchetype.swarm:
        return roundBossRequired ? 0 : 1;
      case EnemyArchetype.runner:
      case EnemyArchetype.stalker:
        return 1;
      case EnemyArchetype.tank:
      case EnemyArchetype.splitter:
        return 2;
      case EnemyArchetype.brute:
        return 3;
      case EnemyArchetype.rainbow:
        return 4;
    }
  }

  void addCredits(int amount) {
    // Coins were removed from the active progression flow.
  }

  void collectSample(int amount, {required bool banksForNextRound}) {
    if (amount <= 0) {
      return;
    }
    if (banksForNextRound) {
      final cap = currentSampleThreshold - 4;
      bankedBossSamples = math.min(cap, bankedBossSamples + amount);
      notifyUi();
      return;
    }
    if (combatLevelsThisRound >= currentCombatLevelCap) {
      notifyUi();
      return;
    }
    sampleCount += amount;
    while (sampleCount >= currentSampleThreshold &&
        combatLevelsThisRound < currentCombatLevelCap) {
      sampleCount -= currentSampleThreshold;
      combatLevelsThisRound += 1;
      openCombatLevelChoice();
      if (pausedForCombatLevel) {
        break;
      }
    }
    notifyUi();
  }

  void _grantPickup(
    PickupType type, {
    bool showBannerMessage = true,
    bool showTip = true,
  }) {
    switch (type) {
      case PickupType.shield:
        shieldCharges += 1;
        if (showBannerMessage) {
          showBanner('Shield membrane ready', duration: 1.8);
        }
        if (showTip) {
          showContextTipOnce(
            id: 'pickup_shield',
            title: 'Shield Membrane',
            body:
                'Shield Membrane blocks the next hit. It persists until something breaks it.',
          );
        }
        break;
      case PickupType.magnet:
        if (showBannerMessage) {
          showBanner('Magnetism is removed in this build', duration: 1.6);
        }
        break;
    }
    notifyUi();
  }

  void _openRoundSummary() {
    if (pausedForLevel || gameOver || onTitleScreen) {
      return;
    }
    if (lessonSequence.isEmpty) {
      showBanner(
          'Lesson content unavailable. Reconnect once to download lessons.',
          duration: 3.4);
      currentRound += 1;
      _prepareRound(currentRound);
      notifyUi();
      return;
    }
    currentLessonSession = LevelLessonSession.forRound(
      roundNumber: currentRound,
      lesson: masteryMode ? _buildMasteryLesson() : currentCourseLesson,
      rng: rng,
      requiresChest: chestPendingFromBoss,
    );
    if (chestPendingFromBoss) {
      _primeBossChest(currentLessonSession!);
    }
    pausedForLevel = true;
    roundPhase = RoundFlowPhase.idle;
    overlays.add(LevelOverlay.id);
    notifyUi();
  }

  void _primeBossChest(LevelLessonSession session) {
    final evolutionTarget = nextEvolvableMiniWeapon;
    if (evolutionTarget != null) {
      evolvedMiniWeapons.add(evolutionTarget);
      session.chestResolved = false;
      session.chestTitle =
          '${evolvedMiniWeaponTitle(evolutionTarget)} awakened';
      session.chestSummary =
          'Your boss chest evolved ${evolutionTarget.title}.';
      refreshMiniWeaponAttachments();
      return;
    }
    session.chestOffers = buildBossChestOffers(
      rng: rng,
      activeWeapon: activeWeapon,
      activeWeaponLevel: activeWeaponState.specialLevel,
      activeWeaponBranched: activeWeaponBranched,
      supportWeaponLevels: {
        for (final entry in miniWeaponStates.entries)
          entry.key: entry.value.level,
      },
      branchedSupportWeapons: branchedMiniWeapons,
      passiveLevels: passiveLevels,
      evolvedSupportWeapons: evolvedMiniWeapons,
    );
    session.chestResolved = false;
    session.chestTitle = 'Boss chest opened';
    session.chestSummary = 'Choose 1 premium reward from your current build.';
  }

  LessonContent _buildMasteryLesson() {
    final lessons = [...lessonSequence]..shuffle(rng);
    final questionPool = <LessonQuestion>[
      for (final lesson in lessonSequence) ...lesson.questions,
    ]..shuffle(rng);
    final sampledTerms = <String>[
      for (final lesson in lessons.take(3)) ...lesson.keyTerms.take(2),
    ];
    final recap = lessons.take(3).map((lesson) {
      final terms = lesson.keyTerms.take(2).join(' and ');
      return '${lesson.unitTitle} reconnects terms like $terms.';
    }).join(' ');
    return LessonContent(
      unitNumber: 99,
      unitTitle: 'Mastery Review',
      title: 'Mastery Review Round',
      sourceTitle: 'Mixed review from earlier lessons',
      sourceUrl: '',
      sourceCredit: 'Mixed review generated from earlier course units.',
      readingText: recap,
      prompt: 'Fast mixed review before the next mastery wave.',
      keyTerms: sampledTerms.take(6).toList(),
      questions: questionPool.take(3).toList(),
    );
  }

  void _maybeFinishRound() {
    if (roundPhase == RoundFlowPhase.bossFight &&
        bossRegistry.isEmpty &&
        !roundComplete) {
      _beginCleanup(fromBoss: true);
    }
  }

  void continuePastChest() {
    final session = currentLessonSession;
    if (session == null || session.step != LessonOverlayStep.chest) {
      return;
    }
    session.chestResolved = true;
    session.step = LessonOverlayStep.reading;
    notifyUi();
  }

  void chooseBossChestOffer(BuildOffer offer) {
    final session = currentLessonSession;
    if (session == null || session.step != LessonOverlayStep.chest) {
      return;
    }
    _applyBuildOffer(offer, announce: false);
    session.chestResolved = true;
    session.step = LessonOverlayStep.reading;
    session.chestSummary =
        '${offer.title} improved your build before the lesson break.';
    notifyUi();
  }

  void startLessonQuestions() {
    final session = currentLessonSession;
    if (session == null) {
      return;
    }
    session.step = LessonOverlayStep.questions;
    session.questionIndex = 0;
    notifyUi();
  }

  void selectLessonAnswer(int answerIndex) {
    final session = currentLessonSession;
    if (session == null || session.step != LessonOverlayStep.questions) {
      return;
    }
    session.selectedAnswers[session.questionIndex] = answerIndex;
    notifyUi();
  }

  void submitLessonAnswer() {
    final session = currentLessonSession;
    if (session == null || session.step != LessonOverlayStep.questions) {
      return;
    }
    final selected = session.selectedAnswers[session.questionIndex];
    if (selected == null) {
      return;
    }
    final question = session.presentedQuestions[session.questionIndex];
    if (selected == question.correctIndex) {
      session.correctCount += 1;
      playSfx('quizRight',
          volume: 0.32, minGap: const Duration(milliseconds: 80));
    } else {
      playSfx('quizWrong',
          volume: 0.28, minGap: const Duration(milliseconds: 80));
    }
    session.questionIndex += 1;
    if (session.questionIndex >= session.presentedQuestions.length) {
      _finalizeLessonSession();
    }
    notifyUi();
  }

  void _finalizeLessonSession() {
    final session = currentLessonSession;
    if (session == null) {
      return;
    }
    final resolution = resolveDraftProfile(session.correctCount);
    session.step = LessonOverlayStep.results;
    session.draftProfile = resolution;
    session.resultTitle = resolution.title;
    session.resultSummary = resolution.summary;
    pendingOpeningPressureLevel = resolution.pressureLevel;
    session.draftOffers = buildPostLessonDraft(
      rng: rng,
      activeWeapon: activeWeapon,
      activeWeaponLevel: activeWeaponState.specialLevel,
      activeWeaponBranched: activeWeaponBranched,
      supportWeaponLevels: {
        for (final entry in miniWeaponStates.entries)
          entry.key: entry.value.level,
      },
      branchedSupportWeapons: branchedMiniWeapons,
      passiveLevels: passiveLevels,
      choiceCount: resolution.choiceCount,
      lowerQuality: resolution.lowerQuality,
      evolvedSupportWeapons: evolvedMiniWeapons,
    );
    session.draftResolved = false;
    session.draftRerolled = false;
    session.purchasedSupportOptions.clear();
    if (session.correctCount == 3) {
      quizPerfectRounds += 1;
    } else if (session.correctCount == 2) {
      quizSolidRounds += 1;
    } else {
      quizWeakRounds += 1;
    }
    notifyUi();
  }

  bool get canRerollDraft {
    final session = currentLessonSession;
    return session != null &&
        session.step == LessonOverlayStep.results &&
        !session.draftResolved &&
        !session.draftRerolled &&
        (session.draftProfile?.grantsReroll ?? false);
  }

  void rerollDraftOffers() {
    final session = currentLessonSession;
    if (session == null || !canRerollDraft) {
      return;
    }
    session.draftOffers = buildPostLessonDraft(
      rng: rng,
      activeWeapon: activeWeapon,
      activeWeaponLevel: activeWeaponState.specialLevel,
      activeWeaponBranched: activeWeaponBranched,
      supportWeaponLevels: {
        for (final entry in miniWeaponStates.entries)
          entry.key: entry.value.level,
      },
      branchedSupportWeapons: branchedMiniWeapons,
      passiveLevels: passiveLevels,
      choiceCount: session.draftProfile?.choiceCount ?? 3,
      lowerQuality: session.draftProfile?.lowerQuality ?? false,
      evolvedSupportWeapons: evolvedMiniWeapons,
    );
    session.draftRerolled = true;
    playSfx('ui', volume: 0.52, minGap: const Duration(milliseconds: 80));
    showBanner('Draft rerolled', duration: 1.2);
    notifyUi();
  }

  void chooseDraftOffer(BuildOffer offer) {
    final session = currentLessonSession;
    if (session == null ||
        session.step != LessonOverlayStep.results ||
        session.draftResolved) {
      return;
    }
    _applyBuildOffer(offer);
    playSfx('draft', volume: 0.72, minGap: const Duration(milliseconds: 120));
    session.draftResolved = true;
    notifyUi();
  }

  void skipDraftOffer() {
    final session = currentLessonSession;
    if (session == null ||
        session.step != LessonOverlayStep.results ||
        session.draftResolved) {
      return;
    }
    session.draftResolved = true;
    session.draftSkipped = true;
    showBanner('Draft skipped', duration: 1.0);
    notifyUi();
  }

  void _applyBuildOffer(BuildOffer offer, {bool announce = true}) {
    switch (offer.type) {
      case BuildOfferType.primaryUpgrade:
        final state = activeWeaponState;
        state.unlocked = true;
        state.specialLevel = math.min(
            miniWeaponLevelCap, state.specialLevel + offer.rarity.levelGain);
        if (announce) {
          final branchReady =
              state.specialLevel >= miniWeaponBranchUnlockLevel &&
                  state.branchId == null;
          showBanner(
            branchReady
                ? '${offer.title} grew to Lv.${state.specialLevel} - specialization ready'
                : '${offer.title} grew to Lv.${state.specialLevel}',
            duration: 1.4,
          );
        }
        break;
      case BuildOfferType.primaryBranch:
        final state = activeWeaponState;
        state.unlocked = true;
        state.specialLevel =
            math.max(miniWeaponBranchUnlockLevel, state.specialLevel);
        state.branchId = offer.branchId;
        if (announce) {
          showBanner(
            '${activeWeapon.title} specialized into ${primaryBranchTitle(activeWeapon, state.branchId) ?? offer.title}',
            duration: 1.4,
          );
        }
        break;
      case BuildOfferType.supportUnlock:
        final state = miniWeaponStates[offer.supportWeapon]!;
        state.level = math.max(state.level, offer.rarity.levelGain);
        state.equipped = true;
        _primeMiniWeapon(state.type);
        refreshMiniWeaponAttachments();
        if (announce) {
          final branchReady = state.level >= miniWeaponBranchUnlockLevel &&
              state.branchId == null;
          showBanner(
            branchReady
                ? '${offer.title} unlocked - specialization ready'
                : '${offer.title} unlocked',
            duration: 1.4,
          );
        }
        break;
      case BuildOfferType.supportUpgrade:
        final state = miniWeaponStates[offer.supportWeapon]!;
        state.level =
            math.min(miniWeaponLevelCap, state.level + offer.rarity.levelGain);
        state.equipped = true;
        _primeMiniWeapon(state.type);
        refreshMiniWeaponAttachments();
        if (announce) {
          final branchReady = state.level >= miniWeaponBranchUnlockLevel &&
              state.branchId == null;
          showBanner(
            branchReady
                ? '${offer.title} grew to Lv.${state.level} - specialization ready'
                : '${offer.title} grew to Lv.${state.level}',
            duration: 1.4,
          );
        }
        break;
      case BuildOfferType.supportBranch:
        final state = miniWeaponStates[offer.supportWeapon]!;
        state.level = math.max(miniWeaponBranchUnlockLevel, state.level);
        state.branchId = offer.branchId;
        state.equipped = true;
        _primeMiniWeapon(state.type);
        refreshMiniWeaponAttachments();
        if (announce) {
          showBanner(
            '${state.type.title} specialized into ${supportBranchTitle(state.type, state.branchId) ?? offer.title}',
            duration: 1.4,
          );
        }
        break;
      case BuildOfferType.passiveUnlock:
        final passive = offer.passive!;
        passiveLevels[passive] =
            math.max(passiveLevels[passive] ?? 0, offer.rarity.levelGain);
        if (announce) {
          showBanner('${passive.title} unlocked', duration: 1.4);
        }
        break;
      case BuildOfferType.passiveUpgrade:
        final passive = offer.passive!;
        passiveLevels[passive] =
            math.min(5, (passiveLevels[passive] ?? 0) + offer.rarity.levelGain);
        if (announce) {
          showBanner('${passive.title} grew to Lv.${passiveLevels[passive]}',
              duration: 1.4);
        }
        break;
    }
    notifyUi();
  }

  bool canBuySupportOption(SupportOptionType option) {
    final session = currentLessonSession;
    if (session == null ||
        session.step != LessonOverlayStep.results ||
        !session.draftResolved) {
      return false;
    }
    if (session.purchasedSupportOptions.contains(option) ||
        credits < option.cost) {
      return false;
    }
    switch (option) {
      case SupportOptionType.heal:
        return lives < 3;
      case SupportOptionType.shield:
        return shieldCharges <= 0;
      case SupportOptionType.magnet:
        return false;
      case SupportOptionType.soften:
        return true;
    }
  }

  void buySupportOption(SupportOptionType option) {
    final session = currentLessonSession;
    if (session == null || !canBuySupportOption(option)) {
      return;
    }
    credits -= option.cost;
    session.purchasedSupportOptions.add(option);
    switch (option) {
      case SupportOptionType.heal:
        lives = math.min(3, lives + 1);
        showBanner('1 life restored', duration: 1.2);
        break;
      case SupportOptionType.shield:
        shieldCharges = 1;
        showBanner('Shield membrane primed', duration: 1.2);
        break;
      case SupportOptionType.magnet:
        break;
      case SupportOptionType.soften:
        softenNextRound = true;
        showBanner('Next round opening softened', duration: 1.2);
        break;
    }
    notifyUi();
  }

  void buyWeapon(WeaponType weapon) {
    final state = weaponStates[weapon]!;
    if (state.unlocked || credits < weapon.purchaseCost || weaponPathLocked) {
      return;
    }
    credits -= weapon.purchaseCost;
    state.unlocked = true;
    activeWeapon = weapon;
    lockedWeaponChoice = weapon;
    for (final other in WeaponType.values) {
      if (other != weapon && other != WeaponType.standard) {
        weaponStates[other]!.unlocked = false;
      }
    }
    showBanner(
        '${weapon.title} chosen. Future special rounds unlock mini-weapons.',
        duration: 3.0);
    notifyUi();
  }

  void buyWeaponSpecialUpgrade(WeaponType weapon) {
    final state = weaponStates[weapon]!;
    state.specialLevel += 1;
    showBanner('${weapon.title} upgraded to Lv.${state.specialLevel}',
        duration: 2.2);
  }

  void skipLessonUpgrade() {
    closeLevelOverlay();
  }

  void closeLevelOverlay() {
    final hadSession = currentLessonSession != null;
    final completedCourseRound =
        hadSession && !masteryMode && lessonCursor >= lessonSequence.length - 1;
    currentLessonSession = null;
    pausedForLevel = false;
    overlays.remove(LevelOverlay.id);

    if (completedCourseRound) {
      _recordCourseCompletion();
      openVictoryChoice();
      return;
    }

    if (hadSession &&
        !masteryMode &&
        lessonCursor < lessonSequence.length - 1) {
      lessonCursor += 1;
    }
    nextRoundPressureLevel = pendingOpeningPressureLevel;
    pendingOpeningPressureLevel = 0;
    currentRound += 1;
    _prepareRound(currentRound);
    notifyUi();
  }

  void _recordCourseCompletion() {
    if (isDeveloperMode || isTutorialMode) {
      return;
    }
    if (!courseScoreRecorded) {
      courseCompletedMeta = true;
      bestCourseScore = math.max(bestCourseScore, currentScore);
      courseScoreRecorded = true;
      _persistState();
    }
  }

  void openVictoryChoice() {
    victoryPending = true;
    pausedForMenu = true;
    overlays.add(VictoryOverlay.id);
    playSfx('victory', volume: 0.42, minGap: const Duration(milliseconds: 400));
    notifyUi();
  }

  void continueToMastery() {
    victoryPending = false;
    pausedForMenu = false;
    masteryMode = true;
    runWon = false;
    overlays.remove(VictoryOverlay.id);
    showBanner('Mastery mode unlocked', duration: 2.6);
    showContextTipOnce(
      id: 'mastery_mode',
      title: 'Mastery Mode',
      body:
          'Mastery mode shortens the recap and serves mixed-review questions while the arena pressure ramps up.',
    );
    currentRound += 1;
    _prepareRound(currentRound);
    _persistState();
    notifyUi();
  }

  void finishRunAtVictory() {
    victoryPending = false;
    pausedForMenu = false;
    overlays.remove(VictoryOverlay.id);
    runWon = true;
    _finishRun();
  }

  void _finishRun() {
    gameOver = true;
    pausedForLevel = false;
    pausedForMenu = false;
    overlays.remove(LevelOverlay.id);
    overlays.remove(PauseOverlay.id);
    overlays.remove(ContextTipOverlay.id);
    overlays.remove(TutorialOverlay.id);
    overlays.remove(TitleOverlay.id);
    overlays.remove(InteractiveTutorialOverlay.id);
    if (isDeveloperMode || isTutorialMode) {
      runWon = false;
    } else if (masteryMode) {
      bestMasteryScore = math.max(bestMasteryScore, currentScore);
    }
    if (!isDeveloperMode &&
        !isTutorialMode &&
        researchPointsEarnedThisRun == 0) {
      researchPointsEarnedThisRun = _calculateResearchPointsForRun();
      researchPoints += researchPointsEarnedThisRun;
    }
    _persistState();
    overlays.add(GameOverOverlay.id);
    _refreshMusicForState();
    notifyUi();
  }

  int _calculateResearchPointsForRun() {
    if (kills <= 0 && roundsCleared <= 0 && defeatedBossCount <= 0) {
      return 0;
    }
    final scorePoints = math.max(1, currentScore ~/ 140);
    final bossBonus = defeatedBossCount * 3;
    final roundBonus = roundsCleared ~/ 2;
    final completionBonus = runWon ? 8 : 0;
    final masteryBonus = masteryMode ? 5 : 0;
    return scorePoints +
        bossBonus +
        roundBonus +
        completionBonus +
        masteryBonus;
  }

  void onPlayerHit() {
    final currentPlayer = player;
    if (currentPlayer == null ||
        gameOver ||
        currentPlayer.invulnerableRemaining > 0) {
      return;
    }
    if (isDeveloperMode && developerInvulnerable) {
      playSfx('hit', volume: 0.42, minGap: const Duration(milliseconds: 140));
      showBanner('Developer invulnerability absorbed the hit', duration: 1.0);
      notifyUi();
      return;
    }
    if (shieldCharges > 0) {
      shieldCharges -= 1;
      currentPlayer.invulnerableRemaining = 0.35;
      playSfx('hit', volume: 0.5, minGap: const Duration(milliseconds: 140));
      showBanner('Shield membrane absorbed the hit', duration: 1.2);
      notifyUi();
      return;
    }
    playSfx('hit', volume: 0.8, minGap: const Duration(milliseconds: 140));
    lives -= 1;
    if (lives <= 0) {
      lives = 0;
      _finishRun();
      return;
    }

    currentPlayer.position = Vector2(size.x / 2 - currentPlayer.size.x / 2,
        size.y / 2 - currentPlayer.size.y / 2);
    currentPlayer.invulnerableRemaining = 1.5;
    for (final enemy in enemyRegistry.toList()) {
      if (enemy.center.distanceTo(currentPlayer.center) < 130) {
        enemy.removeFromParent();
      }
    }
    notifyUi();
  }

  void _handleManualCollisions({bool rebuildGrid = true}) {
    final currentPlayer = player;
    if (currentPlayer == null) {
      return;
    }
    if (rebuildGrid) {
      _rebuildEnemyCollisionGrid();
    }
    final playerRect = currentPlayer.rect;
    if (currentPlayer.invulnerableRemaining <= 0) {
      for (final enemy in _enemyCandidatesForRect(playerRect)) {
        if (playerRect.overlaps(enemy.rect)) {
          onPlayerHit();
          return;
        }
      }
      for (final boss in bossRegistry.toList()) {
        if (playerRect.overlaps(boss.contactRect)) {
          onPlayerHit();
          return;
        }
      }
      for (final projectile in enemyProjectileRegistry.toList()) {
        if (playerRect.overlaps(projectile.rect)) {
          projectile.removeFromParent();
          onPlayerHit();
          return;
        }
      }
    }

    for (final bullet in bulletRegistry.toList()) {
      var handled = false;
      for (final enemy in _enemyCandidatesForRect(bullet.rect)) {
        if (bullet.rect.overlaps(enemy.rect)) {
          enemy.takeDamage(bullet.damage);
          if (!bullet.registerHit()) {
            bullet.removeFromParent();
          }
          handled = true;
          break;
        }
      }
      if (handled) {
        continue;
      }
      for (final boss in bossRegistry.toList()) {
        if (bullet.rect.overlaps(boss.hitRect)) {
          boss.takeDamage(bullet.damage);
          if (!bullet.registerHit()) {
            bullet.removeFromParent();
          }
          break;
        }
      }
    }

    for (final coin in coinRegistry.toList()) {
      if (playerRect.overlaps(coin.rect)) {
        addCredits(coin.value);
        coin.removeFromParent();
      }
    }

    for (final sample in sampleRegistry.toList()) {
      if (playerRect.overlaps(sample.rect)) {
        collectSample(sample.value,
            banksForNextRound: sample.banksForNextRound);
        sample.removeFromParent();
      }
    }

    for (final pickup in pickupRegistry.toList()) {
      if (playerRect.overlaps(pickup.rect)) {
        _grantPickup(pickup.pickupType);
        pickup.removeFromParent();
      }
    }
  }

  void _rebuildEnemyCollisionGrid() {
    _enemyCollisionGrid.clear();
    for (final enemy in enemyRegistry) {
      final rect = enemy.rect.inflate(8);
      final minCellX = (rect.left / _enemyCollisionCellSize).floor();
      final maxCellX = (rect.right / _enemyCollisionCellSize).floor();
      final minCellY = (rect.top / _enemyCollisionCellSize).floor();
      final maxCellY = (rect.bottom / _enemyCollisionCellSize).floor();
      for (var cellX = minCellX; cellX <= maxCellX; cellX++) {
        for (var cellY = minCellY; cellY <= maxCellY; cellY++) {
          final key = math.Point<int>(cellX, cellY);
          (_enemyCollisionGrid[key] ??= <EnemyComponent>[]).add(enemy);
        }
      }
    }
  }

  Iterable<EnemyComponent> _enemyCandidatesForRect(Rect rect) sync* {
    if (_enemyCollisionGrid.isEmpty) {
      yield* enemyRegistry;
      return;
    }
    final query = rect.inflate(10);
    final minCellX = (query.left / _enemyCollisionCellSize).floor();
    final maxCellX = (query.right / _enemyCollisionCellSize).floor();
    final minCellY = (query.top / _enemyCollisionCellSize).floor();
    final maxCellY = (query.bottom / _enemyCollisionCellSize).floor();
    final seen = <EnemyComponent>{};
    for (var cellX = minCellX; cellX <= maxCellX; cellX++) {
      for (var cellY = minCellY; cellY <= maxCellY; cellY++) {
        final bucket = _enemyCollisionGrid[math.Point<int>(cellX, cellY)];
        if (bucket == null) {
          continue;
        }
        for (final enemy in bucket) {
          if (seen.add(enemy)) {
            yield enemy;
          }
        }
      }
    }
  }

  Iterable<EnemyComponent> _enemyCandidatesForCircle(
    Vector2 center,
    double radius,
  ) {
    return _enemyCandidatesForRect(
      Rect.fromCircle(center: Offset(center.x, center.y), radius: radius),
    );
  }

  bool damageThreatsInCircle(
    Vector2 center,
    double radius,
    int damage, {
    Set<int>? alreadyHit,
    double knockback = 0,
  }) {
    var hit = false;
    final radiusSq = radius * radius;
    for (final enemy in _enemyCandidatesForCircle(center, radius).toList()) {
      final id = identityHashCode(enemy);
      if (alreadyHit != null && alreadyHit.contains(id)) {
        continue;
      }
      if (enemy.center.distanceToSquared(center) <= radiusSq) {
        enemy.takeDamage(damage);
        if (knockback > 0 && enemy.health > 0) {
          _pushEnemyFromPoint(enemy, center, knockback);
        }
        alreadyHit?.add(id);
        hit = true;
      }
    }
    for (final boss in bossRegistry.toList()) {
      final id = identityHashCode(boss);
      if (alreadyHit != null && alreadyHit.contains(id)) {
        continue;
      }
      final effectiveRadius = radius + boss.hitRadius;
      if (boss.center.distanceToSquared(center) <=
          effectiveRadius * effectiveRadius) {
        boss.takeDamage(damage);
        alreadyHit?.add(id);
        hit = true;
      }
    }
    return hit;
  }

  bool damageThreatsInArc({
    required Vector2 center,
    required Vector2 direction,
    required double radius,
    required double dotThreshold,
    required int damage,
    Set<int>? alreadyHit,
    double knockback = 0,
  }) {
    var hit = false;
    final normalizedDirection =
        direction.length2 == 0 ? Vector2(1, 0) : direction.normalized();
    for (final enemy in _enemyCandidatesForCircle(center, radius).toList()) {
      final id = identityHashCode(enemy);
      if (alreadyHit != null && alreadyHit.contains(id)) {
        continue;
      }
      final delta = enemy.center - center;
      if (delta.length <= radius &&
          delta.normalized().dot(normalizedDirection) >= dotThreshold) {
        enemy.takeDamage(damage);
        if (knockback > 0 && enemy.health > 0) {
          _pushEnemyAlong(enemy, normalizedDirection, knockback);
        }
        alreadyHit?.add(id);
        hit = true;
      }
    }
    for (final boss in bossRegistry.toList()) {
      final id = identityHashCode(boss);
      if (alreadyHit != null && alreadyHit.contains(id)) {
        continue;
      }
      final delta = boss.center - center;
      if (delta.length <= radius + boss.hitRadius &&
          delta.normalized().dot(normalizedDirection) >= dotThreshold) {
        boss.takeDamage(damage);
        alreadyHit?.add(id);
        hit = true;
      }
    }
    return hit;
  }

  void _pushEnemyFromPoint(
    EnemyComponent enemy,
    Vector2 source,
    double distance,
  ) {
    final delta = enemy.center - source;
    final direction = delta.length2 == 0 ? Vector2(1, 0) : delta.normalized();
    _pushEnemyAlong(enemy, direction, distance);
  }

  void _pushEnemyAlong(
    EnemyComponent enemy,
    Vector2 direction,
    double distance,
  ) {
    if (direction.length2 == 0 || distance <= 0) {
      return;
    }
    final offset = direction.normalized() * distance;
    enemy.position += offset;
    enemy.position.x = enemy.position.x
        .clamp(0.0, math.max(0.0, size.x - enemy.size.x))
        .toDouble();
    enemy.position.y = enemy.position.y
        .clamp(playAreaTop, math.max(playAreaTop, size.y - enemy.size.y))
        .toDouble();
  }

  void refreshMiniWeaponAttachments() {
    for (final component
        in children.whereType<MiniWeaponAttachmentComponent>().toList()) {
      component.removeFromParent();
    }
    final rhythmState = miniWeaponStates[MiniWeaponType.rhythmRing]!;
    final lineDriveLevel = miniWeaponLevel(MiniWeaponType.lineDrive);
    if (lineDriveLevel > 0) {
      final evolved = isMiniWeaponEvolved(MiniWeaponType.lineDrive);
      add(
        LineDriveComponent(
          level: lineDriveLevel,
          evolved: evolved,
          branchId: miniWeaponStates[MiniWeaponType.lineDrive]!.branchId,
          tint: const Color(0xFF8EF6C1),
          damage: 1 + (lineDriveLevel + 1) ~/ 3 + (evolved ? 1 : 0),
          sizeValue: 34 + lineDriveLevel.toDouble() * 5.5 + (evolved ? 10 : 0),
        ),
      );
    }

    final snapPrismLevel = miniWeaponLevel(MiniWeaponType.snapPrism);
    if (snapPrismLevel > 0) {
      final evolved = isMiniWeaponEvolved(MiniWeaponType.snapPrism);
      add(
        SnapPrismComponent(
          level: snapPrismLevel,
          evolved: evolved,
          branchId: miniWeaponStates[MiniWeaponType.snapPrism]!.branchId,
          tint: const Color(0xFFBDEBFF),
          damage: 1 + (snapPrismLevel + 1) ~/ 3 + (evolved ? 1 : 0),
        ),
      );
    }

    if (rhythmState.level > 0 && rhythmState.branchId == 'orbit_pulse') {
      final evolved = isMiniWeaponEvolved(MiniWeaponType.rhythmRing);
      final orbitCount = evolved ? 4 : 3;
      for (int index = 0; index < orbitCount; index++) {
        add(
          OrbitCellComponent(
            orbitIndex: index,
            orbitCount: orbitCount,
            radius: 34 + rhythmState.level * 5.5 + (evolved ? 12 : 0),
            speedFactor: 2.15 + rhythmState.level * 0.14,
            tint: const Color(0xFFFFD89C),
            damage: 1 + rhythmState.level ~/ 3 + (evolved ? 1 : 0),
            sizeValue: evolved ? 14 : 12,
          ),
        );
      }
    }
  }

  void _updateMiniWeaponSystems(double dt) {
    final currentPlayer = player;
    if (currentPlayer == null || !canPlayerAttack) {
      return;
    }
    for (final key in _miniWeaponTimers.keys) {
      _miniWeaponTimers[key] = (_miniWeaponTimers[key] ?? 0) + dt;
    }

    final sentryLevel = miniWeaponLevel(MiniWeaponType.sentryPod);
    if (sentryLevel > 0) {
      final evolved = isMiniWeaponEvolved(MiniWeaponType.sentryPod);
      final branchId = miniWeaponStates[MiniWeaponType.sentryPod]!.branchId;
      final needleNest = branchId == 'needle_nest';
      final mortarNest = branchId == 'mortar_nest';
      final interval = math.max(
        needleNest ? 1.90 : 2.15,
        3.55 - sentryLevel * 0.19 - (needleNest ? 0.18 : 0),
      );
      if ((_miniWeaponTimers[MiniWeaponType.sentryPod] ?? 0) >= interval) {
        _miniWeaponTimers[MiniWeaponType.sentryPod] = 0;
        final anchor = _dropMiniWeaponAnchor(currentPlayer);
        add(
          SentryPodComponent(
            position: anchor - Vector2.all(12),
            damage: 1 +
                sentryLevel ~/ 3 +
                (evolved ? 1 : 0) +
                (needleNest ? 1 : 0) +
                (sentryLevel <= 2 ? 1 : 0),
            lifetime: 7.2 + sentryLevel * 1.25 + (evolved ? 1.8 : 0),
            fireInterval: math.max(
                0.34,
                0.82 -
                    sentryLevel * 0.05 -
                    (evolved ? 0.08 : 0) -
                    (needleNest ? 0.07 : 0)),
            range: 220 +
                sentryLevel * 24 +
                (evolved ? 46 : 0) +
                (needleNest ? 36 : 0),
            evolved: evolved,
            branchId: branchId,
          ),
        );
        if (sentryLevel >= 7 &&
            !adaptivePerformanceActive &&
            !reducedEffectsActive) {
          final flankAnchor =
              _dropMiniWeaponAnchor(currentPlayer, distance: 42);
          add(
            SentryPodComponent(
              position: flankAnchor - Vector2.all(12),
              damage: math.max(1, sentryLevel ~/ 2 + (evolved ? 1 : 0)),
              lifetime: 5.8 + sentryLevel * 1.0 + (evolved ? 1.2 : 0),
              fireInterval: math.max(
                  0.38,
                  0.94 -
                      sentryLevel * 0.07 -
                      (evolved ? 0.06 : 0) -
                      (needleNest ? 0.06 : 0)),
              range: 185 + sentryLevel * 20 + (evolved ? 34 : 0),
              evolved: evolved,
              branchId: branchId,
            ),
          );
        }
        if (mortarNest) {
          add(
            BioMineComponent(
              position: anchor - Vector2.all(8),
              damage: 1 + sentryLevel ~/ 3 + (evolved ? 1 : 0),
              triggerRadius: 46 + sentryLevel * 5 + (evolved ? 12 : 0),
            ),
          );
        }
      }
    }

    final beaconLevel = miniWeaponLevel(MiniWeaponType.burstBeacon);
    if (beaconLevel > 0) {
      final evolved = isMiniWeaponEvolved(MiniWeaponType.burstBeacon);
      final interval = math.max(2.8, 5.0 - beaconLevel * 0.45);
      if ((_miniWeaponTimers[MiniWeaponType.burstBeacon] ?? 0) >= interval) {
        _miniWeaponTimers[MiniWeaponType.burstBeacon] = 0;
        add(
          BurstBeaconComponent(
            position: _dropMiniWeaponAnchor(currentPlayer, distance: 34) -
                Vector2.all(11),
            damage: 1 + beaconLevel ~/ 2 + (evolved ? 1 : 0),
            lifetime: 6.5 + beaconLevel + (evolved ? 1.4 : 0),
            fireInterval: math.max(
                0.62, 1.22 - beaconLevel * 0.10 - (evolved ? 0.10 : 0)),
            projectileSpeed: 250 + beaconLevel * 24 + (evolved ? 60 : 0),
            includeDiagonals: evolved || beaconLevel >= 3,
            evolved: evolved,
          ),
        );
      }
    }

    final rhythmLevel = miniWeaponLevel(MiniWeaponType.rhythmRing);
    if (rhythmLevel > 0) {
      final evolved = isMiniWeaponEvolved(MiniWeaponType.rhythmRing);
      final branchId = miniWeaponStates[MiniWeaponType.rhythmRing]!.branchId;
      final tightPulse = branchId == 'tight_pulse';
      final interval = math.max(tightPulse ? 0.82 : 1.15,
          2.35 - rhythmLevel * 0.22 - (tightPulse ? 0.30 : 0));
      if ((_miniWeaponTimers[MiniWeaponType.rhythmRing] ?? 0) >= interval) {
        _miniWeaponTimers[MiniWeaponType.rhythmRing] = 0;
        playSfx('ring',
            volume: 0.48, minGap: const Duration(milliseconds: 220));
        add(
          PulseRingWaveComponent(
            centerPoint: currentPlayer.center.clone(),
            tint: const Color(0xFFFFD166),
            damage: 1 +
                (rhythmLevel + 1) ~/ 3 +
                (evolved ? 1 : 0) +
                (tightPulse ? 1 : 0),
            maxRadius: 132 +
                rhythmLevel * 17 +
                (evolved ? 26 : 0) +
                (tightPulse ? -18 : 0),
            knockback: 12 + rhythmLevel * 2.2 + (tightPulse ? 4 : 0),
          ),
        );
        if ((evolved || rhythmLevel >= 6) &&
            !tightPulse &&
            !adaptivePerformanceActive &&
            !reducedEffectsActive) {
          add(
            PulseRingWaveComponent(
              centerPoint: currentPlayer.center.clone(),
              tint: const Color(0xFFFFE7B0),
              damage: 1,
              maxRadius: 96 + rhythmLevel * 11,
              knockback: 8.0 + rhythmLevel,
            ),
          );
        }
      }
    }

    final cadenceLevel = miniWeaponLevel(MiniWeaponType.crossCadence);
    if (cadenceLevel > 0) {
      final evolved = isMiniWeaponEvolved(MiniWeaponType.crossCadence);
      final interval = math.max(
        0.95,
        (cadenceLevel == 1 ? 1.58 : 1.88) - cadenceLevel * 0.15,
      );
      if ((_miniWeaponTimers[MiniWeaponType.crossCadence] ?? 0) >= interval) {
        _miniWeaponTimers[MiniWeaponType.crossCadence] = 0;
        _spawnCrossCadenceBurst(currentPlayer.center.clone(), cadenceLevel,
            evolved: evolved,
            branchId: miniWeaponStates[MiniWeaponType.crossCadence]!.branchId);
      }
    }
  }

  Vector2 _dropMiniWeaponAnchor(PlayerComponent currentPlayer,
      {double distance = 28}) {
    final facing = currentPlayer.lastFacingDirection;
    final backward =
        facing.length2 == 0 ? Vector2(-1, 0) : -facing.normalized();
    final lateral =
        Vector2(-backward.y, backward.x) * ((rng.nextDouble() - 0.5) * 20);
    return currentPlayer.center + backward * distance + lateral;
  }

  void _spawnCrossCadenceBurst(
    Vector2 center,
    int level, {
    required bool evolved,
    String? branchId,
  }) {
    playSfx('cross', volume: 0.38, minGap: const Duration(milliseconds: 160));
    final lattice = branchId == 'lattice';
    final doubleTap = branchId == 'double_tap';
    final bonusVolley = level >= 6;
    final volleyCount = doubleTap ? 2 : 1;
    final basePierce = (level >= 4 ? 1 : 0) + (evolved ? 1 : 0);
    final baseDamage = 2 + level ~/ 2 + (evolved ? 1 : 0);
    for (int volley = 0; volley < volleyCount; volley++) {
      final directions = <Vector2>[
        Vector2(1, 0),
        Vector2(-1, 0),
        Vector2(0, 1),
        Vector2(0, -1),
        if (lattice || evolved || level >= 3) ...[
          Vector2(1, 1),
          Vector2(-1, 1),
          Vector2(1, -1),
          Vector2(-1, -1),
        ],
      ];
      final angleOffset = doubleTap && volley == 1 ? math.pi / 10 : 0.0;
      for (final direction in directions) {
        final volleyDirection = angleOffset == 0
            ? direction
            : _rotateVector(direction, angleOffset);
        add(
          _makeBullet(
            origin: center.clone() - Vector2.all(4),
            direction: volleyDirection,
            damage: level == 1 ? baseDamage + 1 : baseDamage,
            speed:
                395 + level * 26 + (evolved ? 52 : 0) - (volley == 1 ? 24 : 0),
            bulletSize: 9.5 + level * 0.45 + (evolved ? 1.0 : 0),
            pierce: basePierce + (lattice ? 1 : 0),
            color:
                volley == 0 ? const Color(0xFFBDE0FE) : const Color(0xFFD7F3FF),
            visualStyle: BulletVisualStyle.cross,
          ),
        );
      }
      if (bonusVolley) {
        for (final direction in <Vector2>[
          Vector2(1, 0),
          Vector2(-1, 0),
          Vector2(0, 1),
          Vector2(0, -1),
        ]) {
          add(
            _makeBullet(
              origin: center.clone() - Vector2.all(4),
              direction: _rotateVector(direction, math.pi / 8),
              damage: math.max(1, level ~/ 3 + (evolved ? 1 : 0)),
              speed: 310 + level * 18,
              bulletSize: 7 + level * 0.3,
              pierce: basePierce,
              color: const Color(0xFFE3F8FF),
              visualStyle: BulletVisualStyle.cross,
            ),
          );
        }
      }
    }
  }

  void developerAddCoins([int amount = 100]) {
    if (!isDeveloperMode) {
      return;
    }
    showBanner('Coins are disabled in this build', duration: 1.2);
    notifyUi();
  }

  void developerRestoreLives() {
    if (!isDeveloperMode) {
      return;
    }
    lives = 3;
    player?.invulnerableRemaining = 1.0;
    showBanner('Developer lives restored', duration: 1.2);
    notifyUi();
  }

  void developerToggleInvulnerability() {
    if (!isDeveloperMode) {
      return;
    }
    developerInvulnerable = !developerInvulnerable;
    showBanner(
      developerInvulnerable
          ? 'Developer invulnerability on'
          : 'Developer invulnerability off',
      duration: 1.2,
    );
    notifyUi();
  }

  void developerGrantPickup(PickupType type) {
    if (!isDeveloperMode) {
      return;
    }
    _grantPickup(type);
  }

  void developerClearWave() {
    if (!isDeveloperMode || !runStarted || onTitleScreen) {
      return;
    }
    if (overlays.isActive(PauseOverlay.id)) {
      closePauseSummary();
    }
    _removeActiveThreats();
    if (roundBossRequired) {
      _beginCleanup(fromBoss: true);
    } else {
      _beginCleanup();
    }
    notifyUi();
  }

  void developerForceBossGate() {
    if (!isDeveloperMode) {
      return;
    }
    if (overlays.isActive(PauseOverlay.id)) {
      closePauseSummary();
    }
    final forcedRound = ((currentRound + 2) ~/ 3) * 3;
    currentRound = forcedRound;
    _prepareRound(currentRound);
    _removeActiveThreats();
    roundBossRequired = true;
    roundBossSpawned = false;
    roundPhase = RoundFlowPhase.bossPrelude;
    bossPreludeRemaining = 0.1;
    showBanner('Developer boss gate forced', duration: 1.4);
    notifyUi();
  }

  void developerSpawnSpecificBoss(BossType bossType) {
    if (!isDeveloperMode) {
      return;
    }
    if (overlays.isActive(PauseOverlay.id)) {
      closePauseSummary();
    }
    if (!currentRoundUsesWeaponShop) {
      currentRound = ((currentRound + 2) ~/ 3) * 3;
      _prepareRound(currentRound);
    }
    _removeActiveThreats();
    roundBossRequired = true;
    roundBossSpawned = true;
    roundPhase = RoundFlowPhase.bossFight;
    _spawnSpecificBoss(bossType);
    showBanner('Developer spawned ${bossType.title}', duration: 1.4);
    notifyUi();
  }

  void _removeActiveThreats() {
    for (final enemy in enemyRegistry.toList()) {
      enemy.removeFromParent();
    }
    for (final boss in bossRegistry.toList()) {
      boss.removeFromParent();
    }
    for (final projectile in enemyProjectileRegistry.toList()) {
      projectile.removeFromParent();
    }
  }

  void developerOpenShopResults() {
    if (!isDeveloperMode || onTitleScreen) {
      return;
    }
    closePauseSummary();
    if (currentLessonSession == null) {
      _openRoundSummary();
    }
    final session = currentLessonSession;
    if (session == null) {
      return;
    }
    session.correctCount = 3;
    _finalizeLessonSession();
    notifyUi();
  }

  void developerSkipLessonFlow() {
    if (!isDeveloperMode) {
      return;
    }
    if (currentLessonSession != null) {
      closeLevelOverlay();
    }
  }

  void developerSetWeaponPath(WeaponType weapon) {
    if (!isDeveloperMode) {
      return;
    }
    for (final state in weaponStates.values) {
      state.unlocked =
          state.type == WeaponType.standard || state.type == weapon;
    }
    activeWeapon = weapon;
    lockedWeaponChoice = weapon == WeaponType.standard ? null : weapon;
    weaponStates[weapon]!.unlocked = true;
    showBanner('Developer set weapon path to ${weapon.title}', duration: 1.2);
    notifyUi();
  }

  void developerIncreaseWeaponSpecial([WeaponType? weapon]) {
    if (!isDeveloperMode) {
      return;
    }
    final target = weapon ?? activeWeapon;
    weaponStates[target]!.unlocked = true;
    weaponStates[target]!.specialLevel += 1;
    showBanner('${target.title} special increased', duration: 1.2);
    notifyUi();
  }

  void developerToggleMiniWeapon(MiniWeaponType type) {
    if (!isDeveloperMode) {
      return;
    }
    final state = miniWeaponStates[type]!;
    if (!state.unlocked) {
      if (equippedMiniWeapons.length >= maxMiniWeaponSlots) {
        showBanner('Mini-weapon slots are full', duration: 1.2);
        return;
      }
      state.level = 1;
      state.equipped = true;
      _primeMiniWeapon(type);
    } else if (state.equipped) {
      state.equipped = false;
    } else {
      if (equippedMiniWeapons.length >= maxMiniWeaponSlots) {
        showBanner('Mini-weapon slots are full', duration: 1.2);
        return;
      }
      state.equipped = true;
      _primeMiniWeapon(type);
    }
    refreshMiniWeaponAttachments();
    notifyUi();
  }

  void developerIncreaseMiniWeaponLevel(MiniWeaponType type) {
    if (!isDeveloperMode) {
      return;
    }
    final state = miniWeaponStates[type]!;
    if (!state.unlocked) {
      if (equippedMiniWeapons.length >= maxMiniWeaponSlots) {
        showBanner('Mini-weapon slots are full', duration: 1.2);
        return;
      }
      state.level = 1;
      state.equipped = true;
    } else {
      state.level = math.min(miniWeaponLevelCap, state.level + 1);
    }
    _primeMiniWeapon(type);
    refreshMiniWeaponAttachments();
    notifyUi();
  }

  void openCombatLevelChoice() {
    if (roundBossRequired || overlays.isActive(CombatLevelOverlay.id)) {
      return;
    }
    pausedForCombatLevel = true;
    currentCombatOffers = buildCombatUpgradeOffers(
      rng: rng,
      activeWeapon: activeWeapon,
      supportWeaponLevels: {
        for (final entry in miniWeaponStates.entries)
          entry.key: entry.value.level,
      },
      passiveLevels: passiveLevels,
    );
    overlays.add(CombatLevelOverlay.id);
    playSfx('level', volume: 0.34, minGap: const Duration(milliseconds: 180));
    notifyUi();
  }

  void chooseCombatUpgrade(CombatUpgradeOffer offer) {
    switch (offer.kind) {
      case CombatUpgradeKind.tempo:
        break;
      case CombatUpgradeKind.stride:
        break;
      case CombatUpgradeKind.vacuum:
        break;
      case CombatUpgradeKind.force:
        break;
      case CombatUpgradeKind.primaryAmp:
        break;
      case CombatUpgradeKind.supportAmp:
        final type = offer.supportWeapon;
        if (type != null) {
          final state = miniWeaponStates[type]!;
          state.level =
              math.min(miniWeaponLevelCap, math.max(1, state.level + 1));
          state.equipped = true;
          _primeMiniWeapon(type);
          refreshMiniWeaponAttachments();
        }
        break;
      case CombatUpgradeKind.passiveAmp:
        final passive = offer.passive;
        if (passive != null) {
          passiveLevels[passive] =
              math.min(5, math.max(1, (passiveLevels[passive] ?? 0) + 1));
        }
        break;
    }
    overlays.remove(CombatLevelOverlay.id);
    pausedForCombatLevel = false;
    final branchReady = switch (offer.kind) {
      CombatUpgradeKind.primaryAmp =>
        activeWeaponState.specialLevel >= miniWeaponBranchUnlockLevel &&
            activeWeaponState.branchId == null,
      CombatUpgradeKind.supportAmp => offer.supportWeapon != null &&
          miniWeaponStates[offer.supportWeapon]!.level >=
              miniWeaponBranchUnlockLevel &&
          miniWeaponStates[offer.supportWeapon]!.branchId == null,
      _ => false,
    };
    showBanner(
      branchReady
          ? '${offer.title} strengthened - specialization ready'
          : '${offer.title} strengthened',
      duration: 1.2,
    );
    notifyUi();
  }

  void openPauseSummary() {
    if (gameOver ||
        pausedForLevel ||
        onTitleScreen ||
        overlays.isActive(PauseOverlay.id)) {
      return;
    }
    pausedForMenu = true;
    overlays.add(PauseOverlay.id);
    notifyUi();
  }

  void closePauseSummary() {
    overlays.remove(PauseOverlay.id);
    if (!overlays.isActive(TutorialOverlay.id) &&
        !overlays.isActive(ContextTipOverlay.id)) {
      pausedForMenu = false;
    }
    notifyUi();
  }

  void openTutorial() {
    if (overlays.isActive(TutorialOverlay.id)) {
      return;
    }
    if (!onTitleScreen) {
      pausedForMenu = true;
      overlays.remove(PauseOverlay.id);
    }
    overlays.add(TutorialOverlay.id);
    notifyUi();
  }

  void closeTutorial() {
    if (!overlays.isActive(TutorialOverlay.id)) {
      return;
    }
    overlays.remove(TutorialOverlay.id);
    tutorialSeen = true;
    _persistState();
    final shouldStart = startAfterTutorial;
    startAfterTutorial = false;
    if (shouldStart) {
      startFromTitle();
      return;
    }
    if (!onTitleScreen && !overlays.isActive(ContextTipOverlay.id)) {
      pausedForMenu = false;
    }
    notifyUi();
  }

  void showContextTipOnce({
    required String id,
    required String title,
    required String body,
  }) {
    if (_shownTipIds.contains(id) || onTitleScreen || gameOver) {
      return;
    }
    _shownTipIds.add(id);
    currentTipTitle = title;
    currentTipBody = body;
    pausedForMenu = true;
    overlays.add(ContextTipOverlay.id);
    notifyUi();
  }

  void closeContextTip() {
    overlays.remove(ContextTipOverlay.id);
    if (!overlays.isActive(TutorialOverlay.id) && !victoryPending) {
      pausedForMenu = false;
    }
    notifyUi();
  }

  void notifyUi() {
    uiTick.value++;
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keysPressed
      ..clear()
      ..addAll(keysPressed);

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      if (onTitleScreen) {
        handleTitleStart();
      }
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      triggerDash();
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      if (overlays.isActive(TutorialOverlay.id)) {
        closeTutorial();
      } else if (overlays.isActive(ContextTipOverlay.id)) {
        closeContextTip();
      } else if (overlays.isActive(InteractiveTutorialOverlay.id)) {
        finishInteractiveTutorial();
      } else if (overlays.isActive(PauseOverlay.id)) {
        closePauseSummary();
      } else if (isGameplayActive) {
        openPauseSummary();
      }
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyP) {
      if (overlays.isActive(PauseOverlay.id)) {
        closePauseSummary();
      } else if (isGameplayActive) {
        openPauseSummary();
      }
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyR) {
      if (gameOver) {
        restartGame();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.handled;
  }
}

class PlayerComponent extends PositionComponent
    with HasGameReference<SquareShooterGame> {
  PlayerComponent({required super.position}) : super(size: Vector2.all(28));

  double baseSpeed = 210;
  double dashSpeed = 540;
  double dashCooldown = 2.0;
  double dashCooldownRemaining = 0;
  double dashDuration = 0.16;
  double dashTimeRemaining = 0;
  double fireCooldown = 0.34;
  double reloadMultiplier = 1.0;
  double fireCooldownRemaining = 0;
  double invulnerableRemaining = 0;
  int bulletDamage = 1;
  Vector2 _lastMovementDirection = Vector2(1, 0);
  Vector2 _lastAimDirection = Vector2(1, 0);

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);
  @override
  Vector2 get center => position + size / 2;
  Vector2 get lastFacingDirection => _lastMovementDirection.length2 > 0
      ? _lastMovementDirection.clone()
      : _lastAimDirection.clone();

  @override
  void render(Canvas canvas) {
    final flashing =
        invulnerableRemaining > 0 && (invulnerableRemaining * 8).floor().isEven;
    final frame = game.selectedCharacterFrame;
    final primary = flashing
        ? const Color(0xFFE5F5EC)
        : dashTimeRemaining > 0
            ? const Color(0xFFB7E4C7)
            : switch (frame) {
                CharacterFrame.bioSquare => const Color(0xFF2D6A4F),
                CharacterFrame.lymphocyteScout => const Color(0xFF8EECF5),
                CharacterFrame.macrophageGuard => const Color(0xFFFFB703),
                CharacterFrame.signalPrism => const Color(0xFFFF70A6),
              };
    final accent = switch (frame) {
      CharacterFrame.bioSquare => const Color(0xFFD8F3DC),
      CharacterFrame.lymphocyteScout => const Color(0xFFE3FAFC),
      CharacterFrame.macrophageGuard => const Color(0xFFFFF1BF),
      CharacterFrame.signalPrism => const Color(0xFFFFD6E8),
    };
    final outline = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final fill = Paint()..color = primary;
    final corePaint = Paint()..color = const Color(0xFF081C15);
    final centerOffset = Offset(size.x / 2, size.y / 2);
    switch (frame) {
      case CharacterFrame.bioSquare:
        final body = RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(8));
        canvas.drawRRect(body, fill);
        canvas.drawRRect(body, outline);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: centerOffset, width: 8, height: 8),
            const Radius.circular(2),
          ),
          corePaint,
        );
      case CharacterFrame.lymphocyteScout:
        canvas.drawOval(Rect.fromLTWH(1, 1, size.x - 2, size.y - 2), fill);
        canvas.drawOval(Rect.fromLTWH(1, 1, size.x - 2, size.y - 2), outline);
        canvas.drawCircle(centerOffset.translate(2, -1), 5.2, corePaint);
        canvas.drawCircle(
          centerOffset.translate(-5, 4),
          2.4,
          Paint()..color = accent.withValues(alpha: 0.65),
        );
      case CharacterFrame.macrophageGuard:
        final path = Path()
          ..moveTo(size.x * 0.50, 0)
          ..lineTo(size.x * 0.92, size.y * 0.24)
          ..lineTo(size.x * 0.84, size.y * 0.78)
          ..lineTo(size.x * 0.50, size.y)
          ..lineTo(size.x * 0.16, size.y * 0.78)
          ..lineTo(size.x * 0.08, size.y * 0.24)
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, outline);
        canvas.drawCircle(centerOffset, 5.6, corePaint);
        canvas.drawLine(
          Offset(size.x * 0.26, size.y * 0.32),
          Offset(size.x * 0.74, size.y * 0.68),
          Paint()
            ..color = accent.withValues(alpha: 0.55)
            ..strokeWidth = 2,
        );
      case CharacterFrame.signalPrism:
        final path = Path()
          ..moveTo(size.x * 0.50, 0)
          ..lineTo(size.x, size.y * 0.50)
          ..lineTo(size.x * 0.50, size.y)
          ..lineTo(0, size.y * 0.50)
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, outline);
        canvas.drawCircle(centerOffset, 4.6, corePaint);
        canvas.drawLine(
          Offset(size.x * 0.50, 4),
          Offset(size.x * 0.50, size.y - 4),
          Paint()
            ..color = accent.withValues(alpha: 0.62)
            ..strokeWidth = 1.6,
        );
        canvas.drawLine(
          Offset(4, size.y * 0.50),
          Offset(size.x - 4, size.y * 0.50),
          Paint()
            ..color = accent.withValues(alpha: 0.45)
            ..strokeWidth = 1.2,
        );
    }
    if (game.shieldCharges > 0) {
      final shieldPaint = Paint()
        ..color = const Color(0xFF95D5B2).withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(size.x / 2, size.y / 2),
              width: size.x * 1.7,
              height: size.y * 1.7),
          const Radius.circular(12),
        ),
        shieldPaint,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dashCooldownRemaining > 0) {
      dashCooldownRemaining = math.max(0.0, dashCooldownRemaining - dt);
    }
    if (dashTimeRemaining > 0) {
      dashTimeRemaining = math.max(0.0, dashTimeRemaining - dt);
    }
    if (fireCooldownRemaining > 0) {
      fireCooldownRemaining = math.max(0.0, fireCooldownRemaining - dt);
    }
    if (invulnerableRemaining > 0) {
      invulnerableRemaining = math.max(0.0, invulnerableRemaining - dt);
    }
    if (!game.canPlayerMove) {
      return;
    }

    final move = game.moveInput;
    if (move.length2 > 0) {
      _lastMovementDirection = move.normalized();
    }
    final speed = dashTimeRemaining > 0 ? dashSpeed : baseSpeed;
    final movementDirection = move.length2 > 0
        ? move
        : (dashTimeRemaining > 0 ? _lastMovementDirection : Vector2.zero());
    position += movementDirection * speed * dt;
    position.x =
        position.x.clamp(0.0, math.max(0.0, game.size.x - size.x)).toDouble();
    position.y = position.y
        .clamp(
            game.playAreaTop, math.max(game.playAreaTop, game.size.y - size.y))
        .toDouble();

    if (game.canPlayerAttack && fireCooldownRemaining <= 0) {
      final targetCenter = game.nearestThreatCenterTo(center);
      if (targetCenter != null) {
        final aim = targetCenter - center;
        if (aim.length2 > 0) {
          _lastAimDirection = aim.normalized();
          fireCooldownRemaining = game.fireWeapon(center - Vector2.all(4), aim);
        }
      }
    }
  }

  void tryDash() {
    if (dashCooldownRemaining > 0) {
      return;
    }
    final move = game.moveInput;
    if (move.length2 == 0 && _lastMovementDirection.length2 == 0) {
      return;
    }
    dashCooldownRemaining = dashCooldown;
    dashTimeRemaining = dashDuration;
  }
}

class EnemyComponent extends PositionComponent
    with HasGameReference<SquareShooterGame> {
  EnemyComponent({
    required this.archetype,
    required super.position,
    required super.size,
    required this.baseSpeed,
    required this.health,
    required this.rewardCoins,
    required this.canDropPickup,
    required this.splitGeneration,
    this.enhancedWeaver = false,
    this.spawnedByBoss = false,
  }) : _maxHealth = health;

  final EnemyArchetype archetype;
  final double baseSpeed;
  final int rewardCoins;
  final bool canDropPickup;
  final int splitGeneration;
  final bool enhancedWeaver;
  final bool spawnedByBoss;
  final int _maxHealth;
  int health;
  double behaviorTimer = 0;
  double runnerBurstTimer = 0;
  double hitFlash = 0;
  Vector2 splitterMoveDirection = Vector2.zero();
  Vector2 bruteMoveDirection = Vector2.zero();
  Vector2 visualDirection = Vector2(1, 0);

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);
  @override
  Vector2 get center => position + size / 2;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    game.enemyRegistry.add(this);
  }

  @override
  void onRemove() {
    game.enemyRegistry.remove(this);
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    if (game.biologyResourcePackEnabled) {
      if (game.lowCostEnemyVisuals) {
        _renderFastBiologyPack(canvas);
        return;
      }
      _renderBiologyPack(canvas);
      return;
    }
    final bodyColor = hitFlash > 0
        ? Colors.white
        : enhancedWeaver
            ? const Color(0xFF5E60CE)
            : archetype.bodyColor;
    final bodyPaint = Paint()..color = bodyColor;
    final corePaint = Paint()
      ..color = enhancedWeaver ? const Color(0xFFE0AAFF) : archetype.coreColor;
    final shell = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(7));
    if (archetype == EnemyArchetype.rainbow) {
      final rainbowColors = [
        const Color(0xFFEF476F),
        const Color(0xFFFFD166),
        const Color(0xFF06D6A0),
        const Color(0xFF118AB2),
        const Color(0xFF9B5DE5),
      ];
      final stripeWidth = size.x / rainbowColors.length;
      canvas.save();
      final clipPath = Path()..addRRect(shell);
      canvas.clipPath(clipPath);
      for (int i = 0; i < rainbowColors.length; i++) {
        canvas.drawRect(
          Rect.fromLTWH(i * stripeWidth, 0, stripeWidth + 1, size.y),
          Paint()..color = rainbowColors[i],
        );
      }
      canvas.restore();
      canvas.drawRRect(
          shell, Paint()..color = Colors.white.withValues(alpha: 0.10));
    } else {
      if (enhancedWeaver) {
        canvas.drawRRect(
          shell.inflate(5),
          Paint()..color = const Color(0xFFBDE0FE).withValues(alpha: 0.14),
        );
      }
      canvas.drawRRect(shell, bodyPaint);
    }
    final coreRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * 0.28, size.y * 0.28, size.x * 0.44, size.y * 0.44),
      const Radius.circular(3),
    );
    canvas.drawRRect(coreRect, corePaint);
    if (enhancedWeaver) {
      canvas.drawRRect(
        shell,
        Paint()
          ..color = const Color(0xFFE0AAFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
      canvas.drawLine(
        Offset(size.x * 0.22, size.y * 0.72),
        Offset(size.x * 0.78, size.y * 0.28),
        Paint()
          ..color = const Color(0xFFE0AAFF).withValues(alpha: 0.75)
          ..strokeWidth = 2,
      );
    }
    if (archetype == EnemyArchetype.splitter) {
      final crack = Paint()
        ..color = const Color(0xFF081C15)
        ..strokeWidth = 2;
      canvas.drawLine(Offset(size.x * 0.3, size.y * 0.3),
          Offset(size.x * 0.7, size.y * 0.7), crack);
      canvas.drawLine(Offset(size.x * 0.62, size.y * 0.24),
          Offset(size.x * 0.42, size.y * 0.76), crack);
    } else if (archetype == EnemyArchetype.brute &&
        bruteMoveDirection.length2 > 0) {
      final direction = bruteMoveDirection.normalized();
      final side = Offset(-direction.y, direction.x);
      final base = Offset(size.x / 2, size.y / 2);
      final arrowPaint = Paint()..color = const Color(0xFFFFE8D6);
      for (int index = 0; index < 3; index++) {
        final offsetAmount = 5.0 + index * 7.0;
        final center = Offset(
          base.dx + direction.x * offsetAmount,
          base.dy + direction.y * offsetAmount,
        );
        final tip = Offset(
          center.dx + direction.x * 5.0,
          center.dy + direction.y * 5.0,
        );
        final left = Offset(
          center.dx - direction.x * 3.0 + side.dx * 3.0,
          center.dy - direction.y * 3.0 + side.dy * 3.0,
        );
        final right = Offset(
          center.dx - direction.x * 3.0 - side.dx * 3.0,
          center.dy - direction.y * 3.0 - side.dy * 3.0,
        );
        final path = Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(left.dx, left.dy)
          ..lineTo(right.dx, right.dy)
          ..close();
        canvas.drawPath(path, arrowPaint);
      }
    }
    if (game.showEnemyHealthBars || health < _maxHealth || enhancedWeaver) {
      _drawEnemyHealthBar(canvas);
    }
  }

  void _renderFastBiologyPack(Canvas canvas) {
    final bodyColor = hitFlash > 0
        ? Colors.white
        : enhancedWeaver
            ? const Color(0xFF6C63FF)
            : archetype.bodyColor;
    final coreColor =
        enhancedWeaver ? const Color(0xFFE0AAFF) : archetype.coreColor;
    final centerOffset = Offset(size.x / 2, size.y / 2);
    final bodyPaint = Paint()..color = bodyColor;
    final corePaint = Paint()..color = coreColor.withValues(alpha: 0.92);

    canvas.drawOval(
      Rect.fromCenter(
        center: centerOffset.translate(0, size.y * 0.12),
        width: size.x * 0.86,
        height: size.y * 0.28,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );

    switch (archetype) {
      case EnemyArchetype.runner:
        final angle = math.atan2(visualDirection.y, visualDirection.x);
        canvas.save();
        canvas.translate(size.x / 2, size.y / 2);
        canvas.rotate(angle);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero,
                width: size.x * 0.96,
                height: size.y * 0.48),
            Radius.circular(size.y * 0.28),
          ),
          bodyPaint,
        );
        canvas.drawLine(
          Offset(-size.x * 0.48, 0),
          Offset(-size.x * 0.78, size.y * 0.16),
          Paint()
            ..color = coreColor.withValues(alpha: 0.75)
            ..strokeWidth = 1.8
            ..strokeCap = StrokeCap.round,
        );
        canvas.restore();
        break;
      case EnemyArchetype.stalker:
        final head = Path()
          ..moveTo(size.x * 0.50, size.y * 0.10)
          ..lineTo(size.x * 0.78, size.y * 0.34)
          ..lineTo(size.x * 0.62, size.y * 0.64)
          ..lineTo(size.x * 0.50, size.y * 0.92)
          ..lineTo(size.x * 0.38, size.y * 0.64)
          ..lineTo(size.x * 0.22, size.y * 0.34)
          ..close();
        canvas.drawPath(head, bodyPaint);
        canvas.drawLine(
          Offset(size.x * 0.50, size.y * 0.58),
          Offset(size.x * 0.50, size.y * 0.96),
          Paint()
            ..color = coreColor.withValues(alpha: 0.86)
            ..strokeWidth = 2.2
            ..strokeCap = StrokeCap.round,
        );
        break;
      case EnemyArchetype.splitter:
        canvas.drawCircle(
            Offset(size.x * 0.38, size.y * 0.50), size.x * 0.28, bodyPaint);
        canvas.drawCircle(
            Offset(size.x * 0.62, size.y * 0.50), size.x * 0.28, bodyPaint);
        break;
      case EnemyArchetype.tank:
      case EnemyArchetype.brute:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: centerOffset,
                width: size.x * 0.9,
                height: size.y * 0.78),
            Radius.circular(size.x * 0.24),
          ),
          bodyPaint,
        );
        if (archetype == EnemyArchetype.brute &&
            bruteMoveDirection.length2 > 0) {
          _drawBruteDirectionArrows(canvas, coreColor);
        }
        break;
      case EnemyArchetype.rainbow:
      case EnemyArchetype.swarm:
        canvas.drawCircle(centerOffset, size.x * 0.38, bodyPaint);
        final spikePaint = Paint()
          ..color = bodyColor.withValues(alpha: 0.76)
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i < 6; i++) {
          final angle = i * math.pi / 3;
          canvas.drawLine(
            centerOffset.translate(math.cos(angle) * size.x * 0.30,
                math.sin(angle) * size.x * 0.30),
            centerOffset.translate(math.cos(angle) * size.x * 0.48,
                math.sin(angle) * size.x * 0.48),
            spikePaint,
          );
        }
        break;
    }

    canvas.drawCircle(centerOffset, size.x * 0.13, corePaint);
    if (game.showEnemyHealthBars || health < _maxHealth || enhancedWeaver) {
      _drawEnemyHealthBar(canvas);
    }
  }

  void _renderBiologyPack(Canvas canvas) {
    final bodyColor = hitFlash > 0
        ? Colors.white
        : enhancedWeaver
            ? const Color(0xFF6C63FF)
            : archetype.bodyColor;
    final coreColor =
        enhancedWeaver ? const Color(0xFFE0AAFF) : archetype.coreColor;
    final centerOffset = Offset(size.x / 2, size.y / 2);
    final radius = size.x * 0.42;
    final time = game.arenaVisualTime + behaviorTimer;

    canvas.drawOval(
      Rect.fromCenter(
        center: centerOffset.translate(0, size.y * 0.12),
        width: size.x * 0.95,
        height: size.y * 0.36,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );
    if (enhancedWeaver) {
      canvas.drawCircle(
        centerOffset,
        size.x * 0.62,
        Paint()
          ..shader = ui.Gradient.radial(
            centerOffset,
            size.x * 0.62,
            [
              const Color(0xFFBDE0FE).withValues(alpha: 0.22),
              Colors.transparent,
            ],
          ),
      );
    }

    switch (archetype) {
      case EnemyArchetype.swarm:
        _drawSpikyVirion(
          canvas,
          centerOffset,
          radius,
          bodyColor,
          coreColor,
          spikes: enhancedWeaver ? 10 : 8,
          spin: time * 0.8,
        );
        break;
      case EnemyArchetype.runner:
        _drawFlagellatedBacterium(canvas, bodyColor, coreColor);
        break;
      case EnemyArchetype.stalker:
        _drawBacteriophage(canvas, bodyColor, coreColor);
        break;
      case EnemyArchetype.splitter:
        _drawDividingCell(canvas, bodyColor, coreColor, time);
        break;
      case EnemyArchetype.tank:
        _drawArmoredCell(canvas, bodyColor, coreColor, time);
        break;
      case EnemyArchetype.brute:
        _drawBruteCell(canvas, bodyColor, coreColor, time);
        break;
      case EnemyArchetype.rainbow:
        _drawPrismaticMutation(canvas, time);
        break;
    }

    if (enhancedWeaver) {
      final strandPaint = Paint()
        ..color = const Color(0xFFE0AAFF).withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 3; i++) {
        final y = size.y * (0.28 + i * 0.18);
        final path = Path()
          ..moveTo(size.x * 0.14, y)
          ..cubicTo(
              size.x * 0.34, y - 10, size.x * 0.56, y + 10, size.x * 0.86, y);
        canvas.drawPath(path, strandPaint);
      }
    }

    if (game.showEnemyHealthBars || health < _maxHealth || enhancedWeaver) {
      _drawEnemyHealthBar(canvas);
    }
  }

  void _drawSpikyVirion(
    Canvas canvas,
    Offset centerOffset,
    double radius,
    Color bodyColor,
    Color coreColor, {
    required int spikes,
    required double spin,
  }) {
    final spikePaint = Paint()
      ..color = bodyColor.withValues(alpha: 0.82)
      ..strokeWidth = math.max(1.5, size.x * 0.08)
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < spikes; i++) {
      final angle = spin + i * math.pi * 2 / spikes;
      canvas.drawLine(
        centerOffset.translate(
            math.cos(angle) * radius * 0.74, math.sin(angle) * radius * 0.74),
        centerOffset.translate(
            math.cos(angle) * radius * 1.18, math.sin(angle) * radius * 1.18),
        spikePaint,
      );
    }
    canvas.drawCircle(centerOffset, radius, Paint()..color = bodyColor);
    canvas.drawCircle(
      centerOffset,
      radius * 0.74,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, size.x * 0.06)
        ..color = Colors.white.withValues(alpha: 0.18),
    );
    for (var i = 0; i < 3; i++) {
      final angle = spin * 0.7 + i * math.pi * 2 / 3;
      canvas.drawCircle(
        centerOffset.translate(
          math.cos(angle) * radius * 0.34,
          math.sin(angle) * radius * 0.34,
        ),
        radius * 0.16,
        Paint()..color = coreColor.withValues(alpha: 0.95),
      );
    }
  }

  void _drawFlagellatedBacterium(
    Canvas canvas,
    Color bodyColor,
    Color coreColor,
  ) {
    final angle = math.atan2(visualDirection.y, visualDirection.x);
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(angle);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.x * 1.02,
        height: size.y * 0.50,
      ),
      Radius.circular(size.y * 0.28),
    );
    canvas.drawRRect(body.inflate(size.x * 0.08),
        Paint()..color = bodyColor.withValues(alpha: 0.24));
    canvas.drawRRect(body, Paint()..color = bodyColor);
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.24),
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(-size.x * 0.20 + i * size.x * 0.18, 0),
        size.x * 0.07,
        Paint()..color = coreColor.withValues(alpha: 0.86),
      );
    }
    final flagella = Paint()
      ..color = coreColor.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    for (var side = -1; side <= 1; side += 2) {
      final path = Path()
        ..moveTo(-size.x * 0.54, side * size.y * 0.10)
        ..cubicTo(-size.x * 0.74, side * size.y * 0.34, -size.x * 0.92,
            -side * size.y * 0.24, -size.x * 1.12, side * size.y * 0.10);
      canvas.drawPath(path, flagella);
    }
    canvas.restore();
  }

  void _drawBacteriophage(Canvas canvas, Color bodyColor, Color coreColor) {
    final headCenter = Offset(size.x * 0.50, size.y * 0.32);
    final headRadius = size.x * 0.27;
    final head = Path();
    for (var i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final point = headCenter.translate(
        math.cos(angle) * headRadius,
        math.sin(angle) * headRadius,
      );
      if (i == 0) {
        head.moveTo(point.dx, point.dy);
      } else {
        head.lineTo(point.dx, point.dy);
      }
    }
    head.close();
    canvas.drawPath(head, Paint()..color = bodyColor);
    canvas.drawPath(
      head,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = Colors.white.withValues(alpha: 0.28),
    );
    canvas.drawCircle(headCenter, headRadius * 0.34,
        Paint()..color = coreColor.withValues(alpha: 0.96));
    final tailPaint = Paint()
      ..color = coreColor.withValues(alpha: 0.82)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final tailTop = Offset(size.x * 0.50, size.y * 0.57);
    final tailBottom = Offset(size.x * 0.50, size.y * 0.82);
    canvas.drawLine(tailTop, tailBottom, tailPaint);
    canvas.drawLine(
        Offset(size.x * 0.38, size.y * 0.72), tailBottom, tailPaint);
    canvas.drawLine(
        Offset(size.x * 0.62, size.y * 0.72), tailBottom, tailPaint);
    canvas.drawLine(
        tailBottom, Offset(size.x * 0.30, size.y * 0.96), tailPaint);
    canvas.drawLine(
        tailBottom, Offset(size.x * 0.70, size.y * 0.96), tailPaint);
  }

  void _drawDividingCell(
    Canvas canvas,
    Color bodyColor,
    Color coreColor,
    double time,
  ) {
    final wobble = math.sin(time * 2.4) * size.x * 0.03;
    final left = Offset(size.x * 0.38 - wobble, size.y * 0.50);
    final right = Offset(size.x * 0.62 + wobble, size.y * 0.50);
    final cellRadius = size.x * 0.30;
    final membrane = Paint()..color = bodyColor.withValues(alpha: 0.88);
    canvas.drawCircle(left, cellRadius, membrane);
    canvas.drawCircle(right, cellRadius, membrane);
    canvas.drawCircle(left, cellRadius * 0.42,
        Paint()..color = coreColor.withValues(alpha: 0.88));
    canvas.drawCircle(right, cellRadius * 0.42,
        Paint()..color = coreColor.withValues(alpha: 0.88));
    canvas.drawLine(
      Offset(size.x * 0.50, size.y * 0.20),
      Offset(size.x * 0.50, size.y * 0.80),
      Paint()
        ..color = const Color(0xFF081C15).withValues(alpha: 0.72)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawArmoredCell(
    Canvas canvas,
    Color bodyColor,
    Color coreColor,
    double time,
  ) {
    final centerOffset = Offset(size.x / 2, size.y / 2);
    final shell = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: centerOffset,
        width: size.x * 0.92,
        height: size.y * 0.78,
      ),
      Radius.circular(size.x * 0.24),
    );
    canvas.drawRRect(shell, Paint()..color = bodyColor);
    canvas.drawRRect(
      shell,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = coreColor.withValues(alpha: 0.54),
    );
    for (var i = 0; i < 5; i++) {
      final angle = time * 0.4 + i * math.pi * 2 / 5;
      canvas.drawCircle(
        centerOffset.translate(
            math.cos(angle) * size.x * 0.24, math.sin(angle) * size.y * 0.18),
        size.x * 0.055,
        Paint()..color = coreColor.withValues(alpha: 0.82),
      );
    }
  }

  void _drawBruteCell(
    Canvas canvas,
    Color bodyColor,
    Color coreColor,
    double time,
  ) {
    final centerOffset = Offset(size.x / 2, size.y / 2);
    final membrane = Path()
      ..moveTo(size.x * 0.50, size.y * 0.04)
      ..cubicTo(size.x * 0.88, size.y * 0.10, size.x * 0.98, size.y * 0.45,
          size.x * 0.78, size.y * 0.78)
      ..cubicTo(size.x * 0.56, size.y * 1.02, size.x * 0.16, size.y * 0.92,
          size.x * 0.08, size.y * 0.58)
      ..cubicTo(size.x * 0.02, size.y * 0.24, size.x * 0.20, size.y * 0.02,
          size.x * 0.50, size.y * 0.04)
      ..close();
    canvas.drawPath(membrane, Paint()..color = bodyColor);
    canvas.drawPath(
      membrane,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..color = coreColor.withValues(alpha: 0.42),
    );
    final nucleus = Path()
      ..addOval(Rect.fromCenter(
          center: centerOffset, width: size.x * 0.34, height: size.y * 0.28));
    canvas.drawPath(nucleus, Paint()..color = coreColor.withValues(alpha: 0.9));
    for (var i = 0; i < 3; i++) {
      final angle = time + i * math.pi * 2 / 3;
      canvas.drawLine(
        centerOffset,
        centerOffset.translate(
          math.cos(angle) * size.x * 0.34,
          math.sin(angle) * size.y * 0.30,
        ),
        Paint()
          ..color = coreColor.withValues(alpha: 0.55)
          ..strokeWidth = 2,
      );
    }
    if (bruteMoveDirection.length2 > 0) {
      _drawBruteDirectionArrows(canvas, coreColor);
    }
  }

  void _drawPrismaticMutation(Canvas canvas, double time) {
    final centerOffset = Offset(size.x / 2, size.y / 2);
    final colors = [
      const Color(0xFFEF476F),
      const Color(0xFFFFD166),
      const Color(0xFF06D6A0),
      const Color(0xFF118AB2),
      const Color(0xFF9B5DE5),
    ];
    for (var i = colors.length - 1; i >= 0; i--) {
      final radius = size.x * (0.18 + i * 0.06);
      canvas.drawCircle(
        centerOffset.translate(
          math.cos(time * 0.8 + i) * size.x * 0.04,
          math.sin(time * 0.7 + i) * size.y * 0.04,
        ),
        radius,
        Paint()..color = colors[i].withValues(alpha: 0.78),
      );
    }
    _drawSpikyVirion(
      canvas,
      centerOffset,
      size.x * 0.34,
      Colors.white.withValues(alpha: 0.78),
      const Color(0xFF081C15),
      spikes: 7,
      spin: time,
    );
  }

  void _drawBruteDirectionArrows(Canvas canvas, Color color) {
    final direction = bruteMoveDirection.normalized();
    final side = Offset(-direction.y, direction.x);
    final base = Offset(size.x / 2, size.y / 2);
    final arrowPaint = Paint()..color = color.withValues(alpha: 0.92);
    for (int index = 0; index < 3; index++) {
      final offsetAmount = 6.0 + index * 8.0;
      final center = Offset(
        base.dx + direction.x * offsetAmount,
        base.dy + direction.y * offsetAmount,
      );
      final tip = Offset(
        center.dx + direction.x * 6.0,
        center.dy + direction.y * 6.0,
      );
      final left = Offset(
        center.dx - direction.x * 3.5 + side.dx * 3.5,
        center.dy - direction.y * 3.5 + side.dy * 3.5,
      );
      final right = Offset(
        center.dx - direction.x * 3.5 - side.dx * 3.5,
        center.dy - direction.y * 3.5 - side.dy * 3.5,
      );
      final path = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(left.dx, left.dy)
        ..lineTo(right.dx, right.dy)
        ..close();
      canvas.drawPath(path, arrowPaint);
    }
  }

  void _drawEnemyHealthBar(Canvas canvas) {
    final hpFraction =
        health <= 0 ? 0.0 : (health / _maxHealth).clamp(0.0, 1.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, size.y + 3, size.x, 4), const Radius.circular(999)),
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, size.y + 3, size.x * hpFraction, 4),
          const Radius.circular(999)),
      Paint()..color = const Color(0xFFD8F3DC),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (hitFlash > 0) {
      hitFlash = math.max(0.0, hitFlash - dt);
    }
    if (!game.threatsActive) {
      return;
    }
    final currentPlayer = game.player;
    if (currentPlayer == null) {
      return;
    }
    behaviorTimer += dt;
    final toPlayer = currentPlayer.center - center;
    Vector2 moveVector =
        toPlayer.length2 > 0 ? toPlayer.normalized() : Vector2.zero();
    double speedMultiplier = 1.0;
    switch (archetype) {
      case EnemyArchetype.swarm:
        break;
      case EnemyArchetype.runner:
        if (game.runnerDashUnlocked) {
          if (runnerBurstTimer > 0) {
            runnerBurstTimer = math.max(0.0, runnerBurstTimer - dt);
            speedMultiplier = 1.90 + math.min(0.40, game.currentRound * 0.03);
          } else if (behaviorTimer >=
              math.max(1.4, 2.3 - game.currentRound * 0.05)) {
            behaviorTimer = 0;
            runnerBurstTimer = 0.60;
          }
        }
        break;
      case EnemyArchetype.stalker:
        if (game.stalkerWeaveUnlocked) {
          final cycle = behaviorTimer % 3.2;
          if (cycle < 1.9) {
            final tangent = Vector2(-moveVector.y, moveVector.x);
            moveVector = (moveVector * 0.32) + tangent * 0.92;
            speedMultiplier = 0.96;
          } else {
            speedMultiplier = 1.82 + math.min(0.28, game.currentRound * 0.02);
          }
        } else {
          speedMultiplier = 1.04;
        }
        break;
      case EnemyArchetype.tank:
        if (toPlayer.length < 150 && moveVector.length2 > 0) {
          final tangent = Vector2(-moveVector.y, moveVector.x);
          moveVector = moveVector + tangent * 0.35;
        }
        speedMultiplier = 0.82;
        break;
      case EnemyArchetype.brute:
        if (moveVector.length2 > 0) {
          if (bruteMoveDirection.length2 == 0 || behaviorTimer >= 1.15) {
            behaviorTimer = 0;
            bruteMoveDirection = moveVector.clone();
          }
          moveVector = bruteMoveDirection;
        }
        speedMultiplier = toPlayer.length < 165 ? 1.24 : 1.12;
        break;
      case EnemyArchetype.rainbow:
        final tangent = Vector2(-moveVector.y, moveVector.x);
        if (toPlayer.length < 120) {
          moveVector = tangent * 0.92 - moveVector * 0.28;
        } else {
          moveVector = moveVector + tangent * 0.24;
        }
        speedMultiplier = 1.16;
        break;
      case EnemyArchetype.splitter:
        if (moveVector.length2 > 0) {
          if (splitterMoveDirection.length2 == 0) {
            splitterMoveDirection = moveVector.clone();
          } else {
            final turnResponsiveness = math.min(1.0, dt * 3.4);
            splitterMoveDirection =
                (splitterMoveDirection * (1 - turnResponsiveness)) +
                    (moveVector * turnResponsiveness);
          }
          moveVector = splitterMoveDirection;
        }
        speedMultiplier = toPlayer.length < 145 ? 0.92 : 0.96;
        break;
    }
    if (enhancedWeaver) {
      speedMultiplier += 0.16;
    }
    if (moveVector.length2 > 0) {
      moveVector.normalize();
      visualDirection = moveVector.clone();
      position += moveVector *
          baseSpeed *
          speedMultiplier *
          game.enemySpeedMultiplier *
          dt;
    }
    position.x =
        position.x.clamp(0.0, math.max(0.0, game.size.x - size.x)).toDouble();
    position.y = position.y
        .clamp(
            game.playAreaTop, math.max(game.playAreaTop, game.size.y - size.y))
        .toDouble();
  }

  void takeDamage(int amount) {
    hitFlash = 0.10;
    health -= amount;
    if (health <= 0) {
      if (archetype == EnemyArchetype.splitter && splitGeneration > 0) {
        game.spawnSplitterChildren(this);
      }
      game.awardKill(this);
      removeFromParent();
    }
  }
}

class BossComponent extends PositionComponent
    with HasGameReference<SquareShooterGame> {
  BossComponent({
    required this.bossType,
    required super.position,
    required super.size,
    required this.maxHealth,
    required this.health,
    required this.baseSpeed,
    required this.coinValue,
    this.isMitosisChild = false,
  });

  final BossType bossType;
  final int maxHealth;
  int health;
  final double baseSpeed;
  final int coinValue;
  final bool isMitosisChild;

  double attackTimer = 0;
  double summonTimer = 0;
  double dashWindup = 0;
  double dashActive = 0;
  double recoveryTimer = 0;
  double evadeCooldown = 0;
  double hitFlash = 0;
  double introTimer = 1.0;
  Vector2 dashDirection = Vector2.zero();
  int stalkerDashesSincePause = 0;

  bool _phaseTwoTriggered = false;
  bool _quarterBurstTriggered = false;
  bool _mitosisTriggered = false;

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);
  Rect get hitRect => switch (bossType) {
        BossType.stalkerApex => Rect.fromLTWH(
            position.x + size.x * 0.08,
            position.y + size.y * 0.04,
            size.x * 0.86,
            size.y * 0.90,
          ),
        BossType.splitterQueen => rect.deflate(size.x * 0.04),
        BossType.chargerBrute => rect.deflate(size.x * 0.08),
      };
  Rect get contactRect => switch (bossType) {
        BossType.stalkerApex => Rect.fromLTWH(
            position.x + size.x * 0.18,
            position.y + size.y * 0.14,
            size.x * 0.68,
            size.y * 0.72,
          ),
        BossType.splitterQueen => rect.deflate(size.x * 0.08),
        BossType.chargerBrute => rect.deflate(size.x * 0.16),
      };
  double get hitRadius => switch (bossType) {
        BossType.stalkerApex => size.x * 0.50,
        BossType.splitterQueen => size.x * 0.54,
        BossType.chargerBrute => size.x * 0.48,
      };
  @override
  Vector2 get center => position + size / 2;
  double get healthFraction =>
      health <= 0 ? 0 : (health / maxHealth).clamp(0.0, 1.0);
  bool get inPhaseTwo => health <= maxHealth / 2;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    game.bossRegistry.add(this);
  }

  @override
  void onRemove() {
    game.bossRegistry.remove(this);
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    if (game.biologyResourcePackEnabled) {
      _renderBiologyPackBoss(canvas);
      return;
    }
    final accent = hitFlash > 0
        ? Colors.white
        : switch (bossType) {
            BossType.stalkerApex => const Color(0xFF118AB2),
            BossType.splitterQueen => const Color(0xFF52B788),
            BossType.chargerBrute => const Color(0xFFEF476F),
          };
    final centerOffset = Offset(size.x / 2, size.y / 2);
    canvas.drawOval(
      Rect.fromCenter(
        center: centerOffset.translate(0, size.y * 0.08),
        width: size.x * 1.05,
        height: size.y * 0.72,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.28),
    );
    canvas.drawCircle(
      centerOffset,
      size.x * (isMitosisChild ? 0.58 : 0.72),
      Paint()
        ..shader = ui.Gradient.radial(
          centerOffset,
          size.x * (isMitosisChild ? 0.58 : 0.72),
          [
            accent.withValues(alpha: inPhaseTwo ? 0.24 : 0.15),
            Colors.transparent,
          ],
        ),
    );

    switch (bossType) {
      case BossType.stalkerApex:
        final path = Path()
          ..moveTo(size.x * 0.18, size.y * 0.5)
          ..lineTo(size.x * 0.42, size.y * 0.14)
          ..lineTo(size.x * 0.78, size.y * 0.20)
          ..lineTo(size.x * 0.86, size.y * 0.5)
          ..lineTo(size.x * 0.78, size.y * 0.80)
          ..lineTo(size.x * 0.42, size.y * 0.86)
          ..close();
        canvas.drawPath(path, Paint()..color = accent);
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFD7F3FF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
        final eyePaint = Paint()..color = const Color(0xFFD7F3FF);
        canvas.drawCircle(Offset(size.x * 0.55, size.y * 0.38), 4.5, eyePaint);
        canvas.drawCircle(Offset(size.x * 0.67, size.y * 0.48), 3.2, eyePaint);
        if (dashWindup > 0 && dashDirection.length2 > 0) {
          final telegraph = Paint()
            ..color = const Color(0xFFA9E8FF).withValues(alpha: 0.28)
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round;
          final end = Offset(
            size.x / 2 + dashDirection.x * 285,
            size.y / 2 + dashDirection.y * 285,
          );
          canvas.drawLine(Offset(size.x / 2, size.y / 2), end, telegraph);
        }
        break;
      case BossType.splitterQueen:
        final shell = RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y),
          const Radius.circular(20),
        );
        canvas.drawRRect(shell, Paint()..color = accent);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
                size.x * 0.28, size.y * 0.28, size.x * 0.44, size.y * 0.44),
            const Radius.circular(8),
          ),
          Paint()..color = const Color(0xFFD8F3DC),
        );
        if (inPhaseTwo) {
          final ring = Paint()
            ..color = const Color(0xFFB7E4C7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                  size.x * 0.1, size.y * 0.1, size.x * 0.8, size.y * 0.8),
              const Radius.circular(18),
            ),
            ring,
          );
        }
        break;
      case BossType.chargerBrute:
        final path = Path()
          ..moveTo(size.x / 2, 0)
          ..lineTo(size.x, size.y / 2)
          ..lineTo(size.x / 2, size.y)
          ..lineTo(0, size.y / 2)
          ..close();
        canvas.drawPath(path, Paint()..color = accent);
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFFFE5EC)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
        if (dashWindup > 0 && dashDirection.length2 > 0) {
          final telegraph = Paint()
            ..color = const Color(0xFFFFB3C1).withValues(alpha: 0.35)
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round;
          final end = Offset(
            size.x / 2 + dashDirection.x * 220,
            size.y / 2 + dashDirection.y * 220,
          );
          canvas.drawLine(Offset(size.x / 2, size.y / 2), end, telegraph);
        }
        if (isMitosisChild) {
          canvas.drawCircle(
            Offset(size.x / 2, size.y / 2),
            size.x * 0.18,
            Paint()..color = const Color(0xFFFFE5EC),
          );
          for (int index = 0; index < 3; index++) {
            final angle = index * (math.pi * 2 / 3);
            final start = Offset(
              size.x / 2 + math.cos(angle) * size.x * 0.16,
              size.y / 2 + math.sin(angle) * size.y * 0.16,
            );
            final end = Offset(
              size.x / 2 + math.cos(angle) * size.x * 0.34,
              size.y / 2 + math.sin(angle) * size.y * 0.34,
            );
            canvas.drawLine(
              start,
              end,
              Paint()
                ..color = const Color(0xFFFFE5EC)
                ..strokeWidth = 3,
            );
          }
        }
        break;
    }
  }

  void _renderBiologyPackBoss(Canvas canvas) {
    final accent = hitFlash > 0
        ? Colors.white
        : switch (bossType) {
            BossType.stalkerApex => const Color(0xFF38BDF8),
            BossType.splitterQueen => const Color(0xFF74E291),
            BossType.chargerBrute => const Color(0xFFFB7185),
          };
    final core = switch (bossType) {
      BossType.stalkerApex => const Color(0xFFD7F3FF),
      BossType.splitterQueen => const Color(0xFFD8F3DC),
      BossType.chargerBrute => const Color(0xFFFFE5EC),
    };
    final centerOffset = Offset(size.x / 2, size.y / 2);
    final time = game.arenaVisualTime + attackTimer + summonTimer;

    canvas.drawOval(
      Rect.fromCenter(
        center: centerOffset.translate(0, size.y * 0.12),
        width: size.x * 1.18,
        height: size.y * 0.42,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.30),
    );
    canvas.drawCircle(
      centerOffset,
      size.x * (isMitosisChild ? 0.56 : 0.74),
      Paint()
        ..shader = ui.Gradient.radial(
          centerOffset,
          size.x * (isMitosisChild ? 0.56 : 0.74),
          [
            accent.withValues(alpha: inPhaseTwo ? 0.28 : 0.18),
            Colors.transparent,
          ],
        ),
    );

    switch (bossType) {
      case BossType.stalkerApex:
        _drawApexPhageBoss(canvas, accent, core, time);
        break;
      case BossType.splitterQueen:
        _drawSplitterBroodBoss(canvas, accent, core, time);
        break;
      case BossType.chargerBrute:
        _drawMitosisBruteBoss(canvas, accent, core, time);
        break;
    }
  }

  void _drawApexPhageBoss(
    Canvas canvas,
    Color accent,
    Color core,
    double time,
  ) {
    final headCenter = Offset(size.x * 0.52, size.y * 0.34);
    final headRadius = size.x * 0.28;
    final head = Path();
    for (var i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final point = headCenter.translate(
        math.cos(angle) * headRadius,
        math.sin(angle) * headRadius,
      );
      if (i == 0) {
        head.moveTo(point.dx, point.dy);
      } else {
        head.lineTo(point.dx, point.dy);
      }
    }
    head.close();
    canvas.drawPath(head, Paint()..color = accent);
    canvas.drawPath(
      head,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = core.withValues(alpha: 0.82),
    );
    canvas.drawCircle(headCenter, headRadius * 0.36,
        Paint()..color = core.withValues(alpha: 0.95));
    final tailPaint = Paint()
      ..color = core.withValues(alpha: 0.88)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final tailTop = Offset(size.x * 0.52, size.y * 0.58);
    final tailBottom = Offset(size.x * 0.52, size.y * 0.84);
    canvas.drawLine(tailTop, tailBottom, tailPaint);
    for (var i = 0; i < 4; i++) {
      final side = i.isEven ? -1.0 : 1.0;
      final y = size.y * (0.66 + i * 0.06);
      canvas.drawLine(
        Offset(size.x * 0.52, y),
        Offset(size.x * (0.52 + side * (0.20 + i * 0.03)), y + size.y * 0.14),
        tailPaint,
      );
    }
    for (var i = 0; i < 8; i++) {
      final angle = time * 0.5 + i * math.pi * 2 / 8;
      canvas.drawLine(
        headCenter.translate(math.cos(angle) * headRadius * 0.76,
            math.sin(angle) * headRadius * 0.76),
        headCenter.translate(math.cos(angle) * headRadius * 1.14,
            math.sin(angle) * headRadius * 1.14),
        Paint()
          ..color = accent.withValues(alpha: 0.72)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
    _drawBossDashTelegraph(canvas, core, length: 330);
  }

  void _drawSplitterBroodBoss(
    Canvas canvas,
    Color accent,
    Color core,
    double time,
  ) {
    final centers = [
      Offset(size.x * 0.38, size.y * 0.48),
      Offset(size.x * 0.62, size.y * 0.48),
      Offset(size.x * 0.50, size.y * 0.32),
      if (inPhaseTwo) Offset(size.x * 0.50, size.y * 0.66),
    ];
    for (var i = 0; i < centers.length; i++) {
      final radius = size.x * (i == 2 ? 0.22 : 0.27);
      final wobble = Offset(
        math.cos(time * 1.4 + i) * size.x * 0.015,
        math.sin(time * 1.2 + i) * size.y * 0.015,
      );
      final center = centers[i] + wobble;
      canvas.drawCircle(center, radius, Paint()..color = accent);
      canvas.drawCircle(
          center, radius * 0.44, Paint()..color = core.withValues(alpha: 0.92));
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = core.withValues(alpha: 0.44),
      );
    }
    canvas.drawLine(
      Offset(size.x * 0.50, size.y * 0.18),
      Offset(size.x * 0.50, size.y * 0.82),
      Paint()
        ..color = const Color(0xFF081C15).withValues(alpha: 0.56)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    if (inPhaseTwo) {
      canvas.drawCircle(
        Offset(size.x * 0.50, size.y * 0.50),
        size.x * 0.48,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = core.withValues(alpha: 0.44),
      );
    }
  }

  void _drawMitosisBruteBoss(
    Canvas canvas,
    Color accent,
    Color core,
    double time,
  ) {
    final centerOffset = Offset(size.x / 2, size.y / 2);
    final membrane = Path()
      ..moveTo(size.x * 0.50, size.y * 0.02)
      ..cubicTo(size.x * 0.94, size.y * 0.10, size.x * 1.02, size.y * 0.48,
          size.x * 0.78, size.y * 0.82)
      ..cubicTo(size.x * 0.56, size.y * 1.04, size.x * 0.16, size.y * 0.96,
          size.x * 0.06, size.y * 0.58)
      ..cubicTo(size.x * 0.00, size.y * 0.22, size.x * 0.20, size.y * 0.00,
          size.x * 0.50, size.y * 0.02)
      ..close();
    canvas.drawPath(membrane, Paint()..color = accent);
    canvas.drawPath(
      membrane,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = core.withValues(alpha: 0.74),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: centerOffset,
        width: size.x * 0.34,
        height: size.y * 0.28,
      ),
      Paint()..color = core.withValues(alpha: 0.94),
    );
    for (var i = 0; i < 5; i++) {
      final angle = time * 0.6 + i * math.pi * 2 / 5;
      canvas.drawLine(
        centerOffset,
        centerOffset.translate(
          math.cos(angle) * size.x * 0.36,
          math.sin(angle) * size.y * 0.32,
        ),
        Paint()
          ..color = core.withValues(alpha: 0.58)
          ..strokeWidth = 3,
      );
    }
    if (isMitosisChild) {
      canvas.drawCircle(
        centerOffset,
        size.x * 0.13,
        Paint()..color = const Color(0xFF081C15).withValues(alpha: 0.34),
      );
    }
    _drawBossDashTelegraph(canvas, core, length: 260);
  }

  void _drawBossDashTelegraph(
    Canvas canvas,
    Color color, {
    required double length,
  }) {
    if (dashWindup <= 0 || dashDirection.length2 == 0) {
      return;
    }
    final telegraph = Paint()
      ..color = color.withValues(alpha: 0.34)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final end = Offset(
      size.x / 2 + dashDirection.x * length,
      size.y / 2 + dashDirection.y * length,
    );
    canvas.drawLine(Offset(size.x / 2, size.y / 2), end, telegraph);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (hitFlash > 0) {
      hitFlash = math.max(0.0, hitFlash - dt);
    }
    if (game.roundPhase != RoundFlowPhase.bossFight || !game.threatsActive) {
      return;
    }
    if (inPhaseTwo && !_phaseTwoTriggered && !isMitosisChild) {
      _phaseTwoTriggered = true;
      game.showBanner('${bossType.title} mutates', duration: 2.0);
    }
    final currentPlayer = game.player;
    if (currentPlayer == null) {
      return;
    }
    if (introTimer > 0) {
      introTimer = math.max(0.0, introTimer - dt);
      _moveToward(currentPlayer.center, dt, multiplier: 0.38);
      return;
    }
    evadeCooldown = math.max(0.0, evadeCooldown - dt);
    switch (bossType) {
      case BossType.stalkerApex:
        _updateStalkerApex(dt, currentPlayer);
        break;
      case BossType.splitterQueen:
        _updateSplitterQueen(dt, currentPlayer);
        break;
      case BossType.chargerBrute:
        _updateChargerBrute(dt, currentPlayer);
        break;
    }
    position.x =
        position.x.clamp(0.0, math.max(0.0, game.size.x - size.x)).toDouble();
    position.y = position.y
        .clamp(
            game.playAreaTop, math.max(game.playAreaTop, game.size.y - size.y))
        .toDouble();
  }

  void _updateStalkerApex(double dt, PlayerComponent currentPlayer) {
    if (dashActive > 0) {
      position += dashDirection * (inPhaseTwo ? 520 : 455) * dt;
      dashActive = math.max(0.0, dashActive - dt);
      if (dashActive <= 0) {
        stalkerDashesSincePause += 1;
        final pauseAfterDash = stalkerDashesSincePause >= 2;
        recoveryTimer = pauseAfterDash
            ? (inPhaseTwo ? 0.58 : 0.78)
            : (inPhaseTwo ? 0.22 : 0.30);
        if (pauseAfterDash) {
          stalkerDashesSincePause = 0;
        }
      }
      return;
    }
    if (recoveryTimer > 0) {
      recoveryTimer = math.max(0.0, recoveryTimer - dt);
      _moveToward(currentPlayer.center, dt, multiplier: 0.58);
      return;
    }
    final threateningBullet = _nearestThreateningBullet();
    if (threateningBullet != null && evadeCooldown <= 0) {
      final bulletDirection = threateningBullet.direction.normalized();
      var dodgeDirection = Vector2(-bulletDirection.y, bulletDirection.x);
      if (dodgeDirection.dot(center - threateningBullet.center) < 0) {
        dodgeDirection = -dodgeDirection;
      }
      dashWindup = 0;
      dashDirection = dodgeDirection.normalized();
      dashActive = 0.16;
      evadeCooldown = 0.55;
      return;
    }
    final toPlayer = currentPlayer.center - center;
    if (toPlayer.length2 > 0) {
      final tangent = Vector2(-toPlayer.y, toPlayer.x)..normalize();
      var move = tangent * (inPhaseTwo ? 1.14 : 0.94);
      if (toPlayer.length > 220) {
        move += toPlayer.normalized() * 0.62;
      } else if (toPlayer.length < 145) {
        move -= toPlayer.normalized() * 0.68;
      }
      if (move.length2 > 0) {
        move.normalize();
        position += move * baseSpeed * (inPhaseTwo ? 1.30 : 1.14) * dt;
      }
    }
    summonTimer += dt;
    final summonInterval = inPhaseTwo ? 5.0 : 7.2;
    if (summonTimer >= summonInterval) {
      summonTimer = 0;
      game.showBanner('Apex weavers enter the arena', duration: 1.4);
      game.spawnEnhancedWeavers(center, inPhaseTwo ? 2 : 1);
    }
    attackTimer += dt;
    final interval = inPhaseTwo ? 1.20 : 1.72;
    if (attackTimer >= interval) {
      attackTimer = 0;
      final toPlayer = currentPlayer.center - center;
      dashDirection =
          toPlayer.length2 == 0 ? Vector2(1, 0) : toPlayer.normalized();
      dashWindup = inPhaseTwo ? 0.18 : 0.26;
    }
    if (dashWindup > 0) {
      dashWindup = math.max(0.0, dashWindup - dt);
      if (dashWindup <= 0) {
        dashActive = inPhaseTwo ? 0.24 : 0.20;
      }
    }
  }

  void _updateSplitterQueen(double dt, PlayerComponent currentPlayer) {
    final toPlayer = currentPlayer.center - center;
    if (toPlayer.length2 > 0) {
      final desiredDistance = inPhaseTwo ? 180 : 215;
      var move = Vector2.zero();
      if (toPlayer.length > desiredDistance) {
        move += toPlayer.normalized();
      } else if (toPlayer.length < desiredDistance - 36) {
        move -= toPlayer.normalized();
      }
      final tangent = Vector2(-toPlayer.y, toPlayer.x)..normalize();
      move += tangent * (inPhaseTwo ? 0.90 : 0.55);
      if (move.length2 > 0) {
        move.normalize();
        position += move * baseSpeed * 0.88 * dt;
      }
    }
    summonTimer += dt;
    final summonInterval = inPhaseTwo ? 1.8 : 3.0;
    if (summonTimer >= summonInterval) {
      summonTimer = 0;
      game.spawnBossBrood(center, inPhaseTwo ? 2 : 1, heavySplit: inPhaseTwo);
    }
    if (healthFraction <= 0.25 && !_quarterBurstTriggered) {
      _quarterBurstTriggered = true;
      game.showBanner('${bossType.title} calls a brood surge', duration: 2.0);
      game.spawnBossBrood(center, 8, heavySplit: true);
    }
    if (inPhaseTwo) {
      attackTimer += dt;
      if (attackTimer >= 5.8) {
        attackTimer = 0;
        game.spawnBossBrood(center, 4, heavySplit: false);
      }
    }
  }

  void _updateChargerBrute(double dt, PlayerComponent currentPlayer) {
    if (!isMitosisChild &&
        !_mitosisTriggered &&
        health <= (maxHealth * 0.75).round()) {
      _mitosisTriggered = true;
      game.triggerChargerMitosis(this);
      removeFromParent();
      return;
    }
    if (dashActive > 0) {
      position += dashDirection * (inPhaseTwo ? 430 : 350) * dt;
      dashActive = math.max(0.0, dashActive - dt);
      if (dashActive <= 0) {
        recoveryTimer = inPhaseTwo ? 0.32 : 0.46;
      }
      return;
    }
    if (recoveryTimer > 0) {
      recoveryTimer = math.max(0.0, recoveryTimer - dt);
      _moveToward(currentPlayer.center, dt, multiplier: 0.55);
      return;
    }
    if (dashWindup > 0) {
      dashWindup = math.max(0.0, dashWindup - dt);
      if (dashWindup <= 0) {
        dashActive = inPhaseTwo ? 0.48 : 0.38;
      }
      return;
    }
    _moveToward(currentPlayer.center, dt, multiplier: 0.72);
    attackTimer += dt;
    final interval = inPhaseTwo ? 1.75 : 2.55;
    if (attackTimer >= interval) {
      attackTimer = 0;
      final toPlayer = currentPlayer.center - center;
      dashDirection =
          toPlayer.length2 == 0 ? Vector2(1, 0) : toPlayer.normalized();
      dashWindup = inPhaseTwo ? 0.55 : 0.75;
    }
  }

  BulletComponent? _nearestThreateningBullet() {
    BulletComponent? best;
    double bestDistance = double.infinity;
    for (final bullet in game.bulletRegistry) {
      final delta = center - bullet.center;
      final distanceSq = delta.length2;
      if (distanceSq > 130 * 130) {
        continue;
      }
      if (bullet.direction.dot(delta.normalized()) < 0.72) {
        continue;
      }
      if (distanceSq < bestDistance) {
        bestDistance = distanceSq;
        best = bullet;
      }
    }
    return best;
  }

  void _moveToward(Vector2 target, double dt, {required double multiplier}) {
    final toTarget = target - center;
    if (toTarget.length2 == 0) {
      return;
    }
    position += toTarget.normalized() *
        baseSpeed *
        multiplier *
        game.enemySpeedMultiplier *
        dt;
  }

  void takeDamage(int amount) {
    hitFlash = 0.10;
    health -= amount;
    if (bossType == BossType.chargerBrute &&
        !isMitosisChild &&
        !_mitosisTriggered &&
        health <= (maxHealth * 0.75).round()) {
      _mitosisTriggered = true;
      game.triggerChargerMitosis(this);
      removeFromParent();
      return;
    }
    if (health <= 0) {
      game.awardBossKill(this);
      removeFromParent();
    }
  }
}

enum BulletVisualStyle {
  capsule,
  needle,
  shard,
  orb,
  rail,
  cross,
}

class BulletComponent extends PositionComponent
    with HasGameReference<SquareShooterGame> {
  BulletComponent({
    required super.position,
    required Vector2 direction,
    required this.damage,
    required this.speed,
    required double bulletSize,
    this.homingStrength = 0,
    this.remainingHits = 0,
    required this.tint,
    this.visualStyle = BulletVisualStyle.capsule,
  })  : direction = direction.normalized(),
        super(size: Vector2.all(bulletSize));

  Vector2 direction;
  final int damage;
  final double speed;
  final double homingStrength;
  int remainingHits;
  final Color tint;
  final BulletVisualStyle visualStyle;

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (game.bulletRegistry.length >= game.maxActivePlayerProjectiles) {
      removeFromParent();
      return;
    }
    game.bulletRegistry.add(this);
  }

  @override
  void onRemove() {
    game.bulletRegistry.remove(this);
    super.onRemove();
  }

  bool registerHit() {
    if (remainingHits > 0) {
      remainingHits -= 1;
      return true;
    }
    return false;
  }

  @override
  void render(Canvas canvas) {
    if (game.lowCostProjectileVisuals) {
      final paint = Paint()..color = tint.withValues(alpha: 0.92);
      switch (visualStyle) {
        case BulletVisualStyle.orb:
          canvas.drawCircle(
              Offset(size.x / 2, size.y / 2), size.x * 0.42, paint);
          break;
        case BulletVisualStyle.rail:
        case BulletVisualStyle.needle:
          final angle = math.atan2(direction.y, direction.x);
          canvas.save();
          canvas.translate(size.x / 2, size.y / 2);
          canvas.rotate(angle);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset.zero,
                  width: size.x * 1.45,
                  height: size.y * 0.5),
              const Radius.circular(999),
            ),
            paint,
          );
          canvas.restore();
          break;
        case BulletVisualStyle.cross:
          canvas.drawLine(
            Offset(size.x * 0.18, size.y * 0.5),
            Offset(size.x * 0.82, size.y * 0.5),
            Paint()
              ..color = tint
              ..strokeWidth = math.max(2.0, size.x * 0.2)
              ..strokeCap = StrokeCap.round,
          );
          canvas.drawLine(
            Offset(size.x * 0.5, size.y * 0.18),
            Offset(size.x * 0.5, size.y * 0.82),
            Paint()
              ..color = tint
              ..strokeWidth = math.max(2.0, size.x * 0.2)
              ..strokeCap = StrokeCap.round,
          );
          break;
        case BulletVisualStyle.shard:
        case BulletVisualStyle.capsule:
          canvas.drawCircle(
              Offset(size.x / 2, size.y / 2), size.x * 0.38, paint);
          break;
      }
      return;
    }
    final angle = math.atan2(direction.y, direction.x);
    final w = size.x;
    final h = size.y;
    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.rotate(angle);
    switch (visualStyle) {
      case BulletVisualStyle.capsule:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero, width: w * 1.7, height: h * 0.72),
            const Radius.circular(999),
          ),
          Paint()..color = tint.withValues(alpha: 0.96),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(w * 0.25, 0), width: w * 0.55, height: h * 0.34),
            const Radius.circular(999),
          ),
          Paint()..color = Colors.white.withValues(alpha: 0.35),
        );
      case BulletVisualStyle.needle:
        final path = Path()
          ..moveTo(-w * 0.7, 0)
          ..lineTo(-w * 0.08, -h * 0.42)
          ..lineTo(w * 0.82, 0)
          ..lineTo(-w * 0.08, h * 0.42)
          ..close();
        canvas.drawPath(path, Paint()..color = tint.withValues(alpha: 0.95));
        canvas.drawPath(
          Path()
            ..moveTo(-w * 0.32, 0)
            ..lineTo(w * 0.52, 0),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.32)
            ..strokeWidth = 1.2
            ..strokeCap = StrokeCap.round,
        );
      case BulletVisualStyle.shard:
        final path = Path()
          ..moveTo(-w * 0.55, 0)
          ..lineTo(0, -h * 0.6)
          ..lineTo(w * 0.68, 0)
          ..lineTo(0, h * 0.6)
          ..close();
        canvas.drawPath(path, Paint()..color = tint.withValues(alpha: 0.94));
        canvas.drawPath(
          Path()
            ..moveTo(-w * 0.14, -h * 0.28)
            ..lineTo(w * 0.36, 0)
            ..lineTo(-w * 0.14, h * 0.28),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.24)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.1,
        );
      case BulletVisualStyle.orb:
        canvas.drawCircle(
          Offset.zero,
          w * 0.55,
          Paint()..color = tint.withValues(alpha: 0.20),
        );
        canvas.drawCircle(
          Offset.zero,
          w * 0.36,
          Paint()..color = tint.withValues(alpha: 0.96),
        );
        canvas.drawCircle(
          Offset(w * 0.10, -h * 0.10),
          w * 0.12,
          Paint()..color = Colors.white.withValues(alpha: 0.55),
        );
      case BulletVisualStyle.rail:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero, width: w * 2.1, height: h * 0.38),
            const Radius.circular(999),
          ),
          Paint()..color = tint.withValues(alpha: 0.30),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero, width: w * 1.65, height: h * 0.20),
            const Radius.circular(999),
          ),
          Paint()..color = tint.withValues(alpha: 0.96),
        );
      case BulletVisualStyle.cross:
        final vertical = RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: w * 0.48, height: h * 1.9),
          const Radius.circular(999),
        );
        final horizontal = RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero, width: w * 1.9, height: h * 0.48),
          const Radius.circular(999),
        );
        canvas.drawRRect(
            vertical, Paint()..color = tint.withValues(alpha: 0.92));
        canvas.drawRRect(
            horizontal, Paint()..color = tint.withValues(alpha: 0.92));
        canvas.drawCircle(
          Offset.zero,
          w * 0.16,
          Paint()..color = Colors.white.withValues(alpha: 0.32),
        );
    }
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.canPlayerAttack) {
      return;
    }
    if (homingStrength > 0) {
      final center = position + size / 2;
      final targetCenter = game.nearestThreatCenterTo(center);
      if (targetCenter != null) {
        final desired = (targetCenter - center).normalized();
        direction = (direction * (1 - homingStrength * dt) +
                desired * (homingStrength * dt))
            .normalized();
      }
    }
    position += direction * speed * dt;
    if (position.x < -size.x ||
        position.y < -size.y ||
        position.x > game.size.x + size.x ||
        position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }
}

class EnemyProjectileComponent extends PositionComponent
    with HasGameReference<SquareShooterGame> {
  EnemyProjectileComponent({
    required super.position,
    required Vector2 direction,
    required this.speed,
    required this.tint,
    required double bulletSize,
  })  : direction = direction.normalized(),
        super(size: Vector2.all(bulletSize));

  Vector2 direction;
  final double speed;
  final Color tint;

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (game.enemyProjectileRegistry.length >= game.maxActiveEnemyProjectiles) {
      removeFromParent();
      return;
    }
    game.enemyProjectileRegistry.add(this);
  }

  @override
  void onRemove() {
    game.enemyProjectileRegistry.remove(this);
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(4));
    canvas.drawRRect(body, Paint()..color = tint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            size.x * 0.28, size.y * 0.28, size.x * 0.44, size.y * 0.44),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF081C15),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.threatsActive) {
      return;
    }
    position += direction * speed * dt;
    if (position.x < -size.x ||
        position.y < game.playAreaTop - size.y ||
        position.x > game.size.x + size.x ||
        position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }
}

class CoinComponent extends PositionComponent
    with HasGameReference<SquareShooterGame> {
  CoinComponent({required super.position, required this.value})
      : super(size: Vector2.all(12));

  final int value;
  double life = 8.5;

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);
  @override
  Vector2 get center => position + size / 2;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    game.coinRegistry.add(this);
  }

  @override
  void onRemove() {
    game.coinRegistry.remove(this);
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    final flicker = game.roundPhase == RoundFlowPhase.cleanup &&
        (game.sampleCleanupFlicker.floor().isOdd);
    if (flicker) {
      return;
    }
    final paint = Paint()
      ..color = value >= 10 ? const Color(0xFFFFD166) : const Color(0xFFF4A261);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(3)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3, 3, size.x - 6, size.y - 6),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFFFF1B6).withValues(alpha: 0.55),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameOver ||
        game.pausedForMenu ||
        game.pausedForLevel ||
        game.pausedForCombatLevel) {
      return;
    }
    if (game.roundPhase == RoundFlowPhase.cleanup) {
      if (game.cleanupRemaining <= 0) {
        removeFromParent();
        return;
      }
    } else {
      life -= dt;
    }
    if (life <= 0) {
      removeFromParent();
      return;
    }
    final currentPlayer = game.player;
    if (currentPlayer == null) {
      return;
    }
    final toPlayer = currentPlayer.center - center;
    if (toPlayer.length2 > 0 && toPlayer.length < game.sampleMagnetRadius) {
      position += toPlayer.normalized() * game.sampleMagnetStrength * dt;
    }
    position.x =
        position.x.clamp(0.0, math.max(0.0, game.size.x - size.x)).toDouble();
    position.y = position.y
        .clamp(
            game.playAreaTop, math.max(game.playAreaTop, game.size.y - size.y))
        .toDouble();
  }
}

class SampleComponent extends PositionComponent
    with HasGameReference<SquareShooterGame> {
  SampleComponent({
    required super.position,
    required this.value,
    required this.banksForNextRound,
  }) : super(size: Vector2.all(14));

  final int value;
  final bool banksForNextRound;
  double life = 10;

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);
  @override
  Vector2 get center => position + size / 2;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    game.sampleRegistry.add(this);
  }

  @override
  void onRemove() {
    game.sampleRegistry.remove(this);
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    final flicker = game.roundPhase == RoundFlowPhase.cleanup &&
        (game.sampleCleanupFlicker.floor().isOdd);
    if (flicker) {
      return;
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(4)),
      Paint()
        ..color = banksForNextRound
            ? const Color(0xFF80FFDB)
            : const Color(0xFF74C69D),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, size.x - 8, size.y - 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF081C15),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameOver ||
        game.pausedForMenu ||
        game.pausedForLevel ||
        game.pausedForCombatLevel) {
      return;
    }
    if (game.roundPhase == RoundFlowPhase.cleanup) {
      if (game.cleanupRemaining <= 0) {
        removeFromParent();
      }
    } else {
      life -= dt;
      if (life <= 0) {
        removeFromParent();
        return;
      }
    }
    final currentPlayer = game.player;
    if (currentPlayer == null) {
      return;
    }
    final toPlayer = currentPlayer.center - center;
    if (toPlayer.length2 > 0 && toPlayer.length < game.sampleMagnetRadius) {
      position += toPlayer.normalized() * (game.sampleMagnetStrength + 20) * dt;
    }
    position.x =
        position.x.clamp(0.0, math.max(0.0, game.size.x - size.x)).toDouble();
    position.y = position.y
        .clamp(
            game.playAreaTop, math.max(game.playAreaTop, game.size.y - size.y))
        .toDouble();
  }
}

class PickupComponent extends PositionComponent
    with HasGameReference<SquareShooterGame> {
  PickupComponent({required super.position, required this.pickupType})
      : super(size: Vector2.all(18));

  final PickupType pickupType;
  double life = 10;
  double bob = 0;

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    game.pickupRegistry.add(this);
  }

  @override
  void onRemove() {
    game.pickupRegistry.remove(this);
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    final baseColor = pickupType == PickupType.shield
        ? const Color(0xFF74C69D)
        : const Color(0xFF52B788);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(6)),
      Paint()..color = baseColor,
    );
    final iconPaint = Paint()
      ..color = const Color(0xFFD8F3DC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    if (pickupType == PickupType.shield) {
      final path = Path()
        ..moveTo(size.x / 2, 3)
        ..lineTo(size.x - 4, 6)
        ..lineTo(size.x - 5, size.y - 7)
        ..lineTo(size.x / 2, size.y - 3)
        ..lineTo(5, size.y - 7)
        ..lineTo(4, 6)
        ..close();
      canvas.drawPath(path, iconPaint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(size.x / 2, size.y / 2), width: 9, height: 9),
          const Radius.circular(2),
        ),
        iconPaint,
      );
      canvas.drawLine(
          Offset(size.x / 2, 2), Offset(size.x / 2, size.y - 2), iconPaint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameOver ||
        game.pausedForMenu ||
        game.pausedForLevel ||
        game.pausedForCombatLevel) {
      return;
    }
    life -= dt;
    if (life <= 0) {
      removeFromParent();
      return;
    }
    bob += dt;
    position.y += math.sin(bob * 4) * 4 * dt;
  }
}

abstract class MiniWeaponAttachmentComponent extends PositionComponent
    with HasGameReference<SquareShooterGame> {
  MiniWeaponAttachmentComponent({
    required Vector2 sizeValue,
    required this.damage,
    required this.tint,
  }) : super(size: sizeValue);

  final int damage;
  final Color tint;
  double hitCooldown = 0;

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);
  @override
  Vector2 get center => position + size / 2;

  @override
  void update(double dt) {
    super.update(dt);
    if (hitCooldown > 0) {
      hitCooldown = math.max(0.0, hitCooldown - dt);
    }
  }
}

class SentryPodComponent extends PositionComponent
    with HasGameReference<SquareShooterGame> {
  SentryPodComponent({
    required super.position,
    required this.damage,
    required this.lifetime,
    required this.fireInterval,
    required this.range,
    this.evolved = false,
    this.branchId,
  }) : super(size: Vector2.all(24));

  final int damage;
  final double fireInterval;
  final double range;
  final bool evolved;
  final String? branchId;
  double lifetime;
  double fireTimer = 0;

  @override
  Vector2 get center => position + size / 2;

  @override
  void render(Canvas canvas) {
    final sprite = game.miniWeaponArt(MiniWeaponType.sentryPod);
    if (sprite != null) {
      game.drawSpriteRect(
        canvas,
        sprite,
        Rect.fromLTWH(0, 0, size.x, size.y),
        alpha: evolved ? 1 : 0.96,
      );
      return;
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(5)),
      Paint()..color = const Color(0xFF95D5B2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(size.x / 2, size.y / 2), width: 8, height: 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF081C15),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.canPlayerAttack) {
      return;
    }
    lifetime -= dt;
    if (lifetime <= 0) {
      removeFromParent();
      return;
    }
    fireTimer += dt;
    if (fireTimer < fireInterval) {
      return;
    }
    final target = game.nearestThreatCenterTo(center, maxDistance: range);
    if (target == null) {
      return;
    }
    fireTimer = 0;
    game.playSfx('turret',
        volume: 0.34, minGap: const Duration(milliseconds: 120));
    final baseDirection = target - center;
    final needleNest = branchId == 'needle_nest';
    final shots = needleNest
        ? (evolved ? const [-0.14, 0.0, 0.14] : const [-0.08, 0.08])
        : (evolved ? const [-0.08, 0.08] : const [0.0]);
    for (final angle in shots) {
      game.add(
        game._makeBullet(
          origin: center.clone() - Vector2.all(3),
          direction: angle == 0.0
              ? baseDirection
              : game._rotateVector(baseDirection, angle),
          damage: damage,
          speed: needleNest ? 460 : (evolved ? 420 : 385),
          bulletSize: needleNest ? 7.2 : (evolved ? 8.4 : 7.8),
          pierce: 0,
          color: const Color(0xFFD8F3DC),
          visualStyle:
              needleNest ? BulletVisualStyle.needle : BulletVisualStyle.orb,
        ),
      );
    }
  }
}

class BurstBeaconComponent extends PositionComponent
    with HasGameReference<SquareShooterGame> {
  BurstBeaconComponent({
    required super.position,
    required this.damage,
    required this.lifetime,
    required this.fireInterval,
    required this.projectileSpeed,
    required this.includeDiagonals,
    this.evolved = false,
  }) : super(size: Vector2.all(22));

  final int damage;
  final double fireInterval;
  final double projectileSpeed;
  final bool includeDiagonals;
  final bool evolved;
  double lifetime;
  double fireTimer = 0;

  @override
  Vector2 get center => position + size / 2;

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(5)),
      Paint()..color = const Color(0xFF74C69D),
    );
    final paint = Paint()
      ..color = const Color(0xFF081C15)
      ..strokeWidth = 2;
    canvas.drawLine(
        Offset(size.x / 2, 3), Offset(size.x / 2, size.y - 3), paint);
    canvas.drawLine(
        Offset(3, size.y / 2), Offset(size.x - 3, size.y / 2), paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.canPlayerAttack) {
      return;
    }
    lifetime -= dt;
    if (lifetime <= 0) {
      removeFromParent();
      return;
    }
    fireTimer += dt;
    if (fireTimer < fireInterval) {
      return;
    }
    fireTimer = 0;
    final directions = <Vector2>[
      Vector2(1, 0),
      Vector2(-1, 0),
      Vector2(0, 1),
      Vector2(0, -1),
      if (includeDiagonals) ...[
        Vector2(1, 1),
        Vector2(-1, 1),
        Vector2(1, -1),
        Vector2(-1, -1),
      ],
    ];
    for (final direction in directions) {
      game.add(
        game._makeBullet(
          origin: center.clone() - Vector2.all(3),
          direction: direction,
          damage: damage,
          speed: projectileSpeed,
          bulletSize: evolved ? 7 : 6.5,
          color: const Color(0xFFA9DEF9),
        ),
      );
    }
  }
}

class LineDriveComponent extends MiniWeaponAttachmentComponent {
  LineDriveComponent({
    required this.level,
    required this.evolved,
    required this.branchId,
    required super.tint,
    required super.damage,
    required double sizeValue,
  }) : super(sizeValue: Vector2(sizeValue, 18 + level * 2.4));

  final int level;
  final bool evolved;
  final String? branchId;
  Vector2 direction = Vector2(1, 0);

  @override
  void render(Canvas canvas) {
    final angle = math.atan2(direction.y, direction.x);
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(angle);
    final sprite =
        game.effectArt('beam') ?? game.miniWeaponArt(MiniWeaponType.lineDrive);
    if (sprite != null) {
      game.drawSpriteRect(
        canvas,
        sprite,
        Rect.fromCenter(
          center: Offset.zero,
          width: size.x,
          height: size.y,
        ),
        alpha: evolved ? 1 : 0.92,
      );
      canvas.restore();
      return;
    }
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y),
      const Radius.circular(4),
    );
    canvas.drawRRect(body, Paint()..color = tint.withValues(alpha: 0.55));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(size.x * 0.18, 0),
            width: size.x * 0.35,
            height: size.y * 0.52),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF081C15),
    );
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.canPlayerAttack) {
      return;
    }
    final currentPlayer = game.player;
    if (currentPlayer == null) {
      return;
    }
    direction = currentPlayer.lastFacingDirection.length2 == 0
        ? Vector2(1, 0)
        : currentPlayer.lastFacingDirection.normalized();
    position = currentPlayer.center + direction * (30 + level * 5) - size / 2;
    if (hitCooldown <= 0) {
      final sweepBlade = branchId == 'sweep_blade';
      final sporeCutter = branchId == 'spore_cutter';
      final primaryRadius =
          104.0 + level * 20 + (evolved ? 22 : 0) + (sweepBlade ? 24 : 0);
      final primaryThreshold = (0.76 -
              level * 0.040 -
              (evolved ? 0.05 : 0) -
              (sweepBlade ? 0.10 : 0))
          .clamp(0.30, 0.90);
      final hit = game.damageThreatsInArc(
        center: currentPlayer.center,
        direction: direction,
        radius: primaryRadius,
        dotThreshold: primaryThreshold,
        damage: damage,
        knockback: 7 + level * 1.4 + (sweepBlade ? 3 : 0),
      );
      if (level >= 5 || evolved) {
        game.damageThreatsInArc(
          center: currentPlayer.center + direction * (20 + level * 3),
          direction: direction,
          radius: 56 + level * 12 + (evolved ? 10 : 0),
          dotThreshold: 0.78,
          damage: math.max(1, damage - 1) + (evolved ? 1 : 0),
          knockback: 5.0 + level,
        );
      }
      if (sweepBlade) {
        game.damageThreatsInArc(
          center: currentPlayer.center,
          direction: game._rotateVector(direction, 0.24),
          radius: 78 + level * 13 + (evolved ? 12 : 0),
          dotThreshold: 0.46,
          damage: math.max(1, damage - 1),
          knockback: 6.0 + level,
        );
        game.damageThreatsInArc(
          center: currentPlayer.center,
          direction: game._rotateVector(direction, -0.24),
          radius: 78 + level * 13 + (evolved ? 12 : 0),
          dotThreshold: 0.46,
          damage: math.max(1, damage - 1),
          knockback: 6.0 + level,
        );
      }
      if (level >= 6) {
        game.damageThreatsInArc(
          center: currentPlayer.center,
          direction: direction,
          radius: 68 + level * 13 + (evolved ? 16 : 0),
          dotThreshold: 0.10,
          damage: math.max(1, damage - 1),
          knockback: 5.0 + level,
        );
      }
      if (sporeCutter && hit) {
        game.add(
          SporeTrailPatchComponent(
            position: currentPlayer.center +
                direction * (26 + level * 5) -
                Vector2.all(13),
            damage: math.max(1, damage - 1),
            lifetime: 1.35 + level * 0.10,
            radius: 28 + level * 2.5,
          ),
        );
        if (level >= 5 || evolved) {
          game.add(
            SporeTrailPatchComponent(
              position: currentPlayer.center +
                  direction * (48 + level * 7) -
                  Vector2.all(12),
              damage: math.max(1, damage - 1),
              lifetime: 1.0 + level * 0.08,
              radius: 24 + level * 2,
            ),
          );
        }
      }
      game.playSfx('beam',
          volume: 0.36, minGap: const Duration(milliseconds: 120));
      hitCooldown = math.max(0.06, 0.18 - level * 0.014 - (evolved ? 0.03 : 0));
    }
  }
}

class SnapPrismComponent extends MiniWeaponAttachmentComponent {
  SnapPrismComponent({
    required this.level,
    required this.evolved,
    required this.branchId,
    required super.tint,
    required super.damage,
  }) : super(sizeValue: Vector2.all(18));

  final int level;
  final bool evolved;
  final String? branchId;
  Vector2 _lastDirection = Vector2(1, 0);
  double _turnCharge = 0;

  Vector2 _rotate(Vector2 input, double radians) {
    final cosTheta = math.cos(radians);
    final sinTheta = math.sin(radians);
    return Vector2(
      input.x * cosTheta - input.y * sinTheta,
      input.x * sinTheta + input.y * cosTheta,
    );
  }

  void _spawnArcBurst(
    Vector2 center,
    Vector2 direction, {
    required int damageValue,
    required double radiusValue,
    double alpha = 1,
  }) {
    game.add(
      VanguardArcWaveComponent(
        centerPoint: center,
        direction: direction,
        tint: tint.withValues(alpha: alpha.clamp(0.0, 1.0)),
        damage: damageValue,
        radius: radiusValue,
      ),
    );
  }

  void _spawnFanPattern(
    Vector2 center,
    Vector2 direction, {
    required int damageValue,
    required double radiusValue,
    required bool includeOuter,
    double alpha = 1,
  }) {
    final normalized =
        direction.length2 == 0 ? Vector2(1, 0) : direction.normalized();
    _spawnArcBurst(
      center,
      normalized,
      damageValue: damageValue,
      radiusValue: radiusValue,
      alpha: alpha,
    );
    const innerAngle = 0.26;
    for (final sign in const [-1.0, 1.0]) {
      _spawnArcBurst(
        center,
        _rotate(normalized, innerAngle * sign),
        damageValue: math.max(1, damageValue - 1),
        radiusValue: radiusValue - 6,
        alpha: alpha * 0.92,
      );
    }
    if (includeOuter) {
      const outerAngle = 0.48;
      for (final sign in const [-1.0, 1.0]) {
        _spawnArcBurst(
          center,
          _rotate(normalized, outerAngle * sign),
          damageValue: math.max(1, damageValue - 1),
          radiusValue: radiusValue - 12,
          alpha: alpha * 0.82,
        );
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final sprite = game.miniWeaponArt(MiniWeaponType.snapPrism);
    if (sprite != null) {
      game.drawSpriteRect(
        canvas,
        sprite,
        Rect.fromLTWH(0, 0, size.x, size.y),
        alpha: evolved ? 1 : 0.94,
      );
      return;
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(4)),
      Paint()..color = tint.withValues(alpha: 0.28),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.canPlayerAttack) {
      return;
    }
    final currentPlayer = game.player;
    if (currentPlayer == null) {
      return;
    }
    position = currentPlayer.center - size / 2;
    final currentDirection = currentPlayer.lastFacingDirection.length2 == 0
        ? _lastDirection
        : currentPlayer.lastFacingDirection.normalized();
    if (hitCooldown <= 0) {
      final dot =
          _lastDirection.normalized().dot(currentDirection).clamp(-1.0, 1.0);
      final angleDelta = math.acos(dot);
      _turnCharge =
          (_turnCharge + angleDelta * 1.15 - dt * 0.85).clamp(0.0, 2.6);
      final threshold =
          math.max(0.20, 0.50 - level * 0.045 - (evolved ? 0.05 : 0));
      final chargedThreshold = math.max(0.34, threshold + 0.10 - level * 0.012);
      if (angleDelta >= threshold || _turnCharge >= chargedThreshold) {
        final crosswind = branchId == 'crosswind';
        final echoFan = branchId == 'echo_fan';
        final center = currentPlayer.center.clone();
        final baseRadius = 84.0 + level * 13 + (evolved ? 16 : 0);
        _spawnFanPattern(
          center,
          currentDirection,
          damageValue: damage,
          radiusValue: baseRadius,
          includeOuter: level >= 3 || evolved,
        );
        if (crosswind || level >= 2 || evolved) {
          final perpendicular =
              Vector2(-currentDirection.y, currentDirection.x);
          _spawnArcBurst(
            center,
            perpendicular,
            damageValue: math.max(1, damage - (crosswind ? 0 : 1)),
            radiusValue: evolved ? 84 : 66,
            alpha: 0.80,
          );
          if (crosswind) {
            _spawnArcBurst(
              center,
              -perpendicular,
              damageValue: math.max(1, damage - 1),
              radiusValue: evolved ? 84 : 66,
              alpha: 0.75,
            );
          }
        }
        if (echoFan) {
          _spawnFanPattern(
            center,
            currentDirection,
            damageValue: math.max(1, damage - 1),
            radiusValue: 62 + level * 8 + (evolved ? 8 : 0),
            includeOuter: level >= 5,
            alpha: 0.66,
          );
        }
        if (level >= 6) {
          _spawnFanPattern(
            center,
            -currentDirection,
            damageValue: 1,
            radiusValue: 42 + level * 7 + (evolved ? 4 : 0),
            includeOuter: false,
            alpha: 0.58,
          );
        }
        game.playSfx('fan',
            volume: 0.4, minGap: const Duration(milliseconds: 140));
        _turnCharge = 0;
        hitCooldown =
            math.max(0.14, 0.46 - level * 0.045 - (evolved ? 0.08 : 0));
      }
    }
    _lastDirection = currentDirection;
  }
}

class OrbitCellComponent extends MiniWeaponAttachmentComponent {
  OrbitCellComponent({
    required this.orbitIndex,
    required this.orbitCount,
    required this.radius,
    required this.speedFactor,
    required super.tint,
    required super.damage,
    required double sizeValue,
    this.angleOffset = 0,
  }) : super(sizeValue: Vector2.all(sizeValue));

  final int orbitIndex;
  final int orbitCount;
  final double radius;
  final double speedFactor;
  final double angleOffset;
  @override
  double angle = 0;

  @override
  void render(Canvas canvas) {
    final sprite = game.effectArt('orbit');
    if (sprite != null) {
      game.drawSpriteRect(
        canvas,
        sprite,
        Rect.fromLTWH(0, 0, size.x, size.y),
      );
      return;
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(4)),
      Paint()..color = tint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(size.x / 2, size.y / 2),
            width: size.x * 0.34,
            height: size.y * 0.34),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF081C15),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.canPlayerAttack) {
      return;
    }
    final currentPlayer = game.player;
    if (currentPlayer == null) {
      return;
    }
    angle += dt * speedFactor;
    final theta = angleOffset +
        angle +
        (math.pi * 2 * orbitIndex) / math.max(1, orbitCount);
    final offset = Vector2(math.cos(theta), math.sin(theta)) * radius;
    position = currentPlayer.center + offset - size / 2;
    if (hitCooldown <= 0 &&
        game.damageThreatsInCircle(
          center,
          size.x * 0.82,
          damage,
          knockback: 4,
        )) {
      hitCooldown = 0.18;
    }
  }
}

class PulseRingWaveComponent extends PositionComponent
    with HasGameReference<SquareShooterGame> {
  PulseRingWaveComponent({
    required Vector2 centerPoint,
    required this.tint,
    required this.damage,
    required this.maxRadius,
    this.knockback = 0,
  })  : _centerPoint = centerPoint,
        super(position: centerPoint, size: Vector2.zero());

  final Vector2 _centerPoint;
  final Color tint;
  final int damage;
  final double maxRadius;
  final double knockback;
  final Set<int> _hitIds = <int>{};
  double currentRadius = 10;

  @override
  void render(Canvas canvas) {
    final sprite = game.effectArt('ring');
    if (sprite != null) {
      final side = currentRadius * 2;
      game.drawSpriteRect(
        canvas,
        sprite,
        Rect.fromCenter(
          center: Offset.zero,
          width: side,
          height: side,
        ),
        alpha: 0.52,
      );
      return;
    }
    final paint = Paint()
      ..color = tint.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset.zero,
            width: currentRadius * 2,
            height: currentRadius * 2),
        const Radius.circular(18),
      ),
      paint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.canPlayerAttack) {
      return;
    }
    currentRadius += 240 * dt;
    game.damageThreatsInCircle(
      _centerPoint,
      currentRadius,
      damage,
      alreadyHit: _hitIds,
      knockback: knockback,
    );
    if (currentRadius >= maxRadius) {
      removeFromParent();
    }
  }
}

class VanguardArcWaveComponent extends PositionComponent
    with HasGameReference<SquareShooterGame> {
  VanguardArcWaveComponent({
    required Vector2 centerPoint,
    required this.direction,
    required this.tint,
    required this.damage,
    required this.radius,
    this.knockback = 3,
  })  : _centerPoint = centerPoint,
        super(position: centerPoint, size: Vector2.zero());

  final Vector2 _centerPoint;
  final Vector2 direction;
  final Color tint;
  final int damage;
  final double radius;
  final double knockback;
  final Set<int> _hitIds = <int>{};
  double life = 0.18;

  @override
  void render(Canvas canvas) {
    final dir = direction.length2 == 0 ? Vector2(1, 0) : direction.normalized();
    final angle = math.atan2(dir.y, dir.x);
    canvas.save();
    canvas.rotate(angle);
    final sprite = game.effectArt('arc');
    if (sprite != null) {
      game.drawSpriteRect(
        canvas,
        sprite,
        Rect.fromCenter(
          center: Offset(radius * 0.48, 0),
          width: radius * 1.1,
          height: radius * 0.82,
        ),
        alpha: 0.72,
      );
      canvas.restore();
      return;
    }
    final path = Path()
      ..moveTo(0, 0)
      ..arcTo(Rect.fromCircle(center: Offset.zero, radius: radius), -0.55, 1.1,
          false)
      ..close();
    canvas.drawPath(path, Paint()..color = tint.withValues(alpha: 0.32));
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.canPlayerAttack) {
      return;
    }
    life -= dt;
    game.damageThreatsInArc(
      center: _centerPoint,
      direction: direction,
      radius: radius,
      dotThreshold: 0.42,
      damage: damage,
      alreadyHit: _hitIds,
      knockback: knockback,
    );
    if (life <= 0) {
      removeFromParent();
    }
  }
}

class SporeTrailPatchComponent extends PositionComponent
    with HasGameReference<SquareShooterGame> {
  SporeTrailPatchComponent({
    required super.position,
    required this.damage,
    required this.lifetime,
    required this.radius,
  }) : super(size: Vector2.all(radius));

  final int damage;
  final double radius;
  double lifetime;
  double tickTimer = 0;

  @override
  Vector2 get center => position + size / 2;

  @override
  void render(Canvas canvas) {
    final alpha = lifetime.clamp(0.0, 1.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(6),
      ),
      Paint()
        ..color =
            const Color(0xFF74C69D).withValues(alpha: 0.16 + alpha * 0.20),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.canPlayerAttack) {
      return;
    }
    lifetime -= dt;
    tickTimer += dt;
    if (tickTimer >= 0.30) {
      tickTimer = 0;
      game.damageThreatsInCircle(center, radius * 0.58, damage);
    }
    if (lifetime <= 0) {
      removeFromParent();
    }
  }
}

class BioMineComponent extends PositionComponent
    with HasGameReference<SquareShooterGame> {
  BioMineComponent({
    required super.position,
    required this.damage,
    required this.triggerRadius,
  }) : super(size: Vector2.all(16));

  final int damage;
  final double triggerRadius;
  double armTimer = 0.35;
  double life = 6.0;

  @override
  Vector2 get center => position + size / 2;

  @override
  void render(Canvas canvas) {
    final sprite = game.effectArt('mine');
    if (sprite != null) {
      game.drawSpriteRect(
        canvas,
        sprite,
        Rect.fromLTWH(0, 0, size.x, size.y),
        alpha: armTimer <= 0 ? 1 : 0.82,
      );
      return;
    }
    final armed = armTimer <= 0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(4),
      ),
      Paint()
        ..color = armed ? const Color(0xFF95D5B2) : const Color(0xFF2D6A4F),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(size.x / 2, size.y / 2), width: 6, height: 6),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF081C15),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.canPlayerAttack) {
      return;
    }
    life -= dt;
    armTimer -= dt;
    if (life <= 0) {
      removeFromParent();
      return;
    }
    if (armTimer > 0) {
      return;
    }
    final hit = game.damageThreatsInCircle(
      center,
      triggerRadius,
      damage,
      knockback: 10,
    );
    if (hit && !game.reducedEffectsActive) {
      add(
        PulseRingWaveComponent(
          centerPoint: center.clone(),
          tint: const Color(0xFFB7E4C7),
          damage: 1,
          maxRadius: triggerRadius + 18,
          knockback: 7,
        ),
      );
      removeFromParent();
    }
  }
}

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  static const id = 'hud';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.uiTick,
      builder: (_, __, ___) {
        final currentPlayer = game.player;
        final activeBoss = game.activeBossComponent;
        return SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 8,
                left: 8,
                width: 248,
                child: Card(
                  color: const Color(0xFF081C15).withValues(alpha: 0.78),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            _stat(game.scoreLabel, '${game.currentScore}'),
                            _stat('Round', '${game.currentRound}'),
                            _stat('Lives', _livesText(game.lives)),
                            _stat('Timer', game.timerLabel),
                            _stat(
                              'Dash',
                              currentPlayer == null
                                  ? '--'
                                  : currentPlayer.dashCooldownRemaining <= 0
                                      ? 'Ready'
                                      : currentPlayer.dashCooldownRemaining
                                          .toStringAsFixed(1),
                            ),
                            _stat('Shield', '${game.shieldCharges}'),
                            if (game.enemyFrenzyTimer > 0)
                              _stat('Frenzy',
                                  '${game.enemyFrenzyTimer.toStringAsFixed(1)}s'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (game.fpsMeterVisible) ...[
                          Row(
                            children: [
                              const Text(
                                'FPS',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white70),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: game.fpsProgress,
                                    minHeight: 5,
                                    backgroundColor: Colors.white12,
                                    valueColor: AlwaysStoppedAnimation(
                                        game.fpsBarColor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                game.currentFps <= 0
                                    ? '--'
                                    : game.currentFps.round().toString(),
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: game.levelProgress.clamp(0.0, 1.0),
                            minHeight: 7,
                            backgroundColor: Colors.white12,
                            valueColor:
                                const AlwaysStoppedAnimation(Color(0xFF74C69D)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Samples - Combat level ${game.combatLevelsThisRound}/${game.combatLevelCapLabel}',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFFD8F3DC)),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: game.sampleProgressFraction,
                            minHeight: 6,
                            backgroundColor: Colors.white12,
                            valueColor:
                                const AlwaysStoppedAnimation(Color(0xFF80FFDB)),
                          ),
                        ),
                        if (game.isDeveloperMode) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3A0F18),
                              borderRadius: BorderRadius.circular(999),
                              border:
                                  Border.all(color: const Color(0xFFEF476F)),
                            ),
                            child: const Text(
                              'Developer Mode - Unranked Sandbox',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                        if (activeBoss != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            activeBoss.bossType.title,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD8F3DC)),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: game.bossHealthFraction,
                              minHeight: 8,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFFEF476F)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: _VirtualJoystick(onChanged: game.setTouchDirection),
              ),
              if (game.bannerText != null)
                Positioned(
                  top: 84,
                  left: 24,
                  right: 24,
                  child: Center(
                    child: Card(
                      color: const Color(0xFF081C15).withValues(alpha: 0.84),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Text(
                          game.bannerText!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 20,
                bottom: 126,
                child: FilledButton.tonal(
                  onPressed:
                      game.isGameplayActive ? game.openPauseSummary : null,
                  child: const Text('Pause +\nSummary',
                      textAlign: TextAlign.center),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 20,
                child: FilledButton.tonal(
                  onPressed: game.isGameplayActive ? game.triggerDash : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(92, 92),
                    shape: const CircleBorder(),
                  ),
                  child: const Text('DASH'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _livesText(int count) {
    if (count <= 0) {
      return '0';
    }
    return List<String>.filled(count, '❤').join(' ');
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.white70)),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class TitleOverlay extends StatelessWidget {
  const TitleOverlay({super.key, required this.game});

  static const id = 'title';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.uiTick,
      builder: (_, __, ___) {
        return Material(
          color: const Color(0xCC04110D),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _TitleBackdropPainter(
                          biologyPackEnabled: game.biologyResourcePackEnabled,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -40,
                      left: -20,
                      child: _glowOrb(
                        220,
                        const Color(0x332EC4B6),
                      ),
                    ),
                    Positioned(
                      top: 160,
                      right: -40,
                      child: _glowOrb(
                        260,
                        const Color(0x22FFD166),
                      ),
                    ),
                    Positioned(
                      bottom: -80,
                      left: 260,
                      child: _glowOrb(
                        280,
                        const Color(0x1FC4F1BE),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: LayoutBuilder(
                        builder: (context, constraints) =>
                            _buildDashboard(context, constraints),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboard(BuildContext context, BoxConstraints constraints) {
    const designWidth = 1120.0;
    const designHeight = 920.0;
    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: designWidth,
        height: designHeight,
        child: _buildWideDashboard(context),
      ),
    );
  }

  Widget _buildWideDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeroPanel(context, false),
        const SizedBox(height: 14),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 5, child: _buildPrimaryPlayPanel(context)),
              const SizedBox(width: 14),
              Expanded(flex: 4, child: _buildHomeHubPanel(context)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _glowOrb(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: color.a * 0.2),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroPanel(BuildContext context, bool compact) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: compact ? 140 : 190,
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF235C52), width: 1.2),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10332D),
            Color(0xFF0C1E1A),
            Color(0xFF081714),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0x1910BEB0),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF1E5D52)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Charlotte - HS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFBDEDE5),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Interactive Biology Collection',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9FD9D2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Biology Game',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: compact ? 42 : 52,
                  height: 0.95,
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 6),
                const Text(
                  'Survive, learn, upgrade mini-weapons, and clear boss gates.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.25,
                    color: Color(0xFFD8F3DC),
                  ),
                ),
              ],
            ],
          )),
          const SizedBox(width: 18),
          SizedBox(
            width: compact ? 250 : 360,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickMetric(
                  label: 'Checkpoint',
                  value: game.hasSavedCheckpoint ? 'Saved' : 'None',
                ),
                _QuickMetric(
                  label: 'Research Points',
                  value: '${game.researchPoints}',
                ),
                _QuickMetric(
                  label: 'Graphics',
                  value: game.graphicsQualityLabel,
                ),
                _QuickMetric(
                  label: 'Visual Pack',
                  value: game.visualResourcePackLabel,
                ),
                _QuickMetric(
                  label: 'Character',
                  value: game.selectedCharacterFrame.title,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryPlayPanel(BuildContext context, {bool compact = false}) {
    const accent = Color(0xFF2EC4B6);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: EdgeInsets.all(compact ? 16 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF102621),
              accent.withValues(alpha: 0.12),
              const Color(0xFF071713),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accent.withValues(alpha: 0.42)),
                  ),
                  child: const Icon(Icons.biotech_rounded,
                      color: accent, size: 28),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Biology Game',
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w900)),
                      SizedBox(height: 2),
                      Text('-Dheena Kumar',
                          style:
                              TextStyle(fontSize: 13, color: Colors.white70)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: accent.withValues(alpha: 0.34)),
                  ),
                  child: const Text(
                    'Professional Build',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'A biology-themed survivor arena with lessons, boss gates, and buildcrafting.',
              style: TextStyle(fontSize: 14, height: 1.35),
            ),
            const SizedBox(height: 14),
            const Text('Difficulty',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final difficulty in GameDifficulty.values)
                  ChoiceChip(
                    label: Text(difficulty.title),
                    selected: game.selectedDifficulty == difficulty,
                    onSelected: (_) => game.setSelectedDifficulty(difficulty),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Restart Game starts on ${game.selectedDifficulty.title}. Continue keeps the saved checkpoint difficulty.',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            if (!compact) ...[
              const SizedBox(height: 14),
              Expanded(child: _buildCourseFlowPanel()),
              const SizedBox(height: 14),
            ] else
              const Spacer(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed:
                      game.hasSavedCheckpoint ? game.handleTitleStart : null,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Continue'),
                ),
                OutlinedButton.icon(
                  onPressed: game.startFreshCourse,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Restart Game'),
                ),
                OutlinedButton.icon(
                  onPressed: game.startInteractiveTutorial,
                  icon: const Icon(Icons.sports_esports_rounded),
                  label: const Text('Tutorial'),
                ),
                OutlinedButton.icon(
                  onPressed: game.openTutorial,
                  icon: const Icon(Icons.menu_book_rounded),
                  label: const Text('Detailed Tutorial'),
                ),
                OutlinedButton.icon(
                  onPressed: game.startDeveloperMode,
                  icon: const Icon(Icons.science_rounded),
                  label: const Text('Developer Mode'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseFlowPanel() {
    const accent = Color(0xFF2EC4B6);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 180;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Session Roadmap',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: accent.withValues(alpha: 0.30)),
                    ),
                    child: const Text(
                      '30 second rounds',
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 6 : 10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCourseStepCard(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Draft',
                        body: 'Pick one mini-weapon before the run starts.',
                        accent: accent,
                        compact: compact,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCourseStepCard(
                        icon: Icons.bolt_rounded,
                        title: 'Survive',
                        body: 'Clear each wave and earn one weapon upgrade.',
                        accent: const Color(0xFFFFD166),
                        compact: compact,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCourseStepCard(
                        icon: Icons.psychology_alt_rounded,
                        title: 'Boss Gate',
                        body: 'Beat the boss, unlock a mutation, then learn.',
                        accent: const Color(0xFFFF8C42),
                        compact: compact,
                      ),
                    ),
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 8),
                const Text(
                  'Main actions stay here. Deeper options open only when you need them.',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCourseStepCard({
    required IconData icon,
    required String title,
    required String body,
    required Color accent,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisAlignment:
            compact ? MainAxisAlignment.center : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: compact ? 18 : 22),
          SizedBox(height: compact ? 4 : 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 3),
            Text(
              body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHomeHubPanel(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(child: _buildSettingsSummaryPanel(context)),
              const SizedBox(width: 12),
              Expanded(child: _buildCharacterSummaryPanel(context)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(flex: 2, child: _buildModeStrip(context)),
        const SizedBox(height: 12),
        _buildHomeDesignNote(),
      ],
    );
  }

  Widget _buildSettingsSummaryPanel(BuildContext context) {
    const accent = Color(0xFF2EC4B6);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _openSettingsDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.speed_rounded, color: accent),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Performance Settings',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: accent.withValues(alpha: 0.86)),
                ],
              ),
              const SizedBox(height: 12),
              _buildSummaryLine(
                'Graphics',
                '${game.graphicsQualityLabel} quality',
              ),
              _buildSummaryLine(
                'Biology Resource Pack',
                game.visualResourcePackLabel,
              ),
              _buildSummaryLine(
                'Frame pacing',
                game.framePacingLabel,
              ),
              const Spacer(),
              Text(
                game.currentFps <= 0
                    ? 'Open settings to tune graphics and effects.'
                    : '${game.currentFps.round()} FPS now. Open settings to tune graphics and effects.',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${game.maxActiveEnemies} enemies / ${game.maxActivePlayerProjectiles} shots',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ),
                  const Text(
                    'Open',
                    style: TextStyle(
                      color: accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeDesignNote() {
    return SizedBox(
      height: 126,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF2EC4B6).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2EC4B6).withValues(alpha: 0.28),
                  ),
                ),
                child: const Icon(Icons.dashboard_customize_rounded,
                    color: Color(0xFF2EC4B6)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cleaner Home',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Advanced options are tucked into focused pages so the launcher stays fast to scan.',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterSummaryPanel(BuildContext context) {
    const accent = Color(0xFFFFD166);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_rounded, color: accent),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Character Frame',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text('${game.researchPoints} Research Points',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, color: accent, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              game.selectedCharacterFrame.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              _characterTraitText(game.selectedCharacterFrame),
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () => _openCharacterFrameDialog(context),
                child: const Text('Manage Frames'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeStrip(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildModeTile(
            context,
            title: 'Blood Vessel Defense',
            subtitle: 'Prototype tower defense',
            icon: Icons.shield_rounded,
            accent: const Color(0xFFFF8C42),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BloodDefensePrototypeScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildModeTile(
            context,
            title: 'Coming Soon',
            subtitle: 'Future game slot',
            icon: Icons.science_rounded,
            accent: const Color(0xFF8D99AE),
            onPressed: () =>
                _openLauncherDetails(context, launcherEntries.last),
            actionLabel: 'Learn More',
          ),
        ),
      ],
    );
  }

  Widget _buildModeTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required VoidCallback onPressed,
    String actionLabel = 'Play Prototype',
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: accent, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.white70)),
              const Spacer(),
              Text(actionLabel,
                  style: TextStyle(
                      fontSize: 12,
                      color: accent,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }

  void _openCharacterFrameDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Character Frame'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: _buildCharacterPicker(const Color(0xFFFFD166)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openSettingsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Performance Settings'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildVisualPackToggle(const Color(0xFF2EC4B6)),
                const SizedBox(height: 12),
                _PerformanceSettingsPanel(
                  game: game,
                  accent: const Color(0xFF2EC4B6),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openLauncherDetails(BuildContext context, LauncherEntry entry) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(14),
        content: SizedBox(
          width: 520,
          child: _buildLauncherCard(context, entry, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterPicker(Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x2210BEB0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Character Frame',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              Text(
                '${game.researchPoints} RP',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Spend Research Points to unlock easier-run frames. Purchased frames stay unlocked permanently.',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              for (final frame in CharacterFrame.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _characterShopRow(frame, accent),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _characterShopRow(CharacterFrame frame, Color accent) {
    final unlocked = game.isCharacterFrameUnlocked(frame);
    final selected = game.selectedCharacterFrame == frame;
    final canBuy = game.canPurchaseCharacterFrame(frame);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: selected
            ? accent.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? accent.withValues(alpha: 0.58)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  frame.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  frame.description,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 3),
                Text(
                  _characterTraitText(frame),
                  style: TextStyle(
                    fontSize: 11,
                    color: accent.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (selected)
            const Text('Selected',
                style: TextStyle(fontWeight: FontWeight.w800))
          else if (unlocked)
            OutlinedButton(
              onPressed: () => game.selectCharacterFrame(frame),
              child: const Text('Select'),
            )
          else
            OutlinedButton(
              onPressed:
                  canBuy ? () => game.purchaseCharacterFrame(frame) : null,
              child: Text('${frame.unlockCost} RP'),
            ),
        ],
      ),
    );
  }

  String _characterTraitText(CharacterFrame frame) {
    final traits = <String>[];
    if (frame.speedMultiplier != 1.0) {
      final percent = ((frame.speedMultiplier - 1.0) * 100).round();
      traits.add(percent > 0 ? '+$percent% speed' : '$percent% speed');
    }
    if (frame.bonusLives > 0) {
      traits.add('+${frame.bonusLives} life');
    }
    if (frame.startingShields > 0) {
      traits.add('+${frame.startingShields} shield');
    }
    if (frame.sampleMagnetBonus > 0) {
      traits.add('+${frame.sampleMagnetBonus.round()} sample range');
    }
    return traits.isEmpty ? 'No stat changes' : traits.join('  /  ');
  }

  Widget _buildVisualPackToggle(Color accent) {
    Widget iconBox() {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.34)),
        ),
        child: Icon(Icons.biotech_rounded, color: accent),
      );
    }

    Widget copy() {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biology Resource Pack',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 3),
          Text(
            'Optional microscope-style enemies, bosses, and arena details.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      );
    }

    Widget toggle() {
      return Switch.adaptive(
        value: game.biologyResourcePackEnabled,
        activeThumbColor: accent,
        activeTrackColor: accent.withValues(alpha: 0.34),
        onChanged: game.setBiologyResourcePackEnabled,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 430;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.24)),
          ),
          child: narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        iconBox(),
                        const Spacer(),
                        toggle(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    copy(),
                  ],
                )
              : Row(
                  children: [
                    iconBox(),
                    const SizedBox(width: 12),
                    Expanded(child: copy()),
                    const SizedBox(width: 10),
                    toggle(),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildLauncherCard(
      BuildContext context, LauncherEntry entry, bool compact) {
    final available = entry.status == LauncherEntryStatus.available;
    final accent = switch (entry.gameId) {
      LauncherGameId.squareShooter => const Color(0xFF2EC4B6),
      LauncherGameId.bloodDefense => const Color(0xFFFF8C42),
      null => const Color(0xFF6C7A89),
    };
    final titleIcon = switch (entry.gameId) {
      LauncherGameId.squareShooter => Icons.biotech_rounded,
      LauncherGameId.bloodDefense => Icons.shield_rounded,
      null => Icons.science_rounded,
    };
    final statusLabel = switch (entry.status) {
      LauncherEntryStatus.available => 'Available Now',
      LauncherEntryStatus.comingSoon => 'Coming Soon',
    };
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF102621),
              accent.withValues(alpha: 0.10),
              const Color(0xFF0B1A17),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accent.withValues(alpha: 0.42)),
                    ),
                    child: Icon(titleIcon, color: accent, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.title,
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                        if (entry.credit != null) ...[
                          const SizedBox(height: 4),
                          Text(entry.credit!,
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.white70)),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: accent.withValues(alpha: 0.34)),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                entry.description,
                style: const TextStyle(fontSize: 16, height: 1.45),
              ),
              const SizedBox(height: 16),
              if (available &&
                  entry.gameId == LauncherGameId.squareShooter) ...[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _LauncherMetric(
                      label: 'Checkpoint',
                      value: game.hasSavedCheckpoint ? 'Saved' : 'None',
                      accent: accent,
                    ),
                    _LauncherMetric(
                      label: 'Course',
                      value: '${game.bestCourseScore}',
                      accent: accent,
                    ),
                    _LauncherMetric(
                      label: 'Mastery',
                      value: '${game.bestMasteryScore}',
                      accent: accent,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text('Difficulty',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final difficulty in GameDifficulty.values)
                      ChoiceChip(
                        label: Text(difficulty.title),
                        selected: game.selectedDifficulty == difficulty,
                        onSelected: (_) =>
                            game.setSelectedDifficulty(difficulty),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Restart Game starts on ${game.selectedDifficulty.title}. Continue keeps the saved checkpoint difficulty.',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 14),
                _buildVisualPackToggle(accent),
                const SizedBox(height: 14),
                _PerformanceSettingsPanel(game: game, accent: accent),
                const SizedBox(height: 14),
                _buildCharacterPicker(accent),
                const SizedBox(height: 16),
                const Text('Highlights',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text(
                    '- Lesson + quiz + mini-weapon draft after every round'),
                const Text(
                    '- 30-second survivor rounds with one sample upgrade each wave'),
                const Text('- Easy, Normal, and Hard difficulty modes'),
                const Text(
                    '- Boss gates every third round with premium mini-weapon chest payoffs'),
                const Text('- Developer sandbox available separately'),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: game.hasSavedCheckpoint
                          ? game.handleTitleStart
                          : null,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Continue'),
                    ),
                    OutlinedButton.icon(
                      onPressed: game.startFreshCourse,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Restart Game'),
                    ),
                    OutlinedButton.icon(
                      onPressed: game.startDeveloperMode,
                      icon: const Icon(Icons.science_rounded),
                      label: const Text('Developer Mode'),
                    ),
                    OutlinedButton.icon(
                      onPressed: game.startInteractiveTutorial,
                      icon: const Icon(Icons.sports_esports_rounded),
                      label: const Text('Tutorial'),
                    ),
                    OutlinedButton.icon(
                      onPressed: game.openTutorial,
                      icon: const Icon(Icons.menu_book_rounded),
                      label: const Text('Detailed Tutorial'),
                    ),
                  ],
                ),
              ] else if (available &&
                  entry.gameId == LauncherGameId.bloodDefense) ...[
                _LauncherMetric(
                  label: 'Status',
                  value: 'Prototype',
                  accent: accent,
                ),
                const SizedBox(height: 12),
                const Text('Highlights',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text(
                    '- Red blood cells follow a vessel path across the map'),
                const Text('- Buy biological defenses on open tissue tiles'),
                const Text('- Three simple tower types with different roles'),
                const Text('- Small, fast prototype for testing the idea'),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const BloodDefensePrototypeScreen(),
                          ),
                        );
                      },
                      child: const Text('Play Prototype'),
                    ),
                  ],
                ),
              ] else ...[
                const Text(
                  'This slot is reserved for a future Queen city IGem game.',
                  style: TextStyle(fontSize: 15, color: Colors.white70),
                ),
                const SizedBox(height: 18),
                OutlinedButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Coming Soon'),
                        content: const Text(
                            'This game is not available yet, but the slot is reserved for a future project.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  ),
                  child: const Text('Learn More'),
                ),
              ],
              const SizedBox(height: 14),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.82),
                      accent.withValues(alpha: 0.18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerformanceSettingsPanel extends StatelessWidget {
  const _PerformanceSettingsPanel({
    required this.game,
    required this.accent,
  });

  final SquareShooterGame game;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final fpsText =
        game.currentFps <= 0 ? 'warming up' : '${game.currentFps.round()} FPS';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.34)),
                ),
                child: Icon(Icons.speed_rounded, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Settings',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Current: ${game.graphicsQualityLabel} graphics, ${game.framePacingLabel}, $fpsText.',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Graphics Quality',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in GraphicsQualityPreset.values)
                ChoiceChip(
                  label: Text(preset.title),
                  selected: game.graphicsQualityPreset == preset,
                  onSelected: (_) => game.setGraphicsQualityPreset(preset),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            game.graphicsQualityPreset.description,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF081C15).withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.18)),
            ),
            child: Text(
              'Active caps: ${game.maxActiveEnemies} enemies, '
              '${game.maxActivePlayerProjectiles} player shots, '
              '${game.maxActiveEnemyProjectiles} enemy shots.',
              style: const TextStyle(fontSize: 12, color: Color(0xFFD8F3DC)),
            ),
          ),
          const SizedBox(height: 10),
          _SettingsSwitchRow(
            title: 'VSync Pacing',
            description:
                'Clamps large frame jumps so movement and collisions stay stable.',
            value: game.vSyncPacingEnabled,
            accent: accent,
            onChanged: game.setVSyncPacingEnabled,
          ),
          _SettingsSwitchRow(
            title: 'Auto Performance Scaling',
            description:
                'Automatically trims visuals and caps if the game drops frames.',
            value: game.autoPerformanceScalingEnabled,
            accent: accent,
            onChanged: game.setAutoPerformanceScalingEnabled,
          ),
          _SettingsSwitchRow(
            title: 'Reduced Effects',
            description:
                'Cuts extra duplicate pulses, mines, and secondary effects first.',
            value: game.reducedEffectsEnabled,
            accent: accent,
            onChanged: game.setReducedEffectsEnabled,
          ),
          _SettingsSwitchRow(
            title: 'FPS Meter',
            description: 'Shows the top-left FPS bar while playing.',
            value: game.fpsMeterVisible,
            accent: accent,
            onChanged: game.setFpsMeterVisible,
          ),
        ],
      ),
    );
  }
}

class _QuickMetric extends StatelessWidget {
  const _QuickMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.white70),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.title,
    required this.description,
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final Color accent;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(description,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch.adaptive(
            value: value,
            activeThumbColor: accent,
            activeTrackColor: accent.withValues(alpha: 0.34),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _TitleBackdropPainter extends CustomPainter {
  const _TitleBackdropPainter({required this.biologyPackEnabled});

  final bool biologyPackEnabled;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final backdropColors = biologyPackEnabled
        ? const [
            Color(0xFF07120F),
            Color(0xFF16352C),
            Color(0xFF210B16),
          ]
        : const [
            Color(0xFF06110F),
            Color(0xFF0F2B26),
            Color(0xFF06110F),
          ];
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, size.height),
          [
            backdropColors[0].withValues(alpha: 0.72),
            backdropColors[1].withValues(alpha: 0.64),
            backdropColors[2].withValues(alpha: 0.78),
          ],
          [0.0, 0.5, 1.0],
        ),
    );

    final gridPaint = Paint()
      ..color = const Color(0xFF74D9C3).withValues(alpha: 0.045)
      ..strokeWidth = 1;
    const gridStep = 44.0;
    for (double x = 0; x <= size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (var lane = 0; lane < 4; lane++) {
      final y = size.height * (0.18 + lane * 0.22);
      final path = Path()
        ..moveTo(-80, y)
        ..cubicTo(
          size.width * 0.22,
          y - 46 - lane * 5,
          size.width * 0.64,
          y + 54 + lane * 3,
          size.width + 80,
          y - 22,
        );
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFB8F7E7).withValues(alpha: 0.055)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 22,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFFFD166).withValues(alpha: 0.06)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.5,
      );
    }

    final nodePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = const Color(0xFF2EC4B6).withValues(alpha: 0.12);
    for (var i = 0; i < 12; i++) {
      final x = (size.width * ((i * 37) % 100) / 100) + (i.isEven ? 18 : -18);
      final y = size.height * (0.12 + ((i * 19) % 76) / 100);
      final radius = 10.0 + (i % 4) * 5;
      canvas.drawCircle(Offset(x, y), radius, nodePaint);
    }

    if (biologyPackEnabled) {
      final membranePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFB8F7E7).withValues(alpha: 0.12);
      final nucleusPaint = Paint()
        ..color = const Color(0xFFFFD166).withValues(alpha: 0.08);
      for (var i = 0; i < 7; i++) {
        final x = size.width * (0.08 + ((i * 23) % 86) / 100);
        final y = size.height * (0.16 + ((i * 31) % 70) / 100);
        final radius = 24.0 + (i % 3) * 9;
        canvas.drawCircle(Offset(x, y), radius, membranePaint);
        canvas.drawCircle(Offset(x - radius * 0.18, y + radius * 0.12),
            radius * 0.28, nucleusPaint);
      }
      final spikePaint = Paint()
        ..color = const Color(0xFFEF476F).withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      for (var i = 0; i < 9; i++) {
        final x = size.width * (0.06 + ((i * 17) % 92) / 100);
        final y = size.height * (0.1 + ((i * 29) % 82) / 100);
        final center = Offset(x, y);
        final radius = 8.0 + (i % 3) * 3;
        canvas.drawCircle(center, radius, spikePaint);
        for (var spike = 0; spike < 6; spike++) {
          final angle = spike * math.pi / 3;
          final start = center.translate(
              math.cos(angle) * radius, math.sin(angle) * radius);
          final end = center.translate(
              math.cos(angle) * (radius + 5), math.sin(angle) * (radius + 5));
          canvas.drawLine(start, end, spikePaint);
        }
      }
    }

    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.width * 0.5, size.height * 0.42),
          math.max(size.width, size.height) * 0.72,
          [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.34),
          ],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _TitleBackdropPainter oldDelegate) =>
      oldDelegate.biologyPackEnabled != biologyPackEnabled;
}

class _LauncherMetric extends StatelessWidget {
  const _LauncherMetric({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({super.key, required this.game});

  static const id = 'tutorial';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Card(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Detailed Tutorial',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: game.closeTutorial,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    _tutorialSection(
                      'Core controls',
                      'Move with WASD, arrow keys, or the joystick. Dash with Space or the DASH button. Your strongest defense is spacing: move before you are surrounded.',
                    ),
                    _tutorialSection(
                      'Combat basics',
                      'Your offense comes from mini-weapons. They fire automatically, so focus on positioning, collecting samples, and choosing upgrades that change weapon behavior.',
                    ),
                    _tutorialSection(
                      'Enemy variants',
                      'Swarm enemies are basic bodies. Runners chase quickly. Stalkers weave side-to-side. Splitters create smaller threats. Tanks can later mutate into brutes that charge in readable straight lines.',
                    ),
                    _tutorialSection(
                      'Build drafting',
                      'Pick 1 opening mini-weapon at the start. After lessons and sample levels, unlock more mini-weapons, level the ones you own, or choose a branch at Lv.3. Strong builds usually focus on upgrading a few weapons instead of spreading too thin.',
                    ),
                    _tutorialSection(
                      'Passives and evolutions',
                      'Boss rewards can add passives. Some passives evolve specific mini-weapons at high level. Not every passive needs an evolution, but every mini-weapon has a stronger evolved form to chase.',
                    ),
                    _tutorialSection(
                      'Boss gates',
                      'Every third normal round is a boss gate. Apex Striker dodges and summons enhanced weavers. Splitter Broodmother floods the arena. Charger Brute uses lane charges and mitosis fragments.',
                    ),
                    _tutorialSection(
                      'Learning loop',
                      'After each normal round you read a short lesson, answer three questions, then enter a free mini-weapon draft. Better quizzes make the next build step smoother.',
                    ),
                    _tutorialSection(
                      'Long-term progression',
                      'Runs earn Research Points. Spend them in the character shop to unlock frames with easier-run traits like speed, shields, extra lives, or stronger sample pickup range.',
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: game.closeTutorial,
                      child: const Text('Close Detailed Tutorial'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tutorialSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});

  static const id = 'pause';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.uiTick,
      builder: (_, __, ___) {
        return Material(
          color: Colors.black54,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
              child: Card(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Run Summary',
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold)),
                          ),
                          if (game.isDeveloperMode)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A0F18),
                                borderRadius: BorderRadius.circular(999),
                                border:
                                    Border.all(color: const Color(0xFFEF476F)),
                              ),
                              child: const Text(
                                'Developer Mode',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Attack source: Mini-weapons only'),
                      const SizedBox(height: 6),
                      Text(
                        'Mini-weapons: ${game.equippedMiniWeapons.isEmpty ? 'None yet' : game.equippedMiniWeapons.map((type) => '${type.title} Lv.${game.miniWeaponLevel(type)}').join(', ')}',
                      ),
                      const SizedBox(height: 6),
                      Text('Round type: ${game.roundTypeLabel}'),
                      Text(
                          'Mode: ${game.modeLabel}${game.isDeveloperMode || game.isTutorialMode ? '  -  Score is unranked' : ''}'),
                      Text('Difficulty: ${game.difficultyLabel}'),
                      Text('Checkpoint: ${game.checkpointSummary}'),
                      const SizedBox(height: 12),
                      _PerformanceSettingsPanel(
                        game: game,
                        accent: const Color(0xFF2EC4B6),
                      ),
                      const SizedBox(height: 14),
                      const Text('Controls',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      const Text('- Move: WASD or arrow keys'),
                      const Text('- Dash: Space or DASH button'),
                      const Text('- Pause: P or Esc'),
                      const Text(
                          '- Samples flicker during cleanup, then vanish'),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton(
                            onPressed: game.closePauseSummary,
                            child: const Text('Resume'),
                          ),
                          OutlinedButton(
                            onPressed: game.restartGame,
                            child: Text(game.isDeveloperMode
                                ? 'Restart Sandbox'
                                : 'Restart Run'),
                          ),
                          OutlinedButton(
                            onPressed: game.openTutorial,
                            child: const Text('Detailed Tutorial'),
                          ),
                          OutlinedButton(
                            onPressed: game.returnToTitle,
                            child: const Text('Return To Title'),
                          ),
                        ],
                      ),
                      if (game.isDeveloperMode) ...[
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 6),
                        const Text('Developer Tools',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text(
                            'This sandbox run is unranked and does not write normal checkpoints or best scores.'),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton.tonal(
                              onPressed: game.developerRestoreLives,
                              child: const Text('Restore Lives'),
                            ),
                            FilledButton.tonal(
                              onPressed: game.developerToggleInvulnerability,
                              child: Text(game.developerInvulnerable
                                  ? 'Invuln: On'
                                  : 'Invuln: Off'),
                            ),
                            FilledButton.tonal(
                              onPressed: game.developerClearWave,
                              child: const Text('Clear Wave'),
                            ),
                            FilledButton.tonal(
                              onPressed: game.developerForceBossGate,
                              child: const Text('Force Boss Gate'),
                            ),
                            FilledButton.tonal(
                              onPressed: game.developerOpenShopResults,
                              child: const Text('Open Shop Results'),
                            ),
                            FilledButton.tonal(
                              onPressed: game.developerSkipLessonFlow,
                              child: const Text('Skip Lesson Flow'),
                            ),
                            FilledButton.tonal(
                              onPressed: () =>
                                  game.developerGrantPickup(PickupType.shield),
                              child: const Text('Grant Shield'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text('Spawn Specific Boss',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final bossType in BossType.values)
                              OutlinedButton(
                                onPressed: () =>
                                    game.developerSpawnSpecificBoss(bossType),
                                child: Text(bossType.title),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text('Main Weapon Path',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        ...WeaponType.values.map((weapon) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              color: const Color(0xFF12343B),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(weapon.title,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Text(weapon.description),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        FilledButton.tonal(
                                          onPressed: () => game
                                              .developerSetWeaponPath(weapon),
                                          child: Text(
                                              game.activeWeapon == weapon
                                                  ? 'Active Path'
                                                  : 'Set Path'),
                                        ),
                                        OutlinedButton(
                                          onPressed: () => game
                                              .developerIncreaseWeaponSpecial(
                                                  weapon),
                                          child: const Text('Special +1'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        const Text('Mini-Weapon Loadout',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        ...availableMiniWeaponTypes.map((type) {
                          final state = game.miniWeaponStates[type]!;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              color: const Color(0xFF12343B),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(type.title,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Text(game.miniWeaponSummary(type)),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        FilledButton.tonal(
                                          onPressed: () => game
                                              .developerToggleMiniWeapon(type),
                                          child: Text(
                                            !state.unlocked
                                                ? 'Unlock + Equip'
                                                : state.equipped
                                                    ? 'Unequip'
                                                    : 'Equip',
                                          ),
                                        ),
                                        OutlinedButton(
                                          onPressed: () => game
                                              .developerIncreaseMiniWeaponLevel(
                                                  type),
                                          child:
                                              Text('Level +1 (${state.level})'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DesignInterviewOverlay extends StatelessWidget {
  const DesignInterviewOverlay({super.key, required this.game});

  static const id = 'design_interview';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.uiTick,
      builder: (_, __, ___) {
        final question = game.currentDesignInterviewQuestion;
        final selectedChoice = game.selectedDesignInterviewChoice;
        return Material(
          color: Colors.black54,
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 920, maxHeight: 820),
                child: Card(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Design Interview HUD',
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${question.title} of ${designInterviewQuestions.length}',
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.tonal(
                              onPressed: game.closeDesignInterview,
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF12343B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF2D6A4F)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Code Audit Notes',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 10),
                              for (final finding in designAuditFindings)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text('- $finding',
                                      style: const TextStyle(fontSize: 15)),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(question.prompt,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Text(question.whyItMatters,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white70)),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF1B4332).withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF52B788)),
                          ),
                          child: Text(
                            question.recommendation,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...question.choices.map((choice) {
                          final isSelected =
                              game.selectedDesignInterviewChoiceId == choice.id;
                          final isRecommended =
                              question.recommendedChoiceId == choice.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              color: isSelected
                                  ? const Color(0xFF1F4A3D)
                                  : const Color(0xFF102A24),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            choice.label,
                                            style: const TextStyle(
                                                fontSize: 19,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        if (isRecommended)
                                          const Chip(
                                              label: Text('Recommended')),
                                        if (isSelected)
                                          const Chip(label: Text('Selected')),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(choice.description,
                                        style: const TextStyle(fontSize: 15)),
                                    const SizedBox(height: 12),
                                    FilledButton(
                                      onPressed: () =>
                                          game.answerDesignInterview(choice.id),
                                      child: Text(isSelected &&
                                              !game
                                                  .hasNextDesignInterviewQuestion
                                          ? 'Update Answer'
                                          : 'Choose This'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        if (selectedChoice != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Current answer: ${selectedChoice.label}',
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFFD8F3DC)),
                          ),
                        ],
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            OutlinedButton(
                              onPressed: game.hasPreviousDesignInterviewQuestion
                                  ? game.previousDesignInterviewQuestion
                                  : null,
                              child: const Text('Previous Question'),
                            ),
                            OutlinedButton(
                              onPressed: game.hasNextDesignInterviewQuestion
                                  ? game.nextDesignInterviewQuestion
                                  : null,
                              child: const Text('Next Question'),
                            ),
                            OutlinedButton(
                              onPressed: game.resetDesignInterview,
                              child: const Text('Reset Answers'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Answered ${game.designInterviewAnswers.length} of ${designInterviewQuestions.length}',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white70),
                        ),
                        if (game.designInterviewComplete) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'All interview questions have an answer. We can now turn those choices into a concrete implementation plan.',
                            style: TextStyle(
                                fontSize: 15, color: Color(0xFFD8F3DC)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StarterDraftOverlay extends StatelessWidget {
  const StarterDraftOverlay({super.key, required this.game});

  static const id = 'starter_draft';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.uiTick,
      builder: (_, __, ___) {
        return Material(
          color: Colors.black54,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 760,
                      maxHeight: constraints.maxHeight * 0.92,
                    ),
                    child: Card(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Choose Your Opening Mini-Weapon',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            const Text(
                                'Pick 1 opening mini-weapon. This is your starting attack, and the rest of the run builds through mini-weapon upgrades, branches, and evolutions.'),
                            const SizedBox(height: 18),
                            ...game.currentStarterMiniWeaponOffers
                                .map((weapon) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Card(
                                  color: const Color(0xFF12343B),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(weapon.title,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 6),
                                        Text(weapon.description),
                                        const SizedBox(height: 10),
                                        FilledButton(
                                          onPressed: () => game
                                              .chooseStarterMiniWeapon(weapon),
                                          child: const Text(
                                              'Start With This Mini-Weapon'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class CombatLevelOverlay extends StatelessWidget {
  const CombatLevelOverlay({super.key, required this.game});

  static const id = 'combat_level';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.uiTick,
      builder: (_, __, ___) {
        return Material(
          color: Colors.black54,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 720,
                      maxHeight: constraints.maxHeight * 0.9,
                    ),
                    child: Card(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mini-Weapon Level Up',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            const Text(
                                'Choose 1 mini-weapon upgrade for the rest of the run.'),
                            const SizedBox(height: 18),
                            ...game.currentCombatOffers.map((offer) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Card(
                                  color: const Color(0xFF12343B),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(offer.title,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 6),
                                        Text(offer.description),
                                        const SizedBox(height: 10),
                                        FilledButton(
                                          onPressed: () =>
                                              game.chooseCombatUpgrade(offer),
                                          child: const Text('Take Upgrade'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class ContextTipOverlay extends StatelessWidget {
  const ContextTipOverlay({super.key, required this.game});

  static const id = 'context_tip';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.currentTipTitle ?? 'Tip',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    game.currentTipBody ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: game.closeContextTip,
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LevelOverlay extends StatelessWidget {
  const LevelOverlay({super.key, required this.game});

  static const id = 'level';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.uiTick,
      builder: (_, __, ___) {
        final session = game.currentLessonSession;
        if (session == null) {
          return const SizedBox.shrink();
        }
        return Material(
          color: Colors.black54,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: 860, maxHeight: constraints.maxHeight * 0.92),
                    child: Card(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(22),
                        child: _buildContent(context, session),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, LevelLessonSession session) {
    switch (session.step) {
      case LessonOverlayStep.chest:
        if (session.chestOffers.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.chestTitle,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(session.chestSummary, style: const TextStyle(fontSize: 17)),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: game.continuePastChest,
                child: const Text('Open Lesson'),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.chestTitle,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(session.chestSummary, style: const TextStyle(fontSize: 17)),
            const SizedBox(height: 20),
            const Text('Choose 1 premium reward',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...session.chestOffers.map((offer) => _buildBuildOfferCard(
                  offer: offer,
                  onPressed: () => game.chooseBossChestOffer(offer),
                  buttonText: 'Take Reward',
                )),
          ],
        );
      case LessonOverlayStep.reading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Round ${session.roundNumber} complete',
                style: const TextStyle(fontSize: 18, color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              session.lesson.unitNumber == 99
                  ? session.lesson.unitTitle
                  : 'Unit ${session.lesson.unitNumber}: ${session.lesson.unitTitle}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(session.lesson.title,
                style: const TextStyle(fontSize: 18, color: Colors.white70)),
            const SizedBox(height: 16),
            Text(session.lesson.prompt, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF081C15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 17, height: 1.45, color: Colors.white),
                  children:
                      buildGlossarySpans(context, session.lesson.readingText),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap the highlighted terms for quick beginner-friendly definitions.',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 14),
            Text(session.lesson.sourceCredit,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Key terms in this unit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final term in session.lesson.keyTerms)
                  ActionChip(
                    label: Text(term),
                    onPressed: () {
                      final entry = glossaryForTerm(term);
                      if (entry != null) {
                        showGlossaryDefinition(context, entry);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text('Sources: ${session.lesson.sourceTitle}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            if (session.lesson.sourceUrl.isNotEmpty)
              SelectableText(session.lesson.sourceUrl,
                  style: const TextStyle(color: Colors.lightBlueAccent)),
            const SizedBox(height: 22),
            FilledButton(
                onPressed: game.startLessonQuestions,
                child: const Text('Begin 3-question quiz')),
          ],
        );
      case LessonOverlayStep.questions:
        final index = session.questionIndex;
        final question = session.presentedQuestions[index];
        final selected = session.selectedAnswers[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.lesson.unitNumber == 99
                  ? 'Mastery quiz'
                  : 'Unit ${session.lesson.unitNumber} quiz',
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
                'Question ${index + 1} of ${session.presentedQuestions.length}',
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(question.prompt, style: const TextStyle(fontSize: 19)),
            const SizedBox(height: 18),
            ...List.generate(question.choices.length, (choiceIndex) {
              final isSelected = selected == choiceIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF74C69D)
                            : Colors.white24,
                        width: isSelected ? 2 : 1),
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () => game.selectLessonAnswer(choiceIndex),
                  child: Text(question.choices[choiceIndex]),
                ),
              );
            }),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: selected == null ? null : game.submitLessonAnswer,
              child: Text(index == session.presentedQuestions.length - 1
                  ? 'Finish quiz'
                  : 'Next question'),
            ),
          ],
        );
      case LessonOverlayStep.results:
        final profile = session.draftProfile;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.resultTitle,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(session.resultSummary, style: const TextStyle(fontSize: 17)),
            const SizedBox(height: 20),
            const Text('Build draft',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              profile == null
                  ? 'Choose 1 reward for this run.'
                  : '${profile.choiceCount} choices this round. ${profile.grantsReroll ? 'Perfect quiz: 1 free reroll.' : profile.lowerQuality ? 'Lower-quality board due to quiz result.' : 'Normal build quality.'}',
            ),
            const SizedBox(height: 8),
            if (!session.draftResolved) ...[
              if (game.canRerollDraft)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FilledButton.tonal(
                    onPressed: game.rerollDraftOffers,
                    child: const Text('Use Perfect-Quiz Reroll'),
                  ),
                ),
              ...session.draftOffers.map((offer) => _buildBuildOfferCard(
                    offer: offer,
                    onPressed: () => game.chooseDraftOffer(offer),
                    buttonText: 'Take This',
                  )),
              OutlinedButton(
                onPressed: game.skipDraftOffer,
                child: const Text('Skip Draft Reward'),
              ),
            ] else ...[
              Text(
                session.draftSkipped
                    ? 'You skipped this round\'s draft reward.'
                    : 'Draft locked in. Start the next round when you are ready.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                  onPressed: game.skipLessonUpgrade,
                  child: const Text('Start next round')),
            ],
          ],
        );
    }
  }

  Widget _buildBuildOfferCard({
    required BuildOffer offer,
    required VoidCallback onPressed,
    required String buttonText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: const Color(0xFF12343B),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(offer.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                  Chip(
                    label: Text(offer.rarity.label),
                    backgroundColor:
                        Color(offer.rarity.colorValue).withValues(alpha: 0.22),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(offer.description),
              const SizedBox(height: 8),
              Text(offer.effectLine,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              if (offer.evolutionHint != null) ...[
                const SizedBox(height: 6),
                Text(offer.evolutionHint!,
                    style: const TextStyle(color: Color(0xFFD8F3DC))),
              ],
              const SizedBox(height: 10),
              FilledButton(
                onPressed: onPressed,
                child: Text(buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VictoryOverlay extends StatelessWidget {
  const VictoryOverlay({super.key, required this.game});

  static const id = 'victory';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Course Complete',
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text(
                      'You cleared all eight course units. You can end the run here or push into mastery mode for mixed review and harder late-game fights.'),
                  const SizedBox(height: 16),
                  Text('Course-complete score: ${game.currentScore}'),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton(
                        onPressed: game.continueToMastery,
                        child: const Text('Continue To Mastery'),
                      ),
                      OutlinedButton(
                        onPressed: game.finishRunAtVictory,
                        child: const Text('End Run Here'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  static const id = 'game_over';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.uiTick,
      builder: (_, __, ___) {
        final title = game.isDeveloperMode
            ? 'Developer Sandbox'
            : game.isTutorialMode
                ? 'Tutorial Over'
                : game.runWon
                    ? 'Course Complete'
                    : game.masteryMode
                        ? 'Mastery Over'
                        : 'Game Over';
        return Material(
          color: Colors.black54,
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    Text('Round reached: ${game.currentRound}'),
                    Text('Rounds cleared: ${game.roundsCleared}'),
                    Text(
                        'Time survived: ${game.survivalTime.toStringAsFixed(1)}s'),
                    Text('Kills: ${game.kills}'),
                    Text('Bosses defeated: ${game.defeatedBossCount}'),
                    Text('Final score: ${game.currentScore}'),
                    if (!game.isDeveloperMode && !game.isTutorialMode)
                      Text(
                          'Research earned: ${game.researchPointsEarnedThisRun} RP'),
                    if (!game.isDeveloperMode && !game.isTutorialMode)
                      Text('Total Research Points: ${game.researchPoints}'),
                    if (game.isDeveloperMode || game.isTutorialMode)
                      const Text(
                          'Practice runs are unranked and do not update saved progression.'),
                    Text('Best course clear: ${game.bestCourseScore}'),
                    Text('Best mastery score: ${game.bestMasteryScore}'),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton(
                          onPressed: game.restartGame,
                          child: Text(game.isDeveloperMode
                              ? 'Restart Sandbox'
                              : game.isTutorialMode
                                  ? 'Restart Tutorial'
                                  : 'Play Again From Checkpoint'),
                        ),
                        OutlinedButton(
                          onPressed: game.startFreshCourse,
                          child: Text(
                              game.isDeveloperMode || game.isTutorialMode
                                  ? 'Normal Fresh Course'
                                  : 'Fresh Course'),
                        ),
                        OutlinedButton(
                            onPressed: game.returnToTitle,
                            child: const Text('Title Screen')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class InteractiveTutorialOverlay extends StatelessWidget {
  const InteractiveTutorialOverlay({super.key, required this.game});

  static const id = 'interactive_tutorial';
  final SquareShooterGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.uiTick,
      builder: (_, __, ___) {
        final stepIndex = game.interactiveTutorialStepIndex
            .clamp(0, interactiveTutorialSteps.length - 1);
        final step = interactiveTutorialSteps[stepIndex];
        final isLast = stepIndex == interactiveTutorialSteps.length - 1;
        return SafeArea(
          child: Stack(
            children: [
              Positioned(
                right: 14,
                bottom: 92,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Card(
                    color: const Color(0xEE0B1A17),
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: const BorderSide(color: Color(0xFF2EC4B6)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0x332EC4B6),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                      color: const Color(0xFF2EC4B6)),
                                ),
                                child: Text(
                                  '${stepIndex + 1}/${interactiveTutorialSteps.length}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  step.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            step.body,
                            style: const TextStyle(fontSize: 15, height: 1.35),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0x2210BEB0),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              'Try this: ${step.goal}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD8F3DC),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: stepIndex > 0
                                    ? game.previousInteractiveTutorialStep
                                    : null,
                                child: const Text('Back'),
                              ),
                              OutlinedButton(
                                onPressed: game.finishInteractiveTutorial,
                                child: const Text('Exit Tutorial'),
                              ),
                              FilledButton(
                                onPressed: game.nextInteractiveTutorialStep,
                                child: Text(isLast ? 'Finish' : 'Next'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VirtualJoystick extends StatefulWidget {
  const _VirtualJoystick({required this.onChanged});

  final ValueChanged<Vector2> onChanged;

  @override
  State<_VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<_VirtualJoystick> {
  static const double baseSize = 120;
  static const double knobSize = 48;
  Offset knobOffset = Offset.zero;

  void _updateOffset(Offset localPosition) {
    const radius = baseSize / 2;
    final center = const Offset(radius, radius);
    var delta = localPosition - center;
    final distance = delta.distance;
    final maxDistance = radius - knobSize / 2;
    if (distance > maxDistance && distance > 0) {
      delta = delta / distance * maxDistance;
    }
    setState(() {
      knobOffset = delta;
    });
    final normalized = Vector2(delta.dx / maxDistance, delta.dy / maxDistance);
    if (normalized.length2 > 1) {
      normalized.normalize();
    }
    widget.onChanged(normalized);
  }

  void _reset() {
    setState(() {
      knobOffset = Offset.zero;
    });
    widget.onChanged(Vector2.zero());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _updateOffset(details.localPosition),
      onPanUpdate: (details) => _updateOffset(details.localPosition),
      onPanEnd: (_) => _reset(),
      onPanCancel: _reset,
      child: SizedBox(
        width: baseSize,
        height: baseSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: baseSize,
              height: baseSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF081C15).withValues(alpha: 0.34),
                border: Border.all(color: Colors.white24, width: 2),
              ),
            ),
            Transform.translate(
              offset: knobOffset,
              child: Container(
                width: knobSize,
                height: knobSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.28),
                  border: Border.all(color: Colors.white54, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on SquareShooterGame {
  BulletComponent _makeBullet({
    required Vector2 origin,
    required Vector2 direction,
    required int damage,
    required double speed,
    required double bulletSize,
    double homingStrength = 0,
    int pierce = 0,
    Color color = const Color(0xFFB9FBC0),
    BulletVisualStyle? visualStyle,
  }) {
    final resolvedStyle = visualStyle ??
        (homingStrength > 0
            ? BulletVisualStyle.orb
            : pierce >= 2
                ? BulletVisualStyle.rail
                : bulletSize <= 6.6
                    ? BulletVisualStyle.needle
                    : bulletSize >= 9.6
                        ? BulletVisualStyle.shard
                        : BulletVisualStyle.capsule);
    return BulletComponent(
      position: origin,
      direction: direction.normalized(),
      damage: damage,
      speed: speed,
      bulletSize: bulletSize,
      homingStrength: homingStrength,
      remainingHits: pierce,
      tint: color,
      visualStyle: resolvedStyle,
    );
  }

  Vector2 _rotateVector(Vector2 input, double radians) {
    final cosTheta = math.cos(radians);
    final sinTheta = math.sin(radians);
    return Vector2(
      input.x * cosTheta - input.y * sinTheta,
      input.x * sinTheta + input.y * cosTheta,
    );
  }

  double fireWeapon(Vector2 origin, Vector2 direction) {
    if (direction.length2 == 0) {
      return (player?.fireCooldown ?? 0.38) * (player?.reloadMultiplier ?? 1.0);
    }
    final currentPlayer = player;
    if (currentPlayer == null) {
      return 0.38;
    }

    final normalized = direction.normalized();
    final special = activeWeaponState.specialLevel;
    final branchId = activeWeaponState.branchId;
    final matchingPassiveLevel = 0;
    final forceBonus = _combatStatLevels[CombatUpgradeKind.force] ?? 0;
    final evolved = activeWeaponEvolved;
    switch (activeWeapon) {
      case WeaponType.standard:
        return currentPlayer.fireCooldown * currentPlayer.reloadMultiplier;
      case WeaponType.scatter:
        final shrapnelFan = branchId == 'shrapnel_fan';
        final clusterBloom = branchId == 'cluster_bloom';
        final pelletCount = 5 +
            math.min(3, special ~/ 2) +
            matchingPassiveLevel ~/ 2 +
            (evolved ? 2 : 0) +
            (shrapnelFan ? 2 : 0);
        final spread = math.max(
            0.10,
            0.34 -
                special * 0.015 -
                matchingPassiveLevel * 0.01 +
                (shrapnelFan ? 0.08 : 0) -
                (clusterBloom ? 0.06 : 0));
        final pelletDamage =
            math.max(1, currentPlayer.bulletDamage + forceBonus + special ~/ 3);
        for (int i = 0; i < pelletCount; i++) {
          final centered = i - (pelletCount - 1) / 2;
          add(_makeBullet(
            origin: origin.clone(),
            direction: _rotateVector(normalized, centered * spread),
            damage: pelletDamage,
            speed: 430 + special * 8,
            bulletSize: 6.5 + special * 0.2,
            color: const Color(0xFFFFD166),
          ));
        }
        if (evolved) {
          for (int i = 0; i < 4; i++) {
            final angle = (math.pi * 2 * i) / 4;
            add(_makeBullet(
              origin: origin.clone(),
              direction: _rotateVector(normalized, angle - math.pi / 2),
              damage: pelletDamage,
              speed: 320,
              bulletSize: 6,
              color: const Color(0xFFFFE3A3),
            ));
          }
        }
        if (clusterBloom) {
          for (final sign in const [-1.0, 1.0]) {
            add(_makeBullet(
              origin: origin.clone(),
              direction: _rotateVector(-normalized, sign * 0.30),
              damage: math.max(1, pelletDamage - 1),
              speed: 285,
              bulletSize: 5.5,
              color: const Color(0xFFFFE3A3),
            ));
          }
        }
        return currentPlayer.fireCooldown *
            1.16 *
            currentPlayer.reloadMultiplier;
      case WeaponType.homing:
        final twinSeekers = branchId == 'twin_seekers';
        final hunterSurge = branchId == 'hunter_surge';
        final offsets = twinSeekers
            ? (evolved ? const [-0.14, 0.0, 0.14] : const [-0.08, 0.08])
            : (evolved ? const [-0.08, 0.08] : const [0.0]);
        for (final offset in offsets) {
          add(_makeBullet(
            origin: origin.clone(),
            direction: _rotateVector(normalized, offset),
            damage: currentPlayer.bulletDamage +
                forceBonus +
                2 +
                special ~/ 2 +
                matchingPassiveLevel ~/ 2 +
                (hunterSurge ? 2 : 0),
            speed: 455 + special * 12,
            bulletSize: 10 + special * 0.4,
            homingStrength: 7.5 +
                special * 1.1 +
                matchingPassiveLevel * 0.8 +
                (evolved ? 2.2 : 0) +
                (hunterSurge ? 2.6 : 0),
            color: const Color(0xFF9BF6FF),
          ));
        }
        return currentPlayer.fireCooldown *
            1.18 *
            currentPlayer.reloadMultiplier;
      case WeaponType.heavy:
        final crushCore = branchId == 'crush_core';
        final shockCore = branchId == 'shock_core';
        add(_makeBullet(
          origin: origin.clone(),
          direction: normalized,
          damage: currentPlayer.bulletDamage +
              forceBonus +
              4 +
              special +
              matchingPassiveLevel +
              (crushCore ? 2 : 0),
          speed: 320 +
              special * 10 +
              matchingPassiveLevel * 4 -
              (crushCore ? 24 : 0),
          bulletSize:
              18 + special * 1.8 + matchingPassiveLevel + (crushCore ? 3 : 0),
          pierce: (evolved ? 2 : 0) + (crushCore ? 1 : 0),
          color: const Color(0xFFFF6B6B),
        ));
        if (shockCore) {
          for (final sign in const [-1.0, 1.0]) {
            add(_makeBullet(
              origin: origin.clone(),
              direction: _rotateVector(normalized, sign * 0.22),
              damage: math.max(1, currentPlayer.bulletDamage + forceBonus + 1),
              speed: 380,
              bulletSize: 8,
              color: const Color(0xFFFFA69E),
            ));
          }
        }
        return currentPlayer.fireCooldown *
            1.30 *
            currentPlayer.reloadMultiplier;
      case WeaponType.twin:
        final railPair = branchId == 'rail_pair';
        final mirrorSweep = branchId == 'mirror_sweep';
        final perpendicular = Vector2(-normalized.y, normalized.x);
        final offset = 10 + special * 0.5 + matchingPassiveLevel;
        final signs = railPair
            ? (evolved ? [-1.9, -0.7, 0.7, 1.9] : [-1.4, -0.45, 0.45, 1.4])
            : (mirrorSweep
                ? [-1.8, -0.5, 0.5, 1.8]
                : (evolved ? [-1.6, -0.5, 0.5, 1.6] : [-1.0, 1.0]));
        for (final sign in signs) {
          final laneDirection = mirrorSweep && sign.abs() > 1.0
              ? _rotateVector(normalized, sign.isNegative ? -0.16 : 0.16)
              : normalized;
          add(_makeBullet(
            origin: origin.clone() + perpendicular * (offset * sign),
            direction: laneDirection,
            damage: currentPlayer.bulletDamage + forceBonus + 1 + special ~/ 2,
            speed: 450 + special * 10,
            bulletSize: 7.5 + special * 0.2,
            color: const Color(0xFFA0C4FF),
          ));
        }
        return currentPlayer.fireCooldown *
            1.04 *
            currentPlayer.reloadMultiplier;
      case WeaponType.burst:
        final needleBurst = branchId == 'needle_burst';
        final bloomBurst = branchId == 'bloom_burst';
        final burstCount = 3 +
            math.min(2, special ~/ 3) +
            matchingPassiveLevel ~/ 2 +
            (evolved ? 1 : 0) +
            (bloomBurst ? 2 : 0);
        for (int i = 0; i < burstCount; i++) {
          final spread =
              (i - (burstCount - 1) / 2) * (needleBurst ? 0.035 : 0.06);
          add(_makeBullet(
            origin: origin.clone(),
            direction: _rotateVector(normalized, spread),
            damage: currentPlayer.bulletDamage + forceBonus + 1 + special ~/ 3,
            speed: 460 + special * 8 + (needleBurst ? 26 : 0),
            bulletSize: 7 + special * 0.2 + (needleBurst ? 0.4 : 0),
            color: const Color(0xFF80FFDB),
          ));
        }
        if (bloomBurst) {
          for (final angle in const [-0.42, 0.42]) {
            add(_makeBullet(
              origin: origin.clone(),
              direction: _rotateVector(normalized, angle),
              damage: math.max(1, currentPlayer.bulletDamage + forceBonus),
              speed: 340,
              bulletSize: 6.0,
              color: const Color(0xFFB7E4C7),
            ));
          }
        }
        return currentPlayer.fireCooldown *
            (needleBurst ? 1.08 : (evolved ? 1.05 : 1.22)) *
            currentPlayer.reloadMultiplier;
      case WeaponType.pierce:
        final lanceDrive = branchId == 'lance_drive';
        final forkRail = branchId == 'fork_rail';
        add(_makeBullet(
          origin: origin.clone(),
          direction: normalized,
          damage: currentPlayer.bulletDamage +
              forceBonus +
              3 +
              special +
              matchingPassiveLevel ~/ 2 +
              (lanceDrive ? 1 : 0),
          speed: 520 +
              special * 12 +
              matchingPassiveLevel * 6 +
              (lanceDrive ? 24 : 0),
          bulletSize: 9 + special * 0.3 + (lanceDrive ? 1.5 : 0),
          pierce: 2 +
              special ~/ 2 +
              matchingPassiveLevel ~/ 2 +
              (evolved ? 2 : 0) +
              (lanceDrive ? 2 : 0),
          color: const Color(0xFFC77DFF),
        ));
        if (forkRail) {
          add(_makeBullet(
            origin: origin.clone(),
            direction: _rotateVector(normalized, 0.10),
            damage: currentPlayer.bulletDamage + forceBonus + 2 + special ~/ 2,
            speed: 500,
            bulletSize: 8,
            pierce: 2,
            color: const Color(0xFFE0AAFF),
          ));
        }
        if (evolved) {
          add(_makeBullet(
            origin: origin.clone(),
            direction: _rotateVector(normalized, 0.09),
            damage: currentPlayer.bulletDamage + forceBonus + 2 + special ~/ 2,
            speed: 500,
            bulletSize: 8,
            pierce: 2,
            color: const Color(0xFFE0AAFF),
          ));
        }
        return currentPlayer.fireCooldown *
            1.26 *
            currentPlayer.reloadMultiplier;
      case WeaponType.sniper:
        final pinpoint = branchId == 'pinpoint';
        final afterimage = branchId == 'afterimage';
        add(_makeBullet(
          origin: origin.clone(),
          direction: normalized,
          damage: currentPlayer.bulletDamage +
              forceBonus +
              7 +
              special * 2 +
              matchingPassiveLevel +
              (pinpoint ? 3 : 0),
          speed: 680 +
              special * 20 +
              matchingPassiveLevel * 10 +
              (pinpoint ? 38 : 0),
          bulletSize: 8 + special * 0.2,
          pierce: 1 + special ~/ 3 + (evolved ? 2 : 0),
          color: const Color(0xFFFFC6FF),
        ));
        if (afterimage) {
          add(_makeBullet(
            origin: origin.clone(),
            direction: normalized,
            damage: currentPlayer.bulletDamage + forceBonus + 3 + special,
            speed: 580,
            bulletSize: 7.2,
            pierce: 1,
            color: const Color(0xFFFFE5F5),
          ));
        }
        if (evolved) {
          add(_makeBullet(
            origin: origin.clone(),
            direction: normalized,
            damage: currentPlayer.bulletDamage + forceBonus + 4 + special,
            speed: 600,
            bulletSize: 10,
            pierce: 1,
            color: const Color(0xFFFFD9F7),
          ));
        }
        return currentPlayer.fireCooldown *
            1.55 *
            currentPlayer.reloadMultiplier;
      case WeaponType.nova:
        final sunburst = branchId == 'sunburst';
        final orbitBloom = branchId == 'orbit_bloom';
        final shardCount = 8 +
            math.min(6, special) +
            matchingPassiveLevel +
            (sunburst ? 3 : 0);
        for (int i = 0; i < shardCount; i++) {
          final angle = sunburst
              ? math.atan2(normalized.y, normalized.x) -
                  0.95 +
                  (1.9 * i) / math.max(1, shardCount - 1)
              : (math.pi * 2 * i) / shardCount;
          add(_makeBullet(
            origin: origin.clone(),
            direction: Vector2(math.cos(angle), math.sin(angle)),
            damage: currentPlayer.bulletDamage + forceBonus + 1 + special ~/ 2,
            speed: 360 + special * 10,
            bulletSize: 7 + special * 0.2,
            color: const Color(0xFFFFADAD),
          ));
        }
        if (evolved || orbitBloom) {
          for (int i = 0; i < shardCount; i++) {
            final angle =
                (math.pi * 2 * i) / shardCount + (math.pi / shardCount);
            add(_makeBullet(
              origin: origin.clone(),
              direction: Vector2(math.cos(angle), math.sin(angle)),
              damage:
                  currentPlayer.bulletDamage + forceBonus + 1 + special ~/ 2,
              speed: 300,
              bulletSize: 6.5,
              color: const Color(0xFFFFD6D6),
            ));
          }
        }
        return currentPlayer.fireCooldown *
            1.45 *
            currentPlayer.reloadMultiplier;
    }
  }

  void showBanner(String text, {double duration = 2.4}) {
    bannerText = text;
    bannerTimer = duration;
    notifyUi();
  }
}
