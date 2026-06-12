import 'package:postgres/postgres.dart';

import 'lesson_database_row_set.dart';

Future<LessonDatabaseRowSet> fetchLessonRowsFromDatabase(String databaseUrl) async {
  final connection = await Connection.openFromUrl(_databaseUrlWithSslModeDisabled(databaseUrl));
  try {
    final lessonRows = await connection.execute(
      Sql.named('''
        select unit_number, unit_title, title, source_title, source_url, source_credit,
               reading_text, prompt, key_terms
        from igem_lesson_content
        order by sort_order, unit_number
      '''),
    );
    final questionRows = await connection.execute(
      Sql.named('''
        select lesson_unit_number, prompt, choices, correct_index
        from igem_lesson_question
        order by lesson_unit_number, sort_order, id
      '''),
    );

    return LessonDatabaseRowSet(
      lessons: [for (final row in lessonRows) row.toColumnMap()],
      questions: [for (final row in questionRows) row.toColumnMap()],
    );
  } finally {
    await connection.close();
  }
}

String _databaseUrlWithSslModeDisabled(String databaseUrl) {
  final uri = Uri.parse(databaseUrl);
  return uri.replace(
    queryParameters: <String, String>{
      ...uri.queryParameters,
      'sslmode': uri.queryParameters['sslmode'] ?? 'disable',
    },
  ).toString();
}
