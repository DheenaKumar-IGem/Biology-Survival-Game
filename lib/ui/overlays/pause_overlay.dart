import 'dart:async';

import 'package:flutter/material.dart';

import '../../game/pdac_game.dart';
import '../../services/audio_service.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import '../widgets/glow_button.dart';
import '../screens/settings_screen.dart';

/// Shown when [PdacGame.togglePause] pauses an in-progress round. Lets the
/// player resume, jump to settings, or quit back to the home screen.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});

  final PdacGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPalette.backgroundDeep.withValues(alpha: 0.72),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppPalette.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppPalette.surfaceLight),
                boxShadow: [
                  BoxShadow(
                    color: AppPalette.backgroundDeep.withValues(alpha: 0.45),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.pause_circle,
                          color: AppPalette.playerCore,
                          size: 34,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Paused',
                                style: AppTypography.displayMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your run checkpoint is saved when you leave the arena.',
                                style: AppTypography.label.copyWith(
                                  color: AppPalette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _ControlsPanel(touch: game.touchControlsEnabled),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.end,
                      children: [
                        GlowButton(
                          label: 'Resume',
                          icon: Icons.play_arrow,
                          onPressed: () {
                            unawaited(
                              AudioService.instance.resumeCurrentMusicIfPrimed(),
                            );
                            game.togglePause();
                          },
                        ),
                        GlowButton(
                          label: 'Settings',
                          icon: Icons.settings,
                          color: AppPalette.antibodyColor,
                          filled: false,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                        ),
                        GlowButton(
                          label: 'Save & Quit',
                          icon: Icons.home,
                          color: AppPalette.cytotoxicColor,
                          filled: false,
                          onPressed: () async {
                            await game.saveRunCheckpoint();
                            if (!context.mounted) return;
                            game.overlays.remove('pause');
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlsPanel extends StatelessWidget {
  const _ControlsPanel({required this.touch});

  /// Whether on-screen touch controls are active. Touch players are steered to
  /// the joystick / on-screen buttons; desktop players to the keyboard. Both
  /// detail lines are shown on every chip (so a player who switches input still
  /// sees the other mapping), with the active one emphasized.
  final bool touch;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.backgroundDeep.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.surfaceLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  touch ? Icons.touch_app : Icons.sports_esports,
                  color: AppPalette.gold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('Controls', style: AppTypography.bodyStrong),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final item in pauseControlItems)
                  _ControlChip(
                    icon: item.icon,
                    label: item.label,
                    detail: item.detail,
                    touchDetail: item.touchDetail,
                    touch: touch,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlChip extends StatelessWidget {
  const _ControlChip({
    required this.icon,
    required this.label,
    required this.detail,
    required this.touchDetail,
    required this.touch,
  });

  final IconData icon;
  final String label;

  /// Keyboard mapping (e.g. "WASD / Arrows").
  final String detail;

  /// Touch mapping (e.g. "Drag joystick"). Falls back to [detail] when a
  /// control has no distinct touch form.
  final String touchDetail;

  /// When true, the touch detail is the prominent line and the keyboard detail
  /// is shown muted underneath; when false, the reverse.
  final bool touch;

  @override
  Widget build(BuildContext context) {
    final primary = touch ? touchDetail : detail;
    final secondary = touch ? detail : touchDetail;
    final showSecondary = secondary != primary;
    return Container(
      width: 174,
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppPalette.surface.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppPalette.playerCore.withValues(alpha: 0.26),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppPalette.playerCore, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppTypography.label),
                const SizedBox(height: 2),
                Text(
                  primary,
                  style: AppTypography.bodyStrong.copyWith(fontSize: 13),
                ),
                if (showSecondary) ...[
                  const SizedBox(height: 1),
                  Text(
                    secondary,
                    style: AppTypography.label.copyWith(
                      fontSize: 11,
                      color: AppPalette.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PauseControlItem {
  const PauseControlItem({
    required this.icon,
    required this.label,
    required this.detail,
    String? touchDetail,
  }) : touchDetail = touchDetail ?? detail;

  final IconData icon;
  final String label;

  /// Keyboard/desktop mapping.
  final String detail;

  /// On-screen touch mapping. Defaults to [detail] for controls that have no
  /// distinct touch form.
  final String touchDetail;
}

const pauseControlItems = [
  PauseControlItem(
    icon: Icons.open_with,
    label: 'Move',
    detail: 'WASD / Arrows',
    touchDetail: 'Drag joystick',
  ),
  PauseControlItem(
    icon: Icons.touch_app,
    label: 'Touch Move',
    detail: 'Joystick',
    touchDetail: 'Joystick',
  ),
  PauseControlItem(
    icon: Icons.flash_on,
    label: 'Dash',
    detail: 'Space / Shift',
    touchDetail: 'Dash button',
  ),
  PauseControlItem(
    icon: Icons.swap_horiz,
    label: 'Swap Weapon',
    detail: 'Q',
    touchDetail: 'Swap button',
  ),
];
