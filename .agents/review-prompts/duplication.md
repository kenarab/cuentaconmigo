Lens: code duplication. Goal (author, 1/11/2026): the same code for every platform, with
as little duplication as possible; a broad internal API lives in the shared Rust core
(`core/`, crate `cc_core`, exposed through UniFFI) and each platform keeps only its screens
and hardware access. Compare `core/` with `android/app/src/main/java/`, `ios/CuentaConmigo/`,
`ios/TelegramaCore/`, `server/` and `design/prototypes/` (JS flow interpreter). List every
piece of logic that is still written more than once (validation, rules, formatting,
labels and user-facing texts, flow decisions, double-entry comparison, polling-place
lookup, server client, storage rules) and every duplication inside `core/` itself. For each
finding give: files and lines, what is duplicated, whether it can move into the core (or
into `contracts/`), the proposed API (function or record signature), effort, and risk.
Order by benefit. Do not propose changes to the contracts' meaning.
