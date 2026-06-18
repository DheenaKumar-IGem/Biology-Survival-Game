import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../game/components/hud_data.dart';
import '../../game/pdac_game.dart';
import '../../theme/fx_constants.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// A transient educational banner triggered by [HudData.contextTip] (e.g.
/// when an enemy gains a KRAS resistance tier). Always mounted alongside the
/// HUD; fades in, holds, then clears itself.
class ContextTipOverlay extends StatefulWidget {
  const ContextTipOverlay({super.key, required this.game});

  final PdacGame game;

  @override
  State<ContextTipOverlay> createState() => _ContextTipOverlayState();
}

class _ContextTipOverlayState extends State<ContextTipOverlay> {
  Timer? _dismissTimer;
  String? _lastAnnouncedTip;

  @override
  void initState() {
    super.initState();
    widget.game.hud.contextTip.addListener(_onTipChanged);
    widget.game.hud.roundIntro.addListener(_onIntroChanged);
    // The resistance alert is a higher-priority top banner; re-evaluate so the
    // tip suppresses itself while it's up (one top transient at a time).
    widget.game.hud.resistanceAlert.addListener(_onIntroChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scheduleDismissIfNeeded();
    });
  }

  void _onTipChanged() {
    _dismissTimer?.cancel();
    _scheduleDismissIfNeeded();
  }

  void _onIntroChanged() {
    _dismissTimer?.cancel();
    _scheduleDismissIfNeeded();
  }

  void _scheduleDismissIfNeeded() {
    final tip = widget.game.hud.contextTip.value;
    if (tip == null) return;
    if (widget.game.hud.roundIntro.value != null) return;
    if (widget.game.hud.resistanceAlert.value != null) return;
    _announceTipIfNew(tip);
    // During the tutorial the coaching text must stay put until the beat
    // advances - it's the player's only guidance, so it never auto-dismisses.
    if (widget.game.tutorial) return;
    _dismissTimer = Timer(_dismissDurationFor(tip), _dismissTip);
  }

  void _announceTipIfNew(String tip) {
    if (_lastAnnouncedTip == tip) return;
    _lastAnnouncedTip = tip;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SemanticsService.sendAnnouncement(
        View.of(context),
        tip,
        Directionality.of(context),
      );
    });
  }

  /// How long a tip stays up before auto-dismissing. Scales with the text
  /// length (longer copy needs more reading time) and with the user's text
  /// scale (larger text usually means a reader who wants more time), so a slow
  /// reader on a long tip isn't cut off mid-sentence. Clamped to a sane band.
  Duration _dismissDurationFor(String text) {
    // ~3.3 chars/sec reading budget on top of a 3.5s floor, then stretched by
    // the platform text scale (1.0 = default).
    final textScale =
        MediaQuery.maybeOf(context)?.textScaler.scale(1.0) ??
        WidgetsBinding.instance.platformDispatcher.textScaleFactor;
    final base = 3.5 + text.length / 16.0;
    final scaled = base * textScale.clamp(1.0, 2.0);
    final seconds = scaled.clamp(6.0, 16.0);
    return Duration(milliseconds: (seconds * 1000).round());
  }

  void _dismissTip() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    widget.game.dismissContextTip();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    widget.game.hud.contextTip.removeListener(_onTipChanged);
    widget.game.hud.roundIntro.removeListener(_onIntroChanged);
    widget.game.hud.resistanceAlert.removeListener(_onIntroChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // On a narrow phone a 480-wide banner pinned 64px from the top overlaps the
    // top-left HUD cluster. Keep the banner clear of the HUD by capping its
    // width to a fraction of the screen and, when there isn't room beside the
    // HUD, dropping it below the HUD block height instead of over it.
    const narrowBreakpoint = 600.0;
    final isNarrow = screenWidth < narrowBreakpoint;
    final bannerMaxWidth = isNarrow
        ? (screenWidth - 24).clamp(160.0, 480.0).toDouble()
        : 480.0;
    final topMargin = isNarrow ? 112.0 : 64.0;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ValueListenableBuilder<ResistanceAlertData?>(
            valueListenable: widget.game.hud.resistanceAlert,
            builder: (context, alert, _) {
              return ValueListenableBuilder<RoundIntroData?>(
                valueListenable: widget.game.hud.roundIntro,
                builder: (context, intro, _) {
                  return ValueListenableBuilder<String?>(
                    valueListenable: widget.game.hud.contextTip,
                    builder: (context, tip, _) {
                      // Only one top transient at a time: the round intro and
                      // the (higher-priority) resistance alert both suppress
                      // the tip.
                      final visibleTip = (intro == null && alert == null)
                          ? tip
                          : null;
                      return AnimatedSwitcher(
                        duration: FxConstants.medium,
                        child: visibleTip == null
                            ? const SizedBox.shrink()
                            : Semantics(
                                liveRegion: true,
                                container: true,
                                label: visibleTip,
                                child: ExcludeSemantics(
                                  child: Container(
                                    key: ValueKey(visibleTip),
                                    margin: EdgeInsets.only(top: topMargin),
                                    constraints: BoxConstraints(
                                      maxWidth: bannerMaxWidth,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppPalette.surface.withValues(
                                        alpha: 0.95,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppPalette.mutationRing
                                            .withValues(alpha: 0.7),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppPalette.mutationRing
                                              .withValues(alpha: 0.25),
                                          blurRadius: 16,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.science,
                                          color: AppPalette.mutationRing,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            visibleTip,
                                            style: AppTypography.body.copyWith(
                                              color: AppPalette.textPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Tooltip(
                                          message: 'Dismiss tip',
                                          child: IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 32,
                                              minHeight: 32,
                                            ),
                                            icon: const Icon(
                                              Icons.close,
                                              color: AppPalette.textSecondary,
                                              size: 18,
                                            ),
                                            onPressed: _dismissTip,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
