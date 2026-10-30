import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/children/domain/child.dart';
import '../../features/children/domain/children_repository.dart';
import '../../features/homework/domain/homework_guidance.dart';
import '../../features/homework/domain/homework_repository.dart';
import '../../features/learning/domain/child_dashboard.dart';
import '../../features/learning/domain/dashboard_repository.dart';
import '../../features/learning/domain/exercise_evaluation.dart';
import '../../features/learning/domain/exercise_repository.dart';
import '../../features/learning/domain/lesson.dart';
import '../../features/learning/domain/lessons_repository.dart';
import '../../features/learning/domain/progress.dart';
import '../../features/learning/domain/progress_repository.dart';
import '../../features/rewards/domain/badges_repository.dart';
import '../../features/rewards/domain/child_badge.dart';
import '../../features/rewards/domain/rewards.dart';
import '../../features/rewards/domain/rewards_repository.dart';
import '../../features/tutor/domain/tutor_answer.dart';
import '../../features/tutor/domain/tutor_repository.dart';

class NovaLearnApi
    implements
        AuthRepository,
        ChildrenRepository,
        ProgressRepository,
        LessonsRepository,
        ExerciseRepository,
        RewardsRepository,
        BadgesRepository,
        DashboardRepository,
        TutorRepository,
        HomeworkRepository {
  NovaLearnApi({http.Client? client, String? baseUrl, this.onUnauthorized})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  /// Called once, synchronously, the first time an *authenticated* request (one that sent a
  /// Bearer token) comes back 401 — the access token is dead (expired, revoked, or signed by a
  /// backend that's since restarted with a new secret) and no amount of retrying will fix it.
  /// Not called for a 401 on `login`/`register` themselves, which just means "wrong password."
  final void Function()? onUnauthorized;

  /// Fire-and-forget ping so a sleeping free-tier backend starts waking up the moment the app
  /// opens, rather than only once the parent submits the login form. Never throws.
  Future<void> wakeUp() async {
    try {
      await _client.get(_uri('/actuator/health')).timeout(const Duration(seconds: 90));
    } catch (_) {
      // Best effort only — the real request will surface any genuine connection problem.
    }
  }

  @override
  Future<AuthSession> login(String email, String password) =>
      _authenticate('/api/v1/auth/login', email, password);

  @override
  Future<AuthSession> register(String email, String password) =>
      _authenticate('/api/v1/auth/register', email, password);

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    final http.Response response = await _client.post(
      _uri('/api/v1/auth/refresh'),
      headers: _headers(),
      body: jsonEncode(<String, String>{'refreshToken': refreshToken}),
    );
    return _authSessionFrom(_decodeObject(response));
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _client.post(
      _uri('/api/v1/auth/logout'),
      headers: _headers(),
      body: jsonEncode(<String, String>{'refreshToken': refreshToken}),
    );
  }

  @override
  Future<void> deleteAccount(String accessToken, String password) async {
    final http.Response response = await _client.delete(
      _uri('/api/v1/auth/me'),
      headers: _headers(accessToken),
      body: jsonEncode(<String, String>{'password': password}),
    );
    _ensureSuccess(response);
  }

  @override
  Future<List<Child>> children(String token) async {
    final http.Response response = await _client.get(
      _uri('/api/v1/children'),
      headers: _headers(token),
    );
    final List<Object?> data = _decodeList(response);
    return data.cast<Map<String, Object?>>().map(Child.fromJson).toList();
  }

  @override
  Future<Child> createChild(String token, ChildDraft draft) async {
    final http.Response response = await _client.post(
      _uri('/api/v1/children'),
      headers: _headers(token),
      body: jsonEncode(draft.toJson()),
    );
    return Child.fromJson(_decodeObject(response));
  }

  @override
  Future<List<LessonProgress>> progress(String token, String childId) async {
    final http.Response response = await _client.get(
      _uri('/api/v1/children/$childId/progress'),
      headers: _headers(token),
    );
    return _decodeList(response)
        .cast<Map<String, Object?>>()
        .map(LessonProgress.fromJson)
        .toList();
  }

  @override
  Future<List<LessonSummary>> lessons(String token, String childId) async {
    final http.Response response = await _client.get(
      _uri('/api/v1/children/$childId/lessons'),
      headers: _headers(token),
    );
    return _decodeList(response)
        .cast<Map<String, Object?>>()
        .map(LessonSummary.fromJson)
        .toList();
  }

  @override
  Future<Lesson> lesson(String token, String code) async {
    final http.Response response = await _client.get(
      _uri('/api/v1/lessons/$code'),
      headers: _headers(token),
    );
    return Lesson.fromJson(_decodeObject(response));
  }

  @override
  Future<ExerciseEvaluation> submitAnswer(
    String token,
    String childId,
    String exerciseId,
    int submittedAnswerIndex,
  ) async {
    final http.Response response = await _client.post(
      _uri('/api/v1/children/$childId/exercises/$exerciseId/attempts'),
      headers: _headers(token),
      body: jsonEncode(<String, Object?>{'submittedAnswerIndex': submittedAnswerIndex}),
    );
    return ExerciseEvaluation.fromJson(_decodeObject(response));
  }

  @override
  Future<ChildRewards> rewards(String token, String childId) async {
    final http.Response response = await _client.get(
      _uri('/api/v1/children/$childId/rewards'),
      headers: _headers(token),
    );
    return ChildRewards.fromJson(_decodeObject(response));
  }

  @override
  Future<List<ChildBadge>> badges(String token, String childId) async {
    final http.Response response = await _client.get(
      _uri('/api/v1/children/$childId/badges'),
      headers: _headers(token),
    );
    return _decodeList(response).cast<Map<String, Object?>>().map(ChildBadge.fromJson).toList();
  }

  @override
  Future<ChildDashboard> dashboard(String token, String childId) async {
    final http.Response response = await _client.get(
      _uri('/api/v1/children/$childId/dashboard'),
      headers: _headers(token),
    );
    return ChildDashboard.fromJson(_decodeObject(response));
  }

  @override
  Future<TutorAnswer> ask(
    String token,
    String childId,
    String question,
    String? subject,
    int attempt,
  ) async {
    final http.Response response = await _client.post(
      _uri('/api/v1/children/$childId/tutor/questions'),
      headers: _headers(token),
      body: jsonEncode(<String, Object?>{
        'question': question,
        'subject': subject,
        'attempt': attempt,
      }),
    );
    return TutorAnswer.fromJson(_decodeObject(response));
  }

  @override
  Future<HomeworkGuidance> explain(
    String token,
    String childId,
    String questionText,
  ) async {
    final http.Response response = await _client.post(
      _uri('/api/v1/children/$childId/homework/questions'),
      headers: _headers(token),
      body: jsonEncode(<String, Object?>{'questionText': questionText}),
    );
    return HomeworkGuidance.fromJson(_decodeObject(response));
  }

  Future<AuthSession> _authenticate(
    String path,
    String email,
    String password,
  ) async {
    final http.Response response = await _client.post(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );
    return _authSessionFrom(_decodeObject(response));
  }

  AuthSession _authSessionFrom(Map<String, Object?> data) => AuthSession(
        accessToken: data['accessToken']! as String,
        refreshToken: data['refreshToken']! as String,
        email: data['email']! as String,
      );

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');
  Map<String, String> _headers([String? token]) => <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
  Map<String, Object?> _decodeObject(http.Response response) {
    _ensureSuccess(response);
    return (jsonDecode(response.body) as Map).cast<String, Object?>();
  }

  List<Object?> _decodeList(http.Response response) {
    _ensureSuccess(response);
    return (jsonDecode(response.body) as List).cast<Object?>();
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    if (response.statusCode == 401 && response.request?.headers.containsKey('Authorization') == true) {
      onUnauthorized?.call();
    }
    String message = 'Something went wrong. Please try again.';
    try {
      message =
          (jsonDecode(response.body) as Map)['detail'] as String? ?? message;
    } on FormatException {
      // The API may be unavailable or return a proxy response.
    }
    throw ApiException(statusCode: response.statusCode, message: message);
  }
}

class ApiException implements Exception {
  const ApiException({required this.statusCode, required this.message});
  final int statusCode;
  final String message;
}
