import 'lesson_database_row_set.dart';

Future<LessonDatabaseRowSet> fetchLessonRowsFromDatabase(String databaseUrl) async {
  return const LessonDatabaseRowSet(
    lessons: <Map<String, dynamic>>[],
    questions: <Map<String, dynamic>>[],
  );
}
