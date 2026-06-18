import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../../data/maps/biome_catalog.dart';
import '../../data/maps/biome_def.dart';
import '../../ui/widgets/blob_painter.dart';
import '../pdac_game.dart';

/// Renders the arena's gradient backdrop plus a handful of slow-drifting,
/// low-opacity decorative blobs. Always sized to [PdacGame.arenaSize] and
/// kept behind every other component (added first).
///
/// The look is driven by the active [BiomeDef]: [applyBiome] swaps the
/// gradient and regenerates the decorative blobs so each map (bloodstream,
/// pancreas, salivary gland, ...) reads as a distinct place.
class ArenaBackground extends PositionComponent
    with HasGameReference<PdacGame> {
  ArenaBackground() : super(priority: -1);

  final List<_DriftBlob> _blobs = [];
  double _time = 0;

  BiomeDef _biome = BiomeCatalog.bloodstream;
  late Gradient _gradient = _gradientFor(_biome);

  @override
  Future<void> onLoad() async {
    size = game.arenaSize.clone();
    _rebuildBlobs();
  }

  /// Switches the backdrop to [biome]: rebuilds the gradient and regenerates
  /// the decorative blobs in the biome's colors. Safe to call on every round
  /// start - it's cheap and only the visuals change.
  void applyBiome(BiomeDef biome) {
    _biome = biome;
    _gradient = _gradientFor(biome);
    size = game.arenaSize.clone();
    _rebuildBlobs();
  }

  Gradient _gradientFor(BiomeDef biome) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: biome.backgroundColors,
  );

  void _rebuildBlobs() {
    _blobs.clear();
    // Seed by biome so each map's layout is stable but distinct between maps.
    final rng = Random(_biome.sectionIndex * 31 + 7);
    for (var i = 0; i < _biome.decorBlobCount; i++) {
      final radius = 40.0 + rng.nextDouble() * 90;
      _blobs.add(
        _DriftBlob(
          spec: BlobShapeSpec.generate(
            rng: rng,
            baseRadius: radius,
            quality: game.settings.value.animationQuality,
          ),
          basePosition: Vector2(
            rng.nextDouble() * size.x,
            rng.nextDouble() * size.y,
          ),
          driftRadius: 20 + rng.nextDouble() * 40,
          driftSpeed: 0.05 + rng.nextDouble() * 0.1,
          phase: rng.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.settings.value.reduceMotion) {
      _time +=
          dt * game.settings.value.animationQuality.backgroundAnimationSpeed;
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // Experimental sprite mode: stretch the biome texture across the arena.
    if (game.useSprites) {
      final img = game.spritePack.biome(_biome.id);
      if (img != null) {
        canvas.drawImageRect(
          img,
          Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          rect,
          Paint()..filterQuality = FilterQuality.none,
        );
        return;
      }
    }

    canvas.drawRect(rect, Paint()..shader = _gradient.createShader(rect));

    for (final blob in _blobs) {
      final offset = Offset(
        cos(_time * blob.driftSpeed + blob.phase) * blob.driftRadius,
        sin(_time * blob.driftSpeed * 0.8 + blob.phase) * blob.driftRadius,
      );
      final center = Offset(
        blob.basePosition.x + offset.dx,
        blob.basePosition.y + offset.dy,
      );
      BlobPainter.paint(
        canvas,
        spec: blob.spec,
        center: center,
        time: _time,
        primaryColor: _biome.decorColor,
        accentColor: _biome.decorAccent,
        quality: game.settings.value.animationQuality,
        rimColor: _biome.decorAccent,
        opacity: 0.12,
      );
    }
  }
}

class _DriftBlob {
  _DriftBlob({
    required this.spec,
    required this.basePosition,
    required this.driftRadius,
    required this.driftSpeed,
    required this.phase,
  });

  final BlobShapeSpec spec;
  final Vector2 basePosition;
  final double driftRadius;
  final double driftSpeed;
  final double phase;
}
