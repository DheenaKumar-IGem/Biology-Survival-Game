import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pdac_immune_defense/theme/palette.dart';
import 'package:pdac_immune_defense/ui/widgets/stat_bar.dart';

void main() {
  test('statBarSemanticValue clamps and formats percentages', () {
    expect(statBarSemanticValue(0.734), '73 percent');
    expect(statBarSemanticValue(-1), '0 percent');
    expect(statBarSemanticValue(2), '100 percent');
  });

  testWidgets('StatBar exposes label and value to semantics', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(
        home: StatBar(
          value: 0.42,
          color: AppPalette.playerCore,
          label: 'Round progress',
        ),
      ),
    );

    final data = tester
        .getSemantics(find.bySemanticsLabel('Round progress'))
        .getSemanticsData();
    expect(data.value, '42 percent');
    expect(data.flagsCollection.isHidden, isFalse);
    expect(data.flagsCollection.isEnabled, Tristate.none);

    handle.dispose();
  });
}
