import 'package:flutter_test/flutter_test.dart';

import 'package:pdac_immune_defense/ui/widgets/run_summary.dart';

void main() {
  test('run summary quiz label handles missing and scored quizzes', () {
    expect(runSummaryQuizLabel(correct: 0, total: 0), 'No quiz data');
    expect(runSummaryQuizLabel(correct: 3, total: 4), '3 / 4 (75%)');
    expect(runSummaryQuizLabel(correct: 9, total: 10), '9 / 10 (90%)');
  });

  test('run summary grade rewards round depth, quiz accuracy, and combat', () {
    expect(
      runSummaryGrade(
        roundsReached: 9,
        kills: 140,
        quizCorrect: 9,
        quizTotal: 9,
      ),
      'S',
    );
    expect(
      runSummaryGrade(
        roundsReached: 6,
        kills: 60,
        quizCorrect: 5,
        quizTotal: 8,
      ),
      'B',
    );
    expect(
      runSummaryGrade(roundsReached: 1, kills: 0, quizCorrect: 0, quizTotal: 0),
      'D',
    );
  });

  test('run summary takeaway points to the next useful improvement', () {
    expect(
      runSummaryTakeaway(
        victory: true,
        roundsReached: 9,
        quizCorrect: 9,
        quizTotal: 9,
      ),
      contains('Complete assay'),
    );
    expect(
      runSummaryTakeaway(
        victory: false,
        roundsReached: 2,
        quizCorrect: 0,
        quizTotal: 0,
      ),
      contains('practice dashing'),
    );
    expect(
      runSummaryTakeaway(
        victory: false,
        roundsReached: 5,
        quizCorrect: 3,
        quizTotal: 4,
      ),
      contains('buy permanent upgrades'),
    );
    expect(
      runSummaryTakeaway(
        victory: false,
        roundsReached: 8,
        quizCorrect: 2,
        quizTotal: 4,
      ),
      contains('lesson quizzes'),
    );
    expect(
      runSummaryTakeaway(
        victory: false,
        roundsReached: 8,
        quizCorrect: 4,
        quizTotal: 4,
      ),
      contains('metastatic-stage boss'),
    );
  });
}
