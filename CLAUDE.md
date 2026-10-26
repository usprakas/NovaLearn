# CLAUDE.md

Project-specific notes for working in this repository.

## Layout

```
novalearn/ (repo root)
  backend/        Java 21 / Spring Boot 3.5 API (Maven)
  mobile/         Flutter client
  docs/           PRD, architecture, database, API, security, and status docs
  infrastructure/ Local-dev scripts; AWS IaC is deferred to Phase 6 (see docs/DEVELOPMENT_PLAN.md)
  docker-compose.yml   PostgreSQL + Redis + API, for local development
```

## Conventions

- **Backend** follows ports-and-adapters: `domain` (pure concepts, no framework deps), `application`
  (use cases + repository/AI ports, no Spring Data or HTTP deps), `infrastructure` (JPA, JWT, Redis,
  Anthropic HTTP client — implements the application ports), `interfaces/rest` (controllers, DTOs,
  error translation — never exposes JPA entities), `config` (Spring wiring).
- Every child-scoped operation is parent-scoped: application services check
  `ChildProfileRepository.belongsToParent(childId, parentId)` before any read or write, and throw
  `application.common.ChildNotFoundException` (mapped to 404) if it fails. Follow this pattern for
  any new child-scoped feature.
- Flyway migrations are append-only — never edit a migration that may have already run; add a new
  `V{n}__description.sql` instead.
- The AI tutor/homework helper share one port, `application.ai.AiTextClient`. No implementation
  means no bean is registered (`AiConfig` returns `null`, which Spring exposes as
  `Optional.empty()` to callers) — callers fall back to deterministic offline templates. Follow
  this pattern for any new AI-backed feature; never let a provider outage return a 500 if an
  offline fallback is possible.
- Never commit secrets. `.env.example` documents every required/optional environment variable with
  placeholders only.

## Commands

```sh
# Backend (from backend/)
./mvnw clean verify              # unit tests + Postgres Testcontainers integration test (needs Docker)
./mvnw test -Dtest='!PostgresIntegrationTest'   # unit tests only, no Docker required
./mvnw spring-boot:run            # run the API (needs DATABASE_URL/JWT_SECRET etc., see .env.example)

# Mobile (from mobile/)
flutter pub get
flutter analyze
flutter test

# Local stack (from repo root)
docker compose up --build         # Postgres + Redis + API
```

## Status

See `docs/IMPLEMENTATION_STATUS.md` for exactly what is implemented, what commands were actually
run, and what the next phase is. Do not assume a feature exists because it is named in
`docs/PRD.md` or `docs/DEVELOPMENT_PLAN.md` — those describe intent; `IMPLEMENTATION_STATUS.md`
describes reality.
