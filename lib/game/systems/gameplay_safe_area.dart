import 'dart:ui';

import 'package:flame/components.dart';

const double topLeftHudBlockWidth = 456;
const double topLeftHudBlockHeight = 220;
const double hudBlockActorPadding = 8;
const double hudSpawnEntryPadding = 16;
const double _minimumPlayableWidth = 32;
const double _minimumPlayableHeight = 64;

Rect topLeftHudBlockForArena(
  Vector2 arenaSize, {
  double width = topLeftHudBlockWidth,
  double height = topLeftHudBlockHeight,
}) {
  final arenaWidth = arenaSize.x < 0 ? 0.0 : arenaSize.x;
  final arenaHeight = arenaSize.y < 0 ? 0.0 : arenaSize.y;
  final blockWidth = width.clamp(0.0, _blockMaxWidth(arenaWidth)).toDouble();
  final blockHeight = height
      .clamp(0.0, _blockMaxHeight(arenaHeight))
      .toDouble();

  return Rect.fromLTWH(0, 0, blockWidth, blockHeight);
}

void clampPointToArena(Vector2 point, Vector2 arenaSize, double margin) {
  final minX = margin;
  final maxX = arenaSize.x - margin;
  final minY = margin;
  final maxY = arenaSize.y - margin;

  point.x = _clampWithCollapsedRange(point.x, minX, maxX);
  point.y = _clampWithCollapsedRange(point.y, minY, maxY);
}

void pushPointOutsideTopLeftHudBlock(
  Vector2 point,
  Vector2 arenaSize,
  double margin,
) {
  final block = _inflatedHudBlock(arenaSize, margin);
  if (!_rectContainsPoint(block, point)) return;

  final rightEscape = block.right;
  final bottomEscape = block.bottom;
  final canEscapeRight = rightEscape <= arenaSize.x - margin;
  final canEscapeBottom = bottomEscape <= arenaSize.y - margin;

  if (!canEscapeRight && !canEscapeBottom) return;
  if (canEscapeRight && !canEscapeBottom) {
    point.x = rightEscape;
    return;
  }
  if (!canEscapeRight && canEscapeBottom) {
    point.y = bottomEscape;
    return;
  }

  final distanceToRight = rightEscape - point.x;
  final distanceToBottom = bottomEscape - point.y;
  if (distanceToRight <= distanceToBottom) {
    point.x = rightEscape;
  } else {
    point.y = bottomEscape;
  }
}

bool pointOverlapsTopLeftHudBlock(
  Vector2 point,
  Vector2 arenaSize,
  double margin,
) {
  return _rectContainsPoint(_inflatedHudBlock(arenaSize, margin), point);
}

void sanitizeSpawnPositionAgainstTopLeftHud(
  Vector2 point,
  Vector2 arenaSize,
  double actorRadius,
) {
  final block = topLeftHudBlockForArena(
    arenaSize,
  ).inflate(actorRadius + hudSpawnEntryPadding);
  final topEntryUnsafe = point.y <= 0 && point.x < block.right;
  final leftEntryUnsafe = point.x <= 0 && point.y < block.bottom;

  if (topEntryUnsafe) {
    if (block.right <= arenaSize.x) {
      point.x = block.right;
    } else {
      _moveSpawnToBottomFallback(point, arenaSize, actorRadius);
    }
    return;
  }

  if (leftEntryUnsafe) {
    if (block.bottom <= arenaSize.y) {
      point.y = block.bottom;
    } else {
      _moveSpawnToRightFallback(point, arenaSize, actorRadius);
    }
    return;
  }

  pushPointOutsideTopLeftHudBlock(point, arenaSize, actorRadius);
}

double _blockMaxWidth(double arenaWidth) {
  if (arenaWidth <= _minimumPlayableWidth) return arenaWidth;
  return arenaWidth - _minimumPlayableWidth;
}

double _blockMaxHeight(double arenaHeight) {
  if (arenaHeight <= _minimumPlayableHeight) return arenaHeight;
  return arenaHeight - _minimumPlayableHeight;
}

Rect _inflatedHudBlock(Vector2 arenaSize, double margin) {
  return topLeftHudBlockForArena(
    arenaSize,
  ).inflate(margin + hudBlockActorPadding);
}

bool _rectContainsPoint(Rect rect, Vector2 point) {
  return rect.contains(Offset(point.x, point.y));
}

void _moveSpawnToBottomFallback(
  Vector2 point,
  Vector2 arenaSize,
  double actorRadius,
) {
  point
    ..x = _clampWithCollapsedRange(
      point.x,
      actorRadius,
      arenaSize.x - actorRadius,
    )
    ..y = arenaSize.y + actorRadius + hudSpawnEntryPadding;
}

void _moveSpawnToRightFallback(
  Vector2 point,
  Vector2 arenaSize,
  double actorRadius,
) {
  point
    ..x = arenaSize.x + actorRadius + hudSpawnEntryPadding
    ..y = _clampWithCollapsedRange(
      point.y,
      actorRadius,
      arenaSize.y - actorRadius,
    );
}

double _clampWithCollapsedRange(
  double value,
  double minValue,
  double maxValue,
) {
  if (maxValue < minValue) return (minValue + maxValue) / 2;
  return value.clamp(minValue, maxValue).toDouble();
}
