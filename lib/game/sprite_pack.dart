import 'dart:ui';

import 'package:flame/cache.dart';

import '../data/enemies/enemy_catalog.dart';

/// Loads and holds the experimental pixel-art sprite pack (assets/images/).
///
/// Loading is tolerant of missing files: any sprite that fails to load is
/// simply absent, and the corresponding component falls back to procedural
/// ("classic") rendering. This lets a partial or replacement pack be dropped
/// in without breaking anything.
class SpritePack {
  final Map<String, Image> _images = {};
  bool loaded = false;

  Future<void> load(Images cache) async {
    final names = <String>[
      'player',
      'boss',
      for (final id in EnemyCatalog.all.keys) 'enemy_$id',
      'biome_bloodstream',
      'biome_pancreas',
      'biome_salivary_gland',
    ];
    for (final name in names) {
      try {
        _images[name] = await cache.load('$name.png');
      } catch (_) {
        // Missing sprite - component renders procedurally instead.
      }
    }
    loaded = true;
  }

  Image? player() => _images['player'];
  Image? boss() => _images['boss'];
  Image? enemy(String id) => _images['enemy_$id'];
  Image? biome(String id) => _images['biome_$id'];
}
