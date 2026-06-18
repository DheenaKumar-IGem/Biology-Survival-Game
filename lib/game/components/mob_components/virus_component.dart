import '../../../data/enemies/enemy_catalog.dart';
import '../mob_component.dart';

/// Convenience constructor for spawning a [MobComponent] using
/// [EnemyCatalog.virus]. All mitosis-split logic lives in
/// [MitosisBehavior] (see `data/enemies/mob_behaviors.dart`) - this class
/// just fixes the [EnemyDef].
class VirusComponent extends MobComponent {
  VirusComponent({
    required super.position,
    super.generation = 0,
    super.healthOverride,
    super.radiusOverride,
    super.isElite = false,
  }) : super(def: EnemyCatalog.virus);
}
