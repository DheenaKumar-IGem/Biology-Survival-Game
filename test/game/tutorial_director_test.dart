import 'package:flutter_test/flutter_test.dart';
import 'package:pdac_immune_defense/game/components/tutorial_director.dart';

/// Guards the interactive tutorial's beat ordering: it must walk move -> one
/// threat of each immune category -> done, and never run off the end.
void main() {
  test('tutorial beats advance in order and terminate at done', () {
    expect(tutorialBeatAfter(TutorialBeat.intro), TutorialBeat.move);
    expect(tutorialBeatAfter(TutorialBeat.move), TutorialBeat.innate);
    expect(tutorialBeatAfter(TutorialBeat.innate), TutorialBeat.antibody);
    expect(tutorialBeatAfter(TutorialBeat.antibody), TutorialBeat.cytotoxic);
    expect(tutorialBeatAfter(TutorialBeat.cytotoxic), TutorialBeat.done);
    expect(tutorialBeatAfter(TutorialBeat.done), TutorialBeat.done);
  });

  test('the sequence teaches all three immune categories once', () {
    final visited = <TutorialBeat>[];
    var beat = TutorialBeat.intro;
    for (var i = 0; i < 20 && beat != TutorialBeat.done; i++) {
      visited.add(beat);
      beat = tutorialBeatAfter(beat);
    }
    expect(beat, TutorialBeat.done, reason: 'sequence must reach done');
    expect(visited, contains(TutorialBeat.innate));
    expect(visited, contains(TutorialBeat.antibody));
    expect(visited, contains(TutorialBeat.cytotoxic));
  });
}
