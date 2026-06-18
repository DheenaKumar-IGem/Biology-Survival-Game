import 'package:flutter/material.dart';

import '../../data/categories.dart';
import '../../data/weapons/weapon_catalog.dart';
import '../../game/game_state.dart';
import '../../game/pdac_game.dart';
import '../../theme/category_glyph.dart';
import '../../theme/colorblind.dart';
import '../../theme/palette.dart';
import '../../theme/typography.dart';
import '../widgets/category_badge.dart';
import '../widgets/glow_button.dart';
import '../widgets/pressable_action.dart';

/// Pre-round loadout picker (`RoundPhase.loadout`). The player equips up to
/// [GameState.maxEquippedWeapons] weapons from the ones they own; combat then
/// cycles only through this set (Q). Requires one weapon per immune category
/// whenever possible so every threat has a matched answer.
class LoadoutOverlay extends StatefulWidget {
  const LoadoutOverlay({super.key, required this.game});

  final PdacGame game;

  @override
  State<LoadoutOverlay> createState() => _LoadoutOverlayState();
}

class _LoadoutOverlayState extends State<LoadoutOverlay> {
  late List<String> _selected;

  GameState get _gameState => widget.game.gameState;

  int get _maxSelect =>
      _gameState.ownedWeapons.length < GameState.maxEquippedWeapons
      ? _gameState.ownedWeapons.length
      : GameState.maxEquippedWeapons;

  @override
  void initState() {
    super.initState();
    // Pre-fill with the current equipped set (the round default), filtered to
    // owned weapons, capped at the max.
    _selected = _gameState.equippedWeapons
        .where(_gameState.ownedWeapons.contains)
        .take(_maxSelect)
        .toList();
    if (_selected.isEmpty) {
      _selected = _gameState.ownedWeapons.take(_maxSelect).toList();
    }
  }

  void _toggle(String weaponId) {
    setState(() {
      if (_selected.contains(weaponId)) {
        _selected.remove(weaponId);
      } else if (_selected.length < _maxSelect) {
        _selected.add(weaponId);
      }
    });
  }

  Set<ImmuneCategory> get _coveredCategories => {
    for (final id in _selected)
      if (WeaponCatalog.all[id] != null) WeaponCatalog.all[id]!.category,
  };

  /// Distinct immune categories present in the owned pool.
  Set<ImmuneCategory> get _ownedCategories => {
    for (final id in _gameState.ownedWeapons)
      if (WeaponCatalog.all[id] != null) WeaponCatalog.all[id]!.category,
  };

  /// How many categories the loadout must cover: every category the player can
  /// actually field, capped by how many weapons they can equip. This can never
  /// exceed what's achievable, so the Start gate can't softlock (covering "all
  /// three" is just the common case where the owned pool spans all three).
  int get _requiredCategoryCount {
    final owned = _ownedCategories.length;
    return owned < _maxSelect ? owned : _maxSelect;
  }

  bool get _hasRequiredCoverage =>
      _coveredCategories.length >= _requiredCategoryCount;

  bool get _ready => _selected.length == _maxSelect && _hasRequiredCoverage;

  void _confirm() {
    if (!_ready) return;
    widget.game.confirmLoadout(List<String>.of(_selected));
  }

  @override
  Widget build(BuildContext context) {
    final owned = _gameState.ownedWeapons;
    final missing = ImmuneCategory.values
        .where((c) => !_coveredCategories.contains(c))
        .toList();

    return Container(
      color: AppPalette.backgroundDeep.withValues(alpha: 0.92),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760, maxHeight: 660),
            child: Container(
              margin: const EdgeInsets.all(18),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.backpack,
                          color: AppPalette.playerCore,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Choose Your Loadout',
                          style: AppTypography.displayMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Semantics(
                        label: 'Selected weapons',
                        value: '${_selected.length} of $_maxSelect',
                        child: ExcludeSemantics(
                          child: Text(
                            '${_selected.length}/$_maxSelect',
                            style: AppTypography.headline.copyWith(
                              color: _ready
                                  ? AppPalette.healthGood
                                  : AppPalette.gold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Equip $_maxSelect weapons for Round '
                    '${_gameState.currentRound}. Aim for one of each color so '
                    'every threat has a matched answer.',
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: 12),
                  _CoverageHint(covered: _coveredCategories, missing: missing),
                  const SizedBox(height: 14),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final weaponId in owned)
                            _LoadoutWeaponCard(
                              weaponId: weaponId,
                              gameState: _gameState,
                              selected: _selected.contains(weaponId),
                              onTap: () => _toggle(weaponId),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact =
                          constraints.maxWidth < 520 ||
                          MediaQuery.textScalerOf(context).scale(1.0) > 1.4;
                      final status = Text(
                        _ready
                            ? 'Ready to deploy.'
                            : !_hasRequiredCoverage
                            ? 'Cover all three immune categories to continue.'
                            : 'Select $_maxSelect weapons to continue.',
                        style: AppTypography.label.copyWith(
                          color: _ready
                              ? AppPalette.healthGood
                              : AppPalette.textSecondary,
                        ),
                      );
                      final button = GlowButton(
                        label: 'Start Round ${_gameState.currentRound}',
                        icon: Icons.play_arrow,
                        onPressed: _ready ? _confirm : null,
                      );
                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            status,
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: button,
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: status),
                          const SizedBox(width: 16),
                          button,
                        ],
                      );
                    },
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

class _CoverageHint extends StatelessWidget {
  const _CoverageHint({required this.covered, required this.missing});

  final Set<ImmuneCategory> covered;
  final List<ImmuneCategory> missing;

  @override
  Widget build(BuildContext context) {
    final allCovered = missing.isEmpty;
    final color = allCovered ? AppPalette.healthGood : AppPalette.gold;
    final text = allCovered
        ? 'All three immune categories covered - great spread.'
        : 'Missing: ${missing.map((c) => c.shortLabel).join(', ')}. '
              'Threats of that color will resist your fire.';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            Icon(
              allCovered ? Icons.check_circle : Icons.warning_amber,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                text,
                style: AppTypography.label.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadoutWeaponCard extends StatelessWidget {
  const _LoadoutWeaponCard({
    required this.weaponId,
    required this.gameState,
    required this.selected,
    required this.onTap,
  });

  final String weaponId;
  final GameState gameState;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final weapon = WeaponCatalog.all[weaponId];
    if (weapon == null) return const SizedBox.shrink();

    final color = categoryDisplayColor(weapon.category);
    final level = gameState.persistentGunState(weaponId).statLevel;

    return PressableAction(
      onPressed: onTap,
      semanticLabel:
          '${selected ? 'Selected weapon' : 'Weapon'}: '
          '${weapon.displayName}, ${weapon.category.shortLabel}',
      semanticValue: selected ? 'Selected' : 'Not selected',
      semanticHint: 'Toggles this weapon in your loadout',
      selected: selected,
      toggled: selected,
      builder:
          (
            context, {
            required enabled,
            required pressed,
            required focused,
            required hovered,
          }) {
            return AnimatedScale(
              scale: pressed ? 0.985 : 1,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 224,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withValues(alpha: focused ? 0.2 : 0.16)
                      : AppPalette.backgroundMid.withValues(
                          alpha: focused || hovered ? 0.96 : 1,
                        ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: color.withValues(alpha: selected ? 0.95 : 0.32),
                    width: focused ? 2.4 : (selected ? 2 : 1),
                  ),
                  boxShadow: focused
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.34),
                            blurRadius: 16,
                          ),
                        ]
                      : const [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CategoryGlyph(
                          category: weapon.category,
                          color: color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            weapon.displayName,
                            style: AppTypography.bodyStrong,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_circle, color: color, size: 18)
                        else
                          const Icon(
                            Icons.circle_outlined,
                            color: AppPalette.textMuted,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        CategoryBadge(category: weapon.category, compact: true),
                        WeaponRoleTag(role: weapon.role),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      level > 0 ? 'Shop level $level' : 'Base weapon',
                      style: AppTypography.label,
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }
}
