# Chequeo electoral_counsel (legal, datos personales y ciberseguridad) · fiscal-planning

## 31/10/2026

> No es asesoramiento legal ni de seguridad profesional.

### 1. Alcance

- Revisión `1dd5c8f`; `sdd/specs/fiscal-planning/SPEC.md` completo.
- Fuente verificada hoy: Código Electoral art. 56 (Infoleg texto actualizado,
  <https://servicios.infoleg.gob.ar/infolegInternet/anexos/15000-19999/19442/texact.htm>):
  los partidos pueden nombrar fiscales de mesa y **fiscales generales de sección**, que
  "tendrán las mismas facultades y estarán habilitados para actuar simultáneamente con el
  fiscal acreditado ante cada mesa"; fuera de ese caso, un fiscal por partido por mesa.
  Art. 71 inc. h (verificado).

### 2. Modelo de amenazas (resumen)

- **Activos:** lista de mesas seguidas por dispositivo (watchlist), estados y notas,
  eventos de capturas de terceros, cotejos, resumen exportable.
- **Actores:** quien quiere conocer el despliegue de fiscales de una fuerza; quien
  quiere ubicar a una persona durante el día; quien inyecta capturas falsas para
  generar "diferencias" y desviar fiscales; equipo de coordinación con acceso excesivo.
- **Superficie:** `PUT /devices/{id}/watchlist`, `GET /devices/{id}/events`, push
  (APNs/FCM), exportación del resumen, almacenamiento local.

### 3. Hallazgos

| # | Sev. | Hallazgo | Base / control |
| --- | --- | --- | --- |
| L1 | ✅ | El modo existe y está respaldado: el fiscal general de sección actúa en varias mesas con las mismas facultades. Quien cubre varias mesas sin ser fiscal general: **a verificar** (el art. 56 limita a uno por partido por mesa, no a una mesa por persona). | Art. 56 verificado; interpretación. |
| L2 | ⚠️ | **Avisos en ventana de veda:** un aviso individual a quien sigue su mesa no es, en principio, "publicar o difundir proyecciones" (interpretación). Pero la **vista de cobertura** de un equipo o el resumen con muchas mesas y sus cifras se acerca a un agregado. | Art. 71 inc. h verificado. Control: avisos sin cifras de votos (sólo "coincide / hay diferencias en N celdas") hasta fin del embargo; nada de sumas entre mesas. |
| L3 | ⛔ si se elige | **FP-3 "fuerza declarada"** expone el partido de quien subió una captura: dato sensible (Ley 25.326 arts. 2 y 7 inc. 3, verificados). Mantener "anónima ★". | Ver trust-chain-identity L1. |
| L4 | ⚠️ alto | **La watchlist es un proxy de ubicación:** mesas = escuelas; la secuencia de mesas seguidas y la hora de cada cambio de estado reconstruyen el recorrido de una persona. Además revela la estrategia de cobertura de una fuerza si se vincula a cuentas partidarias. | Ley 25.326 arts. 4 y 9. Control: suscripción por **circuito o sección** (grano grueso) y filtrado local en el teléfono; o sondeo de un feed público por mesa sin identificar al dispositivo; no guardar en servidor los estados por mesa (quedan en el teléfono); borrar watchlists al cierre del definitivo. |
| L5 | ⚠️ | **Capturas de terceros con imágenes de autoridades y fiscales:** el aviso ya excluye imagen e identidad (correcto). Usarlas como referencia sin confirmarlas como propias (FP-6 ★) es lo prudente. | Art. 7 inc. 3; cadena de custodia. |
| S1 | ⚠️ alto | **BOLA** en `/devices/{id}/watchlist` y `/events`: el id en la ruta permite leer la watchlist de otro. | Derivar el dispositivo del token, no de la ruta (OWASP API1:2023). |
| S2 | ⚠️ | **Inyección de "diferencias" falsas** para desviar fiscales a mesas equivocadas el día D. | Avisos basados sólo en capturas de cuentas con nivel suficiente o con doble carga; indicar "captura no verificada". |
| S3 | ⚠️ | **Push del sistema (FP-2):** APNs/FCM ven metadatos (hora, app, tamaño) y el contenido si no está cifrado. | Push silencioso sin contenido ("hay novedades"), contenido por la API. |
| S4 | ⚠️ | **Exportación del resumen:** contiene mesas, horarios y notas; si se comparte, revela recorrido. | Advertencia previa (ya prevista) y opción de exportar sin horarios. |
| S5 | ✅ | Plan y ubicación en el teléfono, sin equipos en v1, ubicación nunca sale ★. | Minimización (art. 4). |

### 4. Alternativas ordenadas por riesgo

- **L4 watchlist:** (1) nada en servidor: el teléfono consulta un feed por circuito y
  filtra localmente; (2) watchlist en servidor de grano grueso, sin estados, borrada al
  cierre; (3) watchlist por mesa con estados (actual; mayor riesgo).
- **L2 avisos en veda:** (1) sin cifras hasta fin del embargo; (2) cifras sólo de la mesa
  seguida, nunca agregadas; (3) cifras y cobertura agregada (no recomendado sin dictamen).
- **FP-5 equipos (futuro):** (1) sin equipos; (2) equipos que ven sólo estados agregados
  por establecimiento; (3) equipos con detalle por persona.

### 5. Recomendaciones

1. Mantener FP-3 anónima, FP-4 nunca sale, FP-6 sólo referencia como decisiones firmes.
2. Adoptar L4 alternativa 1 o 2 y S1 antes de implementar el endpoint.
3. Agregar criterio: "ningún aviso contiene cifras de votos antes del fin del embargo".
4. Consultar la figura de quien cubre varias mesas sin ser fiscal general.

### 6. No verificado

- Facultades de un fiscal de mesa que recorre varias mesas sin ser fiscal general.
- Si un aviso privado con cifras de una mesa en ventana es "difusión" (art. 71 inc. h).

### Veredicto

**⚠️** — sin ⛔ mientras FP-3 siga "anónima" (si se elige "fuerza declarada", ⛔).
Riesgo principal: la watchlist como rastro de ubicación.
