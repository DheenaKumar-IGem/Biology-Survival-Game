import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/game/systems/weapon_resistance_tracker.dart';

void main() {
  // Drives [count] mismatched (wrong-category) hits with [weaponId] and returns
  // the last event produced.
  WeaponResistanceEvent? mismatchBurst(
    WeaponResistanceTracker tracker,
    String weaponId,
    int count,
  ) {
    WeaponResistanceEvent? event;
    for (var i = 0; i < count; i++) {
      event = tracker.recordHit(weaponId, matched: false);
    }
    return event;
  }

  test('mismatched hits below the warn threshold do nothing', () {
    final tracker = WeaponResistanceTracker();

    for (var i = 0; i < mismatchHitsToWarn - 1; i++) {
      expect(tracker.recordHit('pistol', matched: false), isNull);
    }

    expect(tracker.tierFor('pistol'), 0);
    expect(tracker.multiplierFor('pistol'), 1);
  });

  test('warns (no damage reduction) at the first mismatch threshold', () {
    final tracker = WeaponResistanceTracker();

    final event = mismatchBurst(tracker, 'rifle', mismatchHitsToWarn);

    expect(event, isNotNull);
    expect(event!.weaponId, 'rifle');
    expect(event.tier, 1);
    expect(event.warningOnly, isTrue);
    // Every hit was wrong-category, so the wrong-target ratio is 1.0.
    expect(event.share, closeTo(1, 1e-9));
    // A warning is mechanically inert - no tier / multiplier change yet.
    expect(tracker.tierFor('rifle'), 0);
    expect(tracker.multiplierFor('rifle'), 1);
  });

  test('a real tier lands after further mismatched hits past the warning', () {
    final tracker = WeaponResistanceTracker();

    mismatchBurst(tracker, 'rifle', mismatchHitsToWarn);
    final event = mismatchBurst(tracker, 'rifle', mismatchHitsToEscalate);

    expect(event, isNotNull);
    expect(event!.weaponId, 'rifle');
    expect(event.tier, 1);
    expect(event.warningOnly, isFalse);
    expect(tracker.tierFor('rifle'), 1);
    expect(
      tracker.multiplierFor('rifle'),
      closeTo(weaponResistanceTierMultiplier, 1e-9),
    );
  });

  test('matched-only play NEVER builds resistance', () {
    final tracker = WeaponResistanceTracker();

    for (var i = 0; i < 100; i++) {
      expect(tracker.recordHit('rifle', matched: true), isNull);
    }

    expect(tracker.tierFor('rifle'), 0);
    expect(tracker.multiplierFor('rifle'), 1);
  });

  test('resetForRound clears tiers and pressure', () {
    final tracker = WeaponResistanceTracker();
    mismatchBurst(tracker, 'smg', mismatchHitsToWarn);
    mismatchBurst(tracker, 'smg', mismatchHitsToEscalate);
    expect(tracker.tierFor('smg'), 1);

    tracker.resetForRound();

    expect(tracker.tierFor('smg'), 0);
    expect(tracker.activeTiers, isEmpty);
  });

  test('mixed play counts only mismatch; ratio reflects both', () {
    final tracker = WeaponResistanceTracker();
    WeaponResistanceEvent? event;

    // 3 correct hits for every wrong hit, until the warn threshold is crossed.
    for (var i = 0; i < mismatchHitsToWarn; i++) {
      for (var m = 0; m < 3; m++) {
        expect(tracker.recordHit('shotgun', matched: true), isNull);
      }
      event = tracker.recordHit('shotgun', matched: false);
    }

    expect(event, isNotNull);
    expect(event!.warningOnly, isTrue);
    // mismatch / (matched + mismatch) = 12 / (36 + 12) = 0.25.
    expect(event.share, closeTo(0.25, 1e-9));
    expect(event.share, lessThan(1));
  });

  test('resistance caps at maxWeaponResistanceTier', () {
    final tracker = WeaponResistanceTracker();

    mismatchBurst(tracker, 'rifle', mismatchHitsToWarn); // warning
    mismatchBurst(tracker, 'rifle', mismatchHitsToEscalate); // tier 1
    mismatchBurst(tracker, 'rifle', mismatchHitsToEscalate); // tier 2
    mismatchBurst(tracker, 'rifle', mismatchHitsToEscalate); // tier 3
    expect(tracker.tierFor('rifle'), maxWeaponResistanceTier);

    // One more full window must NOT exceed the cap.
    final overflow = mismatchBurst(tracker, 'rifle', mismatchHitsToEscalate);
    expect(overflow, isNull);
    expect(tracker.tierFor('rifle'), maxWeaponResistanceTier);
  });

  test('resistance is isolated per weapon', () {
    final tracker = WeaponResistanceTracker();
    mismatchBurst(tracker, 'rifle', mismatchHitsToWarn);
    mismatchBurst(tracker, 'rifle', mismatchHitsToEscalate);

    expect(tracker.tierFor('rifle'), 1);
    expect(tracker.tierFor('pistol'), 0);
    expect(tracker.multiplierFor('pistol'), 1);
  });

  test('the escalation window resets after each trigger', () {
    final tracker = WeaponResistanceTracker();
    mismatchBurst(tracker, 'rifle', mismatchHitsToWarn); // warning fires

    // A single further mismatch must not immediately re-fire; it needs a fresh
    // mismatchHitsToEscalate window.
    expect(tracker.recordHit('rifle', matched: false), isNull);
    final event = mismatchBurst(tracker, 'rifle', mismatchHitsToEscalate - 1);
    expect(event, isNotNull);
    expect(event!.warningOnly, isFalse);
  });

  test('an empty weapon id is a no-op', () {
    final tracker = WeaponResistanceTracker();
    expect(tracker.recordHit('', matched: false), isNull);
    expect(tracker.activeTiers, isEmpty);
  });

  test('mismatchProgressFor tracks progress and resets after a trigger', () {
    final tracker = WeaponResistanceTracker();
    expect(tracker.mismatchProgressFor('rifle'), 0);

    // Halfway to the warning threshold (mismatchHitsToWarn is even = 12).
    for (var i = 0; i < mismatchHitsToWarn ~/ 2; i++) {
      tracker.recordHit('rifle', matched: false);
    }
    expect(tracker.mismatchProgressFor('rifle'), closeTo(0.5, 1e-9));

    // Matched fire never advances the progress.
    tracker.recordHit('rifle', matched: true);
    expect(tracker.mismatchProgressFor('rifle'), closeTo(0.5, 1e-9));

    // Crossing the threshold fires the warning and resets the window to 0.
    for (var i = 0; i < mismatchHitsToWarn ~/ 2; i++) {
      tracker.recordHit('rifle', matched: false);
    }
    expect(tracker.mismatchProgressFor('rifle'), 0);
  });
}
