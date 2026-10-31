<!-- reviewer: Astra (gpt-6-astra via codex exec, read-only) · lens: ux · target: sdd/specs/app-screens · revision: c8b3d20 · date: 2026-10-31 12:47 -03 -->

## 1. **Alcance revisado**

Revisión independiente documental por Codex. `git rev-parse --short HEAD`: **`c8b3d20`**, coincide con la revisión solicitada.

- [sdd/specs/app-screens/SPEC.md](/Users/kenarab/home.agents/git/cuentaconmigo/sdd/specs/app-screens/SPEC.md): documento completo, foco en E-00…E-13.
- Contexto: `telegram-capture/SPEC.md`, `mobile-platform/SPEC.md`, `AGENTS.md`, roles `reviewer` y `ux_designer`, manifiesto y plantilla de tarea.

Sin modificaciones, instalaciones ni acceso a la red. Las pantallas son **propuestas pendientes del autor**; D-001 figura como decisión tomada. Las ubicaciones siguientes corresponden a `app-screens/SPEC.md`.

## 2. **Hallazgos**

1. **⛔ Recuperación de errores con destino incorrecto.** E-04 permite omitir datos de mesa; E-08 dirige **todos** los errores a E-07, que sólo contiene totales y votos. Ante `missing_mesa`, «Ir al campo» no conduce al dato faltante: obliga a retroceder buscando dónde corregirlo. **Fuente:** líneas 478–484, 593–600 y 642–654.

2. **⛔ Promesa contradictoria de envío automático.** E-11 dice «se van a enviar cuando haya red» y reutiliza ese texto para el estado sin conexión, aunque P0 no envía. Una persona podría cerrar la app creyendo que entregó la evidencia. Además, E-10 no especifica cuándo registrar `exportedAt` si se cancela o falla el menú de compartir. **Fuente:** líneas 723–729 y 735–763; exclusión de envío en líneas 75–77.

3. **⚠️ Las fichas OCR facilitan asignaciones equivocadas que las sumas no detectan.** Se ofrecen números deduplicados de toda la página, sin identificar su fila de origen. Intercambiar dos votos entre listas conserva el total y puede producir «Todo cierra». Repetir sólo los totales, variante mínima de F-3, tampoco detectaría ese intercambio. **Fuente:** líneas 254–257, 594–607, 648–649 y pregunta 4 de §8.

4. **⚠️ Accesibilidad de controles no equivale a transcripción verificable sin visión.** E-06 sólo etiqueta la imagen; E-07 anuncia el destino de cada ficha, pero no qué fila del documento la originó. No se describe cómo alguien que depende de VoiceOver/TalkBack comprueba la correspondencia. «Se puede completar la carga sólo con VoiceOver» resulta insuficiente como criterio de fidelidad. **Fuente:** líneas 550–559, 605–614 y tabla de §6.

5. **⚠️ Diseño con texto grande todavía ambiguo.** Se exige AX5 sin recortes, pero también botón de 56 pt, franja permanente, imagen fija y fichas sobre el teclado. No se aclara si 56 pt es mínimo ni cómo vuelve el foco tras ampliar la imagen. Android tampoco explicita dimensiones táctiles propias. Puede quedar inaccesible el campo o la acción principal en pantallas chicas. **Fuente:** líneas 309–317, 331–337, 591–608 y §6.

6. **⚠️ Recuperación de borradores y almacenamiento sin criterios suficientes.** Se promete retomar el paso y se afirma «no se perdió nada», pero no se define qué queda guardado ante cierre, batería agotada o disco lleno. El mensaje de E-05 tampoco ofrece un reintento explícito conservando la imagen. Bajo presión, la persona podría salir y perder trabajo aún no persistido. **Fuente:** líneas 368–373, 518–521 y 685–687.

7. **⚠️ La reducción de pasos no está demostrada.** La recomendación anuncia «cuatro pantallas cortas», pero el recorrido E-02→E-09 atraviesa **ocho pantallas**, sin contar el escáner. E-07 muestra «Paso 4/4» antes de validación y confirmación. Esto subestima el esfuerzo y comunica un final prematuro. **Fuente:** líneas 287–303; E-02…E-09; comparación de línea 785.

8. **✅ Buenas bases, todavía sin validación en uso.** Cero explícito, OCR sin autocompletar, errores con texto, zoom mediante botones y explicación del bloqueo reducen ambigüedades. La alternativa de importar está prevista ante cámara denegada. El voseo es mayormente claro. **Fuente:** criterios comunes, E-05/E-06, E-07 y E-09. Esto acredita intención de diseño, no funcionamiento.

## 3. **Alternativas**

Costos relativos de diseño e implementación, no estimaciones de plazo. **Elegiría A en cada fila.**

| Hallazgo | A: recomendada, costo y riesgo | B: alternativa, costo y riesgo |
|---|---|---|
| 1 | Dirigir cada error a su pantalla y campo, conservando el regreso a validación. **Costo bajo; riesgo:** manejar bien el foco. | Editar mesa también desde E-07. **Costo medio; riesgo:** sobrecargar el editor. |
| 2 | P0 con «Guardada en este teléfono» y exportación manual; distinguir cancelación, exportación y recepción. **Costo bajo; riesgo:** entrega manual pendiente. | Separar completamente los diseños P0 y futuros de E-11. **Costo medio; riesgo:** divergencia entre variantes. |
| 3 | Revisión guiada fila por fila contra la imagen antes del bloqueo, con mensaje «Las sumas coinciden». **Costo medio; riesgo:** persiste error humano. | F-3 completa a ciegas, incluyendo filas. **Costo alto en tiempo; riesgo:** fatiga o errores coincidentes. |
| 4 | Definir un recorrido asistido para cotejar el documento y declarar su límite de autonomía. **Costo medio; riesgo:** depender de otra persona. | Diseñar lectura contextual por fila, siempre presentada como OCR pendiente de verificar. **Costo alto y ampliación de alcance; riesgo:** confiar en reconocimiento erróneo. |
| 5 | Alturas mínimas flexibles, modo sólo campos y retorno al mismo campo; comprobar AX5 y Android al 200 %. **Costo medio; riesgo:** más desplazamiento. | F-1 adaptado, un campo por pantalla con acceso al documento. **Costo medio; riesgo:** más transiciones y pérdida de contexto. |
| 6 | Guardado automático con estados «Guardando/Guardado/Error» y reintento que preserve lo recuperable. **Costo medio; riesgo:** fallas de almacenamiento igualmente posibles. | Guardado explícito con aviso al salir. **Costo bajo; riesgo:** olvidos y pérdida ante cierre inesperado. |
| 7 | Mantener el híbrido y mostrar etapas honestas: preparar, cargar, revisar, confirmar. **Costo bajo; riesgo:** conserva ocho pantallas. | Unificar tipo y mesa, y captura y revisión de páginas. **Costo medio; riesgo:** pantallas más densas. |

**Elección entre las propuestas:** prefiero el **híbrido F-1/F-2 corregido**: conserva orientación inicial y comparación con la imagen durante la carga. F-1 completo agrega transiciones; F-3 completo ofrece otra comprobación, pero demanda más tiempo y no garantiza ausencia de errores.

Para navegación, elegiría **N-C por etapas**, empezando directamente en «Mis capturas», sin depender de fecha ni cuenta. N-A agrega búsqueda; N-B simplifica el acceso pero supone mantener dos apps cuando exista la red. Es una recomendación UX, no una decisión arquitectónica ni una aprobación legal.

## 4. **No verificado**

- Implementación, pruebas del núcleo, prototipos ejecutables ni comportamiento real de guardado/exportación.
- VoiceOver/TalkBack, contraste, áreas táctiles, AX5, teclado y foco en dispositivos.
- Legibilidad nocturna, disponibilidad efectiva de linterna, reflejos, rendimiento del zoom/OCR y memoria en teléfonos modestos.
- Recuperación tras interrupciones y funcionamiento sin conexión de cada destino de exportación.
- Fuentes legales y revisión de `electoral_counsel`; este informe no las sustituye.
- Cuota disponible: no hay herramienta para consultarla.

## 5. **Veredicto**

**⛔ No aprobar la propuesta como guía de implementación hasta corregir los destinos de recuperación y las promesas de envío; la accesibilidad y el uso en campo siguen pendientes de validación.**