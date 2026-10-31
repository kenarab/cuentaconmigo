# Flujos como statecharts (`contracts/flows/`)

Estado: **propuesta** (decisiones AA-2, AA-3, AA-5 y AA-9 de
[app-architecture](../../sdd/specs/app-architecture/SPEC.md) abiertas; se trabaja con la
opción ★). El flujo de captura de [app-screens](../../sdd/specs/app-screens/SPEC.md)
(E-02…E-10) se describe una sola vez en `capture.flow.json`; F-1, F-2 y F-3 son
**presentaciones** de la misma máquina, no máquinas distintas. Lo que ninguna
presentación puede hacer lo garantiza la máquina: saltear el aviso de Boleta Única,
editar después de confirmar, confirmar con errores.

Archivos:

- `capture.flow.json`: la definición (sin código: guardas, acciones y efectos son nombres).
- `flow-machine.js`: intérprete de referencia (UMD, sin dependencias) con las guardas y
  acciones nombradas, el validador portado de `Validation.swift`, el normalizador de
  dígitos y la comparación de doble carga.
- `run-vectors.js`: corre `vectors/digits.json`, `vectors/validation.json` y
  `vectors/capture-flow.json`. `node contracts/flows/run-vectors.js [--verbose]`.
- `export-prototype.js`: genera en `design/prototypes/flujo/` los archivos que el
  prototipo carga con `file://`: `capture.flow.js` (flujo + plantilla `generales-2023`
  como globales), `nomina.sample.js` (subconjunto de `data/establecimientos/nomina-2025.json`:
  todos los distritos y secciones, establecimientos sólo de CABA Comuna 1 y Avellaneda) y
  una copia de `flow-machine.js`. No editar los generados; regenerar con
  `node contracts/flows/export-prototype.js`.

Cada implementación (Swift hoy, Kotlin después) reimplementa el intérprete y debe pasar
los mismos vectores. Cambiar una regla: primero este contrato y sus vectores
(skill `contract-change`), después cada implementación.

## Formato del JSON

```jsonc
{
  "id": "capture", "version": 1,
  "presentations": { "f1": { "label": "…", "supportsDoubleEntry": false }, … },
  "effects": { "persist": "qué hace el puerto", … },   // catálogo: nombres válidos
  "context": { … },                                     // contexto inicial
  "initial": "bupWarning",
  "on": { "evento": transición },                       // manejadores de la raíz
  "states": {
    "hoja":      { "screen": "E-02", "on": { … } },
    "compuesto": { "initial": "hijo", "on": { … }, "states": { "hijo": { … } } }
  }
}
```

Una **transición** es `{ "target"?, "guard"?: ["g", "!h"], "actions"?: ["a"], "effects"?: ["e"] }`
o una **lista** de transiciones candidatas para el mismo evento. Sin `target` es
interna: no cambia de estado, sólo ejecuta acciones y devuelve efectos.

## Semántica del intérprete

1. **Estado activo = una hoja**, identificada por su ruta `a.b` (por ejemplo
   `editing.mesa`). La pantalla (`screen`) es la de la hoja o, si no tiene, la del
   ancestro más cercano.
2. **Búsqueda del evento de la hoja a la raíz.** Se mira `on[evento]` en la hoja, luego
   en cada ancestro y por último en la raíz. Así `editing.on.setValues` vale en cualquier
   hijo de `editing` y `on.setPresentation` (raíz) vale en todo estado.
3. **Candidatos en orden; gana el primero cuyas guardas pasan.** `guard` es una lista de
   nombres; todas deben ser verdaderas; `!nombre` niega. Las guardas se evalúan sobre el
   contexto **anterior** y el payload del evento. Si en un nivel ninguna candidata pasa,
   se sigue buscando en el ancestro (semántica SCXML).
4. **Sin manejador o con guardas fallidas, el evento se ignora** sin cambiar estado,
   contexto ni producir efectos. `send()` lo informa con `ignored: true`. No hay
   excepciones ni estados de error: la máquina es la que hace imposible lo prohibido.
5. **Acciones puras antes de efectos.** Las acciones modifican una copia del contexto
   (sin E/S, sin reloj, sin azar) y se aplican en orden. Los **efectos** son sólo
   nombres que `send()` devuelve al adaptador (SwiftUI, Compose, el prototipo HTML), que
   los ejecuta después y, si corresponde, responde con otro evento (`scan` →
   `pagesAdded`). La máquina nunca ejecuta efectos.
6. **Destino compuesto: se entra por `initial`**, recursivamente, hasta una hoja
   (`acceptBup` → `editing` → `editing.documentType`). Los `target` son rutas absolutas.
7. **Validación estática** al crear la máquina: todo `target` existe, toda guarda y
   acción tiene implementación, todo efecto está en el catálogo `effects`, todo estado
   compuesto tiene `initial`. Si algo falla, no se crea la máquina.

API de referencia (`flow-machine.js`):

```js
const m = FlowMachine.createMachine(flow, template, { presentation: 'f3' });
m.state            // 'bupWarning'
m.screen           // 'E-02'
const r = m.send('acceptBup');      // { state, context, effects, ignored, transition, … }
m.availableEvents()                 // [{ type, source, enabled, needsPayload, targets }]
m.issues()                          // validate(plainValues(context), template)
m.snapshot()                        // { state, context } para persistir y restaurar
```

## Contexto de `capture`

| Campo | Contenido |
| --- | --- |
| `presentation` | `f1` / `f2` / `f3` (claves de `presentations`). Ajuste del teléfono, no de la captura. |
| `documentType` | uno de `template.documentTypes` o `null`. |
| `mesa` | `{ campo: texto }`. Las claves de `template.mesaFields` son las que valida la regla `missing_mesa`; se admiten otras (por ejemplo `establecimiento`, propuesto en telegram-capture y pendiente de `contract-change`). |
| `pages` | `[{ id, source?, hash?, … }]` tal como las entregó el adaptador; `id` único. |
| `header`, `cells` | `{ id: { value, origin } }` y `{ categoría: { fila: { value, origin } } }`. `origin` ∈ `manual`, `ocr-accepted`. Un valor ausente es un faltante. |
| `justification` | texto de E-09 (≥ 5 caracteres para confirmar con avisos). |
| `second`, `mismatches`, `doubleEntry` | doble carga mínima (abajo). |
| `sample` | `null` o `{ id, label }` cuando la captura usa un telegrama de ejemplo (modo demostración de telegram-capture; `sample: true` en el paquete está pendiente de `contract-change`). |
| `locked` | `true` desde `confirmed`. Ningún estado posterior a `confirming` acepta eventos de edición. |

### Payloads

- `setValues`: `{ header?: { id: v }, cells?: { categoría: { fila: v } } }` con `v` entero
  (origen `manual`), `null` (borra) o `{ value, origin }`. Claves fuera de la plantilla,
  valores no enteros → evento ignorado.
- `setMesa`: `{ mesa: { campo: texto | null } }`.
- `pagesAdded`: `{ pages: [{ id, … }] }`; ids repetidos no se duplican. `removePage`: `{ id }`.
- `useSample`: `{ sample: { id, label?, mesa: {…}, pages: [{ id, … }] } }`; las páginas se
  guardan con `source: "sample"`.
- `chooseDocumentType`: `{ documentType }`. `setJustification`: `{ justification }`.
  `setPresentation`: `{ presentation }`.
- `setSecondValues`: `{ votantes?, totals?: { categoría: n } }`.
- `edit`, `editMesa`, `editPages` admiten `{ path }` para que la presentación enfoque el
  campo; la máquina no lo usa.

## Estados y presentaciones

```
bupWarning ─acceptBup→ editing { documentType → mesa → pages → values } ─review/next→ validation
validation ─proceed→ confirming ─confirm→ confirmed ─export→ exported
validation ─requestDoubleEntry (sólo F-3)→ handoff → values2 → compare ─acceptMatch→ validation
```

- **F-1 (asistente):** una hoja por pantalla; usa `next`/`back` de las hojas. Ningún
  `next` pasa sin su guarda (`documentTypeChosen`, `mesaComplete`, `hasPages`).
- **F-2 (imagen + campos):** muestra toda la región `editing` en una vista; usa sólo los
  eventos del padre (`chooseDocumentType`, `setMesa`, `pagesAdded`, `setValues`,
  `review`) en cualquier orden. La hoja activa queda en `editing.documentType`: para F-2
  no significa nada, y por eso los datos viven en el padre.
- **F-3 (doble carga):** igual a F-2 más la rama opcional; `requestDoubleEntry` exige
  `presentationSupportsDoubleEntry` (lo declara `presentations.f3`).
- `confirming` (E-09) es un estado propio: `confirm` sólo existe ahí, con dos candidatas
  (sin avisos, o con avisos y justificación). `proceed` desde E-08 exige `hasPages`,
  `noErrors` y que no haya una comparación pendiente.

## Doble carga mínima (AS-5 a, respuesta de Andy)

La segunda persona **no ve** la primera carga ni el OCR (lo garantiza la presentación:
en `values2` no se muestran imagen, fichas ni valores) y tipea sólo `header.votantes` y
el **total de cada categoría**. `computeMismatches` compara cada total con la **suma de
las filas** de la primera carga y `votantes` con `votantes`:

```json
[{ "path": "cells.presidente", "first": 300, "second": 310 }]
```

- `submitSecond` exige `secondComplete` (votantes y un total por categoría, enteros ≥ 0).
- En `compare`: `acceptMatch` (sólo si coinciden) marca `doubleEntry: "matched"`;
  `fixFirstEntry` (sólo si difieren) vuelve a `editing.values` con `doubleEntry: "pending"`;
  `retypeSecond` vuelve a `handoff` borrando la segunda carga; `cancelDoubleEntry` sale
  a `validation` sin registro.
- Con `pending`, `proceed` queda bloqueado hasta `compareAgain` (recalcula con la misma
  segunda carga) o `cancelDoubleEntry`.
- Editar la primera carga después de `matched` vuelve a `none` (`invalidateDoubleEntry`).
- No se registra quién hizo cada carga: el contexto no tiene identidades.

## Vectores (`vectors/capture-flow.json`)

```jsonc
{ "name": "…", "presentation"?: "f3", "prelude"?: "toValidationClean",
  "events": ["acceptBup", { "type": "setMesa", "payload": {…} }],
  "expectState": "editing.mesa", "expectEffects": ["persist"],   // del último evento
  "expectIgnored"?: true, "expectContext"?: { … } }                // coincidencia parcial
```

`preludes` son listas de eventos reutilizables (`{ "prelude": "x" }` dentro de otra lista
las expande). Casos negativos obligatorios: no saltear `bupWarning`, nada editable tras
`confirmed`, `confirm`/`proceed` con errores ignorados, segunda carga sin tocar la
primera. Plantilla de los vectores: `demo-2027` (ficticia).
