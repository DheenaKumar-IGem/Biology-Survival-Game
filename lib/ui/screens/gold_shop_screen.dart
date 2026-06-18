import 'package:flutter/material.dart';

import '../../data/progression/gun_upgrade_def.dart';
import '../../data/progression/persistent_shop_def.dart';
import '../../data/progression/targeting_upgrade_def.dart';
import '../../data/weapons/weapon_catalog.dart';
import '../../data/weapons/weapon_traits.dart';
import '../../game/game_state.dart';
import '../../theme/colorblind.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import '../widgets/category_badge.dart';
import '../widgets/glow_button.dart';
import '../widgets/stat_bar.dart';

/// The persistent gold shop: spend [SaveData.goldCoins] on permanent stat
/// upgrades and trait unlocks for owned weapons (Pistol/Shotgun/SMG).
///
/// Used both as a round-loop overlay (`RoundPhase.goldShop`, via
/// `GoldShopOverlay`) and as a standalone screen from the home menu.
/// [continueLabel]/[onContinue] control the primary action button so both
/// contexts can reuse this widget.
class GoldShopScreen extends StatefulWidget {
  const GoldShopScreen({
    super.key,
    required this.gameState,
    required this.continueLabel,
    required this.onContinue,
  });

  final GameState gameState;
  final String continueLabel;
  final VoidCallback onContinue;

  @override
  State<GoldShopScreen> createState() => _GoldShopScreenState();
}

class _GoldShopScreenState extends State<GoldShopScreen> {
  _ShopFeedback? _feedback;

  Future<void> _purchaseStatUpgrade(String weaponId) async {
    final weapon = WeaponCatalog.all[weaponId];
    final upgrade = PersistentShopCatalog.statUpgrades[weaponId];
    if (weapon == null || upgrade == null) return;

    final bought = await widget.gameState.purchaseStatUpgrade(weaponId);
    if (!mounted) return;
    setState(() {
      if (!bought) {
        _feedback = const _ShopFeedback(
          message: 'Not enough gold for that upgrade yet.',
          icon: Icons.info,
          color: AppPalette.gold,
        );
        return;
      }

      final level = widget.gameState.persistentGunState(weaponId).statLevel;
      _feedback = _ShopFeedback(
        message:
            '${weapon.displayName} ${goldShopStatLabel(upgrade.primaryStat).toLowerCase()} upgraded to level $level.',
        icon: Icons.trending_up,
        color: categoryDisplayColor(weapon.category),
      );
    });
  }

  Future<void> _purchaseTargetingUpgrade() async {
    final tier = TargetingUpgradeCatalog.nextTier(
      widget.gameState.targetingLevel,
    );
    final bought = await widget.gameState.purchaseTargetingUpgrade();
    if (!mounted) return;
    setState(() {
      if (!bought) {
        _feedback = const _ShopFeedback(
          message: 'Not enough gold for that targeting upgrade yet.',
          icon: Icons.info,
          color: AppPalette.gold,
        );
        return;
      }
      _feedback = _ShopFeedback(
        message: 'Targeting upgraded: ${tier?.title ?? 'next tier'}.',
        icon: Icons.my_location,
        color: AppPalette.playerCore,
      );
    });
  }

  Future<void> _purchaseSmartAim() async {
    final bought = await widget.gameState.purchaseSmartAim();
    if (!mounted) return;
    setState(() {
      if (!bought) {
        _feedback = const _ShopFeedback(
          message: 'Smart Aim is still locked or needs more gold.',
          icon: Icons.info,
          color: AppPalette.gold,
        );
        return;
      }
      _feedback = const _ShopFeedback(
        message: 'Smart Aim unlocked! Toggle it any time in Settings.',
        icon: Icons.auto_awesome,
        color: AppPalette.playerCore,
      );
    });
  }

  Future<void> _purchaseWeapon(String weaponId) async {
    final weapon = WeaponCatalog.all[weaponId];
    if (weapon == null) return;
    final bought = await widget.gameState.purchaseWeapon(weaponId);
    if (!mounted) return;
    setState(() {
      if (!bought) {
        _feedback = const _ShopFeedback(
          message: 'Not enough gold for that weapon yet.',
          icon: Icons.info,
          color: AppPalette.gold,
        );
        return;
      }
      _feedback = _ShopFeedback(
        message:
            '${weapon.displayName} added to your arsenal - equip it on the '
            'loadout screen.',
        icon: Icons.add_circle,
        color: categoryDisplayColor(weapon.category),
      );
    });
  }

  Future<void> _purchaseTraitUnlock(WeaponTraitUnlock unlock) async {
    final trait = weaponTraitCatalog[unlock.traitId];
    final weapon = WeaponCatalog.all[unlock.weaponId];
    if (trait == null || weapon == null) return;

    final bought = await widget.gameState.purchaseTraitUnlock(unlock);
    if (!mounted) return;
    setState(() {
      if (!bought) {
        _feedback = const _ShopFeedback(
          message: 'That trait is still locked or needs more gold.',
          icon: Icons.info,
          color: AppPalette.gold,
        );
        return;
      }

      _feedback = _ShopFeedback(
        message: '${weapon.displayName} unlocked ${trait.title}.',
        icon: Icons.auto_awesome,
        color: categoryDisplayColor(weapon.category),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = widget.gameState;
    final discount = gameState.quizDiscount;

    return Container(
      color: AppPalette.backgroundDeep.withValues(alpha: 0.92),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppPalette.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppPalette.surfaceLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Gold Shop', style: AppTypography.displayMedium),
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
                  if (discount > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Quiz discount active: ${(discount * 100).round()}% off',
                      style: AppTypography.label.copyWith(
                        color: AppPalette.healthGood,
                      ),
                    ),
                  ],
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _feedback == null
                        ? const SizedBox(height: 0)
                        : Padding(
                            key: ValueKey(_feedback!.message),
                            padding: const EdgeInsets.only(top: 12),
                            child: _ShopFeedbackBanner(feedback: _feedback!),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _TargetingShopCard(
                            gameState: gameState,
                            onPurchaseTier: _purchaseTargetingUpgrade,
                            onPurchaseSmartAim: _purchaseSmartAim,
                          ),
                          for (final weaponId
                              in PersistentShopCatalog.statUpgrades.keys)
                            if (gameState.ownedWeapons.contains(weaponId))
                              _WeaponShopCard(
                                weaponId: weaponId,
                                gameState: gameState,
                                onPurchaseStat: _purchaseStatUpgrade,
                                onPurchaseTrait: _purchaseTraitUnlock,
                              ),
                          for (final weaponId
                              in WeaponCatalog.shopUnlockCost.keys)
                            if (!gameState.ownedWeapons.contains(weaponId))
                              _WeaponPurchaseCard(
                                weaponId: weaponId,
                                gameState: gameState,
                                onPurchase: _purchaseWeapon,
                              ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GlowButton(
                      label: widget.continueLabel,
                      icon: Icons.arrow_forward,
                      onPressed: widget.onContinue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShopFeedback {
  const _ShopFeedback({
    required this.message,
    required this.icon,
    required this.color,
  });

  final String message;
  final IconData icon;
  final Color color;
}

class _ShopFeedbackBanner extends StatelessWidget {
  const _ShopFeedbackBanner({required this.feedback});

  final _ShopFeedback feedback;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: feedback.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: feedback.color.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(feedback.icon, color: feedback.color, size: 19),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                feedback.message,
                style: AppTypography.bodyStrong.copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeaponShopCard extends StatelessWidget {
  const _WeaponShopCard({
    required this.weaponId,
    required this.gameState,
    required this.onPurchaseStat,
    required this.onPurchaseTrait,
  });

  final String weaponId;
  final GameState gameState;
  final Future<void> Function(String weaponId) onPurchaseStat;
  final Future<void> Function(WeaponTraitUnlock unlock) onPurchaseTrait;

  @override
  Widget build(BuildContext context) {
    final weapon = WeaponCatalog.all[weaponId];
    final upgrade = PersistentShopCatalog.statUpgrades[weaponId];
    if (weapon == null || upgrade == null) return const SizedBox.shrink();

    final state = gameState.persistentGunState(weaponId);
    final color = categoryDisplayColor(weapon.category);
    final cost = gameState.statUpgradeCost(weaponId);
    final maxed = cost == null;
    final canAfford = !maxed && gameState.persistentGold >= cost;

    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.backgroundMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(weapon.displayName, style: AppTypography.headline),
              const SizedBox(width: 8),
              CategoryBadge(category: weapon.category, compact: true),
              const SizedBox(width: 6),
              WeaponRoleTag(role: weapon.role),
            ],
          ),
          const SizedBox(height: 10),
          StatBar(
            value: state.statLevel / upgrade.maxLevel,
            color: color,
            label:
                '${goldShopStatLabel(upgrade.primaryStat)} - Level ${state.statLevel}/${upgrade.maxLevel}',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  maxed
                      ? 'Max level reached'
                      : '+${upgrade.bonusPerLevel} ${goldShopStatLabel(upgrade.primaryStat)} - $cost gold',
                  style: AppTypography.body,
                ),
              ),
              const SizedBox(width: 8),
              GlowButton(
                label: 'Upgrade',
                color: color,
                onPressed: canAfford ? () => onPurchaseStat(weaponId) : null,
              ),
            ],
          ),
          const SizedBox(height: 6),
          _AffordabilityLine(
            text: goldShopAffordabilityLabel(
              cost: cost,
              gold: gameState.persistentGold,
            ),
            color: goldShopAffordabilityColor(
              cost: cost,
              gold: gameState.persistentGold,
            ),
          ),
          const SizedBox(height: 14),
          Text('Special Abilities', style: AppTypography.label),
          const SizedBox(height: 8),
          for (final unlock in PersistentShopCatalog.traitUnlocksFor(weaponId))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TraitUnlockRow(
                unlock: unlock,
                weaponLevel: state.statLevel,
                unlocked: state.unlockedTraits.contains(unlock.traitId),
                gameState: gameState,
                color: color,
                onPurchaseTrait: onPurchaseTrait,
              ),
            ),
        ],
      ),
    );
  }
}

/// Card for buying a weapon the player doesn't own yet into the persistent
/// pool. Once bought it becomes equippable on the loadout screen and gains its
/// own [_WeaponShopCard] for stat/trait upgrades.
class _WeaponPurchaseCard extends StatelessWidget {
  const _WeaponPurchaseCard({
    required this.weaponId,
    required this.gameState,
    required this.onPurchase,
  });

  final String weaponId;
  final GameState gameState;
  final Future<void> Function(String weaponId) onPurchase;

  @override
  Widget build(BuildContext context) {
    final weapon = WeaponCatalog.all[weaponId];
    if (weapon == null) return const SizedBox.shrink();

    final color = categoryDisplayColor(weapon.category);
    final cost = gameState.weaponPurchaseCost(weaponId);
    final canAfford = cost != null && gameState.persistentGold >= cost;

    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.backgroundMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(weapon.displayName, style: AppTypography.headline),
              const SizedBox(width: 8),
              CategoryBadge(category: weapon.category, compact: true),
              const SizedBox(width: 6),
              WeaponRoleTag(role: weapon.role),
              const Spacer(),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppPalette.gold.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppPalette.gold.withValues(alpha: 0.55),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  child: Text(
                    'NEW',
                    style: AppTypography.label.copyWith(
                      color: AppPalette.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            weapon.description,
            style: AppTypography.body.copyWith(fontSize: 13),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AffordabilityLine(
                  text: goldShopAffordabilityLabel(
                    cost: cost,
                    gold: gameState.persistentGold,
                  ),
                  color: goldShopAffordabilityColor(
                    cost: cost,
                    gold: gameState.persistentGold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GlowButton(
                label:
                    'Buy ${cost ?? WeaponCatalog.shopUnlockCost[weaponId] ?? 0}g',
                color: color,
                onPressed: canAfford ? () => onPurchase(weaponId) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Global "Targeting Systems" card: the weapon-independent upgrade track plus
/// the Smart Aim unlock. Mirrors the per-weapon [_WeaponShopCard] styling.
class _TargetingShopCard extends StatelessWidget {
  const _TargetingShopCard({
    required this.gameState,
    required this.onPurchaseTier,
    required this.onPurchaseSmartAim,
  });

  final GameState gameState;
  final Future<void> Function() onPurchaseTier;
  final Future<void> Function() onPurchaseSmartAim;

  @override
  Widget build(BuildContext context) {
    const color = AppPalette.playerCore;
    final level = gameState.targetingLevel;
    final maxLevel = TargetingUpgradeCatalog.maxLevel;
    final nextTier = TargetingUpgradeCatalog.nextTier(level);
    final cost = gameState.targetingUpgradeCost();
    final canAfford = cost != null && gameState.persistentGold >= cost;

    final smartCost = gameState.smartAimUnlockCost();
    final smartUnlocked = gameState.smartAimUnlocked;
    final smartLocked =
        !smartUnlocked && level < TargetingUpgradeCatalog.smartAimUnlockTier;
    final canAffordSmart =
        smartCost != null && gameState.persistentGold >= smartCost;

    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.backgroundMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.my_location, color: color, size: 18),
              const SizedBox(width: 8),
              Text('Targeting Systems', style: AppTypography.headline),
            ],
          ),
          const SizedBox(height: 10),
          StatBar(
            value: maxLevel == 0 ? 0 : level / maxLevel,
            color: color,
            label: 'Track - Level $level/$maxLevel',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  nextTier == null
                      ? 'Targeting track complete'
                      : '${nextTier.title}: ${nextTier.description}',
                  style: AppTypography.body.copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _AffordabilityLine(
                  text: goldShopAffordabilityLabel(
                    cost: cost,
                    gold: gameState.persistentGold,
                  ),
                  color: goldShopAffordabilityColor(
                    cost: cost,
                    gold: gameState.persistentGold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (nextTier != null)
                GlowButton(
                  label: 'Buy ${cost ?? nextTier.cost}g',
                  color: color,
                  onPressed: canAfford ? () => onPurchaseTier() : null,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Special Abilities', style: AppTypography.label),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: smartUnlocked ? 0.6 : 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  smartUnlocked
                      ? Icons.check_circle
                      : (smartLocked ? Icons.lock : Icons.lock_open),
                  color: smartUnlocked
                      ? AppPalette.healthGood
                      : AppPalette.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Smart Aim', style: AppTypography.bodyStrong),
                      Text(
                        smartUnlocked
                            ? 'Unlocked - toggle in Settings'
                            : smartLocked
                            ? 'Requires Targeting level '
                                  '${TargetingUpgradeCatalog.smartAimUnlockTier}'
                            : 'Auto-fire already matches color - this adds '
                                  'threat priority: shoot the closest danger '
                                  'first.',
                        style: AppTypography.label,
                      ),
                    ],
                  ),
                ),
                if (!smartUnlocked && !smartLocked)
                  GlowButton(
                    label:
                        'Buy ${smartCost ?? TargetingUpgradeCatalog.smartAimCost}g',
                    color: color,
                    onPressed: canAffordSmart
                        ? () => onPurchaseSmartAim()
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TraitUnlockRow extends StatelessWidget {
  const _TraitUnlockRow({
    required this.unlock,
    required this.weaponLevel,
    required this.unlocked,
    required this.gameState,
    required this.color,
    required this.onPurchaseTrait,
  });

  final WeaponTraitUnlock unlock;
  final int weaponLevel;
  final bool unlocked;
  final GameState gameState;
  final Color color;
  final Future<void> Function(WeaponTraitUnlock unlock) onPurchaseTrait;

  @override
  Widget build(BuildContext context) {
    final trait = weaponTraitCatalog[unlock.traitId]!;
    final locked = weaponLevel < unlock.unlockTierRequired;
    final cost = gameState.traitUnlockCost(unlock);
    final canAfford =
        !unlocked &&
        !locked &&
        cost != null &&
        gameState.persistentGold >= cost;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: unlocked ? 0.6 : 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            unlocked
                ? Icons.check_circle
                : (locked ? Icons.lock : Icons.lock_open),
            color: unlocked ? AppPalette.healthGood : AppPalette.textMuted,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trait.title, style: AppTypography.bodyStrong),
                Text(
                  locked
                      ? 'Requires level ${unlock.unlockTierRequired}'
                      : unlocked
                      ? 'Unlocked'
                      : trait.description,
                  style: AppTypography.label,
                ),
                if (!unlocked && !locked) ...[
                  const SizedBox(height: 4),
                  Text(
                    goldShopAffordabilityLabel(
                      cost: cost,
                      gold: gameState.persistentGold,
                    ),
                    style: AppTypography.label.copyWith(
                      color: goldShopAffordabilityColor(
                        cost: cost,
                        gold: gameState.persistentGold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!unlocked && !locked)
            GlowButton(
              label: 'Buy ${cost ?? unlock.goldCost}g',
              color: color,
              onPressed: canAfford ? () => onPurchaseTrait(unlock) : null,
            ),
        ],
      ),
    );
  }
}

class _AffordabilityLine extends StatelessWidget {
  const _AffordabilityLine({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 7),
        Text(text, style: AppTypography.label.copyWith(color: color)),
      ],
    );
  }
}

String goldShopStatLabel(WeaponStat stat) => switch (stat) {
  WeaponStat.damage => 'Damage',
  WeaponStat.fireRate => 'Fire Rate',
  WeaponStat.bulletSpeed => 'Bullet Speed',
};

String goldShopAffordabilityLabel({required int? cost, required int gold}) {
  if (cost == null) return 'Upgrade track complete';
  final shortfall = cost - gold;
  if (shortfall <= 0) return 'Ready to purchase';
  return 'Need $shortfall more gold';
}

Color goldShopAffordabilityColor({required int? cost, required int gold}) {
  if (cost == null) return AppPalette.healthGood;
  return gold >= cost ? AppPalette.healthGood : AppPalette.gold;
}
