import '../data/enemies/enemy_dictionary_def.dart';
import '../data/progression/persistent_shop_def.dart';
import '../data/progression/targeting_upgrade_def.dart';
import '../data/weapons/weapon_catalog.dart';
import '../services/persistence_service.dart';
import '../services/playtest_logger.dart';
import '../services/save_data.dart';
import 'systems/category_tracker.dart';

/// High-level phase of the round loop:
/// `playing -> optional bossRecap -> gunUpgradeChoice -> lesson -> quiz
/// -> goldShop -> loadout -> playing` (next round), with `victory`/`gameOver`
/// as terminal states.
enum RoundPhase {
  playing,
  roundClear,
  bossRecap,
  gunUpgradeChoice,
  lesson,
  quiz,
  goldShop,
  loadout,
  victory,
  gameOver,
}

/// Run-scoped progression and state: current round, owned/equipped weapons,
/// run-only gun upgrades (from end-of-round picks), gold earned this run,
/// and the category-usage tracker that feeds the KRAS mutation mechanic.
///
/// Persistent (cross-session) state - [SaveData.goldCoins],
/// [SaveData.gunUpgrades] (gold-shop levels/traits), [SaveData.settings] -
/// is read/written via [persistence] directly.
class GameState {
  GameState({required this.persistence, CheckpointData? checkpoint}) {
    _restoreCheckpoint(checkpoint);
  }

  final PersistenceService persistence;

  int currentRound = 1;
  int goldThisRun = 0;

  /// Maximum weapons equipped (and cycled with Q/Tab) in a single round.
  static const int maxEquippedWeapons = 3;

  /// The weapons equipped for the current round, chosen from [ownedWeapons]
  /// via the loadout screen. Combat cycles only through these.
  List<String> equippedWeapons = <String>[];
  int equippedWeaponIndex = 0;

  /// Number of times each weapon's end-of-round upgrade has been picked
  /// this run. Reset when a new run starts.
  final Map<String, int> runUpgradeCounts = {};

  final CategoryTracker categoryTracker = CategoryTracker();

  /// Score (0-3) from the most recently completed quiz. Drives the gold
  /// shop discount.
  int lastQuizScore = 0;

  /// Cumulative quiz totals across this run, used for the
  /// [VictoryOverlay]/[GameOverOverlay] run summary.
  int totalQuizCorrect = 0;
  int totalQuizQuestions = 0;

  void _restoreCheckpoint(CheckpointData? checkpoint) {
    if (checkpoint == null) {
      equippedWeapons = _defaultLoadout();
      return;
    }

    currentRound = checkpoint.roundNumber
        .clamp(1, CheckpointData.maxRound)
        .toInt();
    goldThisRun = checkpoint.goldThisRun;
    totalQuizCorrect = checkpoint.totalQuizCorrect;
    totalQuizQuestions = checkpoint.totalQuizQuestions;

    final restored = checkpoint.equippedWeapons
        .where(WeaponCatalog.all.containsKey)
        .where(ownedWeapons.contains)
        .take(maxEquippedWeapons)
        .toList();
    equippedWeapons = restored.isEmpty ? _defaultLoadout() : restored;
    equippedWeaponIndex = checkpoint.equippedWeaponIndex
        .clamp(0, equippedWeapons.length - 1)
        .toInt();

    runUpgradeCounts.addEntries(
      checkpoint.runUpgradeCounts.entries.where(
        (entry) => WeaponCatalog.all.containsKey(entry.key) && entry.value > 0,
      ),
    );
  }

  /// Weapons the player owns (persistent pool) - the loadout/shop source.
  List<String> get ownedWeapons => persistence.saveData.ownedWeapons;

  /// A sensible default loadout: the first [maxEquippedWeapons] owned weapons.
  /// Because [ownedWeapons] always leads with the one-per-category starting
  /// trio, this covers all three categories on a fresh save.
  List<String> _defaultLoadout() => ownedWeapons
      .where(WeaponCatalog.all.containsKey)
      .take(maxEquippedWeapons)
      .toList();

  /// Replaces the equipped loadout for the round (called by the loadout
  /// screen). Filters to owned/valid weapons and caps at [maxEquippedWeapons].
  void setEquippedWeapons(List<String> weapons) {
    final valid = weapons
        .where(WeaponCatalog.all.containsKey)
        .where(ownedWeapons.contains)
        .take(maxEquippedWeapons)
        .toList();
    equippedWeapons = valid.isEmpty ? _defaultLoadout() : valid;
    equippedWeaponIndex = 0;
  }

  String get equippedWeaponId {
    if (equippedWeapons.isEmpty) return WeaponCatalog.startingLoadout.first;
    return equippedWeapons[equippedWeaponIndex.clamp(
      0,
      equippedWeapons.length - 1,
    )];
  }

  void cycleEquippedWeapon() {
    if (equippedWeapons.length <= 1) return;
    equippedWeaponIndex = (equippedWeaponIndex + 1) % equippedWeapons.length;
  }

  /// Directly equips the weapon at [index] (clamped), used by tap-to-select
  /// on touch and any direct weapon picker.
  void selectEquippedWeapon(int index) {
    if (equippedWeapons.isEmpty) return;
    equippedWeaponIndex = index.clamp(0, equippedWeapons.length - 1);
  }

  GunPersistentState persistentGunState(String weaponId) =>
      persistence.saveData.gunState(weaponId);

  int runUpgradeCount(String weaponId) => runUpgradeCounts[weaponId] ?? 0;

  /// Upper bound on end-of-round upgrade stacks for a single weapon in one run.
  /// A legit 9-round run picks at most ~8; this just keeps the additive stat
  /// bonus (applied linearly in computeEffectiveStats) from being driven to an
  /// absurd value by a corrupted/edited save restore.
  static const int maxRunUpgradeStacks = 16;

  /// Applies the end-of-round "pick one gun to upgrade" choice for
  /// [weaponId]. Run-scoped only - not persisted.
  void applyRunUpgrade(String weaponId) {
    final next = (runUpgradeCounts[weaponId] ?? 0) + 1;
    runUpgradeCounts[weaponId] = next.clamp(0, maxRunUpgradeStacks);
  }

  bool isWeaponOwned(String weaponId) => ownedWeapons.contains(weaponId);

  /// Discounted gold cost to buy [weaponId] in the shop, or null if it's
  /// already owned or isn't a purchasable weapon.
  int? weaponPurchaseCost(String weaponId) {
    if (isWeaponOwned(weaponId)) return null;
    final base = WeaponCatalog.shopUnlockCost[weaponId];
    if (base == null) return null;
    return (base * (1 - quizDiscount)).round();
  }

  /// Attempts to buy [weaponId] into the persistent pool. Returns true on
  /// success.
  Future<bool> purchaseWeapon(String weaponId) async {
    final cost = weaponPurchaseCost(weaponId);
    if (cost == null || persistentGold < cost) return false;

    await persistence.updateSaveData((save) {
      if (save.ownedWeapons.contains(weaponId)) return save;
      return save.copyWith(
        goldCoins: save.goldCoins - cost,
        ownedWeapons: [...save.ownedWeapons, weaponId],
      );
    });
    PlaytestLogger.instance.shopPurchase(
      kind: 'weapon',
      id: weaponId,
      cost: cost,
      goldAfter: persistentGold,
    );
    return true;
  }

  /// Discount fraction applied to gold-shop prices based on quiz score:
  /// 3/3 = 15%, 2/3 = 10%, 1/3 = 5%, 0/3 = 0%.
  static double quizDiscountForScore(int score) => switch (score) {
    3 => 0.15,
    2 => 0.10,
    1 => 0.05,
    _ => 0.0,
  };

  double get quizDiscount => quizDiscountForScore(lastQuizScore);

  /// Adds gold to the in-memory save immediately. The caller can persist
  /// later, which avoids a storage write for every single coin pickup.
  void addGoldLocal(int amount) {
    if (amount <= 0) return;
    goldThisRun += amount;
    // Replace (don't mutate) the save object so an in-flight persistence write's
    // prior-state backup can never be corrupted by this increment.
    persistence.addLocalGold(amount);
  }

  int get persistentGold => persistence.saveData.goldCoins;

  /// True if the player can currently afford at least one thing in the gold
  /// shop (any weapon, stat upgrade, trait unlock, targeting tier, or Smart
  /// Aim). When false, the shop has nothing to offer and is auto-skipped to
  /// trim the between-round modal chain.
  bool get hasAffordableShopItem {
    bool affordable(int? cost) => cost != null && persistentGold >= cost;

    for (final id in WeaponCatalog.shopUnlockCost.keys) {
      if (affordable(weaponPurchaseCost(id))) return true;
    }
    for (final id in ownedWeapons) {
      if (affordable(statUpgradeCost(id))) return true;
    }
    for (final unlock in PersistentShopCatalog.traitUnlocks) {
      if (!ownedWeapons.contains(unlock.weaponId)) continue;
      if (persistentGunState(
        unlock.weaponId,
      ).unlockedTraits.contains(unlock.traitId)) {
        continue;
      }
      if (affordable(traitUnlockCost(unlock))) return true;
    }
    if (affordable(targetingUpgradeCost())) return true;
    if (affordable(smartAimUnlockCost())) return true;
    return false;
  }

  /// Discounted gold cost to take [weaponId]'s persistent stat upgrade to
  /// the next level, or null if already at max level.
  int? statUpgradeCost(String weaponId) {
    final upgrade = PersistentShopCatalog.statUpgrades[weaponId];
    if (upgrade == null) return null;
    final level = persistentGunState(weaponId).statLevel;
    final base = upgrade.costForNextLevel(level);
    if (base == null) return null;
    return (base * (1 - quizDiscount)).round();
  }

  /// Attempts to purchase the next persistent stat upgrade level for
  /// [weaponId]. Returns true if the purchase succeeded.
  Future<bool> purchaseStatUpgrade(String weaponId) async {
    final cost = statUpgradeCost(weaponId);
    if (cost == null || persistentGold < cost) return false;

    await persistence.updateSaveData((save) {
      final gunUpgrades = Map<String, GunPersistentState>.of(save.gunUpgrades);
      final current = gunUpgrades[weaponId] ?? GunPersistentState();
      gunUpgrades[weaponId] = GunPersistentState(
        statLevel: current.statLevel + 1,
        unlockedTraits: current.unlockedTraits,
      );
      return save.copyWith(
        goldCoins: save.goldCoins - cost,
        gunUpgrades: gunUpgrades,
      );
    });
    PlaytestLogger.instance.shopPurchase(
      kind: 'statUpgrade',
      id: weaponId,
      cost: cost,
      goldAfter: persistentGold,
    );
    return true;
  }

  /// Discounted gold cost to unlock [unlock], or null if its
  /// [WeaponTraitUnlock.unlockTierRequired] hasn't been reached yet.
  int? traitUnlockCost(WeaponTraitUnlock unlock) {
    final level = persistentGunState(unlock.weaponId).statLevel;
    if (level < unlock.unlockTierRequired) return null;
    return (unlock.goldCost * (1 - quizDiscount)).round();
  }

  /// Attempts to purchase [unlock]. Returns true if the purchase succeeded.
  Future<bool> purchaseTraitUnlock(WeaponTraitUnlock unlock) async {
    final cost = traitUnlockCost(unlock);
    if (cost == null || persistentGold < cost) return false;
    final already = persistentGunState(
      unlock.weaponId,
    ).unlockedTraits.contains(unlock.traitId);
    if (already) return false;

    await persistence.updateSaveData((save) {
      final gunUpgrades = Map<String, GunPersistentState>.of(save.gunUpgrades);
      final current = gunUpgrades[unlock.weaponId] ?? GunPersistentState();
      gunUpgrades[unlock.weaponId] = GunPersistentState(
        statLevel: current.statLevel,
        unlockedTraits: {...current.unlockedTraits, unlock.traitId},
      );
      return save.copyWith(
        goldCoins: save.goldCoins - cost,
        gunUpgrades: gunUpgrades,
      );
    });
    PlaytestLogger.instance.shopPurchase(
      kind: 'trait',
      id: '${unlock.weaponId}:${unlock.traitId}',
      cost: cost,
      goldAfter: persistentGold,
    );
    return true;
  }

  // ---------------------------------------------------------------------
  // Global Targeting track (weapon-independent; see
  // `data/progression/targeting_upgrade_def.dart`).
  // ---------------------------------------------------------------------

  int get targetingLevel => persistence.saveData.targetingLevel;

  bool get smartAimUnlocked => persistence.saveData.smartAimUnlocked;

  /// Resolved targeting effects (homing/fire-rate/duplicate) for the current
  /// track level.
  TargetingEffects get targetingEffects =>
      TargetingUpgradeCatalog.effectiveTargeting(targetingLevel);

  /// Discounted gold cost to buy the next Targeting tier, or null if the
  /// track is already complete.
  int? targetingUpgradeCost() {
    final tier = TargetingUpgradeCatalog.nextTier(targetingLevel);
    if (tier == null) return null;
    return (tier.cost * (1 - quizDiscount)).round();
  }

  /// Attempts to purchase the next Targeting tier. Returns true on success.
  Future<bool> purchaseTargetingUpgrade() async {
    final cost = targetingUpgradeCost();
    if (cost == null || persistentGold < cost) return false;

    await persistence.updateSaveData(
      (save) => save.copyWith(
        goldCoins: save.goldCoins - cost,
        targetingLevel: save.targetingLevel + 1,
      ),
    );
    PlaytestLogger.instance.shopPurchase(
      kind: 'targeting',
      cost: cost,
      goldAfter: persistentGold,
    );
    return true;
  }

  /// Discounted cost to unlock Smart Aim, or null if it's already unlocked or
  /// the prerequisite track level hasn't been reached.
  int? smartAimUnlockCost() {
    if (smartAimUnlocked) return null;
    if (targetingLevel < TargetingUpgradeCatalog.smartAimUnlockTier) {
      return null;
    }
    return (TargetingUpgradeCatalog.smartAimCost * (1 - quizDiscount)).round();
  }

  /// Attempts to purchase the Smart Aim unlock. Returns true on success.
  Future<bool> purchaseSmartAim() async {
    final cost = smartAimUnlockCost();
    if (cost == null || persistentGold < cost) return false;

    await persistence.updateSaveData(
      (save) => save.copyWith(
        goldCoins: save.goldCoins - cost,
        smartAimUnlocked: true,
      ),
    );
    PlaytestLogger.instance.shopPurchase(
      kind: 'smartAim',
      cost: cost,
      goldAfter: persistentGold,
    );
    return true;
  }

  /// Whether the Enemy Dictionary entry for [enemyId] has been unlocked.
  bool isEnemyUnlocked(String enemyId) =>
      persistence.saveData.unlockedEnemyEntries.contains(enemyId);

  /// Gold cost to unlock the Enemy Dictionary entry for [enemyId], or null
  /// if it has no entry in [EnemyDictionaryCatalog].
  int? enemyUnlockCost(String enemyId) =>
      EnemyDictionaryCatalog.unlockCostFor(enemyId);

  /// Attempts to purchase the Enemy Dictionary entry for [enemyId]. Returns
  /// true if the purchase succeeded.
  Future<bool> purchaseEnemyUnlock(String enemyId) async {
    if (isEnemyUnlocked(enemyId)) return false;
    final cost = enemyUnlockCost(enemyId);
    if (cost == null || persistentGold < cost) return false;

    await persistence.updateSaveData((save) {
      return save.copyWith(
        goldCoins: save.goldCoins - cost,
        unlockedEnemyEntries: {...save.unlockedEnemyEntries, enemyId},
      );
    });
    return true;
  }
}
