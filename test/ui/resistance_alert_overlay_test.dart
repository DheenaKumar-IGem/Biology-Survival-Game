import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdac_immune_defense/game/components/hud_data.dart';
import 'package:pdac_immune_defense/game/pdac_game.dart';
import 'package:pdac_immune_defense/services/persistence_service.dart';
import 'package:pdac_immune_defense/ui/overlays/resistance_alert_overlay.dart';

void main() {
  testWidgets('ResistanceAlertOverlay renders warning copy cleanly', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final persistence = await PersistenceService.init();
    final game = PdacGame(persistence: persistence);
    game.hud.resistanceAlert.value = const ResistanceAlertData(
      weaponName: 'Antiviral Lance',
      tier: 1,
      share: 0.75,
      warningOnly: true,
      eventId: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(children: [ResistanceAlertOverlay(game: game)]),
      ),
    );
    await tester.pump();

    expect(find.text('WRONG TARGET'), findsOneWidget);
    expect(
      find.text('Antiviral Lance - No damage reduction yet'),
      findsOneWidget,
    );
    expect(
      find.textContaining('75% of these shots hit the wrong cell type'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
