import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:novalearn_mobile/core/network/novalearn_api.dart';
import 'package:novalearn_mobile/features/children/domain/child.dart';
import 'package:novalearn_mobile/features/homework/domain/homework_guidance.dart';
import 'package:novalearn_mobile/features/homework/domain/homework_repository.dart';
import 'package:novalearn_mobile/features/homework/presentation/homework_screen.dart';

class _FakeHomework implements HomeworkRepository {
  _FakeHomework({this.scanResult, this.scanError});
  final String? scanResult;
  final Object? scanError;
  Uint8List? scannedBytes;

  @override
  Future<String> scanQuestion(String token, String childId, Uint8List imageBytes) async {
    scannedBytes = imageBytes;
    if (scanError != null) throw scanError!;
    return scanResult!;
  }

  @override
  Future<HomeworkGuidance> explain(String token, String childId, String questionText) async =>
      const HomeworkGuidance(steps: <String>['Count on from 7.'], finalHint: 'You got this!');
}

final Child _child = Child(
    id: 'child-1', displayName: 'Ava', birthDate: DateTime(2018, 5, 1), gradeLevel: 'GRADE_1', avatar: 'FOX');

Widget _app(HomeworkRepository repo, {Future<Uint8List?> Function(ImageSource)? pick}) =>
    MaterialApp(
        home: Scaffold(
            body: HomeworkTab(
                token: 't', child: _child, homeworkRepository: repo, pickImage: pick)));

void main() {
  test('uploads the photo as base64 to the scans endpoint and returns the question', () async {
    final MockClient client = MockClient((http.Request request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/children/child-1/homework/scans');
      expect(request.headers['Authorization'], 'Bearer token');
      expect(jsonDecode(request.body), <String, Object?>{'imageBase64': base64Encode(<int>[1, 2, 3])});
      return http.Response(jsonEncode(<String, Object?>{'questionText': 'What is 7 + 5?'}), 200);
    });
    final NovaLearnApi api = NovaLearnApi(client: client, baseUrl: 'https://api.example.test');

    expect(await api.scanQuestion('token', 'child-1', Uint8List.fromList(<int>[1, 2, 3])),
        'What is 7 + 5?');
  });

  testWidgets('a scanned photo fills the question box for the user to check', (WidgetTester tester) async {
    final _FakeHomework repo = _FakeHomework(scanResult: 'What is 7 + 5?');
    ImageSource? requested;
    await tester.pumpWidget(_app(repo, pick: (ImageSource source) async {
      requested = source;
      return Uint8List.fromList(<int>[9, 9]);
    }));

    await tester.tap(find.text('Take a photo'));
    await tester.pumpAndSettle();

    expect(requested, ImageSource.camera);
    expect(repo.scannedBytes, <int>[9, 9]);
    expect(find.widgetWithText(TextField, 'What is 7 + 5?'), findsOneWidget);
    // Not submitted automatically — the guidance only appears after the user confirms.
    expect(find.text('Count on from 7.'), findsNothing);
  });

  testWidgets('shows the server message when the photo cannot be read', (WidgetTester tester) async {
    final _FakeHomework repo = _FakeHomework(
        scanError: const ApiException(statusCode: 422, message: 'Try a closer, brighter photo'));
    await tester.pumpWidget(
        _app(repo, pick: (ImageSource _) async => Uint8List.fromList(<int>[1])));

    await tester.tap(find.text('Choose a photo'));
    await tester.pumpAndSettle();

    expect(find.text('Try a closer, brighter photo'), findsOneWidget);
  });

  testWidgets('cancelling the picker does nothing', (WidgetTester tester) async {
    final _FakeHomework repo = _FakeHomework(scanResult: 'unused');
    await tester.pumpWidget(_app(repo, pick: (ImageSource _) async => null));

    await tester.tap(find.text('Choose a photo'));
    await tester.pumpAndSettle();

    expect(repo.scannedBytes, isNull);
  });
}
