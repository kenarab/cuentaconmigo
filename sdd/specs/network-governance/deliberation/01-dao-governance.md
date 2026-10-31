# Deliberación · 01 · Gobernanza descentralizada (perspectiva DAO)

Autoría: especialista en gobernanza descentralizada (agente Claude, sesión del 31/10/2026).
Estado: **posición para la deliberación; nada está decidido. Decide el autor.**
Chequeo de `electoral_counsel`: **pendiente** (obligatorio para todo lo que sigue).
Responde a RC-2 y RC-4 de [civic-network](../../civic-network/SPEC.md) y a TC-2 y TC-10
de [trust-chain-identity](../../trust-chain-identity/SPEC.md).

## 1. ¿DAO sí, no o híbrido?

**Posición: híbrido.** Conviene tomar de las DAO sus mecanismos (reglas escritas y
públicas, decisiones registradas e imposibles de alterar sin que se note, demoras antes
de ejecutar, poderes repartidos), **sin** token, sin blockchain pública y sin dinero
en juego.

| Opción | A favor | En contra |
| --- | --- | --- |
| **A. DAO on-chain** (contratos en una blockchain pública, voto con token o insignias no transferibles) | Nadie puede alterar las reglas en silencio; ejecución automática; antecedente de las insignias no transferibles ("soulbound") | Lo escrito en la cadena es **permanente**: choca con la supresión de datos (Ley 25.326) y con la sensibilidad del grafo y las posiciones (L2 del chequeo de counsel). Con token, quien más tiene más decide (plutocracia), y el poder de voto se puede comprar: Beanstalk perdió unos USD 76-80 M (titulares: 182 M) en 2022 por un voto con préstamo flash y sin demora de ejecución. Comisiones y billeteras excluyen gente. En un contexto electoral, "cripto" invita sospechas de financiamiento opaco |
| **B. Off-chain con registro verificable** (servidor común + registro de solo agregado con árbol de Merkle, firmado y cofirmado por testigos externos) | Cualquiera puede comprobar que el registro no se reescribió; se guardan **hashes y decisiones**, no datos personales; barato; apto para la hackatón | Sigue habiendo un operador que puede censurar *antes* de registrar o caerse. Hacen falta testigos independientes de verdad |
| **C. Federada** (varias organizaciones operan nodos con las mismas reglas; decisiones válidas sólo con firmas de k de n operadores) | Sin punto único de apagado ni de captura (PP-2, principio 6 de participant-protection); los custodios de distinto origen ya existen en TC-12 | Coordinación y costo altos; consenso entre nodos complejo; difícil antes de 2027 si no hay aliados reales |

**Recomendación:** B ahora, diseñada para pasar a C. Opcional: publicar
periódicamente la raíz del registro (sólo un hash) en varios lugares independientes
(sitio de aliados, un diario, una blockchain pública) como sello de tiempo, sin
datos. A todo esto se suma un **derecho de salida**: código abierto y datos públicos
exportables, para que, si la red es capturada, la comunidad pueda bifurcarla.

**Advertencia legal (no verificada, para counsel):** una "DAO" sin persona jurídica
puede dejar responsabilidades difusas en sus miembros (antecedente en EE. UU.: caso
CFTC contra Ooki DAO, 2022-2023). En Argentina probablemente haga falta una
asociación civil o fundación como **encargada formal** que se obligue a cumplir lo que
decida la gobernanza. Una DAO no reemplaza la responsabilidad legal (V-4).

## 2. Reputación dinámica: puntaje continuo, muchos niveles

**Propuesta:** en lugar de 4 niveles fijos, una reputación **continua, por
dimensiones, no transferible, con decaimiento**. Los "niveles" son umbrales para
mostrar (por ejemplo, del 0 al 12) y los **permisos dependen de umbrales por
dimensión**, no de un número único.

- **Dimensiones:** evidencia (capturas), verificación, deliberación, cuidado
  (moderación, mentoría, paneles) y confiabilidad (ausencia de sanciones).
- **Fórmula base (a calibrar en simulación):**
  `R_d(t) = Σ puntos_i · e^(−(t − t_i)/τ)`, con vida media de unos 90 días.
  Nivel mostrado = `floor(log2(1 + R_total))`, tope 12. Rendimientos
  decrecientes: por período, cada dimensión suma `√(puntos)` para que el volumen solo
  no alcance (contra granjas y gamificación).
- **Piso de dignidad:** nadie baja de nivel 1 por inactividad si no tuvo sanciones
  (el decaimiento no expulsa a quien se toma un descanso).
- **No transferible, no comprable, no delegable.** No hay ranking público de
  personas; cada persona ve su propio puntaje y su desglose. Lo público es la
  fórmula y estadísticas agregadas.
- **Neutralidad (criterio 4 de TC):** ninguna regla mira el contenido de la opinión,
  el partido, ni de qué lado argumentó alguien. Se mide **verificación cruzada**, no
  popularidad.

### Catálogo de interacciones (puntos iniciales para calibrar)

| Interacción | Dim. | Puntos | Qué la valida | Tope/mes |
| --- | --- | --- | --- | --- |
| Captura de telegrama o acta que coincide con ≥ 2 capturas independientes de la misma mesa | evidencia | +3 | Coincidencia automática + confirmantes de **ramas distintas** del grafo (ver riesgo de privacidad en §5) | 20 |
| Captura que detecta una divergencia real (después confirmada contra el escrutinio definitivo o por verificadores) | evidencia | +10 | Cotejo con la fuente oficial + 2 verificadores | — |
| Evidencia viral A1 aceptada (hash, fecha, re-chequeo automático) | evidencia | +2 | Segunda persona que la reproduce + re-chequeo del sistema | 15 |
| Verificación ciega de una captura ajena (sin ver la primera lectura) | verificación | +1 | Coincide con la mayoría de verificadores independientes | 40 |
| Argumento con fuente valorado como "bien fundado" por un **panel sorteado ciego** (sin autoría visible) | deliberación | +2 | Rúbrica del panel (fuente, pertinencia, respeto), nunca la postura | 10 |
| Enmienda incorporada a una versión consolidada | deliberación | +3 | Registro de versiones de civic-deliberation | 5 |
| Propuesta estructurada que pasa a votación | deliberación | +5 | Umbral de apoyos de personas verificadas | 2 |
| Servicio cumplido en un panel sorteado (dictamen entregado) | cuidado | +4 | Firma del panel en el registro | — |
| Decisión de moderación confirmada en apelación | cuidado | +1 | Comité de apelación | 20 |
| Capacitación o mentoría confirmada por quien la recibió | cuidado | +2 | Confirmación de la persona capacitada | 5 |
| Invitada que a los 60 días sigue activa y sin sanciones | cuidado | +1 | Contadores (no requiere abrir el grafo) | cupo |
| Captura o evidencia probadamente falsa o manipulada | confiabilidad | −15 y cuarentena | Investigación con registro (TC-4) y apelación | — |
| Moderación revertida por abuso | confiabilidad | −3 | Comité de apelación | — |
| Invitada maliciosa confirmada | confiabilidad | −5 y cupo congelado | TC-3 | — |

**No suman nunca:** cantidad de publicaciones, reacciones o "me gusta" recibidos,
seguidores, tiempo en la app, votos emitidos ni el sentido del voto.

**Permisos por umbral (ejemplo):** invitar (confiabilidad ≥ x y cualquier dimensión
≥ y), verificar capturas (verificación ≥ y), recuperar cuentas, ser elegible para
paneles (umbral **bajo**, para que el sorteo no sea de una élite), moderar
(cuidado ≥ z + elección). El cupo de invitación crece con el nivel, con tope.

### Reputación ≠ poder de voto

**La reputación habilita tareas; no multiplica votos.** En los consensos vale
**una persona verificada, un voto**. Ponderar votos por reputación crea una
aristocracia de veteranos y premia a quien tiene tiempo libre (plutocracia de
reputación). Mecanismos más avanzados, para después:

- **Voto cuadrático** (priorizar entre varias propuestas con créditos iguales por
  persona): sólo es seguro con identidad resistente a Sybil; con QR y seudónimos,
  cada cuenta falsa suma créditos. Postergar.
- **Voto por convicción** (el apoyo crece mientras se mantiene): útil para el
  **backlog de funcionalidades** de la app ("la app evoluciona por consenso"), sin
  fechas límite que se puedan manipular. Candidato para la versión 2.
- **Democracia líquida** (delegar el voto por tema, revocable): el grafo de
  delegaciones revela afinidades (dato sensible, art. 7 de la Ley 25.326). Si se
  adopta, delegación secreta y con tope de poder por delegado. Postergar.

## 3. Decidir y cambiar reglas sin dueño central

**Tres capas de reglas:**

| Capa | Contenido | Cómo se cambia | Demora (timelock) |
| --- | --- | --- | --- |
| **Constitución** | Neutralidad, consenso antes que acción, privacidad, no partidaria, sin amplificación paga, derecho de salida | Supermayoría (≥ 2/3) en **dos votaciones** separadas por 30 días, quórum alto, dictamen de un panel sorteado y de counsel | 30 días |
| **Reglas** | Umbrales de consenso, catálogo de interacciones, cupos, moderación | Mayoría calificada (≥ 60 %) + quórum + chequeo de counsel | 7 días |
| **Parámetros** | Puntos, topes, vida media τ | Panel técnico sorteado propone; la red ratifica u objeta | 7 días, publicado con simulación |

- **Quórum adaptativo:** porcentaje de personas activas en los últimos 90 días, con
  piso absoluto. Así no se paraliza ni lo decide un puñado.
- **Veda de reglas:** desde unos 60 días antes de cada elección hasta el escrutinio
  definitivo **no se cambian reglas ni parámetros** (salvo seguridad). Nadie puede
  cambiar las reglas en medio del partido.
- **Consenso transversal sin clasificar partidos:** para acciones que involucran a
  partidos, exigir apoyo o no objeción de cuentas institucionales de al menos k
  partidos distintos, y ningún veto fundado de m o más. Es mecánico: no requiere que
  nadie decida qué partido es "de qué signo" (decisión que rompería la neutralidad).
- **Consejo de seguridad temporal:** k de n custodios (por ejemplo, 5 de 9) de
  distinto origen (sociedad civil, academia, periodismo, técnicos), sin vínculo
  partidario declarado. **Puede pausar, nunca modificar ni ejecutar.** Pausa de 14
  días como máximo, con justificación pública obligatoria, ratificación posterior de
  la red y revisión de cada uso. El ⛔ de `electoral_counsel` funciona igual: frena,
  no decide.
- **Descentralización progresiva con fechas.** Hoy el control es del autor (AGENTS.md
  lo dice: la instrucción del autor prevalece). Conviene decirlo con honestidad y
  publicar un plan: fase fundacional (el autor tiene veto) → fase de transición
  (veto del autor sólo sobre la constitución) → fase autónoma (sin veto
  individual). Cada paso, con criterios medibles (cantidad de personas verificadas,
  custodios activos, auditoría externa). Una "DAO" que oculta un dueño es peor que
  un dueño declarado.

## 4. Evaluaciones colegiadas de las modalidades frente a plataformas

**Paneles ciudadanos sorteados** con algoritmos de selección justos y verificables
(Flanigan et al., *Nature* 2021, usados en más de 40 asambleas).

- **Composición:** 15 personas sorteadas entre las elegibles (umbral bajo de
  reputación, sin sanciones), estratificadas sólo por criterios **no políticos**
  (antigüedad y banda de reputación; nunca afinidad). Más 2 asesores técnicos y
  `electoral_counsel`, con voz y sin voto. Rotación en cada caso y declaración de
  conflictos (por ejemplo, trabajar para la plataforma evaluada).
- **Sorteo verificable:** semilla de aleatoriedad pública (por ejemplo, una baliza
  pública de aleatoriedad) publicada antes, lista de elegibles en hash, para que
  cualquiera repita el sorteo.
- **Proceso:** expediente (evidencia A1-A4, métricas) → audiencia pública con
  argumentos a favor y en contra → deliberación del panel → **puntaje individual y
  secreto por criterio** → **dictamen público** con mayoría, disidencias y
  fundamentos → la red ratifica por consenso (RC-2) → chequeo de counsel →
  ejecución → **evaluación posterior** con las métricas de platform-accountability.
- **Rúbrica (0-4 por criterio; un 0 en criterio eliminatorio la frena):**
  1. Evidencia suficiente y verificable (eliminatorio).
  2. Legalidad y riesgo legal (eliminatorio; counsel).
  3. **Prueba del espejo:** ¿se aplicaría igual si el contenido favoreciera a otra
     fuerza? (eliminatorio).
  4. No usa denuncias de plataformas ni busca silenciar personas (eliminatorio).
  5. Riesgo para participantes (persecución, exposición).
  6. Proporcionalidad y reversibilidad.
  7. Eficacia esperada y cómo se medirá.
  8. Costo y capacidad real de ejecución.
- **Dos niveles de evaluación:** de la **modalidad** (por ejemplo, "carta abierta con
  evidencia" en general, una vez) y de cada **activación concreta** (panel más chico
  o vía rápida si la modalidad ya está aprobada).

## 5. Riesgos y viabilidad

| Riesgo | Mitigación |
| --- | --- |
| **Captura** por un grupo coordinado (infiltración lenta) | 1 persona = 1 voto; consenso transversal; paneles sorteados; timelocks; veda de reglas; derecho de salida |
| **Plutocracia de reputación** | La reputación no pondera votos; decaimiento; rendimientos decrecientes; umbral bajo para paneles |
| **Sybil** (cuentas falsas) | Alta por QR + análisis del grafo (TC); los votos importan menos que los dictámenes; voto cuadrático sólo con identidad fuerte |
| **Gamificación** (hacer cosas para sumar puntos) | Sumar sólo lo verificado por terceros; topes; sin rankings públicos; no llamarlo "créditos sociales" (TC-10) |
| **Colusión entre verificadores** | Verificación ciega, confirmantes de ramas distintas, muestreo de auditoría |
| **Privacidad**: "ramas distintas" exige leer el grafo, y el grafo se abre sólo por quórum (contradicción A5 del chequeo de counsel) | Calcular la diversidad con identificadores de grupo gruesos y rotativos, o en el dispositivo; a resolver con TC-5/TC-12 |
| **Reputación como dato sensible**: actividad en una red cívica puede revelar afinidad | Retención limitada, puntajes no públicos, borrado tras la elección (TC-5) |
| **Valorar argumentos "puenteando bandos"** (estilo Notas de la Comunidad) | Requiere inferir posturas = dato sensible inferido. **No usarlo**; usar paneles ciegos |
| **Complejidad y costo** para la hackatón | Ver abajo |

**Viable para la hackatón (datos ficticios):**

- Borrador de constitución con las tres capas.
- Registro de decisiones de solo agregado (cadena de hashes en JSON firmada),
  verificable con un script.
- Simulador de reputación con la fórmula y el catálogo, que muestre niveles y el
  efecto de topes y decaimiento.
- Un sorteo verificable de panel y un dictamen de ejemplo con la rúbrica, sobre una
  modalidad ficticia.

**Después:** federación entre organizaciones aliadas, testigos externos del
registro, credenciales anónimas (TC-8), voto por convicción para el backlog, voto
cuadrático y democracia líquida sólo si se resuelven identidad y privacidad.

## Decisiones propuestas al autor

| ID | Decisión | Opciones |
| --- | --- | --- |
| GV-1 | Forma de la red | Híbrido: off-chain verificable, apto para federar ★ · DAO on-chain · centralizada declarada |
| GV-2 | Reputación | Continua por dimensiones con decaimiento y niveles mostrados ★ · 4 niveles fijos (TC-2) |
| GV-3 | Peso del voto | 1 persona verificada = 1 voto ★ · ponderado por reputación |
| GV-4 | Evaluación de modalidades | Paneles sorteados + rúbrica + dictamen público ★ · comité fijo elegido |
| GV-5 | Descentralización | Progresiva, con fases y criterios publicados ★ · inmediata · sin plan |
| GV-6 | Veda de reglas | 60 días antes hasta el escrutinio definitivo ★ · otro plazo · sin veda |

## Fuentes

Verificadas en esta sesión (búsqueda web, 31/10/2026):

- Weyl, Ohlhaver y Buterin, *Decentralized Society: Finding Web3's Soul* (2022), insignias no transferibles: https://papers.ssrn.com/abstract=4105763
- Ataque de gobernanza a Beanstalk (2022): https://www.theregister.com/2022/04/18/beanstalk_loses_182m_flash_loan/ · https://rekt.news/beanstalk-rekt
- Optimism, Cámara de Ciudadanos (una persona, un voto, reputación; veto): https://community.optimism.io/welcome/welcome-overview · https://gov.optimism.io/t/cross-posting-experimentation-with-citizenship/8732 (no verifiqué si el veto está activo)
- Flanigan et al., *Fair algorithms for selecting citizens' assemblies*, *Nature* 596 (2021): https://pmc.ncbi.nlm.nih.gov/articles/PMC8387237/
- Voto por convicción (Commons Stack, 1Hive, BlockScience): https://medium.com/commonsstack/conviction-voting-a-novel-continuous-decision-making-alternative-to-governance-62e215ad2b3d
- MACI, voto privado y resistente a la colusión (requiere coordinador honesto para la resistencia a la colusión): https://maci.pse.dev/docs/introduction

**No verificadas en esta sesión** (de conocimiento previo; confirmar antes de citar
en una SPEC):

- Caso CFTC contra Ooki DAO (responsabilidad de miembros de una DAO sin persona jurídica).
- Registros de transparencia con árboles de Merkle: Certificate Transparency, RFC 9162 (https://www.rfc-editor.org/rfc/rfc9162) y Sigsum (https://www.sigsum.org).
- Baliza pública de aleatoriedad drand (https://drand.love).
- Algoritmo de "puenteo" de Notas de la Comunidad de X (https://communitynotes.x.com/guide/en/under-the-hood/ranking-notes).
- Ostrom, *Governing the Commons* (1990): reglas hechas por quienes las usan, sanciones graduales, resolución de conflictos local.
- Voto cuadrático en la legislatura de Colorado (2019) y riesgos de Sybil del voto cuadrático.
