# NovaLearn Mobile

Flutter client: parent authentication, secure JWT session storage, child profiles, a dynamic
lesson list across Math and English, progress sync, an AI tutor screen ("try another way" rotates
through step-by-step/story/real-life-example explanations), a homework helper screen (type a
question — there's no photo/OCR scanning yet, see the backend's RISKS_AND_TRADEOFFS.md), and a
parent dashboard showing weekly completions, average score, coins, streak, and a strongest/weakest
subject signal.

## Run

Install Flutter, then run:

```bash
flutter create --platforms=android,ios .
flutter pub get
flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

The first command creates only the platform-specific runner files; the `lib/` application source remains unchanged. `10.0.2.2` reaches the host machine from the Android emulator. For an iOS simulator, use `http://localhost:8080`; use your LAN address for a physical device. Start the API first with `docker compose up --build` from the repository root.

The access token is stored through `flutter_secure_storage`, which uses platform secure storage. Do not use a production API over cleartext HTTP.
