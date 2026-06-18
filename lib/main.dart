import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/audio_service.dart';
import 'services/persistence_service.dart';
import 'services/playtest_logger.dart';
import 'services/settings_service.dart';
import 'theme/palette.dart';
import 'theme/typography.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/loading_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Landscape-only mobile game: the HUD is laid out for landscape and breaks in
  // portrait, so lock orientation. Immersive mode hides the status/nav bars to
  // give the playfield the full screen on phones.
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(PdacApp(bootstrap: _bootstrap()));
}

Future<PersistenceService> _bootstrap() async {
  final startedAt = DateTime.now();
  final persistence = await PersistenceService.init();
  await SettingsService.init(persistence);
  await PlaytestLogger.init();
  final settings = SettingsService.instance.value;
  PlaytestLogger.instance.startSession(
    difficulty: settings.difficulty,
    aimMode: settings.aimMode,
    smartAim: settings.smartAimEnabled,
    touch: touchControlsActiveFor(settings.touchControlsMode),
    resumed: persistence.checkpoint != null,
  );
  unawaited(AudioService.instance.enable());

  // Keep the boot transition from flashing for a single frame on fast machines,
  // but keep it short so slow devices aren't held back.
  final elapsed = DateTime.now().difference(startedAt);
  const minimumBootTime = Duration(milliseconds: 400);
  if (elapsed < minimumBootTime) {
    await Future<void>.delayed(minimumBootTime - elapsed);
  }

  return persistence;
}

/// Root widget for PDAC Immune Defense.
class PdacApp extends StatelessWidget {
  const PdacApp({super.key, required this.bootstrap});

  final Future<PersistenceService> bootstrap;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDAC Immune Defense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppPalette.backgroundDeep,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.playerCore,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(bodyMedium: AppTypography.body),
        fontFamily: AppTypography.fontFamily,
      ),
      builder: (context, child) {
        // Stack the in-game Text Scale setting on top of platform large-text
        // preferences, with a ceiling that protects dense combat overlays.
        return ValueListenableBuilder<SettingsData>(
          valueListenable: SettingsService.instance,
          builder: (context, settings, _) {
            final media = MediaQuery.of(context);
            final platformScale = media.textScaler.scale(1.0);
            final effectiveScale = (platformScale * settings.textScale)
                .clamp(0.85, 2.2)
                .toDouble();
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(effectiveScale),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
      home: FutureBuilder<PersistenceService>(
        future: bootstrap,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return LoadingScreen(
              failed: true,
              errorText: 'Startup failed. Restart the game to try again.',
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingScreen();
          }
          return const HomeScreen();
        },
      ),
    );
  }
}
