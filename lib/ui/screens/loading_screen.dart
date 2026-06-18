import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/palette.dart';
import '../../theme/typography.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    super.key,
    this.failed = false,
    this.errorText,
    this.title = 'PDAC IMMUNE DEFENSE',
    this.protocolLabel = 'BIOMARKER PROTOCOL',
    this.footerText =
        'Early detection research is the mission. Your immune defense is coming online.',
    this.stages = loadingStages,
  });

  final bool failed;
  final String? errorText;
  final String title;
  final String protocolLabel;
  final String footerText;
  final List<LoadingStageInfo> stages;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.backgroundDeep,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppPalette.backgroundGradient,
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              final stage = loadingStageForProgress(t, stages: widget.stages);

              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _ScanFieldPainter(progress: t)),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxHeight < 660;
                      final scannerSize = compact ? 168.0 : 220.0;

                      return Center(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: compact ? 18 : 28,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 620),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: scannerSize,
                                  height: scannerSize,
                                  child: CustomPaint(
                                    painter: _BiomarkerScannerPainter(
                                      progress: t,
                                      failed: widget.failed,
                                    ),
                                  ),
                                ),
                                SizedBox(height: compact ? 18 : 26),
                                Text(
                                  widget.title,
                                  style: AppTypography.displayMedium.copyWith(
                                    fontSize: compact ? 28 : 32,
                                    letterSpacing: 0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.failed
                                      ? widget.errorText ?? 'Startup failed.'
                                      : stage.label,
                                  style: AppTypography.body.copyWith(
                                    color: widget.failed
                                        ? AppPalette.healthLow
                                        : AppPalette.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: compact ? 18 : 24),
                                _LoadingBar(sweep: t, failed: widget.failed),
                                SizedBox(height: compact ? 16 : 22),
                                _LoadingBriefingPanel(
                                  stage: stage,
                                  failed: widget.failed,
                                  protocolLabel: widget.protocolLabel,
                                ),
                                SizedBox(height: compact ? 14 : 22),
                                Text(
                                  widget.footerText,
                                  style: AppTypography.label,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class LoadingStageInfo {
  const LoadingStageInfo({
    required this.label,
    required this.briefing,
    required this.status,
    required this.icon,
    required this.color,
  });

  final String label;
  final String briefing;
  final String status;
  final IconData icon;
  final Color color;
}

const loadingStages = [
  LoadingStageInfo(
    label: 'Preparing immune response',
    briefing: 'Priming innate, antibody, and cytotoxic tools for the run.',
    status: 'Priming',
    icon: Icons.shield_outlined,
    color: AppPalette.innateColor,
  ),
  LoadingStageInfo(
    label: 'Reading saliva biomarkers',
    briefing:
        'Exploring the kind of saliva signal patterns scientists hope might one day flag PDAC early.',
    status: 'Reading',
    icon: Icons.science_outlined,
    color: AppPalette.playerCore,
  ),
  LoadingStageInfo(
    label: 'Mapping pancreatic signal',
    briefing: 'Tracing suspicious cell activity before the next wave arrives.',
    status: 'Mapping',
    icon: Icons.radar_outlined,
    color: AppPalette.gold,
  ),
  LoadingStageInfo(
    label: 'Calibrating defenses',
    briefing: 'Tuning weapon traits so each immune tool has a clear role.',
    status: 'Calibrating',
    icon: Icons.tune,
    color: AppPalette.cytotoxicColor,
  ),
];

const tutorialLoadingStages = [
  LoadingStageInfo(
    label: 'Opening training arena',
    briefing: 'Preparing safe practice targets and guided swap prompts.',
    status: 'Opening',
    icon: Icons.school_outlined,
    color: AppPalette.playerCore,
  ),
  LoadingStageInfo(
    label: 'Priming movement drill',
    briefing: 'Centering the defender and setting up the first coaching beat.',
    status: 'Priming',
    icon: Icons.open_with,
    color: AppPalette.innateColor,
  ),
  LoadingStageInfo(
    label: 'Calibrating color match feedback',
    briefing: 'Syncing the reticle rings for matched and mismatched shots.',
    status: 'Syncing',
    icon: Icons.track_changes,
    color: AppPalette.gold,
  ),
  LoadingStageInfo(
    label: 'Launching tutorial',
    briefing: 'The training arena is almost ready.',
    status: 'Launch',
    icon: Icons.play_arrow,
    color: AppPalette.cytotoxicColor,
  ),
];

const newRunLoadingStages = [
  LoadingStageInfo(
    label: 'Preparing new run',
    briefing: 'Clearing stale checkpoint data and opening a fresh mission.',
    status: 'Preparing',
    icon: Icons.restart_alt,
    color: AppPalette.healthGood,
  ),
  LoadingStageInfo(
    label: 'Building loadout station',
    briefing: 'Bringing your immune tools online before the first wave.',
    status: 'Loadout',
    icon: Icons.inventory_2_outlined,
    color: AppPalette.playerCore,
  ),
  LoadingStageInfo(
    label: 'Mapping first biome',
    briefing: 'Tracing the starting arena and its saliva-signal context.',
    status: 'Mapping',
    icon: Icons.map_outlined,
    color: AppPalette.gold,
  ),
  LoadingStageInfo(
    label: 'Starting run',
    briefing: 'Final checks are passing control to the mission.',
    status: 'Start',
    icon: Icons.play_arrow,
    color: AppPalette.cytotoxicColor,
  ),
];

const continueRunLoadingStages = [
  LoadingStageInfo(
    label: 'Recovering saved run',
    briefing: 'Reading the checkpoint and restoring round progress.',
    status: 'Reading',
    icon: Icons.history,
    color: AppPalette.gold,
  ),
  LoadingStageInfo(
    label: 'Restoring defenses',
    briefing: 'Re-equipping your saved weapons, upgrades, and health state.',
    status: 'Restoring',
    icon: Icons.shield_outlined,
    color: AppPalette.playerCore,
  ),
  LoadingStageInfo(
    label: 'Rebuilding arena',
    briefing: 'Reopening the biome at the saved round boundary.',
    status: 'Rebuild',
    icon: Icons.radar_outlined,
    color: AppPalette.innateColor,
  ),
  LoadingStageInfo(
    label: 'Continuing run',
    briefing: 'The checkpoint is ready.',
    status: 'Continue',
    icon: Icons.play_arrow,
    color: AppPalette.cytotoxicColor,
  ),
];

LoadingStageInfo loadingStageForProgress(
  double progress, {
  List<LoadingStageInfo> stages = loadingStages,
}) {
  final activeStages = stages.isEmpty ? loadingStages : stages;
  final stageCount = activeStages.length;
  final normalized = _normalizedLoadingValue(progress);
  final index = min((normalized * stageCount).floor(), stageCount - 1);
  return activeStages[index];
}

double loadingProgressValue(double controllerValue, {bool failed = false}) {
  if (failed) return 1.0;
  final normalized = _normalizedLoadingValue(controllerValue);
  return (0.18 + normalized * 0.72).clamp(0.0, 1.0).toDouble();
}

double _normalizedLoadingValue(double value) {
  if (!value.isFinite) return 0.0;
  return value.clamp(0.0, 1.0).toDouble();
}

class _LoadingBriefingPanel extends StatelessWidget {
  const _LoadingBriefingPanel({
    required this.stage,
    required this.failed,
    required this.protocolLabel,
  });

  final LoadingStageInfo stage;
  final bool failed;
  final String protocolLabel;

  @override
  Widget build(BuildContext context) {
    final accent = failed ? AppPalette.healthLow : stage.color;
    final status = failed ? 'Hold' : stage.status;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.backgroundMid.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.42)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(stage.icon, color: accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    protocolLabel,
                    style: AppTypography.label.copyWith(color: accent),
                  ),
                ),
                _StatusBadge(text: failed ? 'CHECK' : status.toUpperCase()),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              failed ? 'Startup check interrupted' : stage.label,
              style: AppTypography.bodyStrong,
            ),
            const SizedBox(height: 4),
            Text(
              failed
                  ? 'Restart the game once the browser has settled, then the assay can retry safely.'
                  : stage.briefing,
              style: AppTypography.label.copyWith(
                color: AppPalette.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TelemetryPill(
                  label: 'SALIVA ASSAY',
                  value: failed ? 'halted' : 'online',
                  color: AppPalette.playerCore,
                ),
                _TelemetryPill(
                  label: 'BIOMARKERS',
                  value: failed ? 'retry' : status.toLowerCase(),
                  color: accent,
                ),
                _TelemetryPill(
                  label: 'DEFENSES',
                  value: failed ? 'paused' : 'syncing',
                  color: AppPalette.healthGood,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppPalette.surfaceLight.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(text, style: AppTypography.label),
      ),
    );
  }
}

class _TelemetryPill extends StatelessWidget {
  const _TelemetryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: color, size: 8),
            const SizedBox(width: 7),
            Text(
              '$label: $value',
              style: AppTypography.label.copyWith(
                color: AppPalette.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An honest indeterminate indicator: a segment that sweeps back and forth.
/// It signals "working" without implying a measured percentage, since the
/// real startup time isn't known ahead of the load finishing.
class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.sweep, required this.failed});

  /// Looping 0..1 controller value used only to animate the sweep position.
  final double sweep;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final color = failed ? AppPalette.healthLow : AppPalette.playerCore;
    // Map a looping 0..1 value to a position that travels left -> right ->
    // left (ping-pong), so the moving segment never sits at a fixed "percent".
    const segment = 0.34;
    final phase = sweep < 0.5 ? sweep * 2 : (1 - sweep) * 2;
    final start = phase * (1 - segment);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SizedBox(
          width: double.infinity,
          height: 8,
          child: failed
              ? ColoredBox(color: color.withValues(alpha: 0.7))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: ColoredBox(
                            color: AppPalette.surfaceLight.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        Positioned(
                          left: start * w,
                          width: segment * w,
                          top: 0,
                          bottom: 0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, AppPalette.gold],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _BiomarkerScannerPainter extends CustomPainter {
  const _BiomarkerScannerPainter({
    required this.progress,
    required this.failed,
  });

  final double progress;
  final bool failed;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.38;
    final sweep = progress * 2 * pi;
    final scanColor = failed ? AppPalette.healthLow : AppPalette.playerCore;

    final outerPaint = Paint()
      ..color = AppPalette.surfaceLight.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, outerPaint);
    canvas.drawCircle(center, radius * 0.68, outerPaint..strokeWidth = 1);

    final scanPaint = Paint()
      ..color = scanColor.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      pi * 1.35,
      false,
      scanPaint,
    );

    final beamPaint = Paint()
      ..color = scanColor.withValues(alpha: 0.42)
      ..strokeWidth = 2;
    canvas.drawLine(
      center,
      center + Offset(cos(sweep - pi / 2), sin(sweep - pi / 2)) * radius,
      beamPaint,
    );

    final nodes = [
      Offset(cos(0.4), sin(0.4)) * radius * 0.48,
      Offset(cos(2.3), sin(2.3)) * radius * 0.64,
      Offset(cos(4.2), sin(4.2)) * radius * 0.36,
      Offset(cos(5.4), sin(5.4)) * radius * 0.58,
    ];
    for (var i = 0; i < nodes.length; i++) {
      final pulse = 0.55 + 0.45 * sin(progress * 2 * pi + i).abs();
      final paint = Paint()
        ..color = [
          AppPalette.innateColor,
          AppPalette.antibodyColor,
          AppPalette.cytotoxicColor,
          AppPalette.gold,
        ][i].withValues(alpha: 0.65 + pulse * 0.25);
      canvas.drawCircle(center + nodes[i], 4 + pulse * 2, paint);
    }

    final corePaint = Paint()
      ..color = AppPalette.backgroundDeep.withValues(alpha: 0.84);
    canvas.drawCircle(center, radius * 0.2, corePaint);
    final coreRing = Paint()
      ..color = scanColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.2, coreRing);
  }

  @override
  bool shouldRepaint(covariant _BiomarkerScannerPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.failed != failed;
}

class _ScanFieldPainter extends CustomPainter {
  const _ScanFieldPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppPalette.surfaceLight.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    final signalPaint = Paint()
      ..color = AppPalette.playerCore.withValues(alpha: 0.16)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var y = 48.0; y < size.height; y += 64) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    for (var i = 0; i < 4; i++) {
      final y = size.height * (0.22 + i * 0.16);
      final phase = progress * 2 * pi + i * 0.8;
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x <= size.width; x += 28) {
        path.lineTo(x, y + sin(x * 0.018 + phase) * (10 + i * 2));
      }
      canvas.drawPath(path, signalPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanFieldPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
