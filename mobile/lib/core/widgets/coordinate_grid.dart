import 'package:flutter/material.dart';

/// Coordinate-plane lessons (Grade 5/6) already state the exact points in question as plain text
/// — "the point (3,5)", "(2,3) and (2,7)" — so unlike the other visual tags, this one needs no
/// backend migration at all: the client just extracts the points straight out of the existing
/// prompt text.
final RegExp _pointPattern = RegExp(r'\((-?\d+)\s*,\s*(-?\d+)\)');

List<Offset> extractPlanePoints(String text) => _pointPattern
    .allMatches(text)
    .map((RegExpMatch m) => Offset(double.parse(m.group(1)!), double.parse(m.group(2)!)))
    .toList();

/// A small coordinate grid with the given points plotted, auto-scaled to fit them (plus a little
/// padding) and switching to a full four-quadrant grid only when a negative coordinate is present.
class CoordinateGrid extends StatelessWidget {
  const CoordinateGrid({super.key, required this.points, this.height = 160, this.color});
  final List<Offset> points;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
      height: height,
      width: height,
      child: CustomPaint(
          painter: _CoordinateGridPainter(
              points: points, color: color ?? Theme.of(context).colorScheme.primary)));
}

class _CoordinateGridPainter extends CustomPainter {
  const _CoordinateGridPainter({required this.points, required this.color});
  final List<Offset> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final double maxAbsX = points.map((Offset p) => p.dx.abs()).reduce((a, b) => a > b ? a : b);
    final double maxAbsY = points.map((Offset p) => p.dy.abs()).reduce((a, b) => a > b ? a : b);
    final bool hasNegative = points.any((Offset p) => p.dx < 0 || p.dy < 0);
    final double bound = (maxAbsX > maxAbsY ? maxAbsX : maxAbsY).clamp(1, double.infinity) + 1;

    final double padding = 12;
    final double drawable = size.width - padding * 2;
    final Offset origin =
        hasNegative ? Offset(size.width / 2, size.height / 2) : Offset(padding, size.height - padding);
    final double scale = hasNegative ? (drawable / 2) / bound : drawable / bound;

    Offset toCanvas(Offset p) => Offset(origin.dx + p.dx * scale, origin.dy - p.dy * scale);

    final Paint axisPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.2;
    final Paint gridPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    final double gridMin = hasNegative ? -bound : 0;
    for (double i = gridMin; i <= bound; i++) {
      canvas.drawLine(toCanvas(Offset(i, gridMin)), toCanvas(Offset(i, bound)), gridPaint);
      canvas.drawLine(toCanvas(Offset(gridMin, i)), toCanvas(Offset(bound, i)), gridPaint);
    }

    canvas.drawLine(toCanvas(Offset(gridMin, 0)), toCanvas(Offset(bound, 0)), axisPaint);
    canvas.drawLine(toCanvas(Offset(0, gridMin)), toCanvas(Offset(0, bound)), axisPaint);

    final Paint pointPaint = Paint()..color = color;
    for (final Offset p in points) {
      canvas.drawCircle(toCanvas(p), 4, pointPaint);
    }
    if (points.length > 1) {
      final Path path = Path()..moveTo(toCanvas(points.first).dx, toCanvas(points.first).dy);
      for (final Offset p in points.skip(1)) {
        path.lineTo(toCanvas(p).dx, toCanvas(p).dy);
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = color.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4);
    }
  }

  @override
  bool shouldRepaint(covariant _CoordinateGridPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}
