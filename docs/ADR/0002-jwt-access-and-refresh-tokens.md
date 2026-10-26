# 0002 — Short-lived JWT access tokens + rotating, hashed refresh tokens

## Status
Accepted

## Context
The pre-existing implementation only issued a single JWT with no refresh mechanism, so a parent's
session died exactly at the JWT's TTL with no way to extend it short of logging in again. The
master spec requires "short-lived access tokens and a secure refresh strategy" plus "logout and
token invalidation where supported."

## Decision
- Access tokens stay short-lived JWTs (default 1 hour), unchanged in shape.
- Add a refresh token: a 256-bit random value, returned to the client once, persisted only as a
  SHA-256 hash (never the raw value — so a database read alone can never produce a usable token).
- Rotate on every use: `POST /auth/refresh` revokes the presented token and issues a new
  access/refresh pair. A revoked, expired, or unknown token is rejected identically (generic
  `AuthenticationException`), so a caller can't distinguish those cases.
- `POST /auth/logout` revokes the refresh token. The paired access token is not separately
  blocklisted — it just expires on its own short TTL.

## Alternatives considered
- **Blocklist access tokens on logout too** (e.g. a Redis set of revoked JWT IDs, checked on every
  request). Rejected for now: adds a lookup to every authenticated request for a benefit that's
  small given the 1-hour TTL already in place. Revisit if the TTL grows or if immediate
  revocation becomes a real requirement (e.g. for a lost/stolen device).
- **Opaque session tokens instead of JWTs** (fully server-side sessions). Rejected: the existing
  stateless-JWT architecture already works and the spec explicitly asks for JWT.

## Consequences
- A new `refresh_tokens` table and `RefreshTokenRepository` port/adapter.
- `AuthService.AuthResult` now carries a `refreshToken` field; `AuthController`'s
  `/register`/`/login` responses grew that field. This is additive — an older client that ignores
  the new field keeps working.
- Unbounded table growth over time (revoked/expired rows are kept as an audit trail, not purged) —
  documented as a known gap in `docs/SECURITY_AND_CHILD_SAFETY.md`, not fixed in this pass.
