/// A single multiple-choice quiz question.
class LessonQuestion {
  const LessonQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;

  /// Exactly 4 answer choices.
  final List<String> options;

  /// Index into [options] of the correct answer.
  final int correctIndex;

  /// Short feedback shown after the player answers. This turns the quiz
  /// into a teach-back moment instead of only a score check.
  final String explanation;
}

/// A lesson shown after a round, followed by a short quiz.
///
/// Rounds 1-3 cover core game mechanics and basic biology/immunology.
/// Rounds 4-9 progressively go deeper into PDAC (pancreas anatomy, risk
/// factors, KRAS mutations, staging, early detection, treatment).
class LessonContent {
  const LessonContent({
    required this.id,
    required this.title,
    required this.readingText,
    required this.keyTerms,
    required this.questions,
  });

  final String id;
  final String title;
  final String readingText;
  final List<String> keyTerms;

  /// Exactly 3 questions.
  final List<LessonQuestion> questions;
}
