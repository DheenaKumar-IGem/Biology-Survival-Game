import 'package:flutter/material.dart';

import '../../data/progression/gun_upgrade_def.dart';
import '../../data/weapons/weapon_catalog.dart';
import '../../data/weapons/weapon_def.dart';
import '../../game/pdac_game.dart';
import '../../services/settings_service.dart';
import '../../theme/category_glyph.dart';
import '../../theme/colorblind.dart';
import '../../theme/fx_constants.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import '../widgets/category_badge.dart';

/// Shown after a round is cleared (`RoundPhase.gunUpgradeChoice`). The
/// player picks ONE owned weapon to receive its end-of-round stat bump
/// (run-scoped only, see [GunUpgradeCatalog]). Some rounds also offer a new
/// weapon that unlocks immediately and receives the same run upgrade.
class RoundEndUpgradeOverlay extends StatelessWidget {
  const RoundEndUpgradeOverlay({super.key, required this.game});

  final PdacGame game;

  @override
  Widget build(BuildContext context) {
    final gameState = game.gameState;
    // Run upgrade applies to one of the weapons just used this round.
    final options = List<String>.of(gameState.equippedWeapons);

    return Container(
      color: AppPalette.backgroundDeep.withValues(alpha: 0.9),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 820;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    // Reduce Motion: appear instantly, no slide/fade entrance.
                    duration: SettingsService.instance.value.reduceMotion
                        ? Duration.zero
                        : FxConstants.slow,
                    curve: FxConstants.standardCurve,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 18 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _RewardHeader(
                          round: gameState.currentRound,
                          kills: game.hud.kills.value,
                          goldThisRun: gameState.goldThisRun,
                          isWide: isWide,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'SELECT A RUN UPGRADE',
                          style: AppTypography.label.copyWith(
                            color: AppPalette.gold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose one equipped weapon to strengthen for the rest of this run.',
                          style: AppTypography.body,
                        ),
                        const SizedBox(height: 18),
                        _UpgradeGrid(
                          options: options,
                          ownedWeapons: options,
                          upgradeCountFor: gameState.runUpgradeCount,
                          onSelected: _select,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _select(String weaponId) {
    game.chooseGunUpgrade(weaponId);
  }
}

class _RewardHeader extends StatelessWidget {
  const _RewardHeader({
    required this.round,
    required this.kills,
    required this.goldThisRun,
    required this.isWide,
  });

  final int round;
  final int kills;
  final int goldThisRun;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          'ROUND $round CLEAR',
          style: AppTypography.displayMedium.copyWith(
            color: AppPalette.textPrimary,
            height: 1,
          ),
          textAlign: isWide ? TextAlign.left : TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Immune response stabilized. Reinforce one defense before the next biology briefing.',
          style: AppTypography.body,
          textAlign: isWide ? TextAlign.left : TextAlign.center,
        ),
      ],
    );

    final stats = _RewardStats(
      items: [
        _RewardStat(
          icon: Icons.coronavirus,
          label: 'Cleared',
          value: '$kills threats',
          color: AppPalette.playerCore,
        ),
        _RewardStat(
          icon: Icons.paid,
          label: 'Run gold',
          value: '$goldThisRun',
          color: AppPalette.gold,
        ),
        _RewardStat(
          icon: Icons.school,
          label: 'Next',
          value: 'Lesson',
          color: AppPalette.healthGood,
        ),
      ],
    );

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [title, const SizedBox(height: 16), stats],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: 24),
        Flexible(child: stats),
      ],
    );
  }
}

class _RewardStats extends StatelessWidget {
  const _RewardStats({required this.items});

  final List<_RewardStat> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.surfaceLight),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Wrap(
          spacing: 18,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [for (final item in items) _RewardStatAtom(item: item)],
        ),
      ),
    );
  }
}

class _RewardStatAtom extends StatelessWidget {
  const _RewardStatAtom({required this.item});

  final _RewardStat item;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(item.icon, color: item.color, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.label, style: AppTypography.label),
            Text(item.value, style: AppTypography.bodyStrong),
          ],
        ),
      ],
    );
  }
}

class _RewardStat {
  const _RewardStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class _UpgradeGrid extends StatelessWidget {
  const _UpgradeGrid({
    required this.options,
    required this.ownedWeapons,
    required this.upgradeCountFor,
    required this.onSelected,
  });

  final List<String> options;
  final List<String> ownedWeapons;
  final int Function(String weaponId) upgradeCountFor;
  final void Function(String weaponId) onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 900
            ? 3
            : width >= 600
            ? 2
            : 1;
        final spacing = 14.0;
        final cardWidth = (width - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final weaponId in options)
              SizedBox(
                width: cardWidth,
                child: _UpgradeCard(
                  weaponId: weaponId,
                  isUnlock: !ownedWeapons.contains(weaponId),
                  currentTier: upgradeCountFor(weaponId),
                  onSelected: () => onSelected(weaponId),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({
    required this.weaponId,
    required this.isUnlock,
    required this.currentTier,
    required this.onSelected,
  });

  final String weaponId;
  final bool isUnlock;
  final int currentTier;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final weapon = WeaponCatalog.all[weaponId];
    final upgrade = GunUpgradeCatalog.all[weaponId];
    if (weapon == null || upgrade == null) return const SizedBox.shrink();

    final color = categoryDisplayColor(weapon.category);
    return Material(
      color: AppPalette.surface.withValues(alpha: 0.84),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onSelected,
        child: Container(
          constraints: const BoxConstraints(minHeight: 238),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.62)),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 14),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WeaponIcon(weapon: weapon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weapon.displayName,
                          style: AppTypography.headline.copyWith(height: 1.1),
                        ),
                        const SizedBox(height: 6),
                        CategoryBadge(category: weapon.category, compact: true),
                      ],
                    ),
                  ),
                  if (isUnlock)
                    _Badge(label: 'NEW', color: AppPalette.gold)
                  else
                    _Badge(label: 'T$currentTier', color: color),
                ],
              ),
              const SizedBox(height: 16),
              _UpgradeImpact(upgrade: upgrade),
              const SizedBox(height: 12),
              Text(
                weapon.description,
                style: AppTypography.body.copyWith(fontSize: 13),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              const SizedBox(height: 14),
              _SelectRow(isUnlock: isUnlock, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeaponIcon extends StatelessWidget {
  const _WeaponIcon({required this.weapon});

  final WeaponDef weapon;

  @override
  Widget build(BuildContext context) {
    final color = categoryDisplayColor(weapon.category);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.58)),
      ),
      child: SizedBox(
        width: 46,
        height: 46,
        child: CategoryGlyph(category: weapon.category, color: color, size: 24),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: AppTypography.label.copyWith(color: AppPalette.textPrimary),
        ),
      ),
    );
  }
}

class _UpgradeImpact extends StatelessWidget {
  const _UpgradeImpact({required this.upgrade});

  final GunUpgradeOption upgrade;

  @override
  Widget build(BuildContext context) {
    final color = upgradeColor(upgrade.stat);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.backgroundDeep.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(upgradeIcon(upgrade.stat), color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    upgradeStatLabel(upgrade.stat),
                    style: AppTypography.label.copyWith(color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(upgrade.description, style: AppTypography.bodyStrong),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectRow extends StatelessWidget {
  const _SelectRow({required this.isUnlock, required this.color});

  final bool isUnlock;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isUnlock ? Icons.add_circle : Icons.arrow_circle_up,
          color: color,
          size: 19,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            isUnlock ? 'Unlock and upgrade' : 'Choose upgrade',
            style: AppTypography.button.copyWith(fontSize: 15),
          ),
        ),
        Icon(Icons.chevron_right, color: color, size: 22),
      ],
    );
  }
}

String upgradeStatLabel(WeaponStat stat) => switch (stat) {
  WeaponStat.damage => 'Damage boost',
  WeaponStat.fireRate => 'Fire-rate boost',
  WeaponStat.bulletSpeed => 'Projectile speed',
};

IconData upgradeIcon(WeaponStat stat) => switch (stat) {
  WeaponStat.damage => Icons.bolt,
  WeaponStat.fireRate => Icons.speed,
  WeaponStat.bulletSpeed => Icons.open_in_full,
};

Color upgradeColor(WeaponStat stat) => switch (stat) {
  WeaponStat.damage => AppPalette.healthLow,
  WeaponStat.fireRate => AppPalette.playerCore,
  WeaponStat.bulletSpeed => AppPalette.gold,
};
