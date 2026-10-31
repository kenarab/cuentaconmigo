# SPEC · Propuesta de regulación: cuenta de garantía electoral para publicidad en plataformas

Estado: **propuesta de política pública en borrador.** Fecha: 31/10/2026.
Eje: **E. Propuestas y regulación** de la [visión](../vision/SPEC.md).
Es una de las iniciativas que se discuten en la plataforma de
[deliberación](../civic-deliberation/SPEC.md); no tiene prioridad sobre las que propongan otras personas.
Chequeo de `electoral_counsel`: **pendiente** (obligatorio antes de difundirla).

## Problema

Durante la campaña, el dinero destinado a las elecciones compra alcance en las
plataformas. Parte de ese dinero se usa para viralizar campañas de desinformación.
Cuando el Estado detecta un uso indebido, la elección ya pasó, el dinero ya se cobró y
las plataformas, en su mayoría extranjeras, no tienen incentivos ni plazos para
responder. El costo del incumplimiento es bajo y llega tarde.

## Idea central

Todo pago que financie publicidad o amplificación electoral en plataformas digitales
durante el período electoral se deposita en una **cuenta de garantía electoral**:
queda **congelado** y se liquida a la plataforma **después de la elección**, una vez
verificado que cumplió las reglas.

Cumple dos funciones a la vez:

1. **Herramienta para el Estado:** el dinero es trazable y está retenido mientras la
   justicia electoral puede investigar, de modo que una sanción es ejecutable sobre
   fondos que todavía están en el país.
2. **Advertencia para las plataformas:** cobrar depende de cumplir con la ética
   electoral, así que adecuarse pasa a ser su propio interés.

## Mecanismo propuesto (borrador para discutir)

| Elemento | Propuesta inicial | Alternativas a discutir |
| --- | --- | --- |
| Qué dinero alcanza | Todo pago por anuncios, contenido patrocinado o amplificación paga de contenido electoral durante el período de campaña | Sólo pagos de partidos y candidaturas · también terceros (agencias, "influencers", cuentas no oficiales) · umbral mínimo de monto |
| Quién deposita | Quien paga (partido, alianza, candidatura o tercero), en una cuenta del banco público designado | La plataforma recibe el pago y lo transfiere a la cuenta de garantía |
| Quién custodia | Banco público, con supervisión de la justicia electoral | Fideicomiso con auditoría pública |
| Cuándo se libera | Al cierre de un plazo después del escrutinio definitivo, sin sanciones firmes | Liberación escalonada (parte en campaña, el resto después) |
| Condiciones para liberar | Biblioteca de anuncios completa y pública; sin anuncios durante la veda; respuesta en plazo a la justicia electoral; etiquetado de contenido pago | Indicadores del [tablero público de plataformas](../platform-accountability/SPEC.md) como evidencia |
| Si hay incumplimiento | Retención total o parcial, destino a un fondo de educación cívica o de fortalecimiento electoral | Multa graduada · devolución al pagador con sanción a la plataforma |
| Transparencia | Datos abiertos: montos por plataforma, pagador y período | Con resguardo de datos personales de terceros |

## Estrategia parlamentaria (borrador)

Es una regulación: para existir necesita una ley. Etapas propuestas:

1. **Diagnóstico con evidencia:** casos documentados por los ejes A y B
   (desinformación viralizada con dinero de campaña) y comparación con experiencias
   internacionales (a relevar con fuentes; por ejemplo, la regulación europea de
   publicidad política y las reacciones de las plataformas).
2. **Documento base** abierto a discusión en la plataforma de deliberación, con
   versiones y aportes trazables.
3. **Validación jurídica** por un abogado o abogada electoral y especialistas en
   derecho constitucional y tributario/financiero.
4. **Coalición transversal:** buscar coautores de **todos los bloques**. La iniciativa
   es no partidaria y debe poder presentarla cualquier fuerza.
5. **Texto de proyecto de ley** y estrategia de comisiones (a identificar: asuntos
   constitucionales, presupuesto, comunicaciones, según el texto).
6. **Mayorías y plazos:** las leyes del régimen electoral requieren mayoría absoluta
   del total de miembros de cada cámara (Constitución, art. 77; verificar) y
   el calendario electoral 2027 condiciona cuándo podría aplicarse.
7. **Incidencia pública:** campaña de comunicación con los datos del tablero de plataformas.

Todo contacto con legisladores, organismos o medios lo decide y lo hace el autor.

## Riesgos y preguntas para el chequeo legal

| Riesgo | Pregunta | Rol |
| --- | --- | --- |
| Libertad de expresión (Const. arts. 14 y 32; CADH art. 13) | ¿Retener el pago, no el contenido, evita una censura previa? Hay que diseñarlo neutral respecto del contenido | electoral_counsel |
| Derecho de propiedad y libertad de comercio | ¿Es razonable y proporcional retener fondos por un plazo acotado? | electoral_counsel |
| Jurisdicción sobre plataformas extranjeras | ¿Cómo se obliga a quien cobra desde el exterior? ¿Por la vía del pagador local? | electoral_counsel, legal_analyst |
| Evasión | Pagos a terceros, "influencers", cuentas pantalla, criptoactivos, pagos desde el exterior | platform_accountability_analyst, security_analyst |
| Que las plataformas dejen de vender publicidad electoral | ¿Es un resultado aceptable o un efecto no deseado? Evaluar cómo afecta a fuerzas chicas | neutrality_auditor |
| Definición de "contenido electoral" | Una definición demasiado amplia alcanza discurso ciudadano; una demasiado estrecha deja huecos | electoral_counsel, neutrality_auditor |
| Neutralidad | El mecanismo no debe favorecer a quien gobierna ni a ninguna fuerza | neutrality_auditor |

## Criterios de aceptación de esta SPEC

1. Chequeo de `electoral_counsel` registrado en `checks/electoral_counsel.md`, con
   líneas de acción para cada ⛔ o ⚠️.
2. Al menos dos alternativas evaluadas para cada elemento del mecanismo.
3. Publicada en la plataforma de deliberación como **una propuesta más**, con autoría y versión.
4. Ninguna afirmación sobre experiencias internacionales sin fuente verificada.
