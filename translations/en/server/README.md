> Automatic English translation of [`server/README.md`](../../../server/README.md)
> at commit `2089f5b`. The Spanish original prevails.

# Vote-count (escrutinio) backend (prototype)

Prototype of [scrutiny-backend](../sdd/specs/scrutiny-backend/SPEC.md): ingestion of
captures, immutable evidence by SHA-256 and server-side OCR with Tesseract. Python
standard library only, no installations. FastAPI (SB-1 ★) can replace the
HTTP layer without changing the `/v1` API.

```sh
python3 server/scrutiny_server.py          # http://127.0.0.1:8740, prints the enrollment code
```

Implemented endpoints: `GET /v1/health`, `GET /v1/ocr/engines`,
`POST /v1/devices/enroll`, `POST /v1/captures` (returns `missingBlobs`),
`PUT /v1/blobs/{sha256}` (verifies the hash, read-only file),
`GET /v1/captures/{id}` and `GET /v1/captures/{id}/ocr` (detected numbers, always
`origin: "ocr"`).

- **Security:** the device comes from the token and never from the path. Errors in
  RFC 9457 format. By default it listens only on 127.0.0.1. External access is configured
  by the author, with TLS and rate limits (SPEC §7).
- **Data:** `.runtime/scrutiny/` (ignored by Git), with SQLite and blobs.
- **Missing:** human review and double entry, official mirror, quick count, embargo,
  rate limits and integration with the app.
