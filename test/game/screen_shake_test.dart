import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/game/systems/screen_shake.dart';

void main() {
  test('a triggered shake is active, then decays to zero', () {
    final shake = ScreenShake();
    expect(shake.isActive, isFalse);

    shake.trigger(10, 0.2);
    expect(shake.isActive, isTrue);

    shake.update(0.1);
    expect(shake.isActive, isTrue);

    shake.update(0.2); // past the remaining duration
    expect(shake.isActive, isFalse);
    expect(shake.offset, Vector2.zero());
  });

  test('a weaker shake does not cut off a stronger in-progress one', () {
    final shake = ScreenShake();
    shake.trigger(12, 0.5);
    shake.update(0.1);
    shake.trigger(4, 0.1); // weaker + shorter -> ignored
    shake.update(0.2); // still within the original 0.5s window
    expect(shake.isActive, isTrue);
  });

  test('the offset stays within the current magnitude', () {
    final shake = ScreenShake();
    shake.trigger(8, 1.0);
    shake.update(0.1);
    expect(shake.offset.x.abs(), lessThanOrEqualTo(8));
    expect(shake.offset.y.abs(), lessThanOrEqualTo(8));
  });
}
