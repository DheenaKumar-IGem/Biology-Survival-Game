import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../core/geometry_utils.dart';
import '../../services/settings_service.dart';
import '../../theme/fx_constants.dart';

/// Describes the wobble shape of a single blob instance. Generate one per
/// mob/decoration (via [BlobShapeSpec.generate]) and reuse it every frame -
/// only [time] changes.
class BlobShapeSpec {
  const BlobShapeSpec({
    required this.pointCount,
    required this.baseRadius,
    required this.wobbleAmplitude,
    required this.phaseOffsets,
    required this.wobbleSpeed,
  });

  final int pointCount;
  final double baseRadius;
  final double wobbleAmplitude;
  final List<double> phaseOffsets;
  final double wobbleSpeed;

  /// Builds a spec sized for [baseRadius], with point count and wobble
  /// amplitude/speed driven by the current [AnimationQuality] setting.
  factory BlobShapeSpec.generate({
    required Random rng,
    required double baseRadius,
    AnimationQuality quality = AnimationQuality.high,
    double? wobbleSpeed,
  }) {
    final pointCount = max(4, quality.blobPointCount);
    return BlobShapeSpec(
      pointCount: pointCount,
      baseRadius: baseRadius,
      wobbleAmplitude: baseRadius * FxConstants.blobWobbleAmplitudeFraction,
      phaseOffsets: randomPhaseOffsets(rng, pointCount),
      wobbleSpeed: wobbleSpeed ?? FxConstants.blobWobbleSpeed,
    );
  }

  Path buildPath(Offset center, double time, {double radiusScale = 1.0}) {
    final points = blobRingPoints(
      center: center,
      baseRadius: baseRadius * radiusScale,
      time: time,
      phaseOffsets: phaseOffsets,
      wobbleAmplitude: wobbleAmplitude * radiusScale,
      wobbleSpeed: wobbleSpeed,
    );
    return catmullRomClosedPath(points);
  }
}

/// Caches the [Shader] built from a [RadialGradient] for [BlobPainter]'s
/// fill layer. Construct one per blob instance (mob/player/boss) and pass
/// it into [BlobPainter.paint] - the shader is only rebuilt when the fill
/// colors/opacity actually change (e.g. hit-flash), not every frame.
class FillShaderCache {
  Color? _primary;
  Color? _accent;
  double? _opacity;
  Rect? _rect;
  Shader? _shader;

  Shader resolve(Rect rect, Color primary, Color accent, double opacity) {
    if (_shader != null &&
        _rect == rect &&
        _primary == primary &&
        _accent == accent &&
        _opacity == opacity) {
      return _shader!;
    }
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Color.lerp(primary, accent, 0.55)!.withValues(alpha: opacity),
        primary.withValues(alpha: opacity),
        Color.lerp(
          primary,
          const Color(0xFF000000),
          0.25,
        )!.withValues(alpha: opacity),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
    final shader = gradient.createShader(rect);
    _rect = rect;
    _primary = primary;
    _accent = accent;
    _opacity = opacity;
    _shader = shader;
    return shader;
  }
}

/// Stateless helpers for painting a "fluid animated circular germ" blob in
/// layers. Used by [MobComponent]'s renderer and by decorative UI (home
/// screen background blobs, hero mascot).
///
/// Layer order (back to front):
/// 1. Soft outer glow
/// 2. Radial-gradient fill
/// 3. Optional membrane/shield ring
/// 4. Drifting nucleus dot(s)
/// 5. Pulsing resistance/mutation ring
/// 6. Thin rim light
class BlobPainter {
  BlobPainter._();

  // Pooled paints reused across every blob (rendering is single-threaded and
  // each layer resets its own properties before drawing), so a busy arena
  // doesn't allocate ~6 Paints per creature per frame.
  static final Paint _glowPaint = Paint();
  static final Paint _fillPaint = Paint();
  static final Paint _membranePaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _nucleusPaint = Paint();
  static final Paint _nucleusSmallPaint = Paint();
  static final Paint _ringPaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _rimPaint = Paint()..style = PaintingStyle.stroke;

  /// Paints the full layered blob. All layers except the fill are
  /// optional and can be disabled for low [AnimationQuality] or when a
  /// mechanic doesn't apply (e.g. no shield, no resistance).
  static void paint(
    Canvas canvas, {
    required BlobShapeSpec spec,
    required Offset center,
    required double time,
    required Color primaryColor,
    required Color accentColor,
    AnimationQuality quality = AnimationQuality.high,
    double membraneFraction = 0.0,
    int resistanceTier = 0,
    Color? rimColor,
    double opacity = 1.0,
    FillShaderCache? fillCache,
  }) {
    final path = spec.buildPath(center, time);

    if (quality.glowEnabled) {
      _paintGlow(canvas, path, primaryColor, quality, opacity);
    }

    _paintFill(
      canvas,
      path,
      center,
      spec.baseRadius,
      primaryColor,
      accentColor,
      opacity,
      fillCache,
    );

    if (membraneFraction > 0) {
      _paintMembrane(
        canvas,
        spec,
        center,
        time,
        accentColor,
        membraneFraction,
        opacity,
      );
    }

    _paintNuclei(canvas, center, spec.baseRadius, time, accentColor, opacity);

    if (resistanceTier > 0) {
      _paintResistanceRing(canvas, spec, center, time, resistanceTier, opacity);
    }

    _paintRimLight(canvas, path, rimColor ?? accentColor, opacity);
  }

  static void _paintGlow(
    Canvas canvas,
    Path path,
    Color color,
    AnimationQuality quality,
    double opacity,
  ) {
    final blur = FxConstants.glowBlurHigh * quality.glowMultiplier;
    if (blur <= 0) return;
    _glowPaint
      ..color = color.withValues(alpha: 0.35 * opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    canvas.drawPath(path, _glowPaint);
  }

  static void _paintFill(
    Canvas canvas,
    Path path,
    Offset center,
    double radius,
    Color primary,
    Color accent,
    double opacity,
    FillShaderCache? fillCache,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius * 1.1);
    final shader = fillCache != null
        ? fillCache.resolve(rect, primary, accent, opacity)
        : RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color.lerp(primary, accent, 0.55)!.withValues(alpha: opacity),
              primary.withValues(alpha: opacity),
              Color.lerp(
                primary,
                const Color(0xFF000000),
                0.25,
              )!.withValues(alpha: opacity),
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(rect);
    _fillPaint.shader = shader;
    canvas.drawPath(path, _fillPaint);
  }

  static void _paintMembrane(
    Canvas canvas,
    BlobShapeSpec spec,
    Offset center,
    double time,
    Color accent,
    double membraneFraction,
    double opacity,
  ) {
    final membranePath = spec.buildPath(
      center,
      time * 0.7,
      radiusScale: 1.0 + 0.18 * membraneFraction.clamp(0, 1),
    );
    _membranePaint
      ..color = accent.withValues(
        alpha: 0.28 * opacity * membraneFraction.clamp(0, 1),
      )
      ..strokeWidth = max(1.5, spec.baseRadius * 0.18);
    canvas.drawPath(membranePath, _membranePaint);
  }

  static void _paintNuclei(
    Canvas canvas,
    Offset center,
    double radius,
    double time,
    Color accent,
    double opacity,
  ) {
    final driftRadius = radius * 0.28;
    final nucleusRadius = radius * 0.22;
    final offset = Offset(
      cos(time * 0.9) * driftRadius * 0.4,
      sin(time * 0.7) * driftRadius * 0.4,
    );
    _nucleusPaint.color = accent.withValues(alpha: 0.5 * opacity);
    canvas.drawCircle(center + offset, nucleusRadius, _nucleusPaint);

    _nucleusSmallPaint.color = accent.withValues(alpha: 0.35 * opacity);
    final smallOffset = Offset(
      cos(time * 1.3 + pi) * driftRadius * 0.7,
      sin(time * 1.1 + pi) * driftRadius * 0.7,
    );
    canvas.drawCircle(
      center + smallOffset,
      nucleusRadius * 0.5,
      _nucleusSmallPaint,
    );
  }

  static void _paintResistanceRing(
    Canvas canvas,
    BlobShapeSpec spec,
    Offset center,
    double time,
    int resistanceTier,
    double opacity,
  ) {
    final pulse = 0.6 + 0.4 * sin(time * 3.0).abs();
    final ringPath = spec.buildPath(
      center,
      time * 1.2,
      radiusScale: 1.12 + 0.03 * resistanceTier,
    );
    _ringPaint
      ..color = const Color(
        0xFFFFE08A,
      ).withValues(alpha: (0.25 + 0.15 * resistanceTier) * pulse * opacity)
      ..strokeWidth = 1.5 + resistanceTier.toDouble();
    canvas.drawPath(ringPath, _ringPaint);
  }

  static void _paintRimLight(
    Canvas canvas,
    Path path,
    Color rimColor,
    double opacity,
  ) {
    _rimPaint
      ..color = rimColor.withValues(alpha: 0.55 * opacity)
      ..strokeWidth = 1.5;
    canvas.drawPath(path, _rimPaint);
  }
}

/// A self-animating decorative blob for use in plain Flutter UI (home
/// screen background, hero mascot). Game mobs render via [BlobPainter]
/// directly inside their Flame [Component.render] instead of this widget.
class AnimatedBlob extends StatefulWidget {
  const AnimatedBlob({
    super.key,
    required this.radius,
    required this.primaryColor,
    required this.accentColor,
    this.rimColor,
    this.seed = 0,
  });

  final double radius;
  final Color primaryColor;
  final Color accentColor;
  final Color? rimColor;
  final int seed;

  @override
  State<AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<AnimatedBlob>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final BlobShapeSpec _spec;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _spec = BlobShapeSpec.generate(
      rng: Random(widget.seed),
      baseRadius: widget.radius,
      quality: SettingsService.instance.value.animationQuality,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = SettingsService.instance.value.reduceMotion;
    final size = Size.square(widget.radius * 2.6);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final time = reduceMotion ? 0.0 : _controller.value * 2 * pi * 4;
        return CustomPaint(
          size: size,
          painter: _BlobCustomPainter(
            spec: _spec,
            time: time,
            primaryColor: widget.primaryColor,
            accentColor: widget.accentColor,
            rimColor: widget.rimColor,
            quality: SettingsService.instance.value.animationQuality,
          ),
        );
      },
    );
  }
}

class _BlobCustomPainter extends CustomPainter {
  _BlobCustomPainter({
    required this.spec,
    required this.time,
    required this.primaryColor,
    required this.accentColor,
    required this.rimColor,
    required this.quality,
  });

  final BlobShapeSpec spec;
  final double time;
  final Color primaryColor;
  final Color accentColor;
  final Color? rimColor;
  final AnimationQuality quality;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    BlobPainter.paint(
      canvas,
      spec: spec,
      center: center,
      time: time,
      primaryColor: primaryColor,
      accentColor: accentColor,
      rimColor: rimColor,
      quality: quality,
    );
  }

  @override
  bool shouldRepaint(covariant _BlobCustomPainter oldDelegate) =>
      oldDelegate.time != time;
}
