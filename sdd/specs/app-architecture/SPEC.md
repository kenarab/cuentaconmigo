# SPEC · Arquitectura de la app: núcleo desacoplado y presentaciones intercambiables

Estado: **propuesta (rol `planner`, Claude); ninguna decisión tomada.** Responde al pedido
del autor (31/10/2026): ver los tres diseños de Fable (F-1, F-2, F-3) dentro de la app,
y que el diseño quede modular y desacoplado de la lógica para migrar a Android y a otras
interfaces (web, workflows, asistentes). Fecha: 31/10/2026. Aceptación: autor.
Depende de [mobile-platform](../mobile-platform/SPEC.md) (D-001 tomada; D-002 pendiente),
[app-screens](../app-screens/SPEC.md), [telegram-capture](../telegram-capture/SPEC.md),
[review-pipeline](../review-pipeline/SPEC.md). Complementa, no reemplaza, la decisión D-002.

## 1. Problema

- El autor quiere **comparar F-1, F-2 y F-3 en el teléfono**, no sólo en el HTML, y que
  elegir uno no fije la arquitectura.
- Hoy la app iOS tiene **una sola pantalla de carga** (`CaptureEditorView`, base de F-2),
  sin selector, sin asistente y sin doble carga. La lógica del flujo (qué paso sigue, qué
  se puede saltear, cuándo se bloquea) vive implícita en la vista.
- Android, una web de revisión ([scrutiny-backend](../scrutiny-backend/SPEC.md) SB-13), el
  modo planificación ([fiscal-planning](../fiscal-planning/SPEC.md)) y eventuales
  asistentes/bots van a necesitar **el mismo flujo** sin reescribirlo cada vez.

## 2. Estado actual del diseño (hechos verificados en el repo, 31/10/2026)

| Pieza | Qué hay | Qué falta respecto del pedido |
| --- | --- | --- |
| `design/prototypes/escrutinio/index.html` | iPhone simulado E-00..E-13 con panel lateral. Selector **AS-2** con dos valores: `F-2 imagen + campos` y `F-1 asistente por sección` (sólo cambia E-07: F-1 muestra una sección por pantalla). F-3 aparece en E-08 como botón **deshabilitado** "Verificar con otra persona (después)". | No hay F-3 navegable; F-1 no prototipa la preparación en pasos (E-02..E-06 son iguales en ambos); el selector está en el panel de la derecha, no en una pantalla de ajustes de la app simulada. Por eso el autor "no encontró los 3 diseños". |
| `design/prototypes/navegacion/index.html` | N-A / N-B / N-C comparables. | Independiente de F-x; sin cambios necesarios. |
| `ios/TelegramaCore` | Núcleo puro (`Capture`, `FormTemplate`, `Validator`, `DigitNormalizer`, `EvidenceHash`), sin UI, con `ContractTests` que corren `contracts/vectors/{validation,digits}.json`. Bloqueo con `private(set)`. | No modela el **flujo** (pasos, transiciones, guardas). |
| `ios/CuentaConmigo` | `HomeView` → `NavigationStack(path: [UUID])` → `CaptureEditorView` (un `Form` con documento, mesa, páginas, valores, validación, acciones). `CaptureStore` = persistencia + plantilla. `TextRecognizer` (Vision), `DocumentScanner` (VisionKit), `PageViewer`. | Sin pantallas E-02..E-06, E-08, E-09, E-12; sin Ajustes; sin selector F-1/F-2/F-3; la vista decide el orden del flujo; servicios acoplados a la vista (no hay puertos/protocolos). |
| `contracts/` | Schema, plantillas (`generales-2023`, `balotaje-2015`; `demo-2027` sólo para tests), vectores de validación y dígitos. | Sin contrato del **flujo** ni vectores de transición. |
| `ios/scripts/sync-contracts.sh` | Copia `contracts/templates/generales-2023.json` al bundle. | Al día desde `a7e84cb`: la app embebe `generales-2023.json` y ya no la plantilla ficticia. |

Decisiones del pipeline aún abiertas que condicionan esto: AS-2 (F-1 vs F-2), AS-5 (F-3 en
P0 o después) y N-A/N-B/N-C (issue #2). Esta SPEC propone **no cerrarlas por código**:
la app debe poder mostrar las tres hasta que el autor y Andy decidan.

## 3. Investigación: técnicas probadas para separar lógica y presentación

Principio común a todas las fuentes: **la lógica es una función pura `(estado, evento) →
(estado', efectos)`; la UI sólo dibuja el estado y emite eventos; los efectos (cámara, OCR,
disco, red) los ejecuta un adaptador fuera del núcleo.** Es la "Elm Architecture"
(Model/View/Update) que inspiró Redux y, en móvil, MVI, TCA y Crux.

### 3.1 Patrones transversales (aplican con cualquier stack)

| Técnica | Qué aporta aquí | Fuente |
| --- | --- | --- |
| Arquitectura unidireccional (Elm/MVI/TCA) | Estado único por flujo; vista sin lógica; tests sin UI enviando eventos y asertando estado (`TestStore` en TCA) | [Elm guide](https://guide.elm-lang.org/architecture/), [TCA](https://github.com/pointfreeco/swift-composable-architecture) |
| Efectos como datos | El núcleo **describe** "escanear", "OCR de la página 2", "guardar JPEG" como valores; la plataforma los ejecuta. Permite simular cámara/OCR en tests y en el prototipo HTML | [Crux](https://github.com/redbadger/crux): "Side effects such as calling an API are captured as values and executed by the Shell" |
| Statecharts declarativas | El flujo (pasos, guardas, estados paralelos, historia) se escribe como **datos** (JSON/SCXML), no como código de navegación. Varias UIs lo interpretan; se generan tests de cobertura de caminos | [SCXML, W3C Rec. 2015](https://www.w3.org/TR/scxml/); [xstate/graph](https://stately.ai/docs/xstate-graph): `getShortestPaths`/`getSimplePaths` generan un caso de prueba por camino |
| Vectores de contrato | Ya en uso (`contracts/vectors`). Se extienden al flujo: `eventos → estado y efectos esperados` | [contracts/README.md](../../../contracts/README.md) |
| Design tokens (DTCG) | Colores, tipografías y espaciados en JSON compartido → CSS del prototipo, Swift y Kotlin generados; mismo look en las tres presentaciones | [DTCG Format 2025.10](https://www.designtokens.org/TR/2025.10/format/) (borrador vigente sept. 2026) |
| Server-driven UI | El servidor manda el árbol de pantalla. Útil para releases frecuentes; **mala idea** para un flujo offline-first con evidencia. Lo que sí ya hacemos es "template-driven": la plantilla del formulario es declarativa | [Airbnb Ghost Platform](https://medium.com/airbnb-engineering/a-deep-dive-into-airbnbs-server-driven-ui-system-842244c5f5) |

### 3.2 Comparación de stacks para el núcleo compartido

Criterios: equipo chico; hackatón ya; iOS hoy, Android después; offline-first; evidencia
inmutable; gusto del autor por Rust a largo plazo.

| Opción | Cómo queda | A favor | En contra | Para la hackatón |
| --- | --- | --- | --- | --- |
| **A. Swift puro + flujo declarativo + contratos** (sin dependencias) | `TelegramaCore` suma un intérprete de statechart (~200 líneas) y puertos como `protocol`. Android reimplementa el intérprete en Kotlin contra los mismos JSON y vectores | Cero dependencias; continúa D-001 y la opción A de D-002; lo que se escribe hoy sirve mañana (el JSON del flujo y los vectores son el activo); SwiftUI 100 % nativo | Intérprete escrito dos veces (Swift, Kotlin); divergencias sólo detectables por vectores | ★ Viable: se puede hacer en días |
| **B. Núcleo Rust + UniFFI** | Validación, normalización, hash, paquete y máquina de flujo en un crate; Swift/Kotlin consumen bindings generados | Una sola implementación; "full support for Kotlin, Swift and Python" ([UniFFI](https://mozilla.github.io/uniffi-rs/latest/)); mismo crate reutilizable en el backend Python (vía bindings) y en una CLI/bot; en producción en Firefox y Lyft ([Ferrostar](https://stadiamaps.com/blog/ferrostar-building-a-cross-platform-navigation-sdk-in-rust-part-1/)) | Toolchain Rust + `cargo-swift`/NDK en el build; UniFFI "a long way from a 1.0 release"; curva para quien no programa Rust (Andy); no cabe en la hackatón sin riesgo | No ahora. Etapa 3 si la lógica crece |
| **C. Crux (Rust core + shells delgados)** | Como B, pero con el patrón "efectos como datos" ya resuelto y tipos generados para Swift, Kotlin y TypeScript (shell web sin reescribir) | Encaja exactamente con la separación propuesta; "production-ready" según sus autores; shells en SwiftUI/Compose/React | Pre-1.0 con "occasional breaking changes"; FFI propio (BoltFFI), comunidad chica; impone su estructura (más opinado que B) | No ahora. Alternativa a B en etapa 3 |
| **D. Kotlin Multiplatform para el núcleo** | Núcleo Kotlin; Swift lo consume vía Swift export | Respaldo JetBrains/Google; Android lo usa nativo | Swift export "currently in Alpha… breaking changes are expected" ([kotlinlang](https://kotlinlang.org/docs/native-swift-export.html)); Gradle en el build iOS; no aprovecha Rust | No ahora. Pierde frente a B si el autor prefiere Rust |

Descartadas por D-001 (apariencia nativa): Compose Multiplatform en iOS, Flutter, RN.

## 4. Arquitectura propuesta en capas

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ PRESENTACIÓN (intercambiable, elegida en Ajustes)                           │
│  F-1 Asistente  │  F-2 Vista partida  │  F-3 Doble carga  │ (web, bot, CLI) │
│  Cada una: mapa estado→pantalla + vistas. Sin reglas de negocio.            │
├─────────────────────────────────────────────────────────────────────────────┤
│ VIEWMODEL COMÚN  (proyección del estado: campos, errores, paso, OCR chips)   │
├─────────────────────────────────────────────────────────────────────────────┤
│ MÁQUINA DEL FLUJO  (statechart declarativa: contracts/flows/capture.json)   │
│  (estado, evento) → (estado', [efectos])   · intérprete puro, sin I/O        │
├─────────────────────────────────────────────────────────────────────────────┤
│ NÚCLEO DE DOMINIO  (TelegramaCore hoy): Capture, FormTemplate, Validator,    │
│  DigitNormalizer, EvidenceHash, paquete de exportación                       │
├─────────────────────────────────────────────────────────────────────────────┤
│ PUERTOS (protocolos)  Scanner · PhotoImport · OCR · EvidenceStore · Clock ·  │
│                       Settings · Uploader(D-003)                              │
├─────────────────────────────────────────────────────────────────────────────┤
│ ADAPTADORES  iOS: VisionKit, Vision, FileManager+DataProtection, CryptoKit   │
│              Android: ML Kit/CameraX, EncryptedFile, MessageDigest           │
│              Tests/HTML: fakes deterministas (imágenes y OCR ficticios)       │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.1 Núcleo de dominio

Es `TelegramaCore` tal como está. Regla vigente: sin UIKit/SwiftUI/VisionKit; conforme si
pasa los vectores. Se agrega sólo lo que la máquina necesite (p. ej. comparación de dos
cargas para F-3: `diff(carga1, carga2) → [celda, v1, v2]`, con vectores).

### 4.2 Máquina del flujo de captura (nuevo contrato)

Archivo propuesto `contracts/flows/capture.flow.json` (vía skill `contract-change`),
subconjunto de SCXML expresado en JSON: `states`, `initial`, `on: {evento: {target,
guard, effects}}`, `final`. Sin código en el JSON: las guardas son nombres que el núcleo
implementa (`hasPages`, `mesaComplete`, `noErrors`, `warningsJustified`) y los efectos son
nombres de puertos (`scan`, `importPhotos`, `ocr(page)`, `persist`, `lock`, `export`).

Estados (de E-02 a E-11 de app-screens):

```
bupWarning → documentType → mesa → pages → values → validation → confirm → confirmed → exported
                                              │                       ▲
                                              └─(F-3 opcional)─ handoff → values2 → compare ─┘
```

- F-1, F-2 y F-3 **no son máquinas distintas**: son presentaciones de la misma. F-1
  muestra un estado por pantalla; F-2 agrupa `documentType`+`mesa`+`pages`+`values` en
  una vista partida y las "transiciones" son scroll y foco; F-3 activa la rama
  `handoff → values2 → compare` con el evento `requestDoubleEntry` (guarda:
  `presentationSupportsDoubleEntry`). Lo que ninguna presentación puede hacer: saltear
  `bupWarning`, editar tras `confirmed`, confirmar con errores (lo garantiza la máquina,
  no la vista).
- Vectores `contracts/vectors/capture-flow.json`: `{name, events:[…], expectState,
  expectEffects:[…]}` más casos negativos (evento no permitido → estado sin cambio). Se
  generan a mano los caminos críticos y, si se adopta una herramienta tipo xstate/graph
  en el prototipo HTML, se exportan todos los caminos simples (AA-4).
- El prototipo HTML puede ejecutar **el mismo JSON** con un intérprete JS de ~100 líneas:
  así prototipo y app comparten el flujo y no sólo el aspecto.

### 4.3 Puertos y adaptadores

Un `protocol` por efecto (`DocumentScanning`, `PhotoImporting`, `TextRecognizing`,
`EvidenceStoring`, `SettingsStoring`, `Clock`). `CaptureStore` se divide en
`EvidenceStore` (archivos inmutables + `capture.json`) y `TemplateProvider`. Las vistas
nunca llaman a Vision/VisionKit directamente. Fakes en `ios/CuentaConmigoTests`
(imágenes y OCR ficticios) permiten correr el flujo completo en `swift test` y en el
simulador sin cámara.

### 4.4 Presentaciones intercambiables

- `enum CapturePresentation: String { case f1Wizard, f2Split, f3DoubleEntry }` guardado
  en `SettingsStore` (UserDefaults); selector en **E-12 Ajustes/Acerca de** con texto
  "Diseño de la carga (para comparar en la hackatón)". Cambiarlo no toca las capturas
  guardadas (el estado es el mismo).
- Cada presentación es un `struct` que mapea `FlowState → some View` y declara qué
  capacidades usa (`supportsDoubleEntry`). Las vistas reciben el `CaptureFlowViewModel`
  y devuelven eventos; no tocan `Capture` ni `Validator`.
- Lo compartido entre las tres (fichas OCR, fila de valor, banner E-00, visor de página,
  botón primario de 56 pt) vive en `Views/Components/`, con tokens de `design/tokens/`.
- Si la decisión AS-2 cierra en una, las otras se quitan sin tocar núcleo ni máquina.

### 4.5 Tokens de diseño

Los `--vars` CSS de los prototipos (colores, `--warn-*`, radios, tamaños) pasan a
`design/tokens/cuentaconmigo.tokens.json` (formato DTCG). Un script (a elegir, AA-6)
genera `Tokens.swift`, `Tokens.kt` y `tokens.css`. Hasta entonces, el prototipo HTML
sigue siendo la referencia visual (review-pipeline).

## 5. Camino a Android y a otras interfaces

| Destino | Qué reutiliza | Qué escribe |
| --- | --- | --- |
| Android (Kotlin/Compose) | `capture.flow.json`, plantillas, vectores (flujo + validación + dígitos), tokens, equivalencias de app-screens §6 | Intérprete Kotlin (opción A) o bindings (B/C); adaptadores ML Kit/CameraX/EncryptedFile; vistas Compose por presentación |
| Web de revisión humana (SB-13) | Mismo JSON de flujo (estados `values`/`validation`/`confirm`) y tokens | Shell web; sin cámara: estado `pages` se alimenta del servidor |
| Workflows/asistentes (chat, voz, bot de verificación) | La máquina es un **protocolo de conversación**: cada estado = una pregunta; eventos = respuestas | Adaptador de canal. Sin UI gráfica |
| Backend Python (SB-1) | Vectores y schema; si hay núcleo Rust (B), bindings Python de UniFFI para validar paquetes con el mismo código | — |
| Modo planificación (fiscal-planning) | Mismo patrón: máquina `pendiente → visitada → … → cotejado` como segundo flujo declarativo | — |

## 6. Recomendación ★ por etapas (propuesta)

**Etapa 0 · Prototipo (antes de implementar, obligatorio por review-pipeline).** Fable
actualiza `design/prototypes/escrutinio/index.html`: F-3 navegable (carga 1 → traspaso →
carga 2 a ciegas → comparación, sin identidades), F-1 con preparación en pasos reales,
selector con **tres** valores también dentro de la pantalla E-12 del teléfono simulado, y
—si se acepta AA-3— el intérprete JS leyendo `capture.flow.json`. Revisión Astra (`ux`,
`legal`, `neutrality`) → decisión del autor y Andy → recién entonces Swift.

**Estado de la etapa 0 (31/10/2026):** hecho como propuesta, con las opciones ★ de AA-2,
AA-3 y AA-5 provisorias. El flujo está en `contracts/flows/` (intérprete JS de
referencia y 79/79 vectores) y el prototipo en `design/prototypes/flujo/`
([link privado](https://claude.ai/artifact/XKaKVJMsNjDmr91UJZ7rN7)). Incluye el selector
F-1/F-2/F-3 en E-12, listas desplegables con la nómina 2025 y los telegramas oficiales de
Andy como valores transcriptos. Faltan la verificación visual en un navegador, la
revisión Astra (si el autor la autoriza) y la aprobación del autor.

**Etapa 1 · Hackatón, en Swift, sin dependencias nuevas (opción A).**
1. `contracts/flows/capture.flow.json` + `contracts/vectors/capture-flow.json`
   (`contract-change`).
2. `TelegramaCore`: `FlowMachine` (intérprete puro) + `ContractTests.testFlowVectors`.
3. App: puertos/adaptadores; `CaptureFlowViewModel`; presentaciones F-1 y F-2 completas
   según el prototipo aprobado; F-3 en su variante mínima (re-tipear `votantes` y totales
   por categoría a ciegas) si AS-5 lo habilita, o sólo el estado `handoff` visible.
4. Selector en E-12. Verificación: `ios/scripts/verify.sh` + prueba en iPhone del autor.
Mínimo aceptable si falta tiempo: puntos 1, 2 y F-2 sobre la máquina (sin selector), ya
que el activo durable es el flujo declarativo con vectores, no la cantidad de diseños.

**Etapa 2 · Android.** Intérprete Kotlin + adaptadores + Compose contra los mismos
contratos. Equivalencia = pasa los mismos vectores y recorre los mismos caminos.

**Etapa 3 · Núcleo compartido, si conviene.** Disparadores medibles: (a) una regla
divergió entre Swift y Kotlin pese a los vectores, o (b) el núcleo supera ~2.000 líneas
por plataforma, o (c) aparece un tercer consumidor (web/bot/backend). Entonces evaluar
**B (Rust + UniFFI)** como primera opción, por la preferencia del autor y porque sirve
también a Python; C (Crux) si además se quiere el shell web generado. Migración por
módulos: normalización y validación → máquina → paquete/hash. Los vectores garantizan que
la migración no cambia comportamiento.

## 7. Decisiones pendientes

| ID | Decisión | Opciones (★ = recomendada) |
| --- | --- | --- |
| AA-1 | Patrón de la capa Swift | ★ Unidireccional propio (máquina + ViewModel `@Observable`, sin dependencias) · TCA (dependencia SPM, `TestStore`) · MVVM clásico sin máquina |
| AA-2 | Dónde vive la definición del flujo | ★ `contracts/flows/*.json` interpretado en runtime · enum Swift/Kotlin a mano (sin contrato) · SCXML XML estándar |
| AA-3 | El prototipo HTML ejecuta el mismo JSON de flujo | ★ Sí (intérprete JS mínimo) · No, sigue a mano |
| AA-4 | Generación de vectores de flujo | ★ Caminos críticos a mano + caminos simples exportados desde una herramienta tipo xstate/graph (sólo en el prototipo; requiere consulta antes de instalar) · sólo a mano |
| AA-5 | Presentaciones que se implementan para la hackatón | ★ F-1 + F-2 completas y F-3 mínima · sólo F-2 sobre la máquina · las tres completas |
| AA-6 | Tokens de diseño | ★ DTCG JSON + script propio de generación (sin dependencias) · Style Dictionary (dependencia npm) · seguir con CSS vars y constantes Swift a mano |
| AA-7 | Núcleo compartido en etapa 3 | ★ Rust + UniFFI · Crux · KMP · nunca (A permanente) |
| AA-8 | El selector de presentación queda en producción | ★ Sólo en builds de desarrollo/hackatón; producción fija el diseño elegido · siempre visible como accesibilidad (p. ej. F-1 para Dynamic Type grande) |
| AA-9 | Modelado de F-3 | ★ Rama opcional de la misma máquina (`handoff → values2 → compare`) · máquina aparte · región paralela SCXML |

## 8. Criterios de aceptación (medibles)

1. `contracts/flows/capture.flow.json` existe; `swift test` corre `capture-flow.json` con
   ≥ 1 vector por transición y ≥ 1 negativo por guarda (`bupWarning` no salteable,
   `confirmed` sin ediciones, `confirm` con errores rechazado).
2. `TelegramaCore` sigue sin `import UIKit/SwiftUI/VisionKit` (grep en CI/verify.sh).
3. Ninguna vista de `ios/CuentaConmigo/Views` importa `Vision`/`VisionKit`/`PhotosUI`
   directamente: sólo los adaptadores.
4. En Ajustes se cambia entre F-1, F-2 y F-3 y la **misma** captura borrador continúa en
   el mismo estado de la máquina (sin pérdida de datos).
5. El flujo completo corre en `swift test` con adaptadores falsos (sin cámara) y produce
   un paquete que valida contra `capture.schema.json`.
6. El prototipo HTML aprobado y la app recorren la misma secuencia de estados para los
   mismos eventos (comparación manual de ≥ 3 caminos, registrada en VERIFICATION.md).
7. Ningún cambio de comportamiento en el paquete exportado respecto de hoy (mismo schema,
   mismo hash) salvo decisión de contrato.

## 9. Riesgos

- **Sobre-ingeniería antes de la hackatón.** Mitigación: etapa 1 mínima = JSON + intérprete
  + F-2; el resto se suma sólo con prototipo aprobado.
- **Tres presentaciones = tres veces los bugs de UI.** Mitigación: componentes compartidos
  y reglas en la máquina; AA-8 limita el selector a desarrollo.
- **Flujo declarativo demasiado rígido para F-2** (donde el orden es libre). Mitigación:
  en F-2 los estados `documentType/mesa/pages/values` se modelan como región paralela o
  como un solo estado `editing` con guardas al salir (decidir en AA-9/prototipo).
- **Deriva prototipo ↔ app.** Mitigación: AA-3 (mismo JSON) y criterio 6.
- **Rust/UniFFI prematuro** desplaza tiempo de producto. Mitigación: disparadores
  explícitos de etapa 3.
- **Legal/neutralidad.** F-3 tienta a registrar quién cargó: la máquina no tiene campo de
  identidad y el contrato no lo admite; `electoral_counsel` revisa el prototipo de F-3.
- **Datos personales.** Sin cambios: las fotos siguen en el `EvidenceStore` protegido.

## 10. Fuentes

- Elm Architecture: <https://guide.elm-lang.org/architecture/>
- The Composable Architecture (Point-Free): <https://github.com/pointfreeco/swift-composable-architecture>
- Crux (Red Badger): <https://redbadger.github.io/crux/> · <https://github.com/redbadger/crux>
- UniFFI (Mozilla): <https://mozilla.github.io/uniffi-rs/latest/> · <https://github.com/mozilla/uniffi-rs>
- Ferrostar, SDK Rust multiplataforma (Stadia Maps): <https://stadiamaps.com/blog/ferrostar-building-a-cross-platform-navigation-sdk-in-rust-part-1/>
- Kotlin Swift export (Alpha): <https://kotlinlang.org/docs/native-swift-export.html> · roadmap KMP ago. 2025: <https://blog.jetbrains.com/kotlin/2025/08/kmp-roadmap-aug-2025/>
- SCXML 1.0, W3C Recommendation (2015): <https://www.w3.org/TR/scxml/>
- XState v5, testing y `xstate/graph`: <https://stately.ai/docs/testing> · <https://stately.ai/docs/xstate-graph>
- Design Tokens Format Module (DTCG): <https://www.designtokens.org/TR/2025.10/format/>
- Server-driven UI, Airbnb Ghost Platform: <https://medium.com/airbnb-engineering/a-deep-dive-into-airbnbs-server-driven-ui-system-842244c5f5>

## Ajustes por el chequeo de electoral_counsel (31/10/2026)

Informe: [checks/electoral_counsel.md](checks/electoral_counsel.md). Se incorporan como
requisitos las mitigaciones no bloqueantes. Los ⛔ quedan para el autor.

- **Guardas legales en datos** (A2): el `capture.flow.json` va embebido en la app, o
  firmado si algún día se descarga. Los vectores prueban que no se puede saltear el
  aviso de Boleta Única ni editar tras confirmar.
- **Canales de terceros** (A3): ningún workflow, bot ni asistente envía fotos o datos
  de mesas por mensajería de terceros. Esos canales sólo guían el flujo; la evidencia
  viaja por el canal propio.
- **Traspaso en F-3** (A4): el modo traspaso sólo muestra la carga a ciegas, sin
  acceso a la galería ni a otras capturas.
