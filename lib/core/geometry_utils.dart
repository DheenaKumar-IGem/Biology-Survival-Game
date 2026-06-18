import 'dart:math';
import 'dart:ui';

/// Builds a smooth closed Catmull-Rom spline path through [points].
///
/// This is the core trick used to render "fluid" blob shapes: instead of a
/// perfect circle or polygon, we pass a wobbling ring of points through a
/// Catmull-Rom spline so the silhouette gets gentle, organic curves between
/// each control point.
Path catmullRomClosedPath(List<Offset> points) {
  final path = Path();
  if (points.isEmpty) return path;
  if (points.length < 3) {
    path.addOval(Rect.fromCircle(center: points.first, radius: 1));
    return path;
  }

  final n = points.length;
  Offset point(int i) => points[i % n];

  path.moveTo(point(0).dx, point(0).dy);
  for (var i = 0; i < n; i++) {
    final p0 = point(i - 1);
    final p1 = point(i);
    final p2 = point(i + 1);
    final p3 = point(i + 2);

    // Catmull-Rom to Bezier control points.
    final cp1 = Offset(
      p1.dx + (p2.dx - p0.dx) / 6,
      p1.dy + (p2.dy - p0.dy) / 6,
    );
    final cp2 = Offset(
      p2.dx - (p3.dx - p1.dx) / 6,
      p2.dy - (p3.dy - p1.dy) / 6,
    );

    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
  }
  path.close();
  return path;
}

/// Generates the ring of points used by [catmullRomClosedPath] for a
/// wobbling blob: each point sits at `baseRadius + wobble` along an evenly
/// spaced angle, where `wobble` is a sine wave driven by [time] with a
/// per-point [phaseOffsets] so points wobble out of sync for an organic look.
List<Offset> blobRingPoints({
  required Offset center,
  required double baseRadius,
  required double time,
  required List<double> phaseOffsets,
  required double wobbleAmplitude,
  required double wobbleSpeed,
}) {
  final n = phaseOffsets.length;
  final points = <Offset>[];
  for (var i = 0; i < n; i++) {
    final angle = 2 * pi * i / n;
    final wobble = sin(time * wobbleSpeed + phaseOffsets[i]) * wobbleAmplitude;
    final r = baseRadius + wobble;
    points.add(Offset(center.dx + cos(angle) * r, center.dy + sin(angle) * r));
  }
  return points;
}

/// Deterministic-ish per-instance phase offsets for blob wobble, derived
/// from a [Random] so each mob/decoration looks slightly different.
List<double> randomPhaseOffsets(Random rng, int count) {
  return List.generate(count, (_) => rng.nextDouble() * 2 * pi);
}
