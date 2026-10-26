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
- **Rate limiting** on auth endpoints (Redis-backed, fails open if Redis is down — see
  ARCHITECTURE.md).
- **Login error wording is identical** for an unknown email and a wrong password, so the API
  cannot be used to enumerate registered parent accounts.
- **Minimal child data collection**: a child profile is `displayName` (parent-chosen, can be a
  nickname), `birthDate`, `gradeLevel`, `avatar` (one of five fixed illustrated choices — never a
  photo), and optional `learningPreferences` tags. No child email, phone number, address, or photo
  is collected anywhere in this API.
- **AI output is treated as untrusted input**: the tutor/homework endpoints never return a raw,
  unvalidated model response directly from an exception path — a real-provider failure is caught
  and the response falls back to a pre-written, reviewed offline template rather than surfacing
  whatever the provider returned (or an error) to a child. The offline templates are static text
  written by this project and reviewed as part of the code, not generated at request time.
- **No system prompts, credentials, or cross-child data are ever included** in a tutor/homework
  prompt — `TutorService`/`HomeworkService` build the prompt from only the current question,
  optional subject hint, and (for the tutor) the strategy name; nothing else from the request or
  from the database is interpolated into it.

## Known gaps (stated plainly, not hidden)

- **No structured/schema-validated AI output contract yet.** The real Anthropic response is
  treated as a single text blob (split on newlines for the homework helper's step list); there is
  no JSON-schema-constrained response format, no explicit refusal-detection, and no automated check
  that a real model's output stays within an age-appropriate vocabulary or length bound beyond
  `max_tokens: 300`. This is a real gap against the master spec's "use a strict response schema...
  validate model output... limit response length... refuse or safely redirect inappropriate
  requests" — because `ANTHROPIC_API_KEY` is not configured in this environment, the real-provider
  path has never actually been exercised against a live model, so building elaborate output
  validation against a response shape nobody has observed risked validating the wrong thing. This
  is the top-priority item for whoever next has a real API key — see `docs/DEVELOPMENT_PLAN.md`
  Phase 4.
- **No request-size limit specific to the tutor/homework endpoints** beyond Spring's default
  request body size limits and Bean Validation's `@NotBlank`. A child/parent could submit a very
  long "question" today.
- **No per-child or per-session rate limit on tutor/homework calls**, only the IP-based limit on
  the auth endpoints. If a real API key is ever configured, this is a real cost-control gap before
  that happens, not after — do not turn on `ANTHROPIC_API_KEY` in a shared/production environment
  until this is fixed.
- **No access-token revocation/blocklist.** Logout only revokes the refresh token; a still-valid
  access token keeps working until its own short expiry. Accepted trade-off for an MVP given the
  short TTL; a stateful blocklist (likely Redis-backed, reusing the dependency already present)
  is the natural next step if this needs to be tighter.
- **No scheduled purge of expired/revoked refresh tokens.** The table grows unboundedly over time
  in a long-running deployment. Not fixed here.
- **No parent-verification gate for parent-only mobile settings screens** — there are no
  parent-only settings screens implemented yet at all (mobile Phase 3 is not revisited in this
  pass beyond what already existed), so there is nothing to gate today, but when they are built,
  remember the master spec's explicit warning: hiding a button behind a tab is not the same as
  authorizing the action server-side.
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
