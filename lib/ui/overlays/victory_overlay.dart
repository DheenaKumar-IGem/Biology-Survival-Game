import 'package:flutter/material.dart';

import '../../game/pdac_game.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import '../widgets/glow_button.dart';
import '../widgets/run_summary.dart';

/// Shown when the player clears round 9 (`RoundPhase.victory`).
class VictoryOverlay extends StatelessWidget {
  const VictoryOverlay({super.key, required this.game});

  final PdacGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.backgroundDeep.withValues(alpha: 0.94),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppPalette.backgroundDeep.withValues(alpha: 0.96),
            AppPalette.backgroundMid.withValues(alpha: 0.96),
          ],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppPalette.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppPalette.gold.withValues(alpha: 0.62),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppPalette.gold.withValues(alpha: 0.26),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                        constraints.maxWidth < 520 ? 22 : 30,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _EndReportHeader(
                            label: 'ASSAY COMPLETE',
                            title: 'PDAC Signal Contained',
                            message:
                                'You traced the saliva biomarker trail through all 9 rounds and held the immune defense together.\n\n'
                                'In real life, catching and treating pancreatic cancer is still very hard - scientists are working on tests like this one.',
                            icon: Icons.shield_moon,
                          ),
                          const SizedBox(height: 20),
                          RunSummary(
                            game: game,
                            roundsReached: 9,
                            victory: true,
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GlowButton(
                              label: 'Return Home',
                              icon: Icons.home,
                              color: AppPalette.gold,
                              onPressed: () => Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EndReportHeader extends StatelessWidget {
  const _EndReportHeader({
    required this.label,
    required this.title,
    required this.message,
    required this.icon,
  });

  final String label;
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppPalette.gold.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: AppPalette.gold.withValues(alpha: 0.52)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Icon(icon, color: AppPalette.gold, size: 34),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.label.copyWith(color: AppPalette.gold),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.displayLarge,
                ),
              ),
              const SizedBox(height: 8),
              Text(message, style: AppTypography.body),
            ],
          ),
        ),
      ],
    );
  }
}
