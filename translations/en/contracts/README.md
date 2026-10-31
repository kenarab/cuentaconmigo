> Automatic English translation of [`contracts/README.md`](../../../contracts/README.md)
> at commit `8fe408f`. The Spanish original prevails.

# Shared contracts

Platform-independent source for iOS, Android and the future backend
(see `sdd/specs/mobile-platform/SPEC.md`). To change a rule: first the contract
and its vectors, then each implementation.

- `schemas/capture.schema.json`: exported capture package (JSON Schema 2020-12).
- `templates/`: declarative forms. `generales-2023` (President, general election
  of 22/10/2023) is the one the app uses; `balotaje-2015` (2015 runoff) matches the
  samples in `data/ocr-samples/`; `demo-2027` is **fictitious** and only used in the vectors.
- `vectors/validation.json`: validation rules; results compared as a set.
- `vectors/digits.json`: normalization of OCR text to integers.
- `flows/capture.flow.json`: capture flow as a declarative statechart, shared by
  the F-1/F-2/F-3 presentations ([app-architecture](../sdd/specs/app-architecture/SPEC.md)).
  Semantics in [`flows/README.md`](flows/README.md), reference interpreter `flows/flow-machine.js`.
- `vectors/capture-flow.json`: expected flow transitions. To run all the
  vectors in JS: `node contracts/flows/run-vectors.js`.
- `examples/`: valid fictitious examples.

Vectors and examples are fictitious. The 2015 and 2023 templates reproduce public
official forms (political groupings (agrupaciones) and rows, with no data about polling
tables (mesas) or people), by decision of the author of 31/10/2026. Never add personal data.
