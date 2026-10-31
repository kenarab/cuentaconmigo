> Automatic English translation of [`sdd/specs/roadmap/FEATURES.md`](../../../../../sdd/specs/roadmap/FEATURES.md)
> at commit `7452c86`. The Spanish original prevails.

# Candidate features

Date: 31/10/2026. Initial backlog arising from the SPECs. The **proposed priority** is
a recommendation from the design coordinator, **not a decision**. It is decided by the author and
Andy in the prioritization issue (`decision-humana`). Afterwards, the citizen network
will be able to propose new features by consensus ([civic-network](../../../../../sdd/specs/civic-network/SPEC.md)).

Proposed priority: **P0** hackathon · **P1** next version · **P2** later.
Status: ✅ implemented (prototype) · 🟡 partial · 🎨 in screen prototype · 📝 SPEC only · ❓ no SPEC.

## D · Election day and vote count (closing the citizen audit process)

| ID | Feature | SPEC | Depends on | Proposed priority | Status |
| --- | --- | --- | --- | --- | --- |
| F-01 | Scan a telegram, tally sheet (acta) or count certificate (certificado) (native scanner) and import from Photos | telegram-capture | — | P0 | ✅ |
| F-02 | Enter values according to the template and validate (errors and warnings) | telegram-capture | — | P0 | ✅ |
| F-03 | Confirm and lock the capture as evidence (SHA-256 hash and date) | telegram-capture | — | P0 | ✅ |
| F-04 | Export the evidence package with personal-data notice and projection blackout (veda) | telegram-capture, app-screens | AS-11 | P0 | 🟡 |
| F-05 | Guided flow: Single Paper Ballot (Boleta Única) notice → type → polling table (mesa) → scan → data entry | app-screens | AS-1, AS-2 | P0 | 🎨 |
| F-06 | OCR suggestions in the context of each row | app-screens | AS-2 | P1 | 📝 |
| F-07 | Blind double entry (cross-check) | app-screens | AS-5 | P1 | 📝 |
| F-08 | Submission to central reception | mobile-platform, scrutiny-backend | D-003, SB-1 | P1 | 📝 |
| F-09 | Cross-check against the provisional count (escrutinio provisorio) and the final count (escrutinio definitivo) | telegram-capture | F-08, official data | P2 | 📝 |
| F-10 | Geolocated AMBA simulation with projection | amba-simulation | S-1, S-2, S-3 | P0 | 🟡 |
| F-11 | Equivalent native Android app | mobile-platform | D-002 | P1 | 📝 |
| F-12 | Local backend: capture ingestion, server-side OCR, human review and official mirror | scrutiny-backend | SB-1…SB-4 | P0 | 📝 |
| F-13 | Own quick count on a sample of polling tables, ahead of the official one | scrutiny-backend, amba-simulation | SB-5, SB-6, S-3 | P1 | 📝 |
| F-14 | Planning mode for party poll watchers (fiscales) covering several polling tables, with notices of third-party captures | fiscal-planning | FP-1…FP-6 | P1 | 📝 |
| F-15 | Suggest the polling place using location requested on demand (never in the background, without storing it) | telegram-capture, app-screens | polling places dataset (Q1) | P1 | 📝 |
| F-16 | Identify the polling table with cascading drop-down lists and autocomplete (fundamental UX) | telegram-capture, app-screens | roster of polling places (`data/establecimientos/`) | P0 | 🟡 |
| F-17 | Demonstration mode: choose a sample official telegram (Andy's samples, outside Git) that fills in the polling table | telegram-capture | `sample` contract | P0 | 🟡 |

## Citizen network (core product)

| ID | Feature | SPEC | Depends on | Proposed priority | Status |
| --- | --- | --- | --- | --- | --- |
| F-20 | Thematic spaces with transparent ordering (no engagement algorithm) | civic-network | RC-1 | P1 | 📝 |
| F-21 | Structured proposals and deliberation for and against | civic-deliberation | RC-1, DL-1 | P0 (demo) | 📝 |
| F-22 | Consensus measurement and activation of action modalities | civic-network | RC-2 | P1 | 📝 |
| F-23 | Propose app features and decide them by consensus | civic-network | F-21, F-22 | P1 | 📝 |
| F-24 | Institutional accounts for parties on equal terms | civic-network | RC-3 | P2 | 📝 |
| F-25 | Pseudonymous identity and verification that the user is a person | civic-network, participant-protection, trust-chain-identity | RC-5, PP-3, TC-1 | P1 | 📝 |
| F-26 | QR onboarding in trust chains, invitation levels and quotas, containment of malicious subnetworks | trust-chain-identity | TC-1…TC-5 | P1 | 📝 |
| F-27 | Registration of parties with identified officers and onboarding of their poll watchers | trust-chain-identity, civic-network | RC-3, TC-6, TC-7 | P1 | 📝 |

## A · Platforms

| ID | Feature | SPEC | Depends on | Proposed priority | Status |
| --- | --- | --- | --- | --- | --- |
| F-30 | Viral evidence archive (A1) | platform-accountability | P-3 | P0 | 📝 |
| F-31 | Automatic re-check of the public status of each URL | platform-accountability | F-30 | P0 | 📝 |
| F-32 | Public platform dashboard (A4) | platform-accountability | F-30 | P0 (minimal) | 📝 |
| F-33 | AI agents that monitor platform behavior in real time | — | P-1 | P1 | ❓ |
| F-34 | Collective audit of improper electoral advertising (A2) | platform-accountability | P-1 | P1 | 📝 |
| F-35 | Citizen exposure panel, with data donation (A3) | platform-accountability | P-4, PP-* | P2 | 📝 |

## E · Proposals and regulation

| ID | Feature | SPEC | Depends on | Proposed priority | Status |
| --- | --- | --- | --- | --- | --- |
| F-40 | Electoral escrow account published as the first proposal to deliberate | reg-electoral-escrow | F-21 | P0 (demo) | 📝 |
| F-41 | Advocacy document exportable from a proposal with consensus | civic-deliberation | F-22 | P2 | 📝 |

## Cross-cutting · Participant protection

| ID | Feature | SPEC | Depends on | Proposed priority | Status |
| --- | --- | --- | --- | --- | --- |
| F-50 | Preserved evidence vs. publishable copy (data redacted, no EXIF) | participant-protection | PP-6 | P1 | 📝 |
| F-51 | Data inventory and minimal retention | participant-protection | PP-7 | P1 | 📝 |

## Proposed closing of #1 (31/10/2026) · pending the author's acceptance

- **F-P0 = b:** the guided vote count (F-01..F-05, F-16, F-17) and the
  AMBA simulation (F-10) are shown working. The network, identity, governance and the backend are
  presented as vision, with their SPECs (`docs/demo-guion.md`).
- **F-ORD = e:** in parallel. Andy with OCR and samples (#19), Claude with app and backend
  (#17, #18, #26) and the author with the iPhone test and the script (#21).

## Proposed hackathon scope (P0)

Vote-count app with guided flow (F-01 to F-05), AMBA simulation (F-10), a sample
deliberation with the electoral escrow account (F-21, F-40) and a viral evidence
archive with a minimal dashboard (F-30 to F-32).
