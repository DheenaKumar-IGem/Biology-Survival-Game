import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdac_immune_defense/data/bosses/boss_catalog.dart';
import 'package:pdac_immune_defense/data/bosses/boss_def.dart';
import 'package:pdac_immune_defense/game/components/hud_data.dart';
import 'package:pdac_immune_defense/game/pdac_game.dart';
import 'package:pdac_immune_defense/services/persistence_service.dart';
import 'package:pdac_immune_defense/ui/overlays/boss_recap_overlay.dart';

void main() {
  test('boss recap helper copy identifies attack styles', () {
    expect(
      bossRecapStageLabel(BossAttackStyle.krasClonePulse),
      'Early Lesion Signal',
    );
    expect(
      bossRecapFightTakeaway(BossAttackStyle.stromalFortress),
      contains('support cells'),
    );
    expect(
      bossRecapFightTakeaway(BossAttackStyle.metastaticStorm),
      contains('decoy signals'),
    );
  });

  test('localized tumor blurb names support cells without germ wording', () {
    final blurb = BossCatalog.localizedTumor.educationalBlurb;
    expect(blurb, contains('stromal'));
    expect(blurb, contains('support cells'));
    expect(blurb, contains('may be possible for some patients'));
    expect(blurb, isNot(contains('bacteria-like')));
    expect(blurb, isNot(contains('often still possible')));
  });

  test('PanIN blurb keeps pre-cancerous lesion wording precise', () {
    final blurb = BossCatalog.panInLesion.educationalBlurb;
    expect(blurb, contains('pre-cancerous'));
    expect(blurb, contains('Abnormal cells in lesions'));
    expect(blurb, isNot(contains('Cancers like this')));
  });

  test('metastatic blurb uses cancer-cell wording, not dysplasia wording', () {
    final blurb = BossCatalog.metastaticPdac.educationalBlurb;
    expect(blurb, contains('cancer cells'));
    expect(blurb, contains('PDAC cells'));
    expect(blurb, isNot(contains('dysplastic')));
    expect(blurb, isNot(contains('If untreated')));
  });

  testWidgets('BossRecapOverlay renders and advances to upgrades', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final persistence = await PersistenceService.init();
    final game = PdacGame(persistence: persistence);

    game.phase.value = RoundPhase.bossRecap;
    game.hud.bossRecap.value = const BossRecapData(
      roundNumber: 3,
      bossName: 'PanIN Lesion',
      stageLabel: 'Early Lesion Signal',
      fightTakeaway: 'You mixed immune-response pressure.',
      scienceConnection: 'PanIN can be an early pre-cancerous change.',
      nextStep: 'Move toward localized tumor growth.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(children: [BossRecapOverlay(game: game)]),
      ),
    );
    await tester.pump();

    expect(find.text('BOSS DEBRIEF'), findsOneWidget);
    expect(find.text('PanIN Lesion'), findsOneWidget);
    expect(find.text('Round 3 - Early Lesion Signal'), findsOneWidget);
    expect(find.text('What You Modeled'), findsOneWidget);
    expect(find.text('PDAC Connection'), findsOneWidget);
    expect(find.text('Saliva Detection Lead'), findsOneWidget);

    await tester.tap(find.text('Choose Upgrade'));
    await tester.pump();

    expect(game.phase.value, RoundPhase.gunUpgradeChoice);
    expect(game.hud.bossRecap.value, isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
