import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdac_immune_defense/game/pdac_game.dart';
import 'package:pdac_immune_defense/services/persistence_service.dart';
import 'package:pdac_immune_defense/ui/overlays/gameover_overlay.dart';
import 'package:pdac_immune_defense/ui/widgets/run_summary.dart';

void main() {
  testWidgets('GameOverOverlay offers direct retry and return home actions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final persistence = await PersistenceService.init();
    final game = PdacGame(persistence: persistence);
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            GameOverOverlay(
              game: game,
              onRetry: () => retried = true,
              roundsReached: 4,
              summaryStats: const RunSummaryStats(
                kills: 42,
                goldThisRun: 17,
                quizCorrect: 2,
                quizTotal: 3,
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Defenses Overwhelmed'), findsOneWidget);
    expect(find.text('Return Home'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pump();

    expect(retried, isTrue);
  });
}
