import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'save_data.dart';

/// Wraps [SharedPreferences] with typed access to [SaveData] and the
/// fast-path "has the player seen the tutorial" flag.
///
/// Keys:
/// - `'tutorial_seen'` -> bool, checked on every app launch before the
///   rest of [SaveData] is needed.
/// - `'save_data_v1'` -> JSON-encoded [SaveData] (gold, gun upgrades,
///   progress, settings, checkpoint).
class PersistenceService {
  PersistenceService._(
    SharedPreferences prefs,
    this._saveData, {
    Future<void> Function(String rawJson)? writeSaveDataJson,
  }) : _prefs = prefs,
       _writeSaveDataJson =
           writeSaveDataJson ??
           ((rawJson) async {
             await prefs.setString(_saveDataKey, rawJson);
           });

  static const _tutorialSeenKey = 'tutorial_seen';
  static const _disclaimerSeenKey = 'disclaimer_seen';
  static const _saveDataKey = 'save_data_v1';
  static const _saveDataBackupKey = 'save_data_v1_backup';

  final SharedPreferences _prefs;
  final Future<void> Function(String rawJson) _writeSaveDataJson;
  SaveData _saveData;
  Future<void> _saveWriteQueue = Future<void>.value();

  /// False once a canonical save write has failed (e.g. storage full / denied),
  /// so the UI can warn the player that progress may not be persisting instead
  /// of letting spent gold silently revert next launch. Flips back to true on
  /// the next successful write.
  final ValueNotifier<bool> writeHealthy = ValueNotifier(true);

  /// App-wide singleton, set by [init] during startup.
  static late PersistenceService instance;

  @visibleForTesting
  factory PersistenceService.forTesting({
    required SharedPreferences prefs,
    SaveData? initialData,
    Future<void> Function(String rawJson)? writeSaveDataJson,
  }) {
    final service = PersistenceService._(
      prefs,
      initialData ?? SaveData.defaults(),
      writeSaveDataJson: writeSaveDataJson,
    );
    instance = service;
    return service;
  }

  static Future<PersistenceService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_saveDataKey);
    final backupRaw = prefs.getString(_saveDataBackupKey);
    SaveData data = SaveData.defaults();
    String? lastGoodRaw;

    if (raw != null) {
      final loaded = _tryDecodeSave(raw, source: 'primary');
      if (loaded != null) {
        data = loaded;
        lastGoodRaw = raw;
      }
    }

    if (lastGoodRaw == null && backupRaw != null) {
      final loaded = _tryDecodeSave(backupRaw, source: 'backup');
      if (loaded != null) {
        data = loaded;
        lastGoodRaw = backupRaw;
      }
    }

    if (lastGoodRaw != null && lastGoodRaw != backupRaw) {
      try {
        await prefs.setString(_saveDataBackupKey, lastGoodRaw);
      } catch (e, st) {
        debugPrint('Failed to refresh save backup: $e\n$st');
      }
    }

    instance = PersistenceService._(prefs, data);
    return instance;
  }

  static SaveData? _tryDecodeSave(String raw, {required String source}) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw const FormatException('Save root is not a JSON object.');
      }
      return SaveData.fromJson(Map<String, dynamic>.from(decoded));
    } catch (e) {
      debugPrint('Failed to load $source save data; using fallback: $e');
      return null;
    }
  }

  bool get tutorialSeen => _prefs.getBool(_tutorialSeenKey) ?? false;

  Future<void> setTutorialSeen(bool value) async {
    try {
      await _prefs.setBool(_tutorialSeenKey, value);
    } catch (e, st) {
      debugPrint('Failed to persist tutorial-seen flag: $e\n$st');
    }
  }

  /// Whether the one-time first-run intro (disclaimer + quick accessibility
  /// setup) has been shown.
  bool get disclaimerSeen => _prefs.getBool(_disclaimerSeenKey) ?? false;

  Future<void> setDisclaimerSeen(bool value) async {
    try {
      await _prefs.setBool(_disclaimerSeenKey, value);
    } catch (e, st) {
      debugPrint('Failed to persist disclaimer-seen flag: $e\n$st');
    }
  }

  SaveData get saveData => _saveData;

  /// Increments the in-memory gold WITHOUT a disk write, by replacing
  /// [_saveData] with a fresh copy (never mutating the existing object in
  /// place). Coin pickups call this every frame; the value is flushed to disk
  /// later via a batched checkpoint/save. Atomic replacement keeps the save
  /// write queue's prior-state backup honest.
  void addLocalGold(int amount) {
    if (amount <= 0) return;
    _saveData = _saveData.copyWith(goldCoins: _saveData.goldCoins + amount);
  }

  Future<void> saveSaveData(SaveData data) async {
    await _enqueueSaveWrite((_) => data);
  }

  /// Convenience for read-modify-write updates to [saveData].
  Future<void> updateSaveData(
    SaveData Function(SaveData current) updater,
  ) async {
    await _enqueueSaveWrite(updater);
  }

  Future<void> _enqueueSaveWrite(SaveData Function(SaveData current) updater) {
    final operation = _saveWriteQueue.then((_) async {
      final current = _saveData;
      final next = updater(_saveData);
      final nextJson = jsonEncode(next.toJson());
      _saveData = next;
      await _writeSaveBackup(current);
      try {
        await _writeSaveDataJson(nextJson);
        await _writeSaveBackup(next);
        writeHealthy.value = true;
      } catch (e, st) {
        writeHealthy.value = false;
        debugPrint('Failed to persist save data: $e\n$st');
      }
    });

    _saveWriteQueue = operation.catchError((Object e, StackTrace st) {
      debugPrint('Failed to update save data: $e\n$st');
    });
    return operation;
  }

  Future<void> _writeSaveBackup(SaveData data) async {
    try {
      await _prefs.setString(_saveDataBackupKey, jsonEncode(data.toJson()));
    } catch (e, st) {
      debugPrint('Failed to persist save backup: $e\n$st');
    }
  }

  CheckpointData? get checkpoint => _saveData.checkpoint;

  Future<void> saveCheckpoint(CheckpointData checkpoint) async {
    await updateSaveData((save) => save.copyWith(checkpoint: checkpoint));
  }

  Future<void> clearCheckpoint() async {
    await updateSaveData((save) => save.copyWith(clearCheckpoint: true));
  }
}
