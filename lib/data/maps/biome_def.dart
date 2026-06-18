import 'dart:ui';

/// Static definition of a "map" / biome the player fights through.
///
/// The campaign is split into themed biomes, one per 3-round section (see
/// [RoundDef.sectionIndex]). Each biome restyles the arena - background
/// gradient plus the slow-drifting decorative blobs - and carries a slice of
/// the saliva-detection storyline that frames the whole run: the player
/// chases pancreatic cancer's chemical signal from the bloodstream, into the
/// pancreas where PDAC begins, and finally to the salivary gland, where a new
/// saliva test can catch the disease early enough to fight back.
///
/// To add another map, add a [BiomeDef] with the next [sectionIndex] to
/// `biome_catalog.dart` and add the matching rounds to `round_catalog.dart`.
class BiomeDef {
  const BiomeDef({
    required this.id,
    required this.sectionIndex,
    required this.displayName,
    required this.tagline,
    required this.intro,
    required this.backgroundColors,
    required this.decorColor,
    required this.decorAccent,
    this.decorBlobCount = 6,
  });

  final String id;

  /// 1-based. Matches [RoundDef.sectionIndex], so any round maps to a biome.
  final int sectionIndex;

  /// Short map name shown in the HUD (e.g. "The Bloodstream Sea").
  final String displayName;

  /// One-line flavor subtitle.
  final String tagline;

  /// Longer narrative shown once - as a transient context banner - when the
  /// player first enters this biome (the opening round of its section). Keeps
  /// the story moving without a blocking cutscene.
  final String intro;

  /// Top-to-bottom gradient stops painted behind the arena. Two or more
  /// colors.
  final List<Color> backgroundColors;

  /// Fill and accent colors for the decorative background blobs that drift in
  /// this biome.
  final Color decorColor;
  final Color decorAccent;

  /// How many decorative blobs drift in this biome's backdrop.
  final int decorBlobCount;
}
