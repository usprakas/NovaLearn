import 'package:flutter_test/flutter_test.dart';
import 'package:novalearn_mobile/core/widgets/choice_visual.dart';
import 'package:novalearn_mobile/core/widgets/coordinate_grid.dart';

void main() {
  group('parseChoiceVisual', () {
    test('parses a SHAPE tag', () {
      final ParsedChoiceVisual? visual = parseChoiceVisual('SHAPE:circle:Circle');
      expect(visual?.type, ChoiceVisualType.shape);
      expect(visual?.args, <String>['circle']);
      expect(visual?.label, 'Circle');
    });

    test('parses a CLOCK tag and computes a zero-padded label', () {
      final ParsedChoiceVisual? visual = parseChoiceVisual('CLOCK:7:0');
      expect(visual?.type, ChoiceVisualType.clock);
      expect(visual?.args, <String>['7', '0']);
      expect(visual?.label, '7:00');
    });

    test('parses a FRACTION tag, keeping the original fraction text as the label', () {
      final ParsedChoiceVisual? visual = parseChoiceVisual('FRACTION:2:4:2/4');
      expect(visual?.type, ChoiceVisualType.fraction);
      expect(visual?.args, <String>['2', '4']);
      expect(visual?.label, '2/4');
    });

    test('parses a COLOR tag', () {
      final ParsedChoiceVisual? visual = parseChoiceVisual('COLOR:yellow:Yellow');
      expect(visual?.type, ChoiceVisualType.color);
      expect(visual?.label, 'Yellow');
    });

    test('parses a SIZE tag', () {
      final ParsedChoiceVisual? visual = parseChoiceVisual('SIZE:big:Whale');
      expect(visual?.type, ChoiceVisualType.size);
      expect(visual?.args, <String>['big']);
      expect(visual?.label, 'Whale');
    });

    test('returns null for plain, untagged choice text', () {
      expect(parseChoiceVisual('Equal'), isNull);
      expect(parseChoiceVisual('Same size'), isNull);
    });

    test('returns null for a non-numeric CLOCK tag rather than throwing', () {
      expect(parseChoiceVisual('CLOCK:noon:thirty'), isNull);
    });

    test('returns null for a malformed tag with the wrong number of segments', () {
      expect(parseChoiceVisual('FRACTION:1:2'), isNull);
      expect(parseChoiceVisual('SHAPE:circle:Circle:extra'), isNull);
    });
  });

  group('extractPlanePoints', () {
    test('extracts a single ordered pair from a sentence', () {
      expect(extractPlanePoints('What is the point (0,0) called?'), <Offset>[const Offset(0, 0)]);
    });

    test('extracts multiple ordered pairs, including negatives', () {
      expect(
        extractPlanePoints('Distance between (2,3) and (-2,-7)?'),
        <Offset>[const Offset(2, 3), const Offset(-2, -7)],
      );
    });

    test('returns an empty list when the prompt names no point', () {
      expect(extractPlanePoints('Which number tells you how far right or left to go?'), isEmpty);
    });
  });
}
