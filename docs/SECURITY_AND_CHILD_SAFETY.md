# Security and Child Safety

This document states what is actually implemented, what is a known gap, and the legal/compliance
boundary of this document (technical mechanics only — not a compliance certification).

## Implemented

- **Password storage**: BCrypt (`spring-boot-starter-security`'s default adaptive encoder).
  Plaintext passwords are never persisted or logged.
- **Stateless JWT access tokens**, short-lived (default 1 hour), HMAC-signed with a required
  base64-encoded secret (`JWT_SECRET`, never defaulted — the app refuses to start without it).
- **Rotating, single-use refresh tokens**, stored only as a SHA-256 hash; the raw value is
  returned to the client exactly once per issuance. See `docs/ARCHITECTURE.md` → Authentication.
- **Default-deny authorization**: every route except `POST /api/v1/auth/**`, the health check, and
  the OpenAPI/Swagger routes requires a valid bearer token (`SecurityConfig`).
- **Strict parent-to-child data isolation**: every child-scoped application service checks
  `ChildProfileRepository.belongsToParent(childId, parentId)` before any read or write, and the
  JWT's subject claim is the only source of `parentId` (`@AuthenticationPrincipal`, populated by
  `JwtAuthenticationFilter` from the verified token — never from a request body or path parameter).
  Cross-parent access attempts are covered by tests across every service
  (`rejectsAChildOutsideTheParentAccount`-style tests in `RewardsServiceTest`, `TutorServiceTest`,
  `HomeworkServiceTest`, `DashboardServiceTest`, and the original `ProgressServiceTest`).
- **Rate limiting** on auth endpoints (Redis-backed, in-process fallback if Redis is down — see
  ARCHITECTURE.md).
- **Login error wording is identical** for an unknown email and a wrong password, so the API
  cannot be used to enumerate registered parent accounts.
- **Minimal child data collection**: a child profile is `displayName` (parent-chosen, can be a
  nickname), `birthDate`, `gradeLevel`, `avatar` (one of five fixed illustrated choices — never a
  photo), and optional `learningPreferences` tags. No child email, phone number, address, or photo
  is collected anywhere in this API.
- **Exercise answers are graded server-side and the answer key never reaches the client.**
  `GET /lessons/{code}` returns each exercise's prompt and choices but not its correct-answer
  index; that index lives only behind `ExerciseAnswerKey`, read exclusively by
  `ExerciseEvaluationService`. A prior version let the client compute its own score from an
  embedded answer index and submit a final `{score, completed}` directly — that endpoint
  (`PUT .../progress/{lessonCode}`) is gone, not just supplemented, closing what was previously
  documented here as a real, named gap ("Prevent clients from awarding themselves arbitrary
  points" from the master spec).
- **Reward issuance is idempotent against retries.** `RewardsService.award` checks
  `(referenceType, referenceId)` before inserting, and a database unique constraint catches the
  same case under a concurrent race — a resent request can never double-award coins.
- **AI output is treated as untrusted input**: the tutor/homework endpoints never return a raw,
  unvalidated model response directly from an exception path — a real-provider failure is caught
  and the response falls back to a pre-written, reviewed offline template rather than surfacing
  whatever the provider returned (or an error) to a child. The offline templates are static text
  written by this project and reviewed as part of the code, not generated at request time.
- **No system prompts, credentials, or cross-child data are ever included** in a tutor/homework
  prompt — `TutorService`/`HomeworkService` build the prompt from only the current question,
  optional subject hint, and (for the tutor) the strategy name; nothing else from the request or
  from the database is interpolated into it.
- **Content safety filter, checked on both directions** (`ContentSafetyFilter`): a child's
  question is checked *before* any AI call is made — an unsafe question is refused with a safe
  redirect message without the AI client ever being invoked, so no unsafe round-trip happens and
  no cost is incurred. A real AI model's response is checked the same way and capped at 800
  characters before being returned; a response that fails either check is discarded in favor of
  the deterministic offline template, exactly like a provider failure. This is a keyword denylist
  (self-harm, violence, drugs/alcohol, sexual content, weapons, and common PII categories like
  address/phone/SSN/credit-card/password) — a real but narrow baseline, not comprehensive
  moderation; see RISKS_AND_TRADEOFFS.md "Known limitations."
- **Per-child rate limiting on the AI-backed endpoints** (`AiRateLimitFilter`, Redis-backed,
  in-process fallback if Redis is down): default 20 requests/minute/child (`AI_RATE_LIMIT_PER_MINUTE`), separate from and in
  addition to the existing IP-based auth rate limiter — closes the "do not enable a real API key
  in a shared environment until this exists" gap this document previously flagged. This bounds
  request *rate*, not total spend; a real dollar budget cap is still a listed next step.
- **Account deletion requires re-confirming the password**, not just a valid access token
  (`DELETE /api/v1/auth/me`, `AuthService.deleteAccount`) — a stolen/still-valid access token
  alone cannot delete the account. Deletion cascades to every child profile and all their data at
  the database level (`ON DELETE CASCADE` from `child_profiles`/`refresh_tokens` to
  `parent_accounts`), so there is no code path that deletes the account but leaves orphaned child
  data behind.
- **Every request carries a correlation ID through its logs** (`CorrelationIdFilter`, via MDC),
  echoed back in the `X-Correlation-Id` response header — lets a specific parent-reported incident
  be traced through logs without logging any request/response body content.

## Known gaps (stated plainly, not hidden)

- **No JSON-schema-constrained AI output contract yet.** The real Anthropic response is still
  treated as a text blob (split on newlines for the homework helper's step list) with a keyword
  safety check and an 800-character cap layered on top (see "Implemented" above) — there is no
  schema-constrained response format, and no automated check that a real model's output stays
  within an age-appropriate *vocabulary*, only within a safety-keyword and length bound. Because
  `ANTHROPIC_API_KEY` is still not configured in this environment, the real-provider path has
  never actually been exercised against a live model, so building a stricter schema against a
  response shape nobody has observed still risks validating the wrong thing. Top-priority item for
  whoever next has a real API key — see `docs/DEVELOPMENT_PLAN.md` Phase 4.
- **No request-size limit specific to the tutor/homework endpoints** beyond Spring's default
  request body size limits and Bean Validation's `@NotBlank @Size(max = 500)` on the question
  field (added this pass).
- **No dollar-value budget cap on AI calls**, only a requests-per-minute-per-child rate limit (see
  "Implemented" above). A sustained stream of requests under the per-minute limit could still add
  up to real cost over a day; a real deployment should add a daily/monthly spend cap before
  turning on a real API key at any scale.
- **No access-token revocation/blocklist.** Logout only revokes the refresh token; a still-valid
  access token keeps working until its own short expiry. Accepted trade-off for an MVP given the
  short TTL; a stateful blocklist (likely Redis-backed, reusing the dependency already present)
  is the natural next step if this needs to be tighter.
- **No scheduled purge of expired/revoked refresh tokens.** The table grows unboundedly over time
  in a long-running deployment. Not fixed here.
- **No parent-verification gate for parent-only mobile settings screens** — there are no
  parent-only settings screens implemented yet at all, so there is nothing to gate today, but when
  they are built, remember the master spec's explicit warning: hiding a button behind a tab is not
  the same as authorizing the action server-side. This includes account deletion specifically:
  `DELETE /api/v1/auth/me` is implemented and password-gated server-side (see "Implemented"
  above), but there is no mobile UI that calls it yet — this pass was backend-only for that
  endpoint.
- **HTTPS is a deployment-time requirement, not something this codebase enforces.** Nothing here
  rejects a plaintext HTTP connection at the application layer; that is the job of the reverse
  proxy/load balancer in front of it (e.g. an ALB or CloudFront in the eventual AWS deployment —
  see `infrastructure/README.md`), and must be configured before any real deployment.

## Not reviewed, and explicitly out of scope for this document

**No claim of legal compliance is made anywhere in this repository.** Before any real launch,
have qualified counsel review: parental-consent mechanics (the spec implies parent-managed
accounts satisfy this, but that needs legal confirmation, not an engineering assumption),
applicable children's-privacy law (e.g. COPPA in the US and equivalents elsewhere), app-store
child-safety policies (Apple/Google both have specific requirements for kids' apps), and any
education-sector data-handling requirements relevant to the markets this launches in.

## Rewards and engagement — explicit anti-pressure note

Per the master spec's instruction that rewards must never pressure children to overuse the app:
the current reward model (coins on first lesson completion, a daily streak counter) has no loss
mechanic (a missed day resets the *current* streak but the *longest* streak and all coins earned
are permanent — nothing is ever taken away), no push notifications, no countdown timers, and no
mechanism that penalizes a child for not opening the app. If a notification/reminder feature is
ever added, revisit this note and design it to respect a parent-configurable session limit rather
than maximizing time-in-app.
