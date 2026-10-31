# SPEC · Red ciudadana para el cuidado del proceso democrático

Estado: **producto central definido por el autor el 31/10/2026; decisiones RC-1 a RC-5 pendientes.**
Visión: [sdd/specs/vision/SPEC.md](../vision/SPEC.md).
Chequeo de `electoral_counsel`: **pendiente** (obligatorio, en especial RC-3 y la veda).

## Problema

Millones de personas hacen acción política todos los días en redes que pertenecen a
grandes empresas. Esas redes deciden qué se ve, ordenan la conversación según lo que
genera más interacción y venden alcance. La energía cívica queda dispersa y sujeta a
reglas que nadie eligió. Durante una elección, eso pone en riesgo el propio proceso democrático.

## Qué es

Una **red social ad hoc**, ciudadana y no partidaria, para **cuidar el proceso
democrático** de las elecciones 2027. Ahí la ciudadanía y las fuerzas políticas
pueden debatir, **llegar a consensos** y decidir **modalidades de acción** para
proteger ese proceso.

**No es una herramienta de acción política partidaria:** no sirve para hacer campaña
ni para promover candidaturas. Es una herramienta para cuidar las reglas de juego
que comparten todas las fuerzas.

## Principios de diseño

1. **Consenso antes que acción.** La red no actúa por su cuenta frente a las
   plataformas ni frente a nadie. Toda acción externa es el resultado de una
   discusión y un consenso registrados en la red.
2. **Igualdad entre partidos.** Todos los partidos políticos reconocidos pueden
   participar con las mismas herramientas, los mismos límites y la misma visibilidad.
   Ninguna fuerza tiene un lugar privilegiado.
3. **Sin amplificación paga ni algoritmo de interacción.** En la red no se compra
   alcance. El orden de los contenidos es transparente (cronológico, por tema o por
   consenso alcanzado) y está documentado.
4. **Apertura a otras ideas.** Las modalidades de acción iniciales son ejemplos;
   cualquier participante puede proponer otras.
5. **Evidencia y respeto.** Las afirmaciones de hecho llevan fuente. Se modera
   para cuidar la conversación, con reglas públicas y apelación.
6. **Privacidad.** Mínimos datos personales. La afinidad política de una persona es
   un dato sensible (Ley 25.326) y no se le pide a nadie.

## Componentes

| Componente | Qué permite | SPEC |
| --- | --- | --- |
| **Espacios temáticos** | Conversaciones por tema del proceso electoral: plataformas, desinformación, campaña, jornada, escrutinio, regulación | esta |
| **Deliberación y consensos** | Proponer iniciativas, argumentar a favor y en contra, enmendar, versionar y medir el grado de consenso | [civic-deliberation](../civic-deliberation/SPEC.md) |
| **Modalidades de acción** | Catálogo de acciones que la comunidad puede adoptar por consenso, con su procedimiento y responsables | esta (ver abajo) |
| **Herramientas de evidencia** | Auditar plataformas, documentar desinformación, observar la campaña, capturar telegramas | [platform-accountability](../platform-accountability/SPEC.md), [telegram-capture](../telegram-capture/SPEC.md), [amba-simulation](../amba-simulation/SPEC.md) |
| **Participación de partidos** | Cuentas institucionales verificadas de cada partido, con las mismas reglas para todos | esta (RC-3) |

## Modalidades de acción (catálogo abierto)

Ejemplos iniciales. Cada una se activa sólo por consenso:

| Modalidad | Ejemplo |
| --- | --- |
| Auditoría colectiva | Documentar campañas de desinformación viralizadas con dinero electoral |
| Propuesta de regulación | [Cuenta de garantía electoral](../reg-electoral-escrow/SPEC.md) para la publicidad en plataformas |
| Pedido público a plataformas | Carta abierta con evidencia y pedidos concretos, firmada por quienes adhieren |
| Pedido de información pública | Pedidos a organismos del Estado (Ley 27.275) |
| Compromiso entre fuerzas políticas | Acuerdo de buenas prácticas digitales que suscriben los partidos que quieran |
| Fiscalización del escrutinio | Captura y cotejo de telegramas, para cerrar el proceso de auditoría |
| *(nuevas)* | Las que proponga la comunidad |

Cada modalidad define cómo se decide (umbral de consenso), quién ejecuta, qué
evidencia necesita y qué chequeos legales requiere.

## La app evoluciona por consenso

La propia app es un objeto de deliberación. Dentro de la app se pueden **proponer y
discutir nuevas funcionalidades e iniciativas**. Las que alcancen consenso entran al
plan de una **nueva versión**:

1. Propuesta de funcionalidad con la plantilla estructurada (problema, qué cambia, a
   quién beneficia, riesgos y alternativas).
2. Deliberación y medición del consenso, con las mismas reglas que cualquier iniciativa.
3. Las propuestas con consenso pasan a una SPEC (flujo SDD) con el chequeo de
   electoral_counsel y el pipeline de revisión.
4. Se publica qué propuestas entraron en cada versión, y por qué otras no
   (inviabilidad técnica o legal explicada).

Las versiones iniciales (escaneo de telegramas y actas) las define el equipo; a partir
de que exista la red, el plan de versiones se alimenta de estos consensos.

## Cómo se decide (borrador, RC-2)

- Una iniciativa pasa a **acción** cuando reúne un consenso amplio: cantidad mínima
  de participantes verificados, porcentaje de acuerdo y ausencia de objeciones
  fundadas sin respuesta. Los umbrales se definen y publican antes de usarlos.
- **Consenso transversal:** para acciones que involucran a partidos, se exige el
  apoyo de fuerzas de distinto signo. El objetivo es que ninguna acción sea de una facción.
- Toda acción tiene chequeo previo de `electoral_counsel`. Un ⛔ suyo la frena hasta
  que el autor decida.

## Participación de partidos políticos (RC-3)

- Pueden participar todos los partidos con reconocimiento legal, en igualdad.
- Cuenta institucional verificada (por ejemplo, contra el registro de cuentas
  oficiales de la justicia electoral, ver `docs/legal/`).
- Mismas reglas para todos: límites de publicación, prohibición de contenido de
  campaña y de pedidos de voto, e iguales espacios para argumentar.
- **Veda electoral:** definir con electoral_counsel cómo se comportan las cuentas
  partidarias y los contenidos durante la veda y el día de la elección.

## Decisiones pendientes

- RC-1. Construir o reutilizar: una plataforma de participación existente (Decidim,
  CONSUL) extendida con espacios y evidencia, o una red propia. Ver DL-1 en civic-deliberation.
- RC-2. Umbrales de consenso y de consenso transversal.
- RC-3. Reglas exactas para los partidos y verificación de sus cuentas.
- RC-4. Gobernanza de la red: quién la opera, cómo se eligen moderadores y cómo se
  rinden cuentas. Se relaciona con V-4 (organización sin vínculo partidario).
- RC-5. Identidad: verificación de personas sin pedir más datos de los necesarios.

## Criterios de aceptación

1. Ninguna acción externa ocurre sin un registro de consenso y un chequeo legal.
2. Todos los partidos tienen exactamente las mismas capacidades en la red, y eso
   se puede verificar con la documentación pública de reglas y permisos.
3. No hay amplificación paga ni un orden opaco de contenidos.
4. Cualquier participante puede proponer una nueva modalidad de acción o una nueva
   funcionalidad de la app, y las que alcancen consenso entran al plan de versiones.
5. Chequeos de electoral_counsel, neutrality, data_protection y trust_safety registrados.
