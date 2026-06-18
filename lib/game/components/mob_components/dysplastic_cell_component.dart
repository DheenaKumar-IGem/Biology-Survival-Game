import '../../../data/enemies/enemy_catalog.dart';
import '../mob_component.dart';

/// Convenience constructor for spawning a [MobComponent] using
/// [EnemyCatalog.dysplasticCell]. The regeneration-when-undamaged logic
/// lives in [RegenerationBehavior] (see `data/enemies/mob_behaviors.dart`).
class DysplasticCellComponent extends MobComponent {
  DysplasticCellComponent({
    required super.position,
    super.generation = 0,
    super.healthOverride,
    super.radiusOverride,
    super.isElite = false,
  }) : super(def: EnemyCatalog.dysplasticCell);
}
