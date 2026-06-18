import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flame_audio/flame_audio.dart';

import 'settings_service.dart';

/// Thin wrapper around [FlameAudio] that respects the player's
/// music/sfx volume + master-mute settings.
///
/// SFX (`assets/audio/sfx/*`) and the jukebox music loops (`assets/audio/music/*`)
/// ship with the app and are registered in `pubspec.yaml`. Calls are still safe
/// no-ops if a referenced asset is missing or the browser blocks audio
/// (FlameAudio logs a warning rather than throwing; repeated errors trigger an
/// exponential backoff that disables playback).
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  /// Fresh, isolated instance for tests (the production [instance] is a
  /// process-wide singleton whose mutable state would leak across tests).
  @visibleForTesting
  AudioService.forTest();

  /// Wall-clock source for cooldowns/backoff. Injectable so tests can drive it
  /// deterministically instead of depending on real time.
  @visibleForTesting
  DateTime Function() nowProvider = DateTime.now;

  /// Replaces the real FlameAudio pool playback with a test double, so the
  /// cooldown / concurrency / backoff logic can be exercised without an audio
  /// backend. Null in production (uses the pooled FlameAudio path).
  @visibleForTesting
  Future<void> Function(String fileName, double volume)? sfxPlaybackOverride;

  bool _enabled = false;
  bool _musicPrimedByUserGesture = false;
  bool _reportedAudioError = false;
  int _activeSfxRequests = 0;
  int _consecutiveSfxErrors = 0;
  int _consecutiveMusicErrors = 0;
  DateTime _sfxBackoffUntil = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _musicBackoffUntil = DateTime.fromMillisecondsSinceEpoch(0);

  final Map<String, AudioPool> _pools = {};
  final Map<String, Future<AudioPool>> _poolFutures = {};
  final Map<String, DateTime> _lastPlayedAt = {};

  static const int _maxConcurrentSfxStarts = 3;
  static const int _disableAfterConsecutiveErrors = 6;
  static const Duration _poolLoadTimeout = Duration(milliseconds: 1800);
  static const Duration _playbackStartTimeout = Duration(milliseconds: 1200);
  static const Map<String, int> _cooldownMs = {
    'sfx/shoot.wav': 70,
    'sfx/hit.wav': 55,
    'sfx/death.wav': 80,
    'sfx/coin.wav': 100,
    'sfx/mutation.wav': 500,
    'sfx/round_clear.wav': 500,
    'sfx/boss_charge.wav': 350,
    'sfx/swap.wav': 90,
    'sfx/dash.wav': 120,
  };

  static const Map<String, int> _poolSizes = {
    'sfx/shoot.wav': 4,
    'sfx/hit.wav': 4,
    'sfx/death.wav': 3,
    'sfx/coin.wav': 3,
    'sfx/mutation.wav': 1,
    'sfx/round_clear.wav': 1,
    'sfx/boss_charge.wav': 1,
    'sfx/swap.wav': 2,
    'sfx/dash.wav': 2,
  };

  bool _listeningToSettings = false;

  /// Enables audio and starts reacting to live settings changes (so the Music
  /// volume slider and Mute All affect the already-playing loop immediately,
  /// not just on the next playMusic call).
  Future<void> enable() async {
    _enabled = true;
    if (!_listeningToSettings) {
      _listeningToSettings = true;
      SettingsService.instance.addListener(_applyMusicSettings);
    }
  }

  /// Detaches the live settings listener and stops reacting to changes. The
  /// singleton otherwise keeps the listener wired for the app's lifetime; this
  /// gives an explicit teardown for app shutdown and test isolation.
  void disable() {
    _enabled = false;
    if (_listeningToSettings) {
      _listeningToSettings = false;
      SettingsService.instance.removeListener(_applyMusicSettings);
    }
  }

  /// Pushes the current music volume / mute state onto the live BGM player.
  void _applyMusicSettings() {
    if (!_enabled) return;
    final settings = SettingsService.instance.value;
    final volume = settings.muteAll ? 0.0 : settings.musicVolume;
    try {
      FlameAudio.bgm.audioPlayer.setVolume(volume);
    } catch (_) {
      // No BGM playing yet (or platform without a live player): the next
      // playMusic picks up the volume/mute state anyway.
    }
  }

  Future<void> preloadSfx() async {
    if (!_enabled || _sfxBackedOff) return;
    for (final fileName in _poolSizes.keys) {
      try {
        await _poolFor(fileName).timeout(_poolLoadTimeout);
      } catch (error, stackTrace) {
        _poolFutures.remove(fileName);
        _handleAudioError(error, stackTrace, kind: _AudioErrorKind.sfx);
        if (_sfxBackedOff) return;
      }
    }
  }

  Future<void> playSfx(String fileName) async {
    if (!_enabled || _sfxBackedOff) return;
    final settings = SettingsService.instance.value;
    if (settings.muteAll) return;
    final volume = settings.sfxVolume;
    if (volume <= 0) return;

    final now = nowProvider();
    final lastPlayed = _lastPlayedAt[fileName];
    final cooldown = Duration(milliseconds: _cooldownMs[fileName] ?? 80);
    if (lastPlayed != null && now.difference(lastPlayed) < cooldown) return;
    if (_activeSfxRequests >= _maxConcurrentSfxStarts) return;

    _lastPlayedAt[fileName] = now;
    _activeSfxRequests++;
    try {
      final override = sfxPlaybackOverride;
      if (override != null) {
        await override(fileName, volume);
      } else {
        final pool = await _poolFor(fileName).timeout(_poolLoadTimeout);
        await pool.start(volume: volume).timeout(_playbackStartTimeout);
      }
      _consecutiveSfxErrors = 0;
    } catch (error, stackTrace) {
      _poolFutures.remove(fileName);
      _handleAudioError(error, stackTrace, kind: _AudioErrorKind.sfx);
    } finally {
      _activeSfxRequests--;
    }
  }

  /// Starts or restarts music from a trusted user action, which is required by
  /// browsers before autoplay-blocked audio can play reliably.
  Future<void> playMusicFromUserGesture(String fileName) async {
    _primeFromUserGesture();
    await playMusic(fileName);
  }

  /// Restarts music after app resume only if the player has already taken an
  /// explicit action that unlocked music playback for this session.
  Future<void> resumeMusicIfPrimed(String fileName) async {
    if (!_musicPrimedByUserGesture) return;
    _primeFromUserGesture();
    await playMusic(fileName);
  }

  void _primeFromUserGesture() {
    _musicPrimedByUserGesture = true;
    _sfxBackoffUntil = DateTime.fromMillisecondsSinceEpoch(0);
    _musicBackoffUntil = DateTime.fromMillisecondsSinceEpoch(0);
    unawaited(preloadSfx());
  }

  Future<void> playMusic(String fileName) async {
    if (!_enabled || _musicBackedOff) return;
    final settings = SettingsService.instance.value;
    if (settings.muteAll) return;
    final volume = settings.musicVolume;
    if (volume <= 0) return;
    try {
      await FlameAudio.bgm
          .play(fileName, volume: volume)
          .timeout(_playbackStartTimeout);
      _consecutiveMusicErrors = 0;
    } catch (error, stackTrace) {
      _handleAudioError(error, stackTrace, kind: _AudioErrorKind.music);
    }
  }

  void stopMusic() {
    if (!_enabled) return;
    FlameAudio.bgm.stop();
  }

  /// Plays the player's currently selected jukebox track from a trusted user
  /// gesture (the web-autoplay unlock). No-op when the selection is "Off"
  /// (empty track id).
  Future<void> playCurrentMusicFromUserGesture() async {
    final track = SettingsService.instance.value.musicTrackId;
    if (track.isEmpty) return;
    await playMusicFromUserGesture(track);
  }

  /// Resumes the currently selected track after an app resume, only if music
  /// was already primed this session. No-op when "Off" is selected.
  Future<void> resumeCurrentMusicIfPrimed() async {
    final track = SettingsService.instance.value.musicTrackId;
    if (track.isEmpty) return;
    await resumeMusicIfPrimed(track);
  }

  /// Applies the current music selection immediately - used by the jukebox
  /// after it persists a new choice. Stops what's playing and starts the
  /// selected track, or stays silent when "Off" is chosen. The jukebox tap is
  /// the required user gesture, so this re-primes and plays directly.
  Future<void> applySelectedMusic() async {
    stopMusic();
    final track = SettingsService.instance.value.musicTrackId;
    if (track.isEmpty) return;
    _primeFromUserGesture();
    await playMusic(track);
  }

  bool get _sfxBackedOff => nowProvider().isBefore(_sfxBackoffUntil);

  bool get _musicBackedOff => nowProvider().isBefore(_musicBackoffUntil);

  Future<AudioPool> _poolFor(String fileName) {
    final existing = _pools[fileName];
    if (existing != null) return Future.value(existing);

    return _poolFutures[fileName] ??=
        FlameAudio.createPool(
              fileName,
              minPlayers: 1,
              maxPlayers: _poolSizes[fileName] ?? 2,
            )
            .then((pool) {
              _pools[fileName] = pool;
              _poolFutures.remove(fileName);
              return pool;
            })
            .catchError((Object error, StackTrace stackTrace) {
              _poolFutures.remove(fileName);
              Error.throwWithStackTrace(error, stackTrace);
            });
  }

  void _handleAudioError(
    Object error,
    StackTrace stackTrace, {
    required _AudioErrorKind kind,
  }) {
    final consecutiveErrors = switch (kind) {
      _AudioErrorKind.sfx => ++_consecutiveSfxErrors,
      _AudioErrorKind.music => ++_consecutiveMusicErrors,
    };
    final backoffSeconds = consecutiveErrors >= _disableAfterConsecutiveErrors
        ? 30
        : 3;
    final backoffUntil = nowProvider().add(Duration(seconds: backoffSeconds));
    switch (kind) {
      case _AudioErrorKind.sfx:
        _sfxBackoffUntil = backoffUntil;
      case _AudioErrorKind.music:
        _musicBackoffUntil = backoffUntil;
    }

    if (!_reportedAudioError && kDebugMode) {
      _reportedAudioError = true;
      debugPrint('Audio playback paused after browser audio error: $error');
    }
  }
}

enum _AudioErrorKind { sfx, music }
