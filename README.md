# Charlotte - HS

`Charlotte - HS` is a Flutter + Flame biology game app.

It currently includes:
- `Biology Game`, a survivor-style educational arena game with lesson rounds
- `Blood Vessel Defense`, a prototype biology-themed tower defense game

## Tech
- Flutter
- Dart
- Flame

## Controls
- Move: WASD or arrow keys
- Dash: Space or the DASH button
- Close tutorial: Esc

## Notes
Open the project in VS Code, run `flutter pub get`, then `flutter run`.

## Lesson content
Lessons and quiz questions now load from Postgres table content first on native Flutter targets, then cache the latest successful response in `SharedPreferences` for offline play. Flutter Web cannot open direct Postgres socket connections, so web builds use the tracked `web/lesson_cache.json`, an optional hosted JSON export passed through `LESSON_CACHE_URL`, or the last cached lesson data in `SharedPreferences`.

Provide the database URL at runtime with:

```bash
flutter run --dart-define=LESSON_DATABASE_URL=postgresql://user:password@host:5432/game-db
```

For web builds, point the app at a hosted lesson export with:

```bash
flutter run -d chrome --dart-define=LESSON_CACHE_URL=https://your-host.example.com/lesson_cache.json
```

If you do not pass `LESSON_CACHE_URL`, the web build will look for `web/lesson_cache.json` first before falling back to the last cached lesson data or the bundled backup lessons.

Local lesson cache exports such as `.lesson_cache/` and `lesson_cache.json` are still ignored by git. The tracked `web/lesson_cache.json` file is the web-ready export used by the site.

Database content lives in `igem_lesson_content` and `igem_lesson_question`. Each lesson stores its reading text, source metadata, prompt, and `key_terms`; each question stores its prompt, answer choices, and `correct_index`.

## GitHub Pages
The repo includes a GitHub Actions workflow at `.github/workflows/deploy-pages.yml` that builds the Flutter web app and deploys it to GitHub Pages from `main`. For this repo, the site URL is expected to be:

```text
https://queencitygems.github.io/igem-app/
```
## Run
```bash
flutter pub get
flutter run
```
