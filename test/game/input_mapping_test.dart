import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/game/pdac_game.dart';

void main() {
  test('WASD maps to the four directions', () {
    expect(movementKeysFor({LogicalKeyboardKey.keyW}), {PdacKey.up});
    expect(movementKeysFor({LogicalKeyboardKey.keyS}), {PdacKey.down});
    expect(movementKeysFor({LogicalKeyboardKey.keyA}), {PdacKey.left});
    expect(movementKeysFor({LogicalKeyboardKey.keyD}), {PdacKey.right});
  });

  test('arrow keys are equivalent to WASD', () {
    expect(movementKeysFor({LogicalKeyboardKey.arrowUp}), {PdacKey.up});
    expect(movementKeysFor({LogicalKeyboardKey.arrowDown}), {PdacKey.down});
    expect(movementKeysFor({LogicalKeyboardKey.arrowLeft}), {PdacKey.left});
    expect(movementKeysFor({LogicalKeyboardKey.arrowRight}), {PdacKey.right});
  });

  test('diagonals combine and non-movement keys are ignored', () {
    expect(
      movementKeysFor({LogicalKeyboardKey.keyW, LogicalKeyboardKey.keyD}),
      {PdacKey.up, PdacKey.right},
    );
    expect(movementKeysFor({LogicalKeyboardKey.space}), isEmpty);
    expect(movementKeysFor(<LogicalKeyboardKey>{}), isEmpty);
  });
}
