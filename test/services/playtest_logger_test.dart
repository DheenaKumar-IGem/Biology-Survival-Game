import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdac_immune_defense/services/playtest_logger.dart';
import 'package:pdac_immune_defense/services/settings_service.dart';

/// Coverage for [PlaytestLogger]'s recording, session lifecycle, storage cap,
/// and read-out, using a mock SharedPreferences and an injectable clock so it
/// runs without real time or a real backend (mirrors `audio_service_test`).
///
/// The enabled flag is read live from [SettingsService.instance], so each test
/// sets it explicitly; tearDown restores defaults so it can't leak.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  PlaytestLogger newLogger({DateTime Function()? clock}) =>
      PlaytestLogger.forTest(prefs: prefs, clock: clock);

  void setLogging(bool enabled) {
    SettingsService.instance.value = SettingsData.defaults.copyWith(
      playtestLoggingEnabled: enabled,
    );
  }

  void startSession(PlaytestLogger logger, {bool resumed = false}) {
    logger.startSession(
      difficulty: GameDifficulty.standard,
      aimMode: AimMode.auto,
      smartAim: true,
      touch: true,
      resumed: resumed,
    );
  }

  /// Every session in the logger's export, newest last.
  List<Map<String, Object?>> sessionsOf(PlaytestLogger logger) {
    final decoded = jsonDecode(logger.exportJson()) as Map;
    return (decoded['sessions'] as List)
        .map((e) => Map<String, Object?>.from(e as Map))
        .toList();
  }

  /// Events of the live (last) session matching [type].
  List<Map<String, Object?>> eventsOfType(PlaytestLogger logger, String type) {
    final sessions = sessionsOf(logger);
    if (sessions.isEmpty) return [];
    return (sessions.last['events'] as List)
        .map((e) => Map<String, Object?>.from(e as Map))
        .where((e) => e['type'] == type)
        .toList();
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    setLogging(true);
  });

  tearDown(() {
    SettingsService.instance.value = SettingsData.defaults;
  });

  test('records nothing while logging is disabled', () {
    setLogging(false);
    final logger = newLogger();
    startSession(logger);
    logger.roundStarted(
      round: 1,
      biome: 'Bloodstream',
      isBoss: false,
      equippedWeapons: const ['pistol'],
      hp: 100,
    );
    logger.playerDied(round: 1, bossActive: false, liveMobCount: 3);
    expect(logger.summary().eventCount, 0);
    expect(logger.summary().sessionCount, 0);
  });

  test('records a session header plus events when enabled', () {
    final logger = newLogger();
    startSession(logger);
    logger.roundStarted(
      round: 1,
      biome: 'Bloodstream',
      isBoss: false,
      equippedWeapons: const ['pistol'],
      hp: 100,
    );
    final summary = logger.summary();
    expect(summary.sessionCount, 1);
    expect(summary.eventCount, 2); // sessionStart + roundStart
    final start = eventsOfType(logger, 'sessionStart').single;
    expect((start['data'] as Map)['difficulty'], 'standard');
  });

  test('lazily begins a session when an event arrives without startSession', () {
    final logger = newLogger();
    // No startSession call (e.g. logging toggled on mid-play).
    logger.roundStarted(
      round: 2,
      biome: 'Pancreas',
      isBoss: false,
      equippedWeapons: const ['rifle'],
      hp: 80,
    );
    expect(logger.summary().sessionCount, 1);
    // A synthetic sessionStart is prepended so the session has a header.
    expect(eventsOfType(logger, 'sessionStart'), hasLength(1));
    expect(eventsOfType(logger, 'roundStart'), hasLength(1));
  });

  test('endSession archives the session and clears the live slot', () async {
    final logger = newLogger();
    startSession(logger);
    logger.roundStarted(
      round: 2,
      biome: 'Pancreas',
      isBoss: false,
      equippedWeapons: const ['rifle'],
      hp: 90,
    );
    logger.endSession('background');
    await logger.flushForTest();

    expect(sessionsOf(logger), hasLength(1));
    final end = eventsOfType(logger, 'sessionEnd').single;
    expect((end['data'] as Map)['reason'], 'background');

    // A relaunch (new logger over the same prefs) sees the archived session
    // and an empty live slot.
    final reloaded = newLogger();
    expect(reloaded.summary().sessionCount, 1);
    expect(eventsOfType(reloaded, 'roundStart'), hasLength(1));
  });

  test('the live session survives a relaunch before it ends', () async {
    final logger = newLogger();
    startSession(logger);
    logger.roundStarted(
      round: 1,
      biome: 'Bloodstream',
      isBoss: false,
      equippedWeapons: const ['pistol'],
      hp: 100,
    );
    await logger.flushForTest();
    final before = logger.summary().eventCount;

    final reloaded = newLogger();
    expect(reloaded.summary().eventCount, before);
    expect(reloaded.summary().sessionCount, 1);
  });

  test('weapon swaps aggregate into the round and reset each round', () {
    final logger = newLogger();
    startSession(logger);
    logger.roundStarted(
      round: 1,
      biome: 'Bloodstream',
      isBoss: false,
      equippedWeapons: const ['pistol'],
      hp: 100,
    );
    logger.noteSwap();
    logger.noteSwap();
    logger.noteSwap();
    logger.roundCleared(round: 1, hp: 70);

    logger.roundStarted(
      round: 2,
      biome: 'Bloodstream',
      isBoss: false,
      equippedWeapons: const ['pistol'],
      hp: 70,
    );
    logger.noteSwap();
    logger.roundCleared(round: 2, hp: 60);

    final clears = eventsOfType(logger, 'roundClear');
    expect(clears, hasLength(2));
    expect((clears[0]['data'] as Map)['swaps'], 3);
    expect((clears[1]['data'] as Map)['swaps'], 1);
  });

  test('resistance events count per round on the round-clear event', () {
    final logger = newLogger();
    startSession(logger);
    logger.roundStarted(
      round: 4,
      biome: 'Pancreas',
      isBoss: false,
      equippedWeapons: const ['rifle'],
      hp: 100,
    );
    logger.resistanceTriggered(
      round: 4,
      weaponId: 'rifle',
      tier: 1,
      warningOnly: true,
      wrongTargetRatio: 0.5,
    );
    logger.resistanceTriggered(
      round: 4,
      weaponId: 'rifle',
      tier: 2,
      warningOnly: false,
      wrongTargetRatio: 0.6,
    );
    logger.roundCleared(round: 4, hp: 50);
    final clear = eventsOfType(logger, 'roundClear').single;
    expect((clear['data'] as Map)['resistanceEvents'], 2);
  });

  test('summary computes furthest round, deaths and quiz accuracy', () {
    final logger = newLogger();
    startSession(logger);
    logger.roundStarted(
      round: 3,
      biome: 'Pancreas',
      isBoss: false,
      equippedWeapons: const ['rifle'],
      hp: 100,
    );
    logger.quizAnswered(round: 3, questionIndex: 0, chosenOption: 1, correct: true);
    logger.quizAnswered(round: 3, questionIndex: 1, chosenOption: 0, correct: false);
    logger.quizAnswered(round: 3, questionIndex: 2, chosenOption: 2, correct: true);
    logger.playerDied(round: 3, bossActive: false, liveMobCount: 5);

    final summary = logger.summary();
    expect(summary.furthestRound, 3);
    expect(summary.deaths, 1);
    expect(summary.quizCorrect, 2);
    expect(summary.quizTotal, 3);
    expect(summary.quizAccuracyLabel, '67%');
  });

  test('the archive keeps only the most recent 20 sessions', () async {
    for (var i = 1; i <= 22; i++) {
      final logger = newLogger();
      startSession(logger);
      logger.roundStarted(
        round: i,
        biome: 'Bloodstream',
        isBoss: false,
        equippedWeapons: const ['pistol'],
        hp: 100,
      );
      logger.endSession('background');
      await logger.flushForTest();
    }
    final logger = newLogger();
    expect(logger.summary().sessionCount, 20);
    // The two oldest (rounds 1-2) were dropped; round 22 is the newest kept.
    expect(logger.summary().furthestRound, 22);
  });

  test('clear() wipes all recorded data', () async {
    final logger = newLogger();
    startSession(logger);
    logger.roundStarted(
      round: 1,
      biome: 'Bloodstream',
      isBoss: false,
      equippedWeapons: const ['pistol'],
      hp: 100,
    );
    logger.endSession('background');
    await logger.flushForTest();
    expect(logger.summary().sessionCount, 1);

    logger.clear();
    await logger.flushForTest();
    expect(logger.summary().sessionCount, 0);
    expect(logger.summary().eventCount, 0);
  });

  test('the injected clock stamps event timestamps deterministically', () {
    var now = DateTime(2026, 6, 17, 9);
    final logger = newLogger(clock: () => now);
    startSession(logger);
    now = now.add(const Duration(seconds: 5));
    logger.roundStarted(
      round: 1,
      biome: 'Bloodstream',
      isBoss: false,
      equippedWeapons: const ['pistol'],
      hp: 100,
    );
    final startAt = DateTime.parse(
      eventsOfType(logger, 'sessionStart').single['at'] as String,
    );
    final roundAt = DateTime.parse(
      eventsOfType(logger, 'roundStart').single['at'] as String,
    );
    expect(roundAt.difference(startAt), const Duration(seconds: 5));
  });

  test('PlaytestEvent JSON round-trips', () {
    final event = PlaytestEvent(
      type: PlaytestEventType.quizAnswer,
      at: DateTime(2026, 6, 17, 9, 30, 15),
      data: const {'round': 5, 'correct': true},
    );
    final restored = PlaytestEvent.fromJson(event.toJson());
    expect(restored.type, PlaytestEventType.quizAnswer);
    expect(restored.at, event.at);
    expect(restored.data['round'], 5);
    expect(restored.data['correct'], true);
  });
}
