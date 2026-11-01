<!-- reviewer: Fable (claude-fable-5-1 via Claude Code Agent) · lens: duplication · target: sdd/specs/shared-core · revision: 0156dc8 · date: 2026-11-01T16:19-03:00 -->

# Revisión · duplicación de código · núcleo compartido

Lente: [.agents/review-prompts/duplication.md](../../../../.agents/review-prompts/duplication.md).
Objetivo del autor (1/11/2026): el mismo código para todas las plataformas; API interna
amplia en `cc_core`; cada plataforma sólo pantallas y hardware. Lectura sin cambios en el
repo; sin compilar ni ejecutar tests. Propuestas, no decisiones.

## 1. Alcance revisado

Revisión `0156dc8` (main, tras el merge del PR #28).

- `core/src/{api,capture,template,validation,digits,flow,store,server,nomina,lib}.rs`, `core/tests/*`.
- `android/app/src/main/java/ar/cuentaconmigo/app/*.kt`, `android/app/build.gradle.kts`, `android/app/src/test/.../CoreApiTest.kt`.
- `ios/TelegramaCore/Sources/**/*.swift`, `ios/CuentaConmigo/{Model,Services,Views}/*.swift`, `ios/scripts/*.sh` (fase 6 pendiente: se trata como "a reemplazar").
- `server/{scrutiny_server,readings,digits,eval_readings}.py`.
- `design/prototypes/flujo/index.html` y generados (`flow-machine.js`, `capture.flow.js`), `contracts/flows/{flow-machine,export-prototype}.js`, `contracts/flows/capture.flow.json`, `contracts/schemas/capture.schema.json`.

Convención de esfuerzo: S < medio día, M 1-2 días, L > 2 días. Ninguna propuesta cambia el
significado de los contratos; donde se sugiere **agregar** un campo a un contrato se dice.

## 2. Hallazgos

Ordenados por beneficio. Severidad: ⛔ bloquea / ⚠️ riesgo (duplicación con divergencia o
regla fuera del núcleo) / ✅ ok o menor.

### H1 ⚠️ El intérprete del flujo (fase 2) no lo usa ninguna plataforma; las decisiones del statechart están reescritas en Kotlin y Swift

- **Dónde:** `core/src/api.rs:583-625` (`Core::flow`, `FlowSession`) no tiene ningún llamador en `android/` ni `ios/` (`grep FlowSession|\.flow(` → 0). Las guardas y transiciones de `contracts/flows/capture.flow.json` se reimplementan en:
  - `android/.../EditorScreen.kt:139-168` (secciones = pasos de F-1), `:179-187` (Anterior/Siguiente), `:162-165` (avisos → pedir justificación = guardas `noWarnings`/`justificationGiven`), `:295` (botón de doble carga sólo en F-3 = `presentationSupportsDoubleEntry`), `:296` (`pages.isNotEmpty() && issues.none{isError}` = `hasPages` + `noErrors`).
  - `ios/CuentaConmigo/Views/CaptureEditorView.swift:134-164` (`wizardStep`), `:298-312` (misma triple regla).
  - El único consumidor del statechart es el prototipo `design/prototypes/flujo/index.html`.
- **Consecuencia:** la pieza más cara del núcleo (599 líneas, 54/54 vectores) no gobierna la app; la regla "paso 1 de N", el orden de pasos y qué botón se habilita viven tres veces y ya divergen (el prototipo tiene 5 pasos fijos; Android 4 + categorías; iOS `4 + categories.count`). Cualquier cambio del flujo en el contrato no llega a los teléfonos.
- **Puede ir al núcleo:** sí; es exactamente lo que la SPEC §2 asigna al núcleo ("Flujo F-1/F-2/F-3: intérprete").
- **API propuesta (una de dos, ver alternativas):**
  ```rust
  // (a) sesión ligada a una captura: hidrata el contexto desde Capture y persiste las acciones
  impl Core { pub fn flow_for_capture(&self, id: String) -> Result<Arc<FlowSession>, CoreError>; }
  impl FlowSession { pub fn steps(&self) -> Vec<StepRecord>; }   // StepRecord { id, title, kind: "document"|"mesa"|"header"|"category"|"review", category_id: Option<String> }
  // (b) mínimo sin flujo: exponer las guardas ya calculadas
  pub struct CaptureDetail { /* + */ pub can_confirm: bool, pub needs_justification: bool, pub supports_double_entry: bool, pub confirm_hint: String }
  ```
- **Esfuerzo:** (a) L; (b) S. **Riesgo:** (a) el contexto del flujo (`pages[].id`) y `Capture` (`pages[].file/sha256`) tienen formas distintas; hay que definir el mapeo y decidir si el contexto JSON reemplaza o acompaña a `capture.json`. Sin cambio de contrato. (b) deja el flujo sin usar, pero saca la triple regla de las pantallas hoy.

### H2 ⚠️ La comparación de doble carga F-3 (ya anotada en la SPEC) está dos veces en pantallas y difiere del núcleo

- **Dónde:** `core/src/flow.rs:155-181` (`compute_mismatches`, probado por vectores) vs `EditorScreen.kt:330-338` y `DoubleEntryView.swift:581-594`. Textos distintos entre plataformas: "la primera carga suma X, la segunda dice Y" (Kotlin) vs "la suma de la primera carga da X, la segunda dice Y" (Swift); el prototipo muestra tabla Carga 1/Carga 2 con ✓/✗.
- **Consecuencia:** la única regla de F-3 que importa (qué cuenta como diferencia) no pasa por el núcleo ni por los vectores `capture-flow.json` en los teléfonos. Kotlin suma `it.value ?: 0L` sobre filas incompletas (una categoría incompleta compara contra una suma parcial), mientras el núcleo la trata como `null`.
- **API propuesta:**
  ```rust
  #[derive(uniffi::Record)] pub struct SecondEntry { pub votantes: Option<i64>, pub totals: Vec<CategoryTotal> } // CategoryTotal { category: String, total: Option<i64> }
  #[derive(uniffi::Record)] pub struct MismatchRecord { pub path: String, pub label: String, pub first: Option<i64>, pub second: Option<i64>, pub message: String }
  impl Core { pub fn compare_second_entry(&self, id: String, second: SecondEntry) -> Result<Vec<MismatchRecord>, CoreError>; }
  ```
  Reutiliza `flow::compute_mismatches` sobre `Capture` (construyendo el contexto con `validation_input`).
- **Esfuerzo:** S. **Riesgo:** bajo. Si se adopta H1(a), esto sale solo con el evento `secondValues`.

### H3 ⚠️ El enum de presentación (F-1/F-2/F-3) está en Kotlin, Swift y el prototipo, con claves y rótulos distintos

- **Dónde:** `SettingsScreen.kt:353-357` (claves `f1/f2/f3`, rótulo "F-2 · Imagen y campos"), `SettingsView.swift:294-316` (raw values `"F-1"/"F-2"/"F-3"`, persistidos en `@AppStorage("presentation")`), `index.html:259` (`PRES_HELP`), y el contrato `contracts/flows/capture.flow.json` → `presentations.f2.label = "F-2 · Imagen + campos"`, `supportsDoubleEntry`.
- **Consecuencia:** tres rótulos para la misma cosa; iOS persiste una clave que el flujo no reconoce (`"F-2"` ≠ `"f2"`), así que al migrar a `Core::flow("F-2")` fallaría `payloadHasPresentation`. `supportsDoubleEntry` del contrato se ignora y se vuelve a codificar como `presentation == DOUBLE`. El efecto `persistSettings` del flujo lo hace cada plataforma por su cuenta (SharedPreferences `settings/presentation` vs UserDefaults).
- **API propuesta:**
  ```rust
  #[derive(uniffi::Record)] pub struct PresentationRecord { pub id: String, pub label: String, pub detail: String, pub supports_double_entry: bool }
  impl Core {
      pub fn presentations(&self) -> Vec<PresentationRecord>;   // lee CAPTURE_FLOW.presentations
      pub fn presentation(&self) -> String;                      // persistida por el núcleo (archivo en data_dir o SecretStore), default flow.context.presentation
      pub fn set_presentation(&self, id: String) -> Result<(), CoreError>;
  }
  ```
  `detail` no existe en el contrato: queda en el núcleo, o se **agrega** `description` a `presentations.*` del flow JSON (campo nuevo, no cambia semántica; decisión del autor).
- **Esfuerzo:** S. **Riesgo:** iOS necesita migrar el valor guardado ("F-2" → "f2") al pasar al núcleo.

### H4 ⚠️ Los textos de validación están en tres lugares y no dicen lo mismo

- **Dónde:** `core/src/api.rs:195-218` (`issue_message`), `CaptureEditorView.swift:483-506` (`describe`, a reemplazar en fase 6), `index.html:270-276` (`MSG`, el texto **aprobado en el prototipo**).
- **Consecuencia:** para `missing_mesa` el núcleo dice "Falta Distrito.", el prototipo "Falta el dato de mesa: Distrito." y iOS "Falta Distrito"; para `category_total_mismatch` el prototipo muestra la suma y el total ("la suma de las filas (123) no coincide con el total de votantes (120). Si el documento dice eso, podés confirmar igual…"), que es mejor UX (regla del AGENTS.md), y el núcleo no. La app Android ya se aparta del prototipo aprobado.
- **Puede ir al núcleo:** ya está; falta que sea la única copia y que tome los textos del prototipo.
- **API propuesta:** mantener `IssueRecord.message`, pero calcularlo con acceso a valores: `fn issue_message(issue: &ValidationIssue, c: &Capture, t: &FormTemplate) -> String` (interno; sin cambio de firma UniFFI). Opcional: `IssueRecord { pub values: Vec<i64> }` para que la pantalla resalte.
- **Esfuerzo:** S. **Riesgo:** nulo; los códigos y rutas (contrato) no cambian.

### H5 ⚠️ Rótulos de tipo de documento repetidos y, en Android, la lista de tipos ignora la plantilla

- **Dónde:** `core/src/template.rs:20-28` (`DocumentType::label`), `EditorScreen.kt:241` (`listOf("telegrama" to "Telegrama", "acta" to "Acta", "certificado" to "Certificado")`), `FormTemplate.swift:264-270`, `index.html:256-258` (`DOCTYPE_LABEL/SHORT/HELP`).
- **Consecuencia:** `TemplateRecord.document_types` (api.rs:69, 299) ya trae id + rótulo y Android no lo usa; si una plantilla restringe `documentTypes`, Android ofrece los tres igual. El prototipo además tiene rótulo corto y ayuda por tipo que ninguna app muestra.
- **API propuesta:** `OptionRecord { id, label, short_label: Option<String>, help: Option<String> }` o un `DocumentTypeRecord` propio; textos en `template.rs`. Alternativa de contrato: **agregar** `documentTypeLabels` a `contracts/templates/*.json` (campo nuevo; hoy la plantilla sólo lista ids).
- **Esfuerzo:** S. **Riesgo:** nulo.

### H6 ⚠️ Formato de mesa `"%05d"` y rótulo "Mesa N" calculados en cada plataforma

- **Dónde:** `MesaPicker.kt:276, 287, 289`, `MesaPicker.swift:240`; el núcleo devuelve `TableRecord { mesa: i64, circuito }` (api.rs:127-131) y obliga a formatear afuera. Ninguna parte de `contracts/` define el cero a la izquierda (`capture.schema.json:62-74` → `mesa: string` sin `pattern`); la convención sólo se ve en `samples.json` ("00001").
- **Consecuencia:** una regla de datos (cómo se escribe el código de mesa que viaja en la evidencia) vive en dos pantallas; un cambio de criterio (p. ej. 4 dígitos en otra elección) se arregla dos veces.
- **API propuesta:**
  ```rust
  pub struct TableRecord { pub mesa: i64, pub code: String /* "00054" */, pub label: String /* "Mesa 54" */, pub circuito: String }
  impl Core { pub fn mesa_for_table(&self, district: String, section: String, place_code: String, mesa: i64) -> Option<MesaRecord>; }
  ```
  Documentar en `nomina.rs` que ése es el único lugar del formato. No se propone fijar `pattern` en el schema (cambiaría qué paquetes son válidos).
- **Esfuerzo:** S. **Riesgo:** bajo.

### H7 ⚠️ Carga del manifiesto de ejemplos en Kotlin y Swift, con comportamientos distintos; la SPEC lo asigna al núcleo

- **Dónde:** `CoreHolder.kt:85-103` (`Sample`, parseo JSON, `templateId()` elección→plantilla), `SampleTelegram.swift:558-587`, `CaptureEditorView.swift:453-469` (`use`). SPEC §2: "Telegramas de ejemplo (manifiesto)" → núcleo.
- **Consecuencia:** iOS, al usar un ejemplo de 2015, **recrea la captura con la plantilla `balotaje-2015`** (`:460-465`) para que cada casillero tenga campo; Android no (`EditorScreen.kt:206-212`): sólo manda `readingTemplate` al servidor y deja la captura en `generales-2023`, y además `EditorScreen.kt:84` renderiza siempre `core.template(null)` en vez de la plantilla de la captura. Resultado: en Android las lecturas del servidor para 2015 llegan con rutas de agrupaciones 2015 que `apply_readings` descarta (`api.rs:559-567`), y la UX del ejemplo diverge entre plataformas.
- **API propuesta:**
  ```rust
  #[derive(uniffi::Record)] pub struct SampleRecord { pub id: String, pub label: String, pub file: String, pub document_type: String, pub template_id: Option<String>, pub mesa: MesaRecord }
  impl Core {
      pub fn load_samples(&self, manifest_json: String) -> Result<Vec<SampleRecord>, CoreError>; // la plataforma sólo lee el asset
      pub fn use_sample(&self, id: String, sample: SampleRecord, jpeg: Vec<u8>) -> Result<(), CoreError>;
      // use_sample: si no hay páginas y la plantilla difiere, cambia template_id/version (como iOS); set_document_type; set_mesa; add_page(source "sample")
  }
  ```
  y que `Core::capture()` use `template_for(&c.template_id)` también para `TemplateRecord` (agregar `pub fn template_of(&self, id: String) -> TemplateRecord` o incluir `template` en `CaptureDetail`).
- **Esfuerzo:** M. **Riesgo:** `Capture.template_id` pasa a ser mutable mientras no haya páginas; es la misma regla que ya aplica iOS. Datos personales de los ejemplos siguen fuera de Git (sin cambio).

### H8 ⚠️ URL del servidor y alta: el núcleo ya lo cubre; iOS y la build de Android lo repiten

- **Dónde:** núcleo `api.rs:473-502` (`server_url`, `is_connected`, `connect`, `connect_if_needed`, `disconnect`). iOS `ScrutinyClient.swift:137-191` (`ServerSettings`: `bundled` desde `server.json`, `defaultURL` desde Info.plist `CCDefaultServerURL`, Keychain) y `ServerSettingsView.swift:412-425`, todo reemplazable por `Core::new(default_server_url, app_enroll_code, secrets)` + `connect`. Build: `android/app/build.gradle.kts:10-13` parsea `.private/server.json` con una regex; `ios/scripts/install-device.sh:11` lo copia al bundle: dos lectores del mismo archivo privado (aceptable, es tiempo de build).
- **Consecuencia:** nada grave hoy; riesgo de migración en fase 6: el núcleo guarda `scrutinyServerURL` y `scrutinyDeviceToken` por `SecretStore`; iOS tiene la URL en UserDefaults bajo `scrutinyServerURL` (coincide) y el token en Keychain con servicio `com.kenarab.CuentaConmigo.scrutiny` sin clave. El `SecretStore` de iOS debe mapear `TOKEN_KEY` → ese ítem para no desconectar los teléfonos del equipo.
- **Esfuerzo:** S (fase 6). **Riesgo:** pérdida de alta en dispositivos existentes si el mapeo no se hace.
- Nota: Android no ofrece "Desconectar" aunque `Core::disconnect` existe; iOS sí (`ServerSettingsView.swift:398-402`). Divergencia de pantalla, no de regla.

### H9 ⚠️ Comprobantes: el núcleo devuelve JSON crudo y cada plataforma decide cómo mostrarlo

- **Dónde:** `api.rs:124, 370` (`receipts: Vec<String>`), `EditorScreen.kt:302` muestra `"Comprobante: {json crudo}"`; iOS `ScrutinyClient.swift:35-38` decodifica `Receipt` (campos del OpenAPI) sólo para re-serializarlo.
- **Consecuencia:** UX pobre en Android (un JSON en pantalla); si iOS quiere mostrar índice/hash lo parsea de nuevo. La estructura está en `contracts/api/scrutiny-v1.openapi.json`: un solo parser en Rust.
- **API propuesta:** `ReceiptRecord { pub index: u32, pub received_at: String, pub chain_hash: String, pub body_sha256: String, pub raw_json: String }`; `CaptureDetail.receipts: Vec<ReceiptRecord>`; opcional `pub summary: String` ("Comprobante #3 · 2026-11-01 16:02 · a1b2…").
- **Esfuerzo:** S. **Riesgo:** nulo (se conserva `raw_json` tal cual en `receipts.jsonl`).

### H10 ⚠️ Rótulos derivados del estado (título, estado, textos de borrado) calculados por pantalla

- **Dónde:** `HomeScreen.kt:176-184, 199-208`, `EditorScreen.kt:149, 171, 177`, `HomeView.swift:472-476, 505-511`, `CaptureEditorView.swift:37, 98`, `index.html:572, 581`.
- **Consecuencia:** la regla `sent > locked > draft` y sus rótulos ("Enviada"/"Confirmada"/"Borrador", "Mesa sin número") existen por plataforma y ya divergen: iOS no distingue "Enviada" en la lista; el aviso de bloqueo dice "Captura confirmada. Ya no se puede editar." (iOS) vs "Confirmada: ya no se puede editar." (Android).
- **API propuesta:** `CaptureSummary { /* + */ pub status: String /* "draft"|"confirmed"|"sent" */, pub status_label: String, pub title: String /* "Mesa 00054" | "Mesa sin número" */, pub lock_notice: Option<String>, pub delete_prompt: Option<DeletePrompt { title, body, confirm }> }`.
- **Esfuerzo:** S. **Riesgo:** discutible si "textos de pantalla" son pantalla o producto. Los textos del prototipo aprobado son producto (review-pipeline); propongo que todo texto que depende de una **regla** (estado, validación, diferencias, confirmación) salga del núcleo y sólo el "cromo" (botones, títulos de sección) quede en la plataforma.

### H11 ⚠️ Saneado de números tipeados repetido y distinto del normalizador del núcleo

- **Dónde:** `EditorScreen.kt:274, 317, 320` (`filter(Char::isDigit).take(9).toLongOrNull()`), `CaptureEditorView.swift:349-350`, `ReadingReviewView.swift:577-578` (`filter(\.isNumber)…prefix(9)`); el núcleo expone `normalize_digits` (api.rs:448) que además corrige O/l/S/B (`digits.rs`) y nadie lo llama desde Kotlin.
- **Consecuencia:** el límite de 9 dígitos (regla de `digits.json`) está en cuatro lugares; Swift `isNumber` acepta dígitos no ASCII que el núcleo rechaza.
- **API propuesta:** `Core::parse_typed_number(text: String) -> Option<i64>` (sólo dígitos ASCII, máx. 9, vacío → None) junto a `normalize_digits` para OCR.
- **Esfuerzo:** S. **Riesgo:** nulo.

### H12 ⚠️ Lectura asistida sobre la imagen: el núcleo descarta datos que iOS necesita (bloqueo para la fase 6)

- **Dónde:** `server.rs:318-354` (`Reading` sin `cellBox`/`valueBox`; `Readings` sin `image`, `masks`, `alignment.anchorsUsed`; serde ignora esos campos) vs `ScrutinyClient.swift:51-84` y `ReadingReviewView.swift` (440 líneas que los usan). Además `CaptureStore.swift:412-422` (`review-corrections.json`, incluye refs `total.<cat>`) y `ReadingReviewView.swift:604-616` (`writtenCheck`: control del TOTAL escrito) no existen en el núcleo, y `apply_readings` ignora `total.*` (`api.rs:558-567`).
- **Consecuencia:** iOS no puede pasar `ReadingReviewView` al núcleo sin perder el cotejo visual, y el control "suma de filas = TOTAL escrito" (regla de producto, assisted-review §2) quedaría sólo en Swift. La SPEC lista "lecturas por casillero" como hecha pero la cobertura es parcial.
- **API propuesta:**
  ```rust
  pub struct ReadingRecord { /* + */ pub cell_box: Vec<i64>, pub value_box: Option<Vec<i64>> }
  pub struct ReadingsRecord { /* + */ pub image_width: i64, pub image_height: i64, pub anchors_used: u32, pub masks: Vec<Vec<i64>>, pub layout_id: Option<String> }
  impl Core {
      pub fn review_corrections(&self, id: String) -> Vec<ValueRecord>;                 // incluye "total.<cat>"
      pub fn save_review_corrections(&self, id: String, values: Vec<ValueRecord>) -> Result<(), CoreError>;
      pub fn written_total_check(&self, id: String, category: String) -> CheckRecord;   // { ok, sum, missing, total: Option<i64>, message }
  }
  ```
- **Esfuerzo:** M. **Riesgo:** bajo; son campos ya definidos por el servidor (`readings.py:302-333`). Sin cambio de contrato.

### H13 ⚠️ Dentro del núcleo: `api.rs` vuelve a mapear tipos que ya existen y repite ayudantes JSON

- **Dónde:**
  - `MesaRecord` (api.rs:44-49) duplica `capture::Mesa` (capture.rs:28-37); conversión a mano en `:252` y `:384`.
  - `PageRecord` se arma dos veces (`:355-365` y `:415-421`); el ayudante enum→string vía `serde_json::to_value(..).as_str()` aparece tres veces (`:192`, `:362`, `:417`) y `doc_type` (`:187-189`) parsea un enum pasando por `Value::String`.
  - `template_id.as_deref().map(|id| self.template_for(id)).unwrap_or(&self.templates[0])` tres veces (`:293`, `:318`, `:584`).
  - `connect_if_needed()` + `self.client().unwrap()` + el mismo texto de error, dos veces (`:507-516`, `:523-530`).
  - `.map_err(CoreError::msg)` en casi cada línea en lugar de `impl From<StoreError|CaptureError|ServerError|FlowError> for CoreError`.
- **Propuesta:** `#[derive(uniffi::Record)]` directo sobre `capture::Mesa` (coexiste con serde; verificar en build); `impl PageSource { fn as_str() }`, `impl DocumentType { fn id() ; FromStr }`; `fn page_record(&self, id, &Page) -> PageRecord`; `fn template_for(&self, id: Option<&str>) -> &FormTemplate`; `fn connected_client(&self) -> Result<ServerClient, CoreError>`; `From` para los errores.
- **Esfuerzo:** S. **Riesgo:** nulo; refactor interno, los bindings generados no cambian de forma salvo que `Mesa` reemplace a `MesaRecord` (renombre en Kotlin).

### H14 ⚠️ Dentro del núcleo: dos caminos hacia `ValidationInput` y rutas `header.x`/`cells.c.r` parseadas a mano en cuatro lugares

- **Dónde:** `Capture::validation_input` (capture.rs:233-247) vs `flow::plain_values` (flow.rs:58-81). Parseo de rutas con `split('.')` y `match` en `api.rs:197-209` (labels), `:394-399` (`set_value`), `:557-567` (`apply_readings`), y en Swift `CaptureEditorView.swift:440-450`, `ReadingReviewView.swift:905-915`. Pertenencia a plantilla (`t.header_fields.iter().any(|x| x.id == *h)`) en `api.rs:559-563` y `flow.rs:124-135, 220`. El conjunto "todas las rutas de una plantilla" se construye en `api.rs:327-342`, `readings.py:300-301` y `ReadingReviewView.swift:817-819`.
- **Propuesta:**
  ```rust
  pub enum ValuePath { Header(String), Cell { category: String, row: String }, Total(String) }   // FromStr / Display
  impl FormTemplate {
      pub fn contains(&self, p: &ValuePath) -> bool;
      pub fn label(&self, p: &ValuePath) -> String;        // "Presidente · 134 · Unión por la Patria"
      pub fn paths(&self) -> Vec<ValuePath>;
  }
  ```
  `plain_values` y `validation_input` siguen (formas distintas de entrada), pero las búsquedas y rótulos se centralizan.
- **Esfuerzo:** S. **Riesgo:** nulo.

### H15 ✅ Duplicaciones intencionales o aceptables (sin acción, sólo registro)

- `contracts/flows/flow-machine.js` ↔ `core/src/flow.rs`: la referencia JS del contrato y su port; la equivalencia la garantizan los vectores (`capture-flow.json` 54/54 en ambos). `design/prototypes/flujo/flow-machine.js` es copia generada con banner.
- `ios/TelegramaCore/*` ↔ `core/src/{capture,validation,template,digits}.rs`: port 1:1 (líneas 3-177 Swift ≈ capture.rs; Validation.swift ≈ validation.rs; DigitNormalizer ≈ digits.rs; Hashing ≈ `sha256_hex`). El núcleo lo cubre completo; se borra en fase 6, incluidos `ContractTests.swift` (mismos vectores que `core/tests/contracts.rs`) y la copia de plantillas de `ios/scripts/sync-contracts.sh:5-8` (el núcleo las embebe con `include_str!`, `api.rs:15-18`).
- `CaptureStore.swift` ↔ `store.rs`: cubierto (carpeta por captura, páginas inmutables, `receipts.jsonl`, regla de borrado, `export_paths`), salvo `review-corrections.json` (H12). Atención fase 6: pasar a `Core::new` la carpeta Application Support para que `Store::open(..).join("Captures")` encuentre las capturas existentes; ids ya en mayúsculas y fechas ISO-8601 a segundos: compatibles.
- `PollingPlaces.swift` + `MesaPicker.swift:268-273` ↔ `nomina.rs`: cubierto y mejorado (búsqueda sin tildes y por número de mesa; iOS sólo `localizedCaseInsensitiveContains`).
- `ScrutinyClient.swift` ↔ `server.rs`: cubierto salvo H12.
- `server/` (Python): no duplica reglas del núcleo. `readings.py:224` (`sum_check`) es heurística OCR, no validación; `digits.py` es un clasificador, no el normalizador de `digits.json`. El servidor no valida el paquete contra `capture.schema.json` (no es duplicación; se anota).
- `android/.../CoreApiTest.kt` ↔ `core/tests/store_server.rs`: el test Kotlin recorre los bindings; es prueba de integración, no duplicación.
- `android/app/build.gradle.kts:10-13` e `ios/scripts/install-device.sh:11`: dos lectores de `.private/server.json` en tiempo de build; aceptable.
- `capture.rs:288-302` (`iso8601_from_unix` a mano): evitable con un crate de fechas, pero instalar dependencias requiere autorización del autor; se deja.

## 3. Alternativas

| # | A (recomendada) | B | Costo / riesgo |
| --- | --- | --- | --- |
| H1 | (a) `flow_for_capture` + `steps()`; pantallas Kotlin/Swift piden pasos y eventos al núcleo | (b) agregar `can_confirm`, `needs_justification`, `supports_double_entry`, `confirm_hint` a `CaptureDetail` y dejar `FlowSession` para después (o quitarlo de la API hasta que se use) | A: L, define el mapeo contexto↔Capture; B: S, el flujo sigue ocioso pero la regla deja de estar triplicada |
| H2 | `compare_second_entry` reutilizando `compute_mismatches` | resolverlo vía H1(a) con el evento `secondValues` | A: S, bajo; B: depende de H1 |
| H3 | `presentations()`/`presentation()`/`set_presentation()` leyendo el flow JSON; `detail` en el núcleo | **agregar** `description` a `presentations.*` en `capture.flow.json` (campo nuevo, decisión del autor) y dejar el núcleo sin textos propios | A: S; B: S + un cambio aditivo de contrato; en ambas, iOS migra "F-2"→"f2" |
| H4 | `issue_message` con acceso a valores, copiando los textos del prototipo | archivo `contracts/texts/es-AR.json` (nuevo) con todos los textos de reglas, embebido con `include_str!` y usado también por el prototipo | A: S; B: M, pero unifica también H5/H10 y hace revisables los textos por `electoral_counsel` en un solo lugar |
| H5 | Android usa `TemplateRecord.document_types`; `OptionRecord` suma `short_label`/`help` | **agregar** `documentTypeLabels` a las plantillas del contrato | A: S; B: S, aditivo |
| H6 | `TableRecord.code/label` + `mesa_for_table` | fijar `pattern` en el schema | A: S; B: cambia qué paquetes son válidos → **no recomendado** |
| H7 | `load_samples` + `use_sample` con cambio de plantilla como iOS | sólo `load_samples`; dejar el cambio de plantilla como decisión de pantalla | A: M, alinea Android con iOS; B: S, mantiene la divergencia de UX |
| H8 | `SecretStore` iOS mapea `scrutinyDeviceToken` al ítem Keychain existente | aceptar re-alta silenciosa (`connect_if_needed`) al migrar | A: S; B: S, pero consume códigos de alta y genera dispositivos duplicados en el servidor |
| H9 | `ReceiptRecord` parseado en Rust + `raw_json` | sólo `summary: String` | A: S; B: S, menos flexible |
| H10 | campos derivados en `CaptureSummary` | H4-B (archivo de textos) | A: S; B: M |
| H11 | `parse_typed_number` | usar `normalize_digits` también para tipeo | A: S; B: S, pero convierte "l" en 1 al tipear (sorpresa para la persona) |
| H12 | ampliar `ReadingRecord/ReadingsRecord` + correcciones + `written_total_check` | portar `ReadingReviewView` a Compose sin núcleo | A: M; B: duplica 400 líneas de regla visual en Kotlin → **no recomendado** |
| H13 | refactor interno (`From`, `page_record`, `as_str`, `connected_client`) | dejar como está | A: S, cero riesgo; B: deuda que crece con cada método nuevo |
| H14 | `ValuePath` + `FormTemplate::{contains,label,paths}` | dejar como está | A: S; B: ídem |

## 4. No verificado

- No compilé ni corrí `cargo test`, `./gradlew assembleDebug` ni tests JVM; las líneas citadas son de lectura.
- No comprobé que `#[derive(uniffi::Record)]` conviva con `serde` sobre `capture::Mesa` (H13) en uniffi 0.28.3.
- iOS: sin Mac, no verifiqué comportamiento en dispositivo ni los bindings Swift generados.
- No leí `.private/server.json` ni los assets de ejemplo (fuera de Git).
- No evalué si los textos del prototipo (`index.html`) son los aprobados por el autor en el review-pipeline; asumí que el prototipo navegable es la referencia de UX según `sdd/specs/review-pipeline`.
- `android/app/src/main/assets/samples/` y `uniffi/cc_core/cc_core.kt` no están trackeados; no revisé el binding generado.

## 5. Veredicto

⚠️ Sin bloqueos: el núcleo cubre todo TelegramaCore, el guardado, la nómina y el cliente; pero el intérprete del flujo no lo usa ninguna app y las reglas visibles (pasos, confirmación, doble carga, textos, formato de mesa, ejemplos) siguen por plataforma y ya divergen — conviene cerrar H1-H7 y H12 antes de la fase 6 para que iOS migre a una API que no obligue a reescribir Swift dos veces.
