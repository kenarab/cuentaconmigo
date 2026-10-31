# SPEC · Backend de escrutinio: OCR en servidor, espejo oficial y conteo rápido

Estado: **propuesta de diseño (rol `planner`); ninguna decisión tomada.** Resuelve la
decisión D-003 de [mobile-platform](../mobile-platform/SPEC.md) ("backend/recepción
central") y las funcionalidades F-06, F-08 y F-09 de [FEATURES.md](../roadmap/FEATURES.md).
Eje: **D. Jornada y escrutinio** de la [visión](../vision/SPEC.md).
Fecha: 31/10/2026. Aceptación: autor. Chequeo de `electoral_counsel`: **pendiente** (sección 12).

Lo que sigue es una propuesta para el autor: lenguaje, stack, API y arquitectura se
eligen en las decisiones SB-x (sección 9). Nada se instala ni se levanta sin su consentimiento.

## 1. Problema y alcance

El OCR en el teléfono (Vision / ML Kit) sirve como ayuda, pero no alcanza para
extraer con calidad medible los dígitos manuscritos de telegramas, actas y
certificados, ni para comparar motores, ni para procesar las muestras de
[data/ocr-samples](../../../data/ocr-samples/README.md). Además la app hoy no
tiene a dónde enviar la evidencia (E-10/E-11 de [app-screens](../app-screens/SPEC.md)
dicen "envío no configurado").

El pedido del autor: un **servidor local** (primero en su máquina, después accesible
desde afuera) que reciba las capturas de la app, corra OCR y lo que haga falta, y
que distinga **dos escrutinios**:

- **Escrutinio oficial**: espejo de lo que publica la autoridad electoral (provisorio
  y definitivo) y cotejo mesa por mesa contra lo capturado por fiscales.
- **Conteo rápido propio**: una muestra de mesas elegida por sorteo, cargada por
  voluntarios, y una proyección con intervalos que está disponible **antes** que el
  oficial, aunque sólo con algunas mesas.

Relación con el resto del proyecto:

| Pieza | Qué aporta a esta SPEC | Qué recibe |
| --- | --- | --- |
| [docs/hackdash.md](../../../docs/hackdash.md) | El desafío: "una app permite que fiscales y autoridades de mesa escaneen el telegrama y/o acta de su mesa, y una simulación del AMBA muestra cómo se armaría la proyección con muy pocos datos". | El backend es la pieza que une app y proyección; en la hackatón se muestra corriendo local. |
| [telegram-capture](../telegram-capture/SPEC.md) | Paquete de captura inmutable con SHA-256 por página; valores con origen `manual` / `ocr-accepted`. | Un destino para "Enviar" (E-11), OCR de servidor como segunda lectura, cotejo (F-09). |
| App iOS (y Android futura) | Cliente del contrato `capture.schema.json`. | Cola de envíos offline con reintentos; sugerencias OCR del servidor (F-06, opcional). |
| [amba-simulation](../amba-simulation/SPEC.md) | Reproduce las generales 2023 con datos oficiales por mesa de DINE: es la demo de "proyección con pocos datos". | El mismo módulo de proyección (estratificado + intervalos) alimenta la simulación y el conteo rápido real; los datos 2023 sirven para probar el espejo oficial y el cotejo. |
| [contracts/](../../../contracts/README.md) | Schema, plantillas, vectores. | Nuevo contrato: `contracts/api/scrutiny-v1.openapi.yaml` (propuesta, requiere `contract-change`). |
| [participant-protection](../participant-protection/SPEC.md) | Minimización, seudonimato, evidencia sin personas, sin punto único de falla. | Autenticación de dispositivos sin datos personales; copia publicable vs. evidencia preservada. |

Fuera de alcance de esta SPEC: la red ciudadana (civic-network), el acceso público
desde Internet (sección 8: lo configura el autor después), Android, el relevamiento
del formato oficial 2027 (Q1 de telegram-capture).

## 2. Dos escrutinios, un cotejo

```
                 captura (app)            publicación oficial (DINE / CNE)
                      │                            │
                      ▼                            ▼
          ┌──────────────────────┐      ┌──────────────────────┐
          │ Evidencia + OCR +    │      │ Espejo oficial       │
          │ confirmación humana  │      │ provisorio/definitivo│
          └─────────┬────────────┘      └──────────┬───────────┘
                    │ tally confirmado por mesa     │ resultado oficial por mesa
                    ├───────────────┬───────────────┤
                    ▼               ▼               ▼
            ┌──────────────┐ ┌────────────┐ ┌──────────────────┐
            │ Conteo rápido│ │  Cotejo    │ │ Panel oficial    │
            │ (muestra)    │ │ mesa a mesa│ │ (sólo espejo)    │
            └──────────────┘ └────────────┘ └──────────────────┘
             embargo art.71 h   público tras el embargo, sin "fraude"
```

### 2a. Escrutinio oficial (espejo)

- **Fuentes**: resultados por mesa del escrutinio provisorio y del definitivo
  publicados por la autoridad electoral (DINE/CNE), más las imágenes oficiales de
  telegramas cuando se publiquen. Qué formato y URL tendrán en 2027: **a verificar**
  por `electoral_analyst`; en 2023 hubo datos por mesa descargables (los usa la
  simulación AMBA).
- **Procedencia**: cada archivo importado se guarda inmutable con URL, fecha de
  descarga y SHA-256 (mismo criterio que amba-simulation); la normalización genera
  un derivado reproducible y versionado. Nunca se edita lo descargado.
- **Historia**: el provisorio cambia durante la noche; cada importación es una
  **versión** con sello de tiempo. El espejo permite reconstruir "qué decía el
  oficial a las 22:30".
- **Cotejo**: para cada mesa con tally confirmado por personas, se compara celda por
  celda contra el provisorio y, cuando exista, el definitivo. Resultado por mesa:
  `match`, `mismatch` (con las celdas que difieren), `official_missing`,
  `capture_missing`. Las discrepancias **no se califican** como irregularidades:
  se describen (telegram-capture, marco legal 6; en 2025 hubo errores de telegramas
  corregidos en el definitivo, ver MARCO_LEGAL 3).
- El espejo es independiente del conteo rápido: sirve aun sin ninguna captura.

### 2b. Conteo rápido propio (muestra)

Objetivo: tener una estimación con intervalo para la categoría prioritaria
(presidente; otras según plantilla) **con pocas mesas y antes** de que el provisorio
alcance cobertura alta, y además un control externo de ese provisorio.

**Diseño muestral (propuesta, S-3 de amba-simulation decide el modelo):**

1. **Marco**: el padrón de mesas publicado por la autoridad (distrito, sección,
   circuito, mesa, electores). Si en 2027 sólo hay marco por circuito, se estratifica
   a ese nivel.
2. **Estratos**: distrito × sección (en el AMBA: comunas de CABA y 24 partidos),
   opcionalmente por tamaño del circuito. Asignación proporcional a electores con un
   mínimo por estrato; alternativa Neyman si hay varianza histórica (2023).
3. **Sorteo reproducible**: selección sistemática o aleatoria simple dentro de cada
   estrato con un generador determinista (`seed` de 256 bits). La misma semilla y el
   mismo marco producen la misma muestra; el algoritmo y la versión quedan en el
   registro del diseño.
4. **Reemplazos**: por cada mesa sorteada, una lista ordenada de suplentes del mismo
   estrato (mismo sorteo), para cuando no haya voluntario. Las sustituciones se
   registran y se reportan como tasa de reemplazo.
5. **Cobertura**: la mesa de la muestra se cubre con un voluntario (fiscal o autoridad
   que ya está ahí, o persona que fotografía el telegrama expuesto si la normativa
   2027 lo permite: **a verificar**). Mesas sin cobertura = no respuesta; se publica
   la tasa y se corrige por pesos dentro del estrato.
6. **Estimadores**: (i) **de diseño**, sólo mesas de la muestra, estratificado por
   electores, con intervalo (varianza por estrato; bootstrap como control);
   (ii) **postestratificado**, con todas las capturas confirmadas (incluidas las
   oportunistas, fuera de la muestra), etiquetado como secundario porque la llegada
   tiene sesgo. La simulación AMBA muestra exactamente la diferencia entre ambos.
7. **Publicación de la selección** (SB-6): opciones en la tabla de decisiones. La
   recomendación es *commit-reveal*: publicar antes de la elección el SHA-256 de
   (semilla + algoritmo + marco) y revelar la semilla y la muestra después del cierre.
   Evita que alguien presione sobre mesas conocidas y permite auditar que la muestra
   no se eligió después de ver resultados. Los voluntarios reciben su asignación por
   canal privado.

**Qué cuenta**: sólo tallies **confirmados por personas** (sección 4.4). El OCR
solo nunca entra a una estimación.

**Tiempos esperados** (supuestos, a verificar con el calendario 2027): cierre 18:00;
telegramas disponibles para fiscales entre 18:30 y 21:00; publicación oficial del
provisorio desde ~21:00. El conteo rápido se calcula de forma continua desde la
primera carga, pero **no se publica** hasta que vence la ventana del art. 71 inc. h.

### Relación y cotejo entre ambos

| Momento | Conteo rápido | Espejo oficial | Cotejo |
| --- | --- | --- | --- |
| Antes del cierre | sin datos | sin datos | — |
| Cierre → fin del embargo (3 h, a verificar) | se calcula; visible sólo a operadores con registro de acceso | vacío o parcial | interno |
| Tras el embargo | se publica con intervalo, cobertura y método | se espeja a medida que la autoridad publica | público: mesa a mesa, sin calificaciones |
| Definitivo | se cierra y se archiva con el error final | versión definitiva | informe final: precisión del conteo rápido y discrepancias cerradas |

El conteo rápido se **evalúa a sí mismo** contra el oficial (error absoluto por
agrupación, cobertura del intervalo). Ese informe es la rendición de cuentas del
método; con 2023 se puede producir hoy en la simulación.

### Restricción legal (resumen; evaluación en sección 12)

Código Electoral art. 71 inc. h: prohíbe publicar encuestas y proyecciones durante
los comicios y hasta tres horas después del cierre (multa art. 128 bis). **A verificar**
el texto vigente para 2027. Consecuencia de diseño: toda respuesta agregada de la API
lleva un estado de embargo calculado contra la hora oficial de cierre configurada; en
la ventana, los endpoints públicos responden `423 Locked` con el motivo y el momento
de liberación. Los endpoints de **mesa individual** (cotejo) también se embargan por
defecto hasta que `electoral_counsel` diga si un panel parcial cuenta como proyección
(MARCO_LEGAL 4: "consultar").

## 3. Arquitectura propuesta

### 3.1 Componentes

```
 app iOS/Android ──HTTPS──▶ ┌──────────────────────┐
 (cola offline)              │ API /v1 (sin estado)  │──▶ Auth de dispositivos (tokens)
                             └──────┬──────┬────────┘
                                    │      │
                  ┌─────────────────▼┐   ┌─▼────────────────────────┐
                  │ Almacén de blobs  │   │ Base de datos            │
                  │ content-addressed │   │ capturas · OCR · reviews │
                  │ (sha256 → bytes)  │   │ tallies · oficial · log  │
                  └─────────────────▲┘   └─▲──────────▲───────────▲┘
                                    │      │          │           │
                     ┌──────────────┴──────┴──┐  ┌────┴─────┐ ┌──┴──────────┐
                     │ Workers OCR (cola)      │  │ Revisión │ │ Agregador / │
                     │ motor A / motor B …     │  │ humana   │ │ proyección  │
                     └────────────────────────┘  └──────────┘ └─────────────┘
                                                                     ▲
                     ┌───────────────────────────────┐               │
                     │ Importador del espejo oficial  │───────────────┘
                     │ (DINE provisorio / definitivo) │
                     └───────────────────────────────┘
```

| Componente | Responsabilidad | Prototipo (1 máquina) | Escala (N nodos) |
| --- | --- | --- | --- |
| API de ingesta | Validar paquetes contra `capture.schema.json`, recomputar hashes, idempotencia, encolar OCR | 1 proceso HTTP | varios procesos sin estado detrás de un proxy |
| Almacén de evidencia | Blobs inmutables por SHA-256; nunca se sobrescriben ni se borran (salvo orden del autor con registro) | directorio `blobs/ab/cd/<sha256>` con permisos restringidos y cifrado del disco | almacenamiento de objetos S3-compatible (propio), mismo esquema de claves |
| Base de datos | Metadatos, estados, log de auditoría | SQLite en modo WAL | PostgreSQL; mismas migraciones |
| Cola de trabajos OCR | Un trabajo por página y motor; reintentos con backoff; `at-least-once` + resultados idempotentes | tabla `jobs` + worker en proceso aparte | broker (Redis Streams o NATS) y workers horizontales |
| Workers OCR | Motor enchufable (sección 5); salida: texto por región, confianza, versión del motor | 1 worker CPU | N workers CPU/GPU; cada resultado lleva `engine`, `engineVersion`, `modelHash` |
| Revisión humana | Doble carga a ciegas, resolución de diferencias, tally confirmado | web mínima o la propia app | colas por estrato; asignación a revisores sin ver identidades |
| Agregador / proyección | Tallies → estimadores con intervalo; embargo; informe de precisión | mismo código que la simulación AMBA | proceso aparte, caché de agregados |
| Espejo oficial | Importar archivos oficiales versionados; normalizar; cotejar | script de importación manual | importador programado con alertas de cambio de formato |
| Log de auditoría | Evento append-only por cada cambio de estado, encadenado por hash | tabla `events` con `prevHash` | igual, con anclaje periódico del hash raíz publicado |

### 3.2 Modelo de datos (resumen)

- `Capture` (inmutable): el paquete tal como lo mandó la app (`capture.schema.json`),
  `receivedAt`, `deviceId` seudónimo, `status` del servidor.
- `Blob`: `sha256`, `bytes`, `mediaType`, `storedAt`. Una página = un blob.
- `OcrJob` / `OcrResult`: por (blob, engine); regiones con `bbox`, `text`,
  `confidence`; valores normalizados con `normalizeDigits` del contrato. **Siempre
  marcado `origin = ocr`.**
- `Review`: carga humana sobre una captura (`entry = 1 | 2`), ciega respecto de la otra
  y del OCR; `resolvedBy` es un seudónimo de revisor.
- `Tally` (derivado, versionado): valores por celda **confirmados** para una mesa y una
  categoría, con `confirmationMethod ∈ {app-confirmed, double-entry, single-review}`
  y referencia a las capturas y reviews que lo sustentan. Si llegan dos capturas de
  la misma mesa que difieren, el tally queda `disputed` hasta revisión.
- `OfficialImport` / `OfficialResult`: versión de importación, procedencia, valores
  por mesa y categoría.
- `Comparison`: tally vs. oficial, por celda.
- `SampleDesign` / `SampleMesa`: diseño, semilla (sellada), estratos, mesas sorteadas,
  suplentes, estado de cobertura.
- `Event`: `seq`, `at`, `actor` (seudónimo), `type`, `payload`, `prevHash`, `hash`.

Regla transversal: **lo extraído automáticamente (`OcrResult`) nunca se mezcla con lo
confirmado por personas (`Review`, `Tally`)**; viven en tablas distintas, se
exponen en rutas distintas y toda respuesta indica cuál es cuál.

### 3.3 Idempotencia, reintentos y carga offline

- La app genera el `id` (UUID) y los hashes; el servidor los **recomputa** y rechaza
  (`422`) si no coinciden.
- Envío en dos pasos para redes malas: (1) `POST /v1/captures` con el JSON del
  paquete → responde qué blobs faltan; (2) `PUT /v1/blobs/{sha256}` por cada página
  (reintentable; un blob que ya existe responde `200` sin reescribir). Una captura
  pasa a `complete` cuando llegó el último blob.
- Reenviar el mismo paquete devuelve `200` con el mismo recurso; el mismo `id` con
  contenido distinto devuelve `409` (nunca se reemplaza evidencia).
- `Idempotency-Key` opcional para los POST que no tienen id natural (reviews).
- La app encola envíos (E-11) y reintenta con backoff exponencial; el servidor tolera
  llegadas horas después del cierre y conserva `capturedAt` (del teléfono) y
  `receivedAt` (del servidor) por separado.

### 3.4 Cadena de custodia y auditoría

- Blob → hash → paquete → captura → review → tally → agregado: cada eslabón referencia
  al anterior por id y hash; se puede recomputar de punta a punta.
- El log de eventos es append-only y encadenado; el hash raíz se puede publicar
  periódicamente (en el repo, o en el futuro en la red ciudadana) para que cualquiera
  verifique que no se reescribió la historia (SB-9).
- Toda lectura de evidencia cruda (imágenes) por un operador queda registrada.
- Exportación auditable: un verificador externo puede recibir el paquete + blobs +
  eventos y recomputar hashes sin acceso al servidor.

### 3.5 Autenticación de voluntarios sin datos personales

- **Inscripción por código**: el operador emite códigos de inscripción de un solo uso
  (por campaña de cobertura o por estrato, **nunca por partido**: el partido del fiscal
  es dato sensible, Ley 25.326 arts. 2 y 7). La app canjea el código por un
  `deviceToken` ligado a un `deviceId` aleatorio.
- Sin nombre, DNI, teléfono ni ubicación. El código indica a qué mesas de la muestra
  puede reportar cobertura, nada más.
- Opcional (SB-8): la app firma el paquete con una clave generada en el dispositivo
  (Secure Enclave / Keystore); el servidor guarda la clave pública por `deviceId`.
  Permite probar que una captura vino de un dispositivo inscripto sin saber de quién.
- Roles: `device` (enviar capturas, ver las propias), `reviewer` (doble carga, sin
  ver `deviceId`), `operator` (importar oficial, administrar muestra, ver agregados
  embargados con registro), `public` (lectura agregada tras el embargo).
- Revocación por `deviceId`. Retención de registros técnicos (IP) mínima y publicada
  (participant-protection, principio 3).

### 3.6 De un servidor local a varios nodos

1. **Hoy (hackatón)**: un proceso API + un worker + SQLite + directorio de blobs en la
   máquina del autor; la app se conecta por la red local; la simulación AMBA consume
   la misma API de agregados con datos 2023.
2. **Acceso externo** (sección 8): proxy TLS delante, sin cambiar el código.
3. **Escala**: SQLite → PostgreSQL, directorio → objetos S3-compatible, tabla de
   trabajos → broker, N workers. El código accede a esos recursos por interfaces
   (puertos/adaptadores), así el cambio es de configuración, no de API.
4. **Resiliencia** (participant-protection, principio 6): réplicas de lectura del
   espejo oficial y de los agregados públicos en otra jurisdicción; la evidencia cruda
   **no** se replica a nodos públicos.

Dimensionamiento (supuestos para planificar, no datos): ~2 páginas por captura de
1–2 MB cada una; si 5.000 mesas envían en 3 horas son ~10.000 blobs y ~20 GB, menos
de 1 blob/s: un servidor modesto lo absorbe. El cuello de botella es el OCR
(segundos por página por motor en CPU): se resuelve con más workers, no con más API.

## 4. Flujo de una captura en el servidor

1. `received`: llegó el JSON; se validó contra el schema y la plantilla.
2. `complete`: llegaron todos los blobs y los hashes coinciden.
3. `ocr_queued` → `ocr_done` | `ocr_failed`: un trabajo por página y motor
   configurado; los resultados se guardan todos (comparación de motores).
4. `review_pending`: si el tally de la mesa necesita confirmación (SB-7: cuándo).
   Doble carga a ciegas: dos revisores ven la imagen y cargan sin ver el OCR ni la otra
   carga; el servidor compara; sólo las celdas en conflicto van a una tercera
   resolución con la imagen a la vista.
5. `confirmed`: existe un `Tally` con método declarado. Entra al cotejo y, si la mesa
   está en la muestra, al conteo rápido.
6. `rejected`: imagen ilegible, documento no admitido o mesa inexistente en el marco;
   se registra el motivo y la captura **se conserva** (no se borra evidencia).

Valores que vienen de la app ya confirmados por la persona (`manual` /
`ocr-accepted`) se tratan como una **primera carga**; el OCR del servidor es una
lectura automática aparte; la doble carga es una segunda carga humana. Nunca el OCR
reemplaza una carga humana.

## 5. Lenguaje, stack y motores OCR

### 5.1 Python para el prototipo (recomendación)

Motivos: todos los motores OCR y las herramientas de ML se consumen desde Python;
los contratos ya son JSON; la simulación AMBA probablemente use Python para
normalizar datos (S-1); genera OpenAPI desde los tipos sin trabajo extra; se
prototipa en horas para la hackatón.

Propuesta de stack (SB-1, todo sujeto a consentimiento antes de instalar):
Python 3.12 · FastAPI + Pydantic v2 (API y OpenAPI) · SQLite (WAL) con migraciones ·
worker propio sobre tabla de trabajos (sin broker en el prototipo) · Pillow/OpenCV
para recorte y registro de regiones · motor OCR enchufable.

### 5.2 Camino a Rust

El contrato estable es el archivo OpenAPI versionado (`/v1`) más los JSON Schema de
`contracts/`. Mientras ambas implementaciones pasen los mismos **tests de contrato**
(colección de peticiones/respuestas esperadas en `contracts/api/vectors/`), la app
no nota el cambio.

| Orden | Parte | Por qué primero | Rust propuesto |
| --- | --- | --- | --- |
| 1 | Almacén de blobs + validación de hashes + API de ingesta | I/O intensivo, lógica chica y crítica (nunca perder ni alterar evidencia), sin ML | `axum` + `tokio`, `sha2`, `serde` |
| 2 | Agregador / proyección y muestreo | Cómputo determinista, fácil de verificar contra la versión Python con los mismos vectores | crate propio compartido con la simulación (WASM para la web estática) |
| 3 | Espejo oficial (importación y cotejo) | Depende del formato oficial 2027; estabilizar primero en Python | después de conocer el formato |
| 4 | Workers OCR | El ecosistema ML sigue en Python; alternativa: modelos exportados a ONNX y ejecutados desde Rust (`ort`), o bindings a Tesseract | último, o nunca |

Regla: ninguna migración empieza sin tests de contrato en verde en la versión Python.

### 5.3 Motores OCR locales (comparación sin instalar)

Lo que hay que leer son **dígitos manuscritos en celdas de un formulario conocido**,
no texto corrido. Por eso la propuesta es un **pipeline por regiones**: registrar la
imagen contra la plantilla (marcas del formulario), recortar cada celda y reconocer
sólo dígitos. El motor de OCR general es una de las etapas, intercambiable.

| Motor | Licencia | Fortaleza | Debilidad para este caso | Dependencias a instalar (con consentimiento) |
| --- | --- | --- | --- | --- |
| **Tesseract 5** (vía `pytesseract`/`tesserocr`) | Apache 2.0 | Maduro, liviano, CPU, modo "sólo dígitos" por lista blanca, muchos idiomas | Flojo en manuscrito; necesita buen preprocesado y recorte por celda | paquete del sistema `tesseract-ocr` + `spa`; pip `pytesseract`, `opencv-python-headless` |
| **PaddleOCR** (PP-OCR) | Apache 2.0 | Detección + reconocimiento robustos en fotos reales, buen rendimiento en CPU, modelos chicos | Entrenado en impreso; manuscrito irregular; dependencia pesada (`paddlepaddle`) | pip `paddlepaddle` (~ cientos de MB) + `paddleocr` |
| **EasyOCR** | Apache 2.0 | Fácil de usar, PyTorch, decente en escenas | Lento en CPU, torch pesado, manuscrito mediocre | pip `torch` (GB) + `easyocr` |
| **Clasificador propio de dígitos** (CNN chica sobre recortes de celda; p. ej. entrenada con dígitos manuscritos públicos y ajustada con celdas confirmadas de `data/ocr-samples`) | la nuestra | Es exactamente el problema; rápido en CPU; confianza calibrable; se puede exportar a ONNX/Core ML para el teléfono | Hay que construir el registro de regiones y la segmentación de dígitos; necesita celdas confirmadas por personas para medir | pip `onnxruntime` (+ `torch` sólo para entrenar) |

Recomendación (SB-2): **Tesseract como línea de base** (lo más barato de instalar) y
**pipeline por regiones con clasificador de dígitos** como objetivo; PaddleOCR como
segundo motor general para comparar si la base decepciona. Métrica única para todos
(SB-3): exactitud por celda y por dígito sobre las celdas `valor_confirmado` de
`data/ocr-samples/planilla-valores.csv`, más calibración de la confianza
(¿con confianza ≥ 0,9, qué porcentaje es correcto?). Las versiones vigentes de cada
motor se verifican en el momento de instalar.

## 6. API propuesta (REST, `/v1`)

Alternativas consideradas: gRPC (binario, menos natural desde `URLSession` y para
depurar en la hackatón) y GraphQL (innecesario: pocas entidades). **REST + JSON con
OpenAPI 3.1** es la recomendación (SB-4): se genera desde FastAPI, se consume con
`URLSession` sin librerías, y cualquier persona lo prueba con `curl`.

Convenciones: JSON UTF-8; fechas ISO-8601 UTC; ids UUID; hashes hex minúsculas;
`Authorization: Bearer <token>`; paginación por cursor (`?cursor=&limit=`); cambios
en `/v1` sólo aditivos, lo incompatible va a `/v2`; cada respuesta agregada incluye
`embargo` (`{active, until, reason}`).

### 6.1 Salud e inscripción

| Método y ruta | Rol | Cuerpo → respuesta |
| --- | --- | --- |
| `GET /v1/health` | público | → `200 {status, version, time}` |
| `GET /v1/health/ready` | público | → `200` si DB, blobs y cola responden; `503` si no |
| `POST /v1/devices/enroll` | sin token | `{enrollmentCode, platform, appVersion, publicKey?}` → `201 {deviceId, deviceToken, scopes[]}` |
| `DELETE /v1/devices/{deviceId}` | operator | → `204` (revoca) |

### 6.2 Ingesta de capturas y evidencia

| Método y ruta | Rol | Cuerpo → respuesta |
| --- | --- | --- |
| `POST /v1/captures` | device | paquete `capture.schema.json` → `201 {id, status:"received", missingBlobs:[sha256…]}` · `200` si ya existía igual · `409` si mismo id y contenido distinto · `422` si no valida |
| `PUT /v1/blobs/{sha256}` | device | `image/jpeg` binario → `201 {sha256, bytes}` · `200` si ya existía · `422` si el hash no coincide con el cuerpo |
| `GET /v1/captures/{id}` | device (propias) / reviewer / operator | → `200 {capture, status, pages:[{sha256, received}], ocr:{status}, tallyId?}` |
| `GET /v1/captures?mesa=…&status=…` | reviewer / operator | → lista paginada |
| `GET /v1/blobs/{sha256}` | reviewer / operator (registrado en el log) | → bytes; **nunca** público |

### 6.3 OCR (extraído automáticamente)

| Método y ruta | Rol | Cuerpo → respuesta |
| --- | --- | --- |
| `GET /v1/captures/{id}/ocr` | device (propias) / reviewer | → `200 {jobs:[{engine, engineVersion, status, attempts, startedAt, finishedAt}], results:[{engine, page, cells:{categoria:{fila:{text, value, confidence, bbox}}}, header:{…}}]}`; `origin` siempre `"ocr"` |
| `POST /v1/captures/{id}/ocr` | operator | `{engine}` → `202 {jobId}` (reprocesar con otro motor) |
| `GET /v1/ocr/engines` | público | → lista de motores, versiones y métricas publicadas sobre la muestra |

### 6.4 Confirmación humana

| Método y ruta | Rol | Cuerpo → respuesta |
| --- | --- | --- |
| `POST /v1/captures/{id}/reviews` | reviewer | `{entry: 1|2, header:{…}, cells:{…}}` (sin ver OCR ni otra carga) → `201 {reviewId, comparison?: {agree, conflicts:[cellRef…]}}` |
| `POST /v1/captures/{id}/reviews/resolve` | reviewer (distinto de los dos anteriores) | `{cells:{cellRef: value}}` → `200 {tallyId}` |
| `GET /v1/mesas/{distrito}/{seccion}/{circuito}/{mesa}/tally` | reviewer / operator (público tras embargo, SB-10) | → `200 {tally, confirmationMethod, basedOn:{captureIds, reviewIds}, version}` |

### 6.5 Conteo rápido

| Método y ruta | Rol | Cuerpo → respuesta |
| --- | --- | --- |
| `POST /v1/quick-count/designs` | operator | `{frameImportId, strata, allocation, seedCommitment}` → `201 {designId, commitmentHash}` (la semilla se guarda sellada) |
| `POST /v1/quick-count/designs/{id}/reveal` | operator (tras el cierre) | `{seed}` → `200 {sample:[…], verified:true}` |
| `GET /v1/quick-count/designs/{id}` | público | → diseño, estratos, compromiso; la muestra sólo después del *reveal* (SB-6) |
| `GET /v1/quick-count/estimate?design=…&category=presidente&estimator=design|poststratified` | operator (siempre, con registro) · público tras embargo | → `200 {estimator, coverage:{sampled, confirmed, replaced}, results:[{agrupacion, share, lower, upper}], totalVotes, asOf, method}` · `423 Locked {embargo}` |
| `GET /v1/quick-count/accuracy?design=…` | público (tras definitivo) | → error por agrupación vs. provisorio y definitivo, cobertura del intervalo |

Las agrupaciones se listan en el orden de la plantilla oficial (número de lista) y
con la misma precisión; ninguna respuesta destaca a una.

### 6.6 Escrutinio oficial (espejo y cotejo)

| Método y ruta | Rol | Cuerpo → respuesta |
| --- | --- | --- |
| `POST /v1/official/imports` | operator | `{source:"provisorio"|"definitivo", sourceUrl, downloadedAt, sha256}` + archivo → `202 {importId}` |
| `GET /v1/official/imports` | público | → versiones con procedencia y totales |
| `GET /v1/official/summary?source=…&level=distrito|seccion&importId=…` | público (tras embargo) | → totales por agrupación, mesas computadas, versión |
| `GET /v1/official/mesas/{distrito}/{seccion}/{circuito}/{mesa}` | público (tras embargo) | → valores oficiales por versión |
| `GET /v1/comparisons?status=mismatch&distrito=…` | reviewer / operator (público tras embargo, SB-10) | → `[{mesa, tallyVersion, officialImportId, cells:[{ref, tally, official}], status}]` |

### 6.7 Errores

`application/problem+json` (RFC 9457):

```json
{ "type": "https://cuentaconmigo.ar/errors/hash-mismatch", "title": "El hash no coincide",
  "status": 422, "code": "hash_mismatch", "detail": "page-1.jpg: declarado 3f9a…, calculado 8b10…",
  "instance": "/v1/blobs/3f9a…", "errors": [ {"path": "pages[0].sha256", "code": "hash_mismatch"} ] }
```

Códigos iniciales: `schema_invalid`, `template_unknown`, `hash_mismatch`,
`capture_conflict` (409), `blob_missing`, `mesa_not_in_frame`, `embargo_active` (423),
`unauthorized` (401), `forbidden` (403), `rate_limited` (429, con `Retry-After`).
Los `detail` no incluyen datos personales ni rutas internas.

### 6.8 OpenAPI (resumen)

```yaml
openapi: 3.1.0
info: { title: CuentaConmigo Scrutiny API, version: 1.0.0-draft }
servers: [ { url: /v1 } ]
security: [ { bearer: [] } ]
paths:
  /health: { get: { security: [], responses: { "200": { $ref: "#/components/responses/Health" } } } }
  /devices/enroll: { post: { security: [], requestBody: { $ref: "#/components/requestBodies/Enroll" } } }
  /captures:
    post: { requestBody: { content: { application/json: { schema: { $ref: "contracts/schemas/capture.schema.json" } } } },
            responses: { "201": { $ref: "#/components/responses/CaptureAccepted" }, "409": { $ref: "#/components/responses/Problem" } } }
    get:  { parameters: [mesa, status, cursor, limit] }
  /captures/{id}: { get: {} }
  /captures/{id}/ocr: { get: {}, post: {} }
  /captures/{id}/reviews: { post: {} }
  /captures/{id}/reviews/resolve: { post: {} }
  /blobs/{sha256}: { put: { requestBody: { content: { image/jpeg: {} } } }, get: {} }
  /mesas/{distrito}/{seccion}/{circuito}/{mesa}/tally: { get: {} }
  /quick-count/designs: { post: {} }
  /quick-count/designs/{id}: { get: {} }
  /quick-count/designs/{id}/reveal: { post: {} }
  /quick-count/estimate: { get: { responses: { "200": {}, "423": { $ref: "#/components/responses/Problem" } } } }
  /quick-count/accuracy: { get: {} }
  /official/imports: { post: {}, get: {} }
  /official/summary: { get: {} }
  /official/mesas/{distrito}/{seccion}/{circuito}/{mesa}: { get: {} }
  /comparisons: { get: {} }
components:
  securitySchemes: { bearer: { type: http, scheme: bearer } }
  schemas:
    Embargo: { type: object, required: [active], properties: { active: {type: boolean}, until: {type: string, format: date-time}, reason: {type: string} } }
    Value:   { $ref: "contracts/schemas/capture.schema.json#/$defs/value" }
    OcrCell: { type: object, properties: { text: {type: string}, value: {type: [integer, "null"]}, confidence: {type: number}, bbox: {type: array}, origin: {const: ocr} } }
    Estimate: { type: object, properties: { estimator: {enum: [design, poststratified]}, coverage: {}, results: {type: array}, asOf: {}, method: {}, embargo: { $ref: "#/components/schemas/Embargo" } } }
    Problem: { type: object, properties: { type: {}, title: {}, status: {}, code: {}, detail: {}, instance: {}, errors: {type: array} } }
```

El archivo completo se propone en `contracts/api/scrutiny-v1.openapi.yaml`
(requiere `contract-change` y aceptación del autor); los vectores de contrato en
`contracts/api/vectors/`.

## 7. Qué se muestra en la hackatón

1. La app envía una captura de la plantilla demo al servidor local; se ve `received →
   complete → ocr_done`.
2. Pantalla del servidor: imagen, celdas detectadas por OCR con confianza, y al lado
   la carga humana; diferencias marcadas.
3. Métricas del OCR sobre las muestras confirmadas (`/v1/ocr/engines`).
4. Simulación AMBA consumiendo `/v1/quick-count/estimate` con datos 2023 y
   `/v1/official/summary` del espejo 2023: la proyección se estabiliza con pocas mesas
   y se compara con el oficial. Rótulo permanente "SIMULACIÓN · generales 2023".
5. El `423 Locked` de embargo con una hora de cierre simulada, para mostrar que la
   regla está en el código.

Todo con datos ficticios o de 2023; ninguna imagen con nombres o firmas en pantalla
sin tapar.

## 8. Acceso desde afuera (paso posterior, lo configura el autor)

Requisitos que el diseño ya respeta para que ese paso sea sólo configuración:

- TLS obligatorio (proxy inverso con certificados; HSTS); sin HTTP plano fuera de la
  red local.
- Autenticación en toda ruta salvo `/health`, `/devices/enroll` y lecturas públicas
  tras embargo; tokens revocables; secretos fuera de Git (`.private/`).
- Límite de tasa por `deviceId` e IP (ingesta y enrolamiento) con `429`.
- **La evidencia cruda (`/v1/blobs`) nunca es pública** ni se replica a nodos públicos;
  si algún día se publica una copia, es la versión con datos personales tapados y sin
  EXIF (participant-protection PP-6 / F-50), con decisión del autor y de electoral_counsel.
- Separar el punto de entrada público (lecturas agregadas, caché) del de ingesta.
- Registros técnicos con retención corta y publicada; sin analítica de terceros.
- Jurisdicción del alojamiento: Ley 25.326 art. 12 (transferencia internacional):
  decidir con electoral_counsel (PP-4).
- Copias de seguridad cifradas; procedimiento de restauración probado antes de la elección.

## 9. Decisiones pendientes

★ = recomendación del planner, no vinculante.

| ID | Decisión | Opciones |
| --- | --- | --- |
| SB-1 | Lenguaje y framework del prototipo | ★ Python 3.12 + FastAPI + SQLite · Python + Flask · Rust (axum) desde el inicio · Node/TS |
| SB-2 | Motores OCR a instalar primero | ★ Tesseract (base) + pipeline por regiones con clasificador de dígitos · PaddleOCR · EasyOCR · sólo clasificador propio |
| SB-3 | Métrica de OCR | ★ exactitud por celda y por dígito sobre celdas confirmadas de `data/ocr-samples` + calibración de confianza · sólo exactitud por celda · CER sobre texto |
| SB-4 | Estilo de API | ★ REST + JSON + OpenAPI 3.1 · gRPC · GraphQL |
| SB-5 | Modelo del conteo rápido | ★ estratificado por distrito×sección ponderado por electores, con intervalos · postestratificado con regresión · bayesiano jerárquico (coordinar con S-3) |
| SB-6 | Publicación de la selección de mesas | ★ *commit-reveal* (hash antes, semilla y muestra después del cierre) · publicar la muestra antes · publicar sólo después sin compromiso · no publicar |
| SB-7 | Cuándo exigir doble carga | ★ siempre para mesas de la muestra; oportunistas con una carga humana + OCR concordante · siempre todas · nunca (confiar en la app) |
| SB-8 | Firma de paquetes en el dispositivo | ★ opcional en v1 (clave en Secure Enclave/Keystore), obligatoria en v2 · obligatoria desde v1 · no firmar |
| SB-9 | Anclaje público del log de auditoría | ★ publicar el hash raíz diario/horario en el repo · no publicar · servicio externo de sellado de tiempo |
| SB-10 | Publicidad del cotejo mesa a mesa | ★ público tras el embargo, sin calificaciones, con rótulo "diferencia, no irregularidad" · sólo operadores · sólo agregados de discrepancias (a evaluar por electoral_counsel) |
| SB-11 | Base de datos y almacenamiento en escala | ★ PostgreSQL + objetos S3-compatible propio · PostgreSQL + disco replicado · base distribuida |
| SB-12 | Cola de trabajos en escala | ★ Redis Streams · NATS · tabla en PostgreSQL con `SKIP LOCKED` |
| SB-13 | Interfaz de revisión humana | ★ web mínima servida por el backend · la propia app (rol reviewer) · ambas |
| SB-14 | Orden de migración a Rust | ★ blobs/ingesta → agregador → espejo → OCR (nunca o vía ONNX) · agregador primero · todo junto |
| SB-15 | Hora de cierre y duración del embargo | ★ configurables por elección, con valor por defecto 18:00 + 3 h **a verificar** · fijas en código |

## 10. Criterios de aceptación (medibles)

1. Un paquete `capture.example.json` con sus JPEG enviado dos veces produce **un** recurso
   (`201` y luego `200`); el mismo id con otro valor produce `409`; un hash alterado
   produce `422`. Vectores en `contracts/api/vectors/`.
2. Ningún blob se modifica ni se borra: `sha256sum` sobre el almacén coincide con los
   nombres de archivo después de cualquier secuencia de pruebas.
3. Cada `OcrResult` tiene `origin = "ocr"` y ninguna respuesta de `/tally` ni
   `/quick-count/estimate` referencia valores sin `Review` o confirmación humana.
4. OCR: métrica SB-3 publicada por motor sobre el 100 % de las celdas confirmadas de
   `data/ocr-samples`; la línea de base queda registrada antes de optimizar.
5. Conteo rápido: con el marco y los resultados 2023 del AMBA, la misma semilla produce
   la misma muestra en dos ejecuciones (hash idéntico); con 5 % de mesas la estimación
   estratificada queda a menos de 2 puntos del oficial 2023 en la mayoría de las
   semillas (mismo umbral que amba-simulation, a medir).
6. Embargo: con hora de cierre configurada, `/quick-count/estimate` público responde
   `423` dentro de la ventana y `200` fuera; el acceso de operador en ventana queda en
   el log de eventos.
7. Cotejo: para las mesas 2023 cargadas como prueba, `Comparison` detecta el 100 % de
   las diferencias introducidas a propósito y 0 falsos positivos.
8. El log de eventos verifica su cadena de hashes de punta a punta; alterar un evento
   rompe la verificación.
9. Enrolamiento sin datos personales: el esquema de la base no tiene columnas de
   nombre, documento, teléfono, ubicación ni partido (revisión de `data_protection_officer`).
10. Contrato: la app iOS pasa los vectores de `contracts/api/vectors/` contra el
    servidor; el mismo conjunto se reutiliza para la futura implementación Rust.
11. Chequeo de `electoral_counsel` registrado en `checks/electoral_counsel.md` sin ⛔
    abiertos, o con decisión del autor sobre cada ⛔.

## 11. Riesgos

| Riesgo | Mitigación propuesta |
| --- | --- |
| Formato oficial 2027 (telegrama y datos publicados) desconocido | Plantillas declarativas y importador por versión; Q1 de telegram-capture asignado a electoral_analyst |
| OCR insuficiente en manuscrito | Pipeline por regiones + clasificador propio; el OCR nunca decide; doble carga humana |
| Sesgo de cobertura en la muestra (mesas sin voluntario) | Suplentes sorteados, tasa de no respuesta publicada, estimador de diseño separado del postestratificado |
| Publicar algo dentro del embargo por error de configuración de hora | Embargo activo por defecto; hora de cierre explícita y verificada; test 6 |
| Códigos de inscripción que revelen partido | Prohibido por diseño; revisión de data_protection_officer; códigos por campaña/estrato |
| Incautación o filtración de la evidencia cruda | Cifrado en reposo, acceso registrado, sin réplica pública, retención definida |
| Confundir "diferencia" con "irregularidad" en el cotejo | Vocabulario fijo en la API y en pantallas; chequeo de electoral_counsel (SB-10) |
| Punto único de falla el día D | Cola offline en la app (nada se pierde), réplicas de lectura, restauración probada |
| Instalación de dependencias pesadas sin consentimiento | Lista explícita en 5.3; nada se instala sin el autor |

## 12. Chequeo de electoral_counsel: pendiente

Riesgos legales identificados por el planner, para análisis del rol (no son conclusiones):

1. **Art. 71 inc. h (proyecciones)**: confirmar texto vigente para 2027, qué cuenta
   como "publicar" (¿acceso de operadores con registro? ¿agregados parciales por
   mesa?), hora de cierre de referencia y alcance del embargo sobre el cotejo mesa a
   mesa (SB-10). Multa art. 128 bis.
2. **Captura por voluntarios no fiscales** en mesas de la muestra (sección 2b, punto 5):
   si no son fiscales acreditados ni acompañantes cívicos (Acordada 128/11), ¿pueden
   fotografiar un telegrama expuesto? Alternativa de menor riesgo: la muestra sólo se
   cubre con fiscales y autoridades de mesa.
3. **Acordada Extraordinaria 128/11**: un conteo rápido con fiscales partidarios no
   encuadra como acompañamiento cívico; evaluar cómo se presenta públicamente el
   conteo (quién lo hace, con qué legitimidad) y si hace falta otra figura.
4. **Datos personales (Ley 25.326)**: las imágenes contienen nombres y firmas; el
   backend las conserva. Base legal del tratamiento, inscripción de la base (art. 21),
   responsable, retención y jurisdicción del alojamiento (art. 12). Códigos de
   inscripción que no deben permitir inferir opinión política (arts. 2 y 7).
5. **Cotejo público y honor**: publicar discrepancias por mesa puede leerse como
   imputación a autoridades de mesa identificables por número de mesa; definir
   vocabulario y nivel de agregación (SB-10).
6. **Art. 108 (control partidario del provisorio)**: los partidos ya tienen derecho a
   controlar la recolección y transmisión de datos; ver si el conteo rápido se ofrece
   como herramienta igual para todos (coherente con la neutralidad) y qué implica.
7. **Publicación anticipada de la muestra** (SB-6): riesgo de presión sobre mesas
   conocidas vs. transparencia; el *commit-reveal* busca equilibrar; validar.

Salida esperada: `sdd/specs/scrutiny-backend/checks/electoral_counsel.md` con ⛔/⚠️ y
alternativas ordenadas por riesgo; los ⛔ frenan la implementación hasta que decida el autor.

## Ajustes por el chequeo de electoral_counsel (31/10/2026)

Informe: [checks/electoral_counsel.md](checks/electoral_counsel.md). Se incorporan como
requisitos las mitigaciones no bloqueantes. Los ⛔ quedan para el autor.

- **Autorización por objeto** en cada ruta: el dispositivo y el rol salen del token,
  nunca de un id de la ruta (OWASP API1).
- **Enrolamiento resistente a fuerza bruta:** códigos de alta entropía, de un solo uso
  y con vencimiento, con límite de intentos por IP y por código.
- **Embargo a prueba de fallas:** si el servidor no puede determinar la hora o la hora
  de cierre configurada, responde `423 Locked`. La liberación toma la hora real de
  cierre de cada distrito (L3).
- **Parser de imágenes aislado:** se procesa en un proceso aparte sin red, con límites
  de tamaño y de tiempo; los metadatos se descartan.
- **Operadores:** autenticación con llave física (FIDO2) y registro de cada acceso a
  evidencia cruda.
- **Imágenes con datos sensibles** (L6): acceso restringido y retención limitada hasta
  el escrutinio definitivo más un plazo a definir (PP-7). Nunca se publican sin tapar.
- **Voluntarios no fiscales en la muestra** (L4): no se los asigna a mesas hasta tener
  base legal clara. Mientras tanto, la muestra se cubre con fiscales acreditados que
  aceptan participar.
- **Encuadre** (L5): se presenta como herramienta cívica de verificación, no como
  acompañamiento cívico oficial. Las preguntas quedan para un abogado o abogada.

## Medición de base del OCR · 31/10/2026

`scripts/ocr/baseline_tesseract.py` corre Tesseract 5 (español, ya instalado en el
servidor, sin instalaciones nuevas) sobre las 14 muestras disponibles de
`data/ocr-samples` a 300 dpi. Mide qué parte de los valores transcriptos aparece entre
los números detectados en la página, que es la ayuda que la app muestra como fichas.

- **Total: 399/551 = 72,4 %.** Por telegrama: 70–84 % en los PASO 2017 y 30–57 % en
  los del balotaje 2015.
- **Provisorio:** las celdas todavía no están confirmadas por personas (`borrador_ia`),
  y los números chicos (0, 1, 2) pueden coincidir por azar. No mide la posición: falta
  la extracción por regiones de la plantilla (SB-2) y una métrica por celda (SB-3).
