class LessonDatabaseRowSet {
  const LessonDatabaseRowSet({
    required this.lessons,
    required this.questions,
  });

  final List<Map<String, dynamic>> lessons;
  final List<Map<String, dynamic>> questions;
}
