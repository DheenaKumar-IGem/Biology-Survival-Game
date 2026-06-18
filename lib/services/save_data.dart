import '../data/weapons/weapon_catalog.dart';
import '../data/weapons/weapon_traits.dart';
import 'settings_service.dart';

Map<String, dynamic> _stringMap(Object? value) {
  if (value is! Map) return <String, dynamic>{};
  return {
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: entry.value,
  };
}

List<Object?> _objectList(Object? value) {
  if (value is List) return value;
  return const <Object?>[];
}

int _intInRange(
  Object? value, {
  required int fallback,
  required int min,
  required int max,
}) {
  final number = switch (value) {
    num() => value.toInt(),
    String() => int.tryParse(value),
    _ => null,
  };
  return (number ?? fallback).clamp(min, max).toInt();
}

double _doubleInRange(
  Object? value, {
  required double fallback,
  required double min,
  required double max,
}) {
  final number = switch (value) {
    num() => value.toDouble(),
    String() => double.tryParse(value),
    _ => null,
  };
  return (number ?? fallback).clamp(min, max).toDouble();
}

bool _boolValue(Object? value, {required bool fallback}) {
  return value is bool ? value : fallback;
}

/// Persistent (cross-session) progression state for a single weapon:
/// its persistent stat upgrade level and any traits unlocked via the gold
/// shop. See `data/progression/persistent_shop_def.dart`.
class GunPersistentState {
  GunPersistentState({this.statLevel = 0, Set<WeaponTraitId>? unlockedTraits})
    : unlockedTraits = unlockedTraits ?? <WeaponTraitId>{};

  int statLevel;
  Set<WeaponTraitId> unlockedTraits;

  Map<String, dynamic> toJson() => {
    'statLevel': statLevel,
    'unlockedTraits': unlockedTraits.map((t) => t.name).toList(),
  };

  factory GunPersistentState.fromJson(Map<String, dynamic> json) {
    return GunPersistentState(
      statLevel: _intInRange(json['statLevel'], fallback: 0, min: 0, max: 999),
      unlockedTraits: _objectList(json['unlockedTraits'])
          .whereType<String>()
          .map(
            (name) => WeaponTraitId.values.firstWhere(
              (t) => t.name == name,
              orElse: () => WeaponTraitId.explodingRounds,
            ),
          )
          .toSet(),
    );
  }
}

/// Minimal in-run resume state, written at round-end transitions and
/// cleared on victory/game over. Mirrors V13's checkpoint system.
class CheckpointData {
  CheckpointData({
    required this.roundNumber,
    required this.playerHp,
    required this.goldThisRun,
    List<String>? equippedWeapons,
    Map<String, int>? runUpgradeCounts,
    this.equippedWeaponIndex = 0,
    this.totalQuizCorrect = 0,
    this.totalQuizQuestions = 0,
  }) : equippedWeapons = equippedWeapons ?? const <String>[],
       runUpgradeCounts = runUpgradeCounts ?? const <String, int>{};

  static const int maxRound = 9;

  final int roundNumber;
  final double playerHp;
  final int goldThisRun;

  /// The 3 weapons equipped for the in-progress round (the player's loadout),
  /// so a resumed run keeps the same loadout. (v1 saves stored this under the
  /// legacy `ownedWeapons` key; [fromJson] still reads it.)
  final List<String> equippedWeapons;
  final Map<String, int> runUpgradeCounts;
  final int equippedWeaponIndex;
  final int totalQuizCorrect;
  final int totalQuizQuestions;

  Map<String, dynamic> toJson() => {
    'roundNumber': roundNumber,
    'playerHp': playerHp,
    'goldThisRun': goldThisRun,
    'equippedWeapons': equippedWeapons,
    'runUpgradeCounts': runUpgradeCounts,
    'equippedWeaponIndex': equippedWeaponIndex,
    'totalQuizCorrect': totalQuizCorrect,
    'totalQuizQuestions': totalQuizQuestions,
  };

  factory CheckpointData.fromJson(Map<String, dynamic> json) {
    final runUpgradeJson = _stringMap(json['runUpgradeCounts']);
    return CheckpointData(
      roundNumber: _intInRange(
        json['roundNumber'],
        fallback: 1,
        min: 1,
        max: maxRound,
      ),
      playerHp: _doubleInRange(
        json['playerHp'],
        fallback: 100,
        min: 0,
        max: 9999,
      ),
      goldThisRun: _intInRange(
        json['goldThisRun'],
        fallback: 0,
        min: 0,
        max: 999999999,
      ),
      // Prefer the v2 key, falling back to v1's `ownedWeapons`.
      equippedWeapons: _objectList(
        json['equippedWeapons'] ?? json['ownedWeapons'],
      ).whereType<String>().toList(),
      // Clamp to a realistic per-run ceiling (a 9-round run picks at most ~8)
      // so a corrupted/edited save can't inject a huge additive stat stack.
      runUpgradeCounts: runUpgradeJson.map(
        (key, value) =>
            MapEntry(key, _intInRange(value, fallback: 0, min: 0, max: 16)),
      ),
      equippedWeaponIndex: _intInRange(
        json['equippedWeaponIndex'],
        fallback: 0,
        min: 0,
        max: 999,
      ),
      totalQuizCorrect: _intInRange(
        json['totalQuizCorrect'],
        fallback: 0,
        min: 0,
        max: 9999,
      ),
      totalQuizQuestions: _intInRange(
        json['totalQuizQuestions'],
        fallback: 0,
        min: 0,
        max: 9999,
      ),
    );
  }
}

/// Top-level persisted save shape, stored as a single JSON blob.
class SaveData {
  SaveData({
    this.goldCoins = 0,
    Map<String, GunPersistentState>? gunUpgrades,
    this.highestRoundReached = 0,
    this.totalRunsCompleted = 0,
    this.settings = SettingsData.defaults,
    this.checkpoint,
    Set<String>? unlockedEnemyEntries,
    this.targetingLevel = 0,
    this.smartAimUnlocked = false,
    List<String>? ownedWeapons,
  }) : gunUpgrades = gunUpgrades ?? <String, GunPersistentState>{},
       unlockedEnemyEntries = unlockedEnemyEntries ?? <String>{},
       // A missing or empty list falls back to the base trio so the player is
       // never left owning no weapons.
       ownedWeapons = (ownedWeapons == null || ownedWeapons.isEmpty)
           ? List.of(WeaponCatalog.startingLoadout)
           : ownedWeapons;

  /// Schema version, for future migrations. v2 added the global Targeting
  /// track ([targetingLevel]/[smartAimUnlocked]) and persistent weapon
  /// ownership semantics; older saves simply lack the keys and fall back to
  /// the defaults in [fromJson].
  static const int version = 2;

  /// Long-term currency, spent in the persistent gold shop. Immutable: all
  /// updates go through [SaveData.copyWith] so the persistence write queue's
  /// "prior-state" backup is always a true snapshot, never a shared object that
  /// was mutated out from under it.
  final int goldCoins;

  /// Per-weapon persistent upgrade state, keyed by weapon id.
  Map<String, GunPersistentState> gunUpgrades;

  int highestRoundReached;
  int totalRunsCompleted;
  SettingsData settings;

  /// Global "Targeting" upgrade track level (0..TargetingUpgradeCatalog.maxLevel).
  /// Applies to every weapon. See `data/progression/targeting_upgrade_def.dart`.
  int targetingLevel;

  /// Whether the Smart Aim targeting mode has been purchased. Whether it's
  /// *active* is a separate runtime toggle in [SettingsData.smartAimEnabled].
  bool smartAimUnlocked;

  /// Null when there's no run to resume.
  CheckpointData? checkpoint;

  /// Ids of `EnemyCatalog` entries the player has unlocked in the Enemy
  /// Dictionary by spending gold. See `data/enemies/enemy_dictionary_def.dart`.
  Set<String> unlockedEnemyEntries;

  /// Weapons the player owns (persistent). Seeded with
  /// [WeaponCatalog.startingLoadout]; grows as weapons are bought in the gold
  /// shop. The per-round equipped trio is chosen from this pool.
  List<String> ownedWeapons;

  GunPersistentState gunState(String weaponId) =>
      gunUpgrades.putIfAbsent(weaponId, () => GunPersistentState());

  SaveData copyWith({
    int? goldCoins,
    Map<String, GunPersistentState>? gunUpgrades,
    int? highestRoundReached,
    int? totalRunsCompleted,
    SettingsData? settings,
    CheckpointData? checkpoint,
    bool clearCheckpoint = false,
    Set<String>? unlockedEnemyEntries,
    int? targetingLevel,
    bool? smartAimUnlocked,
    List<String>? ownedWeapons,
  }) {
    return SaveData(
      goldCoins: goldCoins ?? this.goldCoins,
      gunUpgrades: gunUpgrades ?? this.gunUpgrades,
      highestRoundReached: highestRoundReached ?? this.highestRoundReached,
      totalRunsCompleted: totalRunsCompleted ?? this.totalRunsCompleted,
      settings: settings ?? this.settings,
      checkpoint: clearCheckpoint ? null : (checkpoint ?? this.checkpoint),
      unlockedEnemyEntries: unlockedEnemyEntries ?? this.unlockedEnemyEntries,
      targetingLevel: targetingLevel ?? this.targetingLevel,
      smartAimUnlocked: smartAimUnlocked ?? this.smartAimUnlocked,
      ownedWeapons: ownedWeapons ?? this.ownedWeapons,
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'goldCoins': goldCoins,
    'gunUpgrades': gunUpgrades.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
    'highestRoundReached': highestRoundReached,
    'totalRunsCompleted': totalRunsCompleted,
    'settings': settings.toJson(),
    'checkpoint': checkpoint?.toJson(),
    'unlockedEnemyEntries': unlockedEnemyEntries.toList(),
    'targetingLevel': targetingLevel,
    'smartAimUnlocked': smartAimUnlocked,
    'ownedWeapons': ownedWeapons,
  };

  factory SaveData.fromJson(Map<String, dynamic> json) {
    final gunUpgradesJson = _stringMap(json['gunUpgrades']);
    final settingsJson = _stringMap(json['settings']);
    final checkpointJson = _stringMap(json['checkpoint']);
    return SaveData(
      goldCoins: _intInRange(
        json['goldCoins'],
        fallback: 0,
        min: 0,
        max: 999999999,
      ),
      gunUpgrades: gunUpgradesJson.map(
        (key, value) =>
            MapEntry(key, GunPersistentState.fromJson(_stringMap(value))),
      ),
      highestRoundReached: _intInRange(
        json['highestRoundReached'],
        fallback: 0,
        min: 0,
        max: 999,
      ),
      totalRunsCompleted: _intInRange(
        json['totalRunsCompleted'],
        fallback: 0,
        min: 0,
        max: 999999999,
      ),
      settings: settingsJson.isNotEmpty
          ? SettingsData.fromJson(settingsJson)
          : SettingsData.defaults,
      checkpoint: checkpointJson.isNotEmpty
          ? CheckpointData.fromJson(checkpointJson)
          : null,
      unlockedEnemyEntries: _objectList(
        json['unlockedEnemyEntries'],
      ).whereType<String>().toSet(),
      // v2 fields - absent in v1 saves, so they default cleanly.
      targetingLevel: _intInRange(
        json['targetingLevel'],
        fallback: 0,
        min: 0,
        max: 99,
      ),
      smartAimUnlocked: _boolValue(json['smartAimUnlocked'], fallback: false),
      // v1 saves lack persistent weapon ownership; default to the base trio.
      ownedWeapons: _objectList(
        json['ownedWeapons'],
      ).whereType<String>().toList(),
    );
  }

  factory SaveData.defaults() => SaveData();
}
