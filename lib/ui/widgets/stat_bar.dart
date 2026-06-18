import 'package:flutter/material.dart';

import '../../theme/fx_constants.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';

/// A labeled horizontal progress bar - used for HP, round progress, and
/// shop upgrade levels. [value] is 0.0-1.0.
class StatBar extends StatelessWidget {
  const StatBar({
    super.key,
    required this.value,
    required this.color,
    this.label,
    this.height = 14,
    this.backgroundColor,
  });

  final double value;
  final Color color;
  final String? label;
  final double height;
  final Color? backgroundColor;

  /// A convenience constructor that picks [AppPalette.healthGood]/Mid/Low
  /// based on [value], for HP bars.
  factory StatBar.health(double value, {String? label}) {
    final color = value > 0.5
        ? AppPalette.healthGood
        : value > 0.25
        ? AppPalette.healthMid
        : AppPalette.healthLow;
    return StatBar(value: value, color: color, label: label);
  }

  @override
  Widget build(BuildContext context) {
    final semanticLabel = label ?? 'Progress';
    final semanticValue = statBarSemanticValue(value);
    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Container(
        height: height,
        color: backgroundColor ?? AppPalette.surface,
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedFractionallySizedBox(
            duration: FxConstants.medium,
            curve: FxConstants.standardCurve,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final content = label == null
        ? bar
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label!, style: AppTypography.label),
              const SizedBox(height: 4),
              bar,
            ],
          );

    return Semantics(
      label: semanticLabel,
      value: semanticValue,
      child: ExcludeSemantics(child: content),
    );
  }
}

String statBarSemanticValue(double value) {
  final percent = (value.clamp(0.0, 1.0) * 100).round();
  return '$percent percent';
}

/// Helper for widgets that need an [AnimatedFractionallySizedBox]-like API
/// but only animate width. Wraps [AnimatedContainer] via
/// [FractionallySizedBox] for simplicity.
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  const AnimatedFractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.child,
    required super.duration,
    super.curve,
  });

  final double widthFactor;
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor =
        visitor(
              _widthFactor,
              widget.widthFactor,
              (value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      alignment: Alignment.centerLeft,
      child: widget.child,
    );
  }
}
