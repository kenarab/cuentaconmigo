# Chequeo electoral_counsel (legal, datos personales y ciberseguridad) · scrutiny-backend

## 31/10/2026

> No es asesoramiento legal ni de seguridad profesional. ⛔ y preguntas abiertas van a
> un/a abogado/a electoral y a un/a profesional de seguridad a través del autor.

### 1. Alcance

- Revisión `5b76a7b` / `1dd5c8f` (sin cambios en esta SPEC entre ambas).
- `sdd/specs/scrutiny-backend/SPEC.md` completo; sección 12 (riesgos del planner) responde punto por punto abajo.
- Fuentes verificadas hoy: Código Electoral Nacional, Infoleg texto actualizado
  (<https://servicios.infoleg.gob.ar/infolegInternet/anexos/15000-19999/19442/texact.htm>):
  art. 71 inc. h ("Publicar o difundir encuestas y proyecciones sobre el resultado de la
  elección durante la realización del comicio y hasta tres horas después de su cierre");
  art. 71 inc. g (fotografía de la BUP, dirigido "a los electores"); art. 56 (fiscales y
  fiscales generales). Ley 25.326 arts. 2, 5, 7, 9, 12, 21 (Infoleg). Art. 128 bis:
  **no** se pudo leer hoy (sólo a-parcial en MARCO_LEGAL).

### 2. Modelo de amenazas (resumen)

| Elemento | Detalle |
| --- | --- |
| Activos | Evidencia cruda (imágenes con nombres, firmas y, en telegramas, fiscales identificados por partido); tallies confirmados; semilla y muestra del conteo rápido; agregados embargados; log encadenado; tokens de dispositivos; cuentas `operator` y `reviewer`. |
| Actores | Quien quiere envenenar el conteo (capturas falsas o alteradas, Sybil); quien quiere publicar agregados en veda (filtración de operador); quien quiere identificar fiscales o autoridades; atacante de disponibilidad el día D; insider con rol operador; quien explota el parser de imágenes. |
| Superficie | `POST /devices/enroll` sin token; ingesta (`/captures`, `/blobs`); lecturas por id (`/captures/{id}`, `/blobs/{sha}`); endpoints de operador (imports, reveal, estimaciones en veda); workers OCR que parsean imágenes y PDFs; importador oficial (contenido externo); reloj del servidor (embargo); backups. |

### 3. Hallazgos legales

| # | Sev. | Hallazgo | Base |
| --- | --- | --- | --- |
| L1 | ✅ | Embargo por defecto, `423` en ventana, cotejo mesa a mesa también embargado hasta definición: alineado con art. 71 inc. h. | **Verificado** art. 71 inc. h. |
| L2 | ⚠️ | **Qué es "publicar o difundir":** el acceso de operadores con registro no es, en principio, publicación (interpretación). Pero compartir estimaciones con coordinadores, partidos o prensa en ventana sí lo sería. El riesgo real es la filtración. | Art. 71 inc. h (verificado); interpretación. Sanción: art. 128 bis (**a verificar** texto y montos). |
| L3 | ⚠️ | **Hora del embargo:** la publicación oficial del provisorio empezó cerca de las 21 h en 2025 (fuente secundaria en MARCO_LEGAL). El embargo debe calcularse sobre la hora real de cierre de **cada** mesa/distrito (mesas que cierran tarde, distritos con husos o desdoblamientos provinciales) y no sobre 18:00 fijo. | Art. 71 inc. h; calendario 2027 **a verificar**. Elecciones provinciales simultáneas: normas provinciales **a verificar**. |
| L4 | ⚠️ alto | **Cobertura por voluntarios no fiscales** (2b punto 5): la norma sólo prevé presencia de fiscales acreditados, apoderados y candidatos en el escrutinio (art. 101, verificado en MARCO_LEGAL). Un tercero que fotografía un telegrama "expuesto" no tiene base clara. | Arts. 56-59, 101 (MARCO_LEGAL, verificado). Interpretación. |
| L5 | ⚠️ | **Encuadre del conteo rápido** (Acordada CNE 128/11): con fiscales partidarios no encaja como acompañamiento cívico. Presentarlo como "herramienta ofrecida por igual a todas las fuerzas" y publicar metodología; no presentarse como observación acreditada. | Acordada 128/11 (a-parcial en MARCO_LEGAL). |
| L6 | ⚠️ alto | **Datos sensibles en las imágenes:** telegramas y certificados llevan nombre, firma y a veces DNI de fiscales **junto al partido** que representan: el almacén de blobs es, indirectamente, un archivo que revela opiniones políticas. La SPEC protege bien el acceso, pero no prevé minimizar en la ingesta. | **Verificado:** Ley 25.326 art. 2, art. 7 inc. 3; art. 4 (minimización). Que las imágenes oficiales publicadas sean "fuente de acceso público irrestricto" (art. 5 inc. 2): **a verificar**; aun así el art. 5 exceptúa consentimiento, no la prohibición del art. 7 inc. 3 (interpretación). |
| L7 | ⚠️ | Inscripción de la base (art. 21), responsable identificado, jurisdicción del alojamiento (art. 12, transferencia internacional). Pendiente PP-4. | Arts. 12, 21 (verificados); aplicabilidad del 21: **a verificar**. |
| L8 | ⚠️ | **Cotejo público y honor (SB-10):** número de mesa ⇒ autoridades identificables. Vocabulario "diferencia, no irregularidad" correcto. Riesgo residual: terceros lo recortan como "fraude". | CP arts. 109-110 (Ley 26.551, a-parcial); CADH 11. |
| L9 | ✅ | Commit-reveal de la muestra (SB-6): equilibra transparencia y riesgo de presión. Validar que la asignación privada a voluntarios no se filtre (equivale a publicar la muestra). | Interpretación. |
| L10 | ✅ | Art. 108: los partidos ya controlan el provisorio; ofrecer el conteo a todos por igual es coherente. | Art. 108 (MARCO_LEGAL, verificado). |
| L11 | ✅ | Inscripción "nunca por partido", sin columnas de datos personales (criterio 9). | Arts. 4, 7. |

### 4. Hallazgos de ciberseguridad (propuestas, salvo lo que la SPEC ya prevé)

| # | Sev. | Riesgo | Control (referencia) |
| --- | --- | --- | --- |
| S1 | ⚠️ alto | **BOLA** en `/captures/{id}`, `/captures/{id}/ocr`, `/devices/{id}/*` (fiscal-planning) y `/mesas/.../tally` antes del embargo. | Autorización por objeto en el servidor en cada ruta; ids no adivinables no son control (OWASP API1:2023; ASVS V4 control de acceso). Tests negativos en `contracts/api/vectors/`. |
| S2 | ⚠️ alto | **Enrolamiento sin token** (`/devices/enroll`): fuerza bruta de códigos, agotamiento. | Códigos ≥ 128 bits o firmados; un uso; caducidad; límite por IP; converger con trust-chain-identity (QR firmado) en lugar de mantener dos sistemas (API2/API4:2023). |
| S3 | ⚠️ alto | **Envenenamiento del conteo rápido** con capturas falsas de dispositivos inscriptos o Sybil. | Sólo tallies con doble carga para la muestra (SB-7 ★); SB-8 firma en dispositivo obligatoria **antes** de la elección real; peso máximo por dispositivo/rama; detección de divergencia con otras capturas de la mesa. |
| S4 | ⚠️ alto | **Parser de imágenes** (Pillow/OpenCV/PDF) expuesto a archivos de atacantes: bombas de descompresión, CVE de decodificadores. | Límites de tamaño y píxeles antes de decodificar, re-codificación en proceso aislado sin red ni acceso a la base, workers sin privilegios, dependencias fijadas y monitoreadas (ASVS V12 archivos). |
| S5 | ⚠️ | `PUT /blobs/{sha256}` en espacio global: oráculo de existencia ("¿alguien ya subió esta imagen?") y blobs huérfanos que llenan el disco. | Aceptar sólo blobs listados en `missingBlobs` de una captura del mismo dispositivo; responder igual exista o no; cuota por dispositivo; recolección de huérfanos con registro (sin tocar evidencia referenciada). |
| S6 | ⚠️ alto | **Embargo dependiente del reloj** y de configuración. | Fail-closed (sin hora de cierre válida ⇒ embargo activo), fuente de tiempo confiable (NTP autenticado), configuración firmada y en el log, test 6 ya previsto; caché/CDN pública que respete `423` (no cachear respuestas internas). |
| S7 | ⚠️ alto | **Rol operator** (ve agregados embargados, revela semilla, importa oficial): insider y robo de cuenta. | AAL3-like (llave física), dos personas para `reveal` e imports, registro de cada lectura en ventana (previsto), sesiones cortas, sin acceso desde redes públicas (NIST SP 800-63B; ASVS V2/V3). |
| S8 | ⚠️ | **Metadatos de ubicación:** fotos importadas de la galería pueden traer EXIF GPS del voluntario. El original inmutable lo preservaría para siempre. | Rechazar/quitar EXIF de ubicación **en el teléfono antes de calcular el hash** (registrando la transformación) o descartar imágenes con GPS; IP no asociadas a capturas, retención corta (prevista). |
| S9 | ⚠️ | **Disponibilidad el día D**: ingesta y lecturas públicas en el mismo host; DDoS tras el embargo. | Separar ingesta de lectura (previsto en §8), lecturas públicas estáticas exportadas a CDN/espejos, colas offline en la app (previsto), simulacro de carga y de restauración antes de la elección. |
| S10 | ⚠️ | Importador oficial: contenido externo (ZIP/CSV) con path traversal o formatos maliciosos. | Descomprimir en sandbox, validar rutas y tamaños, verificar SHA-256 publicado si existe. |
| S11 | ✅ | Hashes recomputados, `409` ante mismo id con otro contenido, log encadenado con anclaje, separación OCR/confirmado, `problem+json` sin datos personales, secretos en `.private/`, TLS/HSTS. | Alineado con ASVS V7/V8/V9. |
| S12 | ⚠️ | Respuesta a incidentes ausente (filtración de blobs o de agregados en veda). | Plan breve: contención, preservación del log, aviso al autor y a electoral_counsel, evaluación de notificación (la Ley 25.326 no impone notificación de brechas; recomendaciones AAIP **a verificar**). |

### 5. Alternativas ordenadas por riesgo

- **L4 cobertura de la muestra:** (1) sólo fiscales acreditados y autoridades de mesa
  (menor riesgo; menor cobertura); (2) también acompañantes cívicos de una OSC inscripta
  (exige otra figura, separada de fiscales); (3) cualquier voluntario que fotografía
  telegramas expuestos (mayor riesgo; no recomendado hasta dictamen).
- **L6 imágenes con datos sensibles:** (1) recorte/tapado de bloques de firmas y
  fiscales en el dispositivo antes de enviar, guardando el original sólo en el teléfono
  de quien capturó; (2) original en servidor cifrado con clave de custodia separada y
  copia de trabajo tapada para revisores; (3) guardar original completo con control de
  acceso (actual; mayor riesgo).
- **L2/L3 embargo:** (1) embargo total de toda salida derivada (incluido cotejo mesa
  a mesa y avisos con comparación) hasta cierre + 3 h del último distrito; (2) embargo
  por distrito según su cierre; (3) sólo agregados embargados (mayor riesgo, depende de
  dictamen sobre "proyección").
- **S2 inscripción:** (1) reutilizar QR de trust-chain-identity; (2) códigos de alta
  entropía por estrato; (3) códigos cortos (no recomendado).

### 6. Recomendaciones accionables

1. Agregar a la SPEC las precondiciones de §8 como **criterios de aceptación** antes del
   acceso externo: S1, S2, S4, S6, S7 con vectores negativos.
2. Elegir L4 alternativa 1 para la elección real hasta tener dictamen.
3. Decidir L6 (recorte en dispositivo) junto con telegram-capture.
4. Converger autenticación con trust-chain-identity (sin rótulo partidario).
5. Calendario 2027 y horas de cierre por distrito como dato configurable y firmado.
6. Plan de incidentes y simulacro el mes previo.

### 7. No verificado

- Texto y montos del art. 128 bis; calendario y horarios 2027; Acordada 128/11 completa.
- Si las imágenes oficiales de telegramas son "fuente de acceso público irrestricto".
- Aplicabilidad del art. 21 Ley 25.326; recomendaciones AAIP vigentes sobre seguridad.
- Normas provinciales para elecciones simultáneas.

### Veredicto

**⚠️** — sin ⛔ para el prototipo local con datos 2023/ficticios. Precondición fuerte:
L4 (alternativa 1), L6 y S1/S2/S6/S7 resueltos antes de cualquier uso con personas
reales o acceso externo.
