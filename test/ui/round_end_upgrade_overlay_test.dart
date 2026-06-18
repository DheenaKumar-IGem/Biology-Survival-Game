import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pdac_immune_defense/data/progression/gun_upgrade_def.dart';
import 'package:pdac_immune_defense/theme/palette.dart';
import 'package:pdac_immune_defense/ui/overlays/round_end_upgrade_overlay.dart';

void main() {
  test('upgrade display helpers identify each stat type', () {
    expect(upgradeStatLabel(WeaponStat.damage), 'Damage boost');
    expect(upgradeStatLabel(WeaponStat.fireRate), 'Fire-rate boost');
    expect(upgradeStatLabel(WeaponStat.bulletSpeed), 'Projectile speed');

    expect(upgradeIcon(WeaponStat.damage), Icons.bolt);
    expect(upgradeIcon(WeaponStat.fireRate), Icons.speed);
    expect(upgradeIcon(WeaponStat.bulletSpeed), Icons.open_in_full);

    expect(upgradeColor(WeaponStat.damage), AppPalette.healthLow);
    expect(upgradeColor(WeaponStat.fireRate), AppPalette.playerCore);
    expect(upgradeColor(WeaponStat.bulletSpeed), AppPalette.gold);
  });
}
