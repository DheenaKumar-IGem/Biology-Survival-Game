import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/services/music_library.dart';
import 'package:pdac_immune_defense/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Off is the empty-id silence entry', () {
    expect(MusicTrack.off.id, '');
    expect(MusicTrack.off.isOff, isTrue);
  });

  test('the default music track points at a real bundled track', () {
    // The settings default must be a track the jukebox actually offers.
    expect(
      MusicTrack.bundled.map((t) => t.id),
      contains(SettingsData.defaultMusicTrackId),
    );
  });

  test('discoverMusicTracks lists the bundled tracks with Off last', () async {
    // In the test environment the asset manifest isn't available, so this
    // exercises the bundled fallback path.
    final tracks = await discoverMusicTracks();
    expect(tracks, isNotEmpty);

    final ids = tracks.map((t) => t.id).toList();
    for (final track in MusicTrack.bundled) {
      expect(ids, contains(track.id));
    }

    expect(tracks.last.isOff, isTrue, reason: 'Off is always listed last');
    // Off appears exactly once.
    expect(tracks.where((t) => t.isOff).length, 1);
  });

  test('track labels are human-readable', () {
    for (final track in MusicTrack.bundled) {
      expect(track.label.trim(), isNotEmpty);
      expect(track.label, isNot(contains('_')));
      expect(track.label, isNot(contains('.wav')));
    }
  });
}
