import '../categories.dart';
import 'weapon_def.dart';
import 'weapon_traits.dart';

/// The full weapon roster for the vertical slice.
///
/// Round 1 loadout: [pistol], [shotgun], and [rifle] are equipped from the
/// start so the player has one answer for each immune-response category.
/// [smg] is offered as an end-of-round upgrade/unlock choice.
class WeaponCatalog {
  WeaponCatalog._();

  static const pistol = WeaponDef(
    id: 'pistol',
    displayName: 'Antiviral Lance',
    description:
        'A heavy innate antiviral pulse that punches clean THROUGH a line of '
        'viruses, striking everything behind the first. Slower to fire, but '
        'devastating against threats lined up by a ring or pincer spawn - and '
        'weak against scattered singles. Line up your shots.',
    category: ImmuneCategory.innate,
    role: 'Piercer',
    baseDamage: 8,
    baseFireRate: 1.6,
    bulletSpeed: 640,
    bulletRadius: 6,
    pelletCount: 1,
    spreadAngleDeg: 0,
    bulletShape: BulletShape.slug,
    pierceCount: 2,
    availableTraits: [
      WeaponTraitId.piercingShots,
      WeaponTraitId.explodingRounds,
    ],
  );

  static const shotgun = WeaponDef(
    id: 'shotgun',
    displayName: 'Antibody Spray',
    description:
        'Releases a close-range spread of antibodies that tag everything '
        'nearby, marking targets for the rest of your defenses to finish.',
    category: ImmuneCategory.antibody,
    role: 'Spread',
    baseDamage: 3,
    baseFireRate: 1.4,
    bulletSpeed: 480,
    bulletRadius: 4,
    pelletCount: 5,
    spreadAngleDeg: 28,
    bulletShape: BulletShape.pellet,
    availableTraits: [
      WeaponTraitId.cytotoxicSlow,
      WeaponTraitId.antibodyHoming,
    ],
  );

  static const smg = WeaponDef(
    id: 'smg',
    displayName: 'Innate Rapid Stream',
    description:
        'A relentless stream of innate-immunity responders that wears down '
        'invaders quickly with rapid, overlapping bursts.',
    category: ImmuneCategory.innate,
    role: 'Rapid',
    baseDamage: 2,
    baseFireRate: 8.0,
    bulletSpeed: 560,
    bulletRadius: 3.5,
    pelletCount: 1,
    spreadAngleDeg: 4,
    bulletShape: BulletShape.dart,
    availableTraits: [
      WeaponTraitId.lifestealRounds,
      WeaponTraitId.antibodyHoming,
    ],
  );

  static const rifle = WeaponDef(
    id: 'rifle',
    displayName: 'Cytotoxic Striker',
    description:
        'A heavy-hitting cytotoxic responder. Slow but powerful pulses that '
        'destroy infected and abnormal cells outright.',
    category: ImmuneCategory.cytotoxic,
    role: 'Marksman',
    baseDamage: 7,
    baseFireRate: 2.2,
    bulletSpeed: 600,
    bulletRadius: 6,
    pelletCount: 1,
    spreadAngleDeg: 0,
    bulletShape: BulletShape.slug,
    availableTraits: [
      WeaponTraitId.explodingRounds,
      WeaponTraitId.piercingShots,
    ],
  );

  static const enzymeSprayer = WeaponDef(
    id: 'enzyme_sprayer',
    displayName: 'Enzyme Sprayer',
    description:
        'A short-range cytotoxic sprayer that coats abnormal cells with '
        'digestive enzyme bursts. Great for clearing sticky swarms.',
    category: ImmuneCategory.cytotoxic,
    role: 'Sprayer',
    baseDamage: 2.0,
    baseFireRate: 3.6,
    bulletSpeed: 430,
    bulletRadius: 4,
    pelletCount: 3,
    spreadAngleDeg: 18,
    bulletShape: BulletShape.pellet,
    availableTraits: [
      WeaponTraitId.cytotoxicSlow,
      WeaponTraitId.lifestealRounds,
    ],
  );

  static const macrophageLauncher = WeaponDef(
    id: 'macrophage_launcher',
    displayName: 'Macrophage Launcher',
    description:
        'Launches heavy innate-immunity bursts that punch through clustered '
        'threats, like big cleanup cells engulfing debris.',
    category: ImmuneCategory.innate,
    role: 'Heavy AoE',
    baseDamage: 8,
    baseFireRate: 2.0,
    bulletSpeed: 470,
    bulletRadius: 7,
    bulletShape: BulletShape.slug,
    availableTraits: [
      WeaponTraitId.explodingRounds,
      WeaponTraitId.piercingShots,
    ],
  );

  static const salivaScanner = WeaponDef(
    id: 'saliva_scanner',
    displayName: 'Saliva Scanner',
    description:
        'Fires precise antibody-targeted pulses that seek out biomarker '
        'signals and decoys in crowded saliva samples.',
    category: ImmuneCategory.antibody,
    role: 'Precision',
    baseDamage: 1.8,
    baseFireRate: 7.0,
    bulletSpeed: 620,
    bulletRadius: 3.5,
    spreadAngleDeg: 3,
    bulletShape: BulletShape.dart,
    availableTraits: [
      WeaponTraitId.antibodyHoming,
      WeaponTraitId.piercingShots,
    ],
  );

  /// All weapons in the catalog, keyed by id.
  static const Map<String, WeaponDef> all = {
    'pistol': pistol,
    'shotgun': shotgun,
    'smg': smg,
    'rifle': rifle,
    'enzyme_sprayer': enzymeSprayer,
    'macrophage_launcher': macrophageLauncher,
    'saliva_scanner': salivaScanner,
  };

  /// Weapons a brand-new save owns - one per immune category so the player
  /// always has a matched answer. The player buys the rest in the gold shop
  /// ([shopUnlockCost]) and equips any three per round via the loadout screen.
  static const List<String> startingLoadout = ['pistol', 'shotgun', 'rifle'];

  /// Gold cost to buy each non-starting weapon in the persistent gold shop.
  /// Starting-loadout weapons are owned from the start and omitted here.
  static const Map<String, int> shopUnlockCost = {
    'smg': 120,
    'enzyme_sprayer': 190,
    'macrophage_launcher': 200,
    'saliva_scanner': 200,
  };
}
