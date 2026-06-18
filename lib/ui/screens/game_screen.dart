import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../game/pdac_game.dart';
import '../../services/audio_service.dart';
import '../../services/persistence_service.dart';
import '../../services/save_data.dart';
import '../../services/settings_service.dart';
import '../overlays/boss_recap_overlay.dart';
import '../overlays/context_tip_overlay.dart';
import '../overlays/gameover_overlay.dart';
import '../overlays/gold_shop_overlay.dart';
import '../overlays/hud_overlay.dart';
import '../overlays/lesson_overlay.dart';
import '../overlays/loadout_overlay.dart';
import '../overlays/pause_overlay.dart';
import '../overlays/quiz_overlay.dart';
import '../overlays/resistance_alert_overlay.dart';
import '../overlays/round_end_upgrade_overlay.dart';
import '../overlays/round_intro_overlay.dart';
import '../overlays/victory_overlay.dart';

/// Hosts the [PdacGame] [GameWidget] plus all gameplay overlays.
///
/// [PdacGame.phase] drives which round-loop overlay is shown; the HUD and
/// context-tip banner are always present, and 'pause' is toggled
/// independently via [PdacGame.togglePause].
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.persistence,
    this.checkpoint,
    this.tutorial = false,
  });

  final PersistenceService persistence;
  final CheckpointData? checkpoint;

  /// When true, hosts the interactive training arena instead of a real run.
  final bool tutorial;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

const _phaseOverlayNames = <RoundPhase, String>{
  RoundPhase.bossRecap: 'bossRecap',
  RoundPhase.gunUpgradeChoice: 'roundEndUpgrade',
  RoundPhase.lesson: 'lesson',
  RoundPhase.quiz: 'quiz',
  RoundPhase.goldShop: 'goldShop',
  RoundPhase.loadout: 'loadout',
  RoundPhase.victory: 'victory',
  RoundPhase.gameOver: 'gameOver',
};

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final PdacGame _game;

  @override
  void initState() {
    super.initState();
    _game = PdacGame(
      persistence: widget.persistence,
      checkpoint: widget.checkpoint,
      tutorial: widget.tutorial,
    );
    _game.phase.addListener(_onPhaseChanged);
    _game.tutorialComplete.addListener(_onTutorialComplete);
    WidgetsBinding.instance.addObserver(this);
  }

  void _onTutorialComplete() {
    if (!_game.tutorialComplete.value) return;
    unawaited(_finishTutorial());
  }

  Future<void> _finishTutorial() async {
    await widget.persistence.setTutorialSeen(true);
    await widget.persistence.clearCheckpoint();
    if (!mounted) return;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
  }

  void _onPhaseChanged() {
    for (final name in _phaseOverlayNames.values) {
      _game.overlays.remove(name);
    }
    final name = _phaseOverlayNames[_game.phase.value];
    if (name != null) _game.overlays.add(name);
  }

  Future<void> _retryRun() async {
    await widget.persistence.clearCheckpoint();
    unawaited(AudioService.instance.playCurrentMusicFromUserGesture());
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameScreen(persistence: widget.persistence),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final transient = state == AppLifecycleState.inactive;
    final backgrounded =
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached;
    if (!transient && !backgrounded) return;

    // Always pause an active round so the player returns to a "tap to resume"
    // gate instead of dropping straight back into a live swarm (the most common
    // mobile interruption is a notification / app switch). This is the safety
    // half and is cheap.
    if (_game.phase.value == RoundPhase.playing && !_game.paused) {
      _game.togglePause();
    }

    // The expensive half - flush the checkpoint + stop music - only on TRUE
    // backgrounding, not on transient `inactive` (which fires repeatedly for
    // control-center swipes / notification banners). Avoids a storm of save
    // writes; the checkpoint is still flushed on real backgrounding and at every
    // round transition.
    if (backgrounded) {
      _game.flushForBackground();
      AudioService.instance.stopMusic();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _game.phase.removeListener(_onPhaseChanged);
    _game.tutorialComplete.removeListener(_onTutorialComplete);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameWidget = GameWidget<PdacGame>(
      game: _game,
      initialActiveOverlays: const [
        'hud',
        'roundIntro',
        'contextTip',
        'resistanceAlert',
      ],
      overlayBuilderMap: {
        'hud': (context, game) => HudOverlay(game: game),
        'roundIntro': (context, game) => RoundIntroOverlay(game: game),
        'contextTip': (context, game) => ContextTipOverlay(game: game),
        'resistanceAlert': (context, game) =>
            ResistanceAlertOverlay(game: game),
        'pause': (context, game) => PauseOverlay(game: game),
        'bossRecap': (context, game) => BossRecapOverlay(game: game),
        'roundEndUpgrade': (context, game) =>
            RoundEndUpgradeOverlay(game: game),
        'lesson': (context, game) => LessonOverlay(game: game),
        'quiz': (context, game) => QuizOverlay(game: game),
        'goldShop': (context, game) => GoldShopOverlay(game: game),
        'loadout': (context, game) => LoadoutOverlay(game: game),
        'victory': (context, game) => VictoryOverlay(game: game),
        'gameOver': (context, game) =>
            GameOverOverlay(game: game, onRetry: _retryRun),
      },
    );

    final body = ValueListenableBuilder<SettingsData>(
      valueListenable: SettingsService.instance,
      builder: (context, settings, _) {
        // Colorblind assist is handled at render time (per-deficiency category
        // color remap + shape glyphs on mobs/bullets); this filter is just the
        // independent Contrast Boost slider.
        final boost = settings.colorContrastBoost;
        if (boost <= 0) return gameWidget;
        return ColorFiltered(
          colorFilter: ColorFilter.matrix(_contrastMatrix(1 + boost)),
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix(_saturationMatrix(1 + boost)),
            child: gameWidget,
          ),
        );
      },
    );

    // During an active round the system back gesture/button opens the pause
    // menu instead of yanking the player out of a live fight; in menus/overlays
    // (or while already paused) it pops normally.
    return ValueListenableBuilder<RoundPhase>(
      valueListenable: _game.phase,
      builder: (context, phase, child) {
        return PopScope(
          canPop: phase != RoundPhase.playing,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (!_game.paused) _game.togglePause();
          },
          child: child!,
        );
      },
      child: Scaffold(body: body),
    );
  }
}

/// Standard saturation adjustment matrix - [saturation] of 1.0 is
/// unchanged, higher values increase color intensity. Used by
/// [SettingsData.colorContrastBoost] for accessibility.
List<double> _saturationMatrix(double saturation) {
  const lumR = 0.213, lumG = 0.715, lumB = 0.072;
  final sr = (1 - saturation) * lumR;
  final sg = (1 - saturation) * lumG;
  final sb = (1 - saturation) * lumB;
  return [
    sr + saturation,
    sg,
    sb,
    0,
    0,
    sr,
    sg + saturation,
    sb,
    0,
    0,
    sr,
    sg,
    sb + saturation,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];
}

/// Standard contrast adjustment matrix - [contrast] of 1.0 is unchanged.
List<double> _contrastMatrix(double contrast) {
  final translate = (1 - contrast) * 0.5 * 255;
  return [
    contrast,
    0,
    0,
    0,
    translate,
    0,
    contrast,
    0,
    0,
    translate,
    0,
    0,
    contrast,
    0,
    translate,
    0,
    0,
    0,
    1,
    0,
  ];
}
