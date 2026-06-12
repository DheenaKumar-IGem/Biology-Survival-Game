import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:square_shooter_game/blood_defense.dart';
import 'package:square_shooter_game/game_logic.dart';
import 'package:square_shooter_game/main.dart';
import 'package:square_shooter_game/survivor_logic.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('launcher card widget shows the current app branding',
      (WidgetTester tester) async {
    final game = SquareShooterGame();
    await tester.pumpWidget(MaterialApp(home: TitleOverlay(game: game)));
    await tester.pump();

    expect(find.text('Charlotte - HS'), findsOneWidget);
    expect(find.text('Biology Game'), findsWidgets);
    expect(find.text('-Dheena Kumar'), findsOneWidget);
    expect(find.text('Blood Vessel Defense'), findsOneWidget);
    expect(find.text('Coming Soon'), findsWidgets);
    expect(find.text('Difficulty'), findsOneWidget);
    expect(find.text('Easy'), findsWidgets);
    expect(find.text('Normal'), findsWidgets);
    expect(find.text('Hard'), findsWidgets);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Restart Game'), findsOneWidget);
    expect(find.text('Tutorial'), findsOneWidget);
    expect(find.text('Detailed Tutorial'), findsOneWidget);
    expect(find.text('Character Frame'), findsOneWidget);
    expect(find.text('Research Points'), findsOneWidget);
    expect(find.text('Biology Resource Pack'), findsOneWidget);
  });

  testWidgets('biology resource pack toggle updates title setting',
      (WidgetTester tester) async {
    final game = SquareShooterGame();
    await tester.pumpWidget(MaterialApp(home: TitleOverlay(game: game)));
    await tester.pump();

    expect(game.biologyResourcePackEnabled, isFalse);
    expect(find.text('Biology Resource Pack'), findsOneWidget);

    await tester.ensureVisible(find.byType(Switch).first);
    await tester.pump();
    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    expect(game.biologyResourcePackEnabled, isTrue);
    expect(find.text('Biology Pack'), findsOneWidget);
  });

  testWidgets('blood vessel defense prototype screen renders',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BloodDefensePrototypeScreen()),
    );
    await tester.pump();

    expect(find.text('Blood Vessel Defense Prototype'), findsOneWidget);
    expect(find.text('Prototype Brief'), findsOneWidget);
    expect(find.text('Start Prototype'), findsOneWidget);
  });

  testWidgets('opening mini-weapon draft shows three offers',
      (WidgetTester tester) async {
    final game = SquareShooterGame();
    game.currentStarterMiniWeaponOffers =
        buildStarterMiniWeaponChoices(math.Random(1));

    await tester.pumpWidget(MaterialApp(home: StarterDraftOverlay(game: game)));
    await tester.pump();

    expect(find.text('Choose Your Opening Mini-Weapon'), findsOneWidget);
    expect(game.currentStarterMiniWeaponOffers, hasLength(3));
  });

  testWidgets('pause summary overlay renders', (WidgetTester tester) async {
    final game = SquareShooterGame();
    await tester.pumpWidget(MaterialApp(home: PauseOverlay(game: game)));
    await tester.pump();

    expect(find.text('Run Summary'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.textContaining('Attack source: Mini-weapons only'),
        findsOneWidget);
  });

  testWidgets('coming soon launcher card renders its action',
      (WidgetTester tester) async {
    final game = SquareShooterGame();
    await tester.pumpWidget(MaterialApp(home: TitleOverlay(game: game)));
    await tester.pump();

    expect(find.text('Coming Soon'), findsWidgets);
    expect(find.text('Coming Soon'), findsWidgets);
    expect(find.text('Learn More'), findsWidgets);
  });

  testWidgets('developer mode pause overlay shows dev tools',
      (WidgetTester tester) async {
    final game = SquareShooterGame();
    game.runMode = RunMode.developer;

    await tester.pumpWidget(MaterialApp(home: PauseOverlay(game: game)));
    await tester.pump();

    expect(find.text('Developer Tools'), findsOneWidget);
    expect(find.text('Spawn Specific Boss'), findsOneWidget);
    expect(find.text('Main Weapon Path'), findsOneWidget);
  });

  testWidgets('victory overlay renders', (WidgetTester tester) async {
    final game = SquareShooterGame();
    await tester.pumpWidget(MaterialApp(home: VictoryOverlay(game: game)));
    await tester.pump();

    expect(find.text('Course Complete'), findsWidgets);
  });

  testWidgets('developer mode starts clean', (WidgetTester tester) async {
    final game = SquareShooterGame();
    await tester.pumpWidget(SquareShooterApp(gameFactory: () => game));
    await tester.pump();
    game.startDeveloperMode();

    expect(game.currentRound, 1);
    expect(game.credits, 0);
    expect(game.isDeveloperMode, isTrue);
  });

  testWidgets('interactive tutorial starts as guided practice',
      (WidgetTester tester) async {
    final game = SquareShooterGame();
    await tester.pumpWidget(SquareShooterApp(gameFactory: () => game));
    await tester.pump();
    game.startInteractiveTutorial();
    await tester.pump();

    expect(game.isTutorialMode, isTrue);
    expect(game.equippedMiniWeapons, contains(MiniWeaponType.sentryPod));
    expect(game.overlays.isActive(InteractiveTutorialOverlay.id), isTrue);
  });

  testWidgets('interactive tutorial overlay renders guidance',
      (WidgetTester tester) async {
    final game = SquareShooterGame();
    await tester.pumpWidget(
      MaterialApp(home: InteractiveTutorialOverlay(game: game)),
    );
    await tester.pump();

    expect(find.text('Move Around'), findsOneWidget);
  });

  testWidgets('detailed tutorial overlay renders deeper guide',
      (WidgetTester tester) async {
    final game = SquareShooterGame();
    await tester.pumpWidget(MaterialApp(home: TutorialOverlay(game: game)));
    await tester.pump();

    expect(find.text('Detailed Tutorial'), findsOneWidget);
    expect(find.text('Enemy variants'), findsOneWidget);
    expect(find.text('Passives and evolutions'), findsOneWidget);
  });

  testWidgets(
      'launcher and pause widgets do not show a design interview button',
      (WidgetTester tester) async {
    final game = SquareShooterGame();
    await tester.pumpWidget(MaterialApp(home: TitleOverlay(game: game)));
    await tester.pump();

    expect(find.text('Design Interview'), findsNothing);

    await tester.pumpWidget(MaterialApp(home: PauseOverlay(game: game)));
    await tester.pump();

    expect(find.text('Design Interview'), findsNothing);
  });
}
