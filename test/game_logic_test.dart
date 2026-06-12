import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:square_shooter_game/game_logic.dart';
import 'package:square_shooter_game/main.dart' as app;
import 'package:square_shooter_game/survivor_logic.dart';

void main() {
  test('score calculation blends combat and learning inputs', () {
    final score = calculateRunScore(
      const RunScoreInputs(
        kills: 50,
        bossesDefeated: 3,
        roundsCleared: 8,
        quizPerfectRounds: 4,
        quizSolidRounds: 2,
        quizWeakRounds: 1,
        survivalSeconds: 180,
        masteryMode: false,
      ),
    );

    expect(score, greaterThan(0));
    expect(
      calculateRunScore(
        const RunScoreInputs(
          kills: 50,
          bossesDefeated: 3,
          roundsCleared: 8,
          quizPerfectRounds: 4,
          quizSolidRounds: 2,
          quizWeakRounds: 1,
          survivalSeconds: 180,
          masteryMode: true,
        ),
      ),
      greaterThan(score),
    );
  });

  test('quiz draft profile follows the new reward ladder', () {
    final perfect = resolveDraftProfile(3);
    final solid = resolveDraftProfile(2);
    final weak = resolveDraftProfile(1);
    final failed = resolveDraftProfile(0);

    expect(perfect.choiceCount, 3);
    expect(perfect.grantsReroll, isTrue);
    expect(solid.choiceCount, 3);
    expect(weak.pressureLevel, 1);
    expect(failed.lowerQuality, isTrue);
  });

  test('boss unlock staging expands with boss rounds seen', () {
    expect(unlockedBossPool(1), [BossType.stalkerApex]);
    expect(unlockedBossPool(2), [
      BossType.stalkerApex,
      BossType.splitterQueen,
    ]);
    expect(unlockedBossPool(4), [
      BossType.stalkerApex,
      BossType.splitterQueen,
      BossType.chargerBrute,
    ]);
  });

  test('boss picker scripts the first three gates before randomizing', () {
    final rng = math.Random(1);
    expect(
      pickBossType(rng: rng, bossRoundsSeen: 1, lastBossType: null),
      BossType.stalkerApex,
    );
    expect(
      pickBossType(
          rng: rng, bossRoundsSeen: 2, lastBossType: BossType.stalkerApex),
      BossType.splitterQueen,
    );
    expect(
      pickBossType(
          rng: rng, bossRoundsSeen: 3, lastBossType: BossType.splitterQueen),
      BossType.chargerBrute,
    );
  });

  test('boss picker avoids immediate repeats when pool has alternatives', () {
    final rng = math.Random(1);
    final picked = pickBossType(
      rng: rng,
      bossRoundsSeen: 5,
      lastBossType: BossType.chargerBrute,
    );

    expect(picked, isNot(BossType.chargerBrute));
  });

  test('post-lesson draft leans toward filling the second weapon slot first',
      () {
    final offers = buildPostLessonDraft(
      rng: math.Random(2),
      activeWeapon: WeaponType.scatter,
      activeWeaponLevel: 1,
      activeWeaponBranched: false,
      supportWeaponLevels: const {},
      branchedSupportWeapons: const <MiniWeaponType>{},
      passiveLevels: const {},
      choiceCount: 3,
      lowerQuality: false,
      evolvedSupportWeapons: const <MiniWeaponType>{},
    );

    expect(offers, hasLength(3));
    expect(offers.first.type, BuildOfferType.supportUnlock);
  });

  test('post-lesson draft prioritizes filling the second support weapon slot',
      () {
    final offers = buildPostLessonDraft(
      rng: math.Random(4),
      activeWeapon: WeaponType.scatter,
      activeWeaponLevel: 1,
      activeWeaponBranched: false,
      supportWeaponLevels: const {MiniWeaponType.sentryPod: 1},
      branchedSupportWeapons: const <MiniWeaponType>{MiniWeaponType.sentryPod},
      passiveLevels: const {},
      choiceCount: 3,
      lowerQuality: false,
      evolvedSupportWeapons: const <MiniWeaponType>{},
    );

    expect(offers, hasLength(3));
    expect(offers.first.type, BuildOfferType.supportUnlock);
    expect(
      offers.every(
        (offer) =>
            offer.type == BuildOfferType.supportUnlock ||
            offer.type == BuildOfferType.supportUpgrade,
      ),
      isTrue,
    );
  });

  test('combat level offers prioritize a second support before upgrades', () {
    final offers = buildCombatUpgradeOffers(
      rng: math.Random(10),
      activeWeapon: WeaponType.scatter,
      supportWeaponLevels: const {MiniWeaponType.sentryPod: 1},
      passiveLevels: const {},
    );

    expect(offers, hasLength(3));
    expect(
        offers
            .take(2)
            .every((offer) => offer.supportWeapon != MiniWeaponType.sentryPod),
        isTrue);
  });

  test(
      'post-lesson draft surfaces branch choices once a support weapon is ready',
      () {
    final offers = buildPostLessonDraft(
      rng: math.Random(5),
      activeWeapon: WeaponType.scatter,
      activeWeaponLevel: 1,
      activeWeaponBranched: false,
      supportWeaponLevels: const {MiniWeaponType.sentryPod: 3},
      branchedSupportWeapons: const <MiniWeaponType>{},
      passiveLevels: const {PassiveType.receptorMesh: 1},
      choiceCount: 3,
      lowerQuality: false,
      evolvedSupportWeapons: const <MiniWeaponType>{},
    );

    expect(
      offers.where((offer) => offer.type == BuildOfferType.supportBranch),
      hasLength(2),
    );
  });

  test('boss chest offers stay premium and never roll common quality', () {
    final offers = buildBossChestOffers(
      rng: math.Random(6),
      activeWeapon: WeaponType.scatter,
      activeWeaponLevel: 3,
      activeWeaponBranched: true,
      supportWeaponLevels: const {MiniWeaponType.sentryPod: 2},
      branchedSupportWeapons: const <MiniWeaponType>{MiniWeaponType.sentryPod},
      passiveLevels: const {PassiveType.sporeMatrix: 1},
      evolvedSupportWeapons: const <MiniWeaponType>{},
    );

    expect(offers, hasLength(3));
    expect(offers.every((offer) => offer.rarity != BuildRarity.common), isTrue);
  });

  test('combat upgrade offers only target owned support weapons', () {
    final offers = buildCombatUpgradeOffers(
      rng: math.Random(8),
      activeWeapon: WeaponType.scatter,
      supportWeaponLevels: const {
        MiniWeaponType.sentryPod: 2,
        MiniWeaponType.lineDrive: 1,
        MiniWeaponType.snapPrism: 1,
        MiniWeaponType.rhythmRing: 1,
      },
      passiveLevels: const {PassiveType.sporeMatrix: 1},
    );

    expect(
      offers.every((offer) => offer.kind == CombatUpgradeKind.supportAmp),
      isTrue,
    );
    expect(
      offers.every(
        (offer) => const {
          MiniWeaponType.sentryPod,
          MiniWeaponType.lineDrive,
          MiniWeaponType.snapPrism,
          MiniWeaponType.rhythmRing,
        }.contains(offer.supportWeapon),
      ),
      isTrue,
    );
  });

  test('persisted meta state round-trips checkpoint snapshots', () {
    const checkpoint = PersistedCheckpointSnapshot(
      round: 6,
      lessonCursor: 5,
      masteryMode: false,
      difficultyName: 'hard',
      credits: 90,
      kills: 120,
      lives: 2,
      totalCoinsCollected: 180,
      survivalTime: 240,
      roundsCleared: 5,
      bossesDefeated: 1,
      quizPerfectRounds: 2,
      quizSolidRounds: 1,
      quizWeakRounds: 2,
      enemyFrenzyTimer: 8,
      activeWeaponName: 'scatter',
      lockedWeaponName: 'scatter',
      upgradeLevels: {'moveSpeed': 2},
      weaponUnlocks: {'scatter': true},
      weaponSpecialLevels: {'scatter': 1},
      weaponBranchIds: {'scatter': 'shrapnel_fan'},
      miniWeaponLevels: {'sentryPod': 2},
      miniWeaponBranchIds: {'sentryPod': 'needle_nest'},
      equippedMiniWeapons: ['sentryPod'],
      passiveLevels: {'sporeMatrix': 2},
      shieldCharges: 1,
      bossRoundsSeen: 2,
      lastBossTypeName: 'splitterQueen',
      activeWeaponEvolved: true,
      evolvedMiniWeapons: ['sentryPod'],
      bankedBossSamples: 14,
      nextRoundPressureLevel: 1,
    );

    final encoded = const PersistedMetaState(
      tutorialSeen: true,
      courseCompleted: true,
      bestCourseScore: 1234,
      bestMasteryScore: 4321,
      researchPoints: 42,
      selectedCharacterName: 'lymphocyteScout',
      unlockedCharacterNames: ['bioSquare', 'lymphocyteScout'],
      biologyResourcePackEnabled: true,
      checkpoint: checkpoint,
    ).encode();

    final decoded = PersistedMetaState.fromEncoded(encoded);
    expect(decoded.tutorialSeen, isTrue);
    expect(decoded.bestCourseScore, 1234);
    expect(decoded.bestMasteryScore, 4321);
    expect(decoded.researchPoints, 42);
    expect(decoded.selectedCharacterName, 'lymphocyteScout');
    expect(decoded.unlockedCharacterNames, contains('lymphocyteScout'));
    expect(decoded.biologyResourcePackEnabled, isTrue);
    expect(decoded.checkpoint?.round, 6);
    expect(decoded.checkpoint?.equippedMiniWeapons, ['sentryPod']);
    expect(decoded.checkpoint?.passiveLevels['sporeMatrix'], 2);
    expect(decoded.checkpoint?.activeWeaponEvolved, isTrue);
    expect(decoded.checkpoint?.evolvedMiniWeapons, ['sentryPod']);
    expect(decoded.checkpoint?.bankedBossSamples, 14);
    expect(decoded.checkpoint?.difficultyName, 'hard');
  });

  test('boss rewards always grant shield now that magnet is removed', () {
    expect(bossRewardPickupForIndex(0), PickupType.shield);
    expect(bossRewardPickupForIndex(2), PickupType.shield);
    expect(bossRewardPickupForIndex(5), PickupType.shield);
  });

  test('bundled lesson fallback stays available offline', () {
    expect(app.bundledLessonSequence, isNotEmpty);
    expect(app.bundledLessonSequence.first.questions, isNotEmpty);
  });
}
