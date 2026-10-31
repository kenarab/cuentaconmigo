> Automatic English translation of [`sdd/specs/telegram-capture/SPEC.md`](../../../../../sdd/specs/telegram-capture/SPEC.md)
> at commit `7f53fdd`. The Spanish original prevails.

# SPEC · Capture of telegrams and tally sheets (iOS prototype)

Status: **proposal under implementation; author acceptance pending.**
Axis: **D. Election day and vote count (jornada y escrutinio)** of the [vision](../../../../../sdd/specs/vision/SPEC.md), the visible closing of the process.
Date: 31/10/2026. Depends on [mobile-platform](../../../../../sdd/specs/mobile-platform/SPEC.md).

## Problem

When the vote count (escrutinio) closes, party poll watchers (fiscales) and polling-table officials
(autoridades de mesa) need to record a faithful copy of the count telegram (telegrama de escrutinio)
(and/or tally sheet (acta) or count certificate (certificado)) of their polling table (mesa), with
the numbers transcribed and verified, to later cross-check them against the official
results. They do it under pressure, at night and with poor connectivity.

## Prototype scope (P0)

Included:

1. Scan one or more pages with the native scanner (cropping and perspective) or
   import them from Photos (this also allows testing in the simulator).
2. Choose the document type: `telegrama`, `acta` or `certificado`.
3. Identify the polling table: district, section, circuit and polling table number.
4. On-device OCR as an **aid**: it shows the detected numbers to
   copy into the fields; it never fills in or confirms values by itself.
5. Enter the values per row and category according to the form template,
   with the image visible and zoomable.
6. Validate with the template rules and show clear warnings.
7. Confirm the capture: it becomes **locked** (no further edits).
8. Export the evidence package (contract JSON + images) with the system
   share menu.

Outside P0: submission to a central server (D-003), user accounts and roles,
cross-check against official results, automatic extraction by form regions,
geolocation, Android.

## Evidence and chain of custody

- Each page is saved as JPEG **only once** and is never rewritten.
  Its SHA-256 (lowercase hex) and the capture time (ISO-8601 UTC) are recorded.
- The capture package (`contracts/schemas/capture.schema.json`) references the
  pages by file name and hash. Anyone can recompute the hash.
- Values with explicit origin: `manual` (typed) or `ocr-accepted`
  (OCR suggestion accepted by the person). There are never values without human intervention.
- A confirmed capture is not edited. Correcting = a new capture of the same polling table.

## Form and templates

The format in force for 2027 has not been surveyed (see open questions). That is why the
form structure is **declarative** (`contracts/templates/*.json`):
categories (offices), rows (political groupings (agrupaciones) and special votes) and rules.
Author's decision (31/10/2026): the app stops using the fictitious template and no longer
shows fictitious-form warnings. It uses `generales-2023` (President and
Vice President of the general election of 22/10/2023, with the political groupings by number),
consistent with the [AMBA simulation](../amba-simulation/SPEC.md). The rows come from
the DINE per-polling-table results; **they still need to be checked against a real 2023 telegram**.
`balotaje-2015` matches the transcribed samples in `data/ocr-samples/`
(2015 runoff (balotaje); the 2017 PASO primary ones have different lists per district and have no
template). `demo-2027` remains only for the test vectors. Changing the template
does not require changing code.

## Validation rules (contract)

Defined in the template and tested with `contracts/vectors/validation.json`:

| Code | Severity | Rule |
| --- | --- | --- |
| `missing_mesa` | error | District, section, circuit and polling table number are mandatory |
| `missing_value` | error | Every template cell has a value (explicit 0 if applicable) |
| `negative_value` | error | There are no negative values |
| `votantes_exceed_electores` | error | `votantes` (voters who turned out) ≤ `electores` (registered voters) when both are entered |
| `category_total_mismatch` | warning | Sum of each category = `votantes` (rule to be confirmed by electoral_analyst) |

Warnings allow confirming with a written justification; errors do not.

## Digit normalization (contract)

The OCR returns text. `normalizeDigits` converts it to a non-negative integer: it removes
spaces and thousands separators (`.` `,` space), fixes common confusions
(`O/o→0`, `l/I/|→1`, `S→5`, `B→8`) **only** if the token has at least one real
digit, and rejects the rest. Vectors in `contracts/vectors/digits.json`.

## Identifying the polling table with drop-down lists (author's request, 31/10/2026)

**User experience is fundamental** (principle 9 of the [vision](../../../../../sdd/specs/vision/SPEC.md)).
Identifying the polling table must not require typing codes:

- **Cascading drop-down lists:** district → section → circuit → polling place
  → polling table. Each list is filtered by the previous choice and supports text search
  (polling place name, locality or polling table number).
- **Fill in what is already known:** choosing the polling place fills in district,
  section and circuit, and the polling table is chosen from that polling place's range. Typing
  a valid polling table number fills in the rest.
- **Remember** the last polling table and the polling tables of the day's plan ([fiscal-planning](../fiscal-planning/SPEC.md)),
  always inside the phone.
- Works offline: the lists come inside the app, by district.
- Data: `data/establecimientos/nomina-2025.json` (Ministry of the Interior, 2025: 17,292
  polling places with polling table ranges and circuit), copied into the app at build time.
- Initial implementation on iOS (`MesaPicker`): district, section, polling place with
  search and polling table. Choosing the polling table fills in the four codes. The text fields remain
  for corrections. Pending: test it on the iPhone and add it to the prototype (#14).
- On-demand geolocation (see below) is one more shortcut. The lists remain the
  main path.

## Demonstration mode with real sample telegrams (author's request, 31/10/2026)

To try the app without having papers at hand:

- In the Document section, a **"Usar un ejemplo"** (Use a sample) menu lists the official
  telegrams that Andy transcribed (`data/ocr-samples/`: 2015 runoff and 2017 PASO).
  Choosing one, the app adds the image and **fills in by itself** the identification of the
  polling table (district, section, circuit and polling table). The figures are left to be entered or to
  test the OCR. **No synthetic data is used** (author's instruction).
- **Outside Git:** the images contain names, signatures and DNI numbers of real people and the
  repository is public. `scripts/samples/fetch_ocr_samples.py` downloads them from the
  official URLs or from the Internet Archive, verifies the SHA-256 from Andy's manifest,
  converts page 1 to JPEG and leaves them in `ios/CuentaConmigo/Resources/Samples/`,
  a folder ignored by Git. `ios/scripts/install-device.sh` runs it before building.
- The page is recorded with `source: "sample"` (contract), so that it is never confused
  with real evidence.
- **Current limits:**
  - The app uses the `generales-2023` template, while the samples are from 2015
    and 2017: the political grouping rows do not match. Choosing the template according to the
    sample's election is left as an improvement.
  - There are no 2023 telegrams in the sample yet.
  - One of the 15 PDFs (`2017/020600450_00222.pdf`) is not available in the Internet
    Archive.

## Location-based polling place suggestion, on demand (author's request, 31/10/2026)

It comes from the author's first test on his iPhone: identifying the polling place and the
polling table takes time. Proposal:

- On the polling table identification screen, a **"Sugerir mi
  establecimiento"** (Suggest my polling place) button. Only when it is tapped does the app request the location **once**:
  "while using" permission or approximate location. The app never uses location in
  the background nor leaves it enabled. **Policy:** only in specific cases.
- The comparison is done **on the phone**, against the public list of
  polling places of the district included in the app (or downloaded without sending the
  location). The app shows the 3 closest; the person chooses one and completes the polling table.
- **The location is not stored, not sent and does not go into the evidence package.**
  Only the chosen polling place remains in the package, like any other polling table data.
- Without permission or without signal, manual entry stays the same.
- **Dependency:** a public dataset of polling places with coordinates and polling table
  range (question Q1 of [amba-simulation](../amba-simulation/SPEC.md)). If none exists
  with coordinates, it can be derived from the roster of polling places plus geocoding,
  with human review.
- Screen: added to the [app-screens](../app-screens/SPEC.md) prototype before
  implementing it (review-pipeline).
- Pending check: `electoral_counsel` (legal and security). Risk to assess: a
  seized phone must not reveal routes; that is why no history is stored.

## Privacy and security

- Photos may contain names and signatures: they are personal data (Law 25.326 (Ley 25.326)).
  They are stored in the app container with Data Protection `complete`, excluded
  from iCloud backup. Contacts are not requested. Location is only requested on demand
  to suggest the polling place (see above) and is never stored.
- Permissions: camera only (scanner). Importing from Photos uses the picker without broad permission.
- Export is decided by the person; the app sends nothing to the network in P0.

## UX

Simple Rioplatense Spanish, large buttons, dynamic type and VoiceOver.
Flow: Home (captures) → New → Scan/Import → Polling table data → Values
(image on top, fields below) → Validation review → Confirm → Export.

## Legal restrictions (from [docs/legal/MARCO_LEGAL.md](../../../../../docs/legal/MARCO_LEGAL.md))

- **Never photograph the Single Paper Ballot (Boleta Única)** (Electoral Code (Código Electoral)
  art. 71 subsec. g, fine under art. 128).
  The app warns about it before scanning and only accepts telegram, tally sheet or certificate.
- Photographing the certificate or the telegram is not expressly prohibited, but
  it is not explicitly authorized either: it is the priority question for an
  electoral lawyer (L-1).
- The poll watcher has the right to receive the **count certificate (certificado de escrutinio)**
  (art. 102): it is the document we expect to capture most often.
- Do not publish aggregates or projections until three hours after the polls close
  (art. 71 subsec. h). The app publishes nothing; the future backend must respect that window.
- The party a poll watcher represents is a political opinion, that is, sensitive
  data (Law 25.326, arts. 2 and 7). Do not record it without a prior legal decision.

## Acceptance criteria

1. The core's `swift test` passes all vectors in `contracts/vectors`.
2. The example `contracts/examples/capture.example.json` decodes and re-encodes
   losslessly with the core models.
3. The app builds for iOS 17+ without signing (`xcodebuild … CODE_SIGNING_ALLOWED=NO`).
4. On a real iPhone (author): scan, enter, validate, confirm and export a
   capture of the demo template; the exported hash matches `shasum -a 256`.
5. A confirmed capture does not allow editing values.
6. No real or personal data in the repository.

## Open questions

- Q1. Official 2027 format of the telegram, tally sheet and certificate (with the Single Paper
  Ballot (Boleta Única de Papel)). Assign to electoral_analyst with sources and dates.
- Q2. Must the sum per category equal `votantes` or can it be smaller? It affects
  the severity of `category_total_mismatch`.
- Q3. What polling table identification does the form have printed (barcode/QR)?
  It could replace manual entry.
- Q4. Central reception, poll watcher identity and capture anti-fraud (D-003).

## Adjustments from the electoral_counsel check (31/10/2026)

Report: [checks/electoral_counsel.md](../../../../../sdd/specs/telegram-capture/checks/electoral_counsel.md). The non-blocking
mitigations are incorporated as requirements. The ⛔ items are left to the author.

- **No location in the images:** when importing from Photos or scanning, the EXIF/GPS
  metadata is removed **before** computing the hash and storing the page. That way, the
  immutable original no longer contains the location (S1).
- **Export:** before sharing, the app warns that the photos contain names and
  signatures. The publishable copy with covered data is left for F-50 (L4).
- **Authorship:** the hash proves the integrity of the file, not who generated it. Signing
  with the device key comes with SB-8 (S2).
- **Templates:** only templates embedded in the app, or signed if in the future they are
  downloaded (S4).
- L-1 (whether the certificate and telegram may be photographed) remains open for an electoral
  lawyer before any real use.
