/// Gold costs (and bonus "field notes") for unlocking entries in the
/// in-game Enemy Dictionary (see `ui/screens/enemy_dictionary_screen.dart`).
///
/// Unlocking an entry is purely informational - it reveals the germ's
/// real-world biology blurb, stats, and category in the dictionary. It has
/// no effect on gameplay.
class EnemyDictionaryCatalog {
  EnemyDictionaryCatalog._();

  /// Gold cost to unlock each [EnemyCatalog] entry, keyed by enemy id.
  static const Map<String, int> unlockCosts = {
    'virus': 10,
    'bacteria': 15,
    'fungal_spore': 20,
    'parasite': 30,
    'dysplastic_cell': 40,
    'biomarker_vesicle': 35,
    'stromal_fibroblast': 45,
    'mucin_blob': 35,
    'decoy_signal': 25,
  };

  /// A short real-world biology fact shown once an entry is unlocked,
  /// connecting the in-game germ to the science it represents.
  static const Map<String, String> fieldNotes = {
    'virus':
        'Real viruses can\'t reproduce on their own - they hijack a host '
        'cell\'s machinery to copy themselves, which is why infections can '
        'spread so quickly.',
    'bacteria':
        'Many real bacteria build a slimy "biofilm" coating that makes it '
        'harder for antibiotics and immune cells to reach them.',
    'fungal_spore':
        'Fungal spores are tough, dormant cells that can drift through the '
        'air and survive harsh conditions until they find a place to grow.',
    'parasite':
        'Parasites live on or inside a host and take resources from it - '
        'some can stay hidden from the immune system for a long time.',
    'dysplastic_cell':
        'Dysplastic cells look and behave abnormally compared to healthy '
        'cells. In PDAC, cells like these can build up genetic changes (such '
        'as a mutated KRAS gene, covered in the lessons) that let them grow '
        'out of control. In this game its color just tells you which weapon to '
        'match - it isn\'t a claim about which real immune response beats this '
        'cell.',
    'biomarker_vesicle':
        'Researchers study tiny molecules and vesicles in body fluids '
        'because they can carry clues from hard-to-reach organs. Saliva is '
        'being explored as one possible sample source for PDAC biomarkers.',
    'stromal_fibroblast':
        'PDAC tumors often grow inside a dense surrounding tissue called '
        'stroma. That microenvironment can protect cancer cells and make '
        'treatment harder. Its in-game color only tells you which weapon to '
        'match - it isn\'t a claim about which real immune response beats this '
        'cell.',
    'mucin_blob':
        'Mucins are gel-forming proteins found in mucus. Some pancreatic '
        'tumors produce abnormal mucins that help create a sticky, protective '
        'barrier. Its in-game color only tells you which weapon to match - it '
        'isn\'t a claim about which real immune response beats this cell.',
    'decoy_signal':
        'Not every signal in a biological sample means cancer. Good tests '
        'must separate useful biomarkers from harmless background noise.',
  };

  /// Gold cost to unlock the dictionary entry for [enemyId], or null if
  /// there's no entry for it.
  static int? unlockCostFor(String enemyId) => unlockCosts[enemyId];
}
