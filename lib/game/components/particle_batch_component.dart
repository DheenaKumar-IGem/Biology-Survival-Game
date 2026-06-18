import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// A single component that owns all short-lived hit/death particles.
///
/// This avoids creating dozens of tiny Flame components during crowded
/// fights, which is especially helpful when burst waves and shotgun pellets
/// are both active.
class ParticleBatchComponent extends Component {
  final List<_ParticleEntry> _particles = [];

  int get activeCount => _particles.length;

  void spawn({
    required Vector2 position,
    required Vector2 velocity,
    required Color color,
    double lifespan = 0.4,
    double size = 4,
  }) {
    _particles.add(
      _ParticleEntry(
        position: position.clone(),
        velocity: velocity.clone(),
        color: color,
        lifespan: lifespan,
        size: size,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (var i = _particles.length - 1; i >= 0; i--) {
      final particle = _particles[i];
      particle.age += dt;
      if (particle.age >= particle.lifespan) {
        _particles.removeAt(i);
        continue;
      }
      particle.position.add(particle.velocity * dt);
      particle.velocity.scale(0.9);
    }
  }

  // Pooled paints reused across all particles each frame (render is
  // single-threaded), so the juicier multi-layer look doesn't allocate.
  static final Paint _core = Paint();
  static final Paint _glow = Paint()..blendMode = BlendMode.plus;
  static final Paint _streak = Paint()..strokeCap = StrokeCap.round;
  static const Color _white = Color(0xFFFFFFFF);

  @override
  void render(Canvas canvas) {
    for (final particle in _particles) {
      final t = (particle.age / particle.lifespan).clamp(0.0, 1.0);
      final alpha = 1 - t;
      // Hot white core early in life that cools to the category color.
      final color = Color.lerp(_white, particle.color, (t * 1.6).clamp(0.0, 1.0))!;
      final pos = Offset(particle.position.x, particle.position.y);
      final r = particle.size / 2 * (1 - t * 0.5);

      // Velocity-aligned streak for fast particles (cheap sense of motion).
      final vx = particle.velocity.x;
      final vy = particle.velocity.y;
      final speed2 = vx * vx + vy * vy;
      if (speed2 > 1600) {
        final inv = 1 / sqrt(speed2);
        final tail = Offset(pos.dx - vx * inv * r * 2.4, pos.dy - vy * inv * r * 2.4);
        _streak
          ..color = color.withValues(alpha: alpha * 0.5)
          ..strokeWidth = r * 0.9;
        canvas.drawLine(tail, pos, _streak);
      }

      // Additive glow halo, then the solid core.
      _glow.color = color.withValues(alpha: alpha * 0.25);
      canvas.drawCircle(pos, r * 1.8, _glow);
      _core.color = color.withValues(alpha: alpha);
      canvas.drawCircle(pos, r, _core);
    }
  }
}

class _ParticleEntry {
  _ParticleEntry({
    required this.position,
    required this.velocity,
    required this.color,
    required this.lifespan,
    required this.size,
  });

  final Vector2 position;
  final Vector2 velocity;
  final Color color;
  final double lifespan;
  final double size;
  double age = 0;
}
