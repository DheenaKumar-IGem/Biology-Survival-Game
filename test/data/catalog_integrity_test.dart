import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/data/bosses/boss_catalog.dart';
import 'package:pdac_immune_defense/data/categories.dart';
import 'package:pdac_immune_defense/data/enemies/enemy_catalog.dart';
import 'package:pdac_immune_defense/data/enemies/enemy_dictionary_def.dart';
import 'package:pdac_immune_defense/data/lessons/lesson_catalog.dart';
import 'package:pdac_immune_defense/data/progression/gun_upgrade_def.dart';
import 'package:pdac_immune_defense/data/progression/persistent_shop_def.dart';
import 'package:pdac_immune_defense/data/rounds/round_catalog.dart';
import 'package:pdac_immune_defense/data/weapons/weapon_catalog.dart';
import 'package:pdac_immune_defense/services/save_data.dart';

void main() {
  test('checkpoint maxRound matches the actual number of rounds', () {
    // The checkpoint clamp and roundCompletesRun() must agree on "how many
    // rounds exist", or a resumed save could be stranded a round early/late.
    expect(CheckpointData.maxRound, RoundCatalog.all.length);
  });

  test('every round wave references a known enemy and has a sane cap', () {
    for (final round in RoundCatalog.all.values) {
      expect(round.activeMobCap, greaterThanOrEqualTo(18));
      expect(round.activeMobCap, lessThanOrEqualTo(112));
      expect(round.totalSpawnCount, greaterThan(0));

      for (final wave in round.spawnWaves) {
        expect(
          EnemyCatalog.all.containsKey(wave.enemyId),
          isTrue,
          reason: 'Round ${round.roundNumber} references ${wave.enemyId}',
        );
        expect(wave.count, greaterThan(0));
        expect(wave.burstSize, greaterThan(0));
        expect(wave.interval, greaterThan(0));
        if (wave.maxAliveGate != null) {
          expect(wave.maxAliveGate, lessThanOrEqualTo(round.activeMobCap));
        }
      }
    }
  });

  test('every enemy has a dictionary unlock and field note', () {
    for (final enemy in EnemyCatalog.all.values) {
      expect(
        EnemyDictionaryCatalog.unlockCosts.containsKey(enemy.id),
        isTrue,
        reason: '${enemy.id} is missing an unlock cost',
      );
      expect(
        EnemyDictionaryCatalog.fieldNotes.containsKey(enemy.id),
        isTrue,
        reason: '${enemy.id} is missing a field note',
      );
    }
  });

  test('enemy body colors exactly match their category colors', () {
    for (final enemy in EnemyCatalog.all.values) {
      expect(
        enemy.primaryColor,
        enemy.category.color,
        reason:
            '${enemy.id} body color should match the category color used by '
            'matching bullets and HUD chips',
      );
    }
  });

  test('weapon progression covers every weapon', () {
    for (final weapon in WeaponCatalog.all.values) {
      expect(
        GunUpgradeCatalog.all.containsKey(weapon.id),
        isTrue,
        reason: '${weapon.id} is missing a run upgrade',
      );
      expect(
        PersistentShopCatalog.statUpgrades.containsKey(weapon.id),
        isTrue,
        reason: '${weapon.id} is missing a persistent upgrade',
      );
      for (final trait in weapon.availableTraits) {
        expect(
          PersistentShopCatalog.traitUnlocksFor(
            weapon.id,
          ).any((unlock) => unlock.traitId == trait),
          isTrue,
          reason: '${weapon.id} advertises $trait but cannot unlock it',
        );
      }
    }
  });

  test('starting loadout covers all immune categories', () {
    final categories = WeaponCatalog.startingLoadout
        .map((id) => WeaponCatalog.all[id]!.category)
        .toSet();
    expect(categories, containsAll(ImmuneCategory.values));
  });

  test('bosses have attack styles and valid phase adds', () {
    for (final boss in BossCatalog.all.values) {
      expect(EnemyCatalog.all.containsValue(boss.addArchetype), isTrue);
      expect(boss.phaseAddArchetypes, isNotEmpty);
      for (final add in boss.phaseAddArchetypes) {
        expect(EnemyCatalog.all.containsValue(add), isTrue);
      }
    }
  });

  test('lesson quizzes have valid answers and explanations', () {
    for (final lesson in LessonCatalog.all.values) {
      // At least 3 questions per unit; some units add an application-level
      // question on top of the core recall trio.
      expect(lesson.questions.length, greaterThanOrEqualTo(3));
      for (final question in lesson.questions) {
        expect(question.options, hasLength(4));
        expect(question.correctIndex, inInclusiveRange(0, 3));
        expect(
          question.explanation.trim(),
          isNotEmpty,
          reason: '${lesson.id} has a question without feedback',
        );
      }
    }
  });
}
