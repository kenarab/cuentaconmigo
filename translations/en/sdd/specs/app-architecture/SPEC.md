> Automatic English translation of [`sdd/specs/app-architecture/SPEC.md`](../../../../../sdd/specs/app-architecture/SPEC.md)
> at commit `6e223ab`. The Spanish original prevails.

# SPEC · App architecture: decoupled core and interchangeable presentations

Status: **proposal (role `planner`, Claude); no decision taken.** Responds to the author's
request (31/10/2026): see Fable's three designs (F-1, F-2, F-3) inside the app,
and keep the design modular and decoupled from the logic in order to migrate to Android and other
interfaces (web, workflows, assistants). Date: 31/10/2026. Acceptance: author.
Depends on [mobile-platform](../../../../../sdd/specs/mobile-platform/SPEC.md) (D-001 taken; D-002 pending),
[app-screens](../app-screens/SPEC.md), [telegram-capture](../telegram-capture/SPEC.md),
[review-pipeline](../../../../../sdd/specs/review-pipeline/SPEC.md). Complements, does not replace, decision D-002.

## 1. Problem

- The author wants to **compare F-1, F-2 and F-3 on the phone**, not only in the HTML, and
  choosing one should not fix the architecture.
- Today the iOS app has **a single data-entry screen** (`CaptureEditorView`, basis of F-2),
  with no selector, no wizard and no double entry. The flow logic (which step comes next, what
  can be skipped, when it gets locked) lives implicitly in the view.
- Android, a review web app ([scrutiny-backend](../scrutiny-backend/SPEC.md) SB-13), the
  planning mode ([fiscal-planning](../fiscal-planning/SPEC.md)) and eventual
  assistants/bots will need **the same flow** without rewriting it each time.

## 2. Current state of the design (facts verified in the repo, 31/10/2026)

| Piece | What exists | What is missing relative to the request |
| --- | --- | --- |
| `design/prototypes/escrutinio/index.html` | Simulated iPhone E-00..E-13 with side panel. **AS-2** selector with two values: `F-2 imagen + campos` (image + fields) and `F-1 asistente por sección` (wizard by section) (only changes E-07: F-1 shows one section per screen). F-3 appears in E-08 as a **disabled** button "Verificar con otra persona (después)" ("Verify with another person (later)"). | There is no navigable F-3; F-1 does not prototype the step-by-step preparation (E-02..E-06 are the same in both); the selector is in the right-hand panel, not in a settings screen of the simulated app. That is why the author "did not find the 3 designs". |
| `design/prototypes/navegacion/index.html` | Comparable N-A / N-B / N-C. | Independent of F-x; no changes needed. |
| `ios/TelegramaCore` | Pure core (`Capture`, `FormTemplate`, `Validator`, `DigitNormalizer`, `EvidenceHash`), no UI, with `ContractTests` that run `contracts/vectors/{validation,digits}.json`. Locking with `private(set)`. | Does not model the **flow** (steps, transitions, guards). |
| `ios/CuentaConmigo` | `HomeView` → `NavigationStack(path: [UUID])` → `CaptureEditorView` (a `Form` with document, polling table (mesa), pages, values, validation, actions). `CaptureStore` = persistence + template. `TextRecognizer` (Vision), `DocumentScanner` (VisionKit), `PageViewer`. | No screens E-02..E-06, E-08, E-09, E-12; no Settings; no F-1/F-2/F-3 selector; the view decides the order of the flow; services coupled to the view (no ports/protocols). |
| `contracts/` | Schema, templates (`generales-2023`, `balotaje-2015`; `demo-2027` only for tests), validation and digit vectors. | No **flow** contract nor transition vectors. |
| `ios/scripts/sync-contracts.sh` | Copies `contracts/templates/generales-2023.json` into the bundle. | Up to date since `a7e84cb`: the app embeds `generales-2023.json` and no longer the fictitious template. |

Pipeline decisions still open that condition this: AS-2 (F-1 vs F-2), AS-5 (F-3 in
P0 or later) and N-A/N-B/N-C (issue #2). This SPEC proposes **not to close them through code**:
the app must be able to show all three until the author and Andy decide.

## 3. Research: proven techniques to separate logic and presentation

Principle common to all sources: **the logic is a pure function `(state, event) →
(state', effects)`; the UI only draws the state and emits events; the effects (camera, OCR,
disk, network) are executed by an adapter outside the core.** It is the "Elm Architecture"
(Model/View/Update) that inspired Redux and, on mobile, MVI, TCA and Crux.

### 3.1 Cross-cutting patterns (apply with any stack)

| Technique | What it brings here | Source |
| --- | --- | --- |
| Unidirectional architecture (Elm/MVI/TCA) | Single state per flow; view without logic; UI-free tests that send events and assert state (`TestStore` in TCA) | [Elm guide](https://guide.elm-lang.org/architecture/), [TCA](https://github.com/pointfreeco/swift-composable-architecture) |
| Effects as data | The core **describes** "scan", "OCR of page 2", "save JPEG" as values; the platform executes them. Allows simulating camera/OCR in tests and in the HTML prototype | [Crux](https://github.com/redbadger/crux): "Side effects such as calling an API are captured as values and executed by the Shell" |
| Declarative statecharts | The flow (steps, guards, parallel states, history) is written as **data** (JSON/SCXML), not as navigation code. Several UIs interpret it; path-coverage tests are generated | [SCXML, W3C Rec. 2015](https://www.w3.org/TR/scxml/); [xstate/graph](https://stately.ai/docs/xstate-graph): `getShortestPaths`/`getSimplePaths` generate one test case per path |
| Contract vectors | Already in use (`contracts/vectors`). Extended to the flow: `events → expected state and effects` | [contracts/README.md](../../../contracts/README.md) |
| Design tokens (DTCG) | Colors, typography and spacing in shared JSON → prototype CSS, generated Swift and Kotlin; same look in all three presentations | [DTCG Format 2025.10](https://www.designtokens.org/TR/2025.10/format/) (current draft Sept. 2026) |
| Server-driven UI | The server sends the screen tree. Useful for frequent releases; **bad idea** for an offline-first flow with evidence. What we already do is "template-driven": the form template is declarative | [Airbnb Ghost Platform](https://medium.com/airbnb-engineering/a-deep-dive-into-airbnbs-server-driven-ui-system-842244c5f5) |

### 3.2 Comparison of stacks for the shared core

Criteria: small team; hackathon now; iOS today, Android later; offline-first; immutable
evidence; the author's long-term liking for Rust.

| Option | How it looks | Pros | Cons | For the hackathon |
| --- | --- | --- | --- | --- |
| **A. Pure Swift + declarative flow + contracts** (no dependencies) | `TelegramaCore` adds a statechart interpreter (~200 lines) and ports as `protocol`. Android reimplements the interpreter in Kotlin against the same JSON and vectors | Zero dependencies; continues D-001 and option A of D-002; what is written today is useful tomorrow (the flow JSON and the vectors are the asset); 100 % native SwiftUI | Interpreter written twice (Swift, Kotlin); divergences only detectable through vectors | ★ Viable: can be done in days |
| **B. Rust core + UniFFI** | Validation, normalization, hash, package and flow machine in one crate; Swift/Kotlin consume generated bindings | A single implementation; "full support for Kotlin, Swift and Python" ([UniFFI](https://mozilla.github.io/uniffi-rs/latest/)); same crate reusable in the Python backend (via bindings) and in a CLI/bot; in production at Firefox and Lyft ([Ferrostar](https://stadiamaps.com/blog/ferrostar-building-a-cross-platform-navigation-sdk-in-rust-part-1/)) | Rust toolchain + `cargo-swift`/NDK in the build; UniFFI "a long way from a 1.0 release"; learning curve for those who do not program in Rust (Andy); does not fit in the hackathon without risk | Not now. Stage 3 if the logic grows |
| **C. Crux (Rust core + thin shells)** | Like B, but with the "effects as data" pattern already solved and generated types for Swift, Kotlin and TypeScript (web shell without rewriting) | Fits the proposed separation exactly; "production-ready" according to its authors; shells in SwiftUI/Compose/React | Pre-1.0 with "occasional breaking changes"; own FFI (BoltFFI), small community; imposes its structure (more opinionated than B) | Not now. Alternative to B in stage 3 |
| **D. Kotlin Multiplatform for the core** | Kotlin core; Swift consumes it via Swift export | Backed by JetBrains/Google; Android uses it natively | Swift export "currently in Alpha… breaking changes are expected" ([kotlinlang](https://kotlinlang.org/docs/native-swift-export.html)); Gradle in the iOS build; does not leverage Rust | Not now. Loses to B if the author prefers Rust |

Discarded by D-001 (native look): Compose Multiplatform on iOS, Flutter, RN.

## 4. Proposed layered architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ PRESENTATION (interchangeable, chosen in Settings)                          │
│  F-1 Wizard  │  F-2 Split view  │  F-3 Double entry  │ (web, bot, CLI)      │
│  Each one: state→screen map + views. No business rules.                     │
├─────────────────────────────────────────────────────────────────────────────┤
│ COMMON VIEWMODEL  (state projection: fields, errors, step, OCR chips)        │
├─────────────────────────────────────────────────────────────────────────────┤
│ FLOW MACHINE  (declarative statechart: contracts/flows/capture.json)        │
│  (state, event) → (state', [effects])   · pure interpreter, no I/O          │
├─────────────────────────────────────────────────────────────────────────────┤
│ DOMAIN CORE  (TelegramaCore today): Capture, FormTemplate, Validator,        │
│  DigitNormalizer, EvidenceHash, export package                               │
├─────────────────────────────────────────────────────────────────────────────┤
│ PORTS (protocols)  Scanner · PhotoImport · OCR · EvidenceStore · Clock ·     │
│                    Settings · Uploader(D-003)                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│ ADAPTERS  iOS: VisionKit, Vision, FileManager+DataProtection, CryptoKit      │
│           Android: ML Kit/CameraX, EncryptedFile, MessageDigest              │
│           Tests/HTML: deterministic fakes (fictitious images and OCR)         │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.1 Domain core

It is `TelegramaCore` as it stands. Current rule: no UIKit/SwiftUI/VisionKit; compliant if
it passes the vectors. Only what the machine needs is added (e.g. comparison of two
entries for F-3: `diff(carga1, carga2) → [celda, v1, v2]`, with vectors).

### 4.2 Capture flow machine (new contract)

Proposed file `contracts/flows/capture.flow.json` (via the `contract-change` skill),
a subset of SCXML expressed in JSON: `states`, `initial`, `on: {evento: {target,
guard, effects}}`, `final`. No code in the JSON: guards are names that the core
implements (`hasPages`, `mesaComplete`, `noErrors`, `warningsJustified`) and effects are
port names (`scan`, `importPhotos`, `ocr(page)`, `persist`, `lock`, `export`).

States (from E-02 to E-11 of app-screens):

```
bupWarning → documentType → mesa → pages → values → validation → confirm → confirmed → exported
                                              │                       ▲
                                              └─(F-3 optional)─ handoff → values2 → compare ─┘
```

- F-1, F-2 and F-3 **are not different machines**: they are presentations of the same one. F-1
  shows one state per screen; F-2 groups `documentType`+`mesa`+`pages`+`values` into
  a split view and the "transitions" are scroll and focus; F-3 activates the branch
  `handoff → values2 → compare` with the event `requestDoubleEntry` (guard:
  `presentationSupportsDoubleEntry`). What no presentation can do: skip
  `bupWarning`, edit after `confirmed`, confirm with errors (guaranteed by the machine,
  not the view).
- Vectors `contracts/vectors/capture-flow.json`: `{name, events:[…], expectState,
  expectEffects:[…]}` plus negative cases (disallowed event → unchanged state). The
  critical paths are written by hand and, if a tool like xstate/graph is adopted
  in the HTML prototype, all simple paths are exported (AA-4).
- The HTML prototype can run **the same JSON** with a ~100-line JS interpreter:
  that way prototype and app share the flow and not just the look.

### 4.3 Ports and adapters

One `protocol` per effect (`DocumentScanning`, `PhotoImporting`, `TextRecognizing`,
`EvidenceStoring`, `SettingsStoring`, `Clock`). `CaptureStore` is split into
`EvidenceStore` (immutable files + `capture.json`) and `TemplateProvider`. Views
never call Vision/VisionKit directly. Fakes in `ios/CuentaConmigoTests`
(fictitious images and OCR) allow running the full flow in `swift test` and in the
simulator without a camera.

### 4.4 Interchangeable presentations

- `enum CapturePresentation: String { case f1Wizard, f2Split, f3DoubleEntry }` stored
  in `SettingsStore` (UserDefaults); selector in **E-12 Settings/About** with the text
  "Diseño de la carga (para comparar en la hackatón)" ("Data-entry design (to compare at the
  hackathon)"). Changing it does not touch the saved captures (the state is the same).
- Each presentation is a `struct` that maps `FlowState → some View` and declares which
  capabilities it uses (`supportsDoubleEntry`). The views receive the `CaptureFlowViewModel`
  and return events; they do not touch `Capture` or `Validator`.
- What the three share (OCR chips, value row, E-00 banner, page viewer,
  56 pt primary button) lives in `Views/Components/`, with tokens from `design/tokens/`.
- If decision AS-2 settles on one, the others are removed without touching core or machine.

### 4.5 Design tokens

The prototypes' CSS `--vars` (colors, `--warn-*`, radii, sizes) move to
`design/tokens/cuentaconmigo.tokens.json` (DTCG format). A script (to be chosen, AA-6)
generates `Tokens.swift`, `Tokens.kt` and `tokens.css`. Until then, the HTML prototype
remains the visual reference (review-pipeline).

## 5. Path to Android and other interfaces

| Target | What it reuses | What it writes |
| --- | --- | --- |
| Android (Kotlin/Compose) | `capture.flow.json`, templates, vectors (flow + validation + digits), tokens, app-screens §6 equivalences | Kotlin interpreter (option A) or bindings (B/C); ML Kit/CameraX/EncryptedFile adapters; Compose views per presentation |
| Human review web app (SB-13) | Same flow JSON (states `values`/`validation`/`confirm`) and tokens | Web shell; no camera: state `pages` is fed from the server |
| Workflows/assistants (chat, voice, verification bot) | The machine is a **conversation protocol**: each state = a question; events = answers | Channel adapter. No graphical UI |
| Python backend (SB-1) | Vectors and schema; if there is a Rust core (B), UniFFI Python bindings to validate packages with the same code | — |
| Planning mode (fiscal-planning) | Same pattern: machine `pendiente → visitada → … → cotejado` (pending → visited → … → cross-checked) as a second declarative flow | — |

## 6. ★ Recommendation by stages (proposal)

**Stage 0 · Prototype (before implementing, mandatory per review-pipeline).** Fable
updates `design/prototypes/escrutinio/index.html`: navigable F-3 (entry 1 → handoff →
blind entry 2 → comparison, no identities), F-1 with real step-by-step preparation,
selector with **three** values also inside screen E-12 of the simulated phone, and
—if AA-3 is accepted— the JS interpreter reading `capture.flow.json`. Astra review (`ux`,
`legal`, `neutrality`) → decision by the author and Andy → only then Swift.

**Status of stage 0 (31/10/2026):** done as a proposal, with the ★ options of AA-2,
AA-3 and AA-5 as provisional. The flow is in `contracts/flows/` (reference JS
interpreter and 79/79 vectors) and the prototype in `design/prototypes/flujo/`
([private link](https://claude.ai/artifact/XKaKVJMsNjDmr91UJZ7rN7)). It includes the
F-1/F-2/F-3 selector in E-12, drop-down lists with the 2025 roster and Andy's official
telegrams as transcribed values. Still missing: visual verification in a browser, the
Astra review (if the author authorizes it) and the author's approval.

**Stage 1 · Hackathon, in Swift, with no new dependencies (option A).**
1. `contracts/flows/capture.flow.json` + `contracts/vectors/capture-flow.json`
   (`contract-change`).
2. `TelegramaCore`: `FlowMachine` (pure interpreter) + `ContractTests.testFlowVectors`.
3. App: ports/adapters; `CaptureFlowViewModel`; F-1 and F-2 presentations complete
   according to the approved prototype; F-3 in its minimal variant (blind re-typing of `votantes`
   and totals per category) if AS-5 enables it, or only the visible `handoff` state.
4. Selector in E-12. Verification: `ios/scripts/verify.sh` + test on the author's iPhone.
Acceptable minimum if time runs short: items 1, 2 and F-2 on top of the machine (no selector),
since the durable asset is the declarative flow with vectors, not the number of designs.

**Stage 2 · Android.** Kotlin interpreter + adapters + Compose against the same
contracts. Equivalence = passes the same vectors and walks the same paths.

**Stage 3 · Shared core, if worthwhile.** Measurable triggers: (a) a rule
diverged between Swift and Kotlin despite the vectors, or (b) the core exceeds ~2,000 lines
per platform, or (c) a third consumer appears (web/bot/backend). Then evaluate
**B (Rust + UniFFI)** as the first option, given the author's preference and because it also
serves Python; C (Crux) if a generated web shell is also wanted. Migration by
modules: normalization and validation → machine → package/hash. The vectors guarantee that
the migration does not change behavior.

## 7. Pending decisions

| ID | Decision | Options (★ = recommended) |
| --- | --- | --- |
| AA-1 | Pattern of the Swift layer | ★ Own unidirectional (machine + `@Observable` ViewModel, no dependencies) · TCA (SPM dependency, `TestStore`) · classic MVVM without machine |
| AA-2 | Where the flow definition lives | ★ `contracts/flows/*.json` interpreted at runtime · hand-written Swift/Kotlin enum (no contract) · standard SCXML XML |
| AA-3 | The HTML prototype runs the same flow JSON | ★ Yes (minimal JS interpreter) · No, stays hand-written |
| AA-4 | Generation of flow vectors | ★ Critical paths by hand + simple paths exported from a tool like xstate/graph (only in the prototype; requires consultation before installing) · by hand only |
| AA-5 | Presentations implemented for the hackathon | ★ F-1 + F-2 complete and minimal F-3 · only F-2 on top of the machine · all three complete |
| AA-6 | Design tokens | ★ DTCG JSON + own generation script (no dependencies) · Style Dictionary (npm dependency) · keep CSS vars and Swift constants by hand |
| AA-7 | Shared core in stage 3 | ★ Rust + UniFFI · Crux · KMP · never (permanent A) |
| AA-8 | The presentation selector stays in production | ★ Only in development/hackathon builds; production fixes the chosen design · always visible as accessibility (e.g. F-1 for large Dynamic Type) |
| AA-9 | Modeling of F-3 | ★ Optional branch of the same machine (`handoff → values2 → compare`) · separate machine · SCXML parallel region |

## 8. Acceptance criteria (measurable)

1. `contracts/flows/capture.flow.json` exists; `swift test` runs `capture-flow.json` with
   ≥ 1 vector per transition and ≥ 1 negative per guard (`bupWarning` not skippable,
   `confirmed` without edits, `confirm` with errors rejected).
2. `TelegramaCore` still has no `import UIKit/SwiftUI/VisionKit` (grep in CI/verify.sh).
3. No view in `ios/CuentaConmigo/Views` imports `Vision`/`VisionKit`/`PhotosUI`
   directly: only the adapters.
4. In Settings one switches between F-1, F-2 and F-3 and the **same** draft capture continues in
   the same machine state (no data loss).
5. The full flow runs in `swift test` with fake adapters (no camera) and produces
   a package that validates against `capture.schema.json`.
6. The approved HTML prototype and the app walk the same sequence of states for the
   same events (manual comparison of ≥ 3 paths, recorded in VERIFICATION.md).
7. No behavior change in the exported package compared to today (same schema,
   same hash) except by contract decision.

## 9. Risks

- **Over-engineering before the hackathon.** Mitigation: minimal stage 1 = JSON + interpreter
  + F-2; the rest is added only with an approved prototype.
- **Three presentations = three times the UI bugs.** Mitigation: shared components
  and rules in the machine; AA-8 limits the selector to development.
- **Declarative flow too rigid for F-2** (where the order is free). Mitigation:
  in F-2 the states `documentType/mesa/pages/values` are modeled as a parallel region or
  as a single `editing` state with guards on exit (decide in AA-9/prototype).
- **Prototype ↔ app drift.** Mitigation: AA-3 (same JSON) and criterion 6.
- **Premature Rust/UniFFI** displaces product time. Mitigation: explicit
  stage 3 triggers.
- **Legal/neutrality.** F-3 tempts one to record who entered the data: the machine has no
  identity field and the contract does not allow it; `electoral_counsel` reviews the F-3 prototype.
- **Personal data.** No changes: photos remain in the protected `EvidenceStore`.

## 10. Sources

- Elm Architecture: <https://guide.elm-lang.org/architecture/>
- The Composable Architecture (Point-Free): <https://github.com/pointfreeco/swift-composable-architecture>
- Crux (Red Badger): <https://redbadger.github.io/crux/> · <https://github.com/redbadger/crux>
- UniFFI (Mozilla): <https://mozilla.github.io/uniffi-rs/latest/> · <https://github.com/mozilla/uniffi-rs>
- Ferrostar, cross-platform Rust SDK (Stadia Maps): <https://stadiamaps.com/blog/ferrostar-building-a-cross-platform-navigation-sdk-in-rust-part-1/>
- Kotlin Swift export (Alpha): <https://kotlinlang.org/docs/native-swift-export.html> · KMP roadmap Aug. 2025: <https://blog.jetbrains.com/kotlin/2025/08/kmp-roadmap-aug-2025/>
- SCXML 1.0, W3C Recommendation (2015): <https://www.w3.org/TR/scxml/>
- XState v5, testing and `xstate/graph`: <https://stately.ai/docs/testing> · <https://stately.ai/docs/xstate-graph>
- Design Tokens Format Module (DTCG): <https://www.designtokens.org/TR/2025.10/format/>
- Server-driven UI, Airbnb Ghost Platform: <https://medium.com/airbnb-engineering/a-deep-dive-into-airbnbs-server-driven-ui-system-842244c5f5>

## Adjustments from the electoral_counsel check (31/10/2026)

Report: [checks/electoral_counsel.md](../../../../../sdd/specs/app-architecture/checks/electoral_counsel.md). The non-blocking
mitigations are incorporated as requirements. The ⛔ items are left to the author.

- **Legal guards in data** (A2): `capture.flow.json` is embedded in the app, or
  signed if it is ever downloaded. The vectors prove that the Single Ballot (Boleta Única)
  warning cannot be skipped and that nothing can be edited after confirming.
- **Third-party channels** (A3): no workflow, bot or assistant sends photos or polling-table
  data through third-party messaging. Those channels only guide the flow; the evidence
  travels through the project's own channel.
- **Handoff in F-3** (A4): handoff mode only shows the blind entry, without
  access to the gallery or to other captures.
