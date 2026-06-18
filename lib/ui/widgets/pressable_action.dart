import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef PressableActionBuilder =
    Widget Function(
      BuildContext context, {
      required bool enabled,
      required bool pressed,
      required bool focused,
      required bool hovered,
    });

/// Keeps custom game controls keyboard- and screen-reader friendly without
/// forcing them into a stock Material button shape.
class PressableAction extends StatefulWidget {
  const PressableAction({
    super.key,
    required this.onPressed,
    required this.builder,
    this.semanticLabel,
    this.semanticValue,
    this.semanticHint,
    this.selected,
    this.toggled,
    this.mouseCursor,
    this.autofocus = false,
    this.behavior = HitTestBehavior.opaque,
  });

  final VoidCallback? onPressed;
  final PressableActionBuilder builder;
  final String? semanticLabel;
  final String? semanticValue;
  final String? semanticHint;
  final bool? selected;
  final bool? toggled;
  final MouseCursor? mouseCursor;
  final bool autofocus;
  final HitTestBehavior behavior;

  @override
  State<PressableAction> createState() => _PressableActionState();
}

class _PressableActionState extends State<PressableAction> {
  bool _pressed = false;
  bool _focused = false;
  bool _hovered = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _setFocused(bool value) {
    if (_focused == value) return;
    setState(() => _focused = value);
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  void _activate() {
    if (!_enabled) return;
    widget.onPressed?.call();
  }

  @override
  void didUpdateWidget(covariant PressableAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled && _pressed) {
      _pressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _enabled;

    return Semantics(
      button: true,
      enabled: enabled,
      excludeSemantics: widget.semanticLabel != null,
      label: widget.semanticLabel,
      value: widget.semanticValue,
      hint: widget.semanticHint,
      selected: widget.selected,
      toggled: widget.toggled,
      onTap: enabled ? _activate : null,
      child: FocusableActionDetector(
        enabled: enabled,
        autofocus: widget.autofocus,
        mouseCursor:
            widget.mouseCursor ??
            (enabled ? SystemMouseCursors.click : SystemMouseCursors.basic),
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        onShowFocusHighlight: _setFocused,
        onShowHoverHighlight: _setHovered,
        child: GestureDetector(
          behavior: widget.behavior,
          excludeFromSemantics: true,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTap: enabled ? _activate : null,
          child: widget.builder(
            context,
            enabled: enabled,
            pressed: _pressed,
            focused: _focused,
            hovered: _hovered,
          ),
        ),
      ),
    );
  }
}
