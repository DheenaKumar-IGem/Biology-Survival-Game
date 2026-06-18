import '../categories.dart';
import '../enemies/enemy_catalog.dart';
import '../../theme/palette.dart';
import 'boss_def.dart';

/// Boss encounters for the end of each 3-round section.
///
/// Each boss represents a stage of PDAC progression, tying the KRAS
/// mutation/resistance mechanic ([KrasResistanceState]) to the real-world
/// fact that KRAS mutations occur in ~90% of pancreatic ductal
/// adenocarcinomas and drive its progression from a pre-cancerous lesion to
/// a localized tumor to metastatic disease.
///
/// Full rendering/behavior ([BossComponent]) is a skeleton for now - these
/// are data definitions only.
class BossCatalog {
  BossCatalog._();

  static final panInLesion = BossDef(
    roundNumber: 3,
    id: 'panin_lesion',
    displayName: 'PanIN Lesion',
    educationalBlurb:
        'PanIN: an early, pre-cancerous change in the pancreas. It is often '
        'the first step toward PDAC. Abnormal cells in lesions like this can '
        'already carry built-in driver changes (you will learn about the KRAS '
        'gene later), which let them slip past any single immune response used '
        'on its own. That is why mixing your responses works better - a varied '
        'defense gives the threat fewer ways to escape.',
    category: ImmuneCategory.cytotoxic,
    addArchetype: EnemyCatalog.virus,
    addThresholdsPercent: [75, 50, 25],
    chargeTelegraphSeconds: 1.0,
    chargeCooldownBaseSeconds: 6.0,
    baseRadius: 60,
    primaryColor: AppPalette.cytotoxicColor,
    accentColor: AppPalette.mutationRing,
    attackStyle: BossAttackStyle.krasClonePulse,
    phaseAddArchetypes: [EnemyCatalog.virus, EnemyCatalog.biomarkerVesicle],
  );

  static final localizedTumor = BossDef(
    roundNumber: 6,
    id: 'localized_tumor',
    displayName: 'Localized Tumor',
    educationalBlurb:
        'Over time, mutated cells can grow into a localized tumor confined '
        'to the pancreas. At this stage, surgery to remove the tumor may be '
        'possible for some patients - early detection matters. The tumor recruits '
        'stromal and mucus-like support cells to help it resist treatment.',
    category: ImmuneCategory.antibody,
    addArchetype: EnemyCatalog.bacteria,
    addThresholdsPercent: [75, 50, 25],
    chargeTelegraphSeconds: 0.9,
    chargeCooldownBaseSeconds: 5.5,
    baseRadius: 75,
    primaryColor: AppPalette.antibodyColor,
    accentColor: AppPalette.mutationRing,
    attackStyle: BossAttackStyle.stromalFortress,
    phaseAddArchetypes: [
      EnemyCatalog.stromalFibroblast,
      EnemyCatalog.mucinBlob,
    ],
  );

  static final metastaticPdac = BossDef(
    roundNumber: 9,
    id: 'metastatic_pdac',
    displayName: 'Metastatic PDAC',
    educationalBlurb:
        'As PDAC progresses, cancer cells can spread (metastasize) beyond the '
        'pancreas to other organs, becoming much harder to fully clear. This '
        'final stage scatters PDAC cells and misleading signals - exactly the '
        'outcome an early saliva test would aim to prevent by flagging the '
        'disease long before it reaches this point. A strong, varied defense '
        'is essential.',
    category: ImmuneCategory.cytotoxic,
    addArchetype: EnemyCatalog.dysplasticCell,
    addThresholdsPercent: [75, 50, 25],
    chargeTelegraphSeconds: 0.8,
    chargeCooldownBaseSeconds: 5.0,
    baseRadius: 90,
    primaryColor: AppPalette.cytotoxicColor,
    accentColor: AppPalette.gold,
    attackStyle: BossAttackStyle.metastaticStorm,
    phaseAddArchetypes: [
      EnemyCatalog.dysplasticCell,
      EnemyCatalog.decoySignal,
      EnemyCatalog.biomarkerVesicle,
    ],
  );

  /// All bosses, keyed by the round number they appear on.
  static final Map<int, BossDef> all = {
    3: panInLesion,
    6: localizedTumor,
    9: metastaticPdac,
  };
}
