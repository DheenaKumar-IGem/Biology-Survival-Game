import 'dart:math' as math;

import 'game_logic.dart';

enum BuildRarity {
  common(
    label: 'Common',
    colorValue: 0xFF95D5B2,
    levelGain: 1,
  ),
  rare(
    label: 'Rare',
    colorValue: 0xFFFFD166,
    levelGain: 1,
  ),
  epic(
    label: 'Epic',
    colorValue: 0xFFE0AAFF,
    levelGain: 1,
  );

  const BuildRarity({
    required this.label,
    required this.colorValue,
    required this.levelGain,
  });

  final String label;
  final int colorValue;
  final int levelGain;
}

enum PassiveType {
  sporeMatrix,
  receptorMesh,
  denseCore,
  mirrorMembrane,
  pulseRhythm,
  railSpines,
  focusLens,
  haloGland;
}

// Edit these values to rename every passive in one place.
final Map<PassiveType, String> passiveTitles = <PassiveType, String>{
  PassiveType.sporeMatrix: 'Chamber',
  PassiveType.receptorMesh: 'Tracking',
  PassiveType.denseCore: 'Anchor',
  PassiveType.mirrorMembrane: 'Mirror',
  PassiveType.pulseRhythm: 'Clock',
  PassiveType.railSpines: 'Piercing Barbs',
  PassiveType.focusLens: 'Focus Lens',
  PassiveType.haloGland: 'Ring',
};

final Map<PassiveType, String> passiveDescriptions = <PassiveType, String>{
  PassiveType.sporeMatrix:
      'Adds wider spread and stronger close-range coverage.',
  PassiveType.receptorMesh:
      'Improves tracking and strengthens turret-style attacks.',
  PassiveType.denseCore: 'Adds heavier hits and stronger burst impact.',
  PassiveType.mirrorMembrane:
      'Tightens mirrored shots and direction-change attacks.',
  PassiveType.pulseRhythm: 'Speeds repeated bursts and steady pulse effects.',
  PassiveType.railSpines: 'Improves piercing lines and beam-style attacks.',
  PassiveType.focusLens: 'Boosts accurate long-range shots.',
  PassiveType.haloGland: 'Expands ring pressure and cross-pattern attacks.',
};

extension PassiveTypeDisplay on PassiveType {
  String get title => passiveTitles[this] ?? name;
  String get description => passiveDescriptions[this] ?? '';
}

enum BuildOfferType {
  primaryUpgrade,
  primaryBranch,
  supportUnlock,
  supportUpgrade,
  supportBranch,
  passiveUnlock,
  passiveUpgrade,
}

class BuildOffer {
  const BuildOffer({
    required this.type,
    required this.rarity,
    this.weapon,
    this.supportWeapon,
    this.passive,
    required this.title,
    required this.description,
    required this.effectLine,
    this.evolutionHint,
    this.branchId,
  });

  final BuildOfferType type;
  final BuildRarity rarity;
  final WeaponType? weapon;
  final MiniWeaponType? supportWeapon;
  final PassiveType? passive;
  final String title;
  final String description;
  final String effectLine;
  final String? evolutionHint;
  final String? branchId;
}

enum SupportOptionType {
  heal(
    title: 'Restore Life',
    description: 'Recover 1 lost life before the next round.',
    cost: 26,
  ),
  shield(
    title: 'Shield Membrane',
    description: 'Start the next round with a one-hit shield charge.',
    cost: 20,
  ),
  magnet(
    title: 'Magnet Pulse',
    description: 'Begin the next round with a temporary pickup pulse.',
    cost: 18,
  ),
  soften(
    title: 'Soften Next Round',
    description:
        'Reduce the next round\'s opening pressure and suppress the early anchor threat.',
    cost: 24,
  );

  const SupportOptionType({
    required this.title,
    required this.description,
    required this.cost,
  });

  final String title;
  final String description;
  final int cost;
}

enum CombatUpgradeKind {
  tempo,
  stride,
  vacuum,
  force,
  primaryAmp,
  supportAmp,
  passiveAmp,
}

// Edit these values to rename the base combat passives in one place.
final Map<CombatUpgradeKind, String> combatUpgradeTitles =
    <CombatUpgradeKind, String>{};

final Map<CombatUpgradeKind, String> combatUpgradeDescriptions =
    <CombatUpgradeKind, String>{};

extension CombatUpgradeKindDisplay on CombatUpgradeKind {
  String get title => combatUpgradeTitles[this] ?? name;
  String get description => combatUpgradeDescriptions[this] ?? '';
}

class CombatUpgradeOffer {
  const CombatUpgradeOffer({
    required this.kind,
    required this.title,
    required this.description,
    this.supportWeapon,
    this.passive,
  });

  final CombatUpgradeKind kind;
  final String title;
  final String description;
  final MiniWeaponType? supportWeapon;
  final PassiveType? passive;
}

class BranchDefinition {
  const BranchDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.effectLine,
  });

  final String id;
  final String title;
  final String description;
  final String effectLine;
}

class QuizDraftProfile {
  const QuizDraftProfile({
    required this.choiceCount,
    required this.pressureLevel,
    required this.lowerQuality,
    required this.grantsReroll,
    required this.title,
    required this.summary,
    required this.scoreBonus,
  });

  final int choiceCount;
  final int pressureLevel;
  final bool lowerQuality;
  final bool grantsReroll;
  final String title;
  final String summary;
  final int scoreBonus;
}

QuizDraftProfile resolveDraftProfile(int correctCount) {
  switch (correctCount) {
    case 3:
      return const QuizDraftProfile(
        choiceCount: 3,
        pressureLevel: 0,
        lowerQuality: false,
        grantsReroll: true,
        title: '3 / 3 correct',
        summary: 'Perfect round. You get 1 free reroll on this round\'s draft.',
        scoreBonus: 120,
      );
    case 2:
      return const QuizDraftProfile(
        choiceCount: 3,
        pressureLevel: 0,
        lowerQuality: false,
        grantsReroll: false,
        title: '2 / 3 correct',
        summary: 'Solid round. Standard 3-choice draft.',
        scoreBonus: 70,
      );
    case 1:
      return const QuizDraftProfile(
        choiceCount: 3,
        pressureLevel: 1,
        lowerQuality: false,
        grantsReroll: false,
        title: '1 / 3 correct',
        summary:
            'Standard draft, but the next round opens with extra pressure.',
        scoreBonus: 20,
      );
    default:
      return const QuizDraftProfile(
        choiceCount: 3,
        pressureLevel: 2,
        lowerQuality: true,
        grantsReroll: false,
        title: '0 / 3 correct',
        summary:
            'The next round opens rougher, and your draft quality is a little worse.',
        scoreBonus: -20,
      );
  }
}

PassiveType evolutionPassiveForWeapon(WeaponType weapon) {
  switch (weapon) {
    case WeaponType.scatter:
      return PassiveType.sporeMatrix;
    case WeaponType.homing:
      return PassiveType.receptorMesh;
    case WeaponType.heavy:
      return PassiveType.denseCore;
    case WeaponType.twin:
      return PassiveType.mirrorMembrane;
    case WeaponType.burst:
      return PassiveType.pulseRhythm;
    case WeaponType.pierce:
      return PassiveType.railSpines;
    case WeaponType.sniper:
      return PassiveType.focusLens;
    case WeaponType.nova:
      return PassiveType.haloGland;
    case WeaponType.standard:
      return PassiveType.focusLens;
  }
}

String evolvedWeaponTitle(WeaponType weapon) {
  switch (weapon) {
    case WeaponType.scatter:
      return 'Venom Haze';
    case WeaponType.homing:
      return 'Receptor Bloom';
    case WeaponType.heavy:
      return 'Cataclysm Core';
    case WeaponType.twin:
      return 'Mirror Bloom';
    case WeaponType.burst:
      return 'Pulse Organ';
    case WeaponType.pierce:
      return 'Rail Bloom';
    case WeaponType.sniper:
      return 'Surgical Beam';
    case WeaponType.nova:
      return 'Halo Storm';
    case WeaponType.standard:
      return 'Starter Bloom';
  }
}

PassiveType? evolutionPassiveForMiniWeapon(MiniWeaponType weapon) {
  switch (weapon) {
    case MiniWeaponType.sentryPod:
      return PassiveType.receptorMesh;
    case MiniWeaponType.burstBeacon:
      return null;
    case MiniWeaponType.lineDrive:
      return PassiveType.railSpines;
    case MiniWeaponType.snapPrism:
      return PassiveType.mirrorMembrane;
    case MiniWeaponType.rhythmRing:
      return PassiveType.pulseRhythm;
    case MiniWeaponType.crossCadence:
      return PassiveType.haloGland;
  }
}

MiniWeaponType? miniWeaponForEvolutionPassive(PassiveType passive) {
  switch (passive) {
    case PassiveType.receptorMesh:
      return MiniWeaponType.sentryPod;
    case PassiveType.denseCore:
      return null;
    case PassiveType.railSpines:
      return MiniWeaponType.lineDrive;
    case PassiveType.mirrorMembrane:
      return MiniWeaponType.snapPrism;
    case PassiveType.pulseRhythm:
      return MiniWeaponType.rhythmRing;
    case PassiveType.haloGland:
      return MiniWeaponType.crossCadence;
    case PassiveType.sporeMatrix:
    case PassiveType.focusLens:
      return null;
  }
}

String evolvedMiniWeaponTitle(MiniWeaponType weapon) {
  return '${weapon.title} Prime';
}

List<BranchDefinition> primaryBranchDefinitions(WeaponType weapon) {
  switch (weapon) {
    case WeaponType.standard:
      return const <BranchDefinition>[
        BranchDefinition(
          id: 'steady_line',
          title: 'Steady Line',
          description:
              'Keep the lane straight and sharpen every follow-up shot.',
          effectLine: 'Straighter volleys with cleaner follow-through.',
        ),
        BranchDefinition(
          id: 'split_line',
          title: 'Split Line',
          description:
              'Peel off side shots so the starter lane covers more space.',
          effectLine: 'Adds small side shots around the main line.',
        ),
      ];
    case WeaponType.scatter:
      return const <BranchDefinition>[
        BranchDefinition(
          id: 'shrapnel_fan',
          title: 'Shrapnel Fan',
          description:
              'Spread the cone wider until it becomes a front-wall blast.',
          effectLine: 'Wider cone with extra flank pellets.',
        ),
        BranchDefinition(
          id: 'cluster_bloom',
          title: 'Cluster Bloom',
          description:
              'Keep the cone tighter, but shed rear spores behind each shot.',
          effectLine: 'Adds rear spore shots behind the main burst.',
        ),
      ];
    case WeaponType.homing:
      return const <BranchDefinition>[
        BranchDefinition(
          id: 'twin_seekers',
          title: 'Twin Seekers',
          description:
              'Launch a paired set of seekers so tracking covers more targets.',
          effectLine: 'Fires paired seekers with gentler divergence.',
        ),
        BranchDefinition(
          id: 'hunter_surge',
          title: 'Hunter Surge',
          description:
              'Tighten the tracking curve and make every hit punch harder.',
          effectLine: 'Sharper lock-on with stronger impact.',
        ),
      ];
    case WeaponType.heavy:
      return const <BranchDefinition>[
        BranchDefinition(
          id: 'crush_core',
          title: 'Crush Core',
          description:
              'Grow the slug into a slow crushing round that keeps pushing.',
          effectLine: 'Bigger rounds with extra pierce.',
        ),
        BranchDefinition(
          id: 'shock_core',
          title: 'Shock Core',
          description:
              'Break the heavy shot into a core round plus shock splinters.',
          effectLine: 'Adds side shock fragments to each shot.',
        ),
      ];
    case WeaponType.twin:
      return const <BranchDefinition>[
        BranchDefinition(
          id: 'rail_pair',
          title: 'Rail Pair',
          description:
              'Tighten the pair into layered rails that hammer one lane.',
          effectLine: 'Adds an extra inner pair of parallel shots.',
        ),
        BranchDefinition(
          id: 'mirror_sweep',
          title: 'Mirror Sweep',
          description:
              'Angle the outer pair so the weapon sweeps a wider front.',
          effectLine: 'Adds outward mirror shots for broader coverage.',
        ),
      ];
    case WeaponType.burst:
      return const <BranchDefinition>[
        BranchDefinition(
          id: 'needle_burst',
          title: 'Needle Burst',
          description: 'Compress the burst into a tight lance of fast needles.',
          effectLine: 'Tighter burst with faster follow-up.',
        ),
        BranchDefinition(
          id: 'bloom_burst',
          title: 'Bloom Burst',
          description:
              'Widen the volley and let extra petals spill off the sides.',
          effectLine: 'Adds wide petals around the burst.',
        ),
      ];
    case WeaponType.pierce:
      return const <BranchDefinition>[
        BranchDefinition(
          id: 'lance_drive',
          title: 'Lance Drive',
          description:
              'Stretch the rail into one brutal spear that keeps drilling.',
          effectLine: 'Longer rail shot with more pierce.',
        ),
        BranchDefinition(
          id: 'fork_rail',
          title: 'Fork Rail',
          description:
              'Split the rail into a paired lane that forks through crowds.',
          effectLine: 'Adds a second offset rail shot.',
        ),
      ];
    case WeaponType.sniper:
      return const <BranchDefinition>[
        BranchDefinition(
          id: 'pinpoint',
          title: 'Pinpoint',
          description: 'Turn every shot into a razor-straight execution round.',
          effectLine: 'Harder-hitting precision shots.',
        ),
        BranchDefinition(
          id: 'afterimage',
          title: 'Afterimage',
          description:
              'Trail each sniper shot with a faint echo that keeps the lane hot.',
          effectLine: 'Adds a follow-up echo round.',
        ),
      ];
    case WeaponType.nova:
      return const <BranchDefinition>[
        BranchDefinition(
          id: 'sunburst',
          title: 'Sunburst',
          description:
              'Densify the starburst and lean it harder into the front arc.',
          effectLine: 'Denser front-weighted starbursts.',
        ),
        BranchDefinition(
          id: 'orbit_bloom',
          title: 'Orbit Bloom',
          description:
              'Spin a second ring between bursts so the nova never fully closes.',
          effectLine: 'Adds an offset follow-up ring.',
        ),
      ];
  }
}

List<BranchDefinition> supportBranchDefinitions(MiniWeaponType weapon) {
  switch (weapon) {
    case MiniWeaponType.sentryPod:
      return const <BranchDefinition>[
        BranchDefinition(
          id: 'needle_nest',
          title: 'Needle Nest',
          description:
              'Make each turret a fast hunter that opens with a focused volley.',
          effectLine: 'Focused multi-shot turrets with longer reach.',
        ),
        BranchDefinition(
          id: 'mortar_nest',
          title: 'Mortar Nest',
          description:
              'Turn the turret into a safer zone-control nest that seeds mines nearby.',
          effectLine: 'Turrets seed larger bio-mines while they fire.',
        ),
      ];
    case MiniWeaponType.burstBeacon:
      return const <BranchDefinition>[];
    case MiniWeaponType.lineDrive:
      return const <BranchDefinition>[
        BranchDefinition(
          id: 'sweep_blade',
          title: 'Sweep Blade',
          description:
              'Fan the beam into layered sweep lines that clear a broader lane in front of you.',
          effectLine: 'Adds wider side sweeps and stronger pushback.',
        ),
        BranchDefinition(
          id: 'spore_cutter',
          title: 'Spore Cutter',
          description:
              'Carve the lane with the beam and seed corrosive spore patches where it lands.',
          effectLine:
              'Beam drops larger damaging spore patches along its path.',
        ),
      ];
    case MiniWeaponType.snapPrism:
      return const <BranchDefinition>[
        BranchDefinition(
          id: 'crosswind',
          title: 'Crosswind',
          description:
              'Every snap throws extra fans into both side lanes and fills more of the screen.',
          effectLine: 'Adds stronger side fans on every snap.',
        ),
        BranchDefinition(
          id: 'echo_fan',
          title: 'Echo Fan',
          description:
              'Each snap repeats with a second lighter fan through the same lane.',
          effectLine: 'Adds a second echo fan after each snap.',
        ),
      ];
    case MiniWeaponType.rhythmRing:
      return const <BranchDefinition>[
        BranchDefinition(
          id: 'tight_pulse',
          title: 'Tight Pulse',
          description:
              'Speed the pulse cycle up and shove close enemies away more often.',
          effectLine: 'Faster defensive pulses with stronger close pressure.',
        ),
        BranchDefinition(
          id: 'orbit_pulse',
          title: 'Orbit Pulse',
          description:
              'Spin orbit cells around you between pulses to grind nearby threats.',
          effectLine: 'Adds larger orbiting cells between pulses.',
        ),
      ];
    case MiniWeaponType.crossCadence:
      return const <BranchDefinition>[
        BranchDefinition(
          id: 'lattice',
          title: 'Lattice',
          description:
              'Add diagonals until every burst cuts a lattice through the room.',
          effectLine: 'Cadence bursts gain diagonal lanes and extra pierce.',
        ),
        BranchDefinition(
          id: 'double_tap',
          title: 'Double Tap',
          description:
              'Every cadence pulse repeats with a second crossfire volley.',
          effectLine: 'Each burst fires a second rotating volley.',
        ),
      ];
  }
}

String? primaryBranchTitle(WeaponType weapon, String? branchId) {
  for (final branch in primaryBranchDefinitions(weapon)) {
    if (branch.id == branchId) {
      return branch.title;
    }
  }
  return null;
}

String? supportBranchTitle(MiniWeaponType weapon, String? branchId) {
  for (final branch in supportBranchDefinitions(weapon)) {
    if (branch.id == branchId) {
      return branch.title;
    }
  }
  return null;
}

List<WeaponType> buildStarterWeaponChoices(math.Random rng) {
  final pool = [
    WeaponType.scatter,
    WeaponType.homing,
    WeaponType.heavy,
    WeaponType.twin,
    WeaponType.burst,
    WeaponType.pierce,
    WeaponType.sniper,
    WeaponType.nova,
  ]..shuffle(rng);
  return pool.take(3).toList();
}

List<MiniWeaponType> buildStarterMiniWeaponChoices(math.Random rng) {
  final pool = [...availableMiniWeaponTypes]..shuffle(rng);
  return pool.take(3).toList();
}

BuildRarity _rollRarity(
  math.Random rng, {
  required bool premium,
  required bool lowerQuality,
}) {
  final roll = rng.nextDouble();
  if (premium) {
    if (roll < 0.28) {
      return BuildRarity.epic;
    }
    return BuildRarity.rare;
  }
  if (lowerQuality) {
    return roll < 0.85 ? BuildRarity.common : BuildRarity.rare;
  }
  if (roll < 0.68) {
    return BuildRarity.common;
  }
  if (roll < 0.92) {
    return BuildRarity.rare;
  }
  return BuildRarity.epic;
}

String _miniWeaponLevelEffect(MiniWeaponType weapon, int level) {
  switch (weapon) {
    case MiniWeaponType.sentryPod:
      switch (level) {
        case 1:
          return 'Lv.1 - Quickly drops a defensive turret that covers nearby threats.';
        case 2:
          return 'Lv.2 - Turrets deploy sooner, last longer, and reach farther.';
        case 3:
          return 'Lv.3 - Choose hunter turrets or mine-seeding zone turrets.';
        case 4:
          return 'Lv.4 - Turrets deploy more often and hold the lane longer.';
        case 5:
          return 'Lv.5 - Turret bolts hit harder and travel farther.';
        case 6:
          return 'Lv.6 - Turrets strengthen their coverage window.';
        case 7:
          return 'Lv.7 - Turrets deploy a second flank nest.';
        default:
          return 'Lv.8 - Turret reaches its evolution threshold.';
      }
    case MiniWeaponType.burstBeacon:
      return 'Retired prototype weapon.';
    case MiniWeaponType.lineDrive:
      switch (level) {
        case 1:
          return 'Lv.1 - Carves a forward beam lane that nudges enemies back.';
        case 2:
          return 'Lv.2 - Beam reaches farther and sweeps a wider angle.';
        case 3:
          return 'Lv.3 - Choose a wide pushback sweep or lingering spore trail.';
        case 4:
          return 'Lv.4 - Beam sweeps more often.';
        case 5:
          return 'Lv.5 - Beam adds a second cutting pulse down the lane.';
        case 6:
          return 'Lv.6 - Beam carves a longer lane with heavier pushback.';
        case 7:
          return 'Lv.7 - Beam recovers faster between sweeps.';
        default:
          return 'Lv.8 - Beam reaches its evolution threshold.';
      }
    case MiniWeaponType.snapPrism:
      switch (level) {
        case 1:
          return 'Lv.1 - Movement changes fire a forgiving forward fan.';
        case 2:
          return 'Lv.2 - Fan burst triggers from smaller turns and reaches farther.';
        case 3:
          return 'Lv.3 - Choose stronger side fans or a second echo fan.';
        case 4:
          return 'Lv.4 - Turns charge bursts faster and recover sooner.';
        case 5:
          return 'Lv.5 - Burst widens with outer blades.';
        case 6:
          return 'Lv.6 - Bursts hit harder and add rear coverage.';
        case 7:
          return 'Lv.7 - Smaller turns build into a snap burst faster.';
        default:
          return 'Lv.8 - Fan Burst reaches its evolution threshold.';
      }
    case MiniWeaponType.rhythmRing:
      switch (level) {
        case 1:
          return 'Lv.1 - Emits a panic ring that clears space around you.';
        case 2:
          return 'Lv.2 - Rings expand farther and push enemies back.';
        case 3:
          return 'Lv.3 - Choose faster defensive pulses or orbiting cells.';
        case 4:
          return 'Lv.4 - Rings pulse more often.';
        case 5:
          return 'Lv.5 - Rings hit harder.';
        case 6:
          return 'Lv.6 - Pulse radius grows again.';
        case 7:
          return 'Lv.7 - Secondary pulse pressure improves.';
        default:
          return 'Lv.8 - Pulse Ring reaches its evolution threshold.';
      }
    case MiniWeaponType.crossCadence:
      switch (level) {
        case 1:
          return 'Lv.1 - Fires steady crossfire in four directions.';
        case 2:
          return 'Lv.2 - Cross bursts fire more often and travel farther.';
        case 3:
          return 'Lv.3 - Choose diagonal lattice fire or a repeat volley.';
        case 4:
          return 'Lv.4 - Cross shots gain size and light pierce.';
        case 5:
          return 'Lv.5 - Cross bursts hit harder.';
        case 6:
          return 'Lv.6 - Add a denser layer of crossfire.';
        case 7:
          return 'Lv.7 - Cadence tightens again.';
        default:
          return 'Lv.8 - Cross reaches its evolution threshold.';
      }
  }
}

BuildOffer _supportUnlockOffer(MiniWeaponType weapon, BuildRarity rarity,
    {String? evolutionHint}) {
  return BuildOffer(
    type: BuildOfferType.supportUnlock,
    rarity: rarity,
    supportWeapon: weapon,
    title: weapon.title,
    description: weapon.description,
    effectLine: _miniWeaponLevelEffect(weapon, rarity.levelGain),
    evolutionHint: evolutionHint,
  );
}

BuildOffer _supportBranchOffer(
  MiniWeaponType weapon,
  BranchDefinition branch, {
  String? evolutionHint,
}) {
  return BuildOffer(
    type: BuildOfferType.supportBranch,
    rarity: BuildRarity.rare,
    supportWeapon: weapon,
    title: '${weapon.title}: ${branch.title}',
    description: branch.description,
    effectLine: branch.effectLine,
    evolutionHint: evolutionHint,
    branchId: branch.id,
  );
}

BuildOffer _supportUpgradeOffer(MiniWeaponType weapon, BuildRarity rarity,
    {String? evolutionHint, required int currentLevel}) {
  final targetLevel =
      math.min(miniWeaponLevelCap, currentLevel + rarity.levelGain);
  return BuildOffer(
    type: BuildOfferType.supportUpgrade,
    rarity: rarity,
    supportWeapon: weapon,
    title: weapon.title,
    description: weapon.description,
    effectLine: _miniWeaponLevelEffect(weapon, targetLevel),
    evolutionHint: evolutionHint,
  );
}

BuildOffer _passiveUnlockOffer(PassiveType passive, BuildRarity rarity,
    {String? evolutionHint}) {
  return BuildOffer(
    type: BuildOfferType.passiveUnlock,
    rarity: rarity,
    passive: passive,
    title: passive.title,
    description: passive.description,
    effectLine: 'Unlock at Lv.${rarity.levelGain}',
    evolutionHint: evolutionHint,
  );
}

BuildOffer _passiveUpgradeOffer(PassiveType passive, BuildRarity rarity,
    {String? evolutionHint}) {
  return BuildOffer(
    type: BuildOfferType.passiveUpgrade,
    rarity: rarity,
    passive: passive,
    title: passive.title,
    description: passive.description,
    effectLine:
        '+${rarity.levelGain} passive level${rarity.levelGain > 1 ? 's' : ''}',
    evolutionHint: evolutionHint,
  );
}

List<BuildOffer> buildPostLessonDraft({
  required math.Random rng,
  required WeaponType activeWeapon,
  required int activeWeaponLevel,
  required bool activeWeaponBranched,
  required Map<MiniWeaponType, int> supportWeaponLevels,
  required Set<MiniWeaponType> branchedSupportWeapons,
  required Map<PassiveType, int> passiveLevels,
  required int choiceCount,
  required bool lowerQuality,
  required Set<MiniWeaponType> evolvedSupportWeapons,
}) {
  final offers = <BuildOffer>[];
  final unlockedSupports = supportWeaponLevels.entries
      .where((entry) => entry.value > 0)
      .map((entry) => entry.key)
      .toSet();
  final ownedPassives = passiveLevels.entries
      .where((entry) => entry.value > 0)
      .map((entry) => entry.key)
      .toSet();
  final pendingSupportBranches = unlockedSupports
      .where((type) =>
          (supportWeaponLevels[type] ?? 0) >= miniWeaponBranchUnlockLevel &&
          !branchedSupportWeapons.contains(type))
      .toList();

  final supportUnlocks = unlockedSupports.length < miniWeaponSlotCap
      ? availableMiniWeaponTypes
          .where((type) => !unlockedSupports.contains(type))
          .toList()
      : <MiniWeaponType>[];
  final supportUpgrades = unlockedSupports
      .where((type) =>
          (supportWeaponLevels[type] ?? 0) < miniWeaponLevelCap &&
          ((supportWeaponLevels[type] ?? 0) < miniWeaponBranchUnlockLevel ||
              branchedSupportWeapons.contains(type)))
      .toList();

  void addBranchBundle() {
    if (pendingSupportBranches.isEmpty) {
      return;
    }
    final type =
        pendingSupportBranches[rng.nextInt(pendingSupportBranches.length)];
    final matchingPassive = evolutionPassiveForMiniWeapon(type);
    final hint = matchingPassive != null &&
            ownedPassives.contains(matchingPassive) &&
            !evolvedSupportWeapons.contains(type)
        ? 'Evolution path active'
        : null;
    offers.addAll(
      supportBranchDefinitions(type).map(
        (branch) => _supportBranchOffer(type, branch, evolutionHint: hint),
      ),
    );
  }

  BuildOffer? tryPickCategory(String category) {
    final rarity = _rollRarity(rng, premium: false, lowerQuality: lowerQuality);
    switch (category) {
      case 'supportUnlock':
        if (supportUnlocks.isEmpty ||
            unlockedSupports.length +
                    offers
                        .where((offer) =>
                            offer.type == BuildOfferType.supportUnlock)
                        .length >=
                miniWeaponSlotCap) {
          return null;
        }
        final type =
            supportUnlocks.removeAt(rng.nextInt(supportUnlocks.length));
        final matchingPassive = evolutionPassiveForMiniWeapon(type);
        final hint =
            matchingPassive != null && ownedPassives.contains(matchingPassive)
                ? 'Pairs with owned: ${matchingPassive.title}'
                : null;
        return _supportUnlockOffer(type, rarity, evolutionHint: hint);
      case 'supportUpgrade':
        if (supportUpgrades.isEmpty) {
          return null;
        }
        final type =
            supportUpgrades.removeAt(rng.nextInt(supportUpgrades.length));
        final matchingPassive = evolutionPassiveForMiniWeapon(type);
        final hint = matchingPassive != null &&
                ownedPassives.contains(matchingPassive) &&
                !evolvedSupportWeapons.contains(type)
            ? 'Evolution path active'
            : null;
        return _supportUpgradeOffer(
          type,
          rarity,
          evolutionHint: hint,
          currentLevel: supportWeaponLevels[type] ?? 0,
        );
    }
    return null;
  }

  addBranchBundle();

  if (unlockedSupports.length < 2 && supportUnlocks.isNotEmpty) {
    final offer = tryPickCategory('supportUnlock');
    if (offer != null) {
      offers.add(offer);
    }
  }

  while (offers.length < choiceCount) {
    final available = <String>[
      if (unlockedSupports.length < miniWeaponSlotCap &&
          supportUnlocks.isNotEmpty)
        'supportUnlock',
      if (supportUpgrades.isNotEmpty) 'supportUpgrade',
    ];
    if (available.isEmpty) {
      break;
    }
    final category = available[rng.nextInt(available.length)];
    final offer = tryPickCategory(category);
    if (offer == null) {
      continue;
    }
    final duplicate = offers.any((existing) =>
        existing.type == offer.type &&
        existing.weapon == offer.weapon &&
        existing.supportWeapon == offer.supportWeapon &&
        existing.passive == offer.passive &&
        existing.branchId == offer.branchId);
    if (!duplicate) {
      offers.add(offer);
    }
  }
  return offers.take(choiceCount).toList();
}

List<BuildOffer> buildBossChestOffers({
  required math.Random rng,
  required WeaponType activeWeapon,
  required int activeWeaponLevel,
  required bool activeWeaponBranched,
  required Map<MiniWeaponType, int> supportWeaponLevels,
  required Set<MiniWeaponType> branchedSupportWeapons,
  required Map<PassiveType, int> passiveLevels,
  required Set<MiniWeaponType> evolvedSupportWeapons,
}) {
  final offers = <BuildOffer>[];
  final unlockedSupports = supportWeaponLevels.entries
      .where((entry) => entry.value > 0)
      .map((entry) => entry.key)
      .toSet();
  final supportUnlocks = unlockedSupports.length < miniWeaponSlotCap
      ? availableMiniWeaponTypes
          .where((type) => !unlockedSupports.contains(type))
          .toList()
      : <MiniWeaponType>[];
  final supportUpgrades = supportWeaponLevels.entries
      .where((entry) =>
          entry.value > 0 &&
          (entry.value < miniWeaponBranchUnlockLevel ||
              branchedSupportWeapons.contains(entry.key)) &&
          entry.value < miniWeaponLevelCap)
      .map((entry) => entry.key)
      .toList();
  final pendingSupportBranches = supportWeaponLevels.entries
      .where((entry) =>
          entry.value >= miniWeaponBranchUnlockLevel &&
          !branchedSupportWeapons.contains(entry.key))
      .map((entry) => entry.key)
      .toList();
  final passiveCandidates = <PassiveType>[];
  final seenPassives = <PassiveType>{};

  void addPassiveCandidate(PassiveType passive) {
    if ((passiveLevels[passive] ?? 0) >= 5 || !seenPassives.add(passive)) {
      return;
    }
    passiveCandidates.add(passive);
  }

  for (final support in supportWeaponLevels.entries
      .where((entry) => entry.value > 0)
      .map((entry) => entry.key)) {
    final matchingPassive = evolutionPassiveForMiniWeapon(support);
    if (matchingPassive != null) {
      addPassiveCandidate(matchingPassive);
    }
  }
  for (final passive in PassiveType.values) {
    addPassiveCandidate(passive);
  }

  if (pendingSupportBranches.isNotEmpty) {
    final support =
        pendingSupportBranches[rng.nextInt(pendingSupportBranches.length)];
    final matchingPassive = evolutionPassiveForMiniWeapon(support);
    final hint = matchingPassive != null &&
            (passiveLevels[matchingPassive] ?? 0) > 0 &&
            !evolvedSupportWeapons.contains(support)
        ? 'Evolution path active'
        : null;
    offers.addAll(
      supportBranchDefinitions(support).map(
        (branch) => _supportBranchOffer(support, branch, evolutionHint: hint),
      ),
    );
  }

  supportUpgrades.shuffle(rng);
  supportUnlocks.shuffle(rng);
  passiveCandidates.shuffle(rng);
  if (supportUpgrades.isNotEmpty && offers.length < 3) {
    final support = supportUpgrades.first;
    final matchingPassive = evolutionPassiveForMiniWeapon(support);
    final hint = matchingPassive != null &&
            (passiveLevels[matchingPassive] ?? 0) > 0 &&
            !evolvedSupportWeapons.contains(support)
        ? 'Evolution path active'
        : null;
    offers.add(_supportUpgradeOffer(
        support, _rollRarity(rng, premium: true, lowerQuality: false),
        evolutionHint: hint, currentLevel: supportWeaponLevels[support] ?? 0));
  }
  if (supportUnlocks.isNotEmpty && offers.length < 3) {
    final support = supportUnlocks.first;
    final matchingPassive = evolutionPassiveForMiniWeapon(support);
    final hint =
        matchingPassive != null && (passiveLevels[matchingPassive] ?? 0) > 0
            ? 'Pairs with owned: ${matchingPassive.title}'
            : null;
    offers.add(_supportUnlockOffer(
      support,
      _rollRarity(rng, premium: true, lowerQuality: false),
      evolutionHint: hint,
    ));
  }
  if (passiveCandidates.isNotEmpty && offers.length < 3) {
    final passive = passiveCandidates.first;
    final level = passiveLevels[passive] ?? 0;
    final matchingSupport = miniWeaponForEvolutionPassive(passive);
    offers.add(
      level > 0
          ? _passiveUpgradeOffer(
              passive,
              _rollRarity(rng, premium: true, lowerQuality: false),
              evolutionHint: matchingSupport != null &&
                      (supportWeaponLevels[matchingSupport] ?? 0) > 0 &&
                      !evolvedSupportWeapons.contains(matchingSupport)
                  ? 'Evolution path active'
                  : null,
            )
          : _passiveUnlockOffer(
              passive,
              _rollRarity(rng, premium: true, lowerQuality: false),
              evolutionHint: matchingSupport != null &&
                      (supportWeaponLevels[matchingSupport] ?? 0) > 0 &&
                      !evolvedSupportWeapons.contains(matchingSupport)
                  ? 'Pairs with owned: ${matchingSupport.title}'
                  : null,
            ),
    );
  }
  while (offers.length < 3) {
    if (supportUpgrades.isNotEmpty) {
      final support = supportUpgrades[rng.nextInt(supportUpgrades.length)];
      final matchingPassive = evolutionPassiveForMiniWeapon(support);
      final hint = matchingPassive != null &&
              (passiveLevels[matchingPassive] ?? 0) > 0 &&
              !evolvedSupportWeapons.contains(support)
          ? 'Evolution path active'
          : null;
      offers.add(_supportUpgradeOffer(
        support,
        BuildRarity.rare,
        evolutionHint: hint,
        currentLevel: supportWeaponLevels[support] ?? 0,
      ));
      continue;
    }
    if (supportUnlocks.isNotEmpty) {
      offers.add(
        _supportUnlockOffer(
          supportUnlocks[rng.nextInt(supportUnlocks.length)],
          BuildRarity.rare,
        ),
      );
      continue;
    }
    if (passiveCandidates.isNotEmpty) {
      offers.add(
        _passiveUnlockOffer(
          passiveCandidates[rng.nextInt(passiveCandidates.length)],
          BuildRarity.rare,
        ),
      );
      continue;
    }
    break;
  }
  return offers.take(3).toList();
}

List<CombatUpgradeOffer> buildCombatUpgradeOffers({
  required math.Random rng,
  required WeaponType activeWeapon,
  required Map<MiniWeaponType, int> supportWeaponLevels,
  required Map<PassiveType, int> passiveLevels,
}) {
  final unlockedSupports = supportWeaponLevels.entries
      .where((entry) => entry.value > 0)
      .map((entry) => entry.key)
      .toSet();
  final unlocks = availableMiniWeaponTypes
      .where((type) => !unlockedSupports.contains(type))
      .toList()
    ..shuffle(rng);
  final upgrades = unlockedSupports.toList()..shuffle(rng);
  final pool = unlockedSupports.length < 2
      ? <MiniWeaponType>[
          if (unlockedSupports.length < miniWeaponSlotCap) ...unlocks,
          ...upgrades,
        ]
      : <MiniWeaponType>[
          ...upgrades,
          if (unlockedSupports.length < miniWeaponSlotCap) ...unlocks,
        ];
  return pool.take(3).map((type) {
    final level = supportWeaponLevels[type] ?? 0;
    return CombatUpgradeOffer(
      kind: CombatUpgradeKind.supportAmp,
      title: type.title,
      description: level <= 0
          ? _miniWeaponLevelEffect(type, 1)
          : _miniWeaponLevelEffect(
              type, math.min(miniWeaponLevelCap, level + 1)),
      supportWeapon: type,
    );
  }).toList();
}
