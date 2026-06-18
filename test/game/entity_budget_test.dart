import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/game/systems/entity_budget.dart';

void main() {
  test('tryAcquire respects the cap, release frees a slot', () {
    final b = EntityBudget();
    expect(b.count(EntityBudget.bullet), 0);

    expect(b.tryAcquire(EntityBudget.bullet, 2), isTrue);
    expect(b.tryAcquire(EntityBudget.bullet, 2), isTrue);
    expect(b.count(EntityBudget.bullet), 2);

    // At cap -> refused, count unchanged.
    expect(b.tryAcquire(EntityBudget.bullet, 2), isFalse);
    expect(b.count(EntityBudget.bullet), 2);

    b.release(EntityBudget.bullet);
    expect(b.count(EntityBudget.bullet), 1);
    expect(b.tryAcquire(EntityBudget.bullet, 2), isTrue);
  });

  test('release never goes below zero', () {
    final b = EntityBudget();
    b.release(EntityBudget.coin);
    expect(b.count(EntityBudget.coin), 0);
  });

  test('keys are tracked independently', () {
    final b = EntityBudget();
    b.tryAcquire(EntityBudget.coin, 5);
    b.tryAcquire(EntityBudget.cloud, 5);
    expect(b.count(EntityBudget.coin), 1);
    expect(b.count(EntityBudget.cloud), 1);
    expect(b.count(EntityBudget.bullet), 0);
  });

  test('a dynamic cap is honored per call', () {
    final b = EntityBudget();
    expect(b.tryAcquire(EntityBudget.cloud, 1), isTrue);
    expect(b.tryAcquire(EntityBudget.cloud, 1), isFalse); // lower cap blocks
    expect(b.tryAcquire(EntityBudget.cloud, 2), isTrue); // higher cap allows
  });
}
