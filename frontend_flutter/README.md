# Flutter Dashboard

This Flutter web app provides a richer dashboard for monitoring inference
results from the demo backend.

## Prerequisites

- Flutter SDK installed (`flutter --version`)

## Run locally

```bash
cd frontend_flutter
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8000 \
  --dart-define=API_BASE=http://localhost:5000
```

Open `http://localhost:8000` in your browser.
