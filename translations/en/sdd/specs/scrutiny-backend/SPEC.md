> Automatic English translation of [`sdd/specs/scrutiny-backend/SPEC.md`](../../../../../sdd/specs/scrutiny-backend/SPEC.md)
> at commit `8e69e7b`. The Spanish original prevails.

# SPEC · Vote-count backend: server-side OCR, official mirror and quick count

Status: **design proposal (role `planner`); no decision taken.** Resolves
decision D-003 of [mobile-platform](../../../../../sdd/specs/mobile-platform/SPEC.md) ("backend/central
reception") and features F-06, F-08 and F-09 of [FEATURES.md](../roadmap/FEATURES.md).
Axis: **D. Election day and vote count (jornada y escrutinio)** of the [vision](../../../../../sdd/specs/vision/SPEC.md).
Date: 31/10/2026. Acceptance: author. `electoral_counsel` check: **pending** (section 12).

What follows is a proposal for the author: language, stack, API and architecture are
chosen in decisions SB-x (section 9). Nothing is installed or brought up without his consent.

## 1. Problem and scope

On-phone OCR (Vision / ML Kit) works as an aid, but it is not enough to
extract with measurable quality the handwritten digits of telegrams, tally sheets (actas) and
count certificates (certificados), nor to compare engines, nor to process the samples in
[data/ocr-samples](../../../data/ocr-samples/README.md). Moreover, the app today has
nowhere to send the evidence (E-10/E-11 of [app-screens](../app-screens/SPEC.md)
say "envío no configurado" ("submission not configured")).

The author's request: a **local server** (first on his machine, later reachable
from outside) that receives the captures from the app, runs OCR and whatever else is needed, and
that distinguishes **two counts**:

- **Official count (escrutinio oficial)**: mirror of what the electoral authority publishes (provisional
  (provisorio) and final (definitivo)) and polling-table-by-polling-table cross-check against what party
  poll watchers (fiscales) captured.
- **Own quick count**: a sample of polling tables (mesas) chosen by lot, entered by
  volunteers, and a projection with intervals that is available **before** the
  official one, even if only with some polling tables.

Relationship with the rest of the project:

| Piece | What it brings to this SPEC | What it receives |
| --- | --- | --- |
| [docs/hackdash.md](../../../../../docs/hackdash.md) | The challenge: "una app permite que fiscales y autoridades de mesa escaneen el telegrama y/o acta de su mesa, y una simulación del AMBA muestra cómo se armaría la proyección con muy pocos datos" ("an app lets poll watchers and polling-table officials scan the telegram and/or tally sheet of their polling table, and an AMBA simulation shows how the projection would be built with very little data"). | The backend is the piece that joins app and projection; at the hackathon it is shown running locally. |
| [telegram-capture](../telegram-capture/SPEC.md) | Immutable capture package with SHA-256 per page; values with origin `manual` / `ocr-accepted`. | A destination for "Enviar" ("Send") (E-11), server OCR as a second reading, cross-check (F-09). |
| iOS app (and future Android) | Client of the `capture.schema.json` contract. | Offline submission queue with retries; server OCR suggestions (F-06, optional). |
| [amba-simulation](../amba-simulation/SPEC.md) | Replays the 2023 general election with official DINE per-polling-table data: it is the "projection with little data" demo. | The same projection module (stratified + intervals) feeds the simulation and the real quick count; the 2023 data serve to test the official mirror and the cross-check. |
| [contracts/](../../../contracts/README.md) | Schema, templates, vectors. | New contract: `contracts/api/scrutiny-v1.openapi.yaml` (proposal, requires `contract-change`). |
| [participant-protection](../../../../../sdd/specs/participant-protection/SPEC.md) | Minimization, pseudonymity, evidence without people, no single point of failure. | Device authentication without personal data; publishable copy vs. preserved evidence. |

Out of scope for this SPEC: the citizen network (civic-network), public access
from the Internet (section 8: the author configures it later), Android, the survey
of the official 2027 format (Q1 of telegram-capture).

## 2. Two counts, one cross-check

```
                 capture (app)            official publication (DINE / CNE)
                      │                            │
                      ▼                            ▼
          ┌──────────────────────┐      ┌──────────────────────┐
          │ Evidence + OCR +     │      │ Official mirror      │
          │ human confirmation   │      │ provisional/final    │
          └─────────┬────────────┘      └──────────┬───────────┘
                    │ confirmed tally per mesa      │ official result per mesa
                    ├───────────────┬───────────────┤
                    ▼               ▼               ▼
            ┌──────────────┐ ┌────────────┐ ┌──────────────────┐
            │ Quick count  │ │ Cross-check│ │ Official panel   │
            │ (sample)     │ │ mesa by    │ │ (mirror only)    │
            │              │ │ mesa       │ │                  │
            └──────────────┘ └────────────┘ └──────────────────┘
             embargo art.71 h   public after the embargo, no "fraud"
```

### 2a. Official count (mirror)

- **Sources**: per-polling-table results of the provisional count and of the final count
  published by the electoral authority (DINE/CNE), plus the official images of
  telegrams when they are published. What format and URL they will have in 2027: **to be verified**
  by `electoral_analyst`; in 2023 there was downloadable per-polling-table data (used by the
  AMBA simulation).
- **Provenance**: each imported file is stored immutably with URL, download date
  and SHA-256 (same criterion as amba-simulation); normalization generates
  a reproducible, versioned derivative. What was downloaded is never edited.
- **History**: the provisional count changes during the night; each import is a
  timestamped **version**. The mirror allows reconstructing "what the
  official count said at 22:30".
- **Cross-check**: for each polling table with a tally confirmed by people, it is compared cell by
  cell against the provisional count and, when available, the final one. Result per polling table:
  `match`, `mismatch` (with the differing cells), `official_missing`,
  `capture_missing`. Discrepancies are **not characterized** as irregularities:
  they are described (telegram-capture, legal framework 6; in 2025 there were telegram errors
  corrected in the final count, see MARCO_LEGAL 3).
- The mirror is independent of the quick count: it is useful even without any capture.

### 2b. Own quick count (sample)

Goal: to have an estimate with an interval for the priority category
(president; others according to the template) **with few polling tables and before** the provisional count
reaches high coverage, and also an external check of that provisional count.

**Sample design (proposal; S-3 of amba-simulation decides the model):**

1. **Frame**: the register of polling tables published by the authority (district, section,
   circuit, polling table, registered voters). If in 2027 there is only a per-circuit frame, stratification
   is done at that level.
2. **Strata**: district × section (in the AMBA: CABA communes and 24 districts (partidos)),
   optionally by circuit size. Allocation proportional to registered voters with a
   minimum per stratum; Neyman alternative if there is historical variance (2023).
3. **Reproducible draw**: systematic or simple random selection within each
   stratum with a deterministic generator (256-bit `seed`). The same seed and the
   same frame produce the same sample; the algorithm and the version stay in the
   design record.
4. **Replacements**: for each drawn polling table, an ordered list of substitutes from the same
   stratum (same draw), for when there is no volunteer. Substitutions are
   recorded and reported as a replacement rate.
5. **Coverage**: the sample polling table is covered by a volunteer (poll watcher or polling-table official
   who is already there, or a person who photographs the posted telegram if the 2027
   regulations allow it: **to be verified**). Uncovered polling tables = non-response; the
   rate is published and corrected with weights within the stratum.
6. **Estimators**: (i) **design-based**, only sample polling tables, stratified by
   registered voters, with interval (variance per stratum; bootstrap as a check);
   (ii) **post-stratified**, with all confirmed captures (including
   opportunistic ones, outside the sample), labeled as secondary because arrival
   is biased. The AMBA simulation shows exactly the difference between the two.
7. **Publication of the selection** (SB-6): options in the decisions table. The
   recommendation is *commit-reveal*: publish before the election the SHA-256 of
   (seed + algorithm + frame) and reveal the seed and the sample after the polls close.
   It prevents anyone from putting pressure on known polling tables and allows auditing that the sample
   was not chosen after seeing results. Volunteers receive their assignment through a
   private channel.

**What counts**: only tallies **confirmed by people** (section 4.4). OCR
alone never enters an estimate.

**Expected timing** (assumptions, to be verified against the 2027 calendar): polls close at 18:00;
telegrams available to poll watchers between 18:30 and 21:00; official publication of the
provisional count from ~21:00. The quick count is computed continuously from the
first entry, but **is not published** until the window of art. 71 subsec. h expires.

### Relationship and cross-check between the two

| Moment | Quick count | Official mirror | Cross-check |
| --- | --- | --- | --- |
| Before the polls close | no data | no data | — |
| Close → end of embargo (3 h, to be verified) | computed; visible only to operators with access logging | empty or partial | internal |
| After the embargo | published with interval, coverage and method | mirrored as the authority publishes | public: polling table by polling table, without characterizations |
| Final | closed and archived with the final error | final version | final report: quick-count accuracy and closed discrepancies |

The quick count **evaluates itself** against the official one (absolute error per
political grouping (agrupación), interval coverage). That report is the method's accountability;
with 2023 it can be produced today in the simulation.

### Legal restriction (summary; assessment in section 12)

Electoral Code (Código Electoral) art. 71 subsec. h: prohibits publishing polls and projections during
the election and until three hours after the polls close (fine under art. 128 bis). **To be verified**:
the text in force for 2027. Design consequence: every aggregated API response
carries an embargo status computed against the configured official closing time; within
the window, public endpoints respond `423 Locked` with the reason and the release
time. **Individual polling table** endpoints (cross-check) are also embargoed by
default until `electoral_counsel` says whether a partial panel counts as a projection
(MARCO_LEGAL 4: "consultar" ("consult")).

## 3. Proposed architecture

### 3.1 Components

```
 iOS/Android app ──HTTPS──▶ ┌──────────────────────┐
 (offline queue)             │ API /v1 (stateless)   │──▶ Device auth (tokens)
                             └──────┬──────┬────────┘
                                    │      │
                  ┌─────────────────▼┐   ┌─▼────────────────────────┐
                  │ Blob store        │   │ Database                 │
                  │ content-addressed │   │ captures · OCR · reviews │
                  │ (sha256 → bytes)  │   │ tallies · official · log │
                  └─────────────────▲┘   └─▲──────────▲───────────▲┘
                                    │      │          │           │
                     ┌──────────────┴──────┴──┐  ┌────┴─────┐ ┌──┴──────────┐
                     │ OCR workers (queue)     │  │ Human    │ │ Aggregator /│
                     │ engine A / engine B …   │  │ review   │ │ projection  │
                     └────────────────────────┘  └──────────┘ └─────────────┘
                                                                     ▲
                     ┌───────────────────────────────┐               │
                     │ Official mirror importer       │───────────────┘
                     │ (DINE provisional / final)     │
                     └───────────────────────────────┘
```

| Component | Responsibility | Prototype (1 machine) | Scale (N nodes) |
| --- | --- | --- | --- |
| Ingestion API | Validate packages against `capture.schema.json`, recompute hashes, idempotency, enqueue OCR | 1 HTTP process | several stateless processes behind a proxy |
| Evidence store | Immutable blobs by SHA-256; never overwritten or deleted (except by the author's order, with logging) | directory `blobs/ab/cd/<sha256>` with restricted permissions and disk encryption | S3-compatible object storage (self-hosted), same key scheme |
| Database | Metadata, statuses, audit log | SQLite in WAL mode | PostgreSQL; same migrations |
| OCR job queue | One job per page and engine; retries with backoff; `at-least-once` + idempotent results | `jobs` table + worker in a separate process | broker (Redis Streams or NATS) and horizontal workers |
| OCR workers | Pluggable engine (section 5); output: text per region, confidence, engine version | 1 CPU worker | N CPU/GPU workers; each result carries `engine`, `engineVersion`, `modelHash` |
| Human review | Blind double entry, difference resolution, confirmed tally | minimal web app or the app itself | queues per stratum; assignment to reviewers without seeing identities |
| Aggregator / projection | Tallies → estimators with interval; embargo; accuracy report | same code as the AMBA simulation | separate process, aggregate cache |
| Official mirror | Import versioned official files; normalize; cross-check | manual import script | scheduled importer with format-change alerts |
| Audit log | Append-only event for each status change, hash-chained | `events` table with `prevHash` | same, with periodic anchoring of the published root hash |

### 3.2 Data model (summary)

- `Capture` (immutable): the package as sent by the app (`capture.schema.json`),
  `receivedAt`, pseudonymous `deviceId`, server `status`.
- `Blob`: `sha256`, `bytes`, `mediaType`, `storedAt`. One page = one blob.
- `OcrJob` / `OcrResult`: per (blob, engine); regions with `bbox`, `text`,
  `confidence`; values normalized with the contract's `normalizeDigits`. **Always
  marked `origin = ocr`.**
- `Review`: human entry on a capture (`entry = 1 | 2`), blind with respect to the other one
  and to the OCR; `resolvedBy` is a reviewer pseudonym.
- `Tally` (derived, versioned): **confirmed** per-cell values for a polling table and a
  category, with `confirmationMethod ∈ {app-confirmed, double-entry, single-review}`
  and a reference to the captures and reviews that support it. If two differing captures of
  the same polling table arrive, the tally stays `disputed` until review.
- `OfficialImport` / `OfficialResult`: import version, provenance, values
  per polling table and category.
- `Comparison`: tally vs. official, per cell.
- `SampleDesign` / `SampleMesa`: design, seed (sealed), strata, drawn polling tables,
  substitutes, coverage status.
- `Event`: `seq`, `at`, `actor` (pseudonym), `type`, `payload`, `prevHash`, `hash`.

Cross-cutting rule: **what is extracted automatically (`OcrResult`) is never mixed with what
is confirmed by people (`Review`, `Tally`)**; they live in different tables, are
exposed on different routes and every response indicates which is which.

### 3.3 Idempotency, retries and offline entry

- The app generates the `id` (UUID) and the hashes; the server **recomputes** them and rejects
  (`422`) if they do not match.
- Two-step submission for poor networks: (1) `POST /v1/captures` with the package
  JSON → responds which blobs are missing; (2) `PUT /v1/blobs/{sha256}` for each page
  (retryable; a blob that already exists responds `200` without rewriting). A capture
  becomes `complete` when the last blob has arrived.
- Resending the same package returns `200` with the same resource; the same `id` with
  different content returns `409` (evidence is never replaced).
- Optional `Idempotency-Key` for POSTs that have no natural id (reviews).
- The app queues submissions (E-11) and retries with exponential backoff; the server tolerates
  arrivals hours after the polls close and keeps `capturedAt` (from the phone) and
  `receivedAt` (from the server) separately.

### 3.4 Chain of custody and audit

- Blob → hash → package → capture → review → tally → aggregate: each link references
  the previous one by id and hash; it can be recomputed end to end.
- The event log is append-only and chained; the root hash can be published
  periodically (in the repo, or in the future in the citizen network) so that anyone
  can verify that history was not rewritten (SB-9).
- Every read of raw evidence (images) by an operator is logged.
- Auditable export: an external verifier can receive the package + blobs +
  events and recompute hashes without access to the server.

### 3.5 Volunteer authentication without personal data

- **Enrollment by code**: the operator issues single-use enrollment codes
  (per coverage campaign or per stratum, **never per party**: the poll watcher's party
  is sensitive data, Law 25.326 (Ley 25.326) arts. 2 and 7). The app redeems the code for a
  `deviceToken` bound to a random `deviceId`.
- No name, national ID (DNI), phone number or location. The code indicates which sample polling tables
  it can report coverage for, nothing more.
- Optional (SB-8): the app signs the package with a key generated on the device
  (Secure Enclave / Keystore); the server stores the public key per `deviceId`.
  It allows proving that a capture came from an enrolled device without knowing whose it is.
- Roles: `device` (send captures, see its own), `reviewer` (double entry, without
  seeing `deviceId`), `operator` (import official data, manage the sample, see embargoed
  aggregates with logging), `public` (aggregated reads after the embargo).
- Revocation by `deviceId`. Minimal and published retention of technical records (IP)
  (participant-protection, principle 3).

### 3.6 From a local server to several nodes

1. **Today (hackathon)**: one API process + one worker + SQLite + blob directory on the
   author's machine; the app connects over the local network; the AMBA simulation consumes
   the same aggregates API with 2023 data.
2. **External access** (section 8): TLS proxy in front, without changing the code.
3. **Scale**: SQLite → PostgreSQL, directory → S3-compatible objects, job table
   → broker, N workers. The code accesses those resources through interfaces
   (ports/adapters), so the change is one of configuration, not of API.
4. **Resilience** (participant-protection, principle 6): read replicas of the
   official mirror and of the public aggregates in another jurisdiction; raw evidence
   is **not** replicated to public nodes.

Sizing (planning assumptions, not data): ~2 pages per capture of
1–2 MB each; if 5,000 polling tables submit within 3 hours that is ~10,000 blobs and ~20 GB, less
than 1 blob/s: a modest server absorbs it. The bottleneck is OCR
(seconds per page per engine on CPU): it is solved with more workers, not with more API.

## 4. Flow of a capture on the server

1. `received`: the JSON arrived; it was validated against the schema and the template.
2. `complete`: all blobs arrived and the hashes match.
3. `ocr_queued` → `ocr_done` | `ocr_failed`: one job per page and configured
   engine; all results are stored (engine comparison).
4. `review_pending`: if the polling table's tally needs confirmation (SB-7: when).
   Blind double entry: two reviewers see the image and enter data without seeing the OCR or the other
   entry; the server compares; only the conflicting cells go to a third
   resolution with the image in view.
5. `confirmed`: there is a `Tally` with a declared method. It enters the cross-check and, if the polling table
   is in the sample, the quick count.
6. `rejected`: illegible image, document not accepted or polling table not in the frame;
   the reason is recorded and the capture **is kept** (evidence is not deleted).

Values coming from the app already confirmed by the person (`manual` /
`ocr-accepted`) are treated as a **first entry**; the server OCR is a separate
automatic reading; double entry is a second human entry. OCR never
replaces a human entry.

## 5. Language, stack and OCR engines

### 5.1 Python for the prototype (recommendation)

Reasons: all OCR engines and ML tools are consumed from Python;
the contracts are already JSON; the AMBA simulation will probably use Python to
normalize data (S-1); it generates OpenAPI from the types with no extra work; it can be
prototyped in hours for the hackathon.

Stack proposal (SB-1, all subject to consent before installing):
Python 3.12 · FastAPI + Pydantic v2 (API and OpenAPI) · SQLite (WAL) with migrations ·
own worker on top of a job table (no broker in the prototype) · Pillow/OpenCV
for cropping and region registration · pluggable OCR engine.

### 5.2 Path to Rust

The stable contract is the versioned OpenAPI file (`/v1`) plus the JSON Schemas in
`contracts/`. As long as both implementations pass the same **contract tests**
(collection of expected requests/responses in `contracts/api/vectors/`), the app
does not notice the change.

| Order | Part | Why first | Proposed Rust |
| --- | --- | --- | --- |
| 1 | Blob store + hash validation + ingestion API | I/O intensive, small and critical logic (never lose or alter evidence), no ML | `axum` + `tokio`, `sha2`, `serde` |
| 2 | Aggregator / projection and sampling | Deterministic computation, easy to verify against the Python version with the same vectors | own crate shared with the simulation (WASM for the static web) |
| 3 | Official mirror (import and cross-check) | Depends on the official 2027 format; stabilize first in Python | after the format is known |
| 4 | OCR workers | The ML ecosystem remains in Python; alternative: models exported to ONNX and run from Rust (`ort`), or Tesseract bindings | last, or never |

Rule: no migration starts without green contract tests on the Python version.

### 5.3 Local OCR engines (comparison without installing)

What needs to be read are **handwritten digits in cells of a known form**,
not running text. That is why the proposal is a **region-based pipeline**: register the
image against the template (form marks), crop each cell and recognize
only digits. The general OCR engine is one of the stages, interchangeable.

| Engine | License | Strength | Weakness for this case | Dependencies to install (with consent) |
| --- | --- | --- | --- | --- |
| **Tesseract 5** (via `pytesseract`/`tesserocr`) | Apache 2.0 | Mature, lightweight, CPU, "digits only" mode via whitelist, many languages | Weak on handwriting; needs good preprocessing and per-cell cropping | system package `tesseract-ocr` + `spa`; pip `pytesseract`, `opencv-python-headless` |
| **PaddleOCR** (PP-OCR) | Apache 2.0 | Robust detection + recognition on real photos, good CPU performance, small models | Trained on print; irregular handwriting; heavy dependency (`paddlepaddle`) | pip `paddlepaddle` (~ hundreds of MB) + `paddleocr` |
| **EasyOCR** | Apache 2.0 | Easy to use, PyTorch, decent on scenes | Slow on CPU, heavy torch, mediocre handwriting | pip `torch` (GB) + `easyocr` |
| **Own digit classifier** (small CNN on cell crops; e.g. trained with public handwritten digits and fine-tuned with confirmed cells from `data/ocr-samples`) | ours | It is exactly the problem; fast on CPU; calibratable confidence; can be exported to ONNX/Core ML for the phone | Region registration and digit segmentation have to be built; needs cells confirmed by people to measure | pip `onnxruntime` (+ `torch` only for training) |

Recommendation (SB-2): **Tesseract as the baseline** (cheapest to install) and a
**region-based pipeline with a digit classifier** as the goal; PaddleOCR as a
second general engine to compare if the baseline disappoints. A single metric for all
(SB-3): per-cell and per-digit accuracy on the `valor_confirmado` (confirmed value) cells of
`data/ocr-samples/planilla-valores.csv`, plus confidence calibration
(with confidence ≥ 0.9, what percentage is correct?). The current versions of each
engine are checked at install time.

## 6. Proposed API (REST, `/v1`)

Alternatives considered: gRPC (binary, less natural from `URLSession` and for
debugging at the hackathon) and GraphQL (unnecessary: few entities). **REST + JSON with
OpenAPI 3.1** is the recommendation (SB-4): it is generated from FastAPI, consumed with
`URLSession` without libraries, and anyone can test it with `curl`.

Conventions: UTF-8 JSON; ISO-8601 UTC dates; UUID ids; lowercase hex hashes;
`Authorization: Bearer <token>`; cursor pagination (`?cursor=&limit=`); changes
in `/v1` only additive, incompatible ones go to `/v2`; each aggregated response includes
`embargo` (`{active, until, reason}`).

### 6.1 Health and enrollment

| Method and route | Role | Body → response |
| --- | --- | --- |
| `GET /v1/health` | public | → `200 {status, version, time}` |
| `GET /v1/health/ready` | public | → `200` if DB, blobs and queue respond; `503` otherwise |
| `POST /v1/devices/enroll` | no token | `{enrollmentCode, platform, appVersion, publicKey?}` → `201 {deviceId, deviceToken, scopes[]}` |
| `DELETE /v1/devices/{deviceId}` | operator | → `204` (revokes) |

### 6.2 Ingestion of captures and evidence

| Method and route | Role | Body → response |
| --- | --- | --- |
| `POST /v1/captures` | device | `capture.schema.json` package → `201 {id, status:"received", missingBlobs:[sha256…]}` · `200` if it already existed identically · `409` if same id and different content · `422` if it does not validate |
| `PUT /v1/blobs/{sha256}` | device | binary `image/jpeg` → `201 {sha256, bytes}` · `200` if it already existed · `422` if the hash does not match the body |
| `GET /v1/captures/{id}` | device (own) / reviewer / operator | → `200 {capture, status, pages:[{sha256, received}], ocr:{status}, tallyId?}` |
| `GET /v1/captures?mesa=…&status=…` | reviewer / operator | → paginated list |
| `GET /v1/blobs/{sha256}` | reviewer / operator (logged) | → bytes; **never** public |

### 6.3 OCR (extracted automatically)

| Method and route | Role | Body → response |
| --- | --- | --- |
| `GET /v1/captures/{id}/ocr` | device (own) / reviewer | → `200 {jobs:[{engine, engineVersion, status, attempts, startedAt, finishedAt}], results:[{engine, page, cells:{categoria:{fila:{text, value, confidence, bbox}}}, header:{…}}]}`; `origin` always `"ocr"` |
| `POST /v1/captures/{id}/ocr` | operator | `{engine}` → `202 {jobId}` (reprocess with another engine) |
| `GET /v1/ocr/engines` | public | → list of engines, versions and published metrics on the sample |

### 6.4 Human confirmation

| Method and route | Role | Body → response |
| --- | --- | --- |
| `POST /v1/captures/{id}/reviews` | reviewer | `{entry: 1|2, header:{…}, cells:{…}}` (without seeing OCR or the other entry) → `201 {reviewId, comparison?: {agree, conflicts:[cellRef…]}}` |
| `POST /v1/captures/{id}/reviews/resolve` | reviewer (different from the previous two) | `{cells:{cellRef: value}}` → `200 {tallyId}` |
| `GET /v1/mesas/{distrito}/{seccion}/{circuito}/{mesa}/tally` | reviewer / operator (public after embargo, SB-10) | → `200 {tally, confirmationMethod, basedOn:{captureIds, reviewIds}, version}` |

### 6.5 Quick count

| Method and route | Role | Body → response |
| --- | --- | --- |
| `POST /v1/quick-count/designs` | operator | `{frameImportId, strata, allocation, seedCommitment}` → `201 {designId, commitmentHash}` (the seed is stored sealed) |
| `POST /v1/quick-count/designs/{id}/reveal` | operator (after the polls close) | `{seed}` → `200 {sample:[…], verified:true}` |
| `GET /v1/quick-count/designs/{id}` | public | → design, strata, commitment; the sample only after the *reveal* (SB-6) |
| `GET /v1/quick-count/estimate?design=…&category=presidente&estimator=design|poststratified` | operator (always, with logging) · public after embargo | → `200 {estimator, coverage:{sampled, confirmed, replaced}, results:[{agrupacion, share, lower, upper}], totalVotes, asOf, method}` · `423 Locked {embargo}` |
| `GET /v1/quick-count/accuracy?design=…` | public (after the final count) | → error per political grouping vs. provisional and final, interval coverage |

Political groupings are listed in the order of the official template (list number) and
with the same precision; no response highlights any of them.

### 6.6 Official count (mirror and cross-check)

| Method and route | Role | Body → response |
| --- | --- | --- |
| `POST /v1/official/imports` | operator | `{source:"provisorio"|"definitivo", sourceUrl, downloadedAt, sha256}` + file → `202 {importId}` |
| `GET /v1/official/imports` | public | → versions with provenance and totals |
| `GET /v1/official/summary?source=…&level=distrito|seccion&importId=…` | public (after embargo) | → totals per political grouping, polling tables counted, version |
| `GET /v1/official/mesas/{distrito}/{seccion}/{circuito}/{mesa}` | public (after embargo) | → official values per version |
| `GET /v1/comparisons?status=mismatch&distrito=…` | reviewer / operator (public after embargo, SB-10) | → `[{mesa, tallyVersion, officialImportId, cells:[{ref, tally, official}], status}]` |

### 6.7 Errors

`application/problem+json` (RFC 9457):

```json
{ "type": "https://cuentaconmigo.ar/errors/hash-mismatch", "title": "El hash no coincide",
  "status": 422, "code": "hash_mismatch", "detail": "page-1.jpg: declarado 3f9a…, calculado 8b10…",
  "instance": "/v1/blobs/3f9a…", "errors": [ {"path": "pages[0].sha256", "code": "hash_mismatch"} ] }
```

Initial codes: `schema_invalid`, `template_unknown`, `hash_mismatch`,
`capture_conflict` (409), `blob_missing`, `mesa_not_in_frame`, `embargo_active` (423),
`unauthorized` (401), `forbidden` (403), `rate_limited` (429, with `Retry-After`).
`detail` fields include no personal data or internal paths.

### 6.8 OpenAPI (summary)

```yaml
openapi: 3.1.0
info: { title: CuentaConmigo Scrutiny API, version: 1.0.0-draft }
servers: [ { url: /v1 } ]
security: [ { bearer: [] } ]
paths:
  /health: { get: { security: [], responses: { "200": { $ref: "#/components/responses/Health" } } } }
  /devices/enroll: { post: { security: [], requestBody: { $ref: "#/components/requestBodies/Enroll" } } }
  /captures:
    post: { requestBody: { content: { application/json: { schema: { $ref: "contracts/schemas/capture.schema.json" } } } },
            responses: { "201": { $ref: "#/components/responses/CaptureAccepted" }, "409": { $ref: "#/components/responses/Problem" } } }
    get:  { parameters: [mesa, status, cursor, limit] }
  /captures/{id}: { get: {} }
  /captures/{id}/ocr: { get: {}, post: {} }
  /captures/{id}/reviews: { post: {} }
  /captures/{id}/reviews/resolve: { post: {} }
  /blobs/{sha256}: { put: { requestBody: { content: { image/jpeg: {} } } }, get: {} }
  /mesas/{distrito}/{seccion}/{circuito}/{mesa}/tally: { get: {} }
  /quick-count/designs: { post: {} }
  /quick-count/designs/{id}: { get: {} }
  /quick-count/designs/{id}/reveal: { post: {} }
  /quick-count/estimate: { get: { responses: { "200": {}, "423": { $ref: "#/components/responses/Problem" } } } }
  /quick-count/accuracy: { get: {} }
  /official/imports: { post: {}, get: {} }
  /official/summary: { get: {} }
  /official/mesas/{distrito}/{seccion}/{circuito}/{mesa}: { get: {} }
  /comparisons: { get: {} }
components:
  securitySchemes: { bearer: { type: http, scheme: bearer } }
  schemas:
    Embargo: { type: object, required: [active], properties: { active: {type: boolean}, until: {type: string, format: date-time}, reason: {type: string} } }
    Value:   { $ref: "contracts/schemas/capture.schema.json#/$defs/value" }
    OcrCell: { type: object, properties: { text: {type: string}, value: {type: [integer, "null"]}, confidence: {type: number}, bbox: {type: array}, origin: {const: ocr} } }
    Estimate: { type: object, properties: { estimator: {enum: [design, poststratified]}, coverage: {}, results: {type: array}, asOf: {}, method: {}, embargo: { $ref: "#/components/schemas/Embargo" } } }
    Problem: { type: object, properties: { type: {}, title: {}, status: {}, code: {}, detail: {}, instance: {}, errors: {type: array} } }
```

The full file is proposed at `contracts/api/scrutiny-v1.openapi.yaml`
(requires `contract-change` and the author's acceptance); the contract vectors at
`contracts/api/vectors/`.

## 7. What is shown at the hackathon

1. The app sends a capture of the demo template to the local server; one sees `received →
   complete → ocr_done`.
2. Server screen: image, cells detected by OCR with confidence, and next to it
   the human entry; differences highlighted.
3. OCR metrics on the confirmed samples (`/v1/ocr/engines`).
4. AMBA simulation consuming `/v1/quick-count/estimate` with 2023 data and
   `/v1/official/summary` from the 2023 mirror: the projection stabilizes with few polling tables
   and is compared with the official result. Permanent label "SIMULACIÓN · generales 2023"
   ("SIMULATION · 2023 general election").
5. The embargo `423 Locked` with a simulated closing time, to show that the
   rule is in the code.

All with fictitious or 2023 data; no image with names or signatures on screen
without redaction.

## 8. Access from outside (later step, configured by the author)

Requirements the design already meets so that this step is only configuration:

- Mandatory TLS (reverse proxy with certificates; HSTS); no plain HTTP outside the
  local network.
- Authentication on every route except `/health`, `/devices/enroll` and public reads
  after the embargo; revocable tokens; secrets outside Git (`.private/`).
- Rate limit per `deviceId` and IP (ingestion and enrollment) with `429`.
- **Raw evidence (`/v1/blobs`) is never public** nor replicated to public nodes;
  if someday a copy is published, it is the version with personal data redacted and no
  EXIF (participant-protection PP-6 / F-50), by decision of the author and of electoral_counsel.
- Separate the public entry point (aggregated reads, cache) from the ingestion one.
- Technical logs with short, published retention; no third-party analytics.
- Hosting jurisdiction: Law 25.326 art. 12 (international transfer):
  decide with electoral_counsel (PP-4).
- Encrypted backups; restore procedure tested before the election.

## 9. Pending decisions

★ = the planner's recommendation, non-binding.

| ID | Decision | Options |
| --- | --- | --- |
| SB-1 | Prototype language and framework | ★ Python 3.12 + FastAPI + SQLite · Python + Flask · Rust (axum) from the start · Node/TS |
| SB-2 | OCR engines to install first | ★ Tesseract (baseline) + region-based pipeline with digit classifier · PaddleOCR · EasyOCR · own classifier only |
| SB-3 | OCR metric | ★ per-cell and per-digit accuracy on confirmed cells from `data/ocr-samples` + confidence calibration · per-cell accuracy only · CER on text |
| SB-4 | API style | ★ REST + JSON + OpenAPI 3.1 · gRPC · GraphQL |
| SB-5 | Quick count model | ★ stratified by district×section weighted by registered voters, with intervals · post-stratified with regression · hierarchical Bayesian (coordinate with S-3) |
| SB-6 | Publication of the polling table selection | ★ *commit-reveal* (hash before, seed and sample after the polls close) · publish the sample beforehand · publish only afterwards without commitment · do not publish |
| SB-7 | When to require double entry | ★ always for sample polling tables; opportunistic ones with one human entry + agreeing OCR · always all · never (trust the app) |
| SB-8 | Package signing on the device | ★ optional in v1 (key in Secure Enclave/Keystore), mandatory in v2 · mandatory from v1 · do not sign |
| SB-9 | Public anchoring of the audit log | ★ publish the daily/hourly root hash in the repo · do not publish · external timestamping service |
| SB-10 | Publicity of the polling-table-by-polling-table cross-check | ★ public after the embargo, without characterizations, labeled "diferencia, no irregularidad" ("difference, not irregularity") · operators only · only aggregates of discrepancies (to be assessed by electoral_counsel) |
| SB-11 | Database and storage at scale | ★ PostgreSQL + self-hosted S3-compatible objects · PostgreSQL + replicated disk · distributed database |
| SB-12 | Job queue at scale | ★ Redis Streams · NATS · PostgreSQL table with `SKIP LOCKED` |
| SB-13 | Human review interface | ★ minimal web app served by the backend · the app itself (reviewer role) · both |
| SB-14 | Order of migration to Rust | ★ blobs/ingestion → aggregator → mirror → OCR (never or via ONNX) · aggregator first · all together |
| SB-15 | Closing time and embargo duration | ★ configurable per election, with default value 18:00 + 3 h **to be verified** · fixed in code |

## 10. Acceptance criteria (measurable)

1. A `capture.example.json` package with its JPEGs sent twice produces **one** resource
   (`201` and then `200`); the same id with another value produces `409`; an altered hash
   produces `422`. Vectors in `contracts/api/vectors/`.
2. No blob is modified or deleted: `sha256sum` over the store matches the
   file names after any sequence of tests.
3. Every `OcrResult` has `origin = "ocr"` and no response from `/tally` or
   `/quick-count/estimate` references values without a `Review` or human confirmation.
4. OCR: SB-3 metric published per engine over 100 % of the confirmed cells of
   `data/ocr-samples`; the baseline is recorded before optimizing.
5. Quick count: with the 2023 AMBA frame and results, the same seed produces
   the same sample in two runs (identical hash); with 5 % of polling tables the stratified
   estimate stays within 2 points of the official 2023 result in most
   seeds (same threshold as amba-simulation, to be measured).
6. Embargo: with a configured closing time, the public `/quick-count/estimate` responds
   `423` within the window and `200` outside it; operator access within the window is recorded in
   the event log.
7. Cross-check: for the 2023 polling tables entered as a test, `Comparison` detects 100 % of
   the differences introduced on purpose and 0 false positives.
8. The event log verifies its hash chain end to end; altering an event
   breaks the verification.
9. Enrollment without personal data: the database schema has no columns for
   name, ID document, phone number, location or party (review by `data_protection_officer`).
10. Contract: the iOS app passes the vectors in `contracts/api/vectors/` against the
    server; the same set is reused for the future Rust implementation.
11. `electoral_counsel` check recorded in `checks/electoral_counsel.md` with no open ⛔,
    or with the author's decision on each ⛔.

## 11. Risks

| Risk | Proposed mitigation |
| --- | --- |
| Official 2027 format (telegram and published data) unknown | Declarative templates and per-version importer; Q1 of telegram-capture assigned to electoral_analyst |
| Insufficient OCR on handwriting | Region-based pipeline + own classifier; OCR never decides; human double entry |
| Coverage bias in the sample (polling tables without a volunteer) | Drawn substitutes, published non-response rate, design estimator separate from the post-stratified one |
| Publishing something within the embargo due to a time misconfiguration | Embargo active by default; explicit and verified closing time; test 6 |
| Enrollment codes that reveal party | Prohibited by design; review by data_protection_officer; codes per campaign/stratum |
| Seizure or leak of raw evidence | Encryption at rest, logged access, no public replica, defined retention |
| Confusing "difference" with "irregularity" in the cross-check | Fixed vocabulary in the API and on screens; electoral_counsel check (SB-10) |
| Single point of failure on election day | Offline queue in the app (nothing is lost), read replicas, tested restore |
| Installing heavy dependencies without consent | Explicit list in 5.3; nothing is installed without the author |

## 12. electoral_counsel check: pending

Legal risks identified by the planner, for the role's analysis (they are not conclusions):

1. **Art. 71 subsec. h (projections)**: confirm the text in force for 2027, what counts
   as "publishing" (operator access with logging? partial aggregates per
   polling table?), reference closing time and scope of the embargo over the polling-table-by-polling-table
   cross-check (SB-10). Fine under art. 128 bis.
2. **Capture by volunteers who are not poll watchers** at sample polling tables (section 2b, item 5):
   if they are neither accredited poll watchers nor civic observers (acompañantes cívicos) (Acordada 128/11), may they
   photograph a posted telegram? Lower-risk alternative: the sample is only
   covered with poll watchers and polling-table officials.
3. **Extraordinary Ruling (Acordada Extraordinaria) 128/11**: a quick count with party poll watchers does not
   qualify as civic observation (acompañamiento cívico); assess how the count is presented publicly
   (who does it, with what legitimacy) and whether another legal figure is needed.
4. **Personal data (Law 25.326)**: the images contain names and signatures; the
   backend keeps them. Legal basis for the processing, registration of the database (art. 21),
   controller, retention and hosting jurisdiction (art. 12). Enrollment
   codes that must not allow inferring political opinion (arts. 2 and 7).
5. **Public cross-check and honor**: publishing discrepancies per polling table may be read as an
   accusation against polling-table officials identifiable by polling table number; define
   vocabulary and level of aggregation (SB-10).
6. **Art. 108 (party oversight of the provisional count)**: parties already have the right to
   oversee data collection and transmission; see whether the quick count is offered
   as a tool equal for all (consistent with neutrality) and what that implies.
7. **Early publication of the sample** (SB-6): risk of pressure on known polling
   tables vs. transparency; *commit-reveal* seeks to balance them; validate.

Expected output: `sdd/specs/scrutiny-backend/checks/electoral_counsel.md` with ⛔/⚠️ and
alternatives ordered by risk; ⛔ items stop implementation until the author decides.
