# SPEC · Simulación de la red de confianza para la hackatón

Estado: **alcance agregado por el autor el 31/10/2026; diseño propuesto (rol `planner`,
Claude); decisiones NS-1 a NS-8 pendientes.** Amplía la decisión F-P0 = b del issue #1:
la red ya no se presenta sólo como visión, sino como **simulación funcionando**.
Depende de [trust-chain-identity](../trust-chain-identity/SPEC.md),
[network-governance](../network-governance/SPEC.md),
[civic-network](../civic-network/SPEC.md), [civic-deliberation](../civic-deliberation/SPEC.md),
[participant-protection](../participant-protection/SPEC.md) y
[review-pipeline](../review-pipeline/SPEC.md) (prototipo antes de implementar).
Chequeo de `electoral_counsel`: **preliminar abajo; el completo queda pendiente.**

## Pedido del autor (31/10/2026)

> "Me gustaría que pongamos dentro del alcance de la hackatón una simulación del sistema
> de credibilidad colectivo que se impacta en la app, posibilidad de escribir mensajes,
> escribir en foros, en encuestas y votación, integración de agentes."

## Qué es y qué no es

- **Es** una simulación **local y con datos ficticios** de la red de confianza: una
  población sintética de personas seudónimas (y algunos agentes de IA rotulados) que
  escriben, deliberan, votan y acumulan **reputación de participación**. La persona que
  prueba la app entra como una más y ve cómo sus acciones y las ajenas cambian la
  reputación y, con ella, lo que la app le habilita.
- "Sistema de credibilidad colectivo" es el nombre que usa el autor para lo que las SPECs
  llaman **reputación de participación** (TC-10 ★, NG-4). En la app se dice
  "reputación de participación"; nunca "créditos", "token" ni "puntaje social".
- **No es** la red real: no hay servidor, cuentas, mensajes entre personas reales ni datos
  personales. Todo vive en el dispositivo (o en el navegador) y se puede reiniciar.
- **No toca el escrutinio:** la red de confianza y la de capturas de actas siguen
  **desconectadas** (TC-13). Una captura de telegrama no suma reputación (NG-13 ★) y la
  reputación no cambia nada del flujo de captura.

## Componentes

### 1. Reputación de participación ("credibilidad colectiva")

- Reglas en un archivo versionado `contracts/reputation/rules.json`: dimensiones
  (evidencia, verificación, deliberación, cuidado, confiabilidad), puntos y topes del
  catálogo de [network-governance §2](../network-governance/SPEC.md), decaimiento y
  umbrales de permisos. El mismo JSON lo usan el prototipo y la app (como el flujo de
  captura). Vectores en `contracts/vectors/reputation.json`.
- **Cómo impacta en la app:** cada cambio muestra **"por qué subió o bajó"** con la regla
  aplicada; los permisos se desbloquean por umbral por dimensión (invitar, verificar
  evidencia ajena, abrir foros de trabajo, entrar al sorteo de paneles) y la app los
  muestra como "lo que podés hacer ahora" y "qué te falta".
- **Reglas que la simulación tiene que demostrar** (no son configurables en la demo):
  la reputación da tareas, **no votos** (una persona verificada, un voto); respaldar no suma;
  no suma publicar, reaccionar ni coincidir con la mayoría; ninguna señal mira el contenido
  de la opinión ni el partido; sin ranking público, insignias ni rachas.
- **Escenarios sembrados:** comportamiento constructivo, una brigada coordinada (anillo de
  cuentas que se valoran entre sí) y una cuenta que sube evidencia falsa. La simulación
  muestra que el anillo no gana reputación (topes, diversidad de rama) y que la evidencia
  falsa resta en confiabilidad, con apelación.

### 2. Mensajes

- Mensajes directos entre seudónimos de la simulación. En la red real serían cifrados de
  extremo a extremo (participant-protection, principio 4); la simulación lo dice en
  pantalla y no promete cifrado que no tiene.
- No suman reputación. Se pueden señalar como abuso (peso por calidad del señalador,
  nunca sanción automática).

### 3. Foros

- **Espacios temáticos** abiertos (plataformas, desinformación, campaña, jornada,
  escrutinio, regulación) en **orden cronológico** u **ordenados por consenso**, siempre
  explicado (civic-network, principio 3).
- **Foros de trabajo** que se abren con reputación (dos dimensiones ≥ u3) y se leen desde
  nivel 1.
- **Argumentos a favor y en contra con fuente**, que sí suman reputación de deliberación
  cuando un panel sorteado ciego los valida (en la simulación, el panel es sintético).

### 4. Encuestas y votación

Son dos cosas distintas y la app no las mezcla:

| | Encuesta | Votación de consenso |
| --- | --- | --- |
| Para qué | Tomar el pulso de la comunidad sobre la **red** (prioridades, reglas, funcionalidades) | Decidir una iniciativa o una modalidad de acción (RC-2) |
| Efecto | Ninguno; es informativa | Si se alcanza el umbral, la iniciativa pasa a acción (con chequeo de electoral_counsel) |
| Quién | Cualquier persona de la red | Personas verificadas con 14 días; **una persona, un voto** |
| Resultado | Agregado | Agregado, con umbral y consenso transversal publicados antes |

- **Nunca** encuestas ni votaciones sobre intención de voto, candidaturas o partidos
  (régimen de encuestas del Código Electoral y dato sensible de la Ley 25.326). La app
  rechaza la plantilla si no se refiere a la red, sus reglas o sus iniciativas.
- El sentido del voto de cada persona no se guarda junto a su cuenta: se guarda
  "ya votó" y el conteo agregado.
- Demo: la iniciativa de la [cuenta de garantía electoral](../reg-electoral-escrow/SPEC.md)
  (F-40) recorre deliberación → votación → consenso.

### 5. Integración de agentes

- Los agentes de IA participan **siempre rotulados** como agentes ("🤖 Agente ·
  resumidor"), con un rol público y quién lo opera. No votan, no tienen reputación, no
  invitan ni moderan solos.
- Agentes de la demo: **resumidor** de un debate (a favor / en contra con fuentes),
  **verificador de fuentes** (si el enlace existe y dice lo citado), **monitor de
  plataformas** (alimenta el archivo de evidencia, F-33) y **asistente de propuestas**
  (ayuda a completar la plantilla estructurada).
- Todo lo que un agente produce es una sugerencia que una persona acepta o descarta; queda
  registrado qué agente, qué versión y qué se le pidió.
- En la hackatón, los agentes son **guionados** (respuestas predefinidas y deterministas);
  conectar un modelo real es NS-5.

## Población sintética

- 60–200 personas ficticias con seudónimos generados (sin nombres reales, sin partido),
  rama de invitación, antigüedad y un perfil de conducta (constructiva, ocasional, brigada,
  falsificadora). Semilla fija para que la demo sea reproducible.
- Un **reloj simulado** permite adelantar días para ver el decaimiento y los permisos.
- El gráfico de invitaciones se muestra sólo a quien explica la simulación (modo
  presentador), nunca como si fuera la red real (TC: privacidad del grafo).

## Dónde se muestra (propuesta)

1. **Prototipo navegable** `design/prototypes/red/index.html` (obligatorio, review-pipeline),
   que ejecuta `rules.json` y la población.
2. **Pestaña "Red (simulación)" en la app iOS**, con franja permanente "Simulación:
   personas y mensajes ficticios", siguiendo la navegación que se decida en AS-1. El
   escrutinio queda igual.

## Decisiones pendientes

| ID | Decisión | Opciones (★ = recomendada) |
| --- | --- | --- |
| NS-1 | Dónde se ve en la hackatón | ★ Prototipo HTML + pestaña en la app · sólo prototipo HTML · sólo la app |
| NS-2 | Tamaño de la población | ★ 120 personas, 3 escenarios sembrados · 60 · 200+ |
| NS-3 | Reglas de reputación en la demo | ★ Las de network-governance §2 tal cual, con umbrales u1–u4 de ejemplo · simplificadas a 2 dimensiones |
| NS-4 | Encuestas | ★ Sólo sobre la red y sus iniciativas, con validación de plantilla · sin encuestas, sólo votación |
| NS-5 | Agentes | ★ Guionados (sin red ni modelo) · un modelo real vía API (requiere decidir proveedor, costo y datos) · ambos con interruptor |
| NS-6 | Mensajes | ★ Directos entre seudónimos, sin adjuntos · sin mensajes, sólo foros |
| NS-7 | Persona que prueba la app | ★ Entra como recién invitada (nivel 1) y sube haciendo cosas · elige un perfil precargado |
| NS-8 | Reloj simulado | ★ Botón "pasar 7 días" · tiempo real |

## Chequeo preliminar de electoral_counsel (no reemplaza el completo)

- 🟠 **Encuestas:** el Código Electoral prohíbe publicar encuestas 48 h antes y durante
  el comicio (art. 71 inc. d/e/h, ver `docs/legal/MARCO_LEGAL.md`). Mitigación: encuestas
  sólo sobre la red, nunca sobre candidaturas ni intención de voto; aun así, bloquear la
  publicación de resultados en esas ventanas en la red real.
- 🟠 **Dato sensible:** votar una iniciativa puede revelar opinión política. Mitigación:
  no guardar el sentido del voto por cuenta; publicar sólo agregados.
- 🟡 **Agentes:** riesgo de que se tomen como personas o como posición de la red.
  Mitigación: rótulo permanente, sin voto, registro de lo que produjeron.
- 🟡 **Simulación tomada como real:** franja permanente y datos 100 % ficticios.
- ✅ Sin datos personales: la población es sintética y local.

## Criterios de aceptación

1. Con la misma semilla, la simulación produce la misma reputación para cada persona
   sintética; `contracts/vectors/reputation.json` pasa en JS y en Swift.
2. Toda variación de reputación visible tiene su motivo ("por qué") con la regla aplicada.
3. Un voto vale lo mismo para cualquier nivel de reputación (test que compara resultados
   con y sin reputación).
4. La brigada sembrada no supera a las cuentas constructivas en ninguna dimensión.
5. Toda intervención de un agente está rotulada y no puede votar.
6. Una encuesta sobre candidaturas o intención de voto es rechazada.
7. La captura de telegramas no cambia de comportamiento y no lee ni escribe reputación.
8. Prototipo aprobado por el autor antes de la implementación en SwiftUI.
