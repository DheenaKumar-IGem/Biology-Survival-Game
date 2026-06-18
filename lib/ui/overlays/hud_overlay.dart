import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../data/weapons/weapon_catalog.dart';
import '../../game/pdac_game.dart';
import '../../game/systems/gameplay_safe_area.dart';
import '../../services/settings_service.dart';
import '../../theme/category_glyph.dart';
import '../../theme/colorblind.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import '../widgets/pressable_action.dart';
import '../widgets/stat_bar.dart';

/// Always-on gameplay HUD: player HP, current round + kill progress,
/// persistent gold, and the equipped-weapon indicator (switch with Q/Tab).
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final PdacGame game;

  @override
  Widget build(BuildContext context) {
    final availableWidth = MediaQuery.sizeOf(context).width - 24;
    final clusterMaxWidth = availableWidth <= 0
        ? topLeftHudBlockWidth - 24
        : availableWidth.clamp(220.0, topLeftHudBlockWidth - 24).toDouble();
    final controlsWidth = (clusterMaxWidth - 216).clamp(144.0, 216.0);

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: clusterMaxWidth),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    _StatusPanel(game: game),
                    SizedBox(
                      width: controlsWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _WeaponSwitcher(game: game),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _GoldChip(game: game),
                              _PauseButton(game: game),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 24,
          bottom: 24,
          child: SafeArea(
            child: ValueListenableBuilder<SettingsData>(
              valueListenable: SettingsService.instance,
              builder: (context, settings, _) {
                // Touch controls (dash + swap button) show only on touch
                // devices; desktop dashes via Space/Shift and swaps via Q/Tab.
                if (!game.touchControlsEnabled) return const SizedBox.shrink();
                final showSwap =
                    settings.weaponSwapStyle == WeaponSwapStyle.swapButton;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showSwap) ...[
                      _SwapButton(game: game),
                      const SizedBox(width: 12),
                    ],
                    _DashButton(game: game),
                  ],
                );
              },
            ),
          ),
        ),
        Positioned(
          // Above the dash/swap buttons on the right, clear of the bottom-left
          // joystick it used to overlap.
          right: 24,
          bottom: 96,
          child: SafeArea(child: _PerformancePanel(game: game)),
        ),
      ],
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.game});

  final PdacGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppPalette.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!game.tutorial)
            ValueListenableBuilder<int>(
              valueListenable: game.hud.round,
              builder: (context, round, _) {
                return Text('Round $round / 9', style: AppTypography.label);
              },
            ),
          ValueListenableBuilder<String?>(
            valueListenable: game.hud.biomeName,
            builder: (context, biome, _) {
              if (biome == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.place,
                      size: 12,
                      color: AppPalette.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        biome,
                        style: AppTypography.label.copyWith(
                          color: AppPalette.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          ValueListenableBuilder<double>(
            valueListenable: game.hud.hp,
            builder: (context, hp, _) {
              return ValueListenableBuilder<double>(
                valueListenable: game.hud.maxHp,
                builder: (context, maxHp, _) {
                  return SizedBox(
                    width: 180,
                    child: StatBar.health(
                      maxHp == 0 ? 0 : hp / maxHp,
                      label: 'HP',
                    ),
                  );
                },
              );
            },
          ),
          if (!game.tutorial) ...[
            const SizedBox(height: 6),
            ValueListenableBuilder<double>(
              valueListenable: game.hud.roundProgress,
              builder: (context, progress, _) {
                return SizedBox(
                  width: 180,
                  child: StatBar(
                    value: progress,
                    color: AppPalette.playerCore,
                    label: 'Round progress',
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 6),
          _EnemiesRemaining(game: game),
          _BossHealthBar(game: game),
        ],
      ),
    );
  }
}

/// Shows the active boss's name and health bar (rounds 3, 6, 9). Hidden
/// when no boss is active.
class _BossHealthBar extends StatelessWidget {
  const _BossHealthBar({required this.game});

  final PdacGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: game.hud.bossName,
      builder: (context, name, _) {
        if (name == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: ValueListenableBuilder<double?>(
            valueListenable: game.hud.bossHealthFraction,
            builder: (context, fraction, _) {
              return SizedBox(
                width: 180,
                child: StatBar(
                  value: fraction ?? 1.0,
                  color: AppPalette.healthLow,
                  label: name,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// A small "germs remaining" readout under the round-progress bar. Once all
/// waves have spawned it switches to a highlighted call-to-action so the
/// player knows the round isn't stuck - there are just stragglers (e.g.
/// tiny mitosis-split viruses) left to mop up.
class _EnemiesRemaining extends StatelessWidget {
  const _EnemiesRemaining({required this.game});

  final PdacGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.hud.enemiesRemaining,
      builder: (context, remaining, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: game.hud.allWavesSpawned,
          builder: (context, allSpawned, _) {
            final mopUp = allSpawned && remaining > 0;
            final color = mopUp ? AppPalette.gold : AppPalette.textSecondary;
            final label = remaining == 0
                ? 'Arena clear!'
                : mopUp
                ? 'Last threats: $remaining - clear them to advance!'
                : '$remaining threat${remaining == 1 ? '' : 's'} active';
            return Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(Icons.coronavirus, color: color, size: 14),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: AppTypography.label.copyWith(color: color),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _WeaponSwitcher extends StatelessWidget {
  const _WeaponSwitcher({required this.game});

  final PdacGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppPalette.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ValueListenableBuilder<SettingsData>(
        valueListenable: SettingsService.instance,
        builder: (context, settings, _) {
          final touch = game.touchControlsEnabled;
          final tappable =
              touch && settings.weaponSwapStyle == WeaponSwapStyle.tapWeapons;
          return ValueListenableBuilder<List<String>>(
            valueListenable: game.hud.ownedWeapons,
            builder: (context, weapons, _) {
              return ValueListenableBuilder<int>(
                valueListenable: game.hud.equippedWeaponIndex,
                builder: (context, equippedIndex, _) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < weapons.length; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        _WeaponChip(
                          weaponId: weapons[i],
                          equipped: i == equippedIndex,
                          index: i,
                          game: game,
                          tappable: tappable,
                        ),
                      ],
                      // The "Q" hint is keyboard-only; hide it on touch.
                      if (!touch) ...[
                        const SizedBox(width: 7),
                        Text('Q', style: AppTypography.label),
                      ],
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _WeaponChip extends StatelessWidget {
  const _WeaponChip({
    required this.weaponId,
    required this.equipped,
    required this.index,
    required this.game,
    required this.tappable,
  });

  final String weaponId;
  final bool equipped;
  final int index;
  final PdacGame game;
  final bool tappable;

  @override
  Widget build(BuildContext context) {
    final def = WeaponCatalog.all[weaponId];
    if (def == null) return const SizedBox.shrink();
    final color = categoryDisplayColor(def.category);
    // [heat] (0-1) is the equipped weapon's progress toward a resistance
    // warning from wrong-color hits; the border lerps toward the resistance
    // color and gains a glow as it climbs, so the full banner never feels
    // out of nowhere. Static intensity (no pulse) keeps it reduce-motion safe.
    Widget buildChip(double heat) {
      return Container(
        // 52x50 keeps the tap target at the ~48px minimum while still fitting
        // three chips (+ the "Q" hint) inside the 192px switcher slot - larger
        // sizes overflow the Row and paint Flutter's debug stripe.
        width: 52,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: equipped ? color.withValues(alpha: 0.22) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color.lerp(
              color.withValues(alpha: equipped ? 0.95 : 0.36),
              AppPalette.mutationRing,
              heat * 0.85,
            )!,
            width: (equipped ? 1.5 : 1.0) + heat,
          ),
          boxShadow: heat > 0.05
              ? [
                  BoxShadow(
                    color: AppPalette.mutationRing.withValues(
                      alpha: 0.45 * heat,
                    ),
                    blurRadius: 5 + 9 * heat,
                    spreadRadius: heat,
                  ),
                ]
              : const [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryGlyph(category: def.category, color: color, size: 16),
            const SizedBox(height: 3),
            Text(
              def.displayName,
              style: AppTypography.label.copyWith(
                color: AppPalette.textPrimary,
                fontSize: 10,
                height: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    // Only the equipped chip reflects heat (the notifier tracks the equipped
    // weapon); others build at heat 0.
    final chip = equipped
        ? ValueListenableBuilder<double>(
            valueListenable: game.hud.equippedWeaponHeat,
            builder: (context, heat, _) => buildChip(heat),
          )
        : buildChip(0);
    final content = tappable
        ? PressableAction(
            onPressed: () => game.selectWeapon(index),
            semanticLabel:
                '${equipped ? 'Equipped weapon' : 'Equip weapon'}: '
                '${def.displayName}, ${def.category.shortLabel}',
            semanticValue: equipped ? 'Equipped' : 'Not equipped',
            semanticHint: 'Selects this weapon',
            selected: equipped,
            builder:
                (
                  context, {
                  required enabled,
                  required pressed,
                  required focused,
                  required hovered,
                }) {
                  return AnimatedScale(
                    scale: pressed ? 0.96 : 1,
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOutCubic,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: focused
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.42),
                                  blurRadius: 12,
                                ),
                              ]
                            : const [],
                      ),
                      child: chip,
                    ),
                  );
                },
          )
        : Semantics(
            button: false,
            selected: equipped,
            label:
                '${equipped ? 'Equipped weapon' : 'Weapon'}: '
                '${def.displayName}, ${def.category.shortLabel}',
            value: equipped ? 'Equipped' : 'Not equipped',
            child: chip,
          );
    return Tooltip(
      message: '${def.displayName} - ${def.category.shortLabel}',
      child: content,
    );
  }
}

/// Touch-only circular button that cycles the equipped weapon (the default
/// mobile weapon-swap style). Mirrors [_DashButton]'s placement/feel.
class _SwapButton extends StatelessWidget {
  const _SwapButton({required this.game});

  final PdacGame game;

  @override
  Widget build(BuildContext context) {
    return _CaptionedControl(
      caption: 'Swap',
      child: Tooltip(
        message: 'Swap weapon',
        child: PressableAction(
          onPressed: game.cycleWeapon,
          semanticLabel: 'Swap weapon',
          semanticHint: 'Cycles to the next equipped weapon',
          builder:
              (
                context, {
                required enabled,
                required pressed,
                required focused,
                required hovered,
              }) {
                return AnimatedScale(
                  scale: pressed ? 0.95 : 1,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOutCubic,
                  child: _HudCircleActionSurface(
                    color: AppPalette.surface.withValues(
                      alpha: focused || hovered ? 0.95 : 0.85,
                    ),
                    focusColor: AppPalette.playerCore,
                    focused: focused,
                    child: const Icon(
                      Icons.swap_horiz,
                      color: AppPalette.textPrimary,
                      size: 26,
                    ),
                  ),
                );
              },
        ),
      ),
    );
  }
}

/// Wraps a touch control button with a small always-on caption beneath it, so
/// its function is readable without a hover/long-press tooltip (the target
/// platform is touch, where tooltips never show during normal tapping).
class _CaptionedControl extends StatelessWidget {
  const _CaptionedControl({required this.caption, required this.child});

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 3),
        // Excluded from semantics: the PressableAction already carries the
        // label/hint for screen readers, so this caption is purely visual.
        ExcludeSemantics(
          child: Text(
            caption,
            style: AppTypography.label.copyWith(
              fontSize: 10,
              color: AppPalette.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.game});

  final PdacGame game;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Pause',
      child: PressableAction(
        onPressed: game.togglePause,
        semanticLabel: 'Pause',
        semanticHint: 'Opens the pause menu',
        builder:
            (
              context, {
              required enabled,
              required pressed,
              required focused,
              required hovered,
            }) {
              return AnimatedScale(
                scale: pressed ? 0.96 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppPalette.surface.withValues(
                      alpha: focused || hovered ? 0.95 : 0.85,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppPalette.playerCore.withValues(
                        alpha: focused ? 0.95 : 0.24,
                      ),
                      width: focused ? 2 : 1,
                    ),
                    boxShadow: focused
                        ? [
                            BoxShadow(
                              color: AppPalette.playerCore.withValues(
                                alpha: 0.36,
                              ),
                              blurRadius: 14,
                            ),
                          ]
                        : const [],
                  ),
                  child: const Icon(
                    Icons.pause,
                    color: AppPalette.textPrimary,
                    size: 22,
                  ),
                ),
              );
            },
      ),
    );
  }
}

class _GoldChip extends StatefulWidget {
  const _GoldChip({required this.game});

  final PdacGame game;

  @override
  State<_GoldChip> createState() => _GoldChipState();
}

class _GoldChipState extends State<_GoldChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );
  late int _lastGold = widget.game.hud.gold.value;

  @override
  void initState() {
    super.initState();
    widget.game.hud.gold.addListener(_onGold);
  }

  void _onGold() {
    final gold = widget.game.hud.gold.value;
    // Honor Reduce Motion: skip the scale/glow pulse on gold gain.
    if (gold > _lastGold && !SettingsService.instance.value.reduceMotion) {
      _pulse.forward(from: 0); // highlight on increase
    }
    _lastGold = gold;
  }

  @override
  void dispose() {
    widget.game.hud.gold.removeListener(_onGold);
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final v = _pulse.value;
        final pulse = v < 0.5 ? v * 2 : (1 - v) * 2; // 0 -> 1 -> 0
        return Transform.scale(
          scale: 1 + 0.18 * pulse,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Color.lerp(
                AppPalette.surface.withValues(alpha: 0.85),
                AppPalette.gold.withValues(alpha: 0.4),
                pulse * 0.8,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppPalette.gold.withValues(alpha: 0.15 + 0.7 * pulse),
                width: 1 + 1.4 * pulse,
              ),
            ),
            child: ValueListenableBuilder<int>(
              valueListenable: widget.game.hud.gold,
              builder: (context, gold, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.paid, color: AppPalette.gold, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '$gold',
                      style: AppTypography.bodyStrong.copyWith(
                        color: AppPalette.gold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _DashButton extends StatelessWidget {
  const _DashButton({required this.game});

  final PdacGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: game.hud.dashCharge,
      builder: (context, charge, _) {
        final ready = charge >= 0.999;
        return _CaptionedControl(
          caption: 'Dash',
          child: Tooltip(
            message: ready ? 'Dash ready' : 'Dash charging',
            child: PressableAction(
              onPressed: game.tryDash,
              semanticLabel: 'Dash',
              semanticValue: ready
                  ? 'Ready'
                  : '${(charge.clamp(0.0, 1.0) * 100).round()} percent charged',
              semanticHint: ready
                  ? 'Triggers a quick dash'
                  : 'Can be pressed, but the dash is still charging',
              builder:
                  (
                    context, {
                    required enabled,
                    required pressed,
                    required focused,
                    required hovered,
                  }) {
                    return AnimatedScale(
                      scale: pressed ? 0.95 : 1,
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOutCubic,
                      child: _HudCircleActionSurface(
                        color: ready
                            ? AppPalette.gold.withValues(alpha: 0.92)
                            : AppPalette.surface.withValues(
                                alpha: focused || hovered ? 0.88 : 0.78,
                              ),
                        focusColor: AppPalette.gold,
                        focused: focused,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (!ready)
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: CircularProgressIndicator(
                                  value: charge,
                                  strokeWidth: 3,
                                  color: AppPalette.gold,
                                  backgroundColor: AppPalette.surfaceLight,
                                ),
                              ),
                            Icon(
                              Icons.flash_on,
                              color: ready
                                  ? AppPalette.backgroundDeep
                                  : AppPalette.textMuted,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
            ),
          ),
        );
      },
    );
  }
}

class _HudCircleActionSurface extends StatelessWidget {
  const _HudCircleActionSurface({
    required this.color,
    required this.focusColor,
    required this.focused,
    required this.child,
  });

  final Color color;
  final Color focusColor;
  final bool focused;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: focusColor.withValues(alpha: focused ? 0.95 : 0.18),
          width: focused ? 2.4 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: focusColor.withValues(alpha: 0.34),
                  blurRadius: 16,
                ),
              ]
            : const [],
      ),
      child: Center(child: child),
    );
  }
}

class _PerformancePanel extends StatelessWidget {
  const _PerformancePanel({required this.game});

  final PdacGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: game.hud.performanceOverlayEnabled,
      builder: (context, enabled, _) {
        if (!enabled) return const SizedBox.shrink();
        return Container(
          width: 188,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppPalette.backgroundDeep.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppPalette.surfaceLight),
          ),
          child: DefaultTextStyle(
            style: AppTypography.label.copyWith(
              color: AppPalette.textSecondary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: game.hud.fps,
                  builder: (context, fps, _) {
                    return Text('FPS ${fps.toStringAsFixed(0)}');
                  },
                ),
                _PerfLine(label: 'Mobs', listenable: game.hud.activeMobCount),
                _PerfLine(
                  label: 'Shots',
                  listenable: game.hud.activeBulletCount,
                ),
                _PerfLine(
                  label: 'FX',
                  listenable: game.hud.activeParticleCount,
                ),
                _PerfLine(label: 'Coins', listenable: game.hud.activeCoinCount),
                _PerfLine(
                  label: 'Clouds',
                  listenable: game.hud.activeCloudCount,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PerfLine extends StatelessWidget {
  const _PerfLine({required this.label, required this.listenable});

  final String label;
  final ValueListenable<int> listenable;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: listenable,
      builder: (context, value, _) => Text('$label $value'),
    );
  }
}
