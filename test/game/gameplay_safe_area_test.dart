import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pdac_immune_defense/game/systems/gameplay_safe_area.dart';

void main() {
  test('top-left HUD block uses desktop size and adapts on compact arenas', () {
    final desktop = topLeftHudBlockForArena(Vector2(960, 540));

    expect(desktop.width, topLeftHudBlockWidth);
    expect(desktop.height, topLeftHudBlockHeight);

    final compact = topLeftHudBlockForArena(Vector2(320, 260));

    expect(compact.width, 288);
    expect(compact.height, 196);
  });

  test('pushPointOutsideTopLeftHudBlock moves a player-sized point out', () {
    final arena = Vector2(960, 540);
    final point = Vector2(20, 20);

    pushPointOutsideTopLeftHudBlock(point, arena, 18);

    expect(pointOverlapsTopLeftHudBlock(point, arena, 18), isFalse);
  });

  test('arena clamp no longer reserves the whole top or bottom HUD bands', () {
    final arena = Vector2(960, 540);
    final point = Vector2(20, 500);

    clampPointToArena(point, arena, 18);
    pushPointOutsideTopLeftHudBlock(point, arena, 18);

    expect(point.x, 20);
    expect(point.y, 500);
  });

  test('top-edge spawn positions are shifted away from the HUD x-range', () {
    final arena = Vector2(960, 540);
    final point = Vector2(100, -30);

    sanitizeSpawnPositionAgainstTopLeftHud(point, arena, 18);

    expect(
      point.x,
      greaterThanOrEqualTo(
        topLeftHudBlockForArena(arena).right + 18 + hudSpawnEntryPadding,
      ),
    );
    expect(point.y, -30);
  });

  test('left-edge spawn positions are shifted away from the HUD y-range', () {
    final arena = Vector2(960, 540);
    final point = Vector2(-30, 100);

    sanitizeSpawnPositionAgainstTopLeftHud(point, arena, 18);

    expect(
      point.y,
      greaterThanOrEqualTo(
        topLeftHudBlockForArena(arena).bottom + 18 + hudSpawnEntryPadding,
      ),
    );
    expect(point.x, -30);
  });

  test('tiny arenas fall back to non-HUD spawn entries', () {
    final arena = Vector2(260, 180);
    final point = Vector2(10, -30);

    sanitizeSpawnPositionAgainstTopLeftHud(point, arena, 18);

    expect(point.y, greaterThan(arena.y));
  });
}
