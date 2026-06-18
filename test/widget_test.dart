import 'dart:convert';

import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdac_immune_defense/game/pdac_game.dart';
import 'package:pdac_immune_defense/main.dart';
import 'package:pdac_immune_defense/services/persistence_service.dart';
import 'package:pdac_immune_defense/services/save_data.dart';
import 'package:pdac_immune_defense/services/settings_service.dart';

void main() {
  testWidgets('App boots to the home screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'tutorial_seen': true});
    final persistence = await PersistenceService.init();
    await SettingsService.init(persistence);

    await tester.pumpWidget(PdacApp(bootstrap: Future.value(persistence)));
    await tester.pump();
    await tester.pump();

    expect(find.text('PDAC IMMUNE DEFENSE'), findsOneWidget);
    expect(find.text('Start Run'), findsOneWidget);
    expect(find.text('MISSION BRIEFING'), findsOneWidget);
  });

  testWidgets('Home screen surfaces a saved run checkpoint', (
    WidgetTester tester,
  ) async {
    final save = SaveData(
      highestRoundReached: 4,
      checkpoint: CheckpointData(
        roundNumber: 3,
        playerHp: 73,
        goldThisRun: 18,
        equippedWeapons: const ['pistol', 'shotgun', 'rifle'],
      ),
    );
    SharedPreferences.setMockInitialValues({
      'tutorial_seen': true,
      'save_data_v1': jsonEncode(save.toJson()),
    });
    final persistence = await PersistenceService.init();
    await SettingsService.init(persistence);

    await tester.pumpWidget(PdacApp(bootstrap: Future.value(persistence)));
    await tester.pump();
    await tester.pump();

    expect(find.text('Continue Run'), findsOneWidget);
    expect(find.text('New Run'), findsOneWidget);
    expect(find.text('Round 3'), findsOneWidget);
    expect(find.text('Run gold'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
  });

  testWidgets(
    'Completing the tutorial clears stale resume controls from home',
    (WidgetTester tester) async {
      final save = SaveData(
        highestRoundReached: 4,
        checkpoint: CheckpointData(
          roundNumber: 3,
          playerHp: 73,
          goldThisRun: 18,
          equippedWeapons: const ['pistol', 'shotgun', 'rifle'],
        ),
      );
      SharedPreferences.setMockInitialValues({
        'disclaimer_seen': true,
        'tutorial_seen': true,
        'save_data_v1': jsonEncode(save.toJson()),
      });
      final persistence = await PersistenceService.init();
      await SettingsService.init(persistence);

      await tester.pumpWidget(PdacApp(bootstrap: Future.value(persistence)));
      await tester.pump();
      await tester.pump();

      expect(find.text('Continue Run'), findsOneWidget);

      await tester.ensureVisible(find.text('Tutorial'));
      await tester.tap(find.text('Tutorial'));
      await tester.pump();
      await tester.pump();

      final gameWidget = tester.widget<GameWidget<PdacGame>>(
        find.byWidgetPredicate((widget) => widget is GameWidget<PdacGame>),
      );
      gameWidget.game!.completeTutorial();

      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(persistence.tutorialSeen, isTrue);
      expect(persistence.checkpoint, isNull);
      expect(find.text('Start Run'), findsOneWidget);
      expect(find.text('Continue Run'), findsNothing);
      expect(find.text('New Run'), findsNothing);
    },
  );
}
