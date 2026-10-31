> Automatic English translation of [`contracts/flows/README.md`](../../../../contracts/flows/README.md)
> at commit `8fe408f`. The Spanish original prevails.

# Flows as statecharts (`contracts/flows/`)

Status: **proposal** (decisions AA-2, AA-3, AA-5 and AA-9 of
[app-architecture](../../sdd/specs/app-architecture/SPEC.md) open; work proceeds with the
★ option). The capture flow of [app-screens](../../sdd/specs/app-screens/SPEC.md)
(E-02…E-10) is described only once in `capture.flow.json`; F-1, F-2 and F-3 are
**presentations** of the same machine, not different machines. What no
presentation can do is guaranteed by the machine: skipping the Single Ballot (Boleta Única)
warning, editing after confirming, confirming with errors.

Files:

- `capture.flow.json`: the definition (no code: guards, actions and effects are names).
- `flow-machine.js`: reference interpreter (UMD, no dependencies) with the named guards and
  actions, the validator ported from `Validation.swift`, the digit normalizer and the
  double-entry comparison.
- `run-vectors.js`: runs `vectors/digits.json`, `vectors/validation.json` and
  `vectors/capture-flow.json`. `node contracts/flows/run-vectors.js [--verbose]`.
- `export-prototype.js`: generates in `design/prototypes/flujo/` the files that the
  prototype loads with `file://`: `capture.flow.js` (flow + `generales-2023` template
  as globals), `nomina.sample.js` (subset of `data/establecimientos/nomina-2025.json`:
  all districts and sections, polling places only from CABA Comuna 1 and Avellaneda) and
  a copy of `flow-machine.js`. Do not edit the generated files; regenerate with
  `node contracts/flows/export-prototype.js`.

Each implementation (Swift today, Kotlin later) reimplements the interpreter and must pass
the same vectors. To change a rule: first this contract and its vectors
(skill `contract-change`), then each implementation.

## JSON format

```jsonc
{
  "id": "capture", "version": 1,
  "presentations": { "f1": { "label": "…", "supportsDoubleEntry": false }, … },
  "effects": { "persist": "what the port does", … },   // catalog: valid names
  "context": { … },                                     // initial context
  "initial": "bupWarning",
  "on": { "event": transition },                        // root handlers
  "states": {
    "leaf":      { "screen": "E-02", "on": { … } },
    "compound":  { "initial": "child", "on": { … }, "states": { "child": { … } } }
  }
}
```

A **transition** is `{ "target"?, "guard"?: ["g", "!h"], "actions"?: ["a"], "effects"?: ["e"] }`
or a **list** of candidate transitions for the same event. Without `target` it is
internal: it does not change state, it only runs actions and returns effects.

## Interpreter semantics

1. **Active state = one leaf**, identified by its path `a.b` (for example
   `editing.mesa`). The screen (`screen`) is the leaf's or, if it has none, that of the
   nearest ancestor.
2. **Event lookup from the leaf to the root.** `on[event]` is looked up in the leaf, then
   in each ancestor and finally in the root. Thus `editing.on.setValues` applies in any
   child of `editing` and `on.setPresentation` (root) applies in every state.
3. **Candidates in order; the first one whose guards pass wins.** `guard` is a list of
   names; all must be true; `!name` negates. Guards are evaluated on the
   **previous** context and the event payload. If no candidate passes at a level,
   lookup continues in the ancestor (SCXML semantics).
4. **Without a handler or with failed guards, the event is ignored** without changing state,
   context or producing effects. `send()` reports it with `ignored: true`. There are no
   exceptions or error states: the machine is what makes the forbidden impossible.
5. **Pure actions before effects.** Actions modify a copy of the context
   (no I/O, no clock, no randomness) and are applied in order. **Effects** are only
   names that `send()` returns to the adapter (SwiftUI, Compose, the HTML prototype), which
   runs them afterwards and, if applicable, replies with another event (`scan` →
   `pagesAdded`). The machine never runs effects.
6. **Compound target: entered through `initial`**, recursively, down to a leaf
   (`acceptBup` → `editing` → `editing.documentType`). `target`s are absolute paths.
7. **Static validation** when creating the machine: every `target` exists, every guard and
   action has an implementation, every effect is in the `effects` catalog, every compound
   state has `initial`. If anything fails, the machine is not created.

Reference API (`flow-machine.js`):

```js
const m = FlowMachine.createMachine(flow, template, { presentation: 'f3' });
m.state            // 'bupWarning'
m.screen           // 'E-02'
const r = m.send('acceptBup');      // { state, context, effects, ignored, transition, … }
m.availableEvents()                 // [{ type, source, enabled, needsPayload, targets }]
m.issues()                          // validate(plainValues(context), template)
m.snapshot()                        // { state, context } to persist and restore
```

## `capture` context

| Field | Content |
| --- | --- |
| `presentation` | `f1` / `f2` / `f3` (keys of `presentations`). A phone setting, not a capture setting. |
| `documentType` | one of `template.documentTypes` or `null`. |
| `mesa` | `{ field: text }`. The keys of `template.mesaFields` are the ones validated by the `missing_mesa` rule; others are allowed (for example `establecimiento`, proposed in telegram-capture and pending `contract-change`). |
| `pages` | `[{ id, source?, hash?, … }]` as delivered by the adapter; unique `id`. |
| `header`, `cells` | `{ id: { value, origin } }` and `{ category: { row: { value, origin } } }`. `origin` ∈ `manual`, `ocr-accepted`. A missing value is a gap. |
| `justification` | text from E-09 (≥ 5 characters to confirm with warnings). |
| `second`, `mismatches`, `doubleEntry` | minimal double entry (below). |
| `sample` | `null` or `{ id, label }` when the capture uses a sample telegram (demonstration mode of telegram-capture; `sample: true` in the package is pending `contract-change`). |
| `locked` | `true` from `confirmed` on. No state after `confirming` accepts editing events. |

### Payloads

- `setValues`: `{ header?: { id: v }, cells?: { category: { row: v } } }` with `v` an integer
  (origin `manual`), `null` (clears) or `{ value, origin }`. Keys outside the template,
  non-integer values → event ignored.
- `setMesa`: `{ mesa: { field: text | null } }`.
- `pagesAdded`: `{ pages: [{ id, … }] }`; repeated ids are not duplicated. `removePage`: `{ id }`.
- `useSample`: `{ sample: { id, label?, mesa: {…}, pages: [{ id, … }] } }`; pages are
  stored with `source: "sample"`.
- `chooseDocumentType`: `{ documentType }`. `setJustification`: `{ justification }`.
  `setPresentation`: `{ presentation }`.
- `setSecondValues`: `{ votantes?, totals?: { category: n } }`.
- `edit`, `editMesa`, `editPages` accept `{ path }` so the presentation can focus the
  field; the machine does not use it.

## States and presentations

```
bupWarning ─acceptBup→ editing { documentType → mesa → pages → values } ─review/next→ validation
validation ─proceed→ confirming ─confirm→ confirmed ─export→ exported
validation ─requestDoubleEntry (F-3 only)→ handoff → values2 → compare ─acceptMatch→ validation
```

- **F-1 (wizard):** one leaf per screen; uses the leaves' `next`/`back`. No
  `next` passes without its guard (`documentTypeChosen`, `mesaComplete`, `hasPages`).
- **F-2 (image + fields):** shows the whole `editing` region in a single view; uses only the
  parent's events (`chooseDocumentType`, `setMesa`, `pagesAdded`, `setValues`,
  `review`) in any order. The active leaf stays at `editing.documentType`: for F-2
  it means nothing, and that is why the data lives in the parent.
- **F-3 (double entry):** same as F-2 plus the optional branch; `requestDoubleEntry` requires
  `presentationSupportsDoubleEntry` (declared by `presentations.f3`).
- `confirming` (E-09) is a state of its own: `confirm` only exists there, with two candidates
  (no warnings, or with warnings and justification). `proceed` from E-08 requires `hasPages`,
  `noErrors` and that there is no pending comparison.

## Minimal double entry (AS-5 a, Andy's answer)

The second person **does not see** the first entry or the OCR (guaranteed by the presentation:
in `values2` no image, chips or values are shown) and types only `header.votantes` and
the **total of each category**. `computeMismatches` compares each total with the **sum of
the rows** of the first entry and `votantes` with `votantes`:

```json
[{ "path": "cells.presidente", "first": 300, "second": 310 }]
```

- `submitSecond` requires `secondComplete` (votantes and one total per category, integers ≥ 0).
- In `compare`: `acceptMatch` (only if they match) sets `doubleEntry: "matched"`;
  `fixFirstEntry` (only if they differ) returns to `editing.values` with `doubleEntry: "pending"`;
  `retypeSecond` returns to `handoff` clearing the second entry; `cancelDoubleEntry` exits
  to `validation` without a record.
- With `pending`, `proceed` stays blocked until `compareAgain` (recomputes with the same
  second entry) or `cancelDoubleEntry`.
- Editing the first entry after `matched` goes back to `none` (`invalidateDoubleEntry`).
- Who made each entry is not recorded: the context has no identities.

## Vectors (`vectors/capture-flow.json`)

```jsonc
{ "name": "…", "presentation"?: "f3", "prelude"?: "toValidationClean",
  "events": ["acceptBup", { "type": "setMesa", "payload": {…} }],
  "expectState": "editing.mesa", "expectEffects": ["persist"],   // of the last event
  "expectIgnored"?: true, "expectContext"?: { … } }                // partial match
```

`preludes` are reusable event lists (`{ "prelude": "x" }` inside another list
expands them). Mandatory negative cases: do not skip `bupWarning`, nothing editable after
`confirmed`, `confirm`/`proceed` with errors ignored, second entry without touching the
first. Vector template: `demo-2027` (fictitious).
