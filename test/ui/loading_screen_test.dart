import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pdac_immune_defense/ui/screens/loading_screen.dart';

void main() {
  test('loading stage helper maps progress to protocol stages', () {
    expect(loadingStageForProgress(0).label, 'Preparing immune response');
    expect(loadingStageForProgress(0.25).label, 'Reading saliva biomarkers');
    expect(loadingStageForProgress(0.50).label, 'Mapping pancreatic signal');
    expect(loadingStageForProgress(0.75).label, 'Calibrating defenses');
    expect(loadingStageForProgress(1).label, 'Calibrating defenses');
  });

  test('loading stage helper supports launch-specific stages', () {
    expect(
      loadingStageForProgress(0, stages: tutorialLoadingStages).label,
      'Opening training arena',
    );
    expect(
      loadingStageForProgress(0.5, stages: newRunLoadingStages).label,
      'Mapping first biome',
    );
    expect(
      loadingStageForProgress(1, stages: continueRunLoadingStages).label,
      'Continuing run',
    );
  });

  test('loading progress helper keeps values bounded', () {
    expect(loadingProgressValue(-1), 0.18);
    expect(loadingProgressValue(0), 0.18);
    expect(loadingProgressValue(0.5), closeTo(0.54, 1e-9));
    expect(loadingProgressValue(1), closeTo(0.9, 1e-9));
    expect(loadingProgressValue(double.nan), 0.18);
    expect(loadingProgressValue(0.5, failed: true), 1.0);
  });

  testWidgets('loading screen renders protocol panel and telemetry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoadingScreen()));

    expect(find.text('PDAC IMMUNE DEFENSE'), findsOneWidget);
    expect(find.text('BIOMARKER PROTOCOL'), findsOneWidget);
    expect(find.text('Preparing immune response'), findsWidgets);
    expect(find.text('SALIVA ASSAY: online'), findsOneWidget);
    expect(find.text('DEFENSES: syncing'), findsOneWidget);
  });

  testWidgets('loading screen renders failed state copy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoadingScreen(failed: true, errorText: 'Startup failed.'),
      ),
    );

    expect(find.text('Startup failed.'), findsOneWidget);
    expect(find.text('Startup check interrupted'), findsOneWidget);
    expect(find.text('SALIVA ASSAY: halted'), findsOneWidget);
  });

  testWidgets('loading screen renders launch-specific protocol copy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoadingScreen(
          protocolLabel: 'TRAINING PROTOCOL',
          footerText:
              'The tutorial is opening with guided practice and safe targets.',
          stages: tutorialLoadingStages,
        ),
      ),
    );

    expect(find.text('TRAINING PROTOCOL'), findsOneWidget);
    expect(find.text('Opening training arena'), findsWidgets);
    expect(
      find.text(
        'The tutorial is opening with guided practice and safe targets.',
      ),
      findsOneWidget,
    );
  });
}
