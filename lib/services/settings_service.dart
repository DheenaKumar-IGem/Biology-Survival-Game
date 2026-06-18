import 'package:flutter/foundation.dart';

import 'persistence_service.dart';

/// Controls how many concurrent hit-spark particles are allowed and how many
/// particles a single event (hit, death, explosion) spawns.
enum ParticleDensity {
  off,
  low,
  medium,
  high;

  /// Maximum concurrent particles on screen.
  int get maxConcurrent => switch (this) {
    ParticleDensity.off => 0,
    ParticleDensity.low => 15,
    ParticleDensity.medium => 40,
    ParticleDensity.high => 100,
  };

  /// Multiplier applied to the "ideal" particle count for a given event.
  double get spawnMultiplier => switch (this) {
    ParticleDensity.off => 0.0,
    ParticleDensity.low => 0.4,
    ParticleDensity.medium => 0.75,
    ParticleDensity.high => 1.0,
  };
}

/// Controls blob fidelity (point count) and whether glow/blur layers and
/// ambient background animation render.
enum AnimationQuality {
  low,
  medium,
  high;

  /// Number of control points used for blob outlines.
  int get blobPointCount => switch (this) {
    AnimationQuality.low => 6,
    AnimationQuality.medium => 8,
    AnimationQuality.high => 11,
  };

  bool get glowEnabled => this != AnimationQuality.low;

  /// Blur radius multiplier for glow layers.
  double get glowMultiplier => switch (this) {
    AnimationQuality.low => 0.0,
    AnimationQuality.medium => 0.6,
    AnimationQuality.high => 1.0,
  };

  /// Speed multiplier for ambient/background animation.
  double get backgroundAnimationSpeed => switch (this) {
    AnimationQuality.low => 0.0,
    AnimationQuality.medium => 0.5,
    AnimationQuality.high => 1.0,
  };
}

/// Convenience bundles that change several performance settings at once.
enum PerformancePreset { smooth, balanced, showcase }

/// When the on-screen touch controls (joystick, dash, weapon-swap) are shown.
/// [auto] detects a mobile device via the platform / browser user-agent.
enum TouchControlsMode { auto, alwaysOn, alwaysOff }

/// Whether on-screen touch controls (and therefore forced auto-aim) are active
/// for [mode] on the current platform. Shared by the game loop and the settings
/// UI so they never disagree about whether the device is "touch".
bool touchControlsActiveFor(TouchControlsMode mode) {
  switch (mode) {
    case TouchControlsMode.alwaysOn:
      return true;
    case TouchControlsMode.alwaysOff:
      return false;
    case TouchControlsMode.auto:
      return defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android;
  }
}

/// How touch players change weapons: a dedicated cycle button, or tapping
/// the weapon chips directly.
enum WeaponSwapStyle { swapButton, tapWeapons }

/// Colorblind assist. When not [none], the three category colors are remapped
/// to a per-deficiency colorblind-safe triad (see theme/colorblind.dart) AND a
/// distinct category shape glyph is drawn on every mob and bullet, so the
/// match mechanic is readable by hue and by shape rather than hue alone. The
/// three modes are genuinely different remaps, not a single shared effect.
enum ColorblindMode { none, deuteranopia, protanopia, tritanopia }

/// Firing aim mode. [auto] targets the nearest matching-category enemy;
/// [manual] aims toward the mouse pointer (desktop opt-in skill ceiling).
enum AimMode { auto, manual }

/// Visual render style. [classic] is the procedural vector "blob" rendering
/// (the default, always available, and the fallback when a sprite is missing).
/// [sprites] is the experimental pixel-art sprite pack (assets/images/).
enum RenderStyle { classic, sprites }

/// Difficulty / assist level. Scales the damage enemies deal to the player so
/// the single fixed campaign curve fits a mixed-skill (kid) audience and
/// classroom use, without changing time-to-kill or the balance math.
/// [standard] is neutral (multiplier 1.0).
enum GameDifficulty {
  assist,
  standard,
  challenge;

  /// Multiplier applied to damage enemies/bosses deal to the player.
  double get enemyDamageMultiplier => switch (this) {
    GameDifficulty.assist => 0.6,
    GameDifficulty.standard => 1.0,
    GameDifficulty.challenge => 1.3,
  };

  String get label => switch (this) {
    GameDifficulty.assist => 'Assist',
    GameDifficulty.standard => 'Standard',
    GameDifficulty.challenge => 'Challenge',
  };

  String get blurb => switch (this) {
    GameDifficulty.assist =>
      'Enemies hit softer - good for younger or newer players.',
    GameDifficulty.standard => 'The intended balance.',
    GameDifficulty.challenge => 'Enemies hit harder.',
  };
}

/// All user-configurable performance/graphics/audio settings.
///
/// Persisted as JSON via [PersistenceService] under the `'settings'` key.
@immutable
class SettingsData {
  const SettingsData({
    this.particleDensity = ParticleDensity.medium,
    this.animationQuality = AnimationQuality.high,
    this.screenShakeEnabled = true,
    this.colorContrastBoost = 0.0,
    this.reduceMotion = false,
    this.musicVolume = 0.6,
    this.sfxVolume = 0.8,
    this.smartAimEnabled = false,
    this.touchControlsMode = TouchControlsMode.auto,
    this.weaponSwapStyle = WeaponSwapStyle.swapButton,
    this.colorblindMode = ColorblindMode.none,
    this.aimMode = AimMode.auto,
    this.textScale = 1.0,
    this.renderStyle = RenderStyle.classic,
    this.difficulty = GameDifficulty.standard,
    this.shapeLabels = true,
    this.muteAll = false,
    this.playtestLoggingEnabled = false,
    this.musicTrackId = defaultMusicTrackId,
  });

  /// The track the game plays out of the box (a calm, looping ambient piece).
  /// Replaces the old jarring theme. Empty string = music Off.
  static const String defaultMusicTrackId = 'music/bloodstream_drift.wav';

  final ParticleDensity particleDensity;
  final AnimationQuality animationQuality;
  final bool screenShakeEnabled;

  /// 0.0-1.0. Increases saturation/contrast for accessibility.
  final double colorContrastBoost;

  /// When true, disables blob wobble and ambient background animation.
  final bool reduceMotion;

  final double musicVolume;
  final double sfxVolume;

  /// Whether Smart Aim is active. Only has any effect once Smart Aim has been
  /// purchased ([SaveData.smartAimUnlocked]). Defaults OFF: it is an opt-in
  /// upgrade the player turns on from the Aiming settings AFTER unlocking it,
  /// not an automatic default.
  final bool smartAimEnabled;

  final TouchControlsMode touchControlsMode;
  final WeaponSwapStyle weaponSwapStyle;
  final ColorblindMode colorblindMode;
  final AimMode aimMode;

  /// 1.0-2.0 multiplier applied to all UI text via MediaQuery.textScaler.
  final double textScale;

  final RenderStyle renderStyle;

  /// Difficulty / assist level (scales the damage enemies deal to the player;
  /// does not change enemy health or time-to-kill).
  final GameDifficulty difficulty;

  /// When true, the category shape glyph (diamond/ring/triangle) is drawn on
  /// MOBS for EVERYONE - not only in colorblind mode - so the color=category
  /// match mechanic is readable by shape as well as hue. (Bullets additionally
  /// get a glyph only in colorblind mode, to avoid clutter on up to 180 live
  /// projectiles.) On by default; doubles as clarity for washed-out screens and
  /// undiagnosed colour-vision deficiency.
  final bool shapeLabels;

  /// One-tap master mute for all audio (music + SFX).
  final bool muteAll;

  /// When true, [PlaytestLogger] records gameplay events to on-device storage
  /// for a teacher/tester to export and review. Default OFF, no network: a
  /// shipped build collects nothing until a supervising adult enables it.
  final bool playtestLoggingEnabled;

  /// The currently selected jukebox music track, as a FlameAudio path under
  /// `assets/audio/` (e.g. `music/bloodstream_drift.wav`). Empty string means
  /// the player chose "Off" (no background music).
  final String musicTrackId;

  static const SettingsData defaults = SettingsData();

  SettingsData copyWith({
    ParticleDensity? particleDensity,
    AnimationQuality? animationQuality,
    bool? screenShakeEnabled,
    double? colorContrastBoost,
    bool? reduceMotion,
    double? musicVolume,
    double? sfxVolume,
    bool? smartAimEnabled,
    TouchControlsMode? touchControlsMode,
    WeaponSwapStyle? weaponSwapStyle,
    ColorblindMode? colorblindMode,
    AimMode? aimMode,
    double? textScale,
    RenderStyle? renderStyle,
    GameDifficulty? difficulty,
    bool? shapeLabels,
    bool? muteAll,
    bool? playtestLoggingEnabled,
    String? musicTrackId,
  }) {
    return SettingsData(
      particleDensity: particleDensity ?? this.particleDensity,
      animationQuality: animationQuality ?? this.animationQuality,
      screenShakeEnabled: screenShakeEnabled ?? this.screenShakeEnabled,
      colorContrastBoost: colorContrastBoost ?? this.colorContrastBoost,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      smartAimEnabled: smartAimEnabled ?? this.smartAimEnabled,
      touchControlsMode: touchControlsMode ?? this.touchControlsMode,
      weaponSwapStyle: weaponSwapStyle ?? this.weaponSwapStyle,
      colorblindMode: colorblindMode ?? this.colorblindMode,
      aimMode: aimMode ?? this.aimMode,
      textScale: textScale ?? this.textScale,
      renderStyle: renderStyle ?? this.renderStyle,
      difficulty: difficulty ?? this.difficulty,
      shapeLabels: shapeLabels ?? this.shapeLabels,
      muteAll: muteAll ?? this.muteAll,
      playtestLoggingEnabled:
          playtestLoggingEnabled ?? this.playtestLoggingEnabled,
      musicTrackId: musicTrackId ?? this.musicTrackId,
    );
  }

  Map<String, dynamic> toJson() => {
    'particleDensity': particleDensity.name,
    'animationQuality': animationQuality.name,
    'screenShakeEnabled': screenShakeEnabled,
    'colorContrastBoost': colorContrastBoost,
    'reduceMotion': reduceMotion,
    'musicVolume': musicVolume,
    'sfxVolume': sfxVolume,
    'smartAimEnabled': smartAimEnabled,
    'touchControlsMode': touchControlsMode.name,
    'weaponSwapStyle': weaponSwapStyle.name,
    'colorblindMode': colorblindMode.name,
    'aimMode': aimMode.name,
    'textScale': textScale,
    'renderStyle': renderStyle.name,
    'difficulty': difficulty.name,
    'shapeLabels': shapeLabels,
    'muteAll': muteAll,
    'playtestLoggingEnabled': playtestLoggingEnabled,
    'musicTrackId': musicTrackId,
  };

  SettingsData applyPerformancePreset(PerformancePreset preset) {
    return switch (preset) {
      PerformancePreset.smooth => copyWith(
        particleDensity: ParticleDensity.low,
        animationQuality: AnimationQuality.low,
        reduceMotion: true,
        screenShakeEnabled: false,
      ),
      PerformancePreset.balanced => copyWith(
        particleDensity: ParticleDensity.medium,
        animationQuality: AnimationQuality.medium,
        reduceMotion: false,
        screenShakeEnabled: true,
      ),
      PerformancePreset.showcase => copyWith(
        particleDensity: ParticleDensity.high,
        animationQuality: AnimationQuality.high,
        reduceMotion: false,
        screenShakeEnabled: true,
      ),
    };
  }

  PerformancePreset get closestPerformancePreset {
    if (particleDensity == ParticleDensity.low &&
        animationQuality == AnimationQuality.low &&
        reduceMotion &&
        !screenShakeEnabled) {
      return PerformancePreset.smooth;
    }
    if (particleDensity == ParticleDensity.high &&
        animationQuality == AnimationQuality.high &&
        !reduceMotion &&
        screenShakeEnabled) {
      return PerformancePreset.showcase;
    }
    return PerformancePreset.balanced;
  }

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      particleDensity: ParticleDensity.values.firstWhere(
        (e) => e.name == json['particleDensity'],
        orElse: () => ParticleDensity.medium,
      ),
      animationQuality: AnimationQuality.values.firstWhere(
        (e) => e.name == json['animationQuality'],
        orElse: () => AnimationQuality.high,
      ),
      screenShakeEnabled: _boolSetting(json['screenShakeEnabled'], true),
      colorContrastBoost: _doubleSetting(
        json['colorContrastBoost'],
        fallback: 0.0,
        min: 0.0,
        max: 1.0,
      ),
      reduceMotion: _boolSetting(json['reduceMotion'], false),
      musicVolume: _doubleSetting(
        json['musicVolume'],
        fallback: 0.6,
        min: 0.0,
        max: 1.0,
      ),
      sfxVolume: _doubleSetting(
        json['sfxVolume'],
        fallback: 0.8,
        min: 0.0,
        max: 1.0,
      ),
      smartAimEnabled: _boolSetting(json['smartAimEnabled'], false),
      touchControlsMode: TouchControlsMode.values.firstWhere(
        (e) => e.name == json['touchControlsMode'],
        orElse: () => TouchControlsMode.auto,
      ),
      weaponSwapStyle: WeaponSwapStyle.values.firstWhere(
        (e) => e.name == json['weaponSwapStyle'],
        orElse: () => WeaponSwapStyle.swapButton,
      ),
      colorblindMode: ColorblindMode.values.firstWhere(
        (e) => e.name == json['colorblindMode'],
        orElse: () => ColorblindMode.none,
      ),
      aimMode: AimMode.values.firstWhere(
        (e) => e.name == json['aimMode'],
        orElse: () => AimMode.auto,
      ),
      textScale: _doubleSetting(
        json['textScale'],
        fallback: 1.0,
        min: 1.0,
        max: 2.0,
      ),
      renderStyle: RenderStyle.values.firstWhere(
        (e) => e.name == json['renderStyle'],
        orElse: () => RenderStyle.classic,
      ),
      difficulty: GameDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => GameDifficulty.standard,
      ),
      shapeLabels: _boolSetting(json['shapeLabels'], true),
      muteAll: _boolSetting(json['muteAll'], false),
      playtestLoggingEnabled: _boolSetting(
        json['playtestLoggingEnabled'],
        false,
      ),
      musicTrackId: _stringSetting(
        json['musicTrackId'],
        SettingsData.defaultMusicTrackId,
      ),
    );
  }
}

bool _boolSetting(Object? value, bool fallback) {
  return value is bool ? value : fallback;
}

String _stringSetting(Object? value, String fallback) {
  return value is String ? value : fallback;
}

double _doubleSetting(
  Object? value, {
  required double fallback,
  required double min,
  required double max,
}) {
  final number = switch (value) {
    num() => value.toDouble(),
    String() => double.tryParse(value),
    _ => null,
  };
  return (number ?? fallback).clamp(min, max).toDouble();
}

/// Live, app-wide access point for [SettingsData].
///
/// Components read [SettingsService.instance.value] directly (it's a
/// [ValueNotifier], so widgets/components can also listen for live
/// updates), and call [update] to change + persist settings.
class SettingsService extends ValueNotifier<SettingsData> {
  SettingsService._(super.initial);

  /// Created eagerly with defaults so it is safe to read/listen to before
  /// [init] runs (e.g. the app-wide text-scale wrapper during loading);
  /// [init] then loads the persisted values into it.
  static final SettingsService instance = SettingsService._(
    SettingsData.defaults,
  );

  static Future<SettingsService> init(PersistenceService persistence) async {
    instance.value = persistence.saveData.settings;
    instance._persistence = persistence;
    return instance;
  }

  late PersistenceService _persistence;

  Future<void> update(
    SettingsData Function(SettingsData current) updater,
  ) async {
    value = updater(value);
    await _persistence.updateSaveData((save) => save.copyWith(settings: value));
  }
}
