# Backend API

A minimal HTTP API for demo inference. This backend is intentionally dependency-free
and uses Python's standard library.

## Endpoints

- `GET /api/health`
  - Returns an uptime check payload.
- `POST /api/infer`
  - Accepts JSON `{ "sample": "name" }` and returns a mock prediction.
- `GET /api/history`
  - Returns the most recent inference responses.

## Run locally

```bash
python3 backend/app.py
```

## Sample request

```bash
curl -X POST http://localhost:5000/api/infer \
  -H "Content-Type: application/json" \
  -d @backend/sample_request.json
```

Example response payloads are available in `backend/sample_response.json`.
