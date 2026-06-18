import 'dart:ui';

import '../../theme/palette.dart';
import '../categories.dart';
import 'enemy_def.dart';

/// The full enemy ("germ") roster.
///
/// [virus], [bacteria], and [fungalSpore] appear from round 1. [parasite]
/// is introduced in round 4 and [dysplasticCell] in round 7, escalating the
/// mob mix as the rounds progress (see `data/rounds/round_catalog.dart`).
class EnemyCatalog {
  EnemyCatalog._();

  static const virus = EnemyDef(
    id: 'virus',
    displayName: 'Virus',
    description:
        'A small, fast-moving invader. When destroyed it may split into '
        'smaller copies - a game way to show an infection still spreading, '
        'not literal virus replication.',
    category: ImmuneCategory.innate,
    baseHealth: 3,
    baseSpeed: 95,
    baseRadius: 12,
    contactDamagePerSecond: 8,
    coinValue: 1,
    behavior: EnemyBehaviorId.mitosis,
    primaryColor: AppPalette.innateColor,
    accentColor: Color(0xFFE8FBFF),
  );

  static const bacteria = EnemyDef(
    id: 'bacteria',
    displayName: 'Bacteria',
    description:
        'Protected by a biofilm - a shield that must be worn down before '
        'the bacteria itself takes damage. The shield slowly regrows if '
        'left alone.',
    category: ImmuneCategory.antibody,
    baseHealth: 8,
    baseSpeed: 55,
    baseRadius: 18,
    contactDamagePerSecond: 12,
    coinValue: 5,
    // Biofilm is an antibody-targeted threat: wrong-color fire barely scratches
    // it (and can't break the shield - see BiofilmShieldBehavior), so the
    // player must swap to the antibody weapon.
    mismatchMultiplier: 0.2,
    behavior: EnemyBehaviorId.biofilmShield,
    primaryColor: AppPalette.antibodyColor,
    accentColor: Color(0xFFF1E6FF),
  );

  static const fungalSpore = EnemyDef(
    id: 'fungal_spore',
    displayName: 'Fungal Spore',
    description:
        'On death, releases a lingering cloud of spores that damages '
        'anything caught inside it.',
    category: ImmuneCategory.cytotoxic,
    baseHealth: 5,
    baseSpeed: 70,
    baseRadius: 15,
    contactDamagePerSecond: 10,
    coinValue: 4,
    behavior: EnemyBehaviorId.sporeCloud,
    primaryColor: AppPalette.cytotoxicColor,
    accentColor: Color(0xFFFFE0D6),
  );

  /// Introduced in round 4. Lunges faster once badly wounded - a desperate
  /// dash for a new host.
  static const parasite = EnemyDef(
    id: 'parasite',
    displayName: 'Parasite',
    description:
        'Latches onto its host and drains health over time, then lunges in a '
        'desperate burst once badly wounded. Antibody tags help the immune '
        'system flush out hidden invaders like this.',
    category: ImmuneCategory.antibody,
    baseHealth: 6,
    baseSpeed: 85,
    baseRadius: 14,
    contactDamagePerSecond: 18,
    coinValue: 5,
    behavior: EnemyBehaviorId.enrage,
    primaryColor: AppPalette.antibodyColor,
    accentColor: Color(0xFFF4E2FF),
  );

  /// Introduced in round 7. Regenerates health if left alone, mirroring
  /// abnormal cells that keep growing rather than dying off - and
  /// foreshadows the boss mutation/resistance mechanic.
  static const dysplasticCell = EnemyDef(
    id: 'dysplastic_cell',
    displayName: 'Dysplastic Cell',
    description:
        'An abnormal cell that keeps growing if left alone, slowly '
        'regenerating health until it is finished off.',
    category: ImmuneCategory.cytotoxic,
    baseHealth: 12,
    baseSpeed: 45,
    baseRadius: 22,
    contactDamagePerSecond: 15,
    coinValue: 10,
    // Abnormal cell that regenerates: mismatched fire can't out-pace its
    // healing, so the player has to bring the matching cytotoxic response.
    mismatchMultiplier: 0.15,
    behavior: EnemyBehaviorId.regeneration,
    primaryColor: AppPalette.cytotoxicColor,
    accentColor: Color(0xFFFFDCE3),
  );

  /// Introduced in round 3. Represents extracellular vesicles and other
  /// measurable clues that may travel through fluids and show up in saliva.
  static const biomarkerVesicle = EnemyDef(
    id: 'biomarker_vesicle',
    displayName: 'Biomarker Vesicle',
    description:
        'A fast signal packet carrying molecular clues. When destroyed, it '
        'bursts into a short-lived signal flare that forces quick movement. '
        'Saliva is being explored by scientists as one possible sample source '
        'for PDAC biomarkers - it is not a working test yet.',
    category: ImmuneCategory.antibody,
    baseHealth: 4,
    baseSpeed: 120,
    baseRadius: 11,
    contactDamagePerSecond: 8,
    coinValue: 4,
    behavior: EnemyBehaviorId.biomarkerSignal,
    primaryColor: AppPalette.antibodyColor,
    accentColor: Color(0xFFEDE6FF),
  );

  /// Introduced in round 5. Tumor-supporting stromal cells protect nearby
  /// threats, making target priority matter.
  static const stromalFibroblast = EnemyDef(
    id: 'stromal_fibroblast',
    displayName: 'Stromal Fibroblast',
    description:
        'A support cell from the tumor microenvironment. It heals and '
        'shields nearby threats, so clearing it early prevents a swarm from '
        'becoming much tougher.',
    category: ImmuneCategory.cytotoxic,
    baseHealth: 10,
    baseSpeed: 42,
    baseRadius: 20,
    contactDamagePerSecond: 10,
    coinValue: 8,
    // Tumor-support cell: even more resistant to wrong-color fire than the
    // default, so it can't be bulldozed - clearing it rewards bringing the
    // matching cytotoxic weapon.
    mismatchMultiplier: 0.18,
    behavior: EnemyBehaviorId.stromalSupport,
    primaryColor: AppPalette.cytotoxicColor,
    // Dull, greyed core so the stromal "support tissue" reads differently from
    // the bright-pink dysplastic cell (both cytotoxic-red). Lightness-only
    // change within the warm family, so it never reads as another category.
    accentColor: Color(0xFFD6BDB7),
  );

  /// Introduced in round 5. Leaves mucin residue that creates temporary
  /// area denial.
  static const mucinBlob = EnemyDef(
    id: 'mucin_blob',
    displayName: 'Mucin Blob',
    description:
        'A sticky mucin barrier that sheds harmful residue as it moves. Some '
        'pancreatic tumors make abnormal mucins like this, and it turns '
        'straight-line kiting into a positioning puzzle.',
    category: ImmuneCategory.innate,
    baseHealth: 9,
    baseSpeed: 50,
    baseRadius: 19,
    contactDamagePerSecond: 12,
    coinValue: 5,
    behavior: EnemyBehaviorId.mucinTrail,
    primaryColor: AppPalette.innateColor,
    // Deeper, gel-like blue core so the mucin blob is distinguishable at a
    // glance from the bright near-white virus (both innate-blue). Same hue
    // family, so the category read is unchanged - only the lightness differs.
    accentColor: Color(0xFFAAD2E6),
  );

  /// Introduced in round 7. Low-health signal clutter that distracts
  /// auto-targeting and makes the salivary detection section feel busier
  /// without adding many expensive high-HP enemies.
  static const decoySignal = EnemyDef(
    id: 'decoy_signal',
    displayName: 'Decoy Signal',
    description:
        'A false molecular clue. It is fragile, but it can pull weapon fire '
        'away from dangerous targets unless you keep moving and swapping.',
    category: ImmuneCategory.antibody,
    baseHealth: 2,
    baseSpeed: 80,
    baseRadius: 9,
    contactDamagePerSecond: 3,
    coinValue: 1,
    behavior: EnemyBehaviorId.decoySignal,
    primaryColor: AppPalette.antibodyColor,
    accentColor: Color(0xFFF6F0FF),
  );

  /// All enemies in the catalog, keyed by id.
  static const Map<String, EnemyDef> all = {
    'virus': virus,
    'bacteria': bacteria,
    'fungal_spore': fungalSpore,
    'parasite': parasite,
    'dysplastic_cell': dysplasticCell,
    'biomarker_vesicle': biomarkerVesicle,
    'stromal_fibroblast': stromalFibroblast,
    'mucin_blob': mucinBlob,
    'decoy_signal': decoySignal,
  };
}
