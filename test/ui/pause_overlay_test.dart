import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdac_immune_defense/game/pdac_game.dart';
import 'package:pdac_immune_defense/services/persistence_service.dart';
import 'package:pdac_immune_defense/services/settings_service.dart';
import 'package:pdac_immune_defense/ui/overlays/pause_overlay.dart';
import 'package:pdac_immune_defense/ui/screens/settings_screen.dart';

void main() {
  test('pause control guide covers core inputs', () {
    expect(pauseControlItems.map((item) => item.label), [
      'Move',
      'Touch Move',
      'Dash',
      'Swap Weapon',
    ]);
    expect(pauseControlItems.map((item) => item.detail), [
      'WASD / Arrows',
      'Joystick',
      'Space / Shift',
      'Q',
    ]);
  });

  testWidgets('PauseOverlay shows controls and opens settings', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final persistence = await PersistenceService.init();
    await SettingsService.init(persistence);
    final game = PdacGame(persistence: persistence);

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(children: [PauseOverlay(game: game)]),
      ),
    );
    await tester.pump();

    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('Controls'), findsOneWidget);
    expect(find.text('WASD / Arrows'), findsOneWidget);
    expect(find.text('Joystick'), findsOneWidget);
    expect(find.text('Space / Shift'), findsOneWidget);
    expect(find.text('Q'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Save & Quit'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
