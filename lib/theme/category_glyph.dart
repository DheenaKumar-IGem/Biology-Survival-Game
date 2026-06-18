import 'package:flutter/widgets.dart';

import '../data/categories.dart';

/// Single source of truth for the category shape language: diamond (innate),
/// ring (antibody), triangle (cytotoxic), centered at [center] within radius
/// [g]. [fill] paints the solid shapes; [stroke] paints the ring (the caller
/// sets its `strokeWidth`).
///
/// Shared by the arena (mobs/bullets, in colorblind mode) and the UI
/// (badges/weapon chips/shop) so a player who learns "triangle = cytotoxic" in
/// the fight sees the same shape in menus.
void drawCategoryGlyph(
  Canvas canvas,
  ImmuneCategory category,
  Offset center,
  double g,
  Paint fill,
  Paint stroke,
) {
  switch (category) {
    case ImmuneCategory.innate:
      canvas.drawPath(
        Path()
          ..moveTo(center.dx, center.dy - g)
          ..lineTo(center.dx + g * 0.82, center.dy)
          ..lineTo(center.dx, center.dy + g)
          ..lineTo(center.dx - g * 0.82, center.dy)
          ..close(),
        fill,
      );
    case ImmuneCategory.antibody:
      canvas.drawCircle(center, g * 0.78, stroke);
    case ImmuneCategory.cytotoxic:
      canvas.drawPath(
        Path()
          ..moveTo(center.dx, center.dy - g)
          ..lineTo(center.dx + g, center.dy + g * 0.78)
          ..lineTo(center.dx - g, center.dy + g * 0.78)
          ..close(),
        fill,
      );
  }
}

/// A small widget that renders [drawCategoryGlyph] in [color] at [size] -
/// the UI counterpart of the arena's category glyphs.
class CategoryGlyph extends StatelessWidget {
  const CategoryGlyph({
    super.key,
    required this.category,
    required this.color,
    this.size = 16,
  });

  final ImmuneCategory category;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _CategoryGlyphPainter(category, color),
    );
  }
}

class _CategoryGlyphPainter extends CustomPainter {
  _CategoryGlyphPainter(this.category, this.color);

  final ImmuneCategory category;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.shortestSide * 0.16).clamp(1.5, 4.0);
    drawCategoryGlyph(canvas, category, center, size.shortestSide * 0.5, fill, stroke);
  }

  @override
  bool shouldRepaint(covariant _CategoryGlyphPainter old) =>
      old.category != category || old.color != color;
}
