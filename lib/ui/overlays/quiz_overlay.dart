import 'package:flutter/material.dart';

import '../../data/lessons/lesson_catalog.dart';
import '../../data/lessons/lesson_def.dart';
import '../../data/rounds/round_catalog.dart';
import '../../game/game_state.dart';
import '../../game/pdac_game.dart';
import '../../services/playtest_logger.dart';
import '../../services/settings_service.dart';
import '../../theme/fx_constants.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import '../widgets/glow_button.dart';
import '../widgets/pressable_action.dart';

/// Shown after the lesson (`RoundPhase.quiz`). A short 3-question
/// multiple-choice quiz; the score (0-3) drives the gold shop discount via
/// [GameState.quizDiscount].
class QuizOverlay extends StatefulWidget {
  const QuizOverlay({super.key, required this.game});

  final PdacGame game;

  @override
  State<QuizOverlay> createState() => _QuizOverlayState();
}

class _QuizOverlayState extends State<QuizOverlay> {
  int _questionIndex = 0;
  int _score = 0;
  int? _selectedPosition;
  bool _answered = false;
  bool _showingResults = false;

  /// Display order of the current question's options, so the correct answer
  /// isn't always shown in the same position. Maps display position ->
  /// original option index.
  List<int> _order = const [];

  LessonContent get _lesson {
    final round = widget.game.gameState.currentRound;
    return LessonCatalog.all['lesson_round_$round'] ??
        LessonCatalog.lessonRound1;
  }

  @override
  void initState() {
    super.initState();
    _shuffleOptions();
  }

  void _shuffleOptions() {
    final questions = _lesson.questions;
    if (questions.isEmpty) {
      _order = const [];
      return;
    }
    final count =
        questions[_questionIndex.clamp(0, questions.length - 1)].options.length;
    _order = List<int>.generate(count, (i) => i)..shuffle();
  }

  void _select(int position, LessonQuestion question) {
    if (_answered) return;
    final chosenOption = _order[position];
    final correct = chosenOption == question.correctIndex;
    setState(() {
      _selectedPosition = position;
      _answered = true;
      if (correct) _score++;
    });
    PlaytestLogger.instance.quizAnswered(
      round: widget.game.gameState.currentRound,
      questionIndex: _questionIndex,
      chosenOption: chosenOption,
      correct: correct,
    );
  }

  void _next() {
    final questions = _lesson.questions;
    if (_questionIndex + 1 < questions.length) {
      setState(() {
        _questionIndex++;
        _selectedPosition = null;
        _answered = false;
        _shuffleOptions();
      });
    } else {
      setState(() => _showingResults = true);
    }
  }

  void _finishQuiz() {
    widget.game.submitQuiz(_score, _lesson.questions.length);
  }

  @override
  Widget build(BuildContext context) {
    final questions = _lesson.questions;
    if (questions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.game.submitQuiz(0, 0);
      });
      return const SizedBox.shrink();
    }
    if (_showingResults) {
      return _QuizResultsView(
        score: _score,
        total: questions.length,
        finalRound:
            widget.game.gameState.currentRound >= RoundCatalog.all.length,
        onContinue: _finishQuiz,
      );
    }
    final question = questions[_questionIndex.clamp(0, questions.length - 1)];

    return Container(
      color: AppPalette.backgroundDeep.withValues(alpha: 0.85),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
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
                    Text(
                      'Question ${_questionIndex + 1} / ${questions.length}',
                      style: AppTypography.label,
                    ),
                    const SizedBox(height: 12),
                    Text(question.question, style: AppTypography.headline),
                    const SizedBox(height: 20),
                    for (var pos = 0; pos < _order.length; pos++) ...[
                      if (pos > 0) const SizedBox(height: 10),
                      _AnswerOption(
                        text: question.options[_order[pos]],
                        state: !_answered
                            ? _AnswerState.neutral
                            : _order[pos] == question.correctIndex
                            ? _AnswerState.correct
                            : pos == _selectedPosition
                            ? _AnswerState.incorrect
                            : _AnswerState.neutral,
                        onTap: () => _select(pos, question),
                      ),
                    ],
                    AnimatedSwitcher(
                      duration: SettingsService.instance.value.reduceMotion
                          ? Duration.zero
                          : FxConstants.medium,
                      child: _answered
                          ? Padding(
                              key: ValueKey(_questionIndex),
                              padding: const EdgeInsets.only(top: 16),
                              child: _AnswerFeedback(
                                correct:
                                    _selectedPosition != null &&
                                    _order[_selectedPosition!] ==
                                        question.correctIndex,
                                correctAnswer:
                                    question.options[question.correctIndex],
                                explanation: question.explanation,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GlowButton(
                        label: _questionIndex + 1 < questions.length
                            ? 'Next'
                            : 'See Results',
                        icon: Icons.arrow_forward,
                        onPressed: _answered ? _next : null,
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

enum _AnswerState { neutral, correct, incorrect }

class _QuizResultsView extends StatelessWidget {
  const _QuizResultsView({
    required this.score,
    required this.total,
    required this.finalRound,
    required this.onContinue,
  });

  final int score;
  final int total;
  final bool finalRound;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final discount = GameState.quizDiscountForScore(score);
    final percent = (discount * 100).round();
    final perfect = total > 0 && score == total;

    return Container(
      color: AppPalette.backgroundDeep.withValues(alpha: 0.86),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Container(
                margin: const EdgeInsets.all(18),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: perfect ? AppPalette.gold : AppPalette.surfaceLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (perfect ? AppPalette.gold : AppPalette.playerCore)
                          .withValues(alpha: 0.16),
                      blurRadius: 22,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          perfect ? Icons.emoji_events : Icons.school,
                          color: perfect
                              ? AppPalette.gold
                              : AppPalette.playerCore,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            quizResultTitle(score, total),
                            style: AppTypography.displayMedium.copyWith(
                              fontSize: 30,
                              height: 1.05,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      finalRound
                          ? 'Here is what you learned in the final unit. This score is recorded in your end report.'
                          : 'Here is what you learned this round. As a bonus, stronger answers also earn a bigger shop discount before the next round.',
                      style: AppTypography.body,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _ResultChip(
                          icon: Icons.check_circle,
                          label: 'Score',
                          value: '$score / $total',
                          color: AppPalette.healthGood,
                        ),
                        _ResultChip(
                          icon: finalRound
                              ? Icons.flag_circle
                              : Icons.shopping_bag,
                          label: finalRound ? 'Mission' : 'Shop Discount',
                          value: finalRound
                              ? 'Complete'
                              : percent == 0
                              ? 'None'
                              : '$percent%',
                          color: finalRound
                              ? AppPalette.gold
                              : percent == 0
                              ? AppPalette.textMuted
                              : AppPalette.gold,
                        ),
                        _ResultChip(
                          icon: Icons.biotech,
                          label: 'Next Stop',
                          value: finalRound ? 'End Report' : 'Gold Shop',
                          color: AppPalette.playerCore,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppPalette.backgroundDeep.withValues(
                          alpha: 0.46,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppPalette.surfaceLight),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.tips_and_updates,
                              color: AppPalette.gold,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                finalRound
                                    ? finalQuizResultMessage(score, total)
                                    : quizResultMessage(score, total),
                                style: AppTypography.body.copyWith(
                                  color: AppPalette.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GlowButton(
                        label: finalRound
                            ? 'Complete Mission'
                            : 'Open Gold Shop',
                        icon: finalRound
                            ? Icons.emoji_events
                            : Icons.arrow_forward,
                        onPressed: onContinue,
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

class _ResultChip extends StatelessWidget {
  const _ResultChip({
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.52)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppTypography.label),
                Text(value, style: AppTypography.bodyStrong),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerFeedback extends StatelessWidget {
  const _AnswerFeedback({
    required this.correct,
    required this.correctAnswer,
    required this.explanation,
  });

  final bool correct;
  final String correctAnswer;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppPalette.healthGood : AppPalette.healthLow;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.backgroundDeep.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.65)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  correct ? Icons.check_circle : Icons.info,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  correct ? 'Correct' : 'Good try',
                  style: AppTypography.bodyStrong.copyWith(color: color),
                ),
              ],
            ),
            if (!correct) ...[
              const SizedBox(height: 8),
              Text(
                'Correct answer: $correctAnswer',
                style: AppTypography.bodyStrong,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              explanation,
              style: AppTypography.body.copyWith(
                color: AppPalette.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String quizResultTitle(int score, int total) {
  if (total > 0 && score == total) return 'Perfect Lab Notes';
  if (score >= 2) return 'Strong Signal';
  if (score == 1) return 'Signal Detected';
  return 'Review Recommended';
}

String quizResultMessage(int score, int total) {
  if (total > 0 && score == total) {
    return 'You understood the whole lesson - excellent recall. As a bonus, that earns the maximum research discount for this shop visit.';
  }
  if (score >= 2) {
    return 'You understood most of the lesson - nice work. As a bonus, you also earned a useful shop discount.';
  }
  if (score == 1) {
    return 'You picked up part of the lesson. Use the answer feedback to learn the rest before the next round.';
  }
  return 'Use the feedback notes to learn this lesson before the next quiz - that is what matters most. No discount this time, but the learning still counts.';
}

String finalQuizResultMessage(int score, int total) {
  if (total > 0 && score == total) {
    return 'You understood the final treatment lesson and completed the full PDAC signal mission.';
  }
  if (score >= 2) {
    return 'You understood most of the final treatment lesson and completed the full PDAC signal mission.';
  }
  if (score == 1) {
    return 'You completed the mission. Review the feedback notes so the final treatment ideas stick.';
  }
  return 'You completed the mission. The final feedback notes are worth reviewing before you share the game.';
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String text;
  final _AnswerState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _AnswerState.correct => AppPalette.healthGood,
      _AnswerState.incorrect => AppPalette.healthLow,
      _AnswerState.neutral => AppPalette.surfaceLight,
    };

    return PressableAction(
      onPressed: onTap,
      builder:
          (
            context, {
            required enabled,
            required pressed,
            required focused,
            required hovered,
          }) {
            return AnimatedScale(
              scale: pressed ? 0.985 : 1,
              duration: FxConstants.fast,
              curve: FxConstants.standardCurve,
              child: AnimatedContainer(
                duration: FxConstants.fast,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: hovered || focused
                      ? AppPalette.surface.withValues(alpha: 0.9)
                      : AppPalette.backgroundMid,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color,
                    width: focused
                        ? 2.4
                        : (state == _AnswerState.neutral ? 1 : 2),
                  ),
                  boxShadow: focused
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.32),
                            blurRadius: 16,
                          ),
                        ]
                      : const [],
                ),
                child: Text(
                  text,
                  style: AppTypography.body.copyWith(
                    color: AppPalette.textPrimary,
                  ),
                ),
              ),
            );
          },
    );
  }
}
