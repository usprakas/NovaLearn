# 0001 — Modular monolith, not microservices

## Status
Accepted

## Context
The master spec explicitly asks for a modular monolith for the MVP and to avoid premature
microservices. The existing codebase (parent auth, child profiles, lessons, progress, rewards,
tutor, homework, dashboard) already lives in one Spring Boot application with package-by-feature
boundaries (`domain`/`application`/`infrastructure`/`interfaces` per feature).

## Decision
Keep one deployable Spring Boot application. Enforce module boundaries through package structure
and the ports-and-adapters convention (an application service for feature X never directly
imports another feature's JPA entities or controllers — it goes through that feature's repository
port if it needs data, as `DashboardService` does with `LessonProgressRepository` and
`RewardsService`), not through separate deployables.

## Consequences
- One JVM, one database connection pool, one deployment artifact — simpler operations for an MVP
  with a small team.
- Package boundaries are a convention enforced by code review, not a build-time constraint (no
  separate Maven modules). If boundaries are violated in the future, consider ArchUnit tests
  before reaching for microservices.
- Splitting a feature into its own service later remains possible because of the ports-and-adapters
  boundary, but is explicitly not a near-term goal.
