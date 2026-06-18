import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdac_immune_defense/game/components/hud_data.dart';
import 'package:pdac_immune_defense/game/pdac_game.dart';
import 'package:pdac_immune_defense/services/persistence_service.dart';
import 'package:pdac_immune_defense/ui/overlays/round_intro_overlay.dart';

void main() {
  testWidgets('RoundIntroOverlay renders the round briefing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final persistence = await PersistenceService.init();
    final game = PdacGame(persistence: persistence);

    game.hud.roundIntro.value = const RoundIntroData(
      roundNumber: 4,
      biomeName: 'The Pancreas',
      objective: 'Push deeper toward the pancreatic source of the signal.',
      threatNames: ['Virus', 'Bacteria', 'Parasite'],
      isBossRound: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(children: [RoundIntroOverlay(game: game)]),
      ),
    );
    await tester.pump();

    expect(find.text('ROUND 4'), findsOneWidget);
    expect(find.text('The Pancreas'), findsOneWidget);
    expect(
      find.text('Push deeper toward the pancreatic source of the signal.'),
      findsOneWidget,
    );
    expect(find.text('Virus'), findsOneWidget);
    expect(find.text('Bacteria'), findsOneWidget);
    expect(find.text('Parasite'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
