import 'package:flutter/material.dart';

/// Backend content can tag a shape-name answer choice as `SHAPE:<key>:<Label>` (e.g.
/// `SHAPE:hexagon:Hexagon`) instead of plain text, so a shape-recognition exercise actually shows
/// the shape rather than asking a child to recognize a shape purely from its written name. Parsed
/// here rather than adding an image/asset column to `exercise_choices` — these are simple
/// geometric shapes fully describable by a key, not photos that would need real asset storage.
const String shapeTokenPrefix = 'SHAPE:';

class ParsedShapeChoice {
  const ParsedShapeChoice({required this.shapeKey, required this.label});
  final String shapeKey;
  final String label;
}

/// Returns the parsed shape+label if [text] is a shape token, otherwise null (meaning: render it
/// as plain text, same as before).
ParsedShapeChoice? parseShapeChoice(String text) {
  if (!text.startsWith(shapeTokenPrefix)) return null;
  final List<String> parts = text.substring(shapeTokenPrefix.length).split(':');
  if (parts.length != 2) return null;
  return ParsedShapeChoice(shapeKey: parts[0], label: parts[1]);
}

/// A small, precisely-drawn vector shape — not a photo or emoji, so it renders identically and
/// crisply across every platform/font instead of depending on emoji glyph support.
class ShapeIcon extends StatelessWidget {
  const ShapeIcon({super.key, required this.shapeKey, this.size = 28, this.color});
  final String shapeKey;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color fill = color ?? Theme.of(context).colorScheme.primary;
    switch (shapeKey) {
      case 'circle':
        return _circle(size, fill);
      case 'sphere':
        return _sphere(size, fill);
      case 'square':
        return _square(size, fill);
      case 'cube':
        return _cube(size, fill);
      case 'rectangle':
        return _rectangle(size, fill);
      case 'triangle':
        return CustomPaint(size: Size(size, size), painter: _PolygonPainter(sides: 3, color: fill));
      case 'pentagon':
        return CustomPaint(size: Size(size, size), painter: _PolygonPainter(sides: 5, color: fill));
      case 'hexagon':
        return CustomPaint(size: Size(size, size), painter: _PolygonPainter(sides: 6, color: fill));
      default:
        return SizedBox(width: size, height: size);
    }
  }

  Widget _circle(double size, Color fill) =>
      Container(width: size, height: size, decoration: BoxDecoration(color: fill, shape: BoxShape.circle));

  Widget _sphere(double size, Color fill) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              center: const Alignment(-0.35, -0.35),
              colors: <Color>[Color.lerp(fill, Colors.white, 0.55)!, fill],
              stops: const <double>[0, 1])));

  Widget _square(double size, Color fill) =>
      Container(width: size, height: size, decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(2)));

  Widget _rectangle(double size, Color fill) => Container(
      width: size * 1.4, height: size * 0.75, decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(2)));

  Widget _cube(double size, Color fill) =>
      CustomPaint(size: Size(size, size), painter: _CubePainter(color: fill));
}

/// Draws a regular polygon with [sides] corners, point-up, filling the given canvas size.
class _PolygonPainter extends CustomPainter {
  const _PolygonPainter({required this.sides, required this.color});
  final int sides;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Path path = Path();
    for (int i = 0; i < sides; i++) {
      final double angle = (-90 + i * 360 / sides) * 3.1415926535 / 180;
      final Offset point = Offset(center.dx + radius * _cos(angle), center.dy + radius * _sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double radians) => _taylorCos(radians);
  double _sin(double radians) => _taylorCos(radians - 1.5707963267948966);

  // Small, dependency-free cosine approximation (good enough for drawing a polygon outline) —
  // avoids pulling in dart:math just for two trig calls, consistent with keeping this a tiny,
  // self-contained painter.
  double _taylorCos(double x) {
    while (x > 3.141592653589793) {
      x -= 2 * 3.141592653589793;
    }
    while (x < -3.141592653589793) {
      x += 2 * 3.141592653589793;
    }
    final double x2 = x * x;
    return 1 - x2 / 2 + (x2 * x2) / 24 - (x2 * x2 * x2) / 720;
  }

  @override
  bool shouldRepaint(covariant _PolygonPainter oldDelegate) =>
      oldDelegate.sides != sides || oldDelegate.color != color;
}

class _CubePainter extends CustomPainter {
  const _CubePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double depth = w * 0.3;
    final Paint front = Paint()..color = color;
    final Paint top = Paint()..color = Color.lerp(color, Colors.white, 0.35)!;
    final Paint side = Paint()..color = Color.lerp(color, Colors.black, 0.2)!;

    final Rect frontRect = Rect.fromLTWH(0, depth, w - depth, h - depth);
    canvas.drawRect(frontRect, front);

    final Path topFace = Path()
      ..moveTo(0, depth)
      ..lineTo(depth, 0)
      ..lineTo(w, 0)
      ..lineTo(w - depth, depth)
      ..close();
    canvas.drawPath(topFace, top);

    final Path sideFace = Path()
      ..moveTo(w - depth, depth)
      ..lineTo(w, 0)
      ..lineTo(w, h - depth)
      ..lineTo(w - depth, h)
      ..close();
    canvas.drawPath(sideFace, side);
  }

  @override
  bool shouldRepaint(covariant _CubePainter oldDelegate) => oldDelegate.color != color;
}
