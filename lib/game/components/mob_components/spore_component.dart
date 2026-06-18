import '../../../data/enemies/enemy_catalog.dart';
import '../mob_component.dart';

/// Convenience constructor for spawning a [MobComponent] using
/// [EnemyCatalog.fungalSpore]. The lingering damage cloud spawned on death
/// is implemented by [SporeCloudBehavior] (see
/// `data/enemies/mob_behaviors.dart`) via [PdacGame.spawnDamageCloud].
class SporeComponent extends MobComponent {
  SporeComponent({
    required super.position,
    super.generation = 0,
    super.healthOverride,
    super.radiusOverride,
    super.isElite = false,
  }) : super(def: EnemyCatalog.fungalSpore);
}
