import 'package:flutter_test/flutter_test.dart';

import 'package:pdac_immune_defense/game/game_state.dart';
import 'package:pdac_immune_defense/ui/overlays/quiz_overlay.dart';

void main() {
  test('quiz result helpers match shop discount rules', () {
    expect(GameState.quizDiscountForScore(0), 0);
    expect(GameState.quizDiscountForScore(1), 0.05);
    expect(GameState.quizDiscountForScore(2), 0.10);
    expect(GameState.quizDiscountForScore(3), 0.15);

    expect(quizResultTitle(3, 3), 'Perfect Lab Notes');
    expect(quizResultTitle(2, 3), 'Strong Signal');
    expect(quizResultTitle(1, 3), 'Signal Detected');
    expect(quizResultTitle(0, 3), 'Review Recommended');

    expect(quizResultMessage(3, 3), contains('maximum research discount'));
    expect(quizResultMessage(0, 3), contains('No discount'));
  });
}
