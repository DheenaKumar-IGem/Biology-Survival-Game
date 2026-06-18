import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A selectable jukebox track. [id] is the FlameAudio path under
/// `assets/audio/` (e.g. `music/bloodstream_drift.wav`); an empty [id] is the
/// special "Off" entry (no background music).
@immutable
class MusicTrack {
  const MusicTrack({required this.id, required this.label});

  final String id;
  final String label;

  bool get isOff => id.isEmpty;

  /// The "no music" choice.
  static const MusicTrack off = MusicTrack(id: '', label: 'Off (silence)');

  /// The tracks that ship with the game. Also the fallback list when the asset
  /// manifest can't be read (e.g. in tests), so the jukebox always has content.
  /// To add a track: drop a `.wav`/`.mp3`/`.ogg` into `assets/audio/music/` -
  /// [discoverMusicTracks] picks it up automatically; adding it here too just
  /// guarantees a nice label and ordering.
  static const List<MusicTrack> bundled = [
    MusicTrack(id: 'music/bloodstream_drift.wav', label: 'Serum Skyline'),
    MusicTrack(id: 'music/immune_calm.wav', label: 'Antibody Aurora'),
    MusicTrack(id: 'music/deep_current.wav', label: 'Abyssal Current'),
  ];

  @override
  bool operator ==(Object other) => other is MusicTrack && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Title-cases a filename stem: `example_track` -> `Example Track`.
String _labelFromFile(String fileStem) {
  return fileStem
      .split(RegExp(r'[_\-\s]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

/// All selectable tracks: every audio file bundled under `assets/audio/music/`
/// (auto-discovered from the asset manifest so new files appear with no code
/// change), followed by an "Off" entry. Falls back to [MusicTrack.bundled] if
/// the manifest is unavailable.
Future<List<MusicTrack>> discoverMusicTracks() async {
  final tracks = <MusicTrack>[...MusicTrack.bundled];
  final seen = {for (final t in tracks) t.id};

  try {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    const prefix = 'assets/audio/music/';
    final audio = RegExp(r'\.(wav|mp3|ogg)$', caseSensitive: false);
    for (final key in manifest.listAssets()) {
      if (!key.startsWith(prefix) || !audio.hasMatch(key)) continue;
      final id = key.replaceFirst('assets/audio/', '');
      if (seen.add(id)) {
        tracks.add(
          MusicTrack(
            id: id,
            label: _labelFromFile(
              key.substring(prefix.length).split('.').first,
            ),
          ),
        );
      }
    }
  } catch (e) {
    debugPrint('Music discovery fell back to the bundled list: $e');
  }

  return [...tracks, MusicTrack.off];
}
