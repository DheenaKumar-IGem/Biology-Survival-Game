import 'package:flutter/material.dart';

import '../../game/components/hud_data.dart';
import '../../game/pdac_game.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import '../widgets/glow_button.dart';

/// Shown after boss clears. It gives the victory a moment to land and ties the
/// encounter back to PDAC progression before the next flow step.
class BossRecapOverlay extends StatelessWidget {
  const BossRecapOverlay({super.key, required this.game});

  final PdacGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BossRecapData?>(
      valueListenable: game.hud.bossRecap,
      builder: (context, recap, _) {
        if (recap == null) return const SizedBox.shrink();
        final finalBoss = recap.roundNumber >= 9;
        return Container(
          color: AppPalette.backgroundDeep.withValues(alpha: 0.88),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppPalette.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppPalette.gold.withValues(alpha: 0.48),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.gold.withValues(alpha: 0.16),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.biotech,
                              color: AppPalette.gold,
                              size: 32,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BOSS DEBRIEF',
                                    style: AppTypography.label.copyWith(
                                      color: AppPalette.gold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    recap.bossName,
                                    style: AppTypography.displayMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Round ${recap.roundNumber} - ${recap.stageLabel}',
                                    style: AppTypography.body.copyWith(
                                      color: AppPalette.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _DebriefPanel(
                          icon: Icons.sports_esports,
                          title: 'What You Modeled',
                          body: recap.fightTakeaway,
                          color: AppPalette.playerCore,
                        ),
                        const SizedBox(height: 12),
                        _DebriefPanel(
                          icon: Icons.science,
                          title: 'PDAC Connection',
                          body: recap.scienceConnection,
                          color: AppPalette.healthGood,
                        ),
                        const SizedBox(height: 12),
                        _DebriefPanel(
                          icon: Icons.radar,
                          title: 'Saliva Detection Lead',
                          body: recap.nextStep,
                          color: AppPalette.antibodyColor,
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GlowButton(
                            label: finalBoss
                                ? 'Review Final Lesson'
                                : 'Choose Upgrade',
                            icon: finalBoss
                                ? Icons.school
                                : Icons.arrow_forward,
                            color: AppPalette.gold,
                            onPressed: game.finishBossRecap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DebriefPanel extends StatelessWidget {
  const _DebriefPanel({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.backgroundDeep.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.36)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppTypography.bodyStrong),
                  const SizedBox(height: 5),
                  Text(
                    body,
                    style: AppTypography.body.copyWith(
                      color: AppPalette.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
