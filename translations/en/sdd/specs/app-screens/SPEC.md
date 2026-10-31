> Automatic English translation of [`sdd/specs/app-screens/SPEC.md`](../../../../../sdd/specs/app-screens/SPEC.md)
> at commit `ab3d317`. The Spanish original prevails.

> Translation note: the wireframe blocks keep the original interface copy in
> Rioplatense Spanish, since that is the text users will see; the surrounding
> descriptions are translated.

# SPEC · App screens: citizen network and vote-count flow

Status: **proposal by Fable (role `ux_designer`), reviewed by Astra and prototyped;
awaiting the decision of the author and Andy in issue #2.** Nothing that follows is a
decision: where there is more than one alternative, one is recommended and the choice is left open.
Date: 31/10/2026 · last updated: 31/10/2026.

## Status and how to review the screens

| Pipeline stage | Status | Where |
| --- | --- | --- |
| 1. Proposal (Fable) | ✅ | This document |
| 2. Validation (Astra: spec, ux, legal, neutrality) | ✅ 6 ⛔ and 18 ⚠️ | `checks/*.astra.md` |
| 3. Consolidation | ✅ | [DECISION.md](../../../../../sdd/specs/app-screens/DECISION.md) |
| 1b. Navigable prototype (Fable) with Astra's corrections | ✅ | `design/prototypes/escrutinio/index.html` · [published view (private)](https://claude.ai/artifact/KNrbEwf8hhBJv8bNZgY6gz) |
| 2b. Astra's review of the prototype | ⏳ pending | — |
| 4. Human decision (AS-1 to AS-12) | ⏳ pending | Issue #2 |
| 5. SwiftUI implementation faithful to the approved prototype | ⏳ after the decision | `ios/CuentaConmigo/` |

**To review:** open the published prototype (or the local HTML in a browser). On the
left is the iPhone; on the right, the panel with:

- the list of screens E-00 to E-13 to jump to any of them;
- each screen's design note, the AS-x decisions that affect it and the changes
  Astra requested;
- selectors to compare alternatives: AS-2 (F-1 wizard or F-2 image + fields),
  AS-6 ("Cero" (Zero) button or empty = 0), AS-3 (certificate preselected) and AS-8 (visible OCR origin);
- simulations: offline, camera denied, scanner unavailable and OCR off;
- sample data: values that add up, or with an error, a warning and a missing value.

Each screen has a direct link (`#e-07`, for example). All data is fictitious.
The published view is private: for Andy to see it, share it from the Share menu.

Relationship with other SPECs:

- Vision: [sdd/specs/vision/SPEC.md](../../../../../sdd/specs/vision/SPEC.md) (axes A–E; vote count D closes the process).
- Core product: [civic-network](../../../../../sdd/specs/civic-network/SPEC.md); consensus engine: [civic-deliberation](../../../../../sdd/specs/civic-deliberation/SPEC.md).
- Monitoring tools: [platform-accountability](../../../../../sdd/specs/platform-accountability/SPEC.md).
- Flow detailed by this SPEC: [telegram-capture](../telegram-capture/SPEC.md) (P0 scope and legal restrictions) and [amba-simulation](../amba-simulation/SPEC.md).
- Platform: [mobile-platform](../../../../../sdd/specs/mobile-platform/SPEC.md) (D-001 taken: SwiftUI first, equivalent native Android; D-002 pending).
- Legal framework: [docs/legal/MARCO_LEGAL.md](../../../../../docs/legal/MARCO_LEGAL.md), sections 3 and 6.
- Visual identity: [design/icon/README.md](../../../../../design/icon/README.md) and [design/cover/cover.svg](../../../../../design/cover/cover.svg).

Convention of this document: **[P0]** goes into the vote-count prototype that
starts now; **[después]** (later) is left for a later phase; **[boceto]** (sketch) is just
a screen idea without detail. All interface text is in Rioplatense Spanish.

---

## 1. Why a screens SPEC

The app is a single story: a citizen network that deliberates for months and that,
on election day, closes its audit with party poll watchers (fiscales) and polling-table officials
(autoridades de mesa) scanning the telegram, the tally sheet (acta) or the count certificate
(certificado) of their polling table (mesa). The prototype that
starts now covers only that closing, but it is worth designing it knowing where it will
live later, so as not to have to redo the navigation when the network arrives.

This SPEC proposes: (1) the complete navigation map, (2) alternatives for the
global architecture, (3) alternatives for the vote-count flow with wireframes,
(4) the detailed inventory of the screens of the recommended flow, (5) their
Android equivalents and (6) sketches of the network's future screens.

---

## 2. Navigation map of the complete app

```
CuentaConmigo
├── Network [later]
│   ├── Thematic spaces (Platforms · Disinformation · Campaign · Election day · Vote count · Regulation)
│   │   └── Space feed (transparent ordering, no engagement algorithm)
│   ├── Proposals (ideas → structured proposals)
│   │   ├── New proposal (mandatory template)
│   │   └── Detail: deliberation for / against · amendments · versions
│   ├── Consensus (status of each initiative, published thresholds, cross-cutting consensus)
│   │   └── Action modalities (open catalog; visible legal check)
│   └── Parties (institutional accounts, all with the same card and the same permissions)
├── Tools [later]
│   ├── Viral evidence archive (A1)
│   ├── Public platform dashboard (A4)
│   ├── Monitoring agents (status, methodology, aggregated data)
│   └── AMBA simulation (link to the static web; "SIMULACIÓN" always visible)
├── Vote count (Escrutinio) [P0]  ← focus of the prototype
│   ├── My captures (list)
│   ├── New capture (flow of section 4)
│   │   ├── Before starting: Single Paper Ballot (Boleta Única) warning
│   │   ├── Document type
│   │   ├── Polling table data
│   │   ├── Page capture (scanner / import)
│   │   ├── Captured pages (zoom, add, remove)
│   │   ├── Value entry (image + fields + OCR as an aid)
│   │   ├── Validation
│   │   └── Confirm and lock
│   ├── Confirmed capture (detail · export · submission pending)
│   └── Export queue / pending submissions
└── Profile / Settings
    ├── [P0] About · template in use (with warning if fictitious) · version · legal
    └── [later] Account, person verification (RC-5), moderation, notifications
```

What goes into the vote-count prototype: the whole **Vote count** branch and a minimal
**About**. Not included: accounts, submission to a server (D-003), cross-check against
official results, network, tools, Android.

---

## 3. Global navigation architecture: alternatives

### N-A. One app with a tab bar and the network in the center

```
┌──────────────────────────────────────┐
│  (contenido de la pestaña activa)    │
│                                      │
├──────────────────────────────────────┤
│ Espacios  Propuestas  ●Red  Herram.  Yo │
└──────────────────────────────────────┘
```

Five tabs; the network (home: activity of the spaces and ongoing consensus processes)
in the center. The vote count lives inside **Tools** as one more
tool, like the evidence archive or the agents.

- Pros: a single identity and a single install; the vote count is presented
  as what it is in the vision (an action modality of the network); the Tools
  tab grows without changing the structure.
- Cons: on election day, a poll watcher with low battery and poor signal has
  to find the vote count two taps deep; today's prototype has no
  network, so four of the five tabs would be empty for months; the
  tab bar competes for vertical space during value entry.

### N-B. Separate vote-count app

Two apps: "CuentaConmigo" (network) and "CuentaConmigo Escrutinio" (the current
prototype, as is). The vote-count app opens directly on "Mis capturas" (My captures).

- Pros: it is what already exists; zero friction on election day; it can be distributed to
  poll watchers of any political force without asking them to join the network (consistent with
  option 1 of V-4); smaller app-store review surface.
- Cons: two brands and two installs; the vote count is disconnected from
  the story ("closing of the audit process"); duplication of profile, settings
  and evidence; two apps on two platforms have to be maintained.

### N-C. One app with an "election day mode"

The app is the network (tab bar as in N-A). On election day, or when the person
activates it by hand in Settings, the home screen becomes **Vote count** in
full screen, with the network reachable from a "Volver a la red" ("Back to the network") button. Outside
that mode, the vote count remains available in Tools. The mode is local
(it does not depend on a server) and can always be activated, to practice.

```
 modo normal                      modo jornada electoral
┌──────────────────┐              ┌──────────────────────┐
│ Red / Espacios   │   día D o    │ ▣ Escrutinio         │
│ ...              │  activación  │ Mis capturas         │
│                  │  manual  ─▶  │ [ Nueva captura ]    │
├──────────────────┤              │                      │
│ ⌂  ✎  ●  ⚒  ☺   │              │ ← Volver a la red    │
└──────────────────┘              └──────────────────────┘
```

- Pros: a single app and a single identity; on election day the vote count is the first thing
  one sees, with no tab bar; the current prototype **is** election day mode, so what
  is built now is not thrown away; it respects the electoral blackout (veda) (in that mode no
  feeds or partisan content are shown, to be defined with `electoral_counsel`).
- Cons: two "states" of the same app that have to be explained; the date-based
  trigger depends on the official calendar (still open); it must be decided what happens with
  network notifications during the mode.

### Recommendation (proposal)

**N-C**, built in two stages: today the prototype is implemented as the
root screen of "election day mode" (which is in fact N-B while the network
does not exist); when the network arrives, that root becomes the mode and the tab bar the
normal state. Condition: the vote-count flow must **not** assume a tab bar
(full screen, primary button at the bottom) nor depend on an account.

Risk to validate with `electoral_counsel`: if the same app combines a network with partisan
accounts and capture of polling-table documents, the reading of
Acordada 128/11 (National Electoral Chamber ruling) and of the blackout (section 3 of the legal framework)
must be reviewed before deciding N-A/N-C.

---

## 4. Vote-count flow: alternatives

Context of use that conditions everything: **at night, under pressure, low light, poor
connectivity, possibly a low-end phone, with a tired hand after
counting ballots**. The person has already received a certificate (or is going to photograph the
telegram before handing it over to the Post Office (Correo)). The goal is a faithful copy with a hash and
verified numbers; nothing more.

### F-1. Step-by-step wizard

One question per screen, "Paso n de 7" (Step n of 7) indicator, large "Continuar" (Continue) button.

```
┌────────────────────────────┐ ┌────────────────────────────┐ ┌────────────────────────────┐
│ ← Paso 1 de 7              │ │ ← Paso 2 de 7              │ │ ← Paso 3 de 7              │
│                            │ │                            │ │                            │
│   ✋ Antes de empezar       │ │  ¿Qué documento vas a      │ │  Datos de la mesa          │
│                            │ │  escanear?                 │ │                            │
│  Nunca fotografíes la      │ │                            │ │  Distrito   [________]     │
│  Boleta Única: está        │ │  ( ) Certificado de        │ │  Sección    [________]     │
│  prohibido (art. 71 g).    │ │      escrutinio            │ │  Circuito   [________]     │
│                            │ │  ( ) Telegrama             │ │  Mesa       [________]     │
│  Sí podés escanear:        │ │  ( ) Acta                  │ │                            │
│  certificado, telegrama,   │ │                            │ │                            │
│  acta.                     │ │                            │ │                            │
│                            │ │                            │ │                            │
│ [ Entendido, continuar ]   │ │ [ Continuar ]              │ │ [ Continuar ]              │
└────────────────────────────┘ └────────────────────────────┘ └────────────────────────────┘
┌────────────────────────────┐ ┌────────────────────────────┐ ┌────────────────────────────┐
│ ← Paso 4 de 7              │ │ ← Paso 5 de 7              │ │ ← Paso 6 de 7              │
│  Escaneá el documento      │ │  Presidente y Vice  (1/2)  │ │  Validación                │
│                            │ │ ┌────────────────────────┐ │ │                            │
│ ┌────────────────────────┐ │ │ │  imagen (zoom)         │ │ │  ✗ Falta el valor de       │
│ │                        │ │ │ └────────────────────────┘ │ │    Diputados: Lista C      │
│ │  (escáner nativo)      │ │ │  Lista A (ficticia) [ 123] │ │  ⚠ Presidente: la suma no  │
│ │                        │ │ │  Lista B (ficticia) [  98] │ │    coincide con votantes   │
│ └────────────────────────┘ │ │  Lista C (ficticia) [    ] │ │                            │
│  Páginas: ▢ ▢  + agregar   │ │  En blanco          [   4] │ │  [ Ir al primer error ]    │
│                            │ │  ...                       │ │                            │
│ [ Importar de Fotos ]      │ │  OCR: [123] [98] [4] [225] │ │                            │
│ [ Continuar ]              │ │ [ Siguiente categoría ]    │ │ [ Confirmar ] (deshab.)    │
└────────────────────────────┘ └────────────────────────────┘ └────────────────────────────┘
```

- Pros: impossible to skip the Single Paper Ballot warning; each screen fits with
  large Dynamic Type; clear order for someone who uses the app only once in their life;
  VoiceOver goes through one task at a time.
- Cons: many taps under pressure (7 steps × categories); going back to
  fix a polling table field is tedious; the image becomes small or is lost when moving
  between categories; on low-end phones each transition is costly.
- Risks: pressure (high: too many steps); low light (neutral, the native scanner
  handles it); connectivity (neutral, everything local); low-end (medium); VoiceOver
  (low); Dynamic Type (low).

### F-2. Split view: image on top, fields below, tap-to-copy from OCR

It is the basis of the current prototype (`CaptureEditorView`), improved: the image stays
fixed on top (zoomable, draggable), the fields below in a list with
sections, and the numbers the OCR detected appear as chips above the keyboard:
one taps a field and then a chip to copy the number.

```
┌────────────────────────────┐ ┌────────────────────────────┐
│ ← Mesa 0421        Acta ▾  │ │ ← Mesa 0421        Acta ▾  │
│ ┌────────────────────────┐ │ │ ┌────────────────────────┐ │
│ │   [imagen · pág 1/2]   │ │ │ │ (imagen ampliada 3x,   │ │
│ │   pellizcar = zoom     │ │ │ │  arrastrada a la fila   │ │
│ │   ⤢ pantalla completa  │ │ │ │  "Lista B")             │ │
│ └────────────────────────┘ │ │ └────────────────────────┘ │
│ ─── Totales de la mesa ─── │ │ ─── Presidente y Vice ──── │
│ Electores        [   350 ] │ │ Lista A (ficticia) [ 123 ] │
│ Total votantes   [   225 ] │ │ Lista B (ficticia) [▮    ] │
│ ─── Presidente y Vice ──── │ │ Lista C (ficticia) [     ] │
│ Lista A (ficticia) [ 123 ] │ ├────────────────────────────┤
│ Lista B (ficticia) [     ] │ │ Detectados: [98] [4] [225] │
│ ...                        │ │  1    2    3    ⌫          │
│ ⚠ 1 aviso · ✗ 2 errores    │ │  4    5    6    Siguiente  │
│ [ Confirmar captura ]      │ │  7    8    9    (teclado)  │
└────────────────────────────┘ └────────────────────────────┘
```

- Pros: everything in view, fewer taps; the person compares number by number with
  the image without changing screens; OCR speeds things up without deciding (traceable
  `ocr-accepted` origin); it already exists in the prototype.
- Cons: on small screens or with large Dynamic Type the image and the list
  fight for space; it is easy to forget the Single Paper Ballot warning if it stays as
  just another text in the form (that happens today); a lot of information for VoiceOver on
  a single screen; on low-end phones zooming a large photo can stutter.
- Risks: pressure (low); low light (neutral); connectivity (neutral); low-end
  (medium: watch the size of the displayed image); VoiceOver (medium: elements
  need ordering and "go to fields"/"go to image" shortcuts);
  Dynamic Type (medium-high: the fixed image shrinks; provide a "fields only" mode).

### F-3. Blind double entry / cross-verification between two people

Two people (for example, a poll watcher and a polling-table official, or two poll watchers from different
forces) enter the same values without seeing each other's entry. The app compares and
only asks to resolve the differences by looking at the image. Minimal variant: a single
person re-types only the critical totals without seeing what they entered.

```
┌────────────────────────────┐ ┌────────────────────────────┐ ┌────────────────────────────┐
│ Carga 1 de 2               │ │ Pasale el teléfono a       │ │ Comparación                │
│ (igual a F-2)              │ │ la otra persona            │ │                            │
│                            │ │                            │ │ Coinciden 11 de 14 valores │
│ ...                        │ │ La segunda carga se hace   │ │                            │
│                            │ │ sin ver la primera.        │ │ Presidente · Lista B       │
│                            │ │ No se guardan nombres.     │ │   carga 1: 98  carga 2: 89 │
│                            │ │                            │ │   [ver imagen] ( 98 ) ( 89 )│
│                            │ │ [ Empezar carga 2 ]        │ │ Diputados · En blanco      │
│                            │ │ [ Saltear: carga simple ]  │ │   carga 1: 4   carga 2: 14 │
│ [ Listo, carga 1 ]         │ │                            │ │   [ver imagen] (  4 ) ( 14 )│
└────────────────────────────┘ └────────────────────────────┘ └────────────────────────────┘
```

- Pros: the best transcription quality (human error is detected by
  discrepancy, not by rule); the evidence package can carry `verification:
  double-entry`; it reinforces neutrality if the two people are from different
  forces.
- Cons: doubles the time at the worst moment of the night; requires two people
  available (not always the case); "blind" has to be designed for real (the
  second person must not be able to see either the OCR or entry 1); temptation to
  record who each person was (sensitive data: no).
- Risks: pressure (high); low light (neutral); connectivity (neutral); low-end
  (low); VoiceOver (medium); Dynamic Type (low).

### Recommendation (proposal)

**Hybrid: short preparation wizard (F-1) + split-view editor (F-2),
with F-3 as an optional "second verification" [later].**

- Step-by-step preparation (Single Paper Ballot warning → type → polling table → scan → pages):
  these are decisions made once and that must not be skippable. Four
  short screens, not seven.
- Value entry on a single split screen (F-2), with OCR as chips, a
  "ampliar imagen" (enlarge image) full-screen button and a "fields only" mode when Dynamic Type
  is large or the screen is small.
- Validation and confirmation as explicit final steps (locking with double
  confirmation).
- F-3 is left as an optional variant from the validation screen ("Verificar
  con otra persona" (Verify with another person)), outside P0, without recording identities.

Reason: it minimizes taps where there is pressure (data entry) and does not allow skipping what is
legally sensitive (the warning) or what is structural (type and polling table). It matches
the UX flow of telegram-capture and reuses almost all of the prototype.

---

## 5. Screens of the recommended flow (detailed inventory)

Criteria common to all screens [P0]:

- Minimum touch target 44×44 pt; primary button at the bottom, full width, 56 pt.
- Dynamic Type up to "AX5" without truncating or overlapping; lists reflow into
  one column; never text in images.
- VoiceOver: every image with a label; every field with label and value; state
  changes (error, confirmed) are announced; explicit reading order.
- Minimum AA contrast; errors not only by color (icon + text); dark mode
  supported (election night is used in the dark).
- Offline by default: nothing the person does needs a network. If a future
  action needed a network, it is queued (E-11) and this is stated clearly.
- Language: simple Rioplatense Spanish, voseo, no technical jargon ("hash" appears only as
  "huella digital (SHA-256)" (digital fingerprint) on the detail screen).
- A confirmed capture is **never** edited or deleted from the app; correcting =
  a new capture of the same polling table (offered as an action).
- No personal data: name, national ID (DNI), party or location are not requested. Photos
  may contain them: they are stored protected and not shown outside the app.

### E-00. Fictitious template warning (cross-cutting component) [P0]

> Author's decision (31/10/2026): the app uses templates from real elections
> (`generales-2023`), so the warning is not shown. The component remains only for
> templates with `fictitious = true`. Resolves AS-7.

- Purpose: that nobody enters real data with a template that is not the
  official form. Shown while `template.fictitious == true`.
- Content: fixed yellow strip above E-01, E-07 and E-10: "Prototipo con un
  formulario ficticio (Lista A/B/C). No cargues datos reales todavía." ("Prototype with a
  fictitious form (List A/B/C). Do not enter real data yet."). Fictitious
  rows carry "(ficticia)" in their label (already in `demo-2027.json`).
- Actions: tapping leads to E-12 (About), which explains which template is in
  use and its version.
- States: none; it cannot be dismissed.
- Accessibility: "alert" role, read first on the screen.
- Acceptance: with the `demo-2027` template, the warning appears on E-01, E-07 and E-10
  and the exported package carries `template.id = demo-2027` and `fictitious = true`;
  with a non-fictitious template, it does not appear.

### E-01. My captures [P0]

```
┌────────────────────────────┐
│ ⚠ Prototipo con formulario │
│   ficticio. Sin datos reales│
│ Escrutinio            ⓘ    │
│                            │
│ Mesa 0421 · Certificado    │
│ 🔒 Confirmada · 2 pág.     │
│ Mesa 0421 · Telegrama      │
│ ✎ Borrador · 1 pág.        │
│                            │
│ (vacío:) Todavía no hay    │
│ capturas. Tocá "Nueva      │
│ captura" al terminar el    │
│ escrutinio de tu mesa.     │
│                            │
│ [ ▣ Nueva captura ]        │
└────────────────────────────┘
```

- Purpose: entry point; see the status of each capture and start a new one.
- Content: E-00 if applicable; list of captures (polling table, type, status
  Draft/Confirmed/Exported/Submission pending, number of pages, time);
  primary button fixed at the bottom.
- Actions: New capture → E-02; tapping a draft → resumes at the step where it
  was left; tapping a confirmed one → E-10; swipe to delete drafts only (with
  confirmation); ⓘ → E-12.
- States: empty (text above); storage error ("No se pudo leer el
  almacenamiento. Reiniciá la app; tus capturas no se borraron." — "Storage could not be read.
  Restart the app; your captures were not deleted."); offline: no
  changes (it is local).
- Accessibility: each row is a single element with a composite label ("Mesa 0421,
  certificado, confirmada, 2 páginas"); the primary button is the last element.
- Acceptance: a confirmed capture does not offer deletion; the order is by creation
  date descending; with VoiceOver one can create a capture and return to the
  list without touching the screen.

### E-02. Before starting: Single Paper Ballot warning [P0]

```
┌────────────────────────────┐
│ ✕                          │
│                            │
│        ✋ (grande)          │
│  Nunca fotografíes la      │
│  Boleta Única              │
│                            │
│  Está prohibido durante    │
│  los comicios (Código      │
│  Electoral, art. 71 inc. g)│
│                            │
│  Sí podés escanear:        │
│  ✓ Certificado de          │
│    escrutinio (te lo       │
│    entrega el presidente)  │
│  ✓ Telegrama               │
│  ✓ Acta                    │
│                            │
│ [ Entendido, continuar ]   │
└────────────────────────────┘
```

- Purpose: comply with the legal restriction before opening the camera; it is the first
  screen of every new capture, always (no "don't show again").
- Content: fixed text, no options. "Más información" (More information) link → E-12 (legal).
- Actions: Entendido (Understood) → E-03; ✕ → discards the draft and returns to E-01.
- States: none.
- Accessibility: the title is announced on appearance; the button is the last element;
  the icon is decorative.
- Acceptance: there is no path to the camera that does not go through this screen; the
  draft records `bupWarningAcknowledgedAt` (time, no identity) in the
  package (field proposal for `contract-change`, to be validated).

### E-03. Document type [P0]

```
┌────────────────────────────┐
│ ← Nueva captura   Paso 1/4 │
│                            │
│ ¿Qué documento vas a       │
│ escanear?                  │
│                            │
│ ┌────────────────────────┐ │
│ │ ● Certificado de       │ │
│ │   escrutinio           │ │
│ │   El que te entregan a │ │
│ │   vos como fiscal.     │ │
│ ├────────────────────────┤ │
│ │ ○ Telegrama            │ │
│ │   Antes de entregarlo  │ │
│ │   al Correo.           │ │
│ ├────────────────────────┤ │
│ │ ○ Acta de escrutinio   │ │
│ │   Sin manipular el     │ │
│ │   original.            │ │
│ └────────────────────────┘ │
│ [ Continuar ]              │
└────────────────────────────┘
```

- Purpose: choose one of the types accepted by the template; steer towards
  the certificate, which is the poll watcher's own document (legal framework 3.1).
- Content: options from `template.documentTypes` with one help line each.
  Preselected: certificate (proposal; validate with `electoral_analyst`).
- Actions: Continue → E-04; ← returns to E-02.
- States: none.
- Accessibility: radio group with full labels, not just the title.
- Acceptance: the value is stored in the package's `documentType` and can be changed
  until confirmation.

### E-04. Polling table data [P0]

```
┌────────────────────────────┐
│ ← Certificado     Paso 2/4 │
│                            │
│ Datos de la mesa           │
│ Los encontrás en el        │
│ encabezado del documento.  │
│                            │
│ Distrito   [ 02         ]  │
│ Sección    [ 03         ]  │
│ Circuito   [ 0012       ]  │
│ Mesa       [ 0421       ]  │
│                            │
│ (futuro) [ ▦ Leer código   │
│   del documento ]          │
│                            │
│ [ Continuar ]              │
└────────────────────────────┘
```

- Purpose: identify the polling table; without this the later cross-check is impossible.
- Content: fields from `template.mesaFields`; numeric/alphanumeric keyboard depending on
  the field; future barcode/QR reading button (Q3, [later]).
- Actions: Continue → E-05; one can proceed with empty fields (they are flagged in E-08
  as `missing_mesa`), because sometimes it is better to scan first and complete later.
- States: format error (only if the template defines one); nothing network-related.
- Accessibility: visible labels, not just placeholders; "Siguiente" (Next) on the
  keyboard goes through the four fields.
- Acceptance: the four values travel in the package's `mesa.*`; empty ones produce
  `missing_mesa` in E-08.

### E-05. Page capture [P0]

```
┌────────────────────────────┐
│ ← Mesa 0421       Paso 3/4 │
│                            │
│ Escaneá todas las páginas  │
│ del certificado.           │
│                            │
│ ┌────────┐ ┌────────┐      │
│ │ pág 1  │ │   +    │      │
│ │ (mini) │ │ agregar│      │
│ └────────┘ └────────┘      │
│                            │
│ Consejos: apoyá el         │
│ documento sobre la mesa,   │
│ acercá la linterna si hay  │
│ poca luz.                  │
│                            │
│ [ 📷 Escanear ]            │
│ [ Importar de Fotos ]      │
│ [ Continuar ]  (si ≥1 pág) │
└────────────────────────────┘
```

- Purpose: obtain one or more faithful images (native scanner with cropping and
  perspective) or import them from Photos (testing in the simulator).
- Content: thumbnails of already saved pages; low-light tips; buttons.
  The native scanner offers a flashlight; if it is unavailable (simulator), import only.
- Actions: Scan → native camera (several pages per session) → returns with the
  pages added; Import → picker without broad permission; Continue → E-06;
  tapping a thumbnail → E-06.
- States: camera permission denied ("Sin cámara no se puede escanear. Podés
  habilitarla en Ajustes o importar de Fotos." — "Without a camera you cannot scan. You can
  enable it in Settings or import from Photos." — with a button to Settings); save error
  ("No se pudo guardar la imagen. Hay poco espacio?" — "The image could not be saved. Low on
  space?"); scanner unavailable (import only).
- Accessibility: thumbnails with "Página 1 de 2, escaneada 20:47"; the native
  scanner is already accessible; avoid depending on pinch gestures on this screen.
- Acceptance: each page is saved as JPEG only once with SHA-256 and UTC
  time; pages can be added until confirmation; on a real iPhone capturing
  two pages in a single scanner session produces two entries.

### E-06. Captured pages [P0]

```
┌────────────────────────────┐
│ ← Páginas (2)              │
│ ┌────────────────────────┐ │
│ │                        │ │
│ │   imagen pág 1         │ │
│ │   (pellizcar = zoom)   │ │
│ │                        │ │
│ └────────────────────────┘ │
│ ◀ 1 / 2 ▶                  │
│ Escaneada 20:47 · SHA-256  │
│ 3f9a…c21e                  │
│                            │
│ [ Quitar esta página ]     │
│   (sólo en borrador)       │
│ [ Agregar otra página ]    │
│ [ Continuar a la carga ]   │
└────────────────────────────┘
```

- Purpose: check that the image is readable (legible numbers, no fingers or
  cropping), reorder or remove before entering data. **The image is not edited**
  (legal framework, section 6: do not "correct" or recompose documents).
- Content: viewer with zoom and pagination; time and abbreviated hash; actions.
- Actions: Remove (draft only, confirms: "Se elimina la imagen y su hash." — "The image and its
  hash are deleted."); Add → E-05; Continue → E-07; it is re-entered from E-07 with "Ampliar" (Enlarge).
- States: illegible image (no automatic detection in P0; the person is trusted);
  missing file ("No se encontró la imagen; volvé a escanear." — "Image not found; scan again.").
- Accessibility: pagination controls as buttons; zoom also with "+"/"−"
  buttons and double tap; label "Imagen del certificado, página 1 de 2".
- Acceptance: removing a page in a draft deletes its file and its entry; a
  confirmed capture does not show "Quitar" (Remove) or "Agregar" (Add).

### E-07. Value entry (split view + OCR as an aid) [P0]

```
┌────────────────────────────┐
│ ← Mesa 0421       Paso 4/4 │
│ ┌────────────────────────┐ │
│ │ imagen pág 1 · ⤢ ampliar│ │
│ │ (fija, zoom, arrastre) │ │
│ └────────────────────────┘ │
│ ⚠ Prototipo: formulario    │
│   ficticio                 │
│ ─ Totales de la mesa ───── │
│ Electores habilit. [ 350 ] │
│ Total de votantes  [ 225 ] │
│ ─ Presidente y Vice ────── │
│ Lista A (ficticia) [ 123 ] │
│ Lista B (ficticia) [▮    ] │
│ Lista C (ficticia) [     ] │
│ Votos en blanco    [     ] │
│ ─────────────────────────  │
│ Detectados: [98] [4] [225] │
│ (teclado numérico)         │
│ ✗ 6 faltan · [ Validar ]   │
└────────────────────────────┘
```

- Purpose: transcribe each template cell while looking at the image, with OCR
  as a suggestion that is never applied by itself.
- Content: fixed image on top (30–40 % of the height; collapsible to a strip with
  "Mostrar imagen" (Show image) when the keyboard is open or with large Dynamic Type);
  list of fields: `headerFields` and then one section per category with all its
  `rows`; "Detectados" (Detected) chips above the keyboard with the OCR numbers from the
  visible page (deduplicated, in order of appearance); missing-values counter.
- Actions: tapping a field → numeric keyboard; tapping a chip → copies the number into the
  focused field with origin `ocr-accepted`; typing → origin `manual`; "Siguiente" (Next) moves to the
  next empty field; explicit "0" with a "Cero" (Zero) button next to the chips
  (avoids the most frequent error: leaving empty what is worth zero); ⤢ → E-06;
  Validar (Validate) → E-08.
- States: no OCR available (the chip strip is hidden, no error);
  processing OCR (brief "Leyendo números…" (Reading numbers…) indicator without blocking entry);
  field edited after accepting OCR → reverts to `manual`; confirmed capture →
  everything disabled with a padlock.
- Accessibility: VoiceOver quick actions "Ir a la imagen" / "Ir a los campos" (Go to image / Go to fields);
  each field announces "Lista A, ficticia, Presidente y Vicepresidente, vacío";
  chips announce "Copiar 98 al campo Lista B"; the image has a label and does not
  trap focus.
- Specific risks: low-end (show a reduced version of the image, not the
  full JPEG); large Dynamic Type ("fields only" mode); low light (the image is already
  captured, the problem lies in E-05).
- Acceptance: no value appears in a field without a tap by the person; each
  value travels with its `origin`; with the demo template there are 2 + 2×7 = 16 cells and the
  counter reflects the empty ones; entry can be completed using VoiceOver alone.

### E-08. Validation [P0]

```
┌────────────────────────────┐
│ ← Validación               │
│                            │
│ ✗ Hay 2 errores            │
│   Falta Diputados: Lista C │
│     [ Ir al campo ]        │
│   Hay más votantes que     │
│   electores habilitados    │
│     [ Ir al campo ]        │
│                            │
│ ⚠ 1 aviso                  │
│   Presidente: la suma no   │
│   coincide con el total de │
│   votantes (223 ≠ 225)     │
│   Si el documento dice     │
│   eso, podés confirmar     │
│   igual con una            │
│   justificación.           │
│                            │
│ [ Confirmar captura ] (off)│
└────────────────────────────┘
```

- Purpose: show the result of the contract rules in plain language and
  take the person directly to the field to fix. With "Todo cierra" (Everything adds up) one moves to E-09.
- Content: errors (blocking) and warnings (allow justification), with the sums that
  do not match spelled out; each item with "Ir al campo" (Go to field) → E-07 with focus on the field.
- Actions: Go to field; Confirm (enabled only without errors and with ≥1 page)
  → E-09; [later] "Verificar con otra persona" (F-3).
- States: everything adds up (green ✓ + text "Todo cierra. Revisá una vez más contra la
  imagen antes de confirmar." — "Everything adds up. Check once more against the image before
  confirming."); no pages ("Agregá al menos una imagen." — "Add at least one image.").
- Accessibility: summary announced on entry ("2 errores, 1 aviso"); each item
  is a button with the full text.
- Acceptance: the texts for each code (`missing_mesa`, `missing_value`,
  `negative_value`, `votantes_exceed_electores`, `category_total_mismatch`)
  are in a single reviewable dictionary; errors can never be justified.

### E-09. Confirm and lock [P0]

```
┌────────────────────────────┐
│ Confirmar captura          │
│                            │
│ Mesa 0421 · Certificado    │
│ 2 páginas · 16 valores     │
│ 1 aviso con justificación: │
│ "El acta dice 223."        │
│ [ ______________________ ] │
│                            │
│ Al confirmar, la captura   │
│ queda bloqueada como       │
│ evidencia: no se puede     │
│ editar ni borrar. Si hay   │
│ un error, hacé una nueva   │
│ captura de la misma mesa.  │
│                            │
│ [ 🔒 Confirmar y bloquear ]│
│ [ Volver a revisar ]       │
└────────────────────────────┘
```

- Purpose: explicit, irreversible step; the justification of warnings is written
  here (not in a small alert, as today).
- Content: summary; justification field mandatory if there are warnings (minimum 5
  characters, no personal data: it asks "what the document says", not "who
  you are"); consequences text.
- Actions: Confirm → locks (`lockedAt` UTC) → E-10; Back → E-08.
- States: missing justification (button disabled + help); disk write
  error ("No se pudo guardar. Intentá de nuevo; no se perdió nada." — "Could not save. Try again;
  nothing was lost.").
- Accessibility: announcement "Captura confirmada y bloqueada" on success; the confirm
  button is destructive-irreversible: prominent style, not red (it is not deleting).
- Acceptance: after confirming, no field of E-04/E-06/E-07 is editable;
  attempting to edit through code throws an error in the core (already covered by tests).

### E-10. Confirmed capture [P0]

```
┌────────────────────────────┐
│ ← Mesa 0421         🔒     │
│ ⚠ Formulario ficticio      │
│ Certificado · confirmada   │
│ 31/10/2026 20:52           │
│ ┌────────┐ ┌────────┐      │
│ │ pág 1  │ │ pág 2  │ ⤢    │
│ └────────┘ └────────┘      │
│ Huella digital (SHA-256)   │
│ pág 1: 3f9a…c21e           │
│ pág 2: 8b10…77d4           │
│                            │
│ Valores (sólo lectura)     │
│ Presidente · Lista A   123 │
│ ...                        │
│                            │
│ Envío: no configurado      │
│ [ Exportar evidencia ]     │
│ [ Nueva captura de la      │
│   misma mesa ]             │
└────────────────────────────┘
```

- Purpose: see the final evidence and get it off the phone.
- Content: status, time, pages (zoomable, E-06 in read mode), hashes,
  read-only values with their origin subtly marked ("OCR" / "tipeado" (typed) icon),
  justification if any, submission status.
- Actions: Export → system share menu with the contract JSON +
  JPEGs (and `exportedAt` record); New capture of the same polling table → E-02 with
  polling table and type prefilled; [later] Send → E-11.
- States: exported (shows "Exportada 20:55"); submission pending (see E-11);
  submission not configured (P0, fixed text "El envío a un centro de cómputos todavía
  no está disponible. Exportá la evidencia y compartila por el canal que te indique
  tu organización." — "Submission to a counting center is not available yet. Export the evidence
  and share it through the channel your organization indicates.").
- Accessibility: hashes labeled "huella digital de la página 1" and a "Copiar" (Copy)
  action; list of values as an accessible table.
- Acceptance: the displayed hash matches `shasum -a 256` of the exported JPEG; the
  exported JSON validates against `contracts/schemas/capture.schema.json`.

### E-11. Export queue / pending submissions [P0 minimal, D-003 later]

```
┌────────────────────────────┐
│ ← Envíos                   │
│                            │
│ Sin conexión. Las capturas │
│ están guardadas en el      │
│ teléfono y se van a enviar │
│ cuando haya red.           │
│                            │
│ Mesa 0421 · Certificado    │
│   ⏳ Pendiente de envío    │
│ Mesa 0421 · Telegrama      │
│   ✓ Exportada 20:55        │
│                            │
│ [ Reintentar ahora ]       │
└────────────────────────────┘
```

- Purpose: make visible that nothing is lost without a network; in P0 it only lists
  exports made and marks "envío no disponible" (submission unavailable).
- Content: network status; list with status per capture.
- Actions: Retry (P0: disabled with an explanation); tap → E-10.
- States: offline (text above); no items ("No hay envíos pendientes." — "No pending submissions.");
  [later] server error with retry and without losing the local package.
- Accessibility: network status is announced on entry.
- Acceptance: in airplane mode, the app shows no error when capturing,
  validating, confirming or exporting via AirDrop/Files.

### E-12. About · template · legal [P0]

- Purpose: transparency: which template is in use (id, version, whether it is
  fictitious), app version, what data it stores and what it does not, links to the
  repository and to the legal framework, text "No es una herramienta de acción política
  partidaria" ("It is not a tool for partisan political action").
- Content: static list; no account or network settings in P0.
- Actions: [later] activate "election day mode" by hand (N-C).
- Acceptance: the template shown is the one loaded by `CaptureStore`.

### E-13. State: camera permission denied [P0]

- System screen replaced by a state within E-05 (see above). It is
  listed separately so that Astra can verify that the alternative path exists
  (import from Photos) and the button to system Settings.

### What changes compared to the current prototype

| Today (`HomeView` + `CaptureEditorView`) | Proposal |
| --- | --- |
| A single `Form` with document, polling table, OCR, values, validation and actions | 4-step preparation (E-02..E-05) + split editor (E-07) + validation (E-08) + confirmation (E-09) |
| Single Paper Ballot warning as a red row in the form | Own mandatory screen before the camera (E-02) |
| Image as 120 pt thumbnails | Fixed image on top, zoomable, collapsible (E-07) and viewer with pagination (E-06) |
| Justification in an `alert` with `TextField` | Confirmation screen with a large field and consequences (E-09) |
| OCR chips in a form section | Chips above the keyboard, bound to the focused field, plus a "Cero" (Zero) button |
| No submission status | E-10/E-11 explicitly say that submission does not exist in P0 |

The core (`TelegramaCore`, contracts, vectors) does not change with this proposal;
only a new optional field (`bupWarningAcknowledgedAt`) is proposed, which requires
`contract-change` if the author accepts it.

---

## 6. Android equivalents (Jetpack Compose / Material 3)

Component level, so that the Android implementation is equivalent without deciding
the shared stack (D-002 is still pending). Android component names
are the standard Compose/Material 3 ones; Google Play services dependencies
(scanner, ML Kit) are **proposals** that require consultation before installing.

| Screen | iOS (SwiftUI) | Android (Compose / M3) | Note |
| --- | --- | --- | --- |
| Navigation | `NavigationStack` + `path` | `NavHost` + `rememberNavController`; predictive back | No tab bar in the vote-count flow on either |
| E-00 | `Section` with yellow `Label` | Tonal `Card` (`tertiaryContainer`) with `Icon` + `Text`; `semantics { liveRegion }` | M3 has no official Banner |
| E-01 | `List` + `safeAreaInset` button | `Scaffold` + `LazyColumn` + `bottomBar` with full-width `Button` | Swipe to delete: `SwipeToDismissBox` only on drafts |
| E-02 | Full-screen view, `fullScreenCover` | Own `NavHost` destination; `BackHandler` discards the draft | Do not use `AlertDialog`: it has to be a screen |
| E-03 | List-style `Picker` / `List` with checkmark | `Column` of `ListItem` + `RadioButton`, `selectableGroup()` | |
| E-04 | `TextField` `.numbersAndPunctuation` | `OutlinedTextField` with `KeyboardOptions(keyboardType = Number, imeAction = Next)` | Visible labels, not just `placeholder` |
| E-05 scanner | `VNDocumentCameraViewController` (VisionKit) | ML Kit Document Scanner (Play services) **or** CameraX + own cropping | Pending decision: Google dependency vs. own control; on AOSP without Play there is no ML Kit |
| E-05 import | `PhotosPicker` | `ActivityResultContracts.PickMultipleVisualMedia` (Photo Picker) | No broad permission on either |
| E-05 permission | On-screen state + link to Settings | `rememberLauncherForActivityResult(RequestPermission)` + state + `Intent` to app settings | |
| E-06 viewer | `ScrollView` + `MagnifyGesture` | `Image` + `Modifier.transformable` + `graphicsLayer`; `HorizontalPager` for pages | +/− buttons for accessibility on both |
| E-07 split view | `VStack` (fixed image) + `Form` | `Column` with fixed-height `Image` + `LazyColumn`; `imePadding()` | Image downsampled in memory (`BitmapFactory.inSampleSize`) |
| E-07 OCR | `Vision` `VNRecognizeTextRequest` (on device) | ML Kit Text Recognition (on device) **or** Tesseract | Same rule: never fills in by itself; the contract's `normalizeDigits` in both cores |
| E-07 chips | `ScrollView(.horizontal)` of `Button` | `LazyRow` of `AssistChip` / `SuggestionChip` | Anchored above the IME |
| E-08 | `Section` with `Label` per severity | `LazyColumn` of `ListItem` with severity `Icon` + `TextButton` "Ir al campo" | Color + icon + text |
| E-09 | Own screen + multiline `TextField` | Own destination + `OutlinedTextField(minLines = 3)` + `Button` | Irreversible confirmation: `FilledButton`, not `error` |
| E-10 export | `ShareLink(items:)` | `Intent.ACTION_SEND_MULTIPLE` with `FileProvider` URIs | Same files: JSON + JPEG |
| E-11 | `List` + state | `LazyColumn` + `ConnectivityManager` for the status text | P0: informational only |
| Protected storage | `FileProtectionType.complete`, excluded from iCloud | `EncryptedFile` (Jetpack Security) or Keystore encryption; `android:allowBackup="false"`; `dataExtractionRules` | Validate with `security_analyst` |
| Hash | `CryptoKit SHA256` | `java.security.MessageDigest("SHA-256")` | Lowercase hex on both |
| Dynamic Type | scalable `.font(.body)` | `sp` + `fontScale`; test at 200 % | |
| VoiceOver / TalkBack | `accessibilityLabel`, `accessibilityElement(children: .combine)` | `contentDescription`, `semantics(mergeDescendants = true)`, `stateDescription` | Reading order: `traversalIndex` |
| Dark mode | automatic with semantic colors | `dynamicColor = false` (own colors, not Material You) + `isSystemInDarkTheme()` | Icon palette as own `ColorScheme` |

---

## 7. Future screens of the citizen network [sketch]

Only so that global navigation and visual language are consistent when
the network arrives. They depend on RC-1/DL-1 (build or reuse Decidim/CONSUL): if it is
reused, these screens are native views on top of that API or an embedded web view, and
the sketch describes the content, not the implementation.

### R-01. Thematic spaces and feed (no engagement algorithm)

```
┌────────────────────────────┐
│ Red               Orden: ▾ │
│ ▸ Plataformas (12 nuevos)  │  Orden visible y elegible:
│ ▸ Desinformación (3)       │  "Más reciente" · "Por tema" ·
│ ▸ Campaña                  │  "Por consenso alcanzado".
│ ▸ Jornada y escrutinio     │  Nunca "Para vos". Nada pago.
│ ▸ Regulación (8)           │  Cada ítem muestra su fuente.
│ ──────────────────────     │
│ 20:40 · Plataformas        │
│ Nueva evidencia A1: ...    │
│ 20:12 · Regulación         │
│ Propuesta v3 publicada ... │
└────────────────────────────┘
```

### R-02. Structured proposal (mandatory template)

Fixed fields, in this order: problem · mechanism · evidence (links to axes
A–D) · legal basis · risks · alternatives. It is not published until all are completed. The
electoral escrow account looks the same as any other proposal.

### R-03. Deliberation for / against

```
┌────────────────────────────┐
│ ← Propuesta v3             │
│ [ A favor (14) ][ En contra (9) ][ Preguntas (5) ][ Enmiendas (2) ]│
│ ─ A favor ───────────────  │
│ Argumento · fuente ↗       │
│ ...                        │
│ ─ En contra ─────────────  │
│ Argumento · fuente ↗       │
│ [ Agregar argumento ]      │
│ [ Proponer enmienda ]      │
└────────────────────────────┘
```

No "likes"; arguments are sorted by date or by replies, never by
votes. Amendments are concrete changes to the text, with a diff.

### R-04. Consensus and action modalities

```
┌────────────────────────────┐
│ Consenso                   │
│ Participantes verificados  │
│ 1.240 / mínimo 1.000  ✓    │
│ Acuerdo 78 % / umbral 70 % ✓│
│ Objeciones sin responder 1 ✗│
│ Consenso transversal:      │
│ fuerzas de distinto signo  │
│ 2 / mínimo 3  ✗            │
│ Chequeo legal: pendiente   │
│ ──────────────────────     │
│ Modalidad propuesta:       │
│ Carta abierta a plataformas│
│ Procedimiento · responsable│
│ [ Proponer otra modalidad ]│
└────────────────────────────┘
```

Thresholds (RC-2) are always shown with their published value; no external
action is marked as "en curso" (in progress) without the `electoral_counsel` check.

### R-05. Parties on equal terms

Directory with the **same card** for each recognized party (name,
verification, link to its arguments), alphabetical order or random per session
(documented), no highlights, no larger logos, same visible posting
limits. During the blackout (veda): behavior to be defined (RC-3).

### R-06. Tools and monitoring agents

A4 dashboard per platform (metrics with public definitions and download of aggregated
data), A1 archive (upload evidence with a hash just like a telegram: same
evidence core, D-EV-1), status of each AI agent (what it measures, with what
method, last run), and the link to the AMBA simulation with "SIMULACIÓN"
always visible.

### R-07. Profile

Minimum: alias, person verification status (RC-5), my proposals and
arguments, my captures. Political affinity is never requested or shown.

---

## 8. Questions for the author

1. Do you confirm the N-C direction (one app, election day mode) or do you prefer to
   keep the vote count as a separate app (N-B) until after the hackathon?
2. Is the count certificate preselected in E-03, or with no preselection
   so as not to suggest which document to photograph?
3. Do you accept adding `bupWarningAcknowledgedAt` to the contract (requires
   `contract-change`)? Alternative: record nothing and trust the flow.
4. Do you want F-3 (double entry) in P0 in its minimal variant (blind re-typing of only `votantes`
   and the totals per category), or is it left for later?
5. Does the explicit "Cero" (Zero) button (E-07) seem right to you, or do you prefer an empty field to be
   treated as 0 with a warning? (Today the contract requires an explicit value: `missing_value`.)
6. For the hackathon demo, can the fictitious template warning (E-00) be
   the permanent yellow strip, or do you prefer something less intrusive?
7. Is the OCR/typed origin per value shown in E-10 (transparency) or only in
   the exported JSON (simpler screen)?
8. Do you want the prototype to include E-12 (About) now or only E-00..E-11?

---

## 9. Points for Astra to validate (review)

Concrete checklist for whoever reviews this proposal:

1. **Legal, flow:** that there is no path to the camera without going through E-02 and
   that E-03 only offers telegram/tally sheet/certificate (telegram-capture, legal framework 3.2).
2. **Legal, texts:** that no screen talks about "fraude" (fraud) or "denuncia" (complaint), nor
   presents the capture as a claim (legal framework 3.4 and 6); that E-10/E-11 do not
   publish or aggregate results (art. 71 h).
3. **Personal data:** that no screen asks for name, national ID (DNI), party, location
   or contacts; that the E-09 justification does not lead people to identify themselves; that F-3
   does not record identities.
4. **Evidence:** that E-06 does not allow editing images and that E-10 shows the hash of
   each page; that "Quitar página" (Remove page) only exists in drafts.
5. **Neutrality:** that row labels come from the template and that no
   screen highlights a political grouping (agrupación); that R-05 describes the same card for all.
6. **Consistency with the contract:** that each screen maps to existing fields of
   `capture.schema.json` and that the only new field is marked as pending.
7. **P0 scope:** that what is marked [P0] matches telegram-capture's "Alcance del prototipo"
   (prototype scope) and that D-003 (submission) does not slip in as functionality.
8. **Accessibility:** that each [P0] screen declares labels, reading order and
   behavior with Dynamic Type; that E-07 has the "fields only" mode.
9. **Field conditions:** that E-05 accounts for low light (flashlight, tips) and that
   E-07 accounts for low-end phones (reduced image); that everything works offline.
10. **Android:** that each screen has a component equivalent and that the
    Google dependencies (ML Kit) appear as proposals, not as decisions.
11. **Proposal vs. decision:** that the document does not fix architecture (N-A/N-B/N-C,
    D-002) or stack, and that each recommendation is labeled as a proposal.
12. **Visual coherence:** that the interface texts are Rioplatense and simple,
    and that the language of "cuidar el proceso" (taking care of the process) (not "controlar" (control), not "vigilar" (watch over)) is
    kept on all screens.

---

## 10. Acceptance criteria for this SPEC

1. The author chooses a global architecture (N-A/N-B/N-C) or asks for another alternative.
2. The author chooses the vote-count flow (F-1/F-2/F-3/hybrid) and, if applicable,
   the UX section of telegram-capture is updated.
3. The accepted screens E-00..E-13 become tasks with `.agents/templates/task.md`,
   one per screen or per group of screens, with the current prototype as a base.
4. Astra's review recorded with the 12 points of section 9, and `electoral_counsel`
   check on E-02, E-03, E-09, E-10 and section 3 (blackout and election day mode).
