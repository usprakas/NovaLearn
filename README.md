# NovaLearn API

The NovaLearn backend: parent authentication, child profiles, a multi-lesson Grade 1 Math/English
catalog, lesson progress, gamification (coins and streaks), an AI tutor, a text-based homework
helper, and a parent dashboard. It follows a ports-and-adapters layout: `application` holds use
cases and repository ports, `domain` holds core concepts, `infrastructure` implements
persistence/security/AI, and `interfaces/rest` is the delivery adapter. See
[ARCHITECTURE.md](ARCHITECTURE.md) for boundaries, the full API inventory, and key decisions, and
[RISKS_AND_TRADEOFFS.md](RISKS_AND_TRADEOFFS.md) for what's real versus a deliberate stand-in
(there's no OCR, no voice, and no AWS deployment here — see why).

## Run locally

1. Copy `.env.example` to `.env`, then replace the `JWT_SECRET` placeholder with
   `openssl rand -base64 64`. `ANTHROPIC_API_KEY` is optional — leave it blank to use the
   deterministic offline tutor/homework templates.
2. Run `docker compose up --build`.
3. Open `http://localhost:8080/swagger-ui.html`.

Use `POST /api/v1/auth/register`, then supply `Authorization: Bearer <accessToken>` for every
other endpoint. Migration history lives in `src/main/resources/db/migration`; Hibernate validates
rather than mutates the schema.

## Quality gates

`mvn verify` runs the unit suite and a PostgreSQL Testcontainers integration smoke test. Docker
must be running for the Testcontainers test. GitHub Actions runs the same verification, plus the
mobile `flutter analyze`/`flutter test`, on every push and pull request. See
[TESTING.md](TESTING.md) for exact counts and what's not covered here.

## Mobile client

The Flutter client is in [mobile](mobile/README.md): parent sign-in, secure token storage, a
dynamic lesson list (Math + English), an AI tutor screen, a homework helper screen, and a parent
dashboard with coins/streaks and a strongest/weakest subject signal.

## Environment

| Variable | Required | Description |
| --- | --- | --- |
| `JWT_SECRET` | Yes | Base64-encoded, cryptographically random secret (generate with `openssl rand -base64 64`). |
| `DATABASE_URL` | No | JDBC URL; defaults to local PostgreSQL. |
| `DATABASE_USERNAME` | No | Database user; defaults to `novalearn`. |
| `DATABASE_PASSWORD` | No | Database password; defaults to `novalearn`. |
| `JWT_ACCESS_TOKEN_TTL_SECONDS` | No | JWT lifetime; defaults to 3600 seconds. |
| `ANTHROPIC_API_KEY` | No | Unset/blank -> offline tutor/homework templates (default). Set -> real Anthropic Messages API calls. Untested against the live API in this authoring environment. |
