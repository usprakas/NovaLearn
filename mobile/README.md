# NovaLearn Mobile

Flutter client for Sprint 2: parent authentication, secure JWT session storage, child profiles, a Grade 1 Math lesson, progress sync, and a parent progress dashboard.

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
