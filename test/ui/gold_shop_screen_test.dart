import 'package:flutter_test/flutter_test.dart';

import 'package:pdac_immune_defense/data/progression/gun_upgrade_def.dart';
import 'package:pdac_immune_defense/theme/palette.dart';
import 'package:pdac_immune_defense/ui/screens/gold_shop_screen.dart';

void main() {
  test('gold shop stat labels are player-facing names', () {
    expect(goldShopStatLabel(WeaponStat.damage), 'Damage');
    expect(goldShopStatLabel(WeaponStat.fireRate), 'Fire Rate');
    expect(goldShopStatLabel(WeaponStat.bulletSpeed), 'Bullet Speed');
  });

  test('gold shop affordability helper explains purchase state', () {
    expect(
      goldShopAffordabilityLabel(cost: null, gold: 0),
      'Upgrade track complete',
    );
    expect(goldShopAffordabilityLabel(cost: 20, gold: 20), 'Ready to purchase');
    expect(goldShopAffordabilityLabel(cost: 20, gold: 12), 'Need 8 more gold');
  });

  test('gold shop affordability color highlights ready and short states', () {
    expect(
      goldShopAffordabilityColor(cost: null, gold: 0),
      AppPalette.healthGood,
    );
    expect(
      goldShopAffordabilityColor(cost: 20, gold: 20),
      AppPalette.healthGood,
    );
    expect(goldShopAffordabilityColor(cost: 20, gold: 12), AppPalette.gold);
  });
}
