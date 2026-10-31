> Automatic English translation of [`sdd/specs/telegram-capture/SPEC.md`](../../../../../sdd/specs/telegram-capture/SPEC.md)
> at commit `ab3d317`. The Spanish original prevails.

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

## Privacy and security

- Photos may contain names and signatures: they are personal data (Law 25.326 (Ley 25.326)).
  They are stored in the app container with Data Protection `complete`, excluded
  from iCloud backup. Location and contacts are not requested.
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
