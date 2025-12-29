#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

cat <<'MESSAGE'
Starting demo services.
- Backend: http://localhost:5000
- Frontend: http://localhost:8000

Press Ctrl+C to stop.
MESSAGE

python3 "$ROOT_DIR/backend/app.py" &
BACKEND_PID=$!

cd "$ROOT_DIR/web"
python3 -m http.server 8000

kill "$BACKEND_PID"
