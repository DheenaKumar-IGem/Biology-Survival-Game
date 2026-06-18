import 'package:flutter/material.dart';

import '../../data/enemies/enemy_catalog.dart';
import '../../data/enemies/enemy_def.dart';
import '../../data/enemies/enemy_dictionary_def.dart';
import '../../game/game_state.dart';
import '../../theme/colorblind.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import '../widgets/blob_painter.dart';
import '../widgets/category_badge.dart';
import '../widgets/glow_button.dart';

/// A bestiary of every germ in [EnemyCatalog]. Each entry is unlocked by
/// spending persistent gold; locked entries are shown as a dim silhouette
/// with their unlock cost, while unlocked entries reveal the full
/// description, stats, and a real-world biology field note.
class EnemyDictionaryScreen extends StatefulWidget {
  const EnemyDictionaryScreen({super.key, required this.gameState});

  final GameState gameState;

  @override
  State<EnemyDictionaryScreen> createState() => _EnemyDictionaryScreenState();
}

class _EnemyDictionaryScreenState extends State<EnemyDictionaryScreen> {
  @override
  Widget build(BuildContext context) {
    final gameState = widget.gameState;

    return Scaffold(
      backgroundColor: AppPalette.backgroundDeep,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  Text('Enemy Dictionary', style: AppTypography.displayMedium),
                  const Spacer(),
                  const Icon(Icons.paid, color: AppPalette.gold, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${gameState.persistentGold}',
                    style: AppTypography.headline.copyWith(
                      color: AppPalette.gold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Text(
                'Every threat\'s color and counter are free - spend gold to unlock its name, stats, and real-world biology.',
                style: AppTypography.body,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final enemy in EnemyCatalog.all.values)
                      _EnemyEntryCard(
                        enemy: enemy,
                        gameState: gameState,
                        onChanged: () => setState(() {}),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnemyEntryCard extends StatelessWidget {
  const _EnemyEntryCard({
    required this.enemy,
    required this.gameState,
    required this.onChanged,
  });

  final EnemyDef enemy;
  final GameState gameState;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final unlocked = gameState.isEnemyUnlocked(enemy.id);
    final cost = gameState.enemyUnlockCost(enemy.id);
    final color = categoryDisplayColor(enemy.category);
    final fieldNote = EnemyDictionaryCatalog.fieldNotes[enemy.id];

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (unlocked ? color : AppPalette.textMuted).withValues(
            alpha: unlocked ? 0.5 : 0.25,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: Center(
                  child: unlocked
                      ? AnimatedBlob(
                          radius: enemy.baseRadius,
                          primaryColor: enemy.primaryColor,
                          accentColor: enemy.accentColor,
                          rimColor: enemy.accentColor,
                          seed: enemy.id.hashCode,
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: 0.35,
                              child: AnimatedBlob(
                                radius: enemy.baseRadius,
                                primaryColor: color,
                                accentColor: color,
                                seed: enemy.id.hashCode,
                              ),
                            ),
                            const Icon(
                              Icons.lock,
                              color: AppPalette.textMuted,
                              size: 22,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unlocked ? enemy.displayName : '???',
                      style: AppTypography.headline,
                    ),
                    const SizedBox(height: 4),
                    CategoryBadge(category: enemy.category, compact: true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (unlocked) ...[
            Text(enemy.description, style: AppTypography.body),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _StatChip(
                  label: 'HP',
                  value: enemy.baseHealth.toStringAsFixed(0),
                ),
                _StatChip(
                  label: 'Speed',
                  value: enemy.baseSpeed.toStringAsFixed(0),
                ),
                _StatChip(label: 'Gold', value: '+${enemy.coinValue}'),
              ],
            ),
            if (fieldNote != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppPalette.backgroundMid,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb,
                      color: AppPalette.gold,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fieldNote,
                        style: AppTypography.label.copyWith(
                          color: AppPalette.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            Text(
              'Counter: match with ${enemy.category.shortLabel} weapons for bonus damage.',
              style: AppTypography.body.copyWith(color: color),
            ),
            const SizedBox(height: 6),
            Text(
              'Unlock to reveal its name, stats, and real-world biology.',
              style: AppTypography.label.copyWith(
                color: AppPalette.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${cost ?? 0} gold',
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppPalette.gold,
                    ),
                  ),
                ),
                GlowButton(
                  label: 'Unlock',
                  color: color,
                  onPressed: cost == null || gameState.persistentGold < cost
                      ? null
                      : () async {
                          await gameState.purchaseEnemyUnlock(enemy.id);
                          onChanged();
                        },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label ', style: AppTypography.label),
        Text(value, style: AppTypography.bodyStrong),
      ],
    );
  }
}
