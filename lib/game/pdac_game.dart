import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show EdgeInsets, KeyEventResult;

import '../data/bosses/boss_catalog.dart';
import '../data/bosses/boss_def.dart';
import '../data/categories.dart';
import '../data/enemies/enemy_def.dart';
import '../data/enemies/enemy_catalog.dart';
import '../data/lessons/lesson_catalog.dart';
import '../data/maps/biome_catalog.dart';
import '../data/maps/biome_def.dart';
import '../data/rounds/round_catalog.dart';
import '../data/weapons/weapon_catalog.dart';
import '../data/rounds/round_def.dart';
import '../services/audio_service.dart';
import '../services/persistence_service.dart';
import '../services/playtest_logger.dart';
import '../services/save_data.dart';
import '../services/settings_service.dart';
import '../theme/colorblind.dart';
import '../theme/fx_constants.dart';
import 'components/boss_component.dart';
import 'components/boss_projectile_component.dart';
import 'components/bullet_component.dart';
import 'components/coin_component.dart';
import 'components/blast_ring_component.dart';
import 'components/damage_cloud_component.dart';
import 'components/floating_damage_number_component.dart';
import 'components/floating_gold_number_component.dart';
import 'components/hud_data.dart';
import 'components/mob_component.dart';
import 'components/particle_batch_component.dart';
import 'components/player_component.dart';
import 'components/reticle_component.dart';
import 'components/tutorial_director.dart';
import 'game_state.dart';
import 'sprite_pack.dart';
import 'systems/entity_budget.dart';
import 'systems/gameplay_safe_area.dart';
import 'systems/screen_shake.dart';
import 'systems/spawner.dart';
import 'systems/weapon_resistance_tracker.dart';
import 'world/arena_background.dart';

export 'components/player_component.dart' show PdacKey;
export 'game_state.dart' show RoundPhase;

String bossRecapStageLabel(BossAttackStyle style) => switch (style) {
  BossAttackStyle.krasClonePulse => 'Early Lesion Signal',
  BossAttackStyle.stromalFortress => 'Tumor Support Network',
  BossAttackStyle.metastaticStorm => 'Metastatic Spread',
};

String bossRecapFightTakeaway(BossAttackStyle style) => switch (style) {
  BossAttackStyle.krasClonePulse =>
    'You handled the KRAS clone pulses by changing position and varying your immune responses.',
  BossAttackStyle.stromalFortress =>
    'You broke through support cells and hazard walls instead of only shooting the largest target.',
  BossAttackStyle.metastaticStorm =>
    'You separated real danger from decoy signals while the disease pattern spread outward.',
};

/// True when [roundDef] should pause for the full lesson + quiz modals. Boss
/// rounds do, and two regular rounds carry must-read science: KRAS resistance
/// in round 5 and saliva-biomarker caveats in round 8. Other regular rounds
/// still teach via transient field notes so combat is not modal-gated every
/// time.
bool roundUsesBlockingLesson(RoundDef roundDef) =>
    roundDef.isBossRound ||
    roundDef.roundNumber == 5 ||
    roundDef.roundNumber == 8;

bool roundCompletesRun(RoundDef roundDef) =>
    roundDef.roundNumber >= RoundCatalog.all.length;

RoundPhase phaseAfterBossRecap(RoundDef roundDef) => roundCompletesRun(roundDef)
    ? RoundPhase.lesson
    : RoundPhase.gunUpgradeChoice;

/// Eased slow-motion factor for the resistance "hit-stop". [remaining] is the
/// seconds left in a window of total length [total]: the factor snaps to
/// [target] immediately and holds there for the first [hold] seconds, then
/// easeOutCubics back to 1.0 over the rest. Returns 1.0 outside the window.
/// Provably bounded in [target, 1.0], never NaN/negative. Pure so the hit-stop
/// curve is unit-testable without a live game.
double resistanceSlowMotionFactor({
  required double remaining,
  required double total,
  required double hold,
  required double target,
}) {
  if (remaining <= 0) return 1.0;
  final easeWindow = total - hold;
  if (easeWindow <= 0) return target;
  if (remaining > easeWindow) return target; // snap + hold
  final t = ((easeWindow - remaining) / easeWindow).clamp(0.0, 1.0);
  final eased = 1 - pow(1 - t, 3).toDouble(); // easeOutCubic
  return target + (1.0 - target) * eased;
}

int? resumableCheckpointRoundForPhase({
  required RoundPhase phase,
  required int currentRound,
  required int? clearedRound,
  required bool clearedRoundCompletesRun,
}) {
  if (phase == RoundPhase.victory || phase == RoundPhase.gameOver) {
    return null;
  }
  if (phase == RoundPhase.loadout) return currentRound;
  if (clearedRound != null) {
    if (clearedRoundCompletesRun) return null;
    return (clearedRound + 1).clamp(1, CheckpointData.maxRound);
  }
  return currentRound;
}

const Map<String, String> _curatedFieldNotes = {
  'lesson_round_1':
      'Fast innate defenses, targeted antibodies, and cytotoxic cell-killing all solve different problems. Match weapons to threats for bonus damage, but rotate when the arena starts selecting for resistant cells.',
  'lesson_round_2':
      'Viruses, bacteria, and fungi behave differently, so clearing the arena is about reading behavior, not only color. Splitting, shielding, and lingering spores are simplified game signals for real differences in infection biology.',
  'lesson_round_4':
      'Risk comes from patterns, not one guaranteed cause. Smoking, inherited variants, chronic inflammation, diabetes, and age can raise PDAC risk, which is why researchers look for earlier warning signals.',
  'lesson_round_5':
      'KRAS is a gene that helps control cell growth. In many PDAC tumors, a KRAS mutation can keep growth signals stuck on, which is why one repeated attack plan may stop working as resistant cells dominate.',
  'lesson_round_7':
      'Staging asks how far cancer has spread and whether surgery may be possible. In the arena, support cells and decoys stand in for the messy signals doctors must sort through before choosing treatment.',
  'lesson_round_8':
      'Saliva-based biomarkers are promising research signals, not an available screening test today. The hard part is proving a signal can find PDAC early without too many false positives or false negatives.',
};

/// Short non-blocking lesson beat for regular rounds. Boss rounds still use
/// full modal lessons and quizzes; these notes keep the skipped units visible.
String? fieldNoteForLesson(String lessonId) {
  final lesson = LessonCatalog.all[lessonId];
  if (lesson == null) return null;
  final note = _curatedFieldNotes[lessonId];
  if (note != null) return 'Field notes - ${lesson.title}: $note';

  final text = lesson.readingText.trim();
  final period = text.indexOf('. ');
  final firstSentence = period == -1 ? text : text.substring(0, period + 1);
  return 'Field notes - ${lesson.title}: $firstSentence';
}

/// Maps the currently-pressed logical keys to the game's movement directions
/// (WASD + arrow keys). Pure, so it's unit-testable without a live game.
Set<PdacKey> movementKeysFor(Set<LogicalKeyboardKey> keysPressed) {
  final keys = <PdacKey>{};
  if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
      keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
    keys.add(PdacKey.up);
  }
  if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
      keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
    keys.add(PdacKey.down);
  }
  if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
      keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
    keys.add(PdacKey.left);
  }
  if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
      keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
    keys.add(PdacKey.right);
  }
  return keys;
}

/// Top-level [FlameGame] for PDAC Immune Defense.
///
/// Owns the round loop / state machine ([phase]), the arena, the player,
/// active mobs, and exposes the small API surface ([spawnMob],
/// [spawnBullet], [spawnParticles], [collectCoin], [onMobDefeated],
/// [onPlayerDamaged], [onPlayerDied], ...) that components call into.
/// Flutter overlays (HUD, round-end screens, ...) observe [phase] and
/// [hud] and drive transitions via [chooseGunUpgrade], [finishLesson],
/// [submitQuiz], and [startNextRound].
class PdacGame extends FlameGame with KeyboardEvents, MouseMovementDetector {
  PdacGame({required this.persistence, this.checkpoint, this.tutorial = false});

  final PersistenceService persistence;
  final CheckpointData? checkpoint;

  /// When true the game runs the interactive training arena: a
  /// [TutorialDirector] drives scripted spawns and prompts, the player is
  /// invulnerable, and the normal round loop is bypassed. Default false leaves
  /// real runs completely unchanged.
  final bool tutorial;

  /// Flips to true when the tutorial's final beat completes so the hosting
  /// [GameScreen] can pop back to the menu.
  final ValueNotifier<bool> tutorialComplete = ValueNotifier(false);

  late final GameState gameState;
  bool _gameStateInitialized = false;
  final HudData hud = HudData();
  final Random rng = Random();

  /// Logical arena size in game units. Updated on resize so components
  /// (player clamping, spawn edges, bullet despawn) stay in sync with the
  /// rendered viewport.
  Vector2 arenaSize = Vector2(960, 540);

  late PlayerComponent player;

  /// The themed backdrop. Retheme it per map via [ArenaBackground.applyBiome]
  /// when a round begins (see [_beginRound]).
  late final ArenaBackground _background;

  late final ParticleBatchComponent _particleBatch;

  /// The map/biome the current round belongs to (bloodstream, pancreas, ...).
  BiomeDef get currentBiome => BiomeCatalog.forRound(gameState.currentRound);

  /// On-screen movement joystick (bottom-left). Only present on touch devices
  /// (see [touchControlsEnabled] / [_syncTouchControls]); null on desktop.
  /// [PlayerComponent.update] blends its [JoystickComponent.relativeDelta]
  /// with [pressedKeys] when present, so keyboard play is unaffected.
  JoystickComponent? joystick;

  /// Latest mouse position in world coordinates, updated while the pointer
  /// hovers the arena. Drives manual aim (see [AimMode.manual]).
  final Vector2 mouseWorldPosition = Vector2.zero();
  bool _hasMousePosition = false;

  /// True when the player is currently aiming with the mouse (manual aim on,
  /// desktop, pointer seen). [WeaponController] fires toward the cursor.
  bool get manualAimActive =>
      settings.value.aimMode == AimMode.manual &&
      !touchControlsEnabled &&
      _hasMousePosition;

  final List<MobComponent> activeMobs = [];
  final Set<PdacKey> pressedKeys = {};

  static const double _mobGridCellSize = 96;
  static const double _maxMobHitRadius = 28;
  // Spatial hash of live mobs, rebuilt each frame. Keyed by a flat int (not a
  // boxed Point) and the per-cell lists are reused across frames (cleared in
  // place) to avoid steady per-frame allocation / GC churn under big swarms.
  final Map<int, List<MobComponent>> _mobGrid = {};
  bool _mobGridBuilt = false;

  /// Encodes signed cell coords into a single int key. The +/-32768 bias keeps
  /// keys collision-free for any arena size we will realistically see.
  static int _cellKey(int x, int y) => (x + 32768) * 65536 + (y + 32768);

  /// Live counts + hard caps for pooled entities (bullets, coins, clouds,
  /// damage/gold numbers, blast rings).
  final EntityBudget _budget = EntityBudget();
  final WeaponResistanceTracker weaponResistance = WeaponResistanceTracker();
  double _smoothedFps = 60;

  // --- Aim reticle ---------------------------------------------------------
  // The [WeaponController] publishes the current auto-aim target here each
  // frame so [ReticleComponent] can draw a matched/mismatched indicator on it.
  // We snapshot position + radius (not the entity) to avoid holding a dangling
  // reference to a mob that may die mid-frame.
  final Vector2 aimTargetPosition = Vector2.zero();
  bool hasAimTarget = false;
  double aimTargetRadius = 0;
  bool aimTargetMatched = false;
  ImmuneCategory aimTargetCategory = ImmuneCategory.innate;

  /// Records the entity the equipped weapon is currently firing at, and
  /// whether the weapon's category matches it. Read by [ReticleComponent].
  void publishAimTarget(
    Vector2 position,
    double radius,
    bool matched,
    ImmuneCategory weaponCategory,
  ) {
    aimTargetPosition.setFrom(position);
    aimTargetRadius = radius;
    aimTargetMatched = matched;
    aimTargetCategory = weaponCategory;
    hasAimTarget = true;
  }

  /// Hides the reticle (no current target, or no equipped weapon).
  void clearAimTarget() => hasAimTarget = false;

  /// A short non-blocking "field notes" banner queued by a regular round's
  /// end, surfaced at the start of the next round (see [_beginRound]) in place
  /// of the full blocking lesson modal.
  String? _pendingScienceTip;
  final ListQueue<String> _contextTipQueue = ListQueue<String>();

  /// The boss for the current round, if any (rounds 3, 6, 9). Cleared once
  /// defeated - see [onBossDefeated].
  BossComponent? activeBoss;

  /// Current round-loop phase. UI overlays listen to this to know which
  /// overlay to show.
  final ValueNotifier<RoundPhase> phase = ValueNotifier(RoundPhase.playing);

  late Spawner _spawner;
  RoundDef? _activeRoundDef;

  int get currentActiveMobCap => min(
    _activeRoundDef?.activeMobCap ?? maxLiveMobHardCap,
    maxLiveMobHardCap,
  );

  /// Difficulty multiplier applied to all damage enemies/bosses deal to the
  /// player (see [GameDifficulty]). 1.0 on Standard.
  double get enemyDamageMultiplier =>
      settings.value.difficulty.enemyDamageMultiplier;

  /// True once the spawner has emitted every scheduled enemy for the round.
  /// After this point the only remaining work is clearing live mobs.
  bool _spawnPhaseComplete = false;

  /// One-shot guard so the round-clear transition fires at most once per round.
  /// [_onRoundCleared] is invoked from [update] while the engine is still
  /// running, and some exit paths (e.g. [startNextRound]) only pause after an
  /// async save - leaving `phase == playing` across the await. Without this,
  /// the next tick would re-run the transition (double upgrade / skipped
  /// round). Reset in [_beginRound].
  bool _roundResolved = false;

  /// Seconds spent waiting for lingering hazards (damage clouds / boss
  /// projectiles) to dissipate after every enemy is already dead. Capped so the
  /// round never appears to hang on a slow-fading cloud (see the round-clear
  /// gate in [update]).
  double _residualHazardWait = 0;

  /// Whether the one-time "what is an elite" tip has been shown this run.
  bool _eliteTipShown = false;

  // --- Resistance-alert presentation (wrong-color overuse warning) ---
  /// Simulation speed during the slow-motion hit-stop.
  static const double _slowMoTarget = 0.35;

  /// Total slow-motion window (snap + hold + ease-out back to full speed).
  static const double _slowMoSeconds = 0.8;

  /// How long the resistance banner stays up (outlives the slow-mo a beat).
  static const double _resistanceHoldSeconds = 2.0;

  /// Minimum gap between disruptive resistance presentations (slow-mo / shake /
  /// sting), so rapid tier escalations don't machine-gun the player.
  static const double _presentationCooldownSeconds = 7.0;

  double _slowMoTimer = 0;
  double _resistanceHoldTimer = 0;
  double _presentationCooldown = 0;
  int _resistanceAlertSeq = 0;

  /// Peak number of live mobs seen since the spawn phase completed. Used to
  /// scale the "cleanup" portion of the round-progress bar so it only hits
  /// 100% when the arena is actually empty (mitosis children included).
  int _peakMobsAfterSpawn = 0;

  /// Screen-shake state. See [triggerShake] and [render].
  final ScreenShake _shake = ScreenShake();

  int _pendingGoldSave = 0;
  double _goldSaveDelay = 0;

  ValueNotifier<SettingsData> get settings => SettingsService.instance;

  /// Experimental pixel-art sprite pack (assets/images/). Loaded once at
  /// startup; components consult [useSprites] to choose sprite vs. procedural.
  final SpritePack spritePack = SpritePack();

  /// True when the player has selected the experimental sprite render style and
  /// the pack finished loading. Individual components still fall back to
  /// procedural rendering for any sprite that's missing.
  bool get useSprites =>
      settings.value.renderStyle == RenderStyle.sprites && spritePack.loaded;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    gameState = GameState(persistence: persistence, checkpoint: checkpoint);
    _gameStateInitialized = true;

    // Preload the experimental sprite pack (no-op visually unless the sprite
    // render style is selected; missing sprites fall back to procedural).
    await spritePack.load(images);

    _background = ArenaBackground();
    await add(_background);

    player = PlayerComponent(position: arenaSize / 2);
    await add(player);
    final restoredHp = checkpoint?.playerHp;
    if (restoredHp != null) {
      player.hp = restoredHp.clamp(1, player.maxHp).toDouble();
    }

    _syncTouchControls();
    settings.addListener(_syncTouchControls);

    _particleBatch = ParticleBatchComponent()..priority = 40;
    await add(_particleBatch);

    // Draws above mobs/bullets/blast rings (all priority 0) but under the
    // particle batch (40) so a kill pop still reads over it.
    await add(ReticleComponent()..priority = 6);

    hud.maxHp.value = player.maxHp;
    hud.hp.value = player.hp;
    hud.gold.value = gameState.persistentGold;
    hud.ownedWeapons.value = List.of(gameState.equippedWeapons);
    hud.equippedWeaponIndex.value = gameState.equippedWeaponIndex;

    // A resumed run keeps its restored loadout and drops straight into the
    // round; a fresh run picks its loadout first; the tutorial runs its own
    // scripted training arena.
    if (tutorial) {
      _beginTutorial();
    } else if (checkpoint != null) {
      _beginRound(gameState.currentRound);
    } else {
      _enterLoadout();
    }
  }

  /// Starts the interactive training arena: equips the one-per-category
  /// starting trio, themes the arena, drops the player straight into play
  /// (invulnerable, see [PlayerComponent.takeDamage]), and hands control to a
  /// [TutorialDirector] that scripts the spawns and prompts. No spawner / round
  /// loop is created, so [update] skips the round telemetry while [tutorial].
  void _beginTutorial() {
    weaponResistance.resetForRound();
    _clearResistancePresentation();
    gameState.setEquippedWeapons(WeaponCatalog.startingLoadout);
    hud.ownedWeapons.value = List.of(gameState.equippedWeapons);
    hud.equippedWeaponIndex.value = gameState.equippedWeaponIndex;

    _background.applyBiome(BiomeCatalog.bloodstream);
    hud.biomeName.value = 'Training Arena';
    hud.round.value = 1;
    hud.roundProgress.value = 0;
    hud.enemiesRemaining.value = 0;
    hud.allWavesSpawned.value = false;
    phase.value = RoundPhase.playing;
    resumeEngine();

    add(TutorialDirector());
  }

  /// Spawns a single scripted enemy for the tutorial at [position].
  void spawnTutorialMob(EnemyDef def, Vector2 position) {
    spawnMob(createMobComponent(def, position.clone()));
  }

  /// Called by [TutorialDirector] on the final beat; the [GameScreen] listens
  /// to [tutorialComplete] and pops back to the menu.
  void completeTutorial() => tutorialComplete.value = true;

  /// Pauses gameplay and shows the loadout screen so the player can choose the
  /// (up to 3) weapons to equip for the upcoming round.
  void _enterLoadout() {
    // When the player owns no more weapons than they can equip, the loadout has
    // no real choice (every owned weapon must be slotted) - skip the no-op
    // screen and drop straight into the round. The overlay only matters once
    // the player has bought extra weapons to choose between.
    final owned = gameState.ownedWeapons;
    if (owned.length <= GameState.maxEquippedWeapons) {
      confirmLoadout(List<String>.of(owned));
      return;
    }
    phase.value = RoundPhase.loadout;
    pauseEngine();
  }

  /// Called by [LoadoutOverlay] once the player confirms their loadout. Equips
  /// the chosen weapons and starts the round.
  void confirmLoadout(List<String> chosen) {
    gameState.setEquippedWeapons(chosen);
    hud.ownedWeapons.value = List.of(gameState.equippedWeapons);
    hud.equippedWeaponIndex.value = gameState.equippedWeaponIndex;
    PlaytestLogger.instance.loadoutChosen(
      round: gameState.currentRound,
      equippedWeapons: gameState.equippedWeapons,
    );
    _beginRound(gameState.currentRound);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    arenaSize = size.clone();
  }

  @override
  void update(double dt) {
    activeMobs.removeWhere((mob) => mob.isDead);
    _rebuildMobGrid();
    // Resistance hit-stop: scale ONLY the simulation (super.update drives every
    // component uniformly). dt is never mutated, so the housekeeping/timers
    // below stay on real wall-clock time.
    final slowMoActive =
        _slowMoTimer > 0 &&
        phase.value == RoundPhase.playing &&
        !settings.value.reduceMotion;
    super.update(slowMoActive ? dt * _currentSlowMoFactor() : dt);

    _shake.update(dt);
    // On REAL dt and BEFORE the phase guard, so the banner/slow-mo timers keep
    // ticking even if the round resolves mid-presentation.
    _advanceResistancePresentation(dt);

    hud.dashCharge.value = player.dashChargeFraction;
    _updatePendingGoldSave(dt);
    _updatePerformanceTelemetry(dt);

    if (phase.value != RoundPhase.playing) return;

    // The tutorial has no spawner / round loop - the TutorialDirector drives
    // everything - so skip the round telemetry and round-clear check (which
    // would otherwise touch the uninitialized `_spawner`).
    if (tutorial || !_gameStateInitialized) return;

    _updateRoundTelemetry();

    // Resolve once every enemy is dead. We normally also wait for lingering
    // hazards (damage clouds / in-flight boss projectiles) to clear so the
    // engine never pauses mid-damage - but cap that wait so a slow-fading cloud
    // can't leave the player standing in an empty arena with the win screen
    // refusing to appear.
    final enemiesClear =
        _spawner.allWavesComplete && activeMobs.isEmpty && activeBoss == null;
    if (enemiesClear) {
      final hazardsClear =
          _budget.count(EntityBudget.cloud) == 0 &&
          _budget.count(EntityBudget.bossProjectile) == 0;
      _residualHazardWait += dt;
      if (hazardsClear || _residualHazardWait >= 1.2) {
        _onRoundCleared();
      }
    } else {
      _residualHazardWait = 0;
    }
  }

  /// Recomputes the round-progress bar and "germs remaining" readout.
  ///
  /// The bar fills to 80% as the scheduled waves spawn, then the final 20%
  /// tracks clearing the survivors. Crucially it reaches 1.0 *only* when no
  /// mobs remain - mitosis children are counted, so a "full" bar always
  /// means the round is genuinely about to advance.
  void _updateRoundTelemetry() {
    final boss = activeBoss;
    hud.bossHealthFraction.value = boss == null
        ? null
        : (boss.health / boss.maxHealth).clamp(0.0, 1.0);

    final total = _activeRoundDef?.totalSpawnCount ?? 0;
    final remaining = activeMobs.length;
    hud.enemiesRemaining.value = remaining;

    if (!_spawner.allWavesComplete) {
      hud.allWavesSpawned.value = false;
      final spawnFraction = total == 0 ? 0.0 : _spawner.spawnedCount / total;
      hud.roundProgress.value = (spawnFraction * 0.8).clamp(0.0, 0.8);
      return;
    }

    hud.allWavesSpawned.value = true;
    if (!_spawnPhaseComplete) {
      _spawnPhaseComplete = true;
      _peakMobsAfterSpawn = remaining;
    }
    // Mitosis children can spawn after the waves finish, so track the peak.
    if (remaining > _peakMobsAfterSpawn) _peakMobsAfterSpawn = remaining;

    final clearedFraction = _peakMobsAfterSpawn == 0
        ? 1.0
        : 1 - remaining / _peakMobsAfterSpawn;
    hud.roundProgress.value = (0.8 + clearedFraction * 0.2).clamp(0.0, 1.0);
  }

  // ---------------------------------------------------------------------
  // Round loop
  // ---------------------------------------------------------------------

  void _beginRound(int roundNumber) {
    final roundDef = RoundCatalog.all[roundNumber]!;
    _activeRoundDef = roundDef;
    _contextTipQueue.clear();
    weaponResistance.resetForRound();
    _clearResistancePresentation();
    _spawnPhaseComplete = false;
    _peakMobsAfterSpawn = 0;
    _roundResolved = false;
    _spawner = Spawner(roundDef);
    add(_spawner);

    // Retheme the arena for this round's map and surface its name. On the
    // opening round of a new map, show the biome's story intro as a transient
    // banner (no blocking cutscene - it auto-dismisses).
    final biome =
        BiomeCatalog.bySection[roundDef.sectionIndex] ??
        BiomeCatalog.bloodstream;
    _background.applyBiome(biome);
    hud.biomeName.value = biome.displayName;
    if (BiomeCatalog.isBiomeOpener(roundNumber)) {
      // A new biome's intro takes precedence over a queued field-notes tip.
      showContextTip(biome.intro);
      _pendingScienceTip = null;
    } else if (_pendingScienceTip != null) {
      // Surface the prior regular round's science as a transient banner. The
      // round-intro banner shows first; the context-tip overlay suppresses
      // itself until the intro auto-dismisses, so the two never collide.
      showContextTip(_pendingScienceTip!);
      _pendingScienceTip = null;
    }

    hud.round.value = roundNumber;
    hud.roundIntro.value = _roundIntroFor(roundDef, biome);
    hud.roundProgress.value = 0;
    hud.enemiesRemaining.value = 0;
    hud.allWavesSpawned.value = false;
    activeBoss = null;
    hud.bossName.value = null;
    hud.bossHealthFraction.value = null;
    phase.value = RoundPhase.playing;
    resumeEngine();

    if (roundDef.isBossRound) {
      _spawnBoss(roundDef.roundNumber);
    }
    PlaytestLogger.instance.roundStarted(
      round: roundNumber,
      biome: biome.displayName,
      isBoss: roundDef.isBossRound,
      equippedWeapons: gameState.equippedWeapons,
      hp: player.hp,
    );
    unawaited(saveRunCheckpoint());
  }

  RoundIntroData _roundIntroFor(RoundDef roundDef, BiomeDef biome) {
    final threatCounts = <String, int>{};
    for (final wave in roundDef.spawnWaves) {
      threatCounts.update(
        wave.enemyId,
        (count) => count + wave.count,
        ifAbsent: () => wave.count,
      );
    }

    final threatNames = threatCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final objective = roundDef.isBossRound
        ? roundDef.roundNumber >= 9
              ? 'Final assay: destroy the metastatic signal and hold the gland.'
              : 'Boss signal detected: dodge the attack pattern and clear adds.'
        : switch (roundDef.sectionIndex) {
            1 => 'Trace the early saliva signal through the bloodstream.',
            2 => 'Push deeper toward the pancreatic source of the signal.',
            _ =>
              'Defend the saliva sample and separate real clues from decoys.',
          };

    return RoundIntroData(
      roundNumber: roundDef.roundNumber,
      biomeName: biome.displayName,
      objective: objective,
      threatNames: [
        for (final entry in threatNames.take(3))
          EnemyCatalog.all[entry.key]?.displayName ?? entry.key,
      ],
      isBossRound: roundDef.isBossRound,
    );
  }

  /// Spawns the boss for [roundNumber] (3, 6, or 9), pre-seeding its
  /// [KrasResistanceState] from the player's most-used immune category so far
  /// this run - the tumor already carries cells that resist what you leaned on
  /// most, so a one-note strategy is punished (it is not the immune pressure
  /// that creates the resistance; resistant cells were already there).
  void _spawnBoss(int roundNumber) {
    final def = BossCatalog.all[roundNumber];
    if (def == null) return;

    final boss = BossComponent(def: def, position: arenaSize / 2);

    // KRAS pre-seed only when the player genuinely over-relied on one immune
    // response (>=55% of damage) - the lesson's warning. Balanced, matched
    // play (now the default targeting) is no longer punished for following
    // exactly what the game teaches.
    final mostUsed = gameState.categoryTracker.mostUsedCategory();
    if (mostUsed != null &&
        gameState.categoryTracker.mostUsedCategoryShare() >= 0.55) {
      boss.resistance.preSeedResistance(mostUsed);
    }

    activeBoss = boss;
    hud.bossName.value = def.displayName;
    queueContextTip(def.educationalBlurb);
    add(boss);
  }

  void showContextTip(String tip) {
    _contextTipQueue.clear();
    hud.contextTip.value = tip;
  }

  void queueContextTip(String tip) {
    if (hud.contextTip.value == null) {
      hud.contextTip.value = tip;
      return;
    }
    _contextTipQueue.add(tip);
  }

  void dismissContextTip() {
    hud.contextTip.value = _contextTipQueue.isEmpty
        ? null
        : _contextTipQueue.removeFirst();
  }

  void _onRoundCleared() {
    if (_roundResolved) return;
    _roundResolved = true;
    // The round-end modal chain pauses the engine (freezing the hold timer), so
    // drop any in-flight resistance banner/slow-mo now rather than stranding it.
    _clearResistancePresentation();

    AudioService.instance.playSfx('sfx/round_clear.wav');
    final dominantBeforeReset = gameState.categoryTracker.overall
        .dominantCategory();
    final mutated = gameState.categoryTracker.endRound();
    if (mutated) {
      final categoryName = dominantBeforeReset?.title ?? 'one response type';
      hud.contextTip.value =
          'Resistance building: cancer cells that already shrug off '
          '$categoryName are slipping through. Mix up your immune responses '
          'to keep the pressure on.';
      AudioService.instance.playSfx('sfx/mutation.wav');
    }
    _flushPendingGoldSave();
    _spawner.removeFromParent();

    PlaytestLogger.instance.roundCleared(
      round: gameState.currentRound,
      hp: player.hp,
    );

    final roundDef = _activeRoundDef;
    if (roundDef != null && roundDef.isBossRound) {
      final recap = _bossRecapFor(roundDef.roundNumber);
      if (recap != null) {
        hud.bossRecap.value = recap;
        unawaited(saveBetweenRoundCheckpoint());
        phase.value = RoundPhase.bossRecap;
        pauseEngine();
        return;
      }
    }

    _advanceToUpgradeOrSkip();
  }

  void _completeRunAndShowVictory() {
    _flushPendingGoldSave();
    PlaytestLogger.instance.victory(finalRound: gameState.currentRound);
    unawaited(persistence.clearCheckpoint());
    unawaited(
      persistence.updateSaveData(
        (save) =>
            save.copyWith(totalRunsCompleted: save.totalRunsCompleted + 1),
      ),
    );
    phase.value = RoundPhase.victory;
    pauseEngine();
  }

  /// Advances to the weapon-upgrade chooser, or skips it when there's only one
  /// equipped weapon (nothing to choose) by auto-applying the bump. Keeps the
  /// between-rounds modal chain shorter.
  void _advanceToUpgradeOrSkip() {
    final weapons = gameState.equippedWeapons;
    if (weapons.length <= 1) {
      if (weapons.isNotEmpty) {
        gameState.applyRunUpgrade(weapons.first);
        unawaited(saveBetweenRoundCheckpoint());
      }
      _afterUpgrade();
      return;
    }
    unawaited(saveBetweenRoundCheckpoint());
    phase.value = RoundPhase.gunUpgradeChoice;
    pauseEngine();
  }

  /// After the end-of-round upgrade is applied, branch on round type. Boss
  /// rounds pause for the full lesson + quiz (the deep teaching beats); regular
  /// rounds skip straight to the shop and surface the round's science as a
  /// non-blocking banner at the next round's start - so play isn't walled off
  /// by a modal chain every single round.
  void _afterUpgrade() {
    final roundDef = _activeRoundDef;
    if (roundDef != null && roundUsesBlockingLesson(roundDef)) {
      unawaited(saveBetweenRoundCheckpoint());
      phase.value = RoundPhase.lesson;
      pauseEngine();
      return;
    }
    if (roundDef != null) {
      _pendingScienceTip = _lessonBannerFor(roundDef.lessonId);
    }
    _proceedToShopOrNext();
  }

  /// Shows the gold shop when the player can afford something, otherwise
  /// advances straight to the next round. Shared by the regular-round and
  /// post-quiz paths.
  void _proceedToShopOrNext() {
    if (gameState.hasAffordableShopItem) {
      phase.value = RoundPhase.goldShop;
      pauseEngine();
    } else {
      unawaited(startNextRound());
    }
  }

  /// A short, non-blocking "field notes" banner derived from a lesson's
  /// reading text, shown on regular rounds in place of the full modal lesson.
  String? _lessonBannerFor(String lessonId) {
    return fieldNoteForLesson(lessonId);
  }

  BossRecapData? _bossRecapFor(int roundNumber) {
    final boss = BossCatalog.all[roundNumber];
    if (boss == null) return null;

    return BossRecapData(
      roundNumber: roundNumber,
      bossName: boss.displayName,
      stageLabel: bossRecapStageLabel(boss.attackStyle),
      fightTakeaway: bossRecapFightTakeaway(boss.attackStyle),
      scienceConnection: boss.educationalBlurb,
      nextStep: switch (roundNumber) {
        3 =>
          'Next, the mission moves from early duct changes toward localized tumor growth.',
        6 =>
          'Next, the sample enters the final noisy-signal push: separate biomarker clues from decoys.',
        _ => 'Next, convert the field data into a stronger detection strategy.',
      },
    );
  }

  void finishBossRecap() {
    hud.bossRecap.value = null;
    final roundDef = _activeRoundDef;
    phase.value = roundDef == null
        ? RoundPhase.gunUpgradeChoice
        : phaseAfterBossRecap(roundDef);
    unawaited(saveBetweenRoundCheckpoint());
    pauseEngine();
  }

  /// Called by [RoundEndUpgradeOverlay] when the player picks [weaponId]
  /// for its end-of-round stat bump.
  void chooseGunUpgrade(String weaponId) {
    gameState.applyRunUpgrade(weaponId);
    unawaited(saveBetweenRoundCheckpoint());
    _afterUpgrade();
  }

  /// Called by [LessonOverlay] once the player has read the lesson.
  void finishLesson() {
    phase.value = RoundPhase.quiz;
  }

  /// Called by [QuizOverlay] with the player's score and the number of
  /// questions in this round's quiz.
  void submitQuiz(int score, int totalQuestions) {
    gameState.lastQuizScore = score;
    gameState.totalQuizCorrect += score;
    gameState.totalQuizQuestions += totalQuestions;
    final roundDef = _activeRoundDef;
    if (roundDef != null && roundCompletesRun(roundDef)) {
      _completeRunAndShowVictory();
      return;
    }
    unawaited(saveBetweenRoundCheckpoint());
    // Skip the gold shop when there's nothing the player can afford - one
    // fewer modal in the between-round chain. The shop still appears the
    // moment anything is buyable.
    _proceedToShopOrNext();
  }

  /// Called once the player is done with the gold shop, advancing to the
  /// next round.
  Future<void> startNextRound() async {
    final nextRound = gameState.currentRound + 1;
    gameState.currentRound = nextRound;

    await persistence.updateSaveData((save) {
      final highest = nextRound > save.highestRoundReached
          ? nextRound
          : save.highestRoundReached;
      return save.copyWith(highestRoundReached: highest);
    });

    player.hp = player.maxHp;
    hud.hp.value = player.hp;
    hud.gold.value = gameState.persistentGold;

    _enterLoadout();
  }

  /// Records one connecting bullet hit for the weapon-resistance mechanic.
  /// Resistance builds from MISMATCHED (wrong-color) hits only - matched fire
  /// never contributes - so the lesson "fire the color that matches" is what
  /// keeps a weapon effective.
  void recordWeaponHit(String weaponId, {required bool matched}) {
    if (tutorial || phase.value != RoundPhase.playing) return;

    // Fairness: a wrong-color hit only builds resistance if the player COULD
    // have matched. When no live mob of this weapon's category is on screen,
    // auto-aim was forced onto an off-color target and the player can't swap to
    // a color that isn't present - so that unavoidable mismatch shouldn't count.
    if (!matched) {
      final category = WeaponCatalog.all[weaponId]?.category;
      if (category != null && !hasLiveMobOfCategory(category)) return;
    }

    final event = weaponResistance.recordHit(weaponId, matched: matched);
    // Keep the equipped weapon's pre-warning HUD heat in sync after every hit.
    if (weaponId == gameState.equippedWeaponId) {
      hud.equippedWeaponHeat.value = weaponResistance.mismatchProgressFor(
        weaponId,
      );
    }
    if (event == null) return;

    // A real tier (not the inert first warning) makes the mob population take
    // reduced damage from this weapon - apply it to everything already alive.
    if (!event.warningOnly) {
      for (final mob in activeMobs) {
        if (!mob.isDead) {
          mob.setWeaponResistanceTier(event.weaponId, event.tier);
        }
      }
    }

    _triggerResistancePresentation(event);
  }

  /// True if at least one live mob of [category] is currently in the arena.
  /// Cheap existence scan (early-exits, no distance math) used by the
  /// resistance fairness check.
  bool hasLiveMobOfCategory(ImmuneCategory category) {
    for (final mob in activeMobs) {
      if (!mob.isDead && mob.def.category == category) return true;
    }
    return false;
  }

  /// Shows the resistance banner (every event) and, rate-limited by a cooldown
  /// so escalations can't machine-gun the player, the disruptive layer: a brief
  /// slow-motion hit-stop, screen shake, and the mutation sting. The game (not
  /// the overlay) owns the banner's lifetime so it can never outlive the
  /// playing phase.
  void _triggerResistancePresentation(WeaponResistanceEvent event) {
    PlaytestLogger.instance.resistanceTriggered(
      round: gameState.currentRound,
      weaponId: event.weaponId,
      tier: event.tier,
      warningOnly: event.warningOnly,
      wrongTargetRatio: event.share,
    );
    final weaponName =
        WeaponCatalog.all[event.weaponId]?.displayName ?? 'Overused weapon';
    _resistanceAlertSeq++;
    hud.resistanceAlert.value = ResistanceAlertData(
      weaponName: weaponName,
      tier: event.tier,
      share: event.share,
      warningOnly: event.warningOnly,
      eventId: _resistanceAlertSeq,
    );
    _resistanceHoldTimer = _resistanceHoldSeconds;

    if (_presentationCooldown > 0) return;
    _presentationCooldown = _presentationCooldownSeconds;
    AudioService.instance.playSfx('sfx/mutation.wav');
    // Slow-mo + shake are motion; skip them under Reduce Motion (the banner +
    // sting + screen-reader announcement still convey the event).
    if (!settings.value.reduceMotion) {
      _slowMoTimer = _slowMoSeconds;
      triggerShake(event.warningOnly ? 5 : 9, 0.4);
    }
  }

  /// Eased slow-motion factor for the active hit-stop. Delegates to the pure
  /// [resistanceSlowMotionFactor] so the curve is unit-tested.
  static const double _slowMoHoldSeconds = 0.3;
  double _currentSlowMoFactor() => resistanceSlowMotionFactor(
    remaining: _slowMoTimer,
    total: _slowMoSeconds,
    hold: _slowMoHoldSeconds,
    target: _slowMoTarget,
  );

  /// Advances the resistance-alert timers on REAL time and clears the banner
  /// when its hold window ends. NOTE: update() does not run while the engine is
  /// paused (lesson/quiz/shop/recap/game-over), so these timers only tick during
  /// the playing phase. The banner can never strand on a modal because
  /// [_clearResistancePresentation] is called on every exit from playing
  /// (round-clear, pause, death) - that is the real invariant, not "ticks in
  /// every phase".
  void _advanceResistancePresentation(double dt) {
    if (_presentationCooldown > 0) {
      _presentationCooldown = max(0, _presentationCooldown - dt);
    }
    if (_slowMoTimer > 0) {
      _slowMoTimer = max(0, _slowMoTimer - dt);
    }
    if (_resistanceHoldTimer > 0) {
      _resistanceHoldTimer = max(0, _resistanceHoldTimer - dt);
      if (_resistanceHoldTimer <= 0) {
        hud.resistanceAlert.value = null;
      }
    }
  }

  /// Force-clears any in-flight resistance presentation. Called on every exit
  /// from the playing phase so a banner/slow-mo triggered in the final moments
  /// of a round can't strand itself on the round-end modals (the engine pauses
  /// during those, freezing the hold timer).
  void _clearResistancePresentation() {
    _slowMoTimer = 0;
    _resistanceHoldTimer = 0;
    hud.resistanceAlert.value = null;
    hud.equippedWeaponHeat.value = 0;
  }

  Future<void> saveRunCheckpoint({int? roundNumber, double? playerHp}) async {
    // The training arena is not a resumable run - never write a checkpoint for
    // it, or pausing + "Save & Quit" would leave a phantom "Continue Run" on
    // the home screen.
    if (tutorial) return;
    _flushPendingGoldSave();
    await persistence.saveCheckpoint(
      CheckpointData(
        roundNumber: roundNumber ?? gameState.currentRound,
        playerHp: playerHp ?? player.hp,
        goldThisRun: gameState.goldThisRun,
        equippedWeapons: List.of(gameState.equippedWeapons),
        runUpgradeCounts: Map.of(gameState.runUpgradeCounts),
        equippedWeaponIndex: gameState.equippedWeaponIndex,
        totalQuizCorrect: gameState.totalQuizCorrect,
        totalQuizQuestions: gameState.totalQuizQuestions,
      ),
    );
  }

  Future<void> saveBetweenRoundCheckpoint() async {
    final roundNumber = _resumableRoundForCurrentPhase();
    if (roundNumber == null) return;
    await saveRunCheckpoint(roundNumber: roundNumber, playerHp: player.maxHp);
  }

  int? _resumableRoundForCurrentPhase() {
    if (tutorial || !_gameStateInitialized) return null;
    final clearedRound = _activeRoundDef;
    return resumableCheckpointRoundForPhase(
      phase: phase.value,
      currentRound: gameState.currentRound,
      clearedRound: _roundResolved ? clearedRound?.roundNumber : null,
      clearedRoundCompletesRun: clearedRound == null
          ? false
          : roundCompletesRun(clearedRound),
    );
  }

  // ---------------------------------------------------------------------
  // Spawning
  // ---------------------------------------------------------------------

  bool spawnMob(MobComponent mob) {
    if (activeMobs.length >= maxLiveMobHardCap) return false;
    mob.setWeaponResistanceTiers(weaponResistance.activeTiers);
    pushPointOutsideTopLeftHudBlock(mob.position, arenaSize, mob.radius);
    activeMobs.add(mob);
    add(mob);
    return true;
  }

  Iterable<MobComponent> nearbyMobs(Vector2 position, double radius) sync* {
    final radiusSquared = radius * radius;
    if (!_mobGridBuilt) {
      // Grid not built yet (e.g. a query before the first update tick): fall
      // back to a brute-force scan, but still honor the requested radius so
      // callers like the explosion AoE never get out-of-range hits.
      for (final mob in activeMobs) {
        if (!mob.isDead &&
            mob.position.distanceToSquared(position) <= radiusSquared) {
          yield mob;
        }
      }
      return;
    }

    final minX = ((position.x - radius) / _mobGridCellSize).floor();
    final maxX = ((position.x + radius) / _mobGridCellSize).floor();
    final minY = ((position.y - radius) / _mobGridCellSize).floor();
    final maxY = ((position.y + radius) / _mobGridCellSize).floor();

    for (var x = minX; x <= maxX; x++) {
      for (var y = minY; y <= maxY; y++) {
        final cell = _mobGrid[_cellKey(x, y)];
        if (cell == null) continue;
        for (final mob in cell) {
          if (mob.isDead) continue;
          if (mob.position.distanceToSquared(position) <= radiusSquared) {
            yield mob;
          }
        }
      }
    }
  }

  MobComponent? nearestMob(
    Vector2 position, {
    ImmuneCategory? category,
    double radius = double.infinity,
    bool excludeDecoys = false,
  }) {
    final candidates = radius.isFinite
        ? nearbyMobs(position, radius)
        : activeMobs.where((mob) => !mob.isDead);
    MobComponent? nearest;
    var nearestDist = double.infinity;
    for (final mob in candidates) {
      if (category != null && mob.def.category != category) continue;
      // Homing/replication shouldn't waste itself curving onto fragile decoy
      // clutter - those are cleared by movement and normal fire.
      if (excludeDecoys && mob.def.behavior == EnemyBehaviorId.decoySignal) {
        continue;
      }
      final dist = mob.position.distanceToSquared(position);
      if (dist < nearestDist) {
        nearestDist = dist;
        nearest = mob;
      }
    }
    return nearest;
  }

  MobComponent? mobHitByCircle(
    Vector2 position,
    double radius, {
    Set<MobComponent>? ignored,
    ImmuneCategory? category,
  }) {
    final searchRadius = radius + _maxMobHitRadius;
    final candidates = !_mobGridBuilt
        ? activeMobs.where((mob) => !mob.isDead)
        : _mobsInGridBounds(position, searchRadius);

    MobComponent? nearest;
    var nearestDist = double.infinity;
    for (final mob in candidates) {
      if (mob.isDead) continue;
      if (ignored != null && ignored.contains(mob)) continue;
      if (category != null && mob.def.category != category) continue;

      final hitRadius = radius + mob.radius;
      final dist = mob.position.distanceToSquared(position);
      if (dist <= hitRadius * hitRadius && dist < nearestDist) {
        nearestDist = dist;
        nearest = mob;
      }
    }
    return nearest;
  }

  /// Spawns a mitosis child for [def] at [position], used by
  /// [MitosisBehavior].
  void spawnMobChild({
    required EnemyDef def,
    required Vector2 position,
    required double health,
    required double radius,
    required int generation,
    double behaviorIntensity = 1.0,
  }) {
    final mob = createMobComponent(
      def,
      position,
      generation: generation,
      healthOverride: health,
      radiusOverride: radius,
    );
    mob.behaviorIntensity = behaviorIntensity;
    spawnMob(mob);
  }

  /// Adds [bullet], honoring the bullet budget. Returns true if it was actually
  /// spawned (false when the cap is hit), so callers can avoid playing fire
  /// feedback for a shot that never materialized.
  bool spawnBullet(Component bullet) {
    if (bullet is BulletComponent) {
      if (!_budget.tryAcquire(EntityBudget.bullet, 180)) return false;
    }
    add(bullet);
    return true;
  }

  void onBulletRemoved() {
    _budget.release(EntityBudget.bullet);
  }

  /// Hard cap on simultaneously-live boss projectiles. Boss patterns can emit
  /// large radial/fan volleys on a short cooldown in the round-9 fight; without
  /// a ceiling these would bypass the budget every other entity respects and
  /// choke low-end devices. Excess spawns are dropped silently (like bullets).
  static const int _bossProjectileCap = 60;

  /// Adds a boss projectile against [_bossProjectileCap]. Returns false (and
  /// drops the projectile) when the cap is reached.
  bool spawnBossProjectile(BossProjectileComponent projectile) {
    if (!_budget.tryAcquire(EntityBudget.bossProjectile, _bossProjectileCap)) {
      return false;
    }
    add(projectile);
    return true;
  }

  void onBossProjectileRemoved() {
    _budget.release(EntityBudget.bossProjectile);
  }

  void spawnDamageCloud({
    required Vector2 position,
    required double radius,
    required double damagePerSecond,
    required double duration,
    double warningSeconds = 0,
  }) {
    final cloudCap = warningSeconds > 0 ? 36 : 28;
    if (!_budget.tryAcquire(EntityBudget.cloud, cloudCap)) return;
    add(
      DamageCloudComponent(
        position: position,
        radius: radius,
        damagePerSecond: damagePerSecond,
        duration: duration,
        warningSeconds: warningSeconds,
      ),
    );
  }

  void onDamageCloudRemoved() {
    _budget.release(EntityBudget.cloud);
  }

  /// Spawns up to [count] short-lived hit/death particles at [position],
  /// scaled by [SettingsData.particleDensity] and capped overall by
  /// [ParticleDensity.maxConcurrent] so a chaotic arena can't spiral into
  /// thousands of live particles.
  void spawnParticles({
    required Vector2 position,
    required Color color,
    required int count,
  }) {
    final density = settings.value.particleDensity;
    if (density == ParticleDensity.off) return;

    final requestedCount =
        activeMobs.length >= FxConstants.highMobCountGlowCutoff
        ? min(count, 3)
        : count;
    final actualCount = (requestedCount * density.spawnMultiplier).round();
    final budget = density.maxConcurrent - _particleBatch.activeCount;
    final spawnCount = actualCount.clamp(0, budget < 0 ? 0 : budget);

    for (var i = 0; i < spawnCount; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 40 + rng.nextDouble() * 80;
      final velocity = Vector2(cos(angle), sin(angle)) * speed;
      _particleBatch.spawn(
        position: position,
        velocity: velocity,
        color: color,
      );
    }
  }

  /// Legacy hook for old per-particle components. New hit sparks are batched
  /// through [_particleBatch], but keeping this hook makes the standalone
  /// component harmless if it is used during experiments.
  void onParticleRemoved() {}

  /// Called when an elite mob spawns. Shows a one-time-per-run explainer so a
  /// first-time player understands the gold ring marks a tougher threat.
  void notifyEliteSpawned() {
    if (_eliteTipShown || tutorial) return;
    _eliteTipShown = true;
    hud.contextTip.value =
        'Gold-ringed threats are elites - tougher and harder-hitting. '
        'Focus them down.';
  }

  /// Spawns a floating damage number at [position]. [matched] colors/sizes it
  /// to show the category match bonus vs. mismatch penalty. Capped so heavy
  /// fire can't flood the screen with text.
  void spawnDamageNumber(Vector2 position, double amount, bool matched) {
    if (amount <= 0) return;
    if (!_budget.tryAcquire(EntityBudget.damageNumber, 18)) return;
    final spot = position.clone()
      ..x += (rng.nextDouble() - 0.5) * 14
      ..y -= 8;
    add(
      FloatingDamageNumberComponent(
        position: spot,
        amount: amount,
        matched: matched,
      ),
    );
  }

  void onDamageNumberRemoved() {
    _budget.release(EntityBudget.damageNumber);
  }

  /// Floats a "+N gold" reward number up from [position] (a kill). Capped so a
  /// big wave doesn't flood the screen.
  void spawnGoldNumber(Vector2 position, int amount) {
    if (amount <= 0) return;
    if (!_budget.tryAcquire(EntityBudget.goldNumber, 14)) return;
    final spot = position.clone()..x += (rng.nextDouble() - 0.5) * 12;
    add(FloatingGoldNumberComponent(position: spot, amount: amount));
  }

  void onGoldNumberRemoved() {
    _budget.release(EntityBudget.goldNumber);
  }

  /// Spawns a one-shot expanding "blast" ring at [position] on a kill.
  void spawnBlastRing(Vector2 position, double maxRadius, Color color) {
    if (!_budget.tryAcquire(EntityBudget.blastRing, 16)) return;
    add(
      BlastRingComponent(
        position: position,
        maxRadius: maxRadius,
        color: color,
      ),
    );
  }

  void onBlastRingRemoved() {
    _budget.release(EntityBudget.blastRing);
  }

  // ---------------------------------------------------------------------
  // Mob / player / coin callbacks
  // ---------------------------------------------------------------------

  void onMobDefeated(MobComponent mob) {
    activeMobs.remove(mob);
    hud.kills.value++;

    final pos = mob.position.clone();
    final gold = mob.def.coinValue;

    // Kill blast: a bigger particle pop + an expanding ring so a kill reads as
    // a satisfying "blast", colored by the response that cleared it.
    spawnParticles(
      position: pos,
      color: colorblindCategoryColor(
        mob.def.category,
        settings.value.colorblindMode,
      ),
      count: mob.isElite ? 18 : 12,
    );
    spawnBlastRing(
      mob.position.clone(),
      mob.radius * (mob.isElite ? 2.2 : 1.7),
      colorblindCategoryColor(mob.def.category, settings.value.colorblindMode),
    );

    // Reward: every kill drops a coin worth the enemy's gold and floats a
    // "+N gold" up from the blast so you see exactly what you won. The coin
    // magnets to the player, where collecting it pulses + dings the tracker.
    spawnCoin(position: mob.position.clone(), value: gold);
    spawnGoldNumber(pos.clone(), gold);

    // Round progress + "germs remaining" are recomputed every tick in
    // [_updateRoundTelemetry] so they account for mitosis children too.
  }

  /// Called by [BossComponent.die] once the boss's health reaches zero.
  /// Drops a small handful of coins, clears [activeBoss] and its HUD
  /// readouts, and lets [update] proceed to [_onRoundCleared] once any
  /// remaining mobs are also cleared.
  void onBossDefeated(BossComponent boss) {
    activeBoss = null;
    hud.bossName.value = null;
    hud.bossHealthFraction.value = null;

    // The boss is the round's centerpiece, so its payout should read as a
    // reward (it used to drop less than ~12 regular kills). Dropped as a few
    // chunky coins so the magnet-collect lands as one satisfying payday.
    const bossGold = 120;
    const bossCoinCount = 8;
    spawnBlastRing(
      boss.position.clone(),
      boss.radius * 2.6,
      const Color(0xFFFFD166),
    );
    spawnGoldNumber(boss.position.clone(), bossGold);
    for (var i = 0; i < bossCoinCount; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final offset = Vector2(cos(angle), sin(angle)) * (boss.radius * 0.7);
      spawnCoin(
        position: boss.position + offset,
        value: bossGold ~/ bossCoinCount,
      );
    }
  }

  void spawnCoin({required Vector2 position, required int value}) {
    if (!_budget.tryAcquire(EntityBudget.coin, 50)) {
      // Coin cap reached: bank the gold immediately instead of spawning a
      // pickup so the reward isn't lost in a chaotic fight.
      gameState.addGoldLocal(value);
      _queueGoldSave(value);
      hud.gold.value = gameState.persistentGold;
      return;
    }
    add(CoinComponent(position: position, value: value));
  }

  void onCoinRemoved() {
    _budget.release(EntityBudget.coin);
  }

  void collectCoin(int value) {
    AudioService.instance.playSfx('sfx/coin.wav');
    gameState.addGoldLocal(value);
    _queueGoldSave(value);
    hud.gold.value = gameState.persistentGold;
  }

  void onPlayerDamaged() {
    hud.hp.value = player.hp;
  }

  void onPlayerDied() {
    _flushPendingGoldSave();
    PlaytestLogger.instance.playerDied(
      round: gameState.currentRound,
      bossActive: activeBoss != null,
      liveMobCount: activeMobs.length,
    );
    unawaited(persistence.clearCheckpoint());
    // Drop any in-flight resistance banner/slow-mo so it can't strand itself on
    // the game-over screen (the engine pauses below, freezing its hold timer).
    _clearResistancePresentation();
    phase.value = RoundPhase.gameOver;
    pauseEngine();
  }

  /// Toggles the pause overlay. Only available during active gameplay -
  /// other phases (lesson, quiz, shop, ...) already pause the engine and
  /// show their own overlay.
  void togglePause() {
    if (phase.value != RoundPhase.playing) return;
    if (paused) {
      resumeEngine();
      overlays.remove('pause');
    } else {
      // Drop any in-flight resistance banner/slow-mo first: pausing freezes the
      // update loop, so its hold timer would otherwise strand the banner over
      // the pause overlay (and replay slow-mo on resume). This is the most
      // common path - the app-lifecycle auto-pause on backgrounding routes here.
      _clearResistancePresentation();
      pauseEngine();
      overlays.add('pause');
    }
  }

  /// Dash button / key entry point used by the HUD and keyboard handler.
  void tryDash() {
    if (phase.value != RoundPhase.playing) return;
    if (player.tryDash()) {
      AudioService.instance.playSfx('sfx/dash.wav');
    }
    hud.dashCharge.value = player.dashChargeFraction;
  }

  /// Cycle to the next equipped weapon (Q key + the HUD swap button).
  void cycleWeapon() {
    if (phase.value != RoundPhase.playing) return;
    final before = gameState.equippedWeaponIndex;
    gameState.cycleEquippedWeapon();
    if (gameState.equippedWeaponIndex != before) {
      // Audio for the core swap action - reinforces the load-bearing input.
      AudioService.instance.playSfx('sfx/swap.wav');
      PlaytestLogger.instance.noteSwap();
    }
    hud.equippedWeaponIndex.value = gameState.equippedWeaponIndex;
    _syncEquippedWeaponHeat();
  }

  /// Directly equip the weapon at [index] (HUD weapon-chip tap).
  void selectWeapon(int index) {
    if (phase.value != RoundPhase.playing) return;
    final before = gameState.equippedWeaponIndex;
    gameState.selectEquippedWeapon(index);
    if (gameState.equippedWeaponIndex != before) {
      AudioService.instance.playSfx('sfx/swap.wav');
      PlaytestLogger.instance.noteSwap();
    }
    hud.equippedWeaponIndex.value = gameState.equippedWeaponIndex;
    _syncEquippedWeaponHeat();
  }

  /// Updates the equipped-weapon pre-warning heat to match the currently
  /// equipped weapon's mismatch progress (called on swap; the per-hit path
  /// updates it inline).
  void _syncEquippedWeaponHeat() {
    hud.equippedWeaponHeat.value = weaponResistance.mismatchProgressFor(
      gameState.equippedWeaponId,
    );
  }

  /// Whether on-screen touch controls (joystick, dash, weapon-swap) should
  /// show. Auto-detects a mobile device via the platform / browser user-agent,
  /// overridable via [SettingsData.touchControlsMode].
  bool get touchControlsEnabled =>
      touchControlsActiveFor(settings.value.touchControlsMode);

  /// Adds or removes the movement joystick to match [touchControlsEnabled].
  /// The Flutter HUD reacts to the same flag, so the two never disagree.
  /// Re-runs whenever settings change so the override applies live.
  void _syncTouchControls() {
    final show = touchControlsEnabled;
    final current = joystick;
    if (show && current == null) {
      final js = JoystickComponent(
        // Knob is a primary always-on control, so keep it at/above the ~44-48px
        // touch-target minimum (24px radius = 48px) with higher contrast.
        knob: CircleComponent(
          radius: 24,
          paint: Paint()..color = const Color(0xCCFFFFFF),
        ),
        background: CircleComponent(
          radius: 46,
          paint: Paint()..color = const Color(0x40FFFFFF),
        ),
        margin: const EdgeInsets.only(left: 28, bottom: 28),
      );
      joystick = js;
      add(js);
    } else if (!show && current != null) {
      current.removeFromParent();
      joystick = null;
    }
  }

  /// Persists pending gold and (mid-run) the checkpoint immediately. Called
  /// from the app-lifecycle observer when the app is backgrounded or the
  /// browser tab is closing, so coins/round progress aren't lost.
  void flushForBackground() {
    _flushPendingGoldSave();
    PlaytestLogger.instance.endSession('background');
    unawaited(saveBetweenRoundCheckpoint());
  }

  // ---------------------------------------------------------------------
  // Input
  // ---------------------------------------------------------------------

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final acceptsGameplayInput = phase.value == RoundPhase.playing && !paused;
    if (!acceptsGameplayInput) {
      pressedKeys.clear();
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.f3) {
        hud.performanceOverlayEnabled.value =
            !hud.performanceOverlayEnabled.value;
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    pressedKeys
      ..clear()
      ..addAll(movementKeysFor(keysPressed));

    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.shiftLeft ||
            event.logicalKey == LogicalKeyboardKey.shiftRight)) {
      tryDash();
    }

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.f3) {
      hud.performanceOverlayEnabled.value =
          !hud.performanceOverlayEnabled.value;
    }

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyQ) {
      cycleWeapon();
    }

    return KeyEventResult.handled;
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    // Arena coordinates == widget coordinates (no camera zoom/pan), so the
    // widget-local pointer position is directly usable as a world target.
    mouseWorldPosition.setFrom(info.eventPosition.widget);
    _hasMousePosition = true;
  }

  /// Briefly offsets the whole render in random directions, decaying from
  /// [magnitude] (pixels) over [duration] (seconds). A no-op if
  /// [SettingsData.screenShakeEnabled] is off. Repeated calls only escalate
  /// the shake - they never shorten an in-progress, stronger shake.
  void triggerShake(double magnitude, double duration) {
    if (!settings.value.screenShakeEnabled) return;
    _shake.trigger(magnitude, duration);
  }

  void _queueGoldSave(int amount) {
    if (amount <= 0) return;
    _pendingGoldSave += amount;
    _goldSaveDelay = 0.75;
  }

  void _updatePendingGoldSave(double dt) {
    if (_pendingGoldSave <= 0) return;
    _goldSaveDelay -= dt;
    if (_goldSaveDelay <= 0) {
      _flushPendingGoldSave();
    }
  }

  void _rebuildMobGrid() {
    // Reuse the cell lists across frames - clear in place rather than dropping
    // and reallocating the map + per-cell lists every tick.
    for (final cell in _mobGrid.values) {
      cell.clear();
    }
    for (final mob in activeMobs) {
      if (mob.isDead) continue;
      final key = _cellKey(
        (mob.position.x / _mobGridCellSize).floor(),
        (mob.position.y / _mobGridCellSize).floor(),
      );
      (_mobGrid[key] ??= []).add(mob);
    }
    _mobGridBuilt = true;
  }

  Iterable<MobComponent> _mobsInGridBounds(
    Vector2 position,
    double radius,
  ) sync* {
    final minX = ((position.x - radius) / _mobGridCellSize).floor();
    final maxX = ((position.x + radius) / _mobGridCellSize).floor();
    final minY = ((position.y - radius) / _mobGridCellSize).floor();
    final maxY = ((position.y + radius) / _mobGridCellSize).floor();

    for (var x = minX; x <= maxX; x++) {
      for (var y = minY; y <= maxY; y++) {
        final cell = _mobGrid[_cellKey(x, y)];
        if (cell == null) continue;
        for (final mob in cell) {
          if (!mob.isDead) yield mob;
        }
      }
    }
  }

  void _updatePerformanceTelemetry(double dt) {
    if (dt > 0) {
      final fps = 1 / dt;
      _smoothedFps = _smoothedFps * 0.9 + fps * 0.1;
    }
    hud.fps.value = _smoothedFps;
    hud.activeMobCount.value = activeMobs.length;
    hud.activeBulletCount.value = _budget.count(EntityBudget.bullet);
    hud.activeParticleCount.value = _particleBatch.activeCount;
    hud.activeCoinCount.value = _budget.count(EntityBudget.coin);
    hud.activeCloudCount.value = _budget.count(EntityBudget.cloud);
  }

  void _flushPendingGoldSave() {
    if (_pendingGoldSave <= 0) return;
    _pendingGoldSave = 0;
    _goldSaveDelay = 0;
    unawaited(persistence.saveSaveData(persistence.saveData));
  }

  @override
  void render(Canvas canvas) {
    if (!_shake.isActive) {
      super.render(canvas);
      return;
    }
    canvas.save();
    canvas.translate(_shake.offset.x, _shake.offset.y);
    super.render(canvas);
    canvas.restore();
  }

  @override
  void onRemove() {
    settings.removeListener(_syncTouchControls);
    _flushPendingGoldSave();
    hud.dispose();
    phase.dispose();
    tutorialComplete.dispose();
    super.onRemove();
  }
}
