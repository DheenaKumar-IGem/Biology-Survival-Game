import 'package:flutter/material.dart';

import '../../theme/fx_constants.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import 'pressable_action.dart';

/// A pill-shaped button with a soft glow and press-scale animation, used
/// throughout the home screen, overlays, and shop.
///
/// [color] tints the glow/border (defaults to [AppPalette.playerCore]);
/// pass a category color to tint category-specific actions.
class GlowButton extends StatefulWidget {
  const GlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppPalette.playerCore,
    this.filled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final bool filled;

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> {
  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final color = disabled ? AppPalette.textMuted : widget.color;

    return PressableAction(
      onPressed: widget.onPressed,
      semanticLabel: widget.label,
      builder:
          (
            context, {
            required enabled,
            required pressed,
            required focused,
            required hovered,
          }) {
            final highlightAlpha = focused ? 1.0 : (hovered ? 0.95 : 0.8);
            return AnimatedScale(
              scale: pressed ? 0.96 : 1.0,
              duration: FxConstants.fast,
              curve: FxConstants.standardCurve,
              child: AnimatedContainer(
                duration: FxConstants.medium,
                curve: FxConstants.standardCurve,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: widget.filled
                      ? color.withValues(alpha: disabled ? 0.12 : 0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: color.withValues(
                      alpha: disabled ? 0.35 : highlightAlpha,
                    ),
                    width: focused ? 2.2 : 1.5,
                  ),
                  boxShadow: disabled
                      ? const []
                      : [
                          BoxShadow(
                            color: color.withValues(
                              alpha: focused ? 0.48 : 0.35,
                            ),
                            blurRadius: focused ? 22 : 16,
                            spreadRadius: focused ? 1 : 0,
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: color, size: 20),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      widget.label,
                      style: AppTypography.button.copyWith(
                        color: disabled
                            ? AppPalette.textMuted
                            : AppPalette.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }
}
