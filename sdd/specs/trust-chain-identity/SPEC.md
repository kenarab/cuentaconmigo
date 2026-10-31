# SPEC · Identidad sin datos personales: cadenas de confianza por QR

Estado: **propuesta del autor (31/10/2026) redactada para su revisión; decisiones TC-n
pendientes; chequeo de `electoral_counsel` (legal y ciberseguridad) pendiente.**
Responde a RC-5 de [civic-network](../civic-network/SPEC.md) y PP-3 de
[participant-protection](../participant-protection/SPEC.md), y precisa RC-3 (partidos).
Afecta la autenticación de [scrutiny-backend](../scrutiny-backend/SPEC.md) y
[fiscal-planning](../fiscal-planning/SPEC.md).

## Idea del autor

- La gente entra **sin dar información personal**: alguien que ya está adentro la
  invita en persona con un **QR**. No conocemos identidades, pero sí quién invitó a quién.
- Si aparece un agente malicioso, se investiga **la subred que lo invitó**.
- Hay una **jerarquía**: las personas más comprometidas y activas pueden invitar a más
  gente que otras.
- Los **partidos políticos** sí se registran con **responsables identificados** y
  tienen características especiales.

## Cuentas de personas

1. **Alta por QR, en persona.** La app de quien invita genera un QR de un solo uso,
   firmado con la clave de su dispositivo y de vida corta (por ejemplo, 2 minutos).
   La persona invitada lo escanea, su teléfono genera su propio par de claves y elige
   un seudónimo. El servidor guarda la clave pública, el seudónimo y la arista
   `invitó → invitada` con la fecha. **No guarda** nombre, DNI, teléfono, mail ni ubicación.
2. **Sesión:** el dispositivo firma cada pedido con su clave (guardada en el Secure
   Enclave o Keystore). Es la misma base que el `deviceToken` de scrutiny-backend.
3. **Recuperación** (pérdida del teléfono): recuperación social. Quien la invitó y
   otra persona de nivel suficiente confirman en persona una clave nueva. La cuenta
   vieja queda revocada.

## Niveles y cupos de invitación

Los niveles dependen de la **conducta en la red**, nunca del partido, la ideología o el
contenido de las opiniones. Los valores son propuestas para calibrar (TC-2).

| Nivel | Cómo se llega | Puede | Cupo de invitaciones |
| --- | --- | --- | --- |
| 0 · Nueva | Por invitación | Leer, deliberar, cargar capturas (requieren segunda verificación) | 0 |
| 1 · Activa | 14 días y aportes confirmados por otras personas (por ejemplo, 3 capturas coincidentes o 5 aportes valorados) | Lo anterior y respaldar propuestas | 2 por mes |
| 2 · Comprometida | 60 días en nivel 1, aportes sostenidos y ninguna sanción | Lo anterior, verificar capturas de otros y recuperar cuentas | 5 por mes |
| 3 · Referente | Elegida por pares de nivel 2 o más, con mandato renovable | Lo anterior, organizar eventos de alta masiva con cupo especial, moderar | 20 por mes o por evento |

- El cupo se **renueva** con el tiempo. Lo no usado no se acumula sin límite.
- **Responsabilidad hacia arriba:** si alguien invitado resulta malicioso, quien
  invitó pierde cupo temporalmente y su nivel queda en revisión. Así se cuida a
  quién se invita, sin castigar por adelantado.

## Detección e investigación de agentes maliciosos

- **Señales:** capturas que divergen de forma sistemática de las de otras personas en
  la misma mesa; volumen anómalo; muchas cuentas nuevas de una misma rama que actúan
  coordinadas; reportes de pares.
- **Análisis del grafo:** los atacantes suelen crear muchas cuentas falsas que se
  conectan poco con la red honesta (ataque Sybil). Los métodos de ranking por grafo
  de confianza aprovechan ese patrón. Se aplican a la estructura de invitaciones, no
  al contenido.
- **Contención proporcional, no expulsión masiva:**
  1. Cuarentena de la cuenta señalada: sus aportes dejan de contar para consensos y
     agregados.
  2. Se congelan los cupos de su rama (quien la invitó y quienes invitó).
  3. Se investiga la subred con registro de auditoría. Las personas afectadas pueden
     apelar.
  4. Sólo con evidencia: revocación de las cuentas involucradas y recálculo de lo
     que hayan aportado. Lo extraído y lo confirmado se recalculan por separado.
- Ninguna medida se basa en opiniones políticas expresadas.

## Principio: la app no registra personas (precisión del autor, 31/10/2026)

- **Por defecto, nadie queda registrado como persona.** La cuenta es una clave y un
  seudónimo, sin datos que identifiquen a nadie.
- **Perfil público, sólo por elección:** quien quiera visibilidad pública puede
  activar un perfil con su nombre, su foto o los vínculos a sus cuentas en otras redes.
- **Riesgo a evaluar en profundidad:** un perfil público identificado **expone a su
  subred**. Quien la invitó y quienes invitó quedan a un paso de una persona conocida.
  Si las aristas se filtran o se infieren por conducta, se pueden reidentificar.
  También expone su historial seudónimo previo, si se lo vincula.
- **Alternativas a ponderar (TC-15):**
  1. **Perfil público como persona separada** ★: una clave nueva, sin aristas ni
     historial vinculados a la cuenta de confianza. La reputación se puede mostrar sólo
     con una credencial anónima ("nivel ≥ N"), sin revelar la cuenta.
  2. Perfil público vinculado a la cuenta, pero con las aristas ocultas y un aviso
     explícito del riesgo para su subred.
  3. Sin perfiles públicos en esta etapa.
- **Vincular cuentas de otras redes** (X, Instagram, TikTok…) agrega otro riesgo:
  esas plataformas pueden cruzar los datos. Requiere una verificación que no publique
  el vínculo entre la cuenta externa y la cuenta de confianza.
- Pendiente: evaluación de `electoral_counsel` (legal y seguridad) y de trust & safety
  antes de decidir.

## Dos redes desconectadas (precisión del autor, 31/10/2026)

- **Red de confianza:** identidad seudónima, invitaciones, reputación, deliberación
  y gobernanza. Es la que describen las secciones anteriores.
- **Red de publicación de actas:** alta de dispositivos para capturar telegramas y
  actas, envío, cotejo y avisos ([scrutiny-backend](../scrutiny-backend/SPEC.md),
  [fiscal-planning](../fiscal-planning/SPEC.md)).
- **Pueden estar desconectadas entre sí.** Un dispositivo de captura no necesita una
  cuenta de la red de confianza, y desde una red no se puede saber quién es quién en
  la otra: claves, identificadores y bases separados. La calidad de una captura se
  valida por coincidencia con otras capturas y con el escrutinio oficial, no por la
  reputación de quien la sube.
- Si más adelante se quisiera que las capturas confirmadas sumen reputación, se haría
  con una credencial anónima ("aporté N capturas coincidentes") que no vincule las
  cuentas (TC-8, TC-13).

## Partidos políticos

**Subredes de partidos con reglas especiales** (precisión del autor, 31/10/2026):

- **No identifican personas. Identifican roles clave en forma genérica**, por ejemplo
  "apoderado/a nacional", "coordinación de fiscales de la sección X" o "fiscal
  general del circuito Y". Cada rol es una **cuenta de rol** con su propia clave.
  Distintas personas pueden ocuparlo a lo largo del tiempo (traspaso de clave o
  delegación con vencimiento), y quién lo ocupa en cada momento queda **dentro del
  partido**.
- Los fiscales de mesa se dan de alta en la **red de publicación de actas** con el QR
  institucional de una cuenta de rol. Sin rótulo personal: el servidor sabe que el
  dispositivo fue habilitado por un rol de un partido, no quién es la persona.
- **Registro institucional del partido:** la cuenta raíz del partido se verifica una
  vez contra el registro de la justicia electoral (a verificar con
  `electoral_counsel`). Los datos de quien hace ese trámite se tratan con su
  consentimiento, fuera de Git, con acceso restringido y sin quedar asociados a las
  cuentas de rol.
- **Mismas características para todos los partidos** (neutralidad):
  - cuenta institucional rotulada como tal, separada de las cuentas de personas;
  - publicación de posiciones oficiales en los espacios de deliberación, con las
    mismas reglas y límites;
  - **alta de sus fiscales** en la red de publicación de actas, con el QR de una
    cuenta de rol. Quedan fuera de la red de confianza: no suman cupos ni niveles
    ciudadanos, para que un partido no pueda capturar la red;
  - asignación de mesas a sus fiscales (se integra con
    [fiscal-planning](../fiscal-planning/SPEC.md));
  - la misma vista de capturas y cotejos que cualquier persona. Sin acceso a la
    identidad ni al grafo de las personas.
- Las acciones de la red siguen requiriendo consenso. Un partido no tiene más votos
  por ser partido.

## Datos personales y riesgos

- **El grafo de invitaciones es sensible.** En un contexto político puede revelar redes
  de afinidad. Las opiniones políticas son datos sensibles (Ley 25.326, art. 2 y 7, a
  verificar). Propuesta: guardar las aristas cifradas, con acceso sólo para
  investigaciones registradas y con retención limitada (TC-5).
- Nada del grafo se publica. Las estadísticas públicas son agregadas.
- Riesgo de **coerción** (alguien obligado a invitar o a entregar su teléfono): cupos
  bajos, revocación rápida y recuperación social.
- Riesgo de **exclusión**: quien no conoce a nadie adentro no puede entrar. Se mitiga
  con eventos de alta masiva de referentes y de organizaciones aliadas (PP-3).

## Privacidad del grafo: marco y propuesta (investigación del 31/10/2026)

**Marco legal (a verificar con `electoral_counsel` y un abogado o abogada):**

- La Ley 25.326 define las opiniones políticas como dato sensible (art. 2). Nadie
  está obligado a darlas, y está **prohibido formar archivos que las revelen directa
  o indirectamente** (art. 7 inc. 3).
- Los partidos políticos sí pueden llevar un registro de sus miembros (art. 7). La
  doctrina trata la afiliación como dato sensible, y la jurisprudencia sobre su
  publicidad no es uniforme.
- Un seudónimo no alcanza para que un dato deje de ser personal si se lo puede
  reidentificar (por ejemplo, cruzando el grafo con el dispositivo).

**Consecuencia de diseño:** el grafo de una red ciudadana y no partidaria no debería
revelar afinidades. El riesgo aparece al **mezclarlo con nodos de partidos** o con
las posiciones expresadas en la deliberación. Buenas prácticas aplicables:
minimización, separación de funciones, cifrado con acceso por quórum, retención
limitada, estadísticas sólo agregadas y credenciales que prueban un atributo sin
revelar quién es la persona.

**Propuesta:**

1. **Dos grafos separados.**
   - **Ciudadano:** sin rótulos partidarios.
   - **Por partido:** sus responsables y fiscales identificados como tales. Cada
     partido es responsable de sus datos (excepción del art. 7) y la red los procesa
     por cuenta del partido. **No hay aristas entre los dos grafos.** Una invitación
     de partido nunca otorga nivel ciudadano.
2. **Aristas cifradas con apertura por quórum.** El servidor guarda cada arista
   `invitó → invitada` cifrada. Para abrirla hace falta un quórum (por ejemplo, 3 de
   5) de custodios de la moderación elegida (RC-4), cada uno de un origen distinto.
   Toda apertura queda registrada y se informa en forma agregada. Para los cupos
   alcanza con contadores: no hace falta leer el grafo.
3. **Comprobante en el teléfono.** Cada dispositivo guarda el comprobante firmado de
   su propia invitación, y puede probar su rama si lo investigan.
4. **Retención:** las aristas se borran pasado un plazo después de la elección
   (TC-5). Las estadísticas públicas son agregadas, con ruido si los grupos son chicos.
5. **Más adelante: credenciales anónimas** (TC-8). La persona prueba "tengo nivel ≥ 2"
   o "soy una persona verificada" sin revelar su cuenta. Hay borradores de estándar
   de la IETF que combinan Privacy Pass con firmas BBS.
6. **Referencia:** BrightID usa un grafo social con seeds de confianza y una variante
   de SybilRank, sin datos personales. Su propia revisión académica reconoce límites
   frente a ataques combinados. Conviene medirlo con simulaciones (criterio 3) antes
   de confiar en él.

## Varios usuarios por teléfono

En hogares que comparten teléfono, limitar a una persona por dispositivo excluye a
gente. Permitir muchas cuentas facilita las granjas de cuentas falsas. Propuesta para
ponderar (TC-9):

- **Por defecto, una cuenta ciudadana por dispositivo.** Con la marca "teléfono
  compartido" se admiten **hasta 3 perfiles**, cada uno con su clave y su propia
  invitación en persona de alguien **distinto**. El cupo de invitaciones del
  dispositivo se comparte.
- El servidor no guarda el identificador del dispositivo. Guarda un hash con sal
  **por función**, que permite contar perfiles sin vincular un perfil ciudadano con
  uno de fiscal de partido.
- Una persona puede ser ciudadana y fiscal de un partido en el mismo teléfono, pero
  en **perfiles no vinculables**, para que su perfil ciudadano no revele su afiliación.
- La atestación del dispositivo (App Attest / Play Integrity) ayuda contra
  emuladores. No es infalible y no debe usarse como identificador.

## Reputación y foros internos

- **Nombre:** se propone **no** llamarlo "créditos sociales", por la asociación con
  sistemas de puntaje ciudadano de control estatal. Se propone "reputación de
  participación" o "cupos" (TC-10).
- Además de invitar, la reputación habilita **foros internos de trabajo**. Las
  personas de nivel 2 o más pueden abrir grupos donde se gestan propuestas antes de
  pasar a la deliberación pública
  ([civic-deliberation](../civic-deliberation/SPEC.md)). Toda propuesta que pida
  acción pasa por la fase pública y el consenso de toda la red.
- **Riesgos:** que se forme una élite, que la red se vuelva opaca, o que un grupo
  coordinado la capture. Mitigaciones:
  - los foros se pueden leer desde el nivel 1;
  - criterios de reputación públicos y calculados sólo con la conducta;
  - mandatos con plazo para referentes;
  - límite de foros por persona;
  - la reputación no se transfiere ni se compra.

## Decisiones pendientes

| ID | Decisión | Opciones |
| --- | --- | --- |
| TC-1 | Método de alta | QR en persona ★ · QR también a distancia (link) con cupo menor · ambos con rótulo distinto |
| TC-2 | Niveles y cupos | Tabla de arriba como punto de partida ★ · menos niveles (0/1/2) · cupos fijos sin niveles |
| TC-3 | Responsabilidad hacia arriba | Pérdida temporal de cupo ★ · sin consecuencias · degradación de nivel |
| TC-4 | Quién investiga una subred | Equipo de moderación elegido (RC-4) ★ · operador de la red · comité mixto con partidos |
| TC-5 | Almacenamiento del grafo | Cifrado con acceso registrado y retención limitada ★ · en claro con control de acceso · sólo en los dispositivos (dificulta investigar) |
| TC-6 | Partidos: verificación de responsables | Contra el registro de la justicia electoral ★ · declaración jurada · ambos |
| TC-7 | Fiscales de partido en la jerarquía | Fuera de la jerarquía ciudadana ★ · dentro, con nivel 0 · elección del fiscal |
| TC-8 | Credenciales anónimas (prueba de que alguien es una persona sin vincularla a su cuenta) | Después de la hackatón ★ · ahora |
| TC-9 | Usuarios por teléfono | 1 por defecto, hasta 3 con "teléfono compartido" ★ · siempre 1 · sin límite con atestación |
| TC-10 | Nombre y alcance de la reputación | "Reputación de participación", habilita invitaciones y foros ★ · sólo cupos de invitación · otro nombre |
| TC-11 | Grafos de partidos | Subredes con cuentas de rol genéricas, separadas del grafo ciudadano y sin aristas cruzadas ★ (precisión del autor) · rótulo partidario dentro del grafo ciudadano |
| TC-13 | Relación entre la red de confianza y la de publicación de actas | Desconectadas ★ (precisión del autor) · vinculadas con credencial anónima · vinculadas por cuenta |
| TC-15 | Perfiles públicos identificados | Persona pública separada, sin vínculo con la cuenta de confianza ★ · vinculado con aristas ocultas y aviso · sin perfiles públicos por ahora |
| TC-14 | Traspaso de cuentas de rol de partido | Delegación con vencimiento firmada por el rol superior ★ · traspaso de clave · una cuenta por persona dentro del rol |
| TC-12 | Apertura de aristas | Quórum de custodios de distinto origen ★ · operador de la red con registro · nunca (sólo comprobantes en el teléfono) |

## Criterios de aceptación

1. Un alta por QR completa en menos de 1 minuto entre dos teléfonos, sin pedir ningún
   dato personal.
2. Un QR usado, vencido o con la firma alterada se rechaza (vectores de contrato).
3. Con una rama simulada de 50 cuentas falsas invitadas desde una sola cuenta, el
   análisis del grafo las marca y la contención las deja fuera de los agregados sin
   afectar a más del 1 % de las cuentas honestas (a medir en simulación).
4. Los cupos y niveles se calculan sólo con señales de conducta: lo verifica una
   revisión de neutralidad.
5. Los partidos tienen exactamente las mismas funciones entre sí.

## Chequeo de electoral_counsel (legal y ciberseguridad): pendiente

A evaluar: datos sensibles y grafo social (Ley 25.326); verificación y datos de los
responsables de partidos; rótulo de fiscales de partido; modelo de amenazas (Sybil,
robo de dispositivo, coerción, abuso de cupos, compromiso de una cuenta de nivel 3,
ataque al servidor el día de la elección); controles de NIST SP 800-63 y OWASP MASVS
que apliquen.
