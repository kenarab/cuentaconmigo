# SPEC · Captura de telegramas y actas (prototipo iOS)

Estado: **propuesta en implementación; aceptación pendiente del autor.**
Eje: **D. Jornada y escrutinio** de la [visión](../vision/SPEC.md), el cierre visible del proceso.
Fecha: 31/10/2026. Depende de [mobile-platform](../mobile-platform/SPEC.md).

## Problema

Al cerrar el escrutinio, fiscales y autoridades de mesa necesitan registrar una
copia fiel del telegrama de escrutinio (y/o acta o certificado) de su mesa, con los
números transcriptos y verificados, para cotejarlos luego con los resultados
oficiales. Lo hacen bajo presión, de noche y con mala conectividad.

## Alcance del prototipo (P0)

Incluido:

1. Escanear una o más páginas con el escáner nativo (recorte y perspectiva) o
   importarlas desde Fotos (también permite probar en simulador).
2. Elegir el tipo de documento: `telegrama`, `acta` o `certificado`.
3. Identificar la mesa: distrito, sección, circuito y número de mesa.
4. OCR en el dispositivo como **ayuda**: muestra los números detectados para
   copiar a los campos; nunca completa ni confirma valores por sí solo.
5. Cargar los valores por fila y categoría según la plantilla del formulario,
   con la imagen a la vista y ampliable.
6. Validar con las reglas de la plantilla y mostrar avisos claros.
7. Confirmar la captura: queda **bloqueada** (sin más ediciones).
8. Exportar el paquete de evidencia (JSON del contrato + imágenes) con el menú
   de compartir del sistema.

Fuera de P0: envío a un servidor central (D-003), cuentas y roles de usuario,
cotejo con resultados oficiales, extracción automática por regiones del formulario,
geolocalización, Android.

## Evidencia y cadena de custodia

- Cada página se guarda como JPEG **una sola vez** y nunca se reescribe.
  Se registra su SHA-256 (hex en minúsculas) y la hora de captura (ISO-8601 UTC).
- El paquete de captura (`contracts/schemas/capture.schema.json`) referencia las
  páginas por nombre de archivo y hash. Cualquiera puede recomputar el hash.
- Valores con origen explícito: `manual` (tipeado) u `ocr-accepted`
  (sugerencia OCR aceptada por la persona). Nunca hay valores sin intervención humana.
- Una captura confirmada no se edita. Corregir = nueva captura de la misma mesa.

## Formulario y plantillas

El formato vigente para 2027 no está relevado (ver preguntas abiertas). Por eso la
estructura del formulario es **declarativa** (`contracts/templates/*.json`):
categorías (cargos), filas (agrupaciones y votos especiales) y reglas.
Decisión del autor (31/10/2026): la app deja de usar la plantilla ficticia y ya no
muestra avisos de formulario ficticio. Usa `generales-2023` (Presidente y
Vicepresidente de las generales del 22/10/2023, con las agrupaciones por número),
coherente con la [simulación del AMBA](../amba-simulation/SPEC.md). Las filas salen de
los resultados por mesa de la DINE; **falta cotejarlas con un telegrama 2023 real**.
`balotaje-2015` coincide con las muestras transcriptas de `data/ocr-samples/`
(balotaje 2015; las de PASO 2017 tienen listas distintas por distrito y no tienen
plantilla). `demo-2027` queda sólo para los vectores de prueba. Cambiar de plantilla
no requiere cambiar código.

## Reglas de validación (contrato)

Definidas en la plantilla y probadas con `contracts/vectors/validation.json`:

| Código | Severidad | Regla |
| --- | --- | --- |
| `missing_mesa` | error | Distrito, sección, circuito y número de mesa son obligatorios |
| `missing_value` | error | Toda celda de la plantilla tiene valor (0 explícito si corresponde) |
| `negative_value` | error | No hay valores negativos |
| `votantes_exceed_electores` | error | `votantes` ≤ `electores` cuando ambos están cargados |
| `category_total_mismatch` | aviso | Suma de cada categoría = `votantes` (regla a confirmar por electoral_analyst) |

Los avisos permiten confirmar con una justificación escrita; los errores no.

## Normalización de dígitos (contrato)

El OCR devuelve texto. `normalizeDigits` convierte a entero no negativo: quita
espacios y separadores de miles (`.` `,` espacio), corrige confusiones comunes
(`O/o→0`, `l/I/|→1`, `S→5`, `B→8`) **sólo** si el token tiene al menos un dígito
real, y rechaza el resto. Vectores en `contracts/vectors/digits.json`.

## Identificación de la mesa con listas desplegables (pedido del autor, 31/10/2026)

**La experiencia de usuario es fundamental** (principio 9 de la [visión](../vision/SPEC.md)).
Identificar la mesa no debe requerir tipear códigos:

- **Listas desplegables en cascada:** distrito → sección → circuito → establecimiento
  → mesa. Cada lista se filtra por la elección anterior y admite búsqueda por texto
  (nombre del establecimiento, localidad o número de mesa).
- **Completar lo que ya se sabe:** al elegir el establecimiento se completan distrito,
  sección y circuito, y la mesa se elige del rango de ese establecimiento. Al escribir
  un número de mesa válido, se completa el resto.
- **Recordar** la última mesa y las mesas del plan del día ([fiscal-planning](../fiscal-planning/SPEC.md)),
  siempre dentro del teléfono.
- Funciona sin conexión: las listas vienen dentro de la app, por distrito.
- Datos: la nómina pública de distritos, secciones, circuitos y mesas. Los de 2023 ya
  están en los resultados por mesa de la DINE. Para los establecimientos se usa la
  nómina pública con su rango de mesas (pregunta Q1).
- La geolocalización a pedido (ver abajo) es un atajo más. Las listas siguen siendo el
  camino principal.

## Modo demostración con 10 telegramas de ejemplo (pedido del autor, 31/10/2026)

Para probar la app sin papeles reales:

- En el escaneo, una opción **"Usar un telegrama de ejemplo"** abre una galería de 10
  telegramas. Al elegir uno, la app **completa sola** la identificación de la mesa
  (distrito, sección, circuito, establecimiento y mesa) y deja las cifras para cargar
  o para probar el OCR.
- **Contenido de los ejemplos:** telegramas **generados** con el formato de 2023 y
  las cifras **reales por mesa** de las generales 2023 de mesas del AMBA, con nombres
  y firmas **inventados** o en blanco. No se usan imágenes reales con datos de
  personas: los ejemplos van dentro de la app y del repo (AGENTS.md: sólo datos
  ficticios o anonimizados).
- Cada ejemplo tiene su archivo de respuesta esperada, para medir el OCR, y queda
  rotulado "Ejemplo 2023" en la captura y en el paquete exportado (`sample: true`).
  Ese campo nuevo del contrato pasa por `contract-change`.
- Selección de mesas: estratificada entre CABA, primer cordón y segundo cordón. Se
  incluyen casos con avisos de validación (suma que no coincide, campo vacío) para
  probar los mensajes.

## Sugerencia de establecimiento por ubicación, a pedido (pedido del autor, 31/10/2026)

Surge de la primera prueba del autor en su iPhone: identificar el establecimiento y la
mesa lleva tiempo. Propuesta:

- En la pantalla de identificación de la mesa, un botón **"Sugerir mi
  establecimiento"**. Recién al tocarlo la app pide la ubicación **una sola vez**:
  permiso "mientras se usa" o ubicación aproximada. La app nunca usa la ubicación en
  segundo plano ni la deja activada. **Política:** sólo en casos puntuales.
- La comparación se hace **en el teléfono**, contra la lista pública de
  establecimientos del distrito incluida en la app (o descargada sin enviar la
  ubicación). La app muestra los 3 más cercanos; la persona elige uno y completa la mesa.
- **La ubicación no se guarda, no se envía y no entra en el paquete de evidencia.**
  En el paquete sólo queda el establecimiento elegido, como cualquier dato de la mesa.
- Sin permiso o sin señal, la carga manual sigue igual.
- **Dependencia:** un dataset público de establecimientos con coordenadas y rango de
  mesas (pregunta Q1 de [amba-simulation](../amba-simulation/SPEC.md)). Si no existe
  con coordenadas, se puede derivar del padrón de establecimientos más geocodificación,
  con revisión humana.
- Pantalla: se suma al prototipo de [app-screens](../app-screens/SPEC.md) antes de
  implementarla (review-pipeline).
- Chequeo pendiente: `electoral_counsel` (legal y seguridad). Riesgo a evaluar: un
  teléfono incautado no debe revelar recorridos; por eso no se guarda historial.

## Privacidad y seguridad

- Las fotos pueden contener nombres y firmas: son datos personales (Ley 25.326).
  Se guardan en el contenedor de la app con Data Protection `complete`, excluidas
  del respaldo de iCloud. No se piden contactos. La ubicación sólo se pide a demanda
  para sugerir el establecimiento (ver arriba) y nunca se guarda.
- Permisos: sólo cámara (escáner). Importar de Fotos usa el selector sin permiso amplio.
- La exportación la decide la persona; la app no envía nada a la red en P0.

## UX

Español rioplatense simple, botones grandes, tipografía dinámica y VoiceOver.
Flujo: Inicio (capturas) → Nueva → Escanear/Importar → Datos de mesa → Valores
(imagen arriba, campos abajo) → Revisión de validaciones → Confirmar → Exportar.

## Restricciones legales (de [docs/legal/MARCO_LEGAL.md](../../../docs/legal/MARCO_LEGAL.md))

- **Nunca fotografiar la Boleta Única** (Código Electoral art. 71 inc. g, multa art. 128).
  La app lo advierte antes de escanear y sólo admite telegrama, acta o certificado.
- Fotografiar el certificado o el telegrama no está prohibido expresamente, pero
  tampoco está autorizado de forma explícita: es la pregunta prioritaria para un
  abogado electoral (L-1).
- El fiscal tiene derecho a recibir el **certificado de escrutinio** (art. 102): es el
  documento que esperamos capturar con más frecuencia.
- No publicar agregados ni proyecciones hasta tres horas después del cierre
  (art. 71 inc. h). La app no publica nada; el futuro backend debe respetar esa ventana.
- El partido al que representa un fiscal es una opinión política, es decir un dato
  sensible (Ley 25.326, arts. 2 y 7). No registrarlo sin una decisión legal previa.

## Criterios de aceptación

1. `swift test` del núcleo pasa todos los vectores de `contracts/vectors`.
2. El ejemplo `contracts/examples/capture.example.json` se decodifica y re-codifica
   sin pérdida con los modelos del núcleo.
3. La app compila para iOS 17+ sin firma (`xcodebuild … CODE_SIGNING_ALLOWED=NO`).
4. En un iPhone real (autor): escanear, cargar, validar, confirmar y exportar una
   captura de la plantilla demo; el hash exportado coincide con `shasum -a 256`.
5. Una captura confirmada no permite editar valores.
6. Ningún dato real ni personal en el repositorio.

## Preguntas abiertas

- Q1. Formato oficial 2027 del telegrama, acta y certificado (con Boleta Única de
  Papel). Asignar a electoral_analyst con fuentes y fechas.
- Q2. ¿La suma por categoría debe igualar a `votantes` o puede ser menor? Afecta
  la severidad de `category_total_mismatch`.
- Q3. ¿Qué identificación de mesa trae impresa el formulario (código de barras/QR)?
  Podría reemplazar la carga manual.
- Q4. Recepción central, identidad de fiscales y antifraude de capturas (D-003).

## Ajustes por el chequeo de electoral_counsel (31/10/2026)

Informe: [checks/electoral_counsel.md](checks/electoral_counsel.md). Se incorporan como
requisitos las mitigaciones no bloqueantes. Los ⛔ quedan para el autor.

- **Sin ubicación en las imágenes:** al importar desde Fotos o escanear, se eliminan
  los metadatos EXIF/GPS **antes** de calcular el hash y guardar la página. Así, el
  original inmutable ya no contiene la ubicación (S1).
- **Exportación:** antes de compartir, la app avisa que las fotos contienen nombres y
  firmas. La copia publicable con datos tapados queda para F-50 (L4).
- **Autoría:** el hash prueba la integridad del archivo, no quién lo generó. La firma
  con clave del dispositivo llega con SB-8 (S2).
- **Plantillas:** sólo plantillas embebidas en la app, o firmadas si en el futuro se
  descargan (S4).
- L-1 (si se puede fotografiar certificado y telegrama) sigue abierta para un abogado
  o abogada electoral antes de cualquier uso real.
