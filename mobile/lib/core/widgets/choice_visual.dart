import 'package:flutter/material.dart';
import 'shape_icon.dart';
import 'vector_math.dart' as vector_math;

/// Generalizes the `SHAPE:` convention from `shape_icon.dart` to four more content types a
/// backend exercise choice can be tagged with, each rendered as a small drawn visual instead of
/// plain text:
/// ```text
///   SHAPE:<key>:<Label>                         -- a geometric shape (see shape_icon.dart)
///   CLOCK:<hour>:<minute>                        -- an analog clock face; the label is computed
///   FRACTION:<numerator>:<denominator>:<Label>   -- a divided circle, numerator shaded
///   COLOR:<key>:<Label>                          -- a filled color swatch
///   SIZE:<big|small>:<Label>                     -- a relative-size cue circle
/// ```
enum ChoiceVisualType { shape, clock, fraction, color, size }

class ParsedChoiceVisual {
  const ParsedChoiceVisual({required this.type, required this.args, required this.label});
  final ChoiceVisualType type;
  final List<String> args;
  final String label;
}

/// Returns the parsed visual if [text] matches one of the tag formats above, otherwise null
/// (meaning: render it as plain text, same as any untagged choice).
ParsedChoiceVisual? parseChoiceVisual(String text) {
  final int firstColon = text.indexOf(':');
  if (firstColon == -1) return null;
  final String prefix = text.substring(0, firstColon);
  final List<String> rest = text.substring(firstColon + 1).split(':');
  switch (prefix) {
    case 'SHAPE':
      if (rest.length != 2) return null;
      return ParsedChoiceVisual(type: ChoiceVisualType.shape, args: <String>[rest[0]], label: rest[1]);
    case 'CLOCK':
      if (rest.length != 2) return null;
      final int? hour = int.tryParse(rest[0]);
      final int? minute = int.tryParse(rest[1]);
      if (hour == null || minute == null) return null;
      return ParsedChoiceVisual(
          type: ChoiceVisualType.clock,
          args: rest,
          label: '$hour:${minute.toString().padLeft(2, '0')}');
    case 'FRACTION':
      if (rest.length != 3) return null;
      return ParsedChoiceVisual(
          type: ChoiceVisualType.fraction, args: <String>[rest[0], rest[1]], label: rest[2]);
    case 'COLOR':
      if (rest.length != 2) return null;
      return ParsedChoiceVisual(type: ChoiceVisualType.color, args: <String>[rest[0]], label: rest[1]);
    case 'SIZE':
      if (rest.length != 2) return null;
      return ParsedChoiceVisual(type: ChoiceVisualType.size, args: <String>[rest[0]], label: rest[1]);
    default:
      return null;
  }
}

/// Builds the right small drawn widget for a parsed choice visual.
class ChoiceVisualIcon extends StatelessWidget {
  const ChoiceVisualIcon({super.key, required this.visual, this.size = 28, this.color});
  final ParsedChoiceVisual visual;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color fill = color ?? Theme.of(context).colorScheme.primary;
    switch (visual.type) {
      case ChoiceVisualType.shape:
        return ShapeIcon(shapeKey: visual.args[0], size: size, color: fill);
      case ChoiceVisualType.clock:
        return ClockFaceIcon(
            hour: int.parse(visual.args[0]), minute: int.parse(visual.args[1]), size: size * 1.3, color: fill);
      case ChoiceVisualType.fraction:
        return FractionDiagram(
            numerator: int.parse(visual.args[0]),
            denominator: int.parse(visual.args[1]),
            size: size * 1.3,
            color: fill);
      case ChoiceVisualType.color:
        return ColorSwatchIcon(colorKey: visual.args[0], size: size);
      case ChoiceVisualType.size:
        return SizeCueIcon(big: visual.args[0] == 'big', size: size * 1.3, color: fill);
    }
  }
}

/// An analog clock face at the given time. Also used, with [emphasizeMinuteHand], for the
/// Grade 3 "the long hand points to N" prompts — there the hour is irrelevant to the question, so
/// the hour hand is drawn faint and only the long hand is emphasized.
class ClockFaceIcon extends StatelessWidget {
  const ClockFaceIcon(
      {super.key, required this.hour, required this.minute, this.size = 36, this.color, this.emphasizeMinuteHand = false});
  final int hour;
  final int minute;
  final double size;
  final Color? color;
  final bool emphasizeMinuteHand;

  @override
  Widget build(BuildContext context) => CustomPaint(
      size: Size(size, size),
      painter: _ClockFacePainter(
          hour: hour,
          minute: minute,
          color: color ?? Theme.of(context).colorScheme.primary,
          emphasizeMinuteHand: emphasizeMinuteHand));
}

class _ClockFacePainter extends CustomPainter {
  const _ClockFacePainter(
      {required this.hour, required this.minute, required this.color, required this.emphasizeMinuteHand});
  final int hour;
  final int minute;
  final Color color;
  final bool emphasizeMinuteHand;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    canvas.drawCircle(center, radius - 1, Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6);

    for (int i = 0; i < 12; i++) {
      final double angle = i * vector_math.pi / 6;
      final Offset inner = _point(center, radius * 0.82, angle);
      final Offset outer = _point(center, radius * 0.96, angle);
      canvas.drawLine(inner, outer, Paint()
        ..color = color.withValues(alpha: 0.6)
        ..strokeWidth = 1);
    }

    final double hourAngle = ((hour % 12) + minute / 60) * (vector_math.pi / 6) - vector_math.pi / 2;
    final double minuteAngle = minute * (vector_math.pi / 30) - vector_math.pi / 2;

    canvas.drawLine(center, _point(center, radius * 0.5, hourAngle), Paint()
      ..color = emphasizeMinuteHand ? color.withValues(alpha: 0.35) : color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round);
    canvas.drawLine(center, _point(center, radius * 0.75, minuteAngle), Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round);
    canvas.drawCircle(center, 1.8, Paint()..color = color);
  }

  Offset _point(Offset center, double radius, double angle) =>
      Offset(center.dx + radius * vector_math.taylorCos(angle), center.dy + radius * vector_math.taylorSin(angle));

  @override
  bool shouldRepaint(covariant _ClockFacePainter oldDelegate) =>
      oldDelegate.hour != hour || oldDelegate.minute != minute || oldDelegate.color != color;
}

/// A circle divided into [denominator] equal wedges with [numerator] of them shaded.
class FractionDiagram extends StatelessWidget {
  const FractionDiagram(
      {super.key, required this.numerator, required this.denominator, this.size = 36, this.color});
  final int numerator;
  final int denominator;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => CustomPaint(
      size: Size(size, size),
      painter: _FractionPainter(
          numerator: numerator, denominator: denominator, color: color ?? Theme.of(context).colorScheme.primary));
}

class _FractionPainter extends CustomPainter {
  const _FractionPainter({required this.numerator, required this.denominator, required this.color});
  final int numerator;
  final int denominator;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (denominator <= 0) return;
    final Rect rect = Offset.zero & size;
    final double sweep = 2 * vector_math.pi / denominator;
    final Paint outline = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final Paint fill = Paint()..color = color;

    for (int i = 0; i < denominator; i++) {
      final double start = i * sweep - vector_math.pi / 2;
      final Path wedge = Path()
        ..moveTo(rect.center.dx, rect.center.dy)
        ..arcTo(rect, start, sweep, false)
        ..close();
      if (i < numerator) canvas.drawPath(wedge, fill);
      canvas.drawPath(wedge, outline);
    }
  }

  @override
  bool shouldRepaint(covariant _FractionPainter oldDelegate) =>
      oldDelegate.numerator != numerator || oldDelegate.denominator != denominator || oldDelegate.color != color;
}

/// A filled swatch of a named color — used for "what color is..." choices.
class ColorSwatchIcon extends StatelessWidget {
  const ColorSwatchIcon({super.key, required this.colorKey, this.size = 28});
  final String colorKey;
  final double size;

  static const Map<String, Color> _colors = <String, Color>{
    'yellow': Color(0xFFFBC02D),
    'purple': Color(0xFF8E24AA),
    'black': Color(0xFF1A1A1A),
    'green': Color(0xFF43A047),
    'red': Color(0xFFE53935),
    'pink': Color(0xFFEC407A),
    'blue': Color(0xFF1E88E5),
    'brown': Color(0xFF6D4C41),
  };

  @override
  Widget build(BuildContext context) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: _colors[colorKey] ?? Theme.of(context).colorScheme.outline,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1)));
}

/// A circle sized relatively large or small within the same fixed icon slot — a quick visual cue
/// for "which one is bigger?" exercises where the choices are named objects, not drawable in
/// recognizable detail (an elephant, a bus) without real illustration assets.
class SizeCueIcon extends StatelessWidget {
  const SizeCueIcon({super.key, required this.big, this.size = 36, this.color});
  final bool big;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final double diameter = big ? size : size * 0.45;
    return SizedBox(
        width: size,
        height: size,
        child: Center(
            child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                    color: color ?? Theme.of(context).colorScheme.primary, shape: BoxShape.circle))));
  }
}
