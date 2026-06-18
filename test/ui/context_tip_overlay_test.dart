import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdac_immune_defense/game/pdac_game.dart';
import 'package:pdac_immune_defense/services/persistence_service.dart';
import 'package:pdac_immune_defense/ui/overlays/context_tip_overlay.dart';

void main() {
  testWidgets('context tip overlay can be dismissed manually', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final persistence = await PersistenceService.init();
    final game = PdacGame(persistence: persistence);
    game.hud.contextTip.value = 'Match your weapon color for bonus damage.';

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(children: [ContextTipOverlay(game: game)]),
      ),
    );
    await tester.pump();

    expect(
      find.text('Match your weapon color for bonus damage.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Dismiss tip'), findsOneWidget);

    await tester.tap(find.byTooltip('Dismiss tip'));
    await tester.pumpAndSettle();

    expect(game.hud.contextTip.value, isNull);
    expect(
      find.text('Match your weapon color for bonus damage.'),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('context tip overlay advances queued tips on dismiss', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final persistence = await PersistenceService.init();
    final game = PdacGame(persistence: persistence);
    game.showContextTip('Field notes: KRAS changes cell-growth signals.');
    game.queueContextTip('Boss signal detected: localized tumor support.');

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(children: [ContextTipOverlay(game: game)]),
      ),
    );
    await tester.pump();

    expect(
      find.text('Field notes: KRAS changes cell-growth signals.'),
      findsOneWidget,
    );
    expect(
      find.text('Boss signal detected: localized tumor support.'),
      findsNothing,
    );

    await tester.tap(find.byTooltip('Dismiss tip'));
    await tester.pumpAndSettle();

    expect(
      find.text('Field notes: KRAS changes cell-growth signals.'),
      findsNothing,
    );
    expect(
      find.text('Boss signal detected: localized tumor support.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Dismiss tip'));
    await tester.pumpAndSettle();

    expect(game.hud.contextTip.value, isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
