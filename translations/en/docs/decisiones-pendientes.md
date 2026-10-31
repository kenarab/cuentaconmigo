> Automatic English translation of [`docs/decisiones-pendientes.md`](../../../docs/decisiones-pendientes.md)
> at commit `a2007be`. The Spanish original prevails.

# Author's pending decisions · 31/10/2026

Board: [GitHub Project](https://github.com/users/kenarab/projects/2), with Type =
Decision. The hackathon ones are answered in issues #1-#9 (the
[human-in-the-loop](../../../sdd/specs/human-in-the-loop/SPEC.md) pipeline); today's new ones are
in the SPECs with their ★ recommendation.

## To unblock work now

| Decision | What it unblocks | ★ Recommendation | Where |
| --- | --- | --- | --- |
| #1 F-P0, F-ORD | What is shown at 17:45 | b) vote count + AMBA simulation; the network as vision | [#1](https://github.com/kenarab/cuentaconmigo/issues/1) |
| #2 AS-1..AS-12 | Vote-count screens (Andy already answered) | See Andy's comment | [#2](https://github.com/kenarab/cuentaconmigo/issues/2) |
| #3 S-1..S-3 | AMBA simulation (today with provisional ★) | Static web, official polygons, stratified | [#3](https://github.com/kenarab/cuentaconmigo/issues/3) |
| #23 ⛔ legal | Use with real identity and party poll watcher data | TC-11 ★, anonymous FP-3, decide TC-5/TC-12 | [#23](https://github.com/kenarab/cuentaconmigo/issues/23) |
| SB-1, SB-2 + installation permission | Backend and server-side OCR (#18) | Python + FastAPI + SQLite; Tesseract | [scrutiny-backend](../sdd/specs/scrutiny-backend/SPEC.md) |
| AA-2, AA-3, AA-5 | Prototype of 3 designs (#14) and modular app | Flow in `contracts/flows`, same JSON in the prototype, F-1+F-2 complete | [app-architecture](../sdd/specs/app-architecture/SPEC.md) |
| swift-crypto | Core tests on Linux | Linux-only dependency, or you run it with `!` | conversation of 31/10 |

## After the hackathon

| SPEC | IDs | Topic |
| --- | --- | --- |
| [network-governance](../sdd/specs/network-governance/SPEC.md) | NG-1..NG-20 | Tokenless DAO, reputation, rules, collegiate evaluations |
| [trust-chain-identity](../sdd/specs/trust-chain-identity/SPEC.md) | TC-1..TC-15 | QR onboarding, levels, graphs, parties, public profiles |
| [scrutiny-backend](../sdd/specs/scrutiny-backend/SPEC.md) | SB-3..SB-15 | OCR, quick count, embargo, scale |
| [app-architecture](../sdd/specs/app-architecture/SPEC.md) | AA-1, AA-4, AA-6..AA-9 | Swift pattern, tokens, Rust core |
| [fiscal-planning](../sdd/specs/fiscal-planning/SPEC.md) | FP-1..FP-6 | Party poll watcher planning mode |
| [amba-simulation](../sdd/specs/amba-simulation/SPEC.md) | S-1..S-3 | Platform, geography, model |
| [mobile-platform](../../../sdd/specs/mobile-platform/SPEC.md) | D-001..D-003 | Mobile platform and backend |

Disagreements that require the author's judgment: bridging algorithm vs. sensitive data
(NG-5), lottery or election for sensitive roles (NG-10), reputation half-life
(NG-16), public profiles (TC-15/NG-20).

Questions for an electoral lawyer and a security professional: in each
`sdd/specs/*/checks/electoral_counsel.md` and in
[network-governance/deliberation/03-legal-security.md](../../../sdd/specs/network-governance/deliberation/03-legal-security.md).
