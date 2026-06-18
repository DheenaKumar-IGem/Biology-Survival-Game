import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/services/audio_service.dart';
import 'package:pdac_immune_defense/services/settings_service.dart';

/// Behavioral coverage for [AudioService]'s defensive SFX gating (cooldown,
/// mute/volume short-circuit, error backoff) using the injectable clock and
/// playback override, so no real audio backend is required.
///
/// Settings are set BEFORE enable() in each test so the music-settings listener
/// (which would touch the real audio backend) never fires mid-test, and each
/// instance is disabled in tearDown so its listener can't leak into the next.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a per-file cooldown suppresses a rapid repeat play', () async {
    SettingsService.instance.value = SettingsData.defaults.copyWith(
      sfxVolume: 1.0,
      muteAll: false,
    );
    var now = DateTime(2020);
    final audio = AudioService.forTest()..nowProvider = () => now;
    addTearDown(audio.disable);
    var plays = 0;
    audio.sfxPlaybackOverride = (_, _) async => plays++;
    await audio.enable();

    await audio.playSfx('sfx/hit.wav');
    expect(plays, 1);

    // Same instant -> inside the cooldown window -> suppressed.
    await audio.playSfx('sfx/hit.wav');
    expect(plays, 1);

    // Advance well past any per-file cooldown -> plays again.
    now = now.add(const Duration(milliseconds: 500));
    await audio.playSfx('sfx/hit.wav');
    expect(plays, 2);
  });

  test('muteAll short-circuits before playback', () async {
    SettingsService.instance.value = SettingsData.defaults.copyWith(
      muteAll: true,
      sfxVolume: 1.0,
    );
    final audio = AudioService.forTest();
    addTearDown(audio.disable);
    var plays = 0;
    audio.sfxPlaybackOverride = (_, _) async => plays++;
    await audio.enable();

    await audio.playSfx('sfx/hit.wav');
    expect(plays, 0);
  });

  test('zero sfx volume short-circuits before playback', () async {
    SettingsService.instance.value = SettingsData.defaults.copyWith(
      muteAll: false,
      sfxVolume: 0.0,
    );
    final audio = AudioService.forTest();
    addTearDown(audio.disable);
    var plays = 0;
    audio.sfxPlaybackOverride = (_, _) async => plays++;
    await audio.enable();

    await audio.playSfx('sfx/coin.wav');
    expect(plays, 0);
  });

  test('repeated playback failures trigger a disabling backoff', () async {
    SettingsService.instance.value = SettingsData.defaults.copyWith(
      sfxVolume: 1.0,
      muteAll: false,
    );
    var now = DateTime(2020);
    final audio = AudioService.forTest()..nowProvider = () => now;
    addTearDown(audio.disable);
    audio.sfxPlaybackOverride = (_, _) async => throw Exception('blocked');
    await audio.enable();

    // Distinct files dodge the per-file cooldown; advancing past each short
    // backoff lets the next play actually attempt (and fail), accumulating
    // consecutive errors up to the disable threshold.
    const files = [
      'sfx/hit.wav',
      'sfx/coin.wav',
      'sfx/shoot.wav',
      'sfx/death.wav',
      'sfx/swap.wav',
      'sfx/dash.wav',
    ];
    for (final file in files) {
      await audio.playSfx(file);
      now = now.add(const Duration(seconds: 5)); // past the 3s soft backoff
    }

    // After the error threshold the backoff jumps to 30s; a play inside that
    // window is suppressed before it ever reaches the (now succeeding) double.
    var plays = 0;
    audio.sfxPlaybackOverride = (_, _) async => plays++;
    now = now.add(const Duration(seconds: 5)); // still inside the 30s backoff
    await audio.playSfx('sfx/round_clear.wav');
    expect(plays, 0, reason: 'still backed off after repeated failures');
  });
}
