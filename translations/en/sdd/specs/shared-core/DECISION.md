> Automatic English translation of [`sdd/specs/shared-core/DECISION.md`](../../../../../sdd/specs/shared-core/DECISION.md)
> at commit `0b1514c`. The Spanish original prevails.

# Decision · Remaining duplication in the shared core

Revision `0156dc8` (1/11/2026). Owner's request: have Fable and Astra analyse the Rust
core to remove as much duplication as possible. Reports:
[duplication.astra.md](../../../../../sdd/specs/shared-core/checks/duplication.astra.md) (Astra, gpt-6-astra via Codex) and
[duplication.fable.md](../../../../../sdd/specs/shared-core/checks/duplication.fable.md) (Fable, claude-fable-5-1).
Consolidated by the coordinating Claude session. This is a proposal: nothing is
implemented until the owner decides.

## Where both reviewers agree

| # | Duplication | Observed consequence | Proposal | Effort |
| --- | --- | --- | --- | --- |
| 1 | No app uses `FlowSession`: F-1 steps, enabling Confirm, warnings → justification and "double entry only in F-3" are rewritten in Kotlin and Swift | Flow guards do not apply in the apps; `Capture::confirm` accepts a 1-character justification (the flow requires 5) and does not require an image | Short term: `can_confirm`, `needs_justification`, `supports_double_entry`, `steps` in `CaptureDetail`. Later: a single capture session (flow + capture + storage) | S / L |
| 2 | F-3 double entry written 4 times (Rust, JS, Swift, Kotlin) | Swift and Kotlin count an empty category as 0; Rust and JS as incomplete | `compare_second_entry(id, SecondEntry) -> Comparison` in the core | S |
| 3 | Validation, messages and document-type labels | Different wording; Android hardcodes the 3 types instead of reading the template | Messages from the core (or a catalog in `contracts/`); use `TemplateRecord.document_types` | S |
| 4 | F-1/F-2/F-3 presentations in 3 enums | iOS stores `"F-2"` while the flow expects `"f2"` | `presentations()` from `capture.flow.json` | S |
| 5 | Table format `%05d` and "Mesa N" in every screen | The prototype does not zero-pad | `TableRecord.code/label` and `mesa_for_table` | S |
| 6 | Sample telegrams and template choice | iOS switches to the sample's template and Android does not | `load_samples` + `use_sample` | M |
| 7 | Duplicated server client (Swift) and incomplete readings in Rust | The core drops boxes and masks used by the iOS review; `ocr_numbers` does not tell "pending" from "no numbers" | Full readings, `ocr_status`, `ReceiptRecord`, review corrections in the core | M |
| 8 | Repetition inside `core/` | `header.x`/`cells.c.r` paths parsed by hand in 4 places, default template 3 times, repeated connection | `ValuePath`, `FormTemplate::{contains,label}`, `connected_client()` | S |

Astra only: the Rust interpreter duplicates the prototype's JS (it proposes WASM, an
architecture decision) and there are minor copies in `server/` (digit inference) and the
prototypes. Fable marks no ⛔; Astra marks items 1 and 2 ⛔ against the "shared logic"
goal. No proposal changes the meaning of the contracts.

## Recommendation

1. **Stage A (S, core + Android only):** items 1 short term, 2, 3, 4, 5 and 8, with Rust
   and JVM tests. It also fixes the two diverging rules (5-character justification and
   required image inside `Capture::confirm`), which the flow contract already states.
2. **Stage B (M):** items 6 and 7, so that iOS migrates only once.
3. **Stage C (Mac):** phase 6, iOS on the core.
4. Postpone the single capture session and WASM for the prototypes.

## Questions for the owner

1. Do stage A now and stage B before phase 6?
2. Double entry with an empty category: "incomplete" (like the contract and Rust) or 0
   (like the apps today)? Recommendation: incomplete.
3. App texts: catalog in `contracts/` (also serves the web) or inside the core?
   Recommendation: `contracts/`.
4. WASM so the web prototypes use the same core? Recommendation: later.
