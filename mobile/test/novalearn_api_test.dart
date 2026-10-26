import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:novalearn_mobile/core/network/novalearn_api.dart';

void main() {
  test('registers a parent against the versioned API endpoint', () async {
    final MockClient client = MockClient((http.Request request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/auth/register');
      expect(jsonDecode(request.body), <String, String>{
        'email': 'parent@example.com',
        'password': 'A secure password',
      });
      return http.Response(
        jsonEncode(<String, String>{
          'parentId': 'd0f00a00-0000-4000-8000-000000000001',
          'email': 'parent@example.com',
          'accessToken': 'signed-token',
          'refreshToken': 'refresh-token-value',
          'tokenType': 'Bearer',
        }),
        201,
      );
    });
    final NovaLearnApi api =
        NovaLearnApi(client: client, baseUrl: 'https://api.example.test');

    final result =
        await api.register('parent@example.com', 'A secure password');

    expect(result.email, 'parent@example.com');
    expect(result.accessToken, 'signed-token');
    expect(result.refreshToken, 'refresh-token-value');
  });

  test('refreshes a session against the versioned API endpoint', () async {
    final MockClient client = MockClient((http.Request request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/auth/refresh');
      expect(jsonDecode(request.body), <String, String>{'refreshToken': 'old-refresh-token'});
      return http.Response(
        jsonEncode(<String, String>{
          'parentId': 'd0f00a00-0000-4000-8000-000000000001',
          'email': 'parent@example.com',
          'accessToken': 'new-access-token',
          'refreshToken': 'new-refresh-token',
          'tokenType': 'Bearer',
        }),
        200,
      );
    });
    final NovaLearnApi api =
        NovaLearnApi(client: client, baseUrl: 'https://api.example.test');

    final result = await api.refresh('old-refresh-token');

    expect(result.accessToken, 'new-access-token');
    expect(result.refreshToken, 'new-refresh-token');
  });

  test('submits an exercise answer against the versioned API endpoint', () async {
    final MockClient client = MockClient((http.Request request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/children/child-1/exercises/exercise-1/attempts');
      expect(jsonDecode(request.body), <String, Object?>{'submittedAnswerIndex': 1});
      return http.Response(
        jsonEncode(<String, Object?>{'correct': true, 'explanation': '2 + 2 = 4.', 'hint': null}),
        201,
      );
    });
    final NovaLearnApi api =
        NovaLearnApi(client: client, baseUrl: 'https://api.example.test');

    final evaluation = await api.submitAnswer('token', 'child-1', 'exercise-1', 1);

    expect(evaluation.correct, isTrue);
  });

  test('converts API errors into a display-safe exception', () async {
    final NovaLearnApi api = NovaLearnApi(
      baseUrl: 'https://api.example.test',
      client: MockClient((http.Request _) async => http.Response(
            jsonEncode(<String, String>{'detail': 'Invalid email or password'}),
            401,
          )),
    );

    await expectLater(
      api.login('parent@example.com', 'wrong password'),
      throwsA(isA<ApiException>().having(
          (ApiException error) => error.statusCode, 'status code', 401)),
    );
  });
}
