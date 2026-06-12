import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:square_shooter_game/main.dart' as app;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('export lesson cache', () async {
    final payload = <String, dynamic>{
      'version': 1,
      'lessons': [
        for (final lesson in app.bundledLessonSequence) lesson.toJson(),
      ],
    };

    final output = const JsonEncoder.withIndent('  ').convert(payload);
    final file = File('web/lesson_cache.json');
    await file.parent.create(recursive: true);
    await file.writeAsString('$output\n');

    expect(file.existsSync(), isTrue);
    expect(app.bundledLessonSequence, isNotEmpty);
  });
}
