import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'vector_math.dart' as vector_math;

/// The app's one recurring decorative motif — a four-point sparkle, drawn rather than sourced as
/// an image asset (same reasoning as every other hand-drawn visual in this app: no image
/// generation is available, and a few lines of vector math cost nothing to ship). Used on the
/// auth screen's hero, empty states, and celebratory moments so "Nova" means something visually,
/// not just in the app's name.
class NovaStar extends StatelessWidget {
  const NovaStar({super.key, this.size = 32, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(color: color ?? Theme.of(context).colorScheme.tertiary));
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double outer = size.width / 2;
    final double inner = outer * 0.32;
    final Path path = Path();
    for (int i = 0; i < 8; i++) {
      final double angle = i * vector_math.pi / 4 - vector_math.pi / 2;
      final double radius = i.isEven ? outer : inner;
      final Offset point = Offset(
          center.dx + radius * vector_math.taylorCos(angle),
          center.dy + radius * vector_math.taylorSin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawCircle(center, inner * 0.55, Paint()..color = Colors.white.withValues(alpha: 0.65));
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => oldDelegate.color != color;
}

/// A loose scatter of small sparkles at fixed, deterministic positions/sizes — a decorative
/// backdrop for a hero section. Deterministic (not `Random()` reseeded each build) so it doesn't
/// visibly jump around on every rebuild.
class NovaStarField extends StatelessWidget {
  const NovaStarField({super.key, required this.child, this.starCount = 10});
  final Widget child;
  final int starCount;

  static final List<_StarSpec> _specs = List<_StarSpec>.generate(16, (int i) {
    final math.Random random = math.Random(i * 97 + 13);
    return _StarSpec(
      left: random.nextDouble(),
      top: random.nextDouble(),
      size: 10 + random.nextDouble() * 18,
      opacity: 0.25 + random.nextDouble() * 0.5,
    );
  });

  @override
  Widget build(BuildContext context) => Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Positioned.fill(
            child: IgnorePointer(
                child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
              children: _specs
                  .take(starCount)
                  .map((_StarSpec spec) => Positioned(
                      left: spec.left * constraints.maxWidth,
                      top: spec.top * constraints.maxHeight,
                      child: Opacity(
                          opacity: spec.opacity,
                          child: NovaStar(size: spec.size, color: Colors.white))))
                  .toList());
        }))),
        child,
      ]);
}

class _StarSpec {
  const _StarSpec({required this.left, required this.top, required this.size, required this.opacity});
  final double left;
  final double top;
  final double size;
  final double opacity;
}
