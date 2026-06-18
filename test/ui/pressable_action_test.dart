import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pdac_immune_defense/ui/widgets/pressable_action.dart';

void main() {
  testWidgets('PressableAction exposes button semantics', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: PressableAction(
          semanticLabel: 'Start mission',
          onPressed: () {},
          builder:
              (
                context, {
                required enabled,
                required pressed,
                required focused,
                required hovered,
              }) => const Text('Start'),
        ),
      ),
    );

    final data = tester
        .getSemantics(find.bySemanticsLabel('Start mission'))
        .getSemanticsData();
    expect(data.label, 'Start mission');
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.flagsCollection.isEnabled, Tristate.isTrue);

    handle.dispose();
  });

  testWidgets('PressableAction activates with keyboard shortcuts', (
    tester,
  ) async {
    var activations = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PressableAction(
              autofocus: true,
              semanticLabel: 'Continue',
              onPressed: () => activations++,
              builder:
                  (
                    context, {
                    required enabled,
                    required pressed,
                    required focused,
                    required hovered,
                  }) => Text(focused ? 'Focused' : 'Ready'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activations, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(activations, 2);
  });

  testWidgets('PressableAction exposes selected and toggled state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: PressableAction(
          semanticLabel: 'Selected weapon: Pistol',
          semanticValue: 'Selected',
          semanticHint: 'Toggles this weapon in your loadout',
          selected: true,
          toggled: true,
          onPressed: () {},
          builder:
              (
                context, {
                required enabled,
                required pressed,
                required focused,
                required hovered,
              }) => const Text('Pistol'),
        ),
      ),
    );

    final data = tester
        .getSemantics(find.bySemanticsLabel('Selected weapon: Pistol'))
        .getSemanticsData();
    expect(data.value, 'Selected');
    expect(data.hint, 'Toggles this weapon in your loadout');
    expect(data.flagsCollection.isSelected, Tristate.isTrue);
    expect(data.flagsCollection.isToggled, Tristate.isTrue);

    handle.dispose();
  });
}
