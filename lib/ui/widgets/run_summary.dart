import 'package:flutter/material.dart';

import '../../game/pdac_game.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';

String runSummaryQuizLabel({required int correct, required int total}) {
  if (total <= 0) return 'No quiz data';
  final percent = (correct / total * 100).round().clamp(0, 100);
  return '$correct / $total ($percent%)';
}

String runSummaryGrade({
  required int roundsReached,
  required int kills,
  required int quizCorrect,
  required int quizTotal,
}) {
  final roundScore = (roundsReached.clamp(0, 9) / 9) * 70;
  final quizScore = quizTotal <= 0 ? 0 : (quizCorrect / quizTotal) * 20;
  final combatScore = kills >= 120 ? 10 : kills / 12;
  final score = (roundScore + quizScore + combatScore).clamp(0, 100);
  if (score >= 90) return 'S';
  if (score >= 78) return 'A';
  if (score >= 64) return 'B';
  if (score >= 48) return 'C';
  return 'D';
}

String runSummaryTakeaway({
  required bool victory,
  required int roundsReached,
  required int quizCorrect,
  required int quizTotal,
}) {
  if (victory) {
    return 'Complete assay: you traced the saliva signal through every stage of the PDAC mission.';
  }
  if (roundsReached <= 3) {
    return 'Next objective: practice dashing through warning zones and matching weapon categories early.';
  }
  if (roundsReached <= 6) {
    return 'Next objective: buy permanent upgrades and rotate weapons before resistance stacks up.';
  }
  final quizPercent = quizTotal <= 0 ? 0 : (quizCorrect / quizTotal) * 100;
  if (quizPercent < 70) {
    return 'Next objective: sharpen the lesson quizzes for bigger shop discounts before the final section.';
  }
  return 'Next objective: preserve HP for the metastatic-stage boss and move before attack lanes fire.';
}

/// End-of-run stat block shown on [VictoryOverlay] and [GameOverOverlay]:
/// rounds reached, kills, gold earned this run, and overall quiz accuracy.
class RunSummary extends StatelessWidget {
  const RunSummary({
    super.key,
    required this.game,
    required this.roundsReached,
    required this.victory,
    this.stats,
  });

  final PdacGame game;
  final bool victory;
  final RunSummaryStats? stats;

  /// Highest round the player reached (9 on victory, [GameState.currentRound]
  /// on a loss).
  final int roundsReached;

  @override
  Widget build(BuildContext context) {
    final resolvedStats = stats ?? RunSummaryStats.fromGame(game);
    final quizTotal = resolvedStats.quizTotal;
    final kills = resolvedStats.kills;
    final quizLabel = runSummaryQuizLabel(
      correct: resolvedStats.quizCorrect,
      total: quizTotal,
    );
    final grade = runSummaryGrade(
      roundsReached: roundsReached,
      kills: kills,
      quizCorrect: resolvedStats.quizCorrect,
      quizTotal: quizTotal,
    );
    final takeaway = runSummaryTakeaway(
      victory: victory,
      roundsReached: roundsReached,
      quizCorrect: resolvedStats.quizCorrect,
      quizTotal: quizTotal,
    );
    final accent = victory ? AppPalette.gold : AppPalette.cytotoxicColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.backgroundDeep.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_turned_in, color: accent, size: 20),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'MISSION DEBRIEF',
                    style: AppTypography.label.copyWith(color: accent),
                  ),
                ),
                _GradeBadge(grade: grade, color: accent),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SummaryTile(
                  icon: Icons.flag,
                  label: 'Rounds',
                  value: '$roundsReached / 9',
                  color: AppPalette.playerCore,
                ),
                _SummaryTile(
                  icon: Icons.coronavirus,
                  label: 'Threats',
                  value: '$kills',
                  color: AppPalette.cytotoxicColor,
                ),
                _SummaryTile(
                  icon: Icons.paid,
                  label: 'Gold',
                  value: '${resolvedStats.goldThisRun}',
                  color: AppPalette.gold,
                ),
                _SummaryTile(
                  icon: Icons.school,
                  label: 'Quiz',
                  value: quizLabel,
                  color: AppPalette.healthGood,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _TakeawayPanel(text: takeaway, color: accent),
          ],
        ),
      ),
    );
  }
}

class RunSummaryStats {
  const RunSummaryStats({
    required this.kills,
    required this.goldThisRun,
    required this.quizCorrect,
    required this.quizTotal,
  });

  factory RunSummaryStats.fromGame(PdacGame game) {
    final state = game.gameState;
    return RunSummaryStats(
      kills: game.hud.kills.value,
      goldThisRun: state.goldThisRun,
      quizCorrect: state.totalQuizCorrect,
      quizTotal: state.totalQuizQuestions,
    );
  }

  final int kills;
  final int goldThisRun;
  final int quizCorrect;
  final int quizTotal;
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.grade, required this.color});

  final String grade;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.56)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('GRADE', style: AppTypography.label.copyWith(color: color)),
            const SizedBox(width: 8),
            Text(
              grade,
              style: AppTypography.bodyStrong.copyWith(
                color: AppPalette.textPrimary,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
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
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 132),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: color.withValues(alpha: 0.34)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: color, size: 17),
            ),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppTypography.label),
                Text(
                  value,
                  style: AppTypography.bodyStrong.copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TakeawayPanel extends StatelessWidget {
  const _TakeawayPanel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.insights, color: color, size: 18),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                text,
                style: AppTypography.body.copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
