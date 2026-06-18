import 'package:flutter/material.dart';

import '../../game/pdac_game.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import '../widgets/glow_button.dart';
import '../widgets/run_summary.dart';

/// Shown when the player's HP reaches zero (`RoundPhase.gameOver`).
class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.game,
    required this.onRetry,
    this.roundsReached,
    this.summaryStats,
  });

  final PdacGame game;
  final VoidCallback onRetry;
  final int? roundsReached;
  final RunSummaryStats? summaryStats;

  @override
  Widget build(BuildContext context) {
    final resolvedRoundsReached = roundsReached ?? game.gameState.currentRound;

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
                        color: AppPalette.cytotoxicColor.withValues(
                          alpha: 0.58,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                        constraints.maxWidth < 520 ? 22 : 30,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _EndReportHeader(
                            label: 'ASSAY INTERRUPTED',
                            title: 'Defenses Overwhelmed',
                            message:
                                'You reached Round $resolvedRoundsReached. Review the debrief, spend gold, and try a sharper immune-response mix.',
                            icon: Icons.favorite_border,
                          ),
                          const SizedBox(height: 20),
                          RunSummary(
                            game: game,
                            roundsReached: resolvedRoundsReached,
                            victory: false,
                            stats: summaryStats,
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              GlowButton(
                                label: 'Return Home',
                                icon: Icons.home,
                                color: AppPalette.textSecondary,
                                filled: false,
                                onPressed: () => Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst),
                              ),
                              GlowButton(
                                label: 'Try Again',
                                icon: Icons.replay,
                                color: AppPalette.cytotoxicColor,
                                onPressed: onRetry,
                              ),
                            ],
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
            color: AppPalette.cytotoxicColor.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppPalette.cytotoxicColor.withValues(alpha: 0.52),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Icon(icon, color: AppPalette.cytotoxicColor, size: 34),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: AppPalette.cytotoxicColor,
                ),
              ),
              const SizedBox(height: 6),
              // Scale the large title down (never up) so it can't overflow its
              // Row at high text scale; it wraps to a second line before
              // shrinking further.
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
