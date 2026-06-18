import 'dart:ui';

import 'biome_def.dart';

/// The campaign's maps, one per 3-round section.
///
/// The progression follows the saliva-detection story: a new saliva test
/// picks up a danger signal (section 1, the bloodstream), the player traces
/// it to where pancreatic cancer begins (section 2, the pancreas), and makes
/// a final stand where that signal surfaces and can be detected early
/// (section 3, the salivary gland).
///
/// Enemy mixes are still defined per round in `round_catalog.dart`; the early
/// rounds are already virus-heavy, which fits the open "ocean" of the
/// bloodstream. A future extension could weight spawns by biome here.
class BiomeCatalog {
  BiomeCatalog._();

  static const bloodstream = BiomeDef(
    id: 'bloodstream',
    sectionIndex: 1,
    displayName: 'The Bloodstream Sea',
    tagline: 'A vast current swarming with viruses.',
    intro:
        'Scientists are studying whether a saliva test might one day catch '
        'pancreatic cancer early. In this story we imagine that idea working: '
        'a test picks up a faint danger signal somewhere in the body. You are '
        'a microscopic immune defender - dive into the bloodstream, clear the '
        'viral swarm, and help trace the signal to its source. Tip: match '
        'your weapon to an enemy\'s color for bonus damage, and swap often!',
    backgroundColors: [Color(0xFF03101C), Color(0xFF06243A), Color(0xFF0A3A55)],
    decorColor: Color(0xFF1F5F82),
    decorAccent: Color(0xFF4FB6E0),
    decorBlobCount: 7,
  );

  static const pancreas = BiomeDef(
    id: 'pancreas',
    sectionIndex: 2,
    displayName: 'The Pancreas',
    tagline: 'Deep in the gland where the trouble begins.',
    intro:
        'The signal leads here - the pancreas, where PDAC (pancreatic cancer) '
        'can first take hold. These threats are your own cells gone wrong, '
        'not germs - dug in and tougher. Hold the line while we imagine what a '
        'saliva test like this could one day detect.',
    // Deep, very desaturated neutral grey-mauve tissue. Dark enough that ALL
    // three category colors + gold pop, and deliberately OFF the saturated
    // violet axis so it doesn't camouflage antibody (violet) enemies the way a
    // plum background would, nor the cytotoxic-red the old warm bg did.
    backgroundColors: [Color(0xFF141118), Color(0xFF221C26), Color(0xFF2E2630)],
    decorColor: Color(0xFF3A3340),
    decorAccent: Color(0xFF6E6478),
    decorBlobCount: 6,
  );

  static const salivaryGland = BiomeDef(
    id: 'salivary_gland',
    sectionIndex: 3,
    displayName: 'The Salivary Gland',
    tagline: 'Where the saliva test makes its stand.',
    intro:
        'Some cancer biomarkers may travel from the pancreas all the way up '
        'to your saliva - which is why scientists are exploring whether a '
        'saliva test could one day spot PDAC early. This is that idea in '
        'action: the test has caught the warning signal here in the saliva, '
        'and your job is to clear it EARLY - before it can spread and turn '
        'metastatic. Catching it this early is the whole point of the test. '
        'Keep mixing your responses: a cancer that carries driver mutations '
        'can slip past any single response used on its own, so a varied '
        'defense works better.',
    backgroundColors: [Color(0xFF04140F), Color(0xFF0A2C22), Color(0xFF114133)],
    decorColor: Color(0xFF1F7A5E),
    decorAccent: Color(0xFF5CD6A8),
    decorBlobCount: 7,
  );

  /// All biomes keyed by their [BiomeDef.sectionIndex].
  static const Map<int, BiomeDef> bySection = {
    1: bloodstream,
    2: pancreas,
    3: salivaryGland,
  };

  /// Biome for a given round number (1-based). Sections are three rounds
  /// each; falls back to the first biome for out-of-range rounds.
  static BiomeDef forRound(int roundNumber) {
    final section = ((roundNumber - 1) ~/ 3) + 1;
    return bySection[section] ?? bloodstream;
  }

  /// True if [roundNumber] is the opening round of its biome (1, 4, 7, ...),
  /// i.e. the moment to show that biome's [BiomeDef.intro].
  static bool isBiomeOpener(int roundNumber) => (roundNumber - 1) % 3 == 0;
}
