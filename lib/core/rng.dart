import 'dart:math';

/// Shared random number generator helpers.
///
/// A single shared [Random] instance is convenient for gameplay (spawn
/// rolls, blob wobble phases, etc.) while still allowing callers to pass
/// their own seeded [Random] for deterministic tests.
final Random sharedRng = Random();

/// Returns a random double in `[min, max)`.
double randomRange(Random rng, double min, double max) {
  return min + rng.nextDouble() * (max - min);
}

/// Rolls a `0..1` chance and returns true if it succeeds.
bool rollChance(Random rng, double chance) => rng.nextDouble() < chance;
