# NovaLearn

*"Every Child Deserves a Personal AI Teacher."*

An AI-powered learning platform MVP for children ages 5–8, starting with Grade 1 mathematics. Java
21/Spring Boot backend, Flutter mobile client, PostgreSQL + Flyway, optional Redis, and a
provider-independent AI tutor/homework-helper adapter that works fully offline with no API key.

See `docs/` for the full picture: `PRD.md` (product vision), `ARCHITECTURE.md` (components and key
decisions), `DATABASE_DESIGN.md` (schema), `API_SPECIFICATION.md` (endpoint inventory),
`SECURITY_AND_CHILD_SAFETY.md`, `DEVELOPMENT_PLAN.md` (phased plan), and `IMPLEMENTATION_STATUS.md`
(what is actually built right now, updated as work progresses).

## Repository layout

```
backend/        Java 21 / Spring Boot 3.5 API (Maven)
mobile/         Flutter client
docs/           Documentation (see above)
infrastructure/ Local-dev helper scripts
docker-compose.yml   PostgreSQL + Redis + API for local development
```

## Run locally

1. Copy `.env.example` to `.env`. Generate `JWT_SECRET` with `openssl rand -base64 64`.
   `ANTHROPIC_API_KEY` is optional — leave it blank to use the deterministic offline AI fallback.
2. `docker compose up --build` — starts PostgreSQL, Redis, and the API together.
3. Open `http://localhost:8080/swagger-ui.html`.

Or run the backend directly against `docker compose up postgres redis`:

```sh
cd backend
./mvnw spring-boot:run
```

### Try it with curl

```sh
# Register a parent (returns an access token + refresh token)
curl -s -X POST http://localhost:8080/api/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"parent@example.com","password":"a very secure password"}'

# Use the accessToken from the response above
TOKEN=<accessToken>

# Create a child profile
curl -s -X POST http://localhost:8080/api/v1/children \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"displayName":"Maya","birthDate":"2020-01-01"}'

# List lessons, ask the tutor, etc. — see docs/API_SPECIFICATION.md for the full set.
```

## Quality gates

```sh
cd backend && ./mvnw verify   # unit tests + Postgres Testcontainers integration test (Docker required)
cd mobile && flutter analyze && flutter test
```

GitHub Actions runs both on every push/PR. See `docs/IMPLEMENTATION_STATUS.md` for what has
actually been run and observed to pass in this development environment (no Docker here, so the
Testcontainers test is unverified locally — CI runs it with Docker available).

## Mobile client

The Flutter client is in [mobile/README.md](mobile/README.md).

## Environment variables

See `.env.example` for the full list with placeholders. Never commit a real value.
