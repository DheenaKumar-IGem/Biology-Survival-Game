import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../game/components/hud_data.dart';
import '../../game/pdac_game.dart';
import '../../services/settings_service.dart';
import '../../theme/fx_constants.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// Short, non-blocking round-start presentation. It gives the start of each
/// round a more finished cadence without interrupting movement or combat.
class RoundIntroOverlay extends StatefulWidget {
  const RoundIntroOverlay({super.key, required this.game});

  final PdacGame game;

  @override
  State<RoundIntroOverlay> createState() => _RoundIntroOverlayState();
}

class _RoundIntroOverlayState extends State<RoundIntroOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    // Respect Reduce Motion: leave the scan ring static instead of looping.
    if (!SettingsService.instance.value.reduceMotion) {
      _scanController.repeat();
    }
    widget.game.hud.roundIntro.addListener(_onIntroChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onIntroChanged());
  }

  void _onIntroChanged() {
    _dismissTimer?.cancel();
    if (widget.game.hud.roundIntro.value == null) return;
    _dismissTimer = Timer(const Duration(milliseconds: 3800), () {
      widget.game.hud.roundIntro.value = null;
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    widget.game.hud.roundIntro.removeListener(_onIntroChanged);
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: SafeArea(
          child: Align(
            alignment: const Alignment(0, -0.34),
            child: ValueListenableBuilder<RoundIntroData?>(
              valueListenable: widget.game.hud.roundIntro,
              builder: (context, intro, _) {
                return AnimatedSwitcher(
                  duration: FxConstants.medium,
                  switchInCurve: FxConstants.standardCurve,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final offset = Tween<Offset>(
                      begin: const Offset(0, -0.12),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: offset, child: child),
                    );
                  },
                  child: intro == null
                      ? const SizedBox.shrink()
                      : _RoundIntroCard(
                          key: ValueKey(
                            '${intro.roundNumber}-${intro.biomeName}',
                          ),
                          intro: intro,
                          scanController: _scanController,
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIntroCard extends StatelessWidget {
  const _RoundIntroCard({
    super.key,
    required this.intro,
    required this.scanController,
  });

  final RoundIntroData intro;
  final Animation<double> scanController;

  @override
  Widget build(BuildContext context) {
    final accent = intro.isBossRound ? AppPalette.healthLow : AppPalette.gold;

    return Container(
      width: 560,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.backgroundDeep.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.2), blurRadius: 22),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            height: 86,
            child: AnimatedBuilder(
              animation: scanController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _RoundScanPainter(
                    progress: scanController.value,
                    color: accent,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  intro.isBossRound
                      ? 'BOSS ROUND ${intro.roundNumber}'
                      : 'ROUND ${intro.roundNumber}',
                  style: AppTypography.label.copyWith(color: accent),
                ),
                const SizedBox(height: 6),
                Text(
                  intro.biomeName,
                  style: AppTypography.headline.copyWith(height: 1.08),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  intro.objective,
                  style: AppTypography.body.copyWith(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final threat in intro.threatNames)
                      _ThreatChip(label: threat),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreatChip extends StatelessWidget {
  const _ThreatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppPalette.surfaceLight.withValues(alpha: 0.86),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.coronavirus,
              color: AppPalette.playerCore,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              label,
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

class _RoundScanPainter extends CustomPainter {
  const _RoundScanPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.42;
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppPalette.surfaceLight.withValues(alpha: 0.74);

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawCircle(center, radius * 0.58, basePaint..strokeWidth = 1);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.9);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      pi * 1.25,
      false,
      arcPaint,
    );

    final sweep = progress * 2 * pi - pi / 2;
    final sweepPaint = Paint()
      ..strokeWidth = 2
      ..color = color.withValues(alpha: 0.46);
    canvas.drawLine(
      center,
      center + Offset(cos(sweep), sin(sweep)) * radius,
      sweepPaint,
    );

    for (var i = 0; i < 3; i++) {
      final angle = progress * 2 * pi + i * 2.1;
      final point = center + Offset(cos(angle), sin(angle)) * radius * 0.7;
      canvas.drawCircle(
        point,
        3.5,
        Paint()..color = AppPalette.playerCore.withValues(alpha: 0.86),
      );
    }

    canvas.drawCircle(
      center,
      radius * 0.18,
      Paint()..color = color.withValues(alpha: 0.78),
    );
  }

  @override
  bool shouldRepaint(covariant _RoundScanPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
