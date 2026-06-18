import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/persistence_service.dart';
import '../../services/playtest_logger.dart';
import '../../services/settings_service.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'disclaimer_screen.dart';
import 'game_screen.dart';

/// Performance, graphics, accessibility, and audio settings. Reads/writes
/// [SettingsService.instance] so changes apply live without restarting.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.backgroundDeep,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppPalette.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: ValueListenableBuilder<SettingsData>(
                valueListenable: SettingsService.instance,
                builder: (context, settings, _) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    children: [
                      _Header(
                        onBack: () => Navigator.of(context).pop(),
                        preset: settings.closestPerformancePreset,
                      ),
                      const SizedBox(height: 18),
                      _SettingsPanel(
                        title: 'Performance Preset',
                        icon: Icons.tune,
                        accent: AppPalette.gold,
                        child: _PresetGrid(settings: settings),
                      ),
                      const SizedBox(height: 14),
                      _SettingsPanel(
                        title: 'Gameplay',
                        icon: Icons.sports_martial_arts,
                        // Gold, not alarm-red: a benign section header shouldn't
                        // read as a danger signal (red is reserved for HP/boss).
                        accent: AppPalette.gold,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _EnumSetting<GameDifficulty>(
                              label: 'Difficulty',
                              value: settings.difficulty,
                              values: GameDifficulty.values,
                              labelOf: difficultyLabel,
                              onChanged: (value) => SettingsService.instance
                                  .update((s) => s.copyWith(difficulty: value)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              settings.difficulty.blurb,
                              style: AppTypography.label,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SettingsPanel(
                        title: 'Graphics',
                        icon: Icons.auto_awesome,
                        accent: AppPalette.playerCore,
                        child: Column(
                          children: [
                            _EnumSetting<ParticleDensity>(
                              label: 'Particles',
                              value: settings.particleDensity,
                              values: ParticleDensity.values,
                              labelOf: particleDensityLabel,
                              onChanged: (value) =>
                                  SettingsService.instance.update(
                                    (s) => s.copyWith(particleDensity: value),
                                  ),
                            ),
                            _DividerLine(),
                            _EnumSetting<AnimationQuality>(
                              label: 'Animation Quality',
                              value: settings.animationQuality,
                              values: AnimationQuality.values,
                              labelOf: animationQualityLabel,
                              onChanged: (value) =>
                                  SettingsService.instance.update(
                                    (s) => s.copyWith(animationQuality: value),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SettingsPanel(
                        title: 'Accessibility',
                        icon: Icons.visibility,
                        accent: AppPalette.healthGood,
                        child: Column(
                          children: [
                            _SwitchSetting(
                              label: 'Reduce Motion',
                              icon: Icons.motion_photos_off,
                              value: settings.reduceMotion,
                              onChanged: (value) =>
                                  SettingsService.instance.update(
                                    (s) => s.copyWith(reduceMotion: value),
                                  ),
                            ),
                            _DividerLine(),
                            _SwitchSetting(
                              label: 'Screen Shake',
                              icon: Icons.vibration,
                              value: settings.screenShakeEnabled,
                              onChanged: (value) =>
                                  SettingsService.instance.update(
                                    (s) =>
                                        s.copyWith(screenShakeEnabled: value),
                                  ),
                            ),
                            _DividerLine(),
                            _SliderSetting(
                              label: 'Contrast Boost',
                              icon: Icons.contrast,
                              value: settings.colorContrastBoost,
                              onChanged: (value) =>
                                  SettingsService.instance.update(
                                    (s) =>
                                        s.copyWith(colorContrastBoost: value),
                                  ),
                            ),
                            _DividerLine(),
                            _EnumSetting<ColorblindMode>(
                              label: 'Colorblind Assist',
                              value: settings.colorblindMode,
                              values: ColorblindMode.values,
                              labelOf: colorblindModeLabel,
                              onChanged: (value) =>
                                  SettingsService.instance.update(
                                    (s) => s.copyWith(colorblindMode: value),
                                  ),
                            ),
                            _DividerLine(),
                            _SwitchSetting(
                              label: 'Shape Labels',
                              icon: Icons.category,
                              value: settings.shapeLabels,
                              onChanged: (value) =>
                                  SettingsService.instance.update(
                                    (s) => s.copyWith(shapeLabels: value),
                                  ),
                            ),
                            _DividerLine(),
                            _SliderSetting(
                              label: 'Larger Text',
                              icon: Icons.format_size,
                              value: settings.textScale - 1.0,
                              onChanged: (value) =>
                                  SettingsService.instance.update(
                                    (s) => s.copyWith(textScale: 1.0 + value),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SettingsPanel(
                        title: 'Controls',
                        icon: Icons.sports_esports,
                        accent: AppPalette.playerCore,
                        child: Column(
                          children: [
                            _EnumSetting<TouchControlsMode>(
                              label: 'Touch Controls',
                              value: settings.touchControlsMode,
                              values: TouchControlsMode.values,
                              labelOf: touchControlsModeLabel,
                              onChanged: (value) =>
                                  SettingsService.instance.update(
                                    (s) => s.copyWith(touchControlsMode: value),
                                  ),
                            ),
                            _DividerLine(),
                            _EnumSetting<WeaponSwapStyle>(
                              label: 'Mobile Weapon Swap',
                              value: settings.weaponSwapStyle,
                              values: WeaponSwapStyle.values,
                              labelOf: weaponSwapStyleLabel,
                              onChanged: (value) =>
                                  SettingsService.instance.update(
                                    (s) => s.copyWith(weaponSwapStyle: value),
                                  ),
                            ),
                            // Aim mode only matters on desktop; touch devices
                            // always use auto-aim, so hide this inert toggle
                            // there (matching how Smart Aim is gated) rather
                            // than showing a control that does nothing.
                            if (!touchControlsActiveFor(
                              settings.touchControlsMode,
                            )) ...[
                              _DividerLine(),
                              _EnumSetting<AimMode>(
                                label: 'Aim (desktop)',
                                value: settings.aimMode,
                                values: AimMode.values,
                                labelOf: aimModeLabel,
                                onChanged: (value) => SettingsService.instance
                                    .update((s) => s.copyWith(aimMode: value)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SettingsPanel(
                        title: 'Experimental',
                        icon: Icons.science,
                        accent: AppPalette.antibodyColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _EnumSetting<RenderStyle>(
                              label: 'Render Style',
                              value: settings.renderStyle,
                              values: RenderStyle.values,
                              labelOf: renderStyleLabel,
                              onChanged: (value) =>
                                  SettingsService.instance.update(
                                    (s) => s.copyWith(renderStyle: value),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sprites swap the procedural cells for an '
                              'experimental pixel-art pack. Classic is the '
                              'default and always available.',
                              style: AppTypography.label,
                            ),
                          ],
                        ),
                      ),
                      if (PersistenceService
                          .instance
                          .saveData
                          .smartAimUnlocked) ...[
                        const SizedBox(height: 14),
                        _SettingsPanel(
                          title: 'Aiming',
                          icon: Icons.my_location,
                          accent: AppPalette.playerCore,
                          child: _SwitchSetting(
                            label: 'Smart Aim',
                            icon: Icons.my_location,
                            value: settings.smartAimEnabled,
                            onChanged: (value) =>
                                SettingsService.instance.update(
                                  (s) => s.copyWith(smartAimEnabled: value),
                                ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      _SettingsPanel(
                        title: 'Audio',
                        icon: Icons.volume_up,
                        accent: AppPalette.antibodyColor,
                        child: Column(
                          children: [
                            _SwitchSetting(
                              label: 'Mute All',
                              icon: Icons.volume_off,
                              value: settings.muteAll,
                              onChanged: (value) => SettingsService.instance
                                  .update((s) => s.copyWith(muteAll: value)),
                            ),
                            _DividerLine(),
                            _SliderSetting(
                              label: 'Music',
                              icon: Icons.music_note,
                              value: settings.musicVolume,
                              onChanged: (value) =>
                                  SettingsService.instance.update(
                                    (s) => s.copyWith(musicVolume: value),
                                  ),
                            ),
                            _DividerLine(),
                            _SliderSetting(
                              label: 'Sound Effects',
                              icon: Icons.graphic_eq,
                              value: settings.sfxVolume,
                              onChanged: (value) => SettingsService.instance
                                  .update((s) => s.copyWith(sfxVolume: value)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SettingsPanel(
                        title: 'Help',
                        icon: Icons.school,
                        accent: AppPalette.cytotoxicColor,
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _ActionButton(
                              label: 'Replay Tutorial',
                              icon: Icons.school,
                              color: AppPalette.playerCore,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => GameScreen(
                                    persistence: PersistenceService.instance,
                                    tutorial: true,
                                  ),
                                ),
                              ),
                            ),
                            _ActionButton(
                              label: 'Restore Defaults',
                              icon: Icons.restart_alt,
                              color: AppPalette.gold,
                              onPressed: () => SettingsService.instance.update(
                                (_) => SettingsData.defaults,
                              ),
                            ),
                            _ActionButton(
                              label: 'About & Safety',
                              icon: Icons.info_outline,
                              color: AppPalette.textSecondary,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const DisclaimerScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _PlaytestPanel(
                        enabled: settings.playtestLoggingEnabled,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.preset});

  final VoidCallback onBack;
  final PerformancePreset preset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: AppPalette.surface.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(8),
          child: IconButton(
            tooltip: 'Back',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppPalette.textPrimary),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppTypography.displayMedium),
              const SizedBox(height: 4),
              Text(
                '${performancePresetLabel(preset)} profile active',
                style: AppTypography.label.copyWith(
                  color: AppPalette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.title,
    required this.icon,
    required this.accent,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.surfaceLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accent, size: 20),
                const SizedBox(width: 9),
                Text(title, style: AppTypography.bodyStrong),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _PresetGrid extends StatelessWidget {
  const _PresetGrid({required this.settings});

  final SettingsData settings;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;
        final spacing = 10.0;
        final width = isWide
            ? (constraints.maxWidth - spacing * 2) / 3
            : constraints.maxWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final preset in PerformancePreset.values)
              SizedBox(
                width: width,
                child: _PresetButton(
                  preset: preset,
                  selected: settings.closestPerformancePreset == preset,
                  onPressed: () => SettingsService.instance.update(
                    (s) => s.applyPerformancePreset(preset),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.preset,
    required this.selected,
    required this.onPressed,
  });

  final PerformancePreset preset;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = switch (preset) {
      PerformancePreset.smooth => AppPalette.healthGood,
      PerformancePreset.balanced => AppPalette.playerCore,
      PerformancePreset.showcase => AppPalette.gold,
    };

    return Material(
      color: selected
          ? color.withValues(alpha: 0.18)
          : AppPalette.backgroundDeep.withValues(alpha: 0.44),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: 94),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: selected ? 0.92 : 0.38),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(performancePresetIcon(preset), color: color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      performancePresetLabel(preset),
                      style: AppTypography.bodyStrong,
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle,
                      color: AppPalette.healthGood,
                      size: 18,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                performancePresetDescription(preset),
                style: AppTypography.label.copyWith(
                  color: AppPalette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchSetting extends StatelessWidget {
  const _SwitchSetting({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppPalette.textSecondary, size: 19),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppTypography.bodyStrong)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppPalette.playerCore,
        ),
      ],
    );
  }
}

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 520;
        final header = Row(
          children: [
            Icon(icon, color: AppPalette.textSecondary, size: 19),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: AppTypography.bodyStrong)),
            Text(percentLabel(value), style: AppTypography.label),
          ],
        );

        final slider = Slider(
          value: value.clamp(0.0, 1.0),
          onChanged: onChanged,
          activeColor: AppPalette.playerCore,
          inactiveColor: AppPalette.surfaceLight,
        );

        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [header, slider],
          );
        }

        return Row(
          children: [
            SizedBox(width: 210, child: header),
            Expanded(child: slider),
          ],
        );
      },
    );
  }
}

class _EnumSetting<T extends Enum> extends StatelessWidget {
  const _EnumSetting({
    required this.label,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 520;
        final labelWidget = Text(label, style: AppTypography.bodyStrong);
        final controls = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in values)
              ChoiceChip(
                label: Text(labelOf(option)),
                selected: option == value,
                onSelected: (_) => onChanged(option),
                selectedColor: AppPalette.playerCore.withValues(alpha: 0.28),
                backgroundColor: AppPalette.backgroundDeep.withValues(
                  alpha: 0.46,
                ),
                side: BorderSide(
                  color: option == value
                      ? AppPalette.playerCore
                      : AppPalette.surfaceLight,
                ),
                labelStyle: AppTypography.label.copyWith(
                  color: option == value
                      ? AppPalette.textPrimary
                      : AppPalette.textSecondary,
                ),
              ),
          ],
        );

        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [labelWidget, const SizedBox(height: 10), controls],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 210, child: labelWidget),
            Expanded(child: controls),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.13),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minWidth: 176, minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.68)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 19),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.button.copyWith(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        color: AppPalette.surfaceLight.withValues(alpha: 0.8),
      ),
    );
  }
}

/// Teacher/tester-facing controls for the local playtest log: an opt-in toggle
/// plus copy/clear of the recorded data. Local-only - the data never leaves the
/// device unless someone copies it out. Stateful so the summary line and button
/// availability refresh after a clear without rebuilding the whole screen.
class _PlaytestPanel extends StatefulWidget {
  const _PlaytestPanel({required this.enabled});

  final bool enabled;

  @override
  State<_PlaytestPanel> createState() => _PlaytestPanelState();
}

class _PlaytestPanelState extends State<_PlaytestPanel> {
  @override
  Widget build(BuildContext context) {
    final summary = PlaytestLogger.instance.summary();
    final hasData = summary.eventCount > 0;
    return _SettingsPanel(
      title: 'Playtest / Research',
      icon: Icons.insights,
      accent: AppPalette.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SwitchSetting(
            label: 'Playtest Logging',
            icon: Icons.fact_check,
            value: widget.enabled,
            onChanged: (value) => SettingsService.instance.update(
              (s) => s.copyWith(playtestLoggingEnabled: value),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Records gameplay events (rounds reached, deaths, quiz answers, '
            'weapon swaps) on THIS DEVICE only - nothing is sent anywhere. '
            'For teachers and testers: turn it on, hand the device to a player, '
            'then Copy the data afterwards to see what happened. Off by default.',
            style: AppTypography.label,
          ),
          _DividerLine(),
          Text(
            hasData
                ? '${summary.sessionCount} session(s), ${summary.eventCount} '
                      'events - furthest round ${summary.furthestRound}, '
                      '${summary.deaths} death(s), quiz '
                      '${summary.quizAccuracyLabel}.'
                : 'No events recorded yet.',
            style: AppTypography.label,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionButton(
                label: 'Copy Playtest Data',
                icon: Icons.copy_all,
                color: AppPalette.playerCore,
                onPressed: () => _copy(summary, hasData),
              ),
              _ActionButton(
                label: 'Clear Playtest Data',
                icon: Icons.delete_outline,
                color: AppPalette.textSecondary,
                onPressed: hasData ? _clear : _nothingToClear,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copy(PlaytestSummary summary, bool hasData) async {
    if (!hasData) {
      _snack('No playtest data to copy yet.');
      return;
    }
    final json = PlaytestLogger.instance.exportJson();
    await Clipboard.setData(ClipboardData(text: json));
    // Also dump to the dev/browser console so the data is grabbable on web
    // even where clipboard access is restricted.
    debugPrint(json);
    if (!mounted) return;
    _snack(
      'Copied ${summary.sessionCount} session(s) / ${summary.eventCount} '
      'events to the clipboard.',
    );
  }

  void _clear() {
    PlaytestLogger.instance.clear();
    setState(() {});
    _snack('Playtest data cleared.');
  }

  void _nothingToClear() => _snack('No playtest data to clear.');

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

String performancePresetLabel(PerformancePreset preset) => switch (preset) {
  PerformancePreset.smooth => 'Smooth',
  PerformancePreset.balanced => 'Balanced',
  PerformancePreset.showcase => 'Showcase',
};

String performancePresetDescription(PerformancePreset preset) =>
    switch (preset) {
      PerformancePreset.smooth => 'Stable play on slower devices',
      PerformancePreset.balanced => 'Good effects with safer frame pacing',
      PerformancePreset.showcase => 'Full effects for stronger devices',
    };

IconData performancePresetIcon(PerformancePreset preset) => switch (preset) {
  PerformancePreset.smooth => Icons.speed,
  PerformancePreset.balanced => Icons.balance,
  PerformancePreset.showcase => Icons.auto_awesome,
};

String particleDensityLabel(ParticleDensity density) => switch (density) {
  ParticleDensity.off => 'Off',
  ParticleDensity.low => 'Low',
  ParticleDensity.medium => 'Medium',
  ParticleDensity.high => 'High',
};

String animationQualityLabel(AnimationQuality quality) => switch (quality) {
  AnimationQuality.low => 'Low',
  AnimationQuality.medium => 'Medium',
  AnimationQuality.high => 'High',
};

String touchControlsModeLabel(TouchControlsMode mode) => switch (mode) {
  TouchControlsMode.auto => 'Auto',
  TouchControlsMode.alwaysOn => 'On',
  TouchControlsMode.alwaysOff => 'Off',
};

String weaponSwapStyleLabel(WeaponSwapStyle style) => switch (style) {
  WeaponSwapStyle.swapButton => 'Swap Button',
  WeaponSwapStyle.tapWeapons => 'Tap Weapons',
};

String aimModeLabel(AimMode mode) => switch (mode) {
  AimMode.auto => 'Auto',
  AimMode.manual => 'Mouse',
};

String colorblindModeLabel(ColorblindMode mode) => switch (mode) {
  ColorblindMode.none => 'Off',
  ColorblindMode.deuteranopia => 'Deuteran',
  ColorblindMode.protanopia => 'Protan',
  ColorblindMode.tritanopia => 'Tritan',
};

String renderStyleLabel(RenderStyle style) => switch (style) {
  RenderStyle.classic => 'Classic',
  RenderStyle.sprites => 'Sprites',
};

String difficultyLabel(GameDifficulty difficulty) => difficulty.label;

String percentLabel(double value) =>
    '${(value.clamp(0.0, 1.0) * 100).round()}%';
