# Implementation Status

Last updated: a session that took NovaLearn from "runs locally only" to **actually deployed and
publicly reachable**, plus a real visual-content pass (shapes/clocks/fractions/coordinate grids
rendered as drawn vector graphics, not just text) and a full visual-identity redesign ("Nova" —
cosmic violet/orange/yellow/pink, Baloo 2 + Nunito typography). Three real bugs were found and
fixed by actually using the deployed app, not just by code review — see "Bugs found and fixed"
below. Backend: 74 unit tests passing. Mobile: 25 tests passing, `flutter analyze` 0 issues. All
work committed and pushed to `github.com/usprakas/NovaLearn`.

**Live right now:**
- Backend API: `https://novalearn-ue6u.onrender.com` (Render, Docker-deployed, Postgres via Neon)
- Web frontend: `https://novalearn-1-yk58.onrender.com` (Render static site) — the one canonical
  frontend going forward
- A second frontend copy also exists at `https://usprakas.github.io/NovaLearn/` (GitHub Pages) —
  deliberately left in place but no longer actively redeployed after this session, per the user's
  explicit preference for Render as the canonical frontend

## What exists coming into this session

Phases 0–5 complete (see `DEVELOPMENT_PLAN.md`), plus a multi-grade curriculum expansion beyond
the master spec's original Grade-1-Math MVP scope: Pre-K through Grade 6, Math + English, 17
lessons/grade (Grade 1 kept its original 5), with real per-child grade filtering. AI tutor/
homework helper existed with offline deterministic templates plus optional Anthropic/Gemini
adapters, never exercised against a live key in this environment until this session. Everything
ran locally only — no deployment existed, and the app had never been visually exercised in a
browser by anyone before this session.

## This session's work

### Visual content (no image assets — everything is drawn)

Exercise choices across the curriculum were plain text even where a picture would obviously help
("which shape has 3 sides?" with no shape shown). Added a text-tag convention
(`SHAPE:`/`CLOCK:`/`FRACTION:`/`COLOR:`/`SIZE:` prefixes on existing `choice_text` values) parsed
client-side and rendered as real drawn vector widgets — circles, clock faces, divided fraction
diagrams, color swatches, relative-size cues — via `CustomPainter`, with no image generation or
asset pipeline (confirmed earlier in the project that Gemini's free tier hard-blocks image
generation, `limit: 0`). Migrations `V17`/`V18` tag the existing rows. Coordinate-plane points and
"the long hand points to N" clock prompts need **no** migration at all — parsed straight out of
already-existing prompt text via regex.

The post-answer feedback card was text-only even for tagged questions. `ExerciseEvaluation` now
also carries `correctChoiceText` — the correct choice's own tagged text, revealed only in the
post-grading response (the same place `explanation` already states the answer in prose, so this
isn't a new disclosure) — so the feedback card shows the same picture the choice list does.

New files: `mobile/lib/core/widgets/{shape_icon,choice_visual,coordinate_grid,vector_math}.dart`.

### Bugs found and fixed (by actually using the app, not just reading code)

1. **Stale session dead-ends with no way back to login.** Any 401 from an authenticated request
   (expired/revoked token, or a dev backend restarting with a new JWT secret) showed a generic
   "Something went wrong" screen with a "Try again" button that retried the same dead token
   forever. `NovaLearnApi` now takes an `onUnauthorized` callback — fired only for a 401 on a
   request that carried a Bearer token (never for a wrong password on login/register) — wired to
   sign out and fall back to the login screen automatically.
2. **No committed CORS configuration at all.** The only CORS handling that existed was a
   "local-only demo, not for commit" patch to `SecurityConfig.java`, hand-reapplied after every
   local restart and never shipped — so the deployed API would have rejected every cross-origin
   browser request outright. Replaced with a permanent `CorsConfigurationSource` bean driven by
   `ALLOWED_ORIGINS` (comma-separated, wildcard-capable), empty/blocked by default.
3. **Hardcoded port.** Render (and most PaaS hosts) inject a `PORT` env var and route to whatever
   the app actually binds; the app always listened on 8080. Now `server.port: ${PORT:8080}`.

### Going live

- **Neon**: real Postgres database, connected via the pooled endpoint with `prepareThreshold=0`
  (PgBouncer transaction-pooling mode doesn't support Postgres server-side prepared statements,
  which Hibernate uses by default — this is the standard documented fix).
- **Render (backend)**: Docker-based web service from the existing `backend/Dockerfile`, no
  changes needed there. Verified end-to-end against the real deployment: registration, login,
  child creation, lesson catalog, grading, the new `correctChoiceText` visual feature.
- **Render (frontend)** and **GitHub Pages (frontend)**: both are the production Flutter web
  build (`flutter build web`), pushed to dedicated branches (`render-web`, `gh-pages`) since
  neither host runs a Flutter toolchain itself — the build happens locally/in this environment,
  the built static output is what gets deployed. GitHub Pages required a `base-href=/NovaLearn/`
  build (subpath); Render's static site required `base-href=/` (served at its own root).

### Visual identity redesign ("Nova")

Replaced generic stock Material styling (single seed-color purple, default type) with a real,
distinctive design system: hand-picked, **WCAG-2.1-contrast-computed** (not eyeballed) palette —
cosmic violet `#6D28D9`, nova orange `#FF7A45`, star yellow `#FFC93C`, nova pink `#F472B6` — Baloo
2 (display/buttons) + Nunito (body) via `google_fonts`, bigger/rounder shapes (20–28px radii), and
a recurring drawn-sparkle motif (`NovaStar`) tying the "Nova" name to something visual. Applied
across the auth screen, child picker, lesson list, lesson screen (incl. a celebration
scale/bounce-in on a correct answer and a brief non-punishing shake on a wrong one, both
respecting `MediaQuery.disableAnimations`), dashboard badges, tutor/homework headers.

New: a public **landing page** (the app previously had none — straight from nothing to a login
form) and a **parent gate** (a quick arithmetic challenge) now standing in front of the Progress
dashboard and Account settings, which were previously one tap away for any child with nothing
stopping them — a real, previously-unflagged safety gap, not just polish.

Pre-K/Kindergarten/Grade 1 also get a distinct lesson layout: a handful of large, color-washed,
icon-led tiles instead of a scrolling list with full-sentence descriptions, since a pre-reader is
choosing by picture and color, not reading a subtitle. Grade 2+ keeps the list.

### Commands actually run, and their results

```sh
cd backend && ./mvnw test -Dtest='!PostgresIntegrationTest' -DfailIfNoTests=false
# -> 74 tests, 0 failures, 0 errors (run repeatedly through the session, after every backend change)

cd mobile && flutter analyze
# -> "No issues found!" (run after every change)

cd mobile && flutter test
# -> 25 tests passing (up from 10 at session start)

cd mobile && flutter build web --base-href=/ --dart-define=API_BASE_URL=https://novalearn-ue6u.onrender.com
cd mobile && flutter build web --base-href=/NovaLearn/ --dart-define=API_BASE_URL=https://novalearn-ue6u.onrender.com
# -> both built clean; output pushed to the render-web / gh-pages branches respectively
# After adding/removing a Flutter plugin, run `flutter clean` before `flutter build web`: an
# incremental build can reuse a stale web plugin registrant and ship without the new plugin's web
# implementation (this happened with image_picker — every photo pick threw on web until a clean
# rebuild).

curl against the live Render backend (register/login/create-child/lessons/grading) with the real
Origin headers of each live frontend
# -> every call verified working end-to-end, not assumed from a successful build
```

## Known issues / explicitly deferred

- ~~The AI tutor runs on offline templates on the live deployment~~ — `GEMINI_API_KEY` is now set
  on the Render backend; verified live (tutor and homework helper both give genuine, kid-friendly
  AI-generated explanations, not the deterministic offline template).
- Kid-sized text (18px+, bumped from default ~14–16px Material sizing) only landed on the lesson
  screen — tutor/homework screens still use default sizing.
- Tablet responsiveness is auto-wrap grids (`SliverGridDelegateWithMaxCrossAxisExtent`,
  `Wrap`), not deliberately designed breakpoint layouts for phone vs. tablet vs. desktop.
- The parent gate has to be solved on every single visit to a gated screen — no "remembered for
  this session" exemption.
- No onboarding flow (avatar picker, "meet the tutor") — a child's first run is still the plain
  name/birthday/grade-level form that existed before this session.
- No formal `ThemeExtension`/named reusable-component library (`NovaButton`, `TutorBubble`, etc.)
  — the design system is real and consistently applied, but lives as per-screen widget code
  rather than extracted, independently-testable named components.
- The mobile app has still never been run on a physical iOS/Android device or simulator/emulator
  in this environment — verified only in Chrome, both locally and against the live deployments.
- Email verification was explicitly scoped and then explicitly deferred at the user's request
  ("hold off for now") — registration still accepts any syntactically-valid, unverified email.
- ~~Rate limiting was silently off in production~~ — the live deployment has no Redis, and the
  limiter failed open, so auth/AI limits were never enforced and the Redis health indicator kept
  `/actuator/health` at `DOWN` (503). Fixed: in-process fallback counter when Redis is unreachable
  (exact for the single Render instance), Redis excluded from health, and a 429 that was
  surfacing as 403 (`sendError` → `/error` → Spring Security) now written directly. Verified live:
  health `UP`, 11th login attempt in a minute gets 429.
- Render's free tier spins the backend down after ~15 minutes idle; the next request after that
  takes 30–60s to wake it back up. Known tradeoff of the free tier, not a bug.
  Mitigated by `.github/workflows/keep-alive.yml` (health ping every 10 min) and a wake-up ping
  the app sends on open, plus a branded HTML splash while Flutter loads.
- ~~Returning to the site in the same browser failed with "Something went wrong"~~ — the saved
  session's access token (1h TTL) had expired, the API answered 403 instead of 401, and the app
  only signs out on 401, so it retried a dead token forever (private windows worked: no saved
  session). Fixed: bad/expired tokens get 401, and the app refreshes the saved session on startup
  (refresh token lasts 30 days), falling back to sign-in if that's rejected. Also stopped
  registering Flutter's deprecated (now no-op) service worker on every load.
  Testing this live exposed a second, older bug: `AuthService.authenticate` (login) ran in a
  read-only transaction, so the refresh token it issued was never written — every login's refresh
  token was rejected by `/auth/refresh` (registration's worked). Fixed; guarded by a test.
- **Homework help now shows a worked solution** (each step's explanation + its math, then the
  answer), replacing the earlier "guiding steps, never the answer" design at the product owner's
  request. Math correctness depends on the model (a lite Gemini model; the prompt asks it to
  double-check) and hasn't been reviewed by an educator. On desktop browsers "Take a photo" now
  opens an in-app webcam view (desktop browsers ignore the file input's camera hint).
- **Homework photo scanning is live** (Take a photo / Choose a photo on the Homework tab →
  `POST /homework/scans` → Gemini transcribes the question → the user checks it → the normal
  `/questions` flow). Photos are never stored. Open items: only verified against generated test
  images, not real handwritten worksheets; on Gemini's free tier photos reach Google under
  training-allowed terms (see RISKS_AND_TRADEOFFS.md) — switch to a paid tier before real families
  use it.
- Curriculum content still has not been reviewed by anyone with elementary-education
  subject-matter expertise (carried over from before this session — still applies).

## Exact next action

In priority order, as scoped with the user at the end of this session:
1. A friendlier tutor screen — suggested-question chips instead of requiring typing, for children
   who can't type yet (onboarding itself — avatar picker + "meet the tutor" — is now done).
2. Extend the kid-sized-text treatment to the tutor/homework screens.
3. Consider a "remembered for this app session" exemption on the parent gate so a parent isn't
   re-solving a math problem every time they check the dashboard.
