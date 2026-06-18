import '../../../data/enemies/enemy_catalog.dart';
import '../mob_component.dart';

/// Convenience constructor for spawning a [MobComponent] using
/// [EnemyCatalog.bacteria]. Shield absorb/regen logic lives in
/// [BiofilmShieldBehavior] (see `data/enemies/mob_behaviors.dart`).
class BacteriaComponent extends MobComponent {
  BacteriaComponent({
    required super.position,
    super.generation = 0,
    super.healthOverride,
    super.radiusOverride,
    super.isElite = false,
  }) : super(def: EnemyCatalog.bacteria);
}
