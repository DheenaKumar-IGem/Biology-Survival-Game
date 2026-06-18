import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdac_immune_defense/services/persistence_service.dart';
import 'package:pdac_immune_defense/services/settings_service.dart';
import 'package:pdac_immune_defense/ui/overlays/jukebox_sheet.dart';

void main() {
  testWidgets('jukebox lists tracks and selecting one updates the setting', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final persistence = PersistenceService.forTesting(prefs: prefs);
    await SettingsService.init(persistence);
    addTearDown(() => SettingsService.instance.value = SettingsData.defaults);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showJukebox(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // The bundled tracks and the Off entry are all listed.
    expect(find.text('Serum Skyline'), findsOneWidget);
    expect(find.text('Antibody Aurora'), findsOneWidget);
    expect(find.text('Abyssal Current'), findsOneWidget);
    expect(find.text('Off (silence)'), findsOneWidget);

    // Selecting "Off" sets the track id to empty (no music).
    await tester.tap(find.text('Off (silence)'));
    await tester.pumpAndSettle();
    expect(SettingsService.instance.value.musicTrackId, '');

    // Selecting a real track persists its asset id and live-switches.
    await tester.tap(find.text('Abyssal Current'));
    await tester.pumpAndSettle();
    expect(
      SettingsService.instance.value.musicTrackId,
      'music/deep_current.wav',
    );
  });
}
