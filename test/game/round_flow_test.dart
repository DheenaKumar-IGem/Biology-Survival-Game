import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/data/rounds/round_catalog.dart';
import 'package:pdac_immune_defense/game/pdac_game.dart';

/// Guards the teaching flow: boss rounds plus the KRAS/saliva caveat units use
/// full blocking lessons; other regular rounds teach via transient banners.
void main() {
  test('boss rounds plus units 5 and 8 use the blocking lesson+quiz', () {
    final blockingRounds = <int>[
      for (final entry in RoundCatalog.all.entries)
        if (roundUsesBlockingLesson(entry.value)) entry.key,
    ];
    expect(blockingRounds, [3, 5, 6, 8, 9]);
  });

  test('boss rounds are exactly 3, 6 and 9', () {
    final bossRounds = <int>[
      for (final entry in RoundCatalog.all.entries)
        if (entry.value.isBossRound) entry.key,
    ]..sort();
    expect(bossRounds, [3, 6, 9]);
  });

  test(
    'every round still carries a lesson id for its banner / full lesson',
    () {
      for (final entry in RoundCatalog.all.entries) {
        expect(
          entry.value.lessonId.trim(),
          isNotEmpty,
          reason: 'Round ${entry.key} is missing a lesson id',
        );
      }
    },
  );

  test('regular-round field notes align with their lesson titles', () {
    final round4Note = fieldNoteForLesson('lesson_round_4')!;
    expect(round4Note, contains('Unit 4: Risk Factors'));
    expect(round4Note, contains('Risk comes from patterns'));
    expect(round4Note, contains('PDAC risk'));

    final round5Note = fieldNoteForLesson('lesson_round_5')!;
    expect(round5Note, contains('Unit 5: The KRAS Gene Mutation'));
    expect(round5Note, contains('KRAS is a gene'));
    expect(round5Note, contains('mutation'));
    expect(round5Note, isNot(contains('Your body is made of trillions')));

    final round8Note = fieldNoteForLesson('lesson_round_8')!;
    expect(round8Note, contains('not an available screening test today'));
    expect(round8Note, contains('false positives'));
    expect(round8Note, contains('false negatives'));
  });

  test('only round 9 completes the run', () {
    final completingRounds = <int>[
      for (final entry in RoundCatalog.all.entries)
        if (roundCompletesRun(entry.value)) entry.key,
    ];
    expect(completingRounds, [9]);
  });

  test('final boss recap routes to final lesson instead of upgrade', () {
    expect(
      phaseAfterBossRecap(RoundCatalog.all[3]!),
      RoundPhase.gunUpgradeChoice,
    );
    expect(
      phaseAfterBossRecap(RoundCatalog.all[6]!),
      RoundPhase.gunUpgradeChoice,
    );
    expect(phaseAfterBossRecap(RoundCatalog.all[9]!), RoundPhase.lesson);
  });

  test('between-round checkpoints resume at the next safe round', () {
    expect(
      resumableCheckpointRoundForPhase(
        phase: RoundPhase.playing,
        currentRound: 4,
        clearedRound: null,
        clearedRoundCompletesRun: false,
      ),
      4,
    );
    expect(
      resumableCheckpointRoundForPhase(
        phase: RoundPhase.gunUpgradeChoice,
        currentRound: 4,
        clearedRound: 4,
        clearedRoundCompletesRun: false,
      ),
      5,
    );
    expect(
      resumableCheckpointRoundForPhase(
        phase: RoundPhase.goldShop,
        currentRound: 8,
        clearedRound: 8,
        clearedRoundCompletesRun: false,
      ),
      9,
    );
    expect(
      resumableCheckpointRoundForPhase(
        phase: RoundPhase.loadout,
        currentRound: 9,
        clearedRound: 8,
        clearedRoundCompletesRun: false,
      ),
      9,
    );
    expect(
      resumableCheckpointRoundForPhase(
        phase: RoundPhase.quiz,
        currentRound: 9,
        clearedRound: 9,
        clearedRoundCompletesRun: true,
      ),
      isNull,
    );
  });
}
