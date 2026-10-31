# Chequeo electoral_counsel (legal, datos personales y ciberseguridad) · trust-chain-identity

## 31/10/2026

> No es asesoramiento legal ni de seguridad profesional. Los ⛔ y las preguntas abiertas
> se derivan, a través del autor, a un/a abogado/a electoral y a un/a profesional de
> seguridad. Neutralidad: ningún hallazgo depende de qué partido se trate.

### 1. Alcance

- Revisión: `5b76a7b` (HEAD al iniciar; durante el chequeo entró `1dd5c8f`, que sólo
  agrega `sdd/specs/app-architecture/SPEC.md`, sin cambios en esta SPEC).
- Archivos: `sdd/specs/trust-chain-identity/SPEC.md` (completo), `participant-protection`,
  `civic-network` (RC-3, RC-5), `scrutiny-backend` §3.5, `fiscal-planning`,
  `docs/legal/MARCO_LEGAL.md`.
- Fuentes primarias consultadas hoy (31/10/2026):
  - Ley 25.326, texto actualizado Infoleg:
    <https://servicios.infoleg.gob.ar/infolegInternet/anexos/60000-64999/64790/texact.htm>
    (arts. 2, 5 inc. 2, 7, 9, 12, 20, 21: **verificado**, lectura por extracto).
  - Código Electoral Nacional, texto actualizado Infoleg:
    <https://servicios.infoleg.gob.ar/infolegInternet/anexos/15000-19999/19442/texact.htm>
    (art. 56: **verificado**).
- Estado de la reforma de la Ley 25.326: sigue vigente; hay proyecto 3397-D-2026
  (ingresado 16/07/2026, reproduce el proyecto PEN 2023) según fuentes secundarias
  ([Diario Judicial](https://www.diariojudicial.com/news-99786-datos-personales-libro-y-debate-en-agenda),
  [abogados.com.ar](https://abogados.com.ar/nuevo-proyecto-de-ley-de-proteccion-de-datos-personales/39762)).
  Trámite parlamentario **a verificar**.

### 2. Modelo de amenazas (resumen)

| Elemento | Detalle |
| --- | --- |
| **Activos** | Grafo `invitó → invitada` con fechas; claves privadas en dispositivos; clave de firma del QR institucional de cada partido; datos de responsables de partidos; niveles y cupos; registro de investigaciones; cuentas nivel 3 (alta masiva, moderación). |
| **Actores** | Atacante Sybil (granjas de cuentas, infiltración desde una rama); partido o grupo que intenta capturar la red; persona coaccionada (empleador, puntero, pareja); actor estatal o privado que busca identificar participantes (pedido judicial, incautación, filtración); moderador o referente comprometido o corrupto; atacante de disponibilidad el día de la elección. |
| **Superficie** | Flujo de alta por QR (emisión, relay, replay, captura de pantalla); endpoint de alta y de recuperación social; API de cupos/niveles; tablero de investigación y moderación; almacenamiento del grafo y logs técnicos (IP); QR institucional de partidos; app (MASVS: almacenamiento de claves, integridad de la app). |

### 3. Hallazgos legales y de datos personales

| # | Sev. | Hallazgo | Base (ley verificada / interpretación) |
| --- | --- | --- | --- |
| L1 | ⛔ | **Rótulo "fiscal de [partido]" en cuentas del servidor (TC-7).** Crea en una base de un tercero no partidario un registro que vincula cuentas (seudónimas pero **determinables**: el partido que emitió el QR conoce a su fiscal) con una **opinión política**. | **Verificado:** Ley 25.326 art. 2 (dato personal incluye personas "determinables"; datos sensibles incluyen "opiniones políticas"); art. 7 inc. 3: prohibida la formación de archivos que revelen datos sensibles "directa o indirectamente", salvo registros de miembros que lleven las propias organizaciones políticas; art. 7 inc. 2: tratamiento sólo por "razones de interés general autorizadas por ley" o fines estadísticos sin identificación. **Interpretación:** el consentimiento del fiscal podría no bastar por la letra del art. 7 inc. 2 (la doctrina discute si el art. 5 lo suple: **a verificar**). CuentaConmigo no es organización política. |
| L2 | ⛔ (sólo para uso con personas reales) | **Grafo de invitaciones como dato sensible por inferencia.** En una red cuyo fin es cívico-político, "quién invitó a quién" revela redes de afinidad; junto a un nodo conocido re-identifica a sus vecinos. La SPEC no fija base legal, finalidad, retención ni custodia de claves (TC-5 abierto), y contradice el criterio 2 de participant-protection ("ante una incautación total no se puede identificar a participantes"). | **Verificado:** art. 2 (determinable), art. 4 (finalidad y minimización: MARCO_LEGAL, verificado), art. 9 (seguridad), art. 21 (inscripción de bases privadas "destinadas a proporcionar informes": aplicabilidad **a verificar**). **Interpretación:** pertenecer a una red no partidaria no es en sí "opinión política", pero el grafo combinado con contenidos y consensos puede revelarla indirectamente (art. 7 inc. 3). El bloqueo no frena la SPEC ni un prototipo con datos ficticios: frena el alta de personas reales hasta decidir TC-5 y su base legal. |
| L3 | ⚠️ | **Responsables de partidos identificados.** Tratamiento con consentimiento, fuera de Git y acceso restringido es correcto. Apoderados y autoridades partidarias son roles públicos ante la justicia electoral, pero sus datos siguen siendo personales. | **Verificado:** art. 5 (consentimiento), art. 9. **A verificar:** si la CNE publica un registro consultable de apoderados/autoridades que permita la verificación de TC-6 sin pedir DNI; texto de la Ley 23.298 sobre apoderados (no leído hoy). |
| L4 | ⚠️ | **"Responsabilidad hacia arriba" y cuarentena de ramas.** Sancionar a quien invitó y congelar ramas por conducta de terceros es una medida de un privado sobre su propia red (no un acto administrativo), pero puede verse como castigo por asociación y afectar derechos de participación si la red se vuelve relevante. | **Verificado:** art. 20 Ley 25.326 rige decisiones judiciales o actos administrativos, **no** a privados. **Interpretación:** aun así conviene revisión humana, motivación y apelación (la SPEC ya prevé apelación). |
| L5 | ⚠️ | **Equidad entre partidos.** Correcto en diseño (mismas funciones, sin acceso al grafo). Riesgo: partidos grandes con muchos fiscales "inundan" capturas; la neutralidad de reglas no garantiza neutralidad de efectos. | CN art. 38 (verificado en MARCO_LEGAL); principio del proyecto (AGENTS.md). |
| L6 | ⚠️ | **Pedidos judiciales y de autoridades sobre el grafo.** El grafo es exactamente lo que un persecutor pediría. | participant-protection (protocolo pendiente). Régimen de requerimientos y secreto: **a verificar** con abogado/a. |
| L7 | ✅ | Alta sin nombre, DNI, teléfono, mail ni ubicación; niveles sólo por conducta; partidos sin acceso al grafo; consenso sin voto extra por ser partido. | Arts. 4 y 7 Ley 25.326 (minimización). |

### 4. Hallazgos de ciberseguridad

Referencias: NIST SP 800-63-4 (suite publicada en 2025 según fuentes secundarias; versión
y numeración de controles **a verificar** en csrc.nist.gov), OWASP MASVS v2, OWASP API
Security Top 10 (2023), OWASP ASVS 4.0.3/5.0. Todo lo de esta sección es **propuesta**,
salvo donde se indica que la SPEC ya lo prevé.

| # | Sev. | Riesgo | Control concreto propuesto |
| --- | --- | --- | --- |
| S1 | ⚠️ alto | **Relay del QR:** "en persona" no se verifica. Una foto del QR enviada por mensajería en sus 2 minutos permite altas remotas; un atacante en la cola de un evento puede escanear el QR de otra persona. | Handshake de dos vías: el invitado muestra a su vez un QR con su clave pública y un nonce; el dispositivo del invitante **firma la vinculación** (`inviter_sig(invitee_pubkey, nonce, ts)`). El token del QR queda ligado a una sola clave. Opcional: prueba de proximidad (NFC/BLE). Rotular "a distancia" si se admite (TC-1). |
| S2 | ⚠️ | Replay, alteración y vencimiento del QR. | Ya previsto (un uso, firma, 2 min, vectores en criterio 2). Agregar: nonce registrado en servidor antes del canje, verificación de reloj con tolerancia acotada, invalidación al primer intento. |
| S3 | ⚠️ alto | **Compromiso de una cuenta nivel 3** (20 invitaciones/mes o por evento, moderación): puerta para un ataque Sybil masivo o para abusar de la moderación. | Nivel 3 con autenticador AAL3-like (clave no exportable + verificación de usuario; idealmente llave física), alta masiva sólo en ventanas declaradas y con co-firma de otro referente, tope absoluto por evento, enfriamiento (las cuentas de un evento quedan nivel 0 sin cupo por un plazo), alertas de volumen. participant-protection principio 10 ya pide 2FA para moderación. |
| S4 | ⚠️ alto | **Sybil y colusión:** SybilRank y similares fallan cuando los atacantes consiguen muchas aristas hacia nodos honestos (infiltración lenta, compra de invitaciones, coerción). El criterio 3 (50 cuentas de una sola rama) es el caso fácil. | Ampliar criterio 3 con ataques de "muchas ramas, pocas cuentas por rama", compra de invitaciones e infiltración lenta. Las capturas de cuentas nuevas nunca cuentan solas (ya previsto: nivel 0 requiere segunda verificación). Limitar el peso de cualquier rama en agregados y consensos. |
| S5 | ⚠️ alto | **Recuperación social como vector de secuestro:** el invitante + otra persona nivel 2 pueden apropiarse de una cuenta. | Período de espera (p. ej. 72 h), aviso al dispositivo viejo con opción de anular, quórum con al menos una persona fuera de la rama del invitante, registro auditado. Fuera de la jornada electoral, o con espera más larga ese día. |
| S6 | ⚠️ alto | **Robo o coerción del dispositivo:** la clave en Secure Enclave/Keystore es fuerte, pero el teléfono desbloqueado la usa. | Exigir verificación de usuario (biometría/código) para firmar acciones sensibles (invitar, verificar, respaldar), clave marcada no exportable y sin respaldo en la nube (MASVS-STORAGE, MASVS-AUTH), revocación rápida desde otra persona de confianza, "modo coacción" a evaluar. |
| S7 | ⚠️ alto | **Grafo y metadatos:** aun cifrado, el servidor necesita el grafo para calcular cupos y Sybil; los logs de IP, horas de alta y tamaño de ramas permiten re-identificar. | Ver alternativas de L2. Separar el grafo de cualquier dato técnico; no guardar IP asociada a la cuenta; redondear fechas de aristas; claves de descifrado para investigación repartidas (umbral k de n entre moderación elegida, TC-4) y acceso con registro encadenado. |
| S8 | ⚠️ | **QR institucional de partidos:** la clave de firma del partido es un activo de alto valor (su robo crea "fiscales de [partido]" falsos). | Clave institucional rotada por elección, en HSM o llave física; cupo de fiscales por mesa (Código Electoral art. 56: uno por partido por mesa, más fiscales generales de sección, **verificado**); revocación. |
| S9 | ⚠️ | **Abuso de API de alta/recuperación** (API4:2023 consumo sin límite; API2:2023 autenticación rota; API1:2023 BOLA en endpoints de rama/cuenta). | Límites de tasa por clave e IP, prueba de trabajo liviana en alta, autorización por objeto en toda consulta de grafo/rama, nunca exponer ids de aristas. |
| S10 | ⚠️ | **Disponibilidad el día de la elección:** alta y recuperación no deberían ser necesarias ese día. | Congelar altas masivas y recuperaciones durante la jornada; la app opera offline con su clave; la cola de capturas no depende del servicio de identidad en línea. |
| S11 | ✅ | Claves generadas en el dispositivo, sin datos de contacto, separación partido/ciudadano, cuarentena antes que expulsión, auditoría y apelación. | Alineado con NIST 800-63B (autenticador criptográfico ligado al dispositivo) e IAL "sin prueba de identidad" por diseño. |

### 5. Alternativas (ordenadas de menor a mayor riesgo)

**L1 · Rótulo de fiscales de partido (TC-7)**
1. **Rótulo genérico "fiscal partidario" sin nombre del partido en el servidor** (el
   partido conoce a sus fiscales en su propio sistema; CuentaConmigo no). Costo: los
   partidos no pueden filtrar "sus" capturas en la red. Riesgo: bajo.
2. **Rótulo sólo en el dispositivo** del fiscal y en el sistema propio del partido;
   el servidor sólo sabe "cuenta institucional delegada" con un id opaco por partido
   rotado por elección. Costo: más complejidad. Riesgo: bajo-medio (el id opaco sigue
   siendo indirectamente sensible si se filtra el mapeo).
3. Rótulo con partido, con consentimiento expreso y dictamen legal favorable sobre el
   art. 7 inc. 2-3. Costo: dictamen. Riesgo: alto hasta tener el dictamen.

**L2 · Grafo de invitaciones (TC-5)**
1. **Grafo minimizado:** guardar sólo lo necesario para cupos (contadores por cuenta) y,
   para la investigación, aristas cifradas con claves repartidas (k de n) entre la
   moderación elegida, retención corta (p. ej. borrado o agregación 90 días después de
   la elección), sin IP asociada. Costo: investigación más lenta. Riesgo: medio-bajo.
2. **Sólo en dispositivos** (cada cuenta guarda su invitante firmado; la cadena se
   reconstruye cuando se investiga, con colaboración). Costo: investigar es difícil,
   Sybil por grafo casi imposible. Riesgo: bajo legal, alto de integridad.
3. En claro con control de acceso. Costo: mínimo. Riesgo: alto (incautación/filtración
   expone toda la red).

**S1 · Relay del QR:** (1) handshake de dos vías ligado a la clave (recomendado);
(2) QR + código corto leído en voz alta; (3) dejar como está y rotular el riesgo.

**S3 · Nivel 3:** (1) co-firma + llave física + enfriamiento; (2) sólo tope por evento;
(3) sin cambios.

**S5 · Recuperación:** (1) espera + aviso + quórum fuera de rama; (2) espera sola;
(3) sin cambios.

### 6. Recomendaciones accionables

1. Decidir TC-7 con la alternativa 1 de L1 antes de cualquier alta real de fiscales.
2. Completar TC-5 con: finalidad, base legal, retención, custodia de claves, quién
   puede pedir acceso y cómo se registra; sumar el grafo al inventario de datos de
   participant-protection (criterio 1).
3. Agregar a la SPEC el handshake de dos vías (S1) y los controles de nivel 3 (S3) y de
   recuperación (S5) como criterios de aceptación con vectores.
4. Ampliar el criterio 3 con escenarios de ataque realistas (S4) y medir falsos
   positivos por rama, no sólo globales.
5. Protocolo de respuesta a pedidos de datos sobre el grafo (L6) antes del lanzamiento.
6. Congelar alta masiva y recuperación durante la jornada electoral (S10).
7. TC-8 (credenciales anónimas): mantener "después de la hackatón", pero diseñar el
   formato de cuenta para no impedirlo.

### 7. Riesgos transversales detectados en otras SPECs

- **civic-network RC-3 / RC-5 y civic-deliberation DL-3:** la identidad de esta SPEC es
  la base de respaldos y consensos; un ataque Sybil exitoso no sólo contamina capturas,
  también fabrica "consensos" que habilitan acciones externas. Los umbrales RC-2 deberían
  ponderar por diversidad de ramas, no sólo por cantidad.
- **civic-network, veda:** cuentas institucionales de partidos publicando en la red
  durante la veda (Código Electoral art. 71 inc. e, 48 h previas, según MARCO_LEGAL,
  verificado allí) requiere regla explícita (pausa de publicaciones institucionales).
- **platform-accountability A3 (donación de datos):** datos de terceros y de quien dona;
  pendiente de su propio chequeo, fuera de este alcance.
- **scrutiny-backend §3.5:** usa códigos de inscripción; debe converger con esta SPEC sin
  heredar el rótulo partidario (ver su chequeo).

### 8. No verificado

- Si el consentimiento suple la exigencia del art. 7 inc. 2 Ley 25.326 (doctrina).
- Aplicabilidad del art. 21 (inscripción) a una base privada que no "proporciona informes".
- Registro público de apoderados/autoridades partidarias consultable (TC-6); Ley 23.298.
- Numeración exacta de controles de NIST SP 800-63-4 y su fecha oficial de publicación.
- Trámite del proyecto 3397-D-2026.

### Veredicto

**⛔** acotado: L1 (rótulo partidario en servidor) y L2 (grafo con personas reales sin
TC-5 resuelto). Ambos bloquean la implementación con datos reales, no la discusión de la
SPEC ni un prototipo con datos ficticios. El resto, ⚠️ con mitigaciones.

## 31/10/2026 · Addendum: secciones nuevas de la SPEC

Revisado sobre el árbol de trabajo (cambio aún sin commit al momento del chequeo,
`HEAD` = `1dd5c8f`): "Privacidad del grafo: marco y propuesta", "Varios usuarios por
teléfono", "Reputación y foros internos" y TC-9 a TC-12. Fuente adicional verificada hoy:
Ley 25.326 arts. 10 y 25 (Infoleg, enlace arriba).

### Grafos separados de partidos (TC-11) frente al art. 7 inc. 3

| # | Sev. | Hallazgo | Base |
| --- | --- | --- | --- |
| A1 | ⚠️ (baja L1 de ⛔ a ⚠️ **si** se elige TC-11 ★ con las condiciones de abajo) | Con grafos separados, sin aristas cruzadas y con el partido como **responsable** y la red como **encargada por cuenta del partido**, el registro partidario se apoya en la excepción del art. 7 inc. 3 (registro de miembros que lleva la organización política) en lugar de crearlo la red. Es la mejor alternativa disponible. | **Verificado:** art. 7 inc. 3; art. 25 (quien presta servicios por cuenta de terceros no puede usar los datos con otro fin ni cederlos, y debe destruirlos al terminar, con conservación de hasta 2 años sólo con autorización expresa); art. 10 (secreto). **Interpretación / a verificar:** (a) la excepción habla de "miembros"; un fiscal **no afiliado** podría no encuadrar; (b) la red debe ser realmente encargada: contrato por partido, finalidad cerrada, sin uso de esos datos para la red ciudadana. |
| A2 | ⚠️ | Condiciones para sostener A1: base y claves **separadas por partido** (no sólo una columna); contrato de encargo idéntico para todos los partidos (neutralidad); destrucción al cierre de la elección (art. 25); prohibido cruzar con el grafo ciudadano incluso en investigaciones; la vista pública muestra "fiscal partidario" sin partido salvo decisión del propio partido y del fiscal. | Arts. 9, 10, 25. |
| A3 | ⚠️ | El quórum de apertura (TC-12) no debe aplicarse al grafo de partidos por custodios ciudadanos: son datos del partido (responsable). Definir quién abre aristas partidarias (el propio partido, con registro). | Art. 25 (encargo). |

### Apertura por quórum (TC-12)

| # | Sev. | Hallazgo | Control propuesto |
| --- | --- | --- | --- |
| A4 | ✅ / ⚠️ | Cifrado de aristas con umbral k de n y custodios de distinto origen es coherente con L2 (alternativa 1) y con participant-protection. Con esto, L2 sigue ⛔ **sólo** hasta que TC-5/TC-12 queden decididos con retención fija e inventario. | Usar un esquema de umbral auditado (no implementación propia); claves de custodios en llaves físicas; ceremonia de generación registrada; prueba de restauración; rotación tras cada elección. |
| A5 | ⚠️ alto | **Contradicción técnica:** la detección Sybil por ranking de grafo (sección "Detección") necesita leer la estructura; si las aristas sólo se abren por quórum, el ranking no puede correr de forma continua. | Elegir y documentar: (a) correr el ranking sobre un grafo con ids rotados y sin fechas finas, dentro de un proceso aislado, aceptando ese riesgo residual; (b) señales locales sin grafo (contadores por rama opacos, volumen, divergencia de capturas) y abrir por quórum sólo ante alerta; (c) ranking periódico en una ceremonia con quórum. Orden por riesgo legal: b < c < a. |
| A6 | ⚠️ | Un pedido judicial puede exigir a los custodios abrir aristas; el quórum no impide una orden válida. | Informarlo en el protocolo de pedidos (L6); el art. 10 permite relevar el secreto por resolución judicial (verificado). |

### Perfiles no vinculables por dispositivo (TC-9)

| # | Sev. | Hallazgo | Control propuesto |
| --- | --- | --- | --- |
| A7 | ⚠️ | "Hash con sal por función" no es anónimo si la entrada es un identificador estable del dispositivo y el servidor guarda las sales: quien tenga el servidor y el teléfono recalcula ambos hashes y vincula perfil ciudadano y fiscal (justo lo que la sección quiere evitar, art. 7 inc. 3). | Derivar el valor en el teléfono con un secreto que nunca sale del dispositivo (p. ej. `HMAC(secreto_local, función)`), no con un id del fabricante; el servidor sólo cuenta. Mejor aún: límite de perfiles verificado localmente + atestación sin id. |
| A8 | ⚠️ | Coerción en teléfonos compartidos: otra persona del hogar ve o usa perfiles ajenos. | Cada perfil con su propio desbloqueo (biometría/código) para firmar; nada del perfil visible desde otro perfil. MASVS-STORAGE/AUTH. |
| A9 | ⚠️ | App Attest / Play Integrity: envían señales a Apple/Google y pueden excluir teléfonos viejos o con ROM libres. | Sólo como señal de riesgo, nunca requisito; documentar en el inventario de datos (art. 12 si hay transferencia: a verificar). |

### Reputación y foros internos (TC-10)

| # | Sev. | Hallazgo | Recomendación |
| --- | --- | --- | --- |
| A10 | ✅ | No usar "créditos sociales": correcto. | — |
| A11 | ⚠️ | Foros cerrados de nivel ≥ 2: riesgo de captura coordinada y de que contenidos con opiniones políticas queden asociados a cuentas y ramas (dato sensible indirecto). | Retención limitada de foros; sin exportar membresías; que ninguna acción externa salga de un foro sin fase pública (ya previsto); auditoría de diversidad de ramas en quienes abren foros. |

### Veredicto actualizado

- L1 (rótulo partidario): **⚠️** si se adopta TC-11 ★ con A2 (contrato de encargo,
  bases separadas, destrucción); sigue **⛔** si se elige "rótulo partidario dentro del
  grafo ciudadano".
- L2 (grafo con personas reales): **⛔** hasta decidir TC-5 y TC-12 y resolver A5.
- SPEC en conjunto: **⛔ acotado** (L2), con camino claro para levantarlo.

Preguntas nuevas para abogado/a: ¿la excepción del art. 7 inc. 3 cubre a fiscales no
afiliados que el partido designa? ¿Un esquema de encargo (art. 25) con todos los
partidos compromete la condición no partidaria de la red frente a la Acordada CNE
128/11?
