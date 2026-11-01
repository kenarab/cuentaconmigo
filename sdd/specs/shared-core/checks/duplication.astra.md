<!-- reviewer: Astra (gpt-6-astra via codex exec, read-only) · lens: duplication · target: sdd/specs/shared-core · revision: 0156dc8 · date: 2026-11-01 16:24 -03 -->

## 1. **Alcance revisado**

Revisión independiente de Codex sobre **`0156dc8`**, obtenido con `git rev-parse --short HEAD`; coincide con la revisión solicitada. Sin cambios locales en las rutas revisadas. El archivo no versionado `.agents/review-prompts/duplication.md` quedó fuera del análisis.

Leí `AGENTS.md`, el rol `reviewer`, la SPEC `shared-core`, los contratos relacionados, las implementaciones y sus pruebas. Abreviaturas usadas:

| Prefijo | Ruta |
|---|---|
| `C/` | `core/src/` |
| `A/` | `android/app/src/main/java/ar/cuentaconmigo/app/` |
| `I/` | `ios/CuentaConmigo/` |
| `T/` | `ios/TelegramaCore/Sources/TelegramaCore/` |
| `P/` | `design/prototypes/` |
| `J` | `contracts/flows/flow-machine.js` |

**Resultado:** la duplicación restante excede las pantallas y la doble carga que declara la [SPEC:75](/home/alephbet/home.codex/git/cuentaconmigo/sdd/specs/shared-core/SPEC.md:75). La migración de iOS está explícitamente pendiente; eso es una decisión registrada, no un incumplimiento nuevo. Los ⛔ siguientes bloquean declarar cumplido el objetivo de lógica compartida.

## 2. **Hallazgos**

Ordenados por beneficio esperado. Las API sugeridas son **propuestas**, no decisiones; esfuerzo y riesgo de las alternativas figuran en §3.

1. **⛔ Navegación y confirmación tienen varias autoridades, incluso dentro del núcleo.**  
   **Ubicación/fuente:** `A/EditorScreen.kt:138–186,290–302`; `I/Views/CaptureEditorView.swift:94–110,134–160,286–318`; `C/api.rs:425–434,583–624`; `C/capture.rs:254–269`; `C/flow.rs:224–243,355`; contrato `contracts/flows/capture.flow.json:38–104`.  
   Ambas apps mantienen pasos, condiciones de botones y confirmación propios. No encontré llamadas al flujo compartido en sus fuentes. En Rust, `FlowSession` tiene un contexto separado de `Capture` y del almacenamiento. **Consecuencia:** F-1 permite avanzar sin las guardas del contrato; con avisos, `Capture::confirm` admite una justificación de un carácter y el flujo exige cinco. La exigencia de imagen está en `Core::confirm`, pero falta en `Capture::confirm`; `core/tests/contracts.rs:94–104` incluso confirma una captura sin páginas.  
   **Destino/API propuesta:** núcleo, `open_capture_session(id, presentation) -> CaptureSession` y `dispatch(event, payload) -> CaptureViewState { detail, step, actions, effects }`, con persistencia coordinada y reglas del flujo vigente.

2. **⛔ Doble carga implementada cuatro veces, con resultados distintos.**  
   **Ubicación/fuente:** `C/flow.rs:155–180`; `J:209–228`; `I/Views/DoubleEntryView.swift:41–42,63–75`; `A/EditorScreen.kt:308–339`.  
   Se repiten comparación de votantes, suma por categoría y diferencias. Swift/Kotlin sustituyen faltantes por cero; Rust/JS producen un total incompleto. Android tampoco exige completar la segunda carga antes de comparar. **Consecuencia:** una categoría vacía puede aparecer coincidente con cero; las pantallas no conservan los estados `pending`/`matched` ni su invalidación al editar. El contrato sí los define en `contracts/flows/README.md:138–156`.  
   **Destino/API propuesta:** núcleo, `SecondEntry { votantes: Option<i64>, totals: Map<String, Option<i64>> }` y `Comparison { complete, mismatches: Vec<Mismatch> }`, expuestos desde la sesión del punto 1.

3. **⚠️ Modelo, validación y serialización siguen duplicados en Swift y JS.**  
   **Ubicación/fuente:** `C/capture.rs:12–270` ↔ `T/Capture.swift:3–175`; `C/template.rs:5–88` ↔ `T/FormTemplate.swift:3–53`; `C/validation.rs:32–96` ↔ `T/Validation.swift:23–77` ↔ `J:76–131`; `P/escrutinio/index.html:221–228,330–347`.  
   Se repiten tipos, valores/orígenes, bloqueo, conversión a entrada de validación, JSON, campos obligatorios, negativos, votantes/electores y sumas. **Consecuencia:** cada corrección requiere varios cambios. Ya difieren ante `required` omitido: Rust/Swift asumen `true`; JS exige `=== true`. El prototipo anterior también mantiene una variante experimental de vacíos como cero.  
   **Destino/API propuesta:** reutilizar `Core::capture`, setters y confirmación; exponer `validate_values(template_id, input) -> Vec<IssueRecord>`. Conservar adaptadores de representación cuando los contratos difieran; no cambiar su significado para unificarlos.

4. **⚠️ Lecturas, aceptación humana, referencias y totales se reinterpretan en varias capas.**  
   **Ubicación/fuente:** `C/server.rs:35–42`; `C/api.rs:531–571`; `I/Services/ScrutinyClient.swift:51–91`; `I/Views/CaptureEditorView.swift:392–417,440–449`; `I/Views/ReadingReviewView.swift:85–134,303–309,357–364`; `server/readings.py:224–278,300–334`; `A/EditorScreen.kt:113–126,266–277`.  
   Se repiten estados `read/empty/unreadable`, identificación de campos, campos pendientes, prioridad del valor humano y agregación por categoría. Dentro de `ReadingReviewView`, la suma y los faltantes se calculan tanto en `writtenCheck` como en `footer`. **Consecuencia:** Android aplica lecturas inmediatamente; iOS espera el cotejo. La API Rust además omite cajas, máscaras y otros datos usados por ese cotejo, por lo que reemplazar el cliente Swift directamente perdería funcionalidad.  
   **Destino/API propuesta:** núcleo, `ReviewSession::preview(readings, corrections) -> ReviewState`, `accept_review(id, result)` y `category_totals(values) -> Vec<CategoryTotal { sum, missing, invalid }>`. Mantener separada la búsqueda probabilística del servidor: no equivale a validar valores confirmados.

5. **⚠️ Ejemplos y elección de plantilla están duplicados y ya divergen.**  
   **Ubicación/fuente:** `A/CoreHolder.kt:36–55`, `A/EditorScreen.kt:84,202–212`; `I/Model/SampleTelegram.swift:7–34`, `I/Views/CaptureEditorView.swift:453–468`; `C/flow.rs:296–313`; `P/flujo/index.html:292–299,701`; SPEC `shared-core:26,38`.  
   Se repiten manifiesto, mesa, tipo y asociación elección/plantilla. **Consecuencia:** Android cambia `readingTemplate` para leer un ejemplo de 2015, pero conserva la plantilla de captura predeterminada; iOS puede sustituirla antes de agregar páginas. El manifiesto prometido no está en la API del núcleo.  
   **Destino/API propuesta:** `samples(manifest_json) -> Vec<SampleRecord>` y `apply_sample(id, sample_id, image_bytes) -> CaptureDetail`, con selección de plantilla y condiciones centralizadas.

6. **⚠️ Hay dos clientes HTTP completos y dos políticas de conexión.**  
   **Ubicación/fuente:** `C/server.rs:66–163` ↔ `I/Services/ScrutinyClient.swift:22–129`; `C/api.rs:473–518,575–578` ↔ `I/Services/ScrutinyClient.swift:137–164`, `I/Views/ServerSettingsView.swift:54–62`, `I/Views/CaptureEditorView.swift:423–435`.  
   Se duplican URL base, Bearer, timeout, errores, alta, subida en dos pasos, comprobantes, consulta OCR, deduplicación y detección de finalización. **Consecuencia:** distinto tratamiento de respuestas y errores; `Core::ocr_numbers` pierde la distinción entre “pendiente” y “terminado sin números” que Swift conserva.  
   **Destino/API propuesta:** usar `connect`, `connect_if_needed`, `send_capture`, `read_cells`; exponer `ocr_status(id) -> OcrResult { finished, numbers }`. Keychain y lectura de configuración del paquete quedan como adaptadores nativos.

7. **⚠️ Almacenamiento y decisiones de borrado se repiten.**  
   **Ubicación/fuente:** `C/store.rs:33–142` ↔ `I/Model/CaptureStore.swift:25–142`; `A/HomeScreen.kt:75–105` ↔ `I/Views/HomeView.swift:27,46–52`; `P/flujo/index.html:416,506,676`; `P/escrutinio/index.html:406,562`. Hash: `C/capture.rs:275–276`, `T/Hashing.swift:4–7`, `server/scrutiny_server.py:304,371`.  
   Se repiten carpetas, JSON, orden, páginas inmutables, comprobantes, detección de envío y archivos exportables. **Consecuencia:** el prototipo dice que ninguna confirmada se borra; las apps y `Store` permiten borrar confirmadas no enviadas. Las correcciones de cotejo de iOS aún no tienen equivalente Rust.  
   **Destino/API propuesta:** reutilizar `Store`; agregar `deletion_policy(id) -> DeletionPolicy { allowed, reason, confirmation }` y `load/save_review_corrections`. Compartir el hash de evidencia es posible; la verificación del servidor debe seguir ejecutándose en su límite de confianza.

8. **⚠️ Nómina, cascadas y formato de mesa se resuelven varias veces.**  
   **Ubicación/fuente:** `C/nomina.rs:29–34,62–98`; `I/Model/PollingPlaces.swift:5–59`; `I/Views/MesaPicker.swift:15–17,25–32,43–66,77–81`; `A/MesaPicker.kt:34–77`; `P/flujo/index.html:280–288,598–613,689–698`.  
   Se duplican expansión de rangos, localización, búsqueda, selección de circuito, restauración y reinicio de descendientes. Swift y Kotlin repiten `%05d`; JS usa el número sin ese relleno. **Consecuencia:** búsquedas distintas —Rust admite palabras y número de mesa; iOS busca la frase— y códigos presentados de manera desigual. Dentro de Rust, `has_table` y `locate` vuelven a recorrer rangos.  
   **Destino/API propuesta:** aprovechar `districts/sections/places/locate`; agregar `select_table(district, section, place, number) -> MesaRecord` y `update_selection(selection, change) -> MesaSelection`.

9. **⚠️ Normalización OCR y entrada manual tienen múltiples implementaciones.**  
   **Ubicación/fuente:** `C/digits.rs:4–28` ↔ `T/DigitNormalizer.swift:6–24` ↔ `J:47–68`; entrada manual en `A/EditorScreen.kt:274,317–320`, `I/Views/CaptureEditorView.swift:348–350`, `I/Views/ReadingReviewView.swift:66–67`, `I/Views/DoubleEntryView.swift:23,66`, `P/flujo/index.html:653–656,741`. Extracción OCR: `I/Services/TextRecognizer.swift:17–20`, `server/scrutiny_server.py:159`, `server/readings.py:200–208`.  
   **Consecuencia:** diferencias en caracteres admitidos, truncamiento, parseo y longitudes; JS usa `parseInt`, la carga principal nativa limita a nueve dígitos y la segunda carga no aplica ese mismo límite.  
   **Destino/API propuesta:** `normalize_digits(text)` ya existe; sumar `parse_manual_value(text) -> ParsedValue` y `extract_numbers(tokens, policy)`. **No** confundir `server/digits.py::normalize`, que normaliza imágenes, con el normalizador de texto.

10. **⚠️ Etiquetas, mensajes y decisiones de presentación no tienen fuente común.**  
    **Ubicación/fuente:** `C/api.rs:195–217`, `C/template.rs:20–26`; `I/Views/CaptureEditorView.swift:483–504`; `I/Views/ReadingReviewView.swift:394–403`; `P/flujo/index.html:256–275,317–324`; `P/escrutinio/index.html:229–247,279–284`. También `A/SettingsScreen.kt:41–49` ↔ `I/Views/SettingsView.swift:4–25` ↔ `contracts/flows/capture.flow.json:5–8`.  
    Se repiten nombres de documentos, presentaciones, resolución ruta→etiqueta, mensajes de validación, vacíos, confirmación, borrado, envío y avisos públicos. Ejemplos literales: aviso de documento en `A/EditorScreen.kt:251`/`I/Views/CaptureEditorView.swift:189`; justificación en `A:223`/`I:83`; inicio vacío en `A/HomeScreen.kt:65`/`I/Views/HomeView.swift:22`.  
    **Consecuencia:** textos y estados divergen: Android muestra “Enviada”; la fila iOS sólo distingue confirmada/borrador. Un cambio editorial requiere varias ediciones.  
    **Destino/API propuesta:** catálogo en `contracts/` y `message(key, args)`, `field_label(template, path, style)`, `presentations()`, `capture_presentation(id)`. Preservar textos aprobados y variantes por contexto.

11. **⚠️ El intérprete Rust es otro mantenimiento manual del intérprete JS.**  
    **Ubicación/fuente:** `C/flow.rs:40–599` ↔ `J:26–561`; `P/flujo/index.html:244,307,331–353`.  
    Además de los ayudantes anteriores, se duplican guardas, acciones, payloads, mezcla de contexto, páginas únicas, invalidación, resolución de estados, validación estructural, transiciones y eventos disponibles. `P/escrutinio/index.html:254–259,330–350,552–592` conserva otra implementación experimental de captura y navegación.  
    **Consecuencia:** pasar los 54 vectores no convierte esas implementaciones en una sola fuente; pueden divergir fuera de esos casos. El prototipo anterior contiene alternativas, no decisiones que deban trasladarse al producto.  
    **Destino/API propuesta:** reutilizar `FlowMachine` mediante una interfaz web —por ejemplo, WASM, **pendiente de aprobación**—: `create_session(flow, template, snapshot)` y `send(event, payload) -> FlowStep`.

12. **⚠️ Quedan duplicaciones internas adicionales en `core/`.**  
    **Fuente y ubicación:** inventario siguiente; se suman a confirmación, comparación, totales y rangos ya señalados.

    | Repetición | Ubicaciones | Consecuencia / API propuesta |
    |---|---|---|
    | Quitar origen y proyectar valores | `capture.rs:233–245`; `flow.rs:58–80` | Dos conversiones equivalentes. `to_validation_input(view)` con adaptadores tipado/JSON. |
    | Completitud de mesa | `validation.rs:35–39`; `flow.rs:225–228` | Cambiar obligatoriedad exige tocar ambos. `mesa_complete(values, template)`. |
    | Suma y completitud de categoría | `validation.rs:66–94`; `flow.rs:164–177` | Difieren con negativos. `CategoryTotal { sum, missing, invalid }`, preservando cómo lo interpreta cada operación. |
    | Rutas y pertenencia a plantilla | `api.rs:196–207,394–398,557–567`; `flow.rs:117–140` | `set_value` acepta rutas desconocidas que el flujo rechaza. `FieldRef::parse(path)` y `template.contains(field)`. |
    | Orígenes y fuentes expresados dos veces | `capture.rs:13–17,64–67`; `flow.rs:87–114`; `api.rs:409–417` | Catálogos/deserialización pueden desalinearse. Conversiones desde los enums existentes. |
    | Registro de acciones y ejecución | `flow.rs:284–375,419–423` | Una acción nueva exige editar dos listas. `Action::parse(name)` y `Action::apply(...)`. |
    | Recorrido de estados y candidatos | `flow.rs:524–529,549–573,580–595` | Consulta y ejecución pueden seleccionar distinto. `candidate_transitions(state, event)`. |
    | Conversión de páginas | `api.rs:355–364,415–420` | Dos constructores del mismo registro. `page_record(capture_id, page)`. |
    | Selección de plantilla predeterminada | `api.rs:233–234,293,318,584` | Repetición del fallback. `resolve_template(id)`. |
    | Bloquear/cargar/mutar/guardar | `api.rs:374–434,550–571` | Manejo transaccional repetido. `mutate_capture(id, operation)`. |
    | Asegurar conexión y error | `api.rs:507–510,523–526` | Bloque literalmente repetido. `connected_client() -> Result<ServerClient>`. |
    | Infraestructura y preparación de pruebas | `core/tests/contracts.rs:8–17,93–118`; `flow.rs:8–10`; `store_server.rs:10–17` | Mantenimiento repetido de fixtures. `tests/common::{read, template, filled_capture}`; conservar aserciones independientes. |

    Los registros UniFFI que adaptan tipos internos no son, por sí solos, lógica duplicada: conviene centralizar conversiones, no forzar estructuras incompatibles a ser una sola.

13. **⚠️ También hay duplicación interna fuera de Rust, de menor prioridad.**  
    **Ubicación/fuente:** `server/digits.py:100–110,118–128` repite carga, segmentación, normalización e inferencia; `server/readings.py:185–186` invoca ambas rutas para una celda. `server/train_digits.py:59–65` repite el avance neuronal de `server/digits.py:32–39`.  
    **Consecuencia:** trabajo de inferencia duplicado y riesgo de entrenar/evaluar con cálculos distintos. **API propuesta:** primero en Python, `predict_digit_probabilities(image)` y `forward(weights, x, return_cache=False)`; migrarlo a Rust no es necesario para eliminar estas copias.  
    En prototipos se repiten utilidades de presentación: `hhmm`, escape HTML y huellas simuladas (`P/escrutinio/index.html:252–253,278`; `P/flujo/index.html:303–305`; `P/navegacion/index.html:299–300`), y formato porcentual (`P/simulacion-amba/index.html:233–234`). Pueden vivir en un módulo JS común; **las huellas simuladas no deben reemplazar SHA-256**.

14. **✅ Las copias generadas y los adaptadores nativos no justifican otra implementación del negocio.**  
    Verifiqué que `P/flujo/flow-machine.js` coincide exactamente con `J` después del encabezado; lo copia `contracts/flows/export-prototype.js:103–104`. Las dos plantillas de `I/Resources/` coinciden byte a byte con `contracts/templates/`; fuente de copia: `ios/scripts/sync-contracts.sh:5–7`.  
    Cámara, Vision, permisos, compartir, zoom y protección nativa pueden conservar sus adaptadores conforme a SPEC §2. No encontré un equivalente del estimador AMBA ni del alineador OCR completo en `core/`: son funcionalidades distintas, no copias del núcleo.

## 3. **Alternativas**

Costos relativos: **bajo** = extracción localizada; **medio** = módulo y consumidores; **alto** = integración entre plataformas y regresión. No son estimaciones calendario.

| Hallazgo | Alternativa A | Alternativa B |
|---|---|---|
| 1 | Sesión única ligada a captura y persistencia. **Alto**; riesgo de migración de borradores. | Integrar `FlowSession` mediante un adaptador común y mantener temporalmente `Capture`. **Medio**; riesgo de desincronización entre estados. |
| 2 | Comparación dentro de la sesión compartida. **Medio**; riesgo bajo si conserva los vectores. | Exponer primero `compare_entries` puro. **Bajo**; no resuelve por sí solo estados pendientes ni invalidación. |
| 3 | Sustituir `TelegramaCore` por UniFFI y compartir validación con web. **Alto**; riesgo de compatibilidad JSON. | Fachada Swift que delegue gradualmente en Rust. **Medio**; convivencia transitoria de modelos. |
| 4 | Sesión de cotejo común con respuesta completa del servidor. **Alto**; riesgo de perder funciones del cotejo actual. | Extraer referencias, agregados y precedencias como funciones puras. **Medio**; la orquestación seguirá duplicada. |
| 5 | Manifiesto y aplicación del ejemplo en `Core`. **Medio**; riesgo de cambiar de plantilla sobre datos existentes. | Generar catálogos y correspondencias desde una fuente en `contracts/`. **Bajo**; conserva parte de la lógica nativa. |
| 6 | Reemplazar cliente Swift por la API Rust ampliada. **Medio**; riesgo en asincronía y configuración existente. | Fachada Swift delegada endpoint por endpoint. **Medio**; período con dos clientes activos. |
| 7 | `Store` común más protección nativa y correcciones de cotejo. **Alto**; riesgo sobre archivos y comprobantes existentes. | Delegar primero políticas y exportación; migrar E/S después. **Medio**; sigue habiendo dos persistencias. |
| 8 | Selección completa y consultas en Rust. **Medio**; riesgo de alterar restauración y búsqueda. | Usar consultas existentes y compartir sólo formato/selección de mesa. **Bajo**; permanecen cascadas duplicadas. |
| 9 | Parsers distintos para OCR y entrada manual, ambos en Rust. **Medio**; riesgo de cambiar entradas hoy toleradas. | Fuente declarativa de políticas y adaptadores generados. **Medio**; siguen existiendo runtimes diferentes. |
| 10 | Catálogo común consumido por Rust y web. **Medio**; riesgo de perder matices de contexto. | Generar recursos Swift/Kotlin/JS desde el catálogo. **Medio**; exige controlar regeneración. |
| 11 | Núcleo puro accesible desde web. **Alto**; riesgo de empaquetado y compatibilidad del prototipo local. | Mantener JS como referencia y ampliar pruebas diferenciales. **Medio**; reduce divergencias, no elimina la duplicación. |
| 12 | Extraer ayudantes por responsabilidad dentro de Rust. **Medio**; riesgo bajo salvo payloads y confirmación. | Refactorizar sólo las repeticiones con divergencias observadas. **Bajo**; deja deuda mecánica explícita. |
| 13 | Compartir preprocesamiento/inferencia Python y utilidades JS. **Bajo/medio**; riesgo de cachés mutables durante entrenamiento. | Mantener entrenamiento separado con comparación numérica y prototipos históricos congelados. **Bajo**; conserva copias, pero limita su mantenimiento activo. |

Ninguna alternativa requiere cambiar el significado de los contratos. Las diferencias entre experimentos, dominio persistido y flujo deben quedar explícitas; no corresponde resolverlas modificando silenciosamente reglas o vectores.

## 4. **No verificado**

- No ejecuté builds, pruebas que escriben archivos, servidor, OCR ni pruebas en dispositivos. Revisé sus fuentes; no ratifico los resultados históricos declarados.
- Confirmé que existen **8 vectores de validación, 17 de dígitos y 54 de flujo**; no equivalen a cobertura de las pantallas.
- No verifiqué migración de capturas existentes, rendimiento, bindings binarios ni recursos privados.
- No hice `fetch`, sincronización ni consultas de PR/issues, por la restricción expresa de solo lectura y sin red.
- Los textos legales se identificaron como copias editoriales; no se evaluó su corrección jurídica.
- El inventario es estático: no acredita equivalencia semántica exhaustiva para todas las entradas posibles.

## 5. **Veredicto**

**⛔ El objetivo de lógica compartida todavía no está cumplido: priorizar sesión/confirmación y doble carga, y ampliar la API antes de sustituir iOS.**