import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/maps/biome_catalog.dart';
import '../../game/game_state.dart';
import '../../services/audio_service.dart';
import '../../services/persistence_service.dart';
import '../../services/save_data.dart';
import '../../services/settings_service.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import '../overlays/jukebox_sheet.dart';
import '../widgets/blob_painter.dart';
import '../widgets/pressable_action.dart';
import 'disclaimer_screen.dart';
import 'enemy_dictionary_screen.dart';
import 'game_screen.dart';
import 'gold_shop_screen.dart';
import 'settings_screen.dart';

/// App entry screen: a polished mission hub that keeps Play primary while
/// surfacing campaign progress, research context, and long-term upgrades.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runFirstLaunchFlow());
  }

  /// First launch: show the one-time disclaimer + quick accessibility intro,
  /// then the interactive tutorial. The tutorial is marked seen only on genuine
  /// completion (see [GameScreen]), so backing out early re-offers it next time
  /// rather than silently dropping the player into a full run unguided.
  Future<void> _runFirstLaunchFlow() async {
    if (!mounted) return;
    if (!PersistenceService.instance.disclaimerSeen) {
      await showFirstRunIntro(context);
      if (!mounted) return;
    }
    if (!PersistenceService.instance.tutorialSeen) {
      await _startTutorial();
    }
  }

  Future<void> _startTutorial() async {
    unawaited(AudioService.instance.playCurrentMusicFromUserGesture());
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          persistence: PersistenceService.instance,
          tutorial: true,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _continueRun() async {
    final checkpoint = PersistenceService.instance.checkpoint;
    if (checkpoint == null) {
      await _startNewRun();
      return;
    }
    unawaited(AudioService.instance.playCurrentMusicFromUserGesture());
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          persistence: PersistenceService.instance,
          checkpoint: checkpoint,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _startNewRun() async {
    await PersistenceService.instance.clearCheckpoint();
    unawaited(AudioService.instance.playCurrentMusicFromUserGesture());
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(persistence: PersistenceService.instance),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final save = PersistenceService.instance.saveData;
    final checkpoint = save.checkpoint;
    final missionRound = checkpoint?.roundNumber ?? 1;
    final biome = BiomeCatalog.forRound(missionRound);
    final campaignProgress = (save.highestRoundReached / 9)
        .clamp(0.0, 1.0)
        .toDouble();
    final upgradedWeapons = save.gunUpgrades.values
        .where(
          (state) => state.statLevel > 0 || state.unlockedTraits.isNotEmpty,
        )
        .length;

    return Scaffold(
      backgroundColor: AppPalette.backgroundDeep,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppPalette.backgroundGradient,
        ),
        child: Stack(
          children: [
            const _DriftingBackground(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  final compact = constraints.maxWidth < 520;
                  final horizontalPadding = isWide ? 48.0 : 20.0;

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          compact ? 16 : 22,
                          horizontalPadding,
                          compact ? 20 : 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _HomeHeader(
                              isWide: isWide,
                              gold: save.goldCoins,
                              bestRound: save.highestRoundReached,
                              upgradedWeapons: upgradedWeapons,
                            ),
                            const _SaveHealthBanner(),
                            SizedBox(height: isWide ? 28 : (compact ? 14 : 22)),
                            if (isWide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: _MissionHero(
                                      biomeName: biome.displayName,
                                      progress: campaignProgress,
                                      compact: false,
                                    ),
                                  ),
                                  const SizedBox(width: 36),
                                  Expanded(
                                    flex: 5,
                                    child: _MissionConsole(
                                      nextRound: missionRound,
                                      biomeName: biome.displayName,
                                      biomeTagline: biome.tagline,
                                      campaignProgress: campaignProgress,
                                      checkpoint: checkpoint,
                                      compact: false,
                                      onContinue: _continueRun,
                                      onNewRun: _startNewRun,
                                      onTutorial: _startTutorial,
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              _MissionHero(
                                biomeName: biome.displayName,
                                progress: campaignProgress,
                                compact: compact,
                              ),
                              SizedBox(height: compact ? 14 : 22),
                              _MissionConsole(
                                nextRound: missionRound,
                                biomeName: biome.displayName,
                                biomeTagline: biome.tagline,
                                campaignProgress: campaignProgress,
                                checkpoint: checkpoint,
                                compact: compact,
                                onContinue: _continueRun,
                                onNewRun: _startNewRun,
                                onTutorial: _startTutorial,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A subtle warning shown only if a save write has failed, so the player knows
/// progress (gold, unlocks) may not be persisting rather than discovering it
/// silently reverted on the next launch.
class _SaveHealthBanner extends StatelessWidget {
  const _SaveHealthBanner();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PersistenceService.instance.writeHealthy,
      builder: (context, healthy, _) {
        if (healthy) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppPalette.healthLow.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppPalette.healthLow.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppPalette.healthLow,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Heads up: progress may not be saving on this device '
                    '(storage is full or blocked).',
                    style: AppTypography.label.copyWith(
                      color: AppPalette.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.isWide,
    required this.gold,
    required this.bestRound,
    required this.upgradedWeapons,
  });

  final bool isWide;
  final int gold;
  final int bestRound;
  final int upgradedWeapons;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            style: AppTypography.displayLarge.copyWith(
              fontSize: isWide ? 44 : 34,
              height: 1.0,
              letterSpacing: isWide ? 4.0 : 2.5,
            ),
            children: const [
              TextSpan(
                text: 'PDAC ',
                style: TextStyle(color: AppPalette.gold),
              ),
              TextSpan(text: 'IMMUNE DEFENSE'),
            ],
          ),
          textAlign: isWide ? TextAlign.left : TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Saliva-signal defense initiative',
          style: AppTypography.body.copyWith(color: AppPalette.textSecondary),
          textAlign: isWide ? TextAlign.left : TextAlign.center,
        ),
      ],
    );

    final status = _StatusStrip(
      items: [
        _StatusItem(icon: Icons.paid, label: 'Gold', value: '$gold'),
        _StatusItem(
          icon: Icons.flag,
          label: 'Best',
          value: bestRound <= 0 ? 'New' : 'Round $bestRound',
        ),
        _StatusItem(
          icon: Icons.biotech,
          label: 'Upgrades',
          value: '$upgradedWeapons',
        ),
      ],
    );

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [title, const SizedBox(height: 18), status],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: 24),
        Flexible(child: status),
      ],
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.items});

  final List<_StatusItem> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.surface.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppPalette.surfaceLight.withValues(alpha: 0.9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Wrap(
          spacing: 18,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [for (final item in items) _StatusAtom(item: item)],
        ),
      ),
    );
  }
}

class _StatusAtom extends StatelessWidget {
  const _StatusAtom({required this.item});

  final _StatusItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(item.icon, color: AppPalette.gold, size: 17),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.label, style: AppTypography.label),
            Text(item.value, style: AppTypography.bodyStrong),
          ],
        ),
      ],
    );
  }
}

class _StatusItem {
  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _MissionHero extends StatefulWidget {
  const _MissionHero({
    required this.biomeName,
    required this.progress,
    this.compact = false,
  });

  final String biomeName;
  final double progress;
  final bool compact;

  @override
  State<_MissionHero> createState() => _MissionHeroState();
}

class _MissionHeroState extends State<_MissionHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    );
    _syncMotion();
    SettingsService.instance.addListener(_syncMotion);
  }

  // Start/stop with the live Reduce Motion setting so toggling it in Settings
  // and returning here takes effect without needing a full rebuild.
  void _syncMotion() {
    final reduce = SettingsService.instance.value.reduceMotion;
    if (reduce && _controller.isAnimating) {
      _controller.stop();
    } else if (!reduce && !_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    SettingsService.instance.removeListener(_syncMotion);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSize = widget.compact ? 320.0 : 520.0;
        final heightFactor = widget.compact ? 0.78 : 0.92;
        final size = min(constraints.maxWidth, maxSize);
        return Center(
          child: SizedBox(
            width: size,
            height: size * heightFactor,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MissionScopePainter(
                          progress: _controller.value,
                          campaignProgress: widget.progress,
                        ),
                      ),
                    ),
                    AnimatedBlob(
                      radius: size * 0.19,
                      primaryColor: AppPalette.avatarCore,
                      accentColor: AppPalette.avatarGlow,
                      rimColor: AppPalette.gold,
                    ),
                    Positioned(
                      left: 8,
                      bottom: 12,
                      child: _SignalPlate(
                        label: 'Current sector',
                        value: widget.biomeName,
                        icon: Icons.radar,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 18,
                      child: _SignalPlate(
                        label: 'Trace',
                        value: '${(widget.progress * 100).round()}%',
                        icon: Icons.timeline,
                        alignEnd: true,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _MissionScopePainter extends CustomPainter {
  const _MissionScopePainter({
    required this.progress,
    required this.campaignProgress,
  });

  final double progress;
  final double campaignProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.42;
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppPalette.surfaceLight.withValues(alpha: 0.58);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppPalette.playerCore.withValues(alpha: 0.32),
          AppPalette.healthLow.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2));

    canvas.drawCircle(center, radius * 1.25, glowPaint);

    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(center, radius * (0.45 + i * 0.2), orbitPaint);
    }

    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..color = AppPalette.gold.withValues(alpha: 0.82);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 1.02),
      -pi / 2,
      2 * pi * campaignProgress,
      false,
      sweepPaint,
    );

    final beamAngle = progress * 2 * pi - pi / 2;
    final beamPaint = Paint()
      ..strokeWidth = 2
      ..color = AppPalette.playerCore.withValues(alpha: 0.44);
    canvas.drawLine(
      center,
      center + Offset(cos(beamAngle), sin(beamAngle)) * radius,
      beamPaint,
    );

    final markers = [
      (angle: 0.25, distance: 0.74, color: AppPalette.gold),
      (angle: 1.35, distance: 0.56, color: AppPalette.antibodyColor),
      (angle: 2.45, distance: 0.86, color: AppPalette.cytotoxicColor),
      (angle: 3.6, distance: 0.64, color: AppPalette.innateColor),
      (angle: 5.0, distance: 0.78, color: AppPalette.healthGood),
    ];

    for (var i = 0; i < markers.length; i++) {
      final marker = markers[i];
      final pulse = 0.55 + 0.45 * sin(progress * 2 * pi + i).abs();
      final point =
          center +
          Offset(cos(marker.angle), sin(marker.angle)) *
              radius *
              marker.distance;
      final markerPaint = Paint()
        ..color = marker.color.withValues(alpha: 0.72 + pulse * 0.22);
      canvas.drawCircle(point, 4 + pulse * 2.5, markerPaint);
      canvas.drawCircle(
        point,
        10 + pulse * 5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = marker.color.withValues(alpha: 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MissionScopePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.campaignProgress != campaignProgress;
}

class _SignalPlate extends StatelessWidget {
  const _SignalPlate({
    required this.label,
    required this.value,
    required this.icon,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.backgroundDeep.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.surfaceLight),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!alignEnd) ...[
              Icon(icon, color: AppPalette.playerCore, size: 18),
              const SizedBox(width: 8),
            ],
            Column(
              crossAxisAlignment: alignEnd
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppTypography.label),
                Text(
                  value,
                  style: AppTypography.bodyStrong.copyWith(fontSize: 14),
                ),
              ],
            ),
            if (alignEnd) ...[
              const SizedBox(width: 8),
              Icon(icon, color: AppPalette.gold, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _MissionConsole extends StatelessWidget {
  const _MissionConsole({
    required this.nextRound,
    required this.biomeName,
    required this.biomeTagline,
    required this.campaignProgress,
    required this.checkpoint,
    this.compact = false,
    required this.onContinue,
    required this.onNewRun,
    required this.onTutorial,
  });

  final int nextRound;
  final String biomeName;
  final String biomeTagline;
  final double campaignProgress;
  final CheckpointData? checkpoint;
  final bool compact;
  final VoidCallback onContinue;
  final VoidCallback onNewRun;
  final VoidCallback onTutorial;

  @override
  Widget build(BuildContext context) {
    final completed = (campaignProgress * 100).round();
    final checkpoint = this.checkpoint;
    final hasCheckpoint = checkpoint != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'MISSION BRIEFING',
          style: AppTypography.label.copyWith(color: AppPalette.gold),
        ),
        SizedBox(height: compact ? 8 : 10),
        Text(
          hasCheckpoint
              ? 'Continue Round $nextRound: $biomeName'
              : 'Start Run: $biomeName',
          style: AppTypography.displayMedium.copyWith(
            fontSize: compact ? 28 : 30,
          ),
        ),
        SizedBox(height: compact ? 6 : 8),
        Text(
          biomeTagline,
          style: AppTypography.body.copyWith(color: AppPalette.textSecondary),
        ),
        SizedBox(height: compact ? 16 : 22),
        _SignalProgress(value: campaignProgress, label: '$completed% traced'),
        if (checkpoint != null) ...[
          const SizedBox(height: 14),
          _ResumeStatus(checkpoint: checkpoint),
        ],
        SizedBox(height: compact ? 18 : 24),
        _MissionActionButton(
          label: hasCheckpoint ? 'Continue Run' : 'Start Run',
          icon: Icons.play_arrow,
          color: AppPalette.playerCore,
          filled: true,
          onPressed: hasCheckpoint ? onContinue : onNewRun,
        ),
        SizedBox(height: compact ? 10 : 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (hasCheckpoint)
              _MissionActionButton(
                label: 'New Run',
                icon: Icons.restart_alt,
                color: AppPalette.healthLow,
                onPressed: onNewRun,
              ),
            _MissionActionButton(
              label: 'Tutorial',
              icon: Icons.school,
              color: AppPalette.textSecondary,
              onPressed: onTutorial,
            ),
            _MissionActionButton(
              label: 'Gold Shop',
              icon: Icons.shopping_bag,
              color: AppPalette.gold,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    backgroundColor: AppPalette.backgroundDeep,
                    body: GoldShopScreen(
                      gameState: GameState(
                        persistence: PersistenceService.instance,
                      ),
                      continueLabel: 'Close',
                      onContinue: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ),
            _MissionActionButton(
              label: 'Enemy Dictionary',
              icon: Icons.menu_book,
              color: AppPalette.textSecondary,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EnemyDictionaryScreen(
                    gameState: GameState(
                      persistence: PersistenceService.instance,
                    ),
                  ),
                ),
              ),
            ),
            _MissionActionButton(
              label: 'Jukebox',
              icon: Icons.queue_music,
              color: AppPalette.playerCore,
              onPressed: () => showJukebox(context),
            ),
            _MissionActionButton(
              label: 'Settings',
              icon: Icons.settings,
              color: AppPalette.textSecondary,
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            _MissionActionButton(
              label: 'About & Safety',
              icon: Icons.info_outline,
              color: AppPalette.textSecondary,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DisclaimerScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResumeStatus extends StatelessWidget {
  const _ResumeStatus({required this.checkpoint});

  final CheckpointData checkpoint;

  @override
  Widget build(BuildContext context) {
    final hp = checkpoint.playerHp.round().clamp(0, 9999);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.playerCore.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppPalette.playerCore.withValues(alpha: 0.42),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Wrap(
          spacing: 14,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _ResumeAtom(
              icon: Icons.bookmark,
              label: 'Checkpoint',
              value: 'Round ${checkpoint.roundNumber}',
              color: AppPalette.playerCore,
            ),
            _ResumeAtom(
              icon: Icons.favorite,
              label: 'HP',
              value: '$hp',
              color: AppPalette.healthGood,
            ),
            _ResumeAtom(
              icon: Icons.paid,
              label: 'Run gold',
              value: '${checkpoint.goldThisRun}',
              color: AppPalette.gold,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumeAtom extends StatelessWidget {
  const _ResumeAtom({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTypography.label),
            Text(value, style: AppTypography.bodyStrong.copyWith(fontSize: 13)),
          ],
        ),
      ],
    );
  }
}

class _SignalProgress extends StatelessWidget {
  const _SignalProgress({required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.analytics, color: AppPalette.gold, size: 18),
            const SizedBox(width: 8),
            Text('Campaign signal', style: AppTypography.bodyStrong),
            const Spacer(),
            Text(
              label,
              style: AppTypography.label.copyWith(
                color: AppPalette.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: AppPalette.surfaceLight.withValues(alpha: 0.55),
                ),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value.clamp(0.0, 1.0),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppPalette.playerCore,
                          AppPalette.gold,
                          AppPalette.healthLow,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MissionActionButton extends StatefulWidget {
  const _MissionActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool filled;

  @override
  State<_MissionActionButton> createState() => _MissionActionButtonState();
}

class _MissionActionButtonState extends State<_MissionActionButton> {
  @override
  Widget build(BuildContext context) {
    return PressableAction(
      onPressed: widget.onPressed,
      semanticLabel: widget.label,
      builder:
          (
            context, {
            required enabled,
            required pressed,
            required focused,
            required hovered,
          }) {
            final borderAlpha = focused ? 1.0 : (hovered ? 0.9 : 0.7);
            return AnimatedScale(
              scale: pressed ? 0.97 : 1,
              duration: const Duration(milliseconds: 130),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: widget.filled ? double.infinity : null,
                constraints: BoxConstraints(
                  minWidth: widget.filled ? 0 : 148,
                  minHeight: widget.filled ? 54 : 48,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.filled
                      ? widget.color.withValues(alpha: focused ? 0.24 : 0.2)
                      : AppPalette.surface.withValues(
                          alpha: hovered || focused ? 0.72 : 0.58,
                        ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.color.withValues(
                      alpha: widget.filled ? 0.95 : borderAlpha,
                    ),
                    width: focused ? 2 : (widget.filled ? 1.6 : 1.2),
                  ),
                  boxShadow: widget.filled || focused
                      ? [
                          BoxShadow(
                            color: widget.color.withValues(
                              alpha: focused ? 0.42 : 0.3,
                            ),
                            blurRadius: focused ? 22 : 18,
                          ),
                        ]
                      : const [],
                ),
                child: Row(
                  mainAxisSize: widget.filled
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: widget.color, size: 21),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.label,
                        style: AppTypography.button.copyWith(
                          fontSize: widget.filled ? 18 : 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }
}

class _DriftingBackground extends StatefulWidget {
  const _DriftingBackground();

  @override
  State<_DriftingBackground> createState() => _DriftingBackgroundState();
}

class _DriftingBackgroundState extends State<_DriftingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _rng = Random(42);
  late final List<_BgBlob> _blobs;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _syncMotion();
    SettingsService.instance.addListener(_syncMotion);
    _blobs = List.generate(5, (i) {
      return _BgBlob(
        radius: 60 + _rng.nextDouble() * 100,
        color: [
          AppPalette.innateColor,
          AppPalette.gold,
          AppPalette.cytotoxicColor,
          AppPalette.healthGood,
          AppPalette.antibodyColor,
        ][i % 5],
        anchor: Alignment(_rng.nextDouble() * 2 - 1, _rng.nextDouble() * 2 - 1),
        phase: _rng.nextDouble() * 2 * pi,
        seed: i,
      );
    });
  }

  // React to the Reduce Motion setting changing while Home is on screen.
  void _syncMotion() {
    final reduce = SettingsService.instance.value.reduceMotion;
    if (reduce && _controller.isAnimating) {
      _controller.stop();
    } else if (!reduce && !_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    SettingsService.instance.removeListener(_syncMotion);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value * 2 * pi;
            return Stack(
              children: [
                for (final blob in _blobs)
                  Align(
                    alignment: Alignment(
                      blob.anchor.x + 0.08 * sin(t + blob.phase),
                      blob.anchor.y + 0.08 * cos(t + blob.phase),
                    ),
                    child: Opacity(
                      opacity: 0.14,
                      child: AnimatedBlob(
                        radius: blob.radius,
                        primaryColor: blob.color,
                        accentColor: blob.color,
                        seed: blob.seed,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BgBlob {
  _BgBlob({
    required this.radius,
    required this.color,
    required this.anchor,
    required this.phase,
    required this.seed,
  });

  final double radius;
  final Color color;
  final Alignment anchor;
  final double phase;
  final int seed;
}
