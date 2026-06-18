import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_service.dart';

/// Bump when the exported JSON shape changes so a reader can tell old exports
/// apart. Local-only; not a save-migration version.
const int kPlaytestSchemaVersion = 1;

/// The discrete moments worth recording for a playtest. All are rare
/// (transitions, taps, outcomes) - nothing here fires from the update/render
/// loop, so logging never costs frame time. Per-press weapon swaps are folded
/// into a count on [PlaytestEventType.roundClear] instead of logged each press.
enum PlaytestEventType {
  sessionStart,
  roundStart,
  roundClear,
  playerDied,
  victory,
  quizAnswer,
  resistance,
  loadout,
  shopPurchase,
  sessionEnd,
}

PlaytestEventType _typeFromName(String name) => PlaytestEventType.values
    .firstWhere((t) => t.name == name, orElse: () => PlaytestEventType.sessionStart);

/// One recorded moment: a [type], the wall-clock [at] it happened, and a
/// free-form [data] bag (round number, weapon id, correctness, etc.).
@immutable
class PlaytestEvent {
  const PlaytestEvent({required this.type, required this.at, this.data = const {}});

  final PlaytestEventType type;
  final DateTime at;
  final Map<String, Object?> data;

  Map<String, Object?> toJson() => {
    'type': type.name,
    'at': at.toIso8601String(),
    'data': data,
  };

  factory PlaytestEvent.fromJson(Map<String, Object?> json) => PlaytestEvent(
    type: _typeFromName(json['type'] as String? ?? 'sessionStart'),
    at: DateTime.tryParse(json['at'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    data: json['data'] is Map
        ? Map<String, Object?>.from(json['data'] as Map)
        : const {},
  );
}

/// Headline numbers shown in the Settings "Playtest" section so a tester can
/// confirm at a glance that recording is working.
@immutable
class PlaytestSummary {
  const PlaytestSummary({
    required this.sessionCount,
    required this.eventCount,
    required this.furthestRound,
    required this.deaths,
    required this.quizCorrect,
    required this.quizTotal,
  });

  final int sessionCount;
  final int eventCount;
  final int furthestRound;
  final int deaths;
  final int quizCorrect;
  final int quizTotal;

  /// Quiz accuracy as a 0-100 string, or '-' when no quiz answers exist yet.
  String get quizAccuracyLabel =>
      quizTotal == 0 ? '-' : '${(quizCorrect * 100 / quizTotal).round()}%';
}

/// Records gameplay events to on-device storage so a teacher/tester can export
/// and review what happened after a kid plays - the data that turns the
/// playtest-gated design decisions (swap-tax, difficulty curve, quiz gaps)
/// into evidence instead of debate.
///
/// Strictly local: there is no network path and the export never leaves the
/// device unless the person holding it copies it out. Recording is a no-op
/// unless [SettingsData.playtestLoggingEnabled] is on, so a shipped build
/// collects nothing by default.
///
/// Storage (SharedPreferences, reusing the app's only persistence dependency):
/// - `playtest_current_v1` holds just the live session (rewritten per event -
///   small), so per-event writes stay cheap.
/// - `playtest_archive_v1` holds the last [_maxSessions] completed sessions,
///   rewritten only when a session ends.
class PlaytestLogger {
  PlaytestLogger._(this._prefs, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const _currentKey = 'playtest_current_v1';
  static const _archiveKey = 'playtest_archive_v1';
  static const _seqKey = 'playtest_seq_v1';
  static const _maxSessions = 20;

  final SharedPreferences? _prefs;
  final DateTime Function() _clock;

  /// App-wide singleton. Eagerly an in-memory, no-storage instance so the
  /// game's hooks are always safe to call (e.g. in tests that never run
  /// bootstrap); [init] replaces it with the persistent one at startup.
  static PlaytestLogger instance = PlaytestLogger._(null);

  int _sessionId = 0;
  bool _sessionActive = false;
  DateTime? _sessionStartedAt;
  DateTime? _roundStartedAt;
  int _swapsThisRound = 0;
  int _resistanceThisRound = 0;
  List<PlaytestEvent> _currentEvents = [];
  Future<void> _writeQueue = Future<void>.value();

  bool get _enabled => SettingsService.instance.value.playtestLoggingEnabled;

  static Future<PlaytestLogger> init() async {
    final prefs = await SharedPreferences.getInstance();
    instance = PlaytestLogger._(prefs).._restoreCurrent();
    return instance;
  }

  /// Fresh instance backed by a mock [prefs] and an injectable [clock], so the
  /// recording/lifecycle logic can be exercised deterministically without real
  /// time or storage. Mirrors `AudioService.forTest()`.
  @visibleForTesting
  factory PlaytestLogger.forTest({
    required SharedPreferences prefs,
    DateTime Function()? clock,
  }) {
    final logger = PlaytestLogger._(prefs, clock: clock).._restoreCurrent();
    instance = logger;
    return logger;
  }

  // --- Session lifecycle -----------------------------------------------------

  /// Begins an app-launch session, tagging it with the settings that matter for
  /// analysis. Called once at bootstrap; safe to skip when logging is off.
  void startSession({
    required GameDifficulty difficulty,
    required AimMode aimMode,
    required bool smartAim,
    required bool touch,
    required bool resumed,
  }) {
    if (!_enabled) return;
    _beginSession({
      'difficulty': difficulty.name,
      'aimMode': aimMode.name,
      'smartAim': smartAim,
      'touch': touch,
      'resumed': resumed,
    });
  }

  /// Closes the active session (called when the app is backgrounded/closed) and
  /// folds it into the archive. No-op if no session is open.
  void endSession(String reason) {
    if (!_sessionActive) return;
    _append(PlaytestEventType.sessionEnd, {
      'reason': reason,
      'durationSec': _secondsSince(_sessionStartedAt),
      'runs': _currentEvents
          .where((e) =>
              e.type == PlaytestEventType.playerDied ||
              e.type == PlaytestEventType.victory)
          .length,
    });
    _archiveCurrent();
  }

  // --- Event hooks (one call per existing call site) -------------------------

  void roundStarted({
    required int round,
    required String biome,
    required bool isBoss,
    required List<String> equippedWeapons,
    required double hp,
  }) {
    if (!_enabled) return;
    _ensureSession();
    _roundStartedAt = _clock();
    _swapsThisRound = 0;
    _resistanceThisRound = 0;
    _append(PlaytestEventType.roundStart, {
      'round': round,
      'biome': biome,
      'isBoss': isBoss,
      'equipped': equippedWeapons,
      'hp': _round1(hp),
    });
  }

  void roundCleared({required int round, required double hp}) {
    if (!_enabled) return;
    _ensureSession();
    _append(PlaytestEventType.roundClear, {
      'round': round,
      'durationSec': _secondsSince(_roundStartedAt),
      'hp': _round1(hp),
      'swaps': _swapsThisRound,
      'resistanceEvents': _resistanceThisRound,
    });
    _roundStartedAt = null;
  }

  void playerDied({
    required int round,
    required bool bossActive,
    required int liveMobCount,
  }) {
    if (!_enabled) return;
    _ensureSession();
    _append(PlaytestEventType.playerDied, {
      'round': round,
      'durationIntoRoundSec': _secondsSince(_roundStartedAt),
      'bossActive': bossActive,
      'liveMobCount': liveMobCount,
    });
  }

  void victory({required int finalRound}) {
    if (!_enabled) return;
    _ensureSession();
    _append(PlaytestEventType.victory, {'finalRound': finalRound});
  }

  void quizAnswered({
    required int round,
    required int questionIndex,
    required int chosenOption,
    required bool correct,
  }) {
    if (!_enabled) return;
    _ensureSession();
    _append(PlaytestEventType.quizAnswer, {
      'round': round,
      'questionIndex': questionIndex,
      'chosenOption': chosenOption,
      'correct': correct,
    });
  }

  void resistanceTriggered({
    required int round,
    required String weaponId,
    required int tier,
    required bool warningOnly,
    required double wrongTargetRatio,
  }) {
    if (!_enabled) return;
    _ensureSession();
    _resistanceThisRound++;
    _append(PlaytestEventType.resistance, {
      'round': round,
      'weaponId': weaponId,
      'tier': tier,
      'warningOnly': warningOnly,
      'wrongTargetRatio': _round1(wrongTargetRatio),
    });
  }

  void loadoutChosen({required int round, required List<String> equippedWeapons}) {
    if (!_enabled) return;
    _ensureSession();
    _append(PlaytestEventType.loadout, {
      'round': round,
      'equipped': equippedWeapons,
    });
  }

  void shopPurchase({
    required String kind,
    String? id,
    required int cost,
    required int goldAfter,
  }) {
    if (!_enabled) return;
    _ensureSession();
    _append(PlaytestEventType.shopPurchase, {
      'kind': kind,
      'id': ?id,
      'cost': cost,
      'goldAfter': goldAfter,
    });
  }

  /// Player-initiated weapon swap. Aggregated into the per-round count rather
  /// than logged per press, so the hot input path stays free.
  void noteSwap() {
    if (!_enabled) return;
    _swapsThisRound++;
  }

  // --- Export / read-out -----------------------------------------------------

  /// Pretty-printed JSON of every recorded session (archive + the live one),
  /// suitable for copying to the clipboard and pasting into a file.
  String exportJson() {
    final sessions = _allSessions();
    return const JsonEncoder.withIndent('  ').convert({
      'schema': kPlaytestSchemaVersion,
      'exportedAt': _clock().toIso8601String(),
      'sessionCount': sessions.length,
      'sessions': sessions,
    });
  }

  /// Headline counts for the Settings UI.
  PlaytestSummary summary() {
    var events = 0, furthest = 0, deaths = 0, quizCorrect = 0, quizTotal = 0;
    final sessions = _allSessions();
    for (final session in sessions) {
      final rawEvents = session['events'];
      if (rawEvents is! List) continue;
      for (final raw in rawEvents) {
        if (raw is! Map) continue;
        events++;
        final type = raw['type'];
        final data = raw['data'] is Map ? raw['data'] as Map : const {};
        final round = data['round'];
        if (round is int && round > furthest) furthest = round;
        if (type == 'playerDied') deaths++;
        if (type == 'quizAnswer') {
          quizTotal++;
          if (data['correct'] == true) quizCorrect++;
        }
      }
    }
    return PlaytestSummary(
      sessionCount: sessions.length,
      eventCount: events,
      furthestRound: furthest,
      deaths: deaths,
      quizCorrect: quizCorrect,
      quizTotal: quizTotal,
    );
  }

  /// Wipes all recorded playtest data from this device.
  void clear() {
    _currentEvents = [];
    _sessionActive = false;
    _roundStartedAt = null;
    _sessionStartedAt = null;
    _enqueue(() async {
      await _prefs?.remove(_currentKey);
      await _prefs?.remove(_archiveKey);
    });
  }

  // --- Internals -------------------------------------------------------------

  void _ensureSession() {
    if (_sessionActive) return;
    // Logging was enabled mid-session (no bootstrap startSession): begin one
    // from the current settings so events aren't dropped.
    final settings = SettingsService.instance.value;
    _beginSession({
      'difficulty': settings.difficulty.name,
      'aimMode': settings.aimMode.name,
      'smartAim': settings.smartAimEnabled,
      'touch': touchControlsActiveFor(settings.touchControlsMode),
      'resumed': false,
      'lazyStart': true,
    });
  }

  void _beginSession(Map<String, Object?> meta) {
    // Don't merge a leftover/previous session into this one.
    if (_currentEvents.isNotEmpty) _archiveCurrent();
    _sessionId = _nextSessionId();
    _sessionStartedAt = _clock();
    _roundStartedAt = null;
    _swapsThisRound = 0;
    _resistanceThisRound = 0;
    _sessionActive = true;
    _currentEvents = [
      PlaytestEvent(
        type: PlaytestEventType.sessionStart,
        at: _sessionStartedAt!,
        data: {'schema': kPlaytestSchemaVersion, ...meta},
      ),
    ];
    _persistCurrent();
  }

  void _append(PlaytestEventType type, Map<String, Object?> data) {
    _currentEvents.add(PlaytestEvent(type: type, at: _clock(), data: data));
    _persistCurrent();
  }

  void _restoreCurrent() {
    final raw = _prefs?.getString(_currentKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      _sessionId = decoded['id'] is int ? decoded['id'] as int : 0;
      final events = decoded['events'];
      if (events is List) {
        _currentEvents = events
            .whereType<Map>()
            .map((e) => PlaytestEvent.fromJson(Map<String, Object?>.from(e)))
            .toList();
        _sessionActive = _currentEvents.isNotEmpty;
      }
    } catch (e, st) {
      debugPrint('Playtest: failed to restore current session: $e\n$st');
      _enqueue(() async {
        await _prefs?.remove(_currentKey);
      });
    }
  }

  /// Snapshot of the live session in its persisted shape.
  Map<String, Object?> _currentToJson() => {
    'id': _sessionId,
    'events': _currentEvents.map((e) => e.toJson()).toList(),
  };

  List<Map<String, Object?>> _readArchive() {
    final raw = _prefs?.getString(_archiveKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, Object?>.from(e))
            .toList();
      }
    } catch (e, st) {
      debugPrint('Playtest: failed to read archive: $e\n$st');
    }
    return [];
  }

  List<Map<String, Object?>> _allSessions() {
    final sessions = _readArchive();
    if (_currentEvents.isNotEmpty) sessions.add(_currentToJson());
    return sessions;
  }

  /// Moves the live session into the capped archive and clears the live slot.
  /// The in-memory reset happens immediately; the disk writes are queued.
  void _archiveCurrent() {
    if (_currentEvents.isEmpty) return;
    final sessionJson = _currentToJson();
    _currentEvents = [];
    _sessionActive = false;
    _enqueue(() async {
      final archive = _readArchive()..add(sessionJson);
      while (archive.length > _maxSessions) {
        archive.removeAt(0);
      }
      await _prefs?.setString(_archiveKey, jsonEncode(archive));
      await _prefs?.remove(_currentKey);
    });
  }

  void _persistCurrent() {
    final snapshot = _currentToJson();
    _enqueue(() async {
      await _prefs?.setString(_currentKey, jsonEncode(snapshot));
    });
  }

  int _nextSessionId() {
    final next = (_prefs?.getInt(_seqKey) ?? 0) + 1;
    _enqueue(() async {
      await _prefs?.setInt(_seqKey, next);
    });
    return next;
  }

  /// Serializes all storage writes so out-of-order completion can't overwrite
  /// newer data with an older snapshot, and swallows write failures (a playtest
  /// log must never crash the game).
  void _enqueue(Future<void> Function() write) {
    _writeQueue = _writeQueue.then((_) async {
      try {
        await write();
      } catch (e, st) {
        debugPrint('Playtest: storage write failed: $e\n$st');
      }
    });
  }

  double? _secondsSince(DateTime? from) => from == null
      ? null
      : (_clock().difference(from).inMilliseconds / 1000.0 * 10).round() / 10;

  double _round1(double v) => (v * 10).round() / 10;

  /// Awaits all queued storage writes - test-only, so assertions can read back
  /// what was persisted.
  @visibleForTesting
  Future<void> flushForTest() => _writeQueue;
}
