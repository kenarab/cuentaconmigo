# Deliberación · network-governance · 03 · Legal y ciberseguridad (`electoral_counsel`)

Fecha: 31/10/2026. Revisión base: `a8feb7f`. Autor del texto: Claude (sesión delegada,
rol `electoral_counsel`); **sin revisión independiente**. Es una posición para deliberar,
no un chequeo de una SPEC ni una decisión.

> No es asesoramiento legal ni de seguridad profesional. Los ⛔ y las preguntas abiertas
> van, a través del autor, a un/a abogado/a electoral y a un/a profesional de seguridad.
> Neutralidad: ningún hallazgo depende de qué partido o sector se trate.

**Convención** (la de [MARCO_LEGAL](../../../../docs/legal/MARCO_LEGAL.md)):
**(a)** ley leída en fuente oficial hoy; **(a-p)** fuente oficial, sólo extracto;
**(b)** fuente secundaria; **(c)** no verificado. **[I]** = interpretación propia.

Pedido del autor: red sin control centralizado ("DAO o algo del estilo"), niveles
numerosos y dinámicos, tipos de interacción que mejoran el nivel, y evaluaciones
colegiadas de las formas de interactuar con plataformas corporativas.

## 1. Encuadre jurídico de una DAO en Argentina

### 1.1 La DAO no existe como sujeto de derecho

- El derecho argentino no reconoce a la "DAO" como figura. **[I]** Para un juez o la
  AAIP habrá personas que operan servidores, publican la app y deciden finalidades.
  "Descentralizar" la decisión no descentraliza la responsabilidad.
- **Responsable de la base de datos** = "titular de un archivo, registro, base o banco
  de datos" (Ley 25.326, art. 2) **(a-p)**. Sin persona jurídica, el responsable
  probable es quien opera la infraestructura: hoy, el autor. **[I]**
- **Encargado** (art. 25): quien trata datos por cuenta de terceros no puede usarlos
  "con un fin distinto al que figure en el contrato de servicios" y debe destruirlos al
  terminar **(a-p)**. Sirve para hosting, partidos (ver TC-11) y proveedores, no para
  diluir al responsable.
- **Inscripción** (art. 21): el texto exige inscribir bancos públicos y privados
  "destinados a proporcionar informes" **(a-p)**. La práctica de la AAIP es pedir la
  inscripción de bases privadas en general **(b)**. Con una base que trata conducta
  cívica de personas, conviene inscribirla aunque se discuta la obligación. **[I]**
- **Sanciones** (art. 31): apercibimiento, multa, suspensión, clausura **(a-p)**; la
  responsabilidad civil y penal (CP art. 157 bis, acceso ilegítimo a datos **(c)**) recae
  en personas si no hay entidad.
- **Hábeas data** (CN art. 43) **(a)**: alguien identificable tiene que poder recibir y
  contestar pedidos en 5 días hábiles (art. 16) **(a-p)**. Una DAO sin persona no puede.

### 1.2 Riesgo de responsabilidad personal de participantes

- **Simple asociación** (CCyC arts. 187-192): si la "DAO" actúa como grupo con fin
  común sin inscribirse, puede encuadrarse así; doctrina sostiene responsabilidad
  solidaria de fundadores y administradores por los actos de la entidad **(b)** (texto
  exacto del art. 191 **(c)**). En EE.UU. se aplicó la misma lógica: *CFTC v. Ooki DAO*
  (2023) trató a quienes votaban como miembros de una asociación no constituida **(b)**.
- Consecuencia **[I]**: si quienes alcanzan niveles altos "deciden" acciones externas
  (cartas, publicaciones de dictámenes) sin entidad que las asuma, ellos son los
  demandables por daños o difamación (CCyC art. 1737 y ss. **(c)**; CP 109-110 **(a-p)**).
  Es exactamente el SLAPP de [participant-protection](../../participant-protection/SPEC.md).

### 1.3 Envoltorio legal ("wrapper")

| Figura | Qué resuelve | Límite |
| --- | --- | --- |
| **Asociación civil** (CCyC arts. 168-186; constitución por instrumento público, art. 169 **(b)**; inscripción IGJ o registro provincial) | Persona jurídica responsable de la base y de los actos externos; asamblea de asociados puede adoptar reglas de decisión de la red por estatuto; sin fin de lucro, sin vínculo partidario (V-4, Acordada CNE 128/11 **(c)**) | La comisión directiva sigue siendo responsable legal: la "DAO" decide dentro del estatuto, la comisión ejecuta y puede vetar lo ilícito. Trámite: semanas a meses **(b)** |
| **Fundación** (CCyC arts. 193-224 **(c)**) | Patrimonio afectado, consejo estable, menos riesgo de captura por asamblea | Menos participativa; el consejo no lo elige la red salvo diseño estatutario |
| **Alianza con una OSC existente** que "aloje" el proyecto | Rápido; legitimidad (participant-protection, escudo institucional) | Dependencia de terceros; contacto lo decide el autor |
| **Wrapper extranjero**: Wyoming DAO LLC (W.S. 17-31-101 a 116, desde 2021 **(b)**; exige identificador público de smart contracts, art. 17-31-106) ; Utah DAO Act (2024) **(c)**; Islas Marshall DAO LLC (2022) **(c)**; Suiza, *Verein*/fundación **(b)** | Limita responsabilidad de miembros en su jurisdicción | **No recomendable [I]**: no protege frente a jueces argentinos por daños locales; transferencia internacional (art. 12 Ley 25.326 **(a-p)**); entidad extranjera actuando en elecciones argentinas es un pretexto de deslegitimación ("injerencia extranjera") |

**Modelo propuesto [I]:** "gobernanza descentralizada dentro de una persona jurídica":
la asociación civil es responsable legal y de datos; su estatuto delega en la red las
decisiones (consensos, niveles, moderación) con un **veto acotado** de la comisión
directiva sólo por ilicitud, fundado y público. Es lo que hacen, salvando distancias,
las cooperativas y muchas DAO con wrapper.

### 1.4 ¿Blockchain pública?

| Problema | Base | Severidad |
| --- | --- | --- |
| Supresión y rectificación en 5 días hábiles imposibles en un ledger inmutable | Ley 25.326 art. 16 **(a-p)** | ⛔ si hay datos personales on-chain |
| Una clave pública o seudónimo es dato personal si es **determinable** (cruce con grafo, IP, horarios) | Art. 2 **(a-p)**; EDPB, Guidelines 02/2025 sobre blockchain **(b)** | ⛔ |
| Votos y respaldos en deliberación cívico-política = opiniones políticas; un registro público y permanente que los asocia a cuentas es "archivo que revela datos sensibles" | Art. 7 inc. 3 **(a-p)**, verificado en el chequeo de trust-chain | ⛔ |
| Nodos en cualquier país = transferencia internacional sin control | Art. 12 **(a-p)** | ⚠️ alto |
| Coerción y compra de votos: un voto verificable públicamente permite probar a un tercero cómo votaste | **[I]**, principio del voto secreto aplicado por analogía | ⚠️ alto |

**Alternativa compatible:** registro **append-only verificable sin datos personales**
(log de transparencia con árbol de Merkle, al estilo Certificate Transparency):
se publican hashes de reglas, versiones de propuestas, resultados agregados y
decisiones de moderación; los votos individuales quedan fuera, cifrados y con
retención limitada. Se puede anclar un hash diario en una cadena pública sin datos.
*Crypto-shredding* (borrar la clave para "suprimir") es mitigación parcial, no
equivale con certeza a supresión **(b)**.

## 2. Tokens y criptoactivos

| Si la "reputación"… | Riesgo | Base |
| --- | --- | --- |
| Es transferible o negociable | Es "activo virtual"; quien la emite, custodia o intercambia puede ser PSAV: registro CNV obligatorio, sujeto obligado UIF (KYC = **identificar a todos**, contradice el diseño sin datos) | Ley 27.739 (B.O. 15/03/2024) incorpora art. 4 bis y art. 20 inc. 13 a Ley 25.246 **(b)**; CNV RG 994/2024 y RG 1058/2025 **(b)**; UIF Res. 49/2024 **(b)** |
| Promete valor o rendimiento | Posible valor negociable / oferta pública | Ley 26.831 **(c)**; **[I]** |
| Tiene valor económico y la usan partidos o candidatos | Puede ser **aporte** a campaña: prohibiciones de aportes (anónimos, de ciertas entidades, etc.) y obligación de registrar | Ley 26.215 art. 15 (sustituido por Ley 27.504) **(b)**; texto vigente **(c)** |
| Se compra con dinero o favores | Compra de influencia; asimilable socialmente a compra de votos; daño de legitimidad grave | **[I]** |
| Se calcula sobre opiniones o afinidad | Dato sensible; perfilamiento político | Ley 25.326 arts. 2 y 7 **(a-p)** |

**Recomendación:** reputación **sin valor económico, intransferible, no canjeable, no
acumulable sin límite, con decaimiento temporal, fuera de cualquier blockchain**, y
nunca llamada "token" ni "créditos". Que lo diga el reglamento de la red y los términos
de uso. Calculada sólo por conducta verificable (no por contenido de opiniones).
Para niveles dinámicos, el art. 20 de la Ley 25.326 (valoraciones basadas sólo en
tratamiento automatizado) rige para actos judiciales y administrativos **(a-p)**; por
analogía **[I]**: toda baja de nivel explicada, revisable por personas y apelable.

## 3. Modelo de amenazas de la gobernanza descentralizada

Activos: reglas de consenso, niveles, votos, resultados, claves de emergencia, canal
de publicación de dictámenes, legitimidad pública. Referencias: OWASP API Top 10
(2023), MASVS v2, NIST SP 800-63-4 **(b)**; todo lo de esta tabla es **propuesta**.

| # | Amenaza | Ejemplo | Control propuesto |
| --- | --- | --- | --- |
| G1 | **Captura por grupo coordinado o partido** | Militancia organizada entra por ramas propias y suma niveles en bloque | Peso por **diversidad de ramas** (no por cantidad); consenso transversal obligatorio (RC-2); techo de influencia por rama; cuentas institucionales de partidos fuera de la jerarquía (TC-7/TC-11) |
| G2 | **Sybil** | Granja de cuentas que "madura" niveles lentamente | Niveles con costo en tiempo y en verificaciones de terceros independientes; SybilRank como señal, no veredicto; ver S4 del chequeo de trust-chain |
| G3 | **Compra o alquiler de reputación** | Pagar a personas de nivel alto para votar o invitar | Intransferible; voto con verificación de usuario en el dispositivo; detección de correlación de votos; sanción a la rama (TC-3) |
| G4 | **Ataques a votaciones** | Inundación de propuestas, votación relámpago de madrugada, *bribery* con voto verificable | Ventanas mínimas de deliberación; quórum mínimo; voto secreto cifrado con recuento verificable; enfriamiento antes de ejecutar; propuestas limitadas por nivel |
| G5 | **Gobernanza que se reescribe a sí misma** | Mayoría coyuntural cambia los umbrales y luego aprueba lo que quiera | Reglas constitucionales que requieren supermayoría + plazo largo + chequeo legal; la neutralidad y el "consenso antes que acción" son **no modificables** por voto |
| G6 | **Claves de emergencia** | Robo o abuso del "botón de pausa" | Multifirma k de n con custodios de distinto origen, llaves físicas, alcance limitado a **pausar** (nunca ejecutar ni borrar), expiración automática y reporte público en 24 h |
| G7 | **Captura de cuentas de nivel alto** | Phishing a moderadores | Passkeys/llave física (AAL3-like), co-firma para acciones sensibles, mandatos con plazo y rotación |
| G8 | **Día de la elección y veda** | Votación para lanzar una acción sobre un hecho viral durante la veda; DDoS | **Congelar** ejecución de acciones externas desde 48 h antes hasta 3 h después del cierre (Código Electoral art. 71 incs. e y h **(a)**, vía MARCO_LEGAL); congelar cambios de nivel y de reglas; modo sólo lectura de gobernanza; capacidad offline de captura |
| G9 | **Infiltración para deslegitimar** | Cuenta aprueba un dictamen difamatorio para que la red "quede pegada" | Chequeo legal obligatorio previo; responsable jurídico que firma; retractación y rectificación rápidas |
| G10 | **Metadatos de votos** | Inferir afinidad por patrones de voto | Votos no vinculados a cuentas en lo publicado; agregados con umbral mínimo de k personas |
| G11 | **Fork hostil** | Alguien replica código y datos públicos y se presenta como "la red" | Marca registrada por la entidad **(c)**; firmas de la entidad en publicaciones oficiales |

### 3.1 Ajuste por `fed6c7e` (dos redes y cuentas de rol de partido, TC-11/13/14)

- **La gobernanza descentralizada abarca sólo la red de confianza.** La red de
  publicación de actas queda fuera: sus reglas (validación por coincidencia y contra el
  escrutinio oficial) se fijan antes de la campaña por la entidad responsable y **no
  se votan** durante el período electoral. Reduce G1, G4 y G8: capturar la gobernanza
  no altera capturas ni cotejos. **[I]** ✅
- **Desconexión real, no nominal (TC-13):** claves, identificadores, bases, logs de IP
  y operadores separados; sin hash de dispositivo compartido entre redes (ver A7 del
  chequeo de trust-chain). Si una sola persona administra ambas bases, la separación
  es organizativa débil. Si luego se suman capturas a la reputación, sólo con
  credencial anónima (TC-8). ⚠️
- **Cuentas de rol de partido:** mejora el art. 7 respecto del rótulo personal
  (L1 pasa a ⚠️ bajo **[I]**): el servidor sabe "dispositivo habilitado por un rol del
  partido X", no la persona. Persiste un riesgo indirecto: quien cruce esa marca con el
  teléfono incautado infiere afiliación. Mitigar: la marca de partido sólo en el
  dispositivo y en el registro de la habilitación con retención corta.
- **Responsabilidad:** el partido es persona jurídica (Ley 23.298 **(c)**) y responde por
  lo que publican sus cuentas de rol; conviene que lo acepte en los términos de uso
  iguales para todos. Las cuentas de rol **no votan** en consensos ni suman niveles
  (consistente con G1).
- **TC-14 (traspaso):** preferir delegación con vencimiento firmada por el rol superior
  (★) frente a traspaso de clave: la clave compartida borra la trazabilidad y no se
  puede revocar a una sola persona. Registro de delegaciones dentro del partido, no en
  la red. Congelar delegaciones nuevas el día de la elección salvo reemplazos de mesa.

## 4. Evaluaciones colegiadas de acciones frente a plataformas

Requisitos legales y de seguridad (cada uno debería ser criterio de aceptación):

1. **No usar denuncias como estrategia** (AGENTS.md; criterio 1 de
   [platform-accountability](../../platform-accountability/SPEC.md)). La evaluación
   rechaza de plano formas que consistan en reportes masivos coordinados, *mass
   flagging* o pedidos de bajada de contenido de personas. **[I]** Además del principio,
   un reporte masivo coordinado puede violar términos de servicio y exponer a quienes
   participan.
2. **Objeto: conductas de plataformas, no de personas.** El dictamen evalúa
   publicidad, algoritmos, cumplimiento de compromisos; no nombra usuarios particulares.
3. **Difamación**: CP arts. 109-110 (Ley 26.551) excluyen expresiones de interés público
   o no asertivas **(a-p)**; la responsabilidad civil subsiste **(b)**. Lenguaje de
   hallazgo ("observamos X en N casos, metodología Y"), no de imputación; derecho a
   réplica previo de la plataforma con plazo; evidencia con hash y cadena de custodia.
4. **Composición del colegio**: sorteo entre personas de nivel suficiente y de ramas
   distintas, más rol legal; declaración de conflictos de interés (empleo en
   plataformas, cargos partidarios); recusación. **[I]**
5. **Publicidad de dictámenes**: se publica el dictamen, la evidencia agregada, la
   metodología y el resultado de la votación; **no** quién votó qué (dato sensible,
   art. 7) ni las deliberaciones con datos de terceros. Disidencias publicadas sin
   identificar, salvo que la persona elija firmarla.
6. **Firma y ejecución**: toda acción externa la firma la persona jurídica, con
   chequeo de `electoral_counsel` y decisión del autor (AGENTS.md); un ⛔ la frena.
7. **Veda y jornada**: no se publican dictámenes ni se ejecutan acciones en la
   ventana de G8; los dictámenes sobre publicidad durante la veda se publican después.
8. **Neutralidad verificable**: la misma métrica para contenido de cualquier fuerza;
   auditoría de muestra por `neutrality_auditor`.
9. **Seguridad del proceso**: evidencia inmutable, voto del colegio cifrado con
   recuento verificable, registro de auditoría, sin canales privados no registrados.
10. **Datos de terceros** en capturas: difuminar, minimizar, retención fijada.

## 5. Recomendación (alternativas de menor a mayor riesgo)

| # | Alternativa | Riesgo legal | Riesgo seguridad | Comentario |
| --- | --- | --- | --- | --- |
| 1 ★ | **Asociación civil (o OSC aliada) + gobernanza por reputación off-chain** con niveles dinámicos, log de transparencia sin datos personales, veto acotado por ilicitud, claves de pausa multifirma | Bajo | Medio | Descentraliza la decisión, centraliza sólo la responsabilidad legal |
| 2 | Igual, con **federación** (instancias operadas por varias OSC, PP-2) | Medio-bajo (varios responsables, contratos art. 25) | Medio | Más resistente al apagado; más coordinación |
| 3 | Gobernanza con **anclaje en blockchain pública de hashes** (sin votos ni datos) | Medio | Medio | Aporta verificabilidad pública; cuidar metadatos |
| 4 | **Votos o reputación on-chain** con seudónimos | Alto ⛔ | Alto | Arts. 7, 12, 16 |
| 5 | **DAO con token transferible**, sin persona jurídica o con wrapper extranjero | Muy alto ⛔ | Alto | PSAV/UIF, Ley 26.215, responsabilidad personal, deslegitimación |

**⛔ (propuesto)**: alternativas 4 y 5 bloquean integración hasta decisión del autor
con dictamen profesional. El resto, ⚠️ con mitigaciones.

### Viable para la hackatón

- Diseño y simulación: reglas de niveles dinámicos, tipos de interacción y su peso,
  con **datos ficticios**; simular G1-G4 (captura por rama, Sybil lento, compra).
- Prototipo navegable (review-pipeline) de: propuesta → deliberación → colegio
  sorteado → dictamen con réplica → consenso → chequeo legal → ejecución congelada en veda.
- Log de transparencia simple (hashes encadenados) de reglas y resultados, sin personas.
- **Fuera de la hackatón:** constitución de la entidad (decisión y trámite del autor),
  inscripción AAIP, credenciales anónimas (TC-8), voto secreto criptográfico real,
  cualquier blockchain o token.

## 6. Preguntas para abogado/a

1. ¿Puede un estatuto de asociación civil delegar decisiones en una votación de
   personas usuarias no asociadas, y con qué responsabilidad de la comisión directiva?
2. ¿Riesgo de que una red de participantes sin inscripción se trate como simple
   asociación (CCyC 187-192) antes de constituir la entidad?
3. ¿Obligación de inscripción (art. 21) para esta base, y con qué finalidad declarada?
4. ¿Encuadre de una "reputación" no transferible como no-activo virtual (Ley 25.246
   art. 4 bis)?
5. ¿Los dictámenes colegiados publicados por la entidad sobre plataformas quedan
   cubiertos por el art. 110 CP (interés público) y qué estándar civil aplica?

## 7. No verificado

Texto exacto de CCyC arts. 169, 187-192, 193-224 y 1737; Ley 26.215 art. 15 vigente;
Ley 26.831 aplicable; Utah DAO Act e Islas Marshall; EDPB 02/2025 versión final;
CP art. 157 bis; Acordada CNE 128/11 completa; *CFTC v. Ooki DAO*.

## Fuentes (acceso 31/10/2026)

- Ley 25.326, Infoleg: <https://servicios.infoleg.gob.ar/infolegInternet/anexos/60000-64999/64790/texact.htm>
- Ley 26.215 (actualización): <https://www.argentina.gob.ar/normativa/nacional/124231/actualizacion>
- Ley 27.739 y PSAV: <https://abogados.com.ar/index.php/nueva-normativa-sobre-lavado-de-activos-creacion-del-registro-de-proveedores-de-servicios-de-activos-virtuales/34488>
- CNV RG 994/2024 y 1058/2025: <https://bruchoufunes.com/nuevas-resoluciones-de-uif-y-cnv-sobre-proveedores-de-servicios-de-activos-virtuales-psav/>, <https://abogados.com.ar/resolucion-general-cnv-n1058-regulacion-de-proveedores-de-servicios-de-activos-virtuales-psav/36529>
- UIF Res. 49/2024: <https://www.argentina.gob.ar/normativa/nacional/norma-397597/texto>
- CCyC simples asociaciones (doctrina): <https://codigocivilonline.com.ar/articulo-191/>
- Wyoming DAO Supplement: <https://law.justia.com/codes/wyoming/2022/title-17/chapter-31/article-1/section-17-31-104/>, <https://sos.wyo.gov/Business/Docs/DAOs_FAQs.pdf>
- Código Electoral y CP 109-110: ver [MARCO_LEGAL](../../../../docs/legal/MARCO_LEGAL.md) §2 y §4.
