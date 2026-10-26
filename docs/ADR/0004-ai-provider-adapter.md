# 0004 — Provider-independent AI adapter with offline-first fallback

## Status
Accepted

## Context
The MVP must work with zero paid API key, and the master spec requires the AI integration to be
provider-independent, server-side only, and never assume a provider guarantees child safety.

## Decision
One port, `application.ai.AiTextClient` (`String complete(String prompt)`), consumed by both
`TutorService` and `HomeworkService` via constructor-injected `Optional<AiTextClient>`.
`config.AiConfig` registers a real implementation (`infrastructure.ai.AnthropicTextClient`) only
when `ANTHROPIC_API_KEY` is set; returning `null` from a `@Bean` method is a supported Spring
pattern that resolves to `Optional.empty()` for consumers, so "no key configured" and "offline
mode" are the same code path, not a special case. Both services catch a failure from the real
client and fall back to their deterministic offline template for that one request.

## Alternatives considered
- **A generic `LlmProvider` interface with named provider enum** (`ANTHROPIC`, `OPENAI`, ...),
  selectable via config. Rejected for now: the master spec asks for "an optional provider
  implementation for *a* configurable LLM API," singular, and adding a provider-selection layer
  with only one real implementation would be speculative generality. If a second real provider is
  ever needed, introduce the selector then, informed by what actually differs between two live
  implementations rather than guessing now.
- **Always call the real provider, mock it in tests.** Rejected: the spec explicitly requires the
  app to work with zero paid API key out of the box, including for a developer who never gets an
  Anthropic key.

## Consequences
- Never exposes an API key to Flutter/browser code — the key lives only in backend environment
  configuration (`ANTHROPIC_API_KEY`), consistent with the spec's explicit requirement.
- The real-provider code path (`AnthropicTextClient`) has never been exercised against the live
  API in this development environment (no key provisioned here) — stated plainly in
  `docs/SECURITY_AND_CHILD_SAFETY.md` and `docs/IMPLEMENTATION_STATUS.md` rather than claimed as
  tested.
- Structured-output validation, a strict response schema, and refusal handling against a *real*
  model response are not yet built, because building them against a response shape nobody here has
  actually observed would be guessing. This is the top-priority item once a real key is available
  — see `docs/DEVELOPMENT_PLAN.md` Phase 4.
