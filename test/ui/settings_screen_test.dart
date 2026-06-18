import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdac_immune_defense/services/persistence_service.dart';
import 'package:pdac_immune_defense/services/settings_service.dart';
import 'package:pdac_immune_defense/ui/screens/settings_screen.dart';

void main() {
  test('settings display helpers produce readable labels', () {
    expect(performancePresetLabel(PerformancePreset.smooth), 'Smooth');
    expect(performancePresetLabel(PerformancePreset.balanced), 'Balanced');
    expect(performancePresetLabel(PerformancePreset.showcase), 'Showcase');

    expect(
      performancePresetDescription(PerformancePreset.smooth),
      contains('slower devices'),
    );
    expect(
      performancePresetIcon(PerformancePreset.showcase),
      Icons.auto_awesome,
    );

    expect(particleDensityLabel(ParticleDensity.off), 'Off');
    expect(particleDensityLabel(ParticleDensity.medium), 'Medium');
    expect(animationQualityLabel(AnimationQuality.high), 'High');
    expect(percentLabel(0.42), '42%');
    expect(percentLabel(2), '100%');
  });

  testWidgets('the Playtest panel renders and its toggle is wired', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final persistence = PersistenceService.forTesting(prefs: prefs);
    await SettingsService.init(persistence);
    addTearDown(() => SettingsService.instance.value = SettingsData.defaults);

    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();

    final list = find.byType(Scrollable).first;
    // Scroll the actual toggle (not just the panel title) into view so the tap
    // below lands on it regardless of how much sits above it.
    await tester.scrollUntilVisible(
      find.text('Playtest Logging'),
      120,
      scrollable: list,
    );
    await tester.pumpAndSettle();
    expect(find.text('Playtest / Research'), findsOneWidget);
    expect(find.text('Copy Playtest Data'), findsOneWidget);

    // Toggling the switch persists through SettingsService.
    expect(SettingsService.instance.value.playtestLoggingEnabled, isFalse);
    final toggle = find.descendant(
      of: find.ancestor(
        of: find.text('Playtest Logging'),
        matching: find.byType(Row),
      ),
      matching: find.byType(Switch),
    );
    await tester.tap(toggle.first);
    await tester.pumpAndSettle();
    expect(SettingsService.instance.value.playtestLoggingEnabled, isTrue);
  });
}
