# Implementation Status

Last updated: this session (Phase 4 "AI tutor hardening" + Phase 5 "Parent dashboard and
hardening" + Phase 6 "plan only", following the Phase 2/3 session before it).

## What exists coming into this session

Phases 0–3 complete. 58 backend unit tests, 9 mobile tests, both green coming in. The AI tutor and
homework helper existed but had no content safety filter, only 3 of 5 strategies, no per-child
rate limiting, and the parent dashboard had no recommended-next-activity field or account-deletion
path.

## What this session did

### Phase 4 — AI tutor hardening (backend)

- **`ContentSafetyFilter`**: a keyword denylist (self-harm, violence, drugs/alcohol, sexual
  content, weapons, and common PII categories) plus an 800-character response cap. Checked on the
  child's question *before* any AI call — an unsafe question is refused (`refused: true`) and the
  AI client is never invoked, so no cost and no unsafe round-trip. Checked again on a real AI
  response — unsafe or oversized output is discarded in favor of the deterministic offline
  template, the same path used for an outright provider failure.
- **Full 5-strategy rotation**: `TutorStrategy` extended from 3 to 5 values
  (`STEP_BY_STEP, STORY, REAL_LIFE_EXAMPLE, VISUAL_ANALOGY, GUIDED_QUESTION`), selected by
  `attempt % 5`; added offline templates for the two new strategies.
  `TutorAnswer`/`HomeworkGuidance` responses gained `suggestedNextActivity` (a pointer at a
  catalog lesson in the question's subject) and `refused`.
- **Per-child AI rate limiting**: `AiRateLimitFilter`, extracted shared fixed-window logic into
  `RedisFixedWindowRateLimiter` (reused by the pre-existing `AuthRateLimitFilter`), keyed by
  `childId` parsed from the request path via regex, default 20 requests/minute
  (`AI_RATE_LIMIT_PER_MINUTE`), fails open if Redis is unreachable — same posture as the existing
  auth limiter.
- Request body validation tightened: `question`/`questionText` now `@NotBlank @Size(max = 500)`.
- Added 4 tests to `TutorServiceTest` (9 total) and 2 to `HomeworkServiceTest` (7 total) covering
  the new strategy count, the refusal path, and treating a real AI response as untrusted output.

### Phase 5 — Parent dashboard and hardening (backend + mobile)

- **Recommended-next-activity**: `ChildDashboard` gained `recommendedNextLessonCode`/
  `recommendedNextLessonTitle` — `DashboardService.recommendNextLesson` returns the first catalog
  lesson, in display order, the child hasn't completed (`null`/`null` if every lesson is done).
  `DashboardController.DashboardResponse` updated to match. Mobile `ChildDashboard` model and
  `ParentDashboard` widget updated to parse and display it (a "Recommended next" card).
- **Account deletion**: `ParentAccountRepository.deleteById` + JPA adapter;
  `AuthService.deleteAccount(parentId, password)` re-confirms the password before deleting;
  `DELETE /api/v1/auth/me` (authenticated, 204 on success, 401 on a wrong password). No new
  cleanup code was needed for child data — `child_profiles`/`refresh_tokens` already cascade-delete
  from `parent_accounts` at the schema level (migrations V1/V3). No mobile UI was added to call
  this endpoint this pass — backend only.
- **Correlation-ID request logging**: `CorrelationIdFilter` (new `infrastructure/logging`
  package) reuses a client-supplied `X-Correlation-Id` header or generates one, puts it in MDC for
  the duration of the request, echoes it in the response header, and clears it afterward even if
  the chain throws. Wired first in the Spring Security filter chain (before the rate limiters, so
  even a rate-limited request's log line carries one). `logging.pattern.level` in `application.yml`
  updated so the ID actually appears in console output (Spring Boot's documented MDC-in-pattern
  approach), since no logback config existed before to carry it.
- **Accessibility**: no new UI code — audited what already exists (every icon-only control already
  has a text label or tooltip) and documented it honestly in RISKS_AND_TRADEOFFS.md rather than
  inventing unverifiable changes with no device to test them on.
- Added 1 test to `DashboardServiceTest` (4 total: recommending the first incomplete lesson), 2 to
  `AuthServiceTest` (12 total: delete-on-correct-password, refuse-on-wrong-password), and a new
  3-test `CorrelationIdFilterTest`.

### Phase 6 — Future extensions (plan only, per the master spec's own instruction)

- Wrote `docs/PHASE_6_PLAN.md`: a per-item implementation plan (shape, new ports/tables, specific
  blockers, suggested build order) for homework OCR, on-device speech-to-text/TTS, additional
  subjects/grades, a teacher dashboard, subscription billing, and AWS infrastructure-as-code.
  Nothing in it was built — every item needs a real external credential, cloud account, or device
  this environment doesn't have, and the spec explicitly asks for a plan here, not an
  implementation.

### Documentation

Updated `DEVELOPMENT_PLAN.md` (Phase 4/5 now ✅, Phase 6 plan-written), `API_SPECIFICATION.md`
(new/changed endpoint shapes), `SECURITY_AND_CHILD_SAFETY.md` (content safety filter, per-child
rate limit, account deletion, correlation ID — moved from "known gap" to "implemented" where
applicable), `RISKS_AND_TRADEOFFS.md` (updated "what's real" table, failure-scenario table,
accessibility note, revised "what I'd do with more time"), and `TESTING.md` (new test counts and
classes) to reflect all of the above.

## Commands actually executed, and their results

```sh
cd backend && ./mvnw -q compile
# -> clean compile after each structural change (ChildDashboard field count, new filter, new
#    endpoint) — run repeatedly through this session, output empty on success as expected

cd backend && ./mvnw -q test -Dtest='CorrelationIdFilterTest,AuthServiceTest' -DfailIfNoTests=false
# -> first run: 1 error (InvalidUseOfMatchersException — a real mistake in a new test, mixing a
#    raw matcher with eq() incorrectly); fixed, reran, all green

cd backend && ./mvnw -q clean test -Dtest='!PostgresIntegrationTest' -DfailIfNoTests=false
# -> 64 unit tests, 0 failures, 0 errors (final run, full suite, after all Phase 4/5 changes)

find target/surefire-reports -name "*.txt" | xargs grep -h "Tests run" | awk ...
# -> Total tests: 64 Failures: 0 Errors: 0 Skipped: 0

cd mobile && flutter analyze
# -> "No issues found!" (full project, after the dashboard model/widget changes)

cd mobile && flutter test
# -> "All tests passed!" (9 tests, unchanged count — no new mobile tests were added this pass)
```

No command was run and then assumed to pass without observing its output. The one real mistake
(an invalid Mockito matcher combination in the first draft of `CorrelationIdFilterTest`) was
caught by actually running the test, not assumed away.

## Known issues / explicitly deferred

- The real Anthropic-backed path has still never been exercised against the live API in this
  environment (no key provisioned) — the content safety filter's "treat AI output as untrusted"
  behavior is unit-tested against a mocked client returning deliberately-unsafe text, not against
  real model output.
- The content safety filter is a keyword denylist, not comprehensive moderation — see
  RISKS_AND_TRADEOFFS.md "Known limitations."
- Per-child AI rate limiting bounds request rate, not dollar spend; no budget cap exists.
- Account deletion has no mobile UI yet.
- No Testcontainers-backed integration test covers the new endpoints against a real database (same
  pre-existing Docker constraint as before).
- The mobile dashboard/tutor UI changes (recommended-next card, refusal/suggestion states) have
  been verified only via `flutter analyze`/`flutter test`, never run on a simulator/emulator or
  device.
- Phase 6 is a plan only (`docs/PHASE_6_PLAN.md`) — nothing in it is built.

## Exact next action

Core MVP (Phases 0–5) is complete and green within this environment's constraints. The next
available real action is either: (a) get this reviewed/committed and pushed, or (b) if a real
Anthropic API key, Docker, a device/emulator, or AWS credentials become available, use them to
close the specific gaps listed above (real-model content-safety verification, Testcontainers
Postgres run, a manual mobile run-through) before starting any Phase 6 work, which should not
begin until explicitly requested per the master spec's own instruction.
