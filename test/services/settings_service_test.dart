import 'package:flutter_test/flutter_test.dart';

import 'package:pdac_immune_defense/services/settings_service.dart';

void main() {
  test('performance presets update the expected settings', () {
    final smooth = SettingsData.defaults.applyPerformancePreset(
      PerformancePreset.smooth,
    );
    expect(smooth.particleDensity, ParticleDensity.low);
    expect(smooth.animationQuality, AnimationQuality.low);
    expect(smooth.reduceMotion, isTrue);
    expect(smooth.screenShakeEnabled, isFalse);
    expect(smooth.closestPerformancePreset, PerformancePreset.smooth);

    final balanced = SettingsData.defaults.applyPerformancePreset(
      PerformancePreset.balanced,
    );
    expect(balanced.particleDensity, ParticleDensity.medium);
    expect(balanced.animationQuality, AnimationQuality.medium);
    expect(balanced.reduceMotion, isFalse);
    expect(balanced.screenShakeEnabled, isTrue);
    expect(balanced.closestPerformancePreset, PerformancePreset.balanced);

    final showcase = SettingsData.defaults.applyPerformancePreset(
      PerformancePreset.showcase,
    );
    expect(showcase.particleDensity, ParticleDensity.high);
    expect(showcase.animationQuality, AnimationQuality.high);
    expect(showcase.reduceMotion, isFalse);
    expect(showcase.screenShakeEnabled, isTrue);
    expect(showcase.closestPerformancePreset, PerformancePreset.showcase);
  });

  test('control + accessibility settings round-trip through json', () {
    const data = SettingsData(
      touchControlsMode: TouchControlsMode.alwaysOn,
      weaponSwapStyle: WeaponSwapStyle.tapWeapons,
      colorblindMode: ColorblindMode.deuteranopia,
      aimMode: AimMode.manual,
      textScale: 1.5,
      renderStyle: RenderStyle.sprites,
      playtestLoggingEnabled: true,
      musicTrackId: 'music/deep_current.wav',
    );
    final restored = SettingsData.fromJson(data.toJson());
    expect(restored.touchControlsMode, TouchControlsMode.alwaysOn);
    expect(restored.weaponSwapStyle, WeaponSwapStyle.tapWeapons);
    expect(restored.colorblindMode, ColorblindMode.deuteranopia);
    expect(restored.aimMode, AimMode.manual);
    expect(restored.textScale, 1.5);
    expect(restored.renderStyle, RenderStyle.sprites);
    expect(restored.playtestLoggingEnabled, isTrue);
    expect(restored.musicTrackId, 'music/deep_current.wav');
  });

  test('musicTrackId defaults to the calm track when missing/invalid', () {
    expect(SettingsData.fromJson({}).musicTrackId,
        SettingsData.defaultMusicTrackId);
    expect(SettingsData.fromJson({'musicTrackId': 42}).musicTrackId,
        SettingsData.defaultMusicTrackId);
    // Empty string is a valid value ("Off"), so it is preserved.
    expect(SettingsData.fromJson({'musicTrackId': ''}).musicTrackId, '');
  });

  test('unknown/invalid new settings fall back to safe defaults', () {
    final restored = SettingsData.fromJson({
      'touchControlsMode': 'bogus',
      'weaponSwapStyle': 'bogus',
      'colorblindMode': 'bogus',
      'aimMode': 'bogus',
      'textScale': 9.0,
    });
    expect(restored.touchControlsMode, TouchControlsMode.auto);
    expect(restored.weaponSwapStyle, WeaponSwapStyle.swapButton);
    expect(restored.colorblindMode, ColorblindMode.none);
    expect(restored.aimMode, AimMode.auto);
    expect(restored.textScale, 2.0); // clamped from out-of-range 9.0
  });

  test('numeric accessibility and audio settings are clamped safely', () {
    final restored = SettingsData.fromJson({
      'colorContrastBoost': 3.5,
      'musicVolume': -2.0,
      'sfxVolume': '0.25',
      'textScale': '1.75',
      'screenShakeEnabled': 'not a bool',
      'muteAll': 'not a bool',
    });

    expect(restored.colorContrastBoost, 1.0);
    expect(restored.musicVolume, 0.0);
    expect(restored.sfxVolume, 0.25);
    expect(restored.textScale, 1.75);
    expect(restored.screenShakeEnabled, isTrue);
    expect(restored.muteAll, isFalse);
  });
}
