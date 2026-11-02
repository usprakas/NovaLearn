import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:novalearn_mobile/core/network/novalearn_api.dart';

http.Response _lessons() => http.Response(jsonEncode(<Object>[]), 200);

void main() {
  test('an expired access token is refreshed and the request replayed, without signing out', () async {
    final List<String?> authHeaders = <String?>[];
    final MockClient client = MockClient((http.Request request) async {
      authHeaders.add(request.headers['Authorization']);
      return request.headers['Authorization'] == 'Bearer old'
          ? http.Response('{"status":401}', 401)
          : _lessons();
    });
    final List<String> refreshedFrom = <String>[];
    bool signedOut = false;
    final NovaLearnApi api = NovaLearnApi(
        client: client,
        baseUrl: 'https://api.example.test',
        tokenRefresher: (String expired) async {
          refreshedFrom.add(expired);
          return 'new';
        },
        onUnauthorized: () => signedOut = true);

    final lessons = await api.lessons('old', 'child-1');

    expect(lessons, isEmpty);
    expect(authHeaders, <String?>['Bearer old', 'Bearer new']);
    expect(refreshedFrom, <String>['old']);
    expect(signedOut, isFalse);
  });

  test('signs out when the session itself can no longer be refreshed', () async {
    final MockClient client =
        MockClient((http.Request request) async => http.Response('{"status":401}', 401, request: request));
    bool signedOut = false;
    final NovaLearnApi api = NovaLearnApi(
        client: client,
        baseUrl: 'https://api.example.test',
        tokenRefresher: (String expired) async => null,
        onUnauthorized: () => signedOut = true);

    await expectLater(api.lessons('old', 'child-1'), throwsA(isA<ApiException>()));
    expect(signedOut, isTrue);
  });

  test('a replayed POST keeps its body', () async {
    final List<String> bodies = <String>[];
    final MockClient client = MockClient((http.Request request) async {
      bodies.add(request.body);
      if (request.headers['Authorization'] == 'Bearer old') return http.Response('{"status":401}', 401);
      return http.Response(jsonEncode(<String, Object?>{'correct': true, 'explanation': 'ok'}), 201);
    });
    final NovaLearnApi api = NovaLearnApi(
        client: client, baseUrl: 'https://api.example.test', tokenRefresher: (String expired) async => 'new');

    final evaluation = await api.submitAnswer('old', 'child-1', 'exercise-1', 2);

    expect(evaluation.correct, isTrue);
    expect(bodies, hasLength(2));
    expect(bodies.last, bodies.first);
    expect(jsonDecode(bodies.last), <String, Object?>{'submittedAnswerIndex': 2});
  });

  test('a wrong password on login is not treated as an expired session', () async {
    final MockClient client = MockClient((http.Request request) async =>
        http.Response(jsonEncode(<String, Object?>{'detail': 'Invalid email or password'}), 401));
    bool refreshed = false;
    bool signedOut = false;
    final NovaLearnApi api = NovaLearnApi(
        client: client,
        baseUrl: 'https://api.example.test',
        tokenRefresher: (String expired) async {
          refreshed = true;
          return 'new';
        },
        onUnauthorized: () => signedOut = true);

    await expectLater(api.login('a@b.c', 'wrong'), throwsA(isA<ApiException>()));
    expect(refreshed, isFalse);
    expect(signedOut, isFalse);
  });
}
