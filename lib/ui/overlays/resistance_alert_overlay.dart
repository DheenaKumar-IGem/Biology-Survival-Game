import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../game/components/hud_data.dart';
import '../../game/pdac_game.dart';
import '../../services/settings_service.dart';
import '../../theme/fx_constants.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// Big transient combat warning shown at the top of the screen when the player
/// keeps firing a weapon at the wrong-color targets. Dismissal and the
/// accompanying slow-motion are owned by [PdacGame] (it clears
/// `hud.resistanceAlert` when the hold window ends), so this widget only
/// animates the card and announces it to screen readers.
class ResistanceAlertOverlay extends StatefulWidget {
  const ResistanceAlertOverlay({super.key, required this.game});

  final PdacGame game;

  @override
  State<ResistanceAlertOverlay> createState() => _ResistanceAlertOverlayState();
}

class _ResistanceAlertOverlayState extends State<ResistanceAlertOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
      lowerBound: 0,
      upperBound: 1,
    );
    widget.game.hud.resistanceAlert.addListener(_onAlertChanged);
    _onAlertChanged();
  }

  void _onAlertChanged() {
    final alert = widget.game.hud.resistanceAlert.value;
    if (alert == null) {
      _pulse.stop();
      return;
    }

    if (SettingsService.instance.value.reduceMotion) {
      _pulse.value = 1;
    } else {
      _pulse.repeat(reverse: true);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SemanticsService.sendAnnouncement(
        View.of(context),
        alert.warningOnly
            ? 'Wrong target warning. You keep firing ${alert.weaponName} at the wrong cell type. Match the color to avoid resistance.'
            : '${alert.weaponName} resistance tier ${alert.tier} is active from firing it at the wrong cells. Swap to the matching color.',
        Directionality.of(context),
      );
    });
  }

  @override
  void dispose() {
    widget.game.hud.resistanceAlert.removeListener(_onAlertChanged);
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: SafeArea(
          child: Align(
            // Upper area, dropped just clear of the ~140px top-left HUD cluster
            // so the alert never hides HP/round mid-combat. The card is kept
            // compact (below) so this still reads as a top banner rather than a
            // mid-screen modal even on short landscape phones.
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 144),
              child: ValueListenableBuilder<ResistanceAlertData?>(
                valueListenable: widget.game.hud.resistanceAlert,
                builder: (context, alert, _) {
                  return AnimatedSwitcher(
                    duration: FxConstants.medium,
                    switchInCurve: FxConstants.standardCurve,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0, -0.18),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: alert == null
                        ? const SizedBox.shrink()
                        : _ResistanceAlertCard(
                            key: ValueKey(alert.eventId),
                            alert: alert,
                            pulse: _pulse,
                          ),
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

class _ResistanceAlertCard extends StatelessWidget {
  const _ResistanceAlertCard({
    super.key,
    required this.alert,
    required this.pulse,
  });

  final ResistanceAlertData alert;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final width = screenWidth < 620
        ? (screenWidth - 28).clamp(280.0, 560.0).toDouble()
        : 600.0;
    final sharePercent = (alert.share * 100).round().clamp(0, 100);
    final heading = alert.warningOnly ? 'WRONG TARGET' : 'RESISTANCE SURGE';
    final status = alert.warningOnly
        ? 'No damage reduction yet'
        : 'Tier ${alert.tier} resistance active';
    final detail = alert.warningOnly
        ? '$sharePercent% of these shots hit the wrong cell type. Match the color before these cells learn to resist it.'
        : '$sharePercent% wrong-target hits. These cells now resist this weapon - swap to the color that matches them.';
    final semanticLabel = '$heading. ${alert.weaponName}. $status. $detail';

    return Semantics(
      liveRegion: true,
      container: true,
      label: semanticLabel,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          final p = pulse.value;
          final glow = 0.28 + 0.22 * p;
          final border = 0.72 + 0.24 * p;
          return ExcludeSemantics(
            child: Container(
              width: width,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Color.lerp(
                  AppPalette.backgroundDeep,
                  AppPalette.healthLow,
                  0.08 + p * 0.04,
                )!.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppPalette.mutationRing.withValues(alpha: border),
                  width: 2.4 + p * 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppPalette.healthLow.withValues(alpha: glow),
                    blurRadius: 30 + p * 14,
                    spreadRadius: 2 + p * 2,
                  ),
                  BoxShadow(
                    color: AppPalette.mutationRing.withValues(
                      alpha: 0.18 + p * 0.1,
                    ),
                    blurRadius: 48,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppPalette.mutationRing,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          heading,
                          textAlign: TextAlign.center,
                          style: AppTypography.displayMedium.copyWith(
                            color: AppPalette.mutationRing,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${alert.weaponName} - $status',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppPalette.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    detail,
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: AppPalette.textPrimary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
