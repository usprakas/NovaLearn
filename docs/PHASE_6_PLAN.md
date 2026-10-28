# Phase 6 — Future Extensions: Implementation Plan (not built)

Per the master spec's own instruction — "Do not begin Phase 6 until the core MVP works unless I
explicitly ask," and for Phase 6 specifically, "propose a separate implementation plan" rather than
build it — this document is a plan only. Nothing described here has been coded. The MVP (Phases
0–5) is complete and green (64 backend tests, 9 mobile tests, all passing); Phase 6 is proposed
next, pending explicit go-ahead, because every item below needs a real external credential, cloud
account, or device/app-store access this environment does not have, so anything built against it
now would be unverified by construction.

## 1. Homework OCR (photographed homework → text)

- **Shape**: add `POST /api/v1/children/{childId}/homework/uploads` accepting an image
  (multipart), returning the same `{steps, finalHint}` shape the text endpoint already returns —
  OCR becomes a new input path into the *existing* `HomeworkService`, not a parallel feature.
- **New port**: `OcrClient` (interface, mirrors the existing `AiTextClient` pattern) with one
  method, `extractText(byte[] imageBytes): String`. A real adapter would call a vision-capable
  model (e.g. Anthropic's vision input on the same Messages API already integrated, avoiding a
  second vendor) or a dedicated OCR service (AWS Textract, Google Vision).
- **Why gated on a real key first**: unlike the text tutor's offline fallback (a static template
  is a believable stand-in for "explain this concept"), there is no deterministic offline
  stand-in for "read text out of an arbitrary photo" — an offline OCR fallback would just be
  fake, so this cannot ship with the same honest offline-first pattern used elsewhere in this repo.
  Needs: a vision-capable API key, and a handful of real sample homework photos to validate
  extraction quality before trusting it in front of a child.
- **Child-safety addition**: the extracted text must pass through the same `ContentSafetyFilter`
  already built for the text tutor/homework paths before being used in any prompt — OCR output is
  untrusted input exactly like a typed question.
- **Storage**: the image itself should not be persisted by default (data minimization — a photo
  of a child's homework page is more sensitive than typed text); if a "re-check this later"
  feature is wanted, store it in S3 with a short TTL lifecycle policy, not indefinitely.

## 2. Speech-to-text / text-to-speech

- **On-device, not cloud**: Flutter's `speech_to_text` and `flutter_tts` packages run entirely on
  the device, needing no API key — this is the one Phase 6 item that isn't blocked by a missing
  credential. It is blocked by having no emulator/simulator/physical device available in this
  environment to verify microphone permission flows, platform-channel behavior, or actual
  recognition accuracy on.
- **Shape**: add a mic button next to the tutor's question `TextField` (`TutorTab`) that fills the
  field via `speech_to_text` rather than introducing a new endpoint — speech is an input modality
  change, not a new backend capability. A speaker icon on the answer `Card` plays it via
  `flutter_tts`. No backend change needed at all.
- **Risk to flag before building**: platform permission prompts (`RECORD_AUDIO` on Android,
  `NSMicrophoneUsageDescription` on iOS) need real device testing to get right — getting this wrong
  silently (a permission denial that isn't handled) is worse for a 5–8-year-old user than not
  having the feature.

## 3. Additional subjects and grades — ✅ done, no longer just a plan

This item was built, on the user's explicit request — see "Multi-grade curriculum expansion" in
`docs/DEVELOPMENT_PLAN.md` for exactly what shipped (Pre-K through Grade 6, Math and English,
17 lessons/grade except Grade 1's original 5) and how each grade was verified. The two real
blockers this plan originally called out were both addressed as part of that work:

- **The missing grade filter was fixed.** `lessons` gained a `grade_level` column; the lesson list
  endpoint is now child-scoped and filtered to the child's own grade (it previously showed every
  lesson to every child regardless of age, exactly the gap this plan flagged).
- **Content review still has not happened.** The point below remains true and unaddressed — what
  changed is that there's now a full PRE_K-GRADE_6 curriculum for that review to actually apply
  to, not just five Grade 1 lessons.

**Content review**: unlike code, curriculum content needs review by someone with actual
elementary-education subject-matter expertise before being trusted in front of real children —
this was true for the original 5 Grade 1 lessons and remains true for the much larger PRE_K-GRADE_6
curriculum now in place. Engineering judgment (standard-progression topics, plausible
difficulty-appropriate questions) was applied, but that is not the same thing as curriculum
expertise, and no such review has happened.

## 4. Teacher dashboard

- **Explicitly out of MVP scope per the PRD itself** ("(Future)"), and a materially different
  product surface: a new actor type (`Role.TEACHER`), a new relationship model (teacher ↔ many
  children not necessarily their own, likely via a classroom/roster join table), and new
  authorization rules distinct from today's strict one-parent-owns-their-children model in
  `SecurityConfig`/`ChildProfileRepository.belongsToParent`.
- **Shape sketch**: `classrooms` (id, teacherId, name), `classroom_members` (classroomId,
  childId) — a child could then belong to a parent (ownership, unchanged) and optionally a
  classroom (a teacher's read-only view). Teacher endpoints would read the *same* dashboard
  aggregation logic (`DashboardService`) per child in their roster, not a parallel implementation.
- **Needs product input before engineering**: how a teacher is verified as a real teacher
  (self-serve signup is a plausible abuse vector — anyone could claim to be a teacher and gain
  read access to children's data), and whether a parent must approve a teacher's access to their
  specific child. This is a policy decision, not something to default silently.

## 5. Subscription billing

- **Needs a real Stripe (or equivalent) account** — cannot be built against a sandbox key safely
  wired for real charges without one, and should not be faked with a mock payment flow that looks
  real to a parent.
- **Shape sketch**: `parent_accounts` gains a `subscription_status` (`TRIAL`, `ACTIVE`, `PAST_DUE`,
  `CANCELED`) and `subscription_expires_at`; a webhook endpoint
  (`POST /api/v1/billing/webhooks/stripe`) updates it from Stripe's events rather than the app
  polling Stripe. Gate AI-tutor/homework access (the actual variable-cost features) on
  `subscription_status == ACTIVE` once this exists — free core lesson content, paid AI tutoring,
  is a defensible split but is a product decision, not an engineering one, and isn't assumed here.
- **PCI scope**: use Stripe Checkout/Elements so card data never touches this backend directly —
  do not build a custom card-number form.

## 6. AWS deployment (infrastructure-as-code)

- **`infrastructure/README.md` already documents the target shape** (ECS Fargate for the API,
  RDS Postgres, ElastiCache Redis, S3 for future OCR uploads, CloudFront/ALB in front) as a
  description of intent — this plan adds the actual IaC tool choice and sequencing:
  1. Start with Terraform (not CDK) given no existing AWS-CDK convention in this repo and
     Terraform's more widely portable state format if the project ever needs to move cloud
     providers or hand off to a dedicated infra team.
  2. VPC + RDS + ElastiCache + ECR first (the stateful/slow-to-provision pieces), verified
     reachable, before the ECS service that depends on them.
  3. Secrets (`JWT_SECRET`, `DATABASE_PASSWORD`, `ANTHROPIC_API_KEY`) go in AWS Secrets Manager,
     injected into the ECS task definition as secrets (never plain environment variables in the
     task definition JSON, which would be visible to anyone with `ecs:DescribeTaskDefinition`).
  4. CI/CD: extend the existing GitHub Actions workflow (which already runs `mvn verify` with a
     real Testcontainers Postgres) with a deploy job gated on a manual approval, pushing to ECR
     and updating the ECS service — not auto-deploying every merge to `main` without a gate,
     given this handles children's data.
  5. **Blocked on**: an actual AWS account and credentials. Nothing above can be verified by
     running it, only reviewed as a plan, until that exists.

## Suggested build order, if/when this is explicitly requested

1. Speech-to-text/TTS first — the only item with zero external-credential dependency, so it's the
   fastest to get genuinely verified rather than merely plausible.
2. AWS deployment — unlocks a real environment to test *everything else* against (including a
   real Postgres/Redis, closing the H2-replay and mocked-Redis gaps noted in TESTING.md today).
3. Homework OCR — once a vision-capable key exists, reusing the AWS environment from step 2 to
   actually exercise it rather than testing it only locally.
4. Additional subjects/grades — content work, can happen in parallel with any of the above once
   someone with curriculum expertise is involved.
5. Teacher dashboard and subscription billing last — both need real product/policy decisions
   (consent model, pricing model) this plan deliberately does not make unilaterally.
