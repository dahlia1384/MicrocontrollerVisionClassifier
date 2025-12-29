from __future__ import annotations

import json
from collections import deque
from datetime import datetime, timezone
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, HTTPServer
from random import randint, random
from time import perf_counter, time

START_TIME = perf_counter()
HISTORY = deque(maxlen=10)


class ApiHandler(BaseHTTPRequestHandler):
    def _set_headers(self, status_code: int) -> None:
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET,POST,OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def _send_json(self, status_code: int, payload: dict) -> None:
        self._set_headers(status_code)
        self.wfile.write(json.dumps(payload).encode("utf-8"))

    def do_OPTIONS(self) -> None:
        self._set_headers(HTTPStatus.NO_CONTENT)

    def do_GET(self) -> None:
        if self.path == "/api/health":
            self._send_json(
                HTTPStatus.OK,
                {
                    "status": "ok",
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                    "uptime_s": round(perf_counter() - START_TIME, 2),
                },
            )
            return

        if self.path == "/api/history":
            self._send_json(HTTPStatus.OK, {"history": list(HISTORY)})
            return

        self._send_json(HTTPStatus.NOT_FOUND, {"error": "Not found"})

    def do_POST(self) -> None:
        if self.path != "/api/infer":
            self._send_json(HTTPStatus.NOT_FOUND, {"error": "Not found"})
            return

        content_length = int(self.headers.get("Content-Length", 0))
        payload_raw = self.rfile.read(content_length) if content_length else b"{}"
        try:
            payload = json.loads(payload_raw.decode("utf-8"))
        except json.JSONDecodeError:
            payload = {}

        sample_name = payload.get("sample", "demo-frame")
        start = perf_counter()
        prediction = {"label": randint(0, 2), "score": round(random(), 3)}
        response = {
            "id": int(time() * 1000),
            "sample": sample_name,
            "prediction": prediction,
            "latency_ms": round((perf_counter() - start) * 1000, 2),
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
        HISTORY.appendleft(response)
        self._send_json(HTTPStatus.OK, response)


def run(host: str = "0.0.0.0", port: int = 5000) -> None:
    server = HTTPServer((host, port), ApiHandler)
    print(f"Backend running on http://{host}:{port}")
    server.serve_forever()


if __name__ == "__main__":
    run()
