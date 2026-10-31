# SPEC · Lectura en el servidor y revisión sobre la imagen del telegrama

Estado: **pedido del autor del 31/10/2026; diseño propuesto (rol `planner`, Claude);
decisiones RV-1 a RV-8 pendientes. Sin implementación.** Fecha: 31/10/2026.
Depende de [scrutiny-backend](../scrutiny-backend/SPEC.md) (OCR en servidor, revisiones,
tally), [telegram-capture](../telegram-capture/SPEC.md) (paquete y evidencia),
[app-screens](../app-screens/SPEC.md) (E-07, E-08) y
[app-architecture](../app-architecture/SPEC.md) (flujo declarativo). Reemplaza como
objetivo a las sugerencias de OCR en el teléfono (F-06), que quedan como respaldo sin red.
Chequeo de `electoral_counsel`: **preliminar abajo; el completo queda pendiente.**

## Pedido del autor (31/10/2026)

Después de probar la app en el iPhone ("se nota que es una maqueta"):

> "La app debería consultar un servicio en el server que hace el OCR y devuelve los
> resultados que tienen que ser validados por quien carga. Lo ideal es que la segunda
> ronda de revisión se haga sobre los telegramas, poniendo los números al costado de los
> números manuscritos, como así el partido. Mientras más confianza, más negros los números
> y las palabras que hay que reconocer, en votos como identificador de partido. El usuario
> puede editar los números. Se le informa si hubo revisión independiente; 2 revisiones
> independientes valen mucho más que una revisión, 3 revisiones o más mejor, pero no sube
> tanto el score del acta o telegrama cargado."

## 1. Flujo

```
Captura (escáner)  →  Lectura en el servidor  →  1ª validación (quien carga)  →  Confirmar
                                                                                    │
                                Revisiones independientes sobre la imagen  ←────────┘
                                (2ª, 3ª… por otras personas)  →  confianza del acta
```

1. **Captura:** igual que hoy (escáner, imágenes inmutables con SHA-256).
2. **Lectura en el servidor:** la app envía las páginas al servicio de OCR del backend y
   recibe, por cada campo de la plantilla, el **valor leído**, su **confianza** (0–1) y su
   **ubicación** en la imagen. También lee el **identificador de cada fila**: número y
   nombre de la agrupación ("134 · Unión por la Patria"), "en blanco", "nulos", etc., para
   comprobar que la fila leída es la que dice la plantilla.
3. **Primera validación por quien carga:** la persona ve la imagen con las lecturas al lado
   (§2), corrige lo que haga falta y confirma. Lo que confirma es una **carga humana**; la
   lectura del servidor queda guardada aparte como `ocr`, nunca como confirmada.
4. **Revisiones independientes:** otras personas revisan la **misma imagen** con los
   valores confirmados al lado de los manuscritos, y aceptan o editan cada uno (§3).
5. **Confianza del acta:** se recalcula con cada revisión y se informa a quien cargó y a
   quien revisa (§4).

**Sin conexión:** la captura se guarda y la lectura queda en cola (E-11). Mientras tanto
se puede cargar a mano o con el OCR del teléfono como respaldo, rotulado "lectura del
teléfono (menos precisa)". Al volver la red, la lectura del servidor se muestra como
segunda opinión para las celdas que difieran.

## 2. Pantalla de revisión sobre la imagen

- La **imagen del telegrama ocupa la pantalla**, con zoom y desplazamiento. Al lado de
  cada número manuscrito se dibuja el número leído; al lado del nombre o número de cada
  agrupación, el identificador leído.
- **Más confianza, más negro:** el texto superpuesto va de gris claro (confianza baja) a
  negro (confianza alta), en 4 escalones con umbrales publicados (RV-3). Como el color
  solo no alcanza (accesibilidad, sol de frente), los escalones bajos llevan además
  **contorno punteado** y VoiceOver lee "134, confianza baja".
- **Editar:** tocar un número abre un teclado numérico sobre esa celda; el valor editado se
  muestra en azul, con la lectura original tachada al lado. Tocar el identificador de una
  fila permite reasignarla si el OCR la confundió con otra agrupación.
- **Orden de atención:** un botón "Siguiente dudoso" lleva de la celda de menor confianza
  a la siguiente, para no obligar a recorrer todo.
- **Cierre de controles:** abajo, la suma de la categoría contra el total de votantes (las
  reglas del contrato de validación) y cuántas celdas faltan revisar.
- **Qué no se muestra:** nombres ni firmas de autoridades de mesa y fiscales. Las zonas de
  firma de la plantilla se tapan en la vista de revisión (participant-protection, F-50).

## 3. Revisiones independientes

- **Qué es independiente:** una revisión hecha desde una **cuenta de la red de actas
  distinta** de la de quien cargó y de las de revisiones anteriores, en otro dispositivo,
  sobre la misma imagen (mismo SHA-256). No requiere identidad (scrutiny-backend §3.5).
  Las redes de confianza y de actas siguen desconectadas (TC-13): revisar no suma
  reputación de participación (NG-13).
- **Asignación:** el servidor ofrece actas para revisar sin mostrar quién las cargó ni
  quién más las revisó. Prioriza las de menor confianza y las mesas de la muestra del
  conteo rápido.
- **Revisión asistida y doble carga a ciegas:** ver los números ya cargados es más rápido,
  pero puede inducir a aceptar errores (sesgo de anclaje). Por eso (RV-5 ★) la revisión
  asistida es la regla general y la **doble carga a ciegas** (F-3, scrutiny-backend §4) se
  mantiene para las mesas de la muestra y para las actas en disputa. Además, una de cada
  N revisiones lleva un **valor de control** alterado a propósito, que mide si las
  personas revisan o aceptan todo; nunca se cuenta en el tally.
- **Información a quien carga:** en el detalle de su captura ve "Sin revisar",
  "Revisada por 1 persona", "Revisada por 2 personas independientes", etc., las celdas
  que alguien cambió y la confianza del acta. No ve quién revisó.

## 4. Confianza del acta

Por cada celda, cuentan las **revisiones humanas que coinciden** en el mismo valor (la
carga de quien sube el acta cuenta como la primera). Con `n` coincidencias:

| `n` | Situación | Confianza de la celda |
| --- | --- | --- |
| 0 | Sólo lectura automática | la confianza del OCR, con tope 0,30 |
| 1 | Una persona (quien cargó) | 0,50 |
| 2 | Dos personas independientes | **0,85** |
| 3 | Tres | 0,955 |
| 4 o más | Cuatro o más | 0,99 (tope) |

Fórmula de referencia: `c(n) = 1 − 0,5 · 0,3^(n−1)` para `n ≥ 1`. La segunda revisión
independiente es la que más suma; desde la tercera, cada una suma poco (pedido del autor).
Los parámetros (0,5 y 0,3) se calibran con las muestras confirmadas (RV-6).

- **Desacuerdo:** si dos revisiones dan valores distintos, la celda queda **en disputa**,
  su confianza es la del valor con más coincidencias menos una penalización, y el acta
  vuelve a la cola para otra revisión (preferentemente a ciegas).
- **Confianza del acta = la de su celda más débil** (no el promedio: una sola celda mal
  leída cambia el resultado de la mesa). Se muestra también "X de Y celdas con 2 o más
  revisiones".
- **Qué no hace la confianza:** no califica a la mesa ni a las autoridades, no se presenta
  como "acta sospechosa" y no reemplaza el escrutinio oficial. El cotejo con el oficial
  (F-09) usa el tally confirmado, y una diferencia se rotula "diferencia, no irregularidad"
  (SB-10).

## 5. Cambios de contrato (vía `contract-change`, cuando se implemente)

- `capture.schema.json`: `origin` admite `ocr-server` (lectura aceptada sin cambios) y
  `review-edited`; las lecturas se guardan con `engine`, `engineVersion`, `confidence` y
  `bbox` por celda, **aparte** de los valores confirmados.
- Plantillas: regiones de cada celda e identificador de fila por plantilla (para dibujar
  al lado del manuscrito y para tapar firmas).
- API (scrutiny-backend §6): `POST /v1/readings` (páginas → lecturas por celda, sin
  guardar la captura si quien carga no confirma; RV-2),
  `GET /v1/review-queue`, `POST /v1/captures/{id}/reviews` con `mode: assisted|blind`, y
  `GET /v1/captures/{id}/confidence`. Vectores en `contracts/api/vectors/` y
  `contracts/vectors/confidence.json` para la fórmula.

## 6. Decisiones pendientes

| ID | Decisión | Opciones (★ = recomendada) |
| --- | --- | --- |
| RV-1 | Lectura principal | ★ Servidor, con OCR del teléfono como respaldo sin red · sólo servidor · sólo teléfono |
| RV-2 | Qué guarda el servidor si quien carga no confirma | ★ Nada: la lectura previa se descarta a las 24 h · se guarda como captura no confirmada |
| RV-3 | Escala visual de confianza | ★ 4 escalones de gris a negro + contorno punteado en los bajos · degradado continuo · color (verde/ámbar/rojo) |
| RV-4 | Quién puede revisar | ★ Cualquier cuenta de la red de actas distinta de quien cargó · sólo fiscales con mesa asignada · voluntarios con capacitación |
| RV-5 | Revisión asistida vs. a ciegas | ★ Asistida en general, a ciegas en muestra y disputas, con valores de control · siempre a ciegas · siempre asistida |
| RV-6 | Fórmula de confianza | ★ `1 − 0,5·0,3^(n−1)`, calibrada con muestras · tabla fija · bayesiana por exactitud medida de cada revisor |
| RV-7 | Confianza del acta | ★ Mínimo de sus celdas · promedio · ponderada por votos de la celda |
| RV-8 | Qué ve quien cargó | ★ Cantidad de revisiones, celdas cambiadas y confianza · sólo "revisada / no revisada" |

## 7. Chequeo preliminar de electoral_counsel (no reemplaza el completo)

- 🟠 **Datos personales en las imágenes:** las actas tienen nombres y firmas de autoridades
  y fiscales. Mostrarlas a revisores desconocidos es un tratamiento nuevo (Ley 25.326):
  tapar zonas de firma y nombres en la vista de revisión y documentar la base legal.
- 🟠 **Mostrar la confianza como acusación:** una confianza baja es incertidumbre de
  lectura, no una irregularidad. Textos revisados por `neutrality_auditor`.
- 🟡 **Publicación en la veda:** la confianza y el tally no se publican durante el comicio
  ni hasta 3 h después del cierre (art. 71 inc. h; embargo de scrutiny-backend).
- 🟡 **Valores de control:** se informa en los términos de uso que existen y que nunca
  entran en el tally.

## 8. Criterios de aceptación

1. Con conexión, una captura de la plantilla 2023 muestra las lecturas del servidor junto a
   cada número manuscrito e identificador de fila, con 4 escalones de intensidad según la
   confianza; sin conexión, cae al OCR del teléfono con su rótulo.
2. Ningún valor con origen `ocr` u `ocr-server` entra al tally sin una confirmación humana.
3. Toda edición conserva la lectura original y el valor anterior; la imagen no cambia.
4. `contracts/vectors/confidence.json` reproduce la tabla de §4 (0 a 5 revisiones,
   desacuerdos y mínimo por acta) en el backend y en la app.
5. La cuenta que cargó un acta no puede contarse como revisión independiente de esa acta.
6. Quien cargó ve la cantidad de revisiones independientes y las celdas cambiadas, sin
   identidades.
7. En la vista de revisión, las zonas de firma de la plantilla están tapadas.
8. Prototipo navegable aprobado por el autor antes de implementar (review-pipeline).
