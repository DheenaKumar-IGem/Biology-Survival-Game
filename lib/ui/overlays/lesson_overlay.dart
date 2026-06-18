import 'package:flutter/material.dart';

import '../../data/lessons/lesson_catalog.dart';
import '../../game/pdac_game.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import '../widgets/glow_button.dart';

/// Shown after the round-end upgrade choice (`RoundPhase.lesson`). Presents
/// the round's biology lesson before the quiz.
class LessonOverlay extends StatelessWidget {
  const LessonOverlay({super.key, required this.game});

  final PdacGame game;

  @override
  Widget build(BuildContext context) {
    final round = game.gameState.currentRound;
    final lesson =
        LessonCatalog.all['lesson_round_$round'] ?? LessonCatalog.lessonRound1;

    return Container(
      color: AppPalette.backgroundDeep.withValues(alpha: 0.85),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppPalette.surfaceLight),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.title, style: AppTypography.displayMedium),
                    const SizedBox(height: 16),
                    Text(lesson.readingText, style: AppTypography.body),
                    if (lesson.keyTerms.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Key terms', style: AppTypography.label),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final term in lesson.keyTerms)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppPalette.surfaceLight,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                term,
                                style: AppTypography.label.copyWith(
                                  color: AppPalette.textPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GlowButton(
                        label: 'Take the Quiz',
                        icon: Icons.arrow_forward,
                        onPressed: game.finishLesson,
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
  }
}
