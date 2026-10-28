# App Store / Play Store Submission Prep

Tracks what's actually been done toward a real App Store/Play Store submission, and — more
importantly — what's still blocking one. Started when the user asked to bring NovaLearn to the
App Store; this is groundwork done *without* an Apple Developer or Google Play Console account
(neither exists yet), so it's deliberately scoped to what doesn't depend on one.

## Done

- **Bundle identifiers replaced**: iOS/macOS `PRODUCT_BUNDLE_IDENTIFIER` and Android
  `namespace`/`applicationId` were still Flutter's `com.example.*` placeholder — both stores
  reject that. Changed to `com.novalearn.app` on both platforms (Android's `MainActivity.kt`
  moved to match the new package path). **This is a placeholder choice, not a confirmed one** —
  change it before the first real App Store Connect / Play Console upload if the actual
  publishing organization ends up using a different domain; changing it *after* the first upload
  creates a new app listing, not a rename.
- **App display names fixed**: iOS `CFBundleDisplayName`/`CFBundleName` and Android
  `android:label` were still `novalearn_mobile`/`Novalearn Mobile` — now `NovaLearn` everywhere.
- **Real app icon**: generated a brand icon (`mobile/assets/icon/icon.png`, via
  `mobile/assets/icon/generate_icon.py`, a one-off Pillow script — not part of the app build)
  reusing the sparkle motif already shown on the sign-in screen (`Icons.auto_awesome`) on the
  app's brand purple (`AppTheme.seed`), so it matches the in-app identity instead of introducing
  an unrelated mark. Wired up via the `flutter_launcher_icons` package (`pubspec.yaml`), which
  generated every required size for iOS, Android, and web from the one master PNG.
- **Privacy policy drafted and published**: `docs/privacy-policy.html` (published version:
  check `/artifacts` or ask for the current link) — written against the application's actual
  data model and AI-provider config, not a generic template. Explicitly marked "Draft — pending
  legal review" throughout; see "Not done" below for exactly what that review still needs to
  cover.
- **Xcode diagnosed**: the earlier "macOS build failed" turned out to be Xcode's command-line
  tools being the active developer directory instead of the full Xcode.app (which *is*
  installed). Fix is one command, but needs `sudo` — the user needs to run
  `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` themselves.

## Not done — real blockers, not just unchecked boxes

- **No Apple Developer Program account** ($99/year) or **Google Play Console account** ($25
  one-time) — neither exists yet. Nothing can actually be submitted without at least one of
  these; code signing, App Store Connect listings, and TestFlight/Play internal testing all
  require one.
- **No publicly-deployed backend.** The API only runs locally (this laptop, or `docker compose`)
  or against a temporary local H2 demo database set up for live-testing sessions. A real
  submitted app needs a real, always-on, publicly reachable API — this is the Phase 6 AWS
  deployment work (`docs/PHASE_6_PLAN.md`), which is a written plan only, not built.
- **No legal review of the privacy policy or the consent model.** `docs/privacy-policy.html` is
  accurate to the code today, but a children's-data app needs qualified counsel to confirm it
  actually satisfies COPPA and each store's children's-category policy (Apple's Kids Category in
  particular has specific, strict rules: no behavioral ads, no third-party analytics without a
  consent flow, a "parental gate" pattern before anything leaves the app). This was already
  flagged as unreviewed in `docs/SECURITY_AND_CHILD_SAFETY.md` before any app-store work started.
- **No parental-gate UX.** Nothing in the mobile app currently gates "leaving the app" actions
  (e.g., an external link, were one ever added) behind an age-check interaction — standard
  practice for kids' apps and something Apple's Kids Category review specifically looks for.
- **No real support/contact information.** App Store Connect and Play Console both require a
  working support URL/email; the privacy policy currently has a placeholder for this.
- **No App Store/Play Store listing assets**: screenshots on real device frames, a short/long
  description, keywords, an age rating questionnaire answered honestly for both stores, a content
  rating for a children's educational app specifically.
- **No code signing / provisioning profiles** — can't be generated without an Apple Developer
  account.
- **Known product gaps that should be resolved before a real submission**, not just before this
  prep work: no mobile UI for account deletion yet (the backend endpoint exists — see
  `docs/IMPLEMENTATION_STATUS.md`), and the AI tutor/homework helper's real-provider path falls
  back to a free-tier Gemini key with Google's own "content used to improve our products" clause
  — not appropriate for a production app handling real children's questions without a
  billing-enabled account carrying a stronger data-use guarantee (see `docs/RISKS_AND_TRADEOFFS.md`).

## Suggested next step, once the user is ready to unblock further

1. Decide on and register the real publishing domain/organization name (affects the bundle ID
   choice above, and the privacy policy's contact details).
2. Enroll in an Apple Developer Program and/or Google Play Console account.
3. Get the backend genuinely deployed (Phase 6 AWS work, or any other real hosting) so the app
   has something real to talk to.
4. Get the privacy policy and consent model in front of qualified counsel.
5. Only then: code signing, store listings, screenshots, TestFlight/internal testing, submission.
