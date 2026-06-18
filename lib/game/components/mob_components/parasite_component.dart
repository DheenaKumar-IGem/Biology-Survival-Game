import '../../../data/enemies/enemy_catalog.dart';
import '../mob_component.dart';

/// Convenience constructor for spawning a [MobComponent] using
/// [EnemyCatalog.parasite]. The wounded speed-boost lives in
/// [EnrageBehavior] (see `data/enemies/mob_behaviors.dart`).
class ParasiteComponent extends MobComponent {
  ParasiteComponent({
    required super.position,
    super.generation = 0,
    super.healthOverride,
    super.radiusOverride,
    super.isElite = false,
  }) : super(def: EnemyCatalog.parasite);
}
