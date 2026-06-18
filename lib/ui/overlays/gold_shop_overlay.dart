import 'package:flutter/material.dart';

import '../../game/pdac_game.dart';
import '../screens/gold_shop_screen.dart';

/// Round-loop wrapper around [GoldShopScreen] (`RoundPhase.goldShop`).
/// "Continue" advances to the next round via [PdacGame.startNextRound].
class GoldShopOverlay extends StatelessWidget {
  const GoldShopOverlay({super.key, required this.game});

  final PdacGame game;

  @override
  Widget build(BuildContext context) {
    return GoldShopScreen(
      gameState: game.gameState,
      continueLabel: 'Continue to Round ${game.gameState.currentRound + 1}',
      onContinue: game.startNextRound,
    );
  }
}
