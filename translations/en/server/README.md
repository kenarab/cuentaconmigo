> Automatic English translation of [`server/README.md`](../../../server/README.md)
> at commit `0d0289e`. The Spanish original prevails.

# Scrutiny backend (prototype)

Prototype of [scrutiny-backend](../../../sdd/specs/scrutiny-backend/SPEC.md): capture
ingestion, immutable evidence by SHA-256 and server-side OCR with Tesseract. Python
standard library only, no installations. FastAPI (SB-1 ★) can replace the HTTP layer
without changing the `/v1` API.

```sh
python3 server/scrutiny_server.py          # http://127.0.0.1:8740, prints the enrollment code
```

Exposing it on the Internet (author): behind a reverse proxy with HTTPS and

```sh
CC_PUBLIC=1 CC_TRUST_PROXY=1 CC_ENROLL_CODES_FILE=/path/codes.txt python3 server/scrutiny_server.py
```

### Starting and stopping the public test server

Current setup of `newbery.duckdns.org/cuentaconmigo` (proxy → `127.0.0.1:8740`):

```sh
cd ~/home.agents/git/cuentaconmigo
nohup env CC_PUBLIC=1 CC_TRUST_PROXY=1 CC_OPEN_TEST=1 \
  CC_ENROLL_CODES_FILE=$PWD/.private/scrutiny-codes.txt CC_APP_ENROLL_CODE=0000 \
  CC_HOST=127.0.0.1 CC_PORT=8740 python3 -E -s server/scrutiny_server.py \
  > ~/home.codex/tmp/scrutiny.log 2>&1 &
curl https://newbery.duckdns.org/cuentaconmigo/v1/health   # "status": "ok"
pkill -f scrutiny_server.py                                  # stop
```

- `python3 -E -s`, not `-I`: with `-I` it does not import `server/readings.py`.
- `CC_OPEN_TEST=1` and `CC_APP_ENROLL_CODE=0000` are **test mode** (enrollment with "0000").
  Remove them before using real data.
- Without `nohup … &` it runs in the terminal and stops with `Ctrl+C`.

`codes.txt` has one enrollment code per line; each one works only once. Security and
receipt details in the SPEC. Contract: `contracts/api/scrutiny-v1.openapi.json`.

Implemented endpoints: `GET /v1/health`, `GET /v1/ocr/engines`,
`POST /v1/devices/enroll`, `POST /v1/captures` (returns `missingBlobs`),
`PUT /v1/blobs/{sha256}` (verifies the hash, read-only file),
`GET /v1/captures/{id}`, `GET /v1/captures/{id}/ocr` (detected numbers, always
`origin: "ocr"`), `GET /v1/log/head` (head of the receipt log) and `POST /v1/readings?templateId=…`
(JPEG image → per-cell reading aligned to the layout in `contracts/layouts/`, with
confidence and boxes; does not store the image; see `sdd/specs/form-layouts/SPEC.md`).
Measurement: `python3 server/eval_readings.py`. Needs Pillow (`python3 -c "import PIL"`).

- **Security:** the device comes from the token and never from the path. Errors in
  RFC 9457 format. By default it listens only on 127.0.0.1. External access is configured
  by the author, with TLS and rate limits (SPEC §7).
- **Data:** `.runtime/scrutiny/` (ignored by Git), with SQLite and blobs.
- **Missing:** human review and double entry, official mirror, quick count and embargo.
