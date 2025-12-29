#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

cat <<'MESSAGE'
Starting demo services.
- Backend: http://localhost:5000
- Frontend (Flutter): http://localhost:8000

Press Ctrl+C to stop.
MESSAGE

python3 "$ROOT_DIR/backend/app.py" &
BACKEND_PID=$!

if command -v flutter >/dev/null 2>&1; then
  cd "$ROOT_DIR/frontend_flutter"
  flutter pub get
  flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8000 \
    --dart-define=API_BASE=http://localhost:5000
else
  echo "Flutter is not installed. Run the backend with the dashboard manually:"
  echo "  cd frontend_flutter"
  echo "  flutter pub get"
  echo "  flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8000 \\"
  echo "    --dart-define=API_BASE=http://localhost:5000"
  wait "$BACKEND_PID"
fi

kill "$BACKEND_PID"
