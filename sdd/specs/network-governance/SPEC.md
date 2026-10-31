# SPEC · Gobernanza descentralizada de la red de confianza

Estado: **propuesta (síntesis de la deliberación del 31/10/2026); decisiones NG-1 a NG-20
pendientes del autor.** Chequeo de `electoral_counsel`: **parcial**, vía la posición
[03-legal-security](deliberation/03-legal-security.md) (sin revisión independiente); el chequeo
formal de esta SPEC está pendiente. Nada de lo que sigue es decisión: el autor decide.

Pedido del autor: "convertir la red en una DAO o algo del estilo, sin control centralizado; bastantes
niveles y dinámicos; diseñar los tipos de interacciones y qué mejora el nivel; evaluaciones
colegiadas de las formas de interactuar con las plataformas corporativas". Posiciones sintetizadas:
[01 DAO](deliberation/01-dao-governance.md), [02 democracia deliberativa](deliberation/02-deliberative-democracy.md),
[03 legal y ciberseguridad](deliberation/03-legal-security.md), [04 trust & safety y neutralidad](deliberation/04-trust-safety-neutrality.md).
Marcas: **[NV]** = fuente no verificada en la posición de origen; **[I]** = interpretación.

## Alcance y relación con otras SPECs

- Resuelve **RC-2 y RC-4** de [civic-network](../civic-network/SPEC.md) y precisa **RC-3**; **DL-2** de
  [civic-deliberation](../civic-deliberation/SPEC.md); **TC-2, TC-3, TC-10, TC-15** de
  [trust-chain-identity](../trust-chain-identity/SPEC.md); gobierna la activación de **A5** de
  [platform-accountability](../platform-accountability/SPEC.md); depende de **V-4** ([visión](../vision/SPEC.md))
  y PP-2 ([participant-protection](../participant-protection/SPEC.md)).
- **Rige sólo la red de confianza** (identidad seudónima, invitaciones, reputación, deliberación,
  gobernanza). La **red de publicación de actas** queda desconectada (TC-13 ★): sus reglas se fijan
  antes de la campaña, no se votan en período electoral y sus capturas se validan por coincidencia y
  escrutinio oficial, nunca por reputación (03 §3.1, 04 §0). Partidos: cuentas de rol genéricas (TC-11 ★, TC-14).
- **La app no registra personas** (TC-15, precisión del autor): la cuenta es una clave y un seudónimo;
  un perfil público identificado es opcional y expone a su subred. Esta SPEC no lo resuelve: lo trata
  como riesgo y decisión abierta (NG-20).
- Hereda el ⛔ acotado del [chequeo de trust-chain](../trust-chain-identity/checks/electoral_counsel.md)
  (L2: grafo con personas reales hasta decidir TC-5/TC-12 y resolver A5).

## 1. ¿DAO? Respuesta de la deliberación

### Consensos de las cuatro posiciones

1. **Principios DAO, no tecnología DAO:** reglas públicas y versionadas, decisiones registradas de
   forma verificable, demoras antes de ejecutar, poderes repartidos. **Sin token, sin blockchain
   pública, sin dinero en juego** (01 §1, 02 §1, 03 §1.4 y §2, 04 tesis 5): un token compra poder; un
   registro público inmutable choca con la Ley 25.326 (arts. 7, 12, 16).
2. **Registro append-only verificable sin datos personales** (árbol de Merkle, estilo Certificate
   Transparency [NV: RFC 9162, Sigsum]): hashes de reglas, versiones, resultados agregados y decisiones
   de moderación. Votos individuales fuera, cifrados, con retención limitada (01 opción B, 03 §1.4).
3. **Una persona jurídica responsable** (asociación civil u OSC aliada) de la base de datos, el hábeas
   data y los actos externos; la gobernanza decide dentro de su estatuto. "Descentralizar la decisión
   no descentraliza la responsabilidad" (03 §1; 01 [NV: *CFTC v. Ooki DAO*]; 02 §4; 04 §5).
4. **La reputación da tareas, no votos.** Una persona verificada = un voto (las cuatro).
5. **Descentralización progresiva** con fases, criterios medibles y fechas publicadas; hoy el control
   es del autor y conviene decirlo (01 §3, 02 §1, 03 §1.3). **Separación de poderes:** proponer,
   admitir, evaluar, decidir, ejecutar y controlar no recaen en la misma instancia (02 §1, 04 §3).
6. **Sorteo verificable + rúbrica pública** para evaluar modalidades frente a plataformas, con
   ratificación de la red, chequeo legal y decisión del autor (las cuatro). **Veda:** sin cambios de
   reglas ni acciones externas en período electoral (01, 03 G8, 04).

### Disensos explícitos y recomendación

| Tema | 01 | 02 | 03 | 04 | ★ síntesis |
| --- | --- | --- | --- | --- | --- |
| Algoritmo de puente / factor latente de perspectiva | No usar: inferir posturas es dato sensible; paneles ciegos | Sí, efímero y agregado por deliberación, con chequeo legal | Perfilamiento político = arts. 2 y 7 | Sí, efímero, sólo como restricción de diversidad; ⚠️ alto | NG-5: ahora sin puente; después sólo con dictamen legal favorable |
| Roles sensibles (moderación, nivel 3) | Cuidado ≥ z + elección | Elección o confirmación periódica con mandato | — | Sorteo entre elegibles con mandato; la elección premia bloques | Sorteo entre elegibles con mandato y confirmación (NG-10) |
| Tamaño del panel | 15 + 2 asesores | 15–25 | "nivel suficiente y ramas distintas" | 9–15 | 15 para modalidades nuevas, 9 para activaciones (NG-7) |
| Vida media del decaimiento | ~90 días | ~6 meses | — | ~90 días | 90 días con piso de dignidad; calibrar (NG-16) |
| Freno de emergencia | Consejo k de n (5 de 9), pausa ≤ 14 días | — | Multifirma k de n, sólo pausar, reporte en 24 h | Cualquier panel sorteado puede suspender por plazo corto | Consejo k de n y, además, pausa breve por panel en curso (NG-14) |
| Veto en la transición | Autor: total → sólo constitución → ninguno | Fundadores, temporal y publicado | Comisión directiva: sólo por ilicitud, fundado y público | — | Fase 0 autor; fase 1 entidad sólo por ilicitud; fase 2 sin veto individual (NG-8) |
| Anclaje de hashes en cadena pública | Opcional, sin datos | — | Riesgo medio (metadatos) | No hasta después de 2027 | Sitios de aliados y prensa ahora; cadena pública: NG-15 |
| Partidos y consenso transversal | k partidos apoyan o no objetan, m vetan | Apoyo desde grupos/ramas distintos | — | Partidos no votan ni integran paneles | Sin voto ni veto; objeción fundada obliga a respuesta registrada (§3, §5) |
| Escala de la rúbrica | 0–4, eliminatorios | 0–3, mínimos por criterio | Requisitos como criterios de aceptación | 0–3 | 0–3 con criterios eliminatorios (§4) |

## 2. Reputación y niveles dinámicos

Nombre: **reputación de participación** (TC-10 ★). Nunca "token", "créditos" ni "créditos sociales" (03 §2, 04 §1).

### Modelo unificado

- **Dimensiones:** **evidencia** (A1–A3), **verificación**, **deliberación**, **cuidado** (paneles,
  moderación, mentoría, auditoría de la red) y **confiabilidad** (ausencia de sanciones). Un nivel alto
  en una dimensión no da permisos en otra (01 §2, 04 §1).
- **Fórmula base, a calibrar en simulación:** `R_d(t) = Σ_períodos √(puntos del período) · e^(−(t − t_i)/τ)`
  por dimensión `d`, vida media ~90 días (NG-16). Rendimientos decrecientes (√) y topes contra el
  volumen; decaimiento contra las élites vitalicias y las cuentas dormidas.
- **Niveles visibles:** `nivel = floor(log2(1 + R_total))`, tope 12 (01; 04 propone 0–7). Son un resumen
  para la persona; **los permisos dependen de umbrales por dimensión**, publicados, versionados y
  modificables como cualquier regla (§3). La tabla 0–3 de TC-2 pasa a ser el resumen en cuatro bandas.
- **Piso de dignidad:** nadie baja de nivel 1 por inactividad si no tuvo sanciones. **No transferible,
  no comprable, no delegable, sin valor económico, no canjeable, fuera de cualquier blockchain** (03 §2);
  lo dicen el reglamento y los términos de uso. **Sin ranking público, insignias ni rachas** (NG-11):
  cada persona ve su puntaje, su desglose y "por qué subió o bajó", con apelación; lo público es la
  fórmula y los agregados.
- **Reputación y perfiles públicos (TC-15, NG-20):** por defecto la reputación es privada y seudónima.
  Si el autor habilita perfiles públicos identificados, el nivel sólo se exhibiría con una credencial
  anónima ("nivel ≥ N", TC-8) que no vincule la cuenta de confianza ni su subred. Vincular cuentas de
  otras redes al perfil queda fuera de la reputación.
- **Neutralidad:** ninguna señal mira el contenido de la opinión, el partido ni de qué lado argumentó
  alguien (criterio 4 de TC); se mide verificación cruzada, no popularidad. **Sanciones graduales y
  reversibles** (Ostrom [NV]): aviso → descuento temporal de la dimensión → cuarentena → revocación sólo
  con evidencia; toda baja con motivo legible y apelable ante un panel sorteado de otra dimensión y
  otras ramas (art. 20 por analogía [I], 03 §2).

### Regla central

**La reputación da tareas, no votos.** En los consensos vale una persona verificada, un voto. Respaldar
una iniciativa es un derecho, no un mérito: no suma reputación. Ponderar votos por reputación crea una
aristocracia de veteranos (01 §2, 02 §2, 04 tesis 2). Voto cuadrático, por convicción y democracia
líquida: postergados (NG-18).

### Catálogo unificado de interacciones (sólo red de confianza)

Puntos iniciales para calibrar. "Rama" = subárbol de invitación; su diversidad se mide con contadores o
identificadores de grupo gruesos y rotativos, sin abrir el grafo (A5-b).

| Interacción | Dimensión | Suma | Quién valida | Tope | Riesgo |
| --- | --- | --- | --- | --- | --- |
| Leer, seguir temas | — | 0 | — | — | — |
| Argumentar a favor o en contra con fuente | deliberación | +2 | Panel sorteado ciego (sin autoría): fuente, pertinencia, respeto; nunca la postura. Con NG-5 (b), puente | 10/mes | Medio: brigadas, tono |
| Enmienda incorporada a una versión consolidada | deliberación | +3 | Registro de versiones; aceptada por quien no es autor | 5/mes | Medio: sabotaje |
| Propuesta estructurada que llega a versión consolidada | deliberación | +5 | Umbral de apoyos verificados + admisión de neutralidad | 2/mes | Medio: spam, propuesta partidaria encubierta |
| Valorar "útil / no útil" | — (ajusta el peso del evaluador) | 0 | Concordancia posterior con verificación independiente | — | Alto: anillos, co-voto |
| Respaldar una iniciativa | — | 0 (derecho) | Persona verificada | — | Alto: Sybil, compra de apoyos |
| Cargar evidencia A1–A3 aceptada | evidencia | +2 | Hash + reproducción por otra persona de otra rama + re-chequeo automático | 15/mes | Alto: fabricación, falsos positivos |
| Hallazgo de A4 reproducido con la metodología pública | evidencia | +5 | Reproducción independiente + revisión de muestra | 3/mes | Medio |
| Verificar evidencia ajena (doble ciego) | verificación | +1 | Coincide con la mayoría de verificadores independientes; muestras de control | 40/mes | Alto: colusión |
| Chequeo de hechos con fuentes (eje B) | verificación | +2 | Fuentes enlazadas + panel sorteado de muestra | 10/mes | Alto: "chequeo" partidario |
| Servicio en panel sorteado (dictamen entregado) | cuidado | +4 | Firma del panel en el registro | Por sorteo | Bajo |
| Decisión de moderación confirmada en apelación o muestra | cuidado | +1 | Panel de apelación | 20/mes | Muy alto: captura (rol por sorteo) |
| Mentoría o capacitación confirmada | cuidado | +2 | Confirmación de quien la recibió, de otra rama | 5/mes | Medio: reciprocidad falsa |
| Invitada activa y sin sanciones a los 60 días | cuidado | +1 | Contadores (no abre el grafo) | Cupo TC-2 | Alto: granjas |
| Hallazgo de sesgo de la propia red confirmado | cuidado | +3 | Otras personas + `neutrality_auditor` | 3/mes | Bajo |
| Señalar abuso | — | 0 | Peso por calidad histórica y diversidad; nunca sanción automática | — | Alto: denuncias coordinadas |
| Invitar por QR | — | 0 | — | Cupo TC-2 | Alto: granjas |
| Capturar telegrama o acta | **fuera** (TC-13) | 0 | Red de actas | — | NG-13 |
| Evidencia probadamente falsa o manipulada | confiabilidad | −15 y cuarentena | Investigación registrada (TC-4) + apelación | — | — |
| Moderación revertida por abuso | confiabilidad | −3 | Panel de apelación | — | — |
| Invitada maliciosa confirmada | confiabilidad | −5 y cupo congelado | TC-3 | — | — |
| Valorar "útil" lo que después se prueba falso | — | baja el peso como evaluador | Verificación posterior [NV: *rater helpfulness*, Community Notes] | — | — |

**No suma nunca:** publicaciones, reacciones, seguidores, tiempo conectado, votos emitidos ni su
sentido, coincidir con la mayoría, apoyos de la propia rama o de un grupo coordinado.

### Permisos por umbral (ilustrativo, a calibrar)

| Permiso | Requisito |
| --- | --- |
| Leer, deliberar, cargar evidencia (con segunda verificación) | Alta por invitación |
| Respaldar (cuenta en consensos) | Persona verificada (DL-3) + 14 días. **Igual voto para todas** |
| Invitar | Confiabilidad sin sanciones + una dimensión ≥ u1; el cupo crece con el nivel, tope 20/mes (TC-2) |
| Verificar evidencia ajena | Verificación ≥ u2 o exactitud ≥ 90 % en muestras de control |
| Recuperar cuentas | Nivel ≥ u3 + controles S5 del chequeo de trust-chain |
| Abrir foros de trabajo | Dos dimensiones ≥ u3; límite de foros; legibles desde nivel 1 (A11) |
| Entrar al sorteo de paneles | Persona verificada + 30 días, sin sanciones vigentes. **Umbral bajo**: evita la élite |
| Moderar, apelar, custodiar claves | Sorteo entre elegibles (cuidado ≥ u4, 90 días sin sanciones), mandato 6 meses, sin reelección inmediata, confirmación periódica (NG-10) |
| Alta masiva en eventos | Rol con mandato + co-firma de otro referente + enfriamiento (S3) |

### Algoritmo de puente frente al dato sensible (NG-5)

El "puente" (un aporte vale si lo valoran útil personas que suelen discrepar) resiste brigadas de un
solo grupo (02 §1, 04 §1), pero el factor latente **infiere perspectiva política**: dato sensible
indirecto (art. 7 inc. 3). Opciones: **(a) no usarlo**: paneles sorteados ciegos y diversidad de rama
como única medida de transversalidad (01 §5), riesgo legal bajo; **(b) efímero y restringido**:
calculado sólo dentro de cada deliberación, no persistido por cuenta, no expuesto ni rotulado, usado
sólo como restricción de diversidad ("cubre / no cubre") y publicado agregado (02 §2, 04 §1), con
dictamen previo de `electoral_counsel` y `data_protection_officer`, riesgo medio; **(c) persistente por
cuenta**: ⛔ propuesto. ★ **(a) ahora** (hackatón y fase 0); **(b) sólo tras dictamen legal favorable**,
con auditoría de que no premia un polo.

## 3. Decisiones y cambio de reglas

| Capa | Contenido | Cómo se cambia | Timelock |
| --- | --- | --- | --- |
| **Constitución** | Neutralidad, consenso antes que acción, privacidad y minimización, no partidaria, sin amplificación paga, una persona un voto, derecho de salida (código abierto y datos exportables) | Supermayoría ≥ 2/3 en **dos votaciones** separadas por 30 días, quórum alto, dictamen de panel sorteado y de `electoral_counsel`. **Neutralidad y "consenso antes que acción" no se modifican por voto** (03 G5) | 30 días |
| **Reglas** | Umbrales de consenso, catálogo de interacciones, cupos, moderación, rúbrica | Mayoría calificada ≥ 60 % + quórum + chequeo de `electoral_counsel` | 7 días |
| **Parámetros** | Puntos, topes, τ, tamaños de panel | Panel técnico sorteado propone con simulación publicada; la red ratifica u objeta | 7 días |

- **Quórum adaptativo (NG-19):** porcentaje de las personas verificadas activas en los últimos 90
  días, con piso absoluto publicado. **Ningún cambio se aplica a decisiones en curso** (04 §3).
- **Veda de reglas (NG-9):** desde 60 días antes de cada elección hasta el escrutinio definitivo no se
  cambian reglas ni parámetros, salvo seguridad con reporte público. Además, **congelamiento
  operativo** desde 48 h antes hasta 3 h después del cierre (Código Electoral art. 71, vía
  MARCO_LEGAL): sin acciones externas, dictámenes, cambios de nivel, alta masiva ni recuperación de
  cuentas; gobernanza en sólo lectura (03 G8, S10).
- **Consejo de pausa (NG-14):** k de n custodios (propuesta 5 de 9) de orígenes distintos (sociedad
  civil, academia, periodismo, técnicos), sin vínculo partidario declarado, llaves físicas. **Puede
  pausar, nunca modificar ni ejecutar.** Pausa ≤ 14 días, justificación pública en 24 h, ratificación
  de la red, revisión de cada uso. El ⛔ de `electoral_counsel` funciona igual: frena, no decide.
  Complemento: un panel sorteado en curso puede suspender por sospecha de captura por un plazo corto
  (04 §3). Los custodios suelen ser personas públicas: sus cuentas de custodia no deben tener aristas
  en el grafo ciudadano (TC-15).
- **Consenso transversal mecánico (RC-2):** una iniciativa pasa a acción cuando reúne (i) un mínimo de
  personas verificadas y un porcentaje de acuerdo publicados antes; (ii) **diversidad de ramas**:
  ninguna rama aporta más de x % de los apoyos (S4 del chequeo de trust-chain); (iii) ninguna
  **objeción fundada sin respuesta registrada**, incluidas las de cuentas de partidos, que no votan ni
  vetan. No requiere clasificar partidos "por signo" (01 §3). Con NG-5 (b), se suma la cobertura de perspectivas.
- **Voto secreto con recuento verificable** (NG-17; 03 G4, G10): nada publicado vincula votos con
  cuentas; agregados con umbral mínimo de k personas.
- **Separación de poderes e incompatibilidades:** proponer / admitir / evaluar (panel) / decidir
  (consenso) / ejecutar (entidad y autor) / controlar (apelación, auditoría, `electoral_counsel`).
  Quien modera un caso no lo evalúa en apelación; quien propone no integra el panel.

### Descentralización progresiva (NG-8)

| Fase | Quién puede vetar | Criterios medibles para pasar a la siguiente |
| --- | --- | --- |
| **0 · Fundacional** (hoy) | El autor, en todo; declarado públicamente | Persona jurídica constituida (V-4); reglamento y constitución publicados; registro verificable operativo |
| **1 · Transición** | Comisión directiva de la entidad sólo por ilicitud, fundada y pública; el autor sólo sobre la constitución | N personas verificadas (a fijar); custodios activos de ≥ 4 orígenes; inscripción de la base (art. 21, si corresponde); auditoría externa del algoritmo; simulaciones adversariales publicadas |
| **2 · Autónoma** | Ningún veto individual; sólo consejo de pausa y ⛔ legal | Federación con ≥ 2 organizaciones operadoras (01 opción C, PP-2); después de las elecciones 2027 |

Una "DAO" que oculta un dueño es peor que un dueño declarado (01 §3).

## 4. Evaluaciones colegiadas de modalidades frente a plataformas

Objeto: decidir si una **modalidad** (carta abierta, pedido de acceso a la información, auditoría A2,
tablero A4, propuesta regulatoria, nuevas) se adopta, se ajusta o se descarta; luego, si cada
**activación** procede; después, si funcionó. La modalidad se evalúa una vez con panel completo; cada
activación, con panel reducido o vía rápida con plantilla aprobada, siempre con los pasos 9 a 12.

### Proceso

1. **Propuesta:** plantilla de civic-deliberation + ficha de acción: qué se pide, a quién, evidencia
   (A1–A4 con hash y metodología), **métrica de éxito y línea de base definidas antes**, plazo, reversión.
2. **Admisión formal** (moderación en pares, sin evaluar el fondo): completa; no partidaria; no consiste
   en reportes masivos ni pedidos de bajada de contenido de personas; no nombra usuarios particulares.
3. **Sorteo verificable:** lista de elegibles publicada como hash antes de la semilla; semilla pública
   posterior al compromiso (baliza de aleatoriedad [NV: drand] o número publicado después, p. ej.
   lotería oficial [NV]); algoritmo de sorteo justo (Flanigan et al., *Nature* 2021; herramienta libre
   [NV: Panelot]) con estratos **no políticos**: región gruesa, antigüedad, banda de reputación, máximo
   1–2 personas por rama, género si se declara voluntariamente. Nunca afinidad. Nadie repite panel en
   el trimestre. Tamaño: NG-7. Cualquiera puede repetir el sorteo.
4. **Conflictos de interés:** declaración privada de vínculo laboral o contractual con la plataforma
   evaluada, un partido o quien propuso; la persona se excusa sin decir por qué; recusación. No se
   pregunta afiliación.
5. **Expediente y descargo:** evidencia, métricas, argumentos a favor y en contra; **derecho de réplica
   previo** de la plataforma con plazo (03 §4.3); descargo escrito de cada partido que quiera, con
   idéntico formato y extensión; expertos y `electoral_counsel` con voz y sin voto.
6. **Deliberación** asincrónica de 1 a 2 semanas, materiales breves, sin canales privados no registrados.
7. **Puntaje individual y secreto por criterio**, con fundamento escrito, según la rúbrica.
8. **Dictamen público:** adoptar / adoptar con cambios / rechazar; puntajes agregados; **disidencias
   fundadas**, firmadas con seudónimo (firmar con nombre exige perfil público y asumir el riesgo para
   la subred, TC-15); fuentes; lenguaje de hallazgo ("observamos X en N casos con la metodología Y"),
   nunca de imputación; no se publica quién votó qué (art. 7).
9. **Ratificación de la red** por consenso transversal (§3); si contradice el dictamen, se registra el motivo.
10. **Chequeo de `electoral_counsel`**: un ⛔ frena hasta que decida el autor.
11. **Decisión del autor** mientras dure la fase 0; en fases 1–2, **firma de la persona jurídica** (03
    §4.6). Ejecución **fuera de la veda** (§3); los dictámenes sobre publicidad en veda se publican después.
12. **Medición posterior:** métricas de platform-accountability predefinidas (tiempo hasta acción
    visible, % sin etiqueta a 24/48/72 h, anuncios ausentes de la biblioteca, anuncios en veda), con
    línea de base y grupo de comparación; respuestas formales recibidas; cambios de política
    documentados. Sin línea de base no se afirma efecto. Un panel nuevo publica la revisión y ajusta la rúbrica.

### Rúbrica pública (0–3 por criterio, fundamento escrito)

| Criterio | Pregunta | Mínimo | Eliminatorio |
| --- | --- | --- | --- |
| Evidencia | ¿Capturas verificadas, independientes, con hash y cadena de custodia? ¿Separa lo extraído de lo confirmado? | 2 | Sí |
| Legalidad | ¿Hay ⛔ de `electoral_counsel`? ¿Respeta veda y Ley 25.326? | Sin ⛔ | Sí |
| **Prueba del espejo (simetría)** | ¿Se aplicaría igual si el contenido favoreciera a otra fuerza? Reescribir el caso invirtiendo actores y documentar casos simétricos | 3 | Sí |
| Sin denuncias ni silenciamiento | ¿Pide transparencia o cumplimiento, no borrar a personas? ¿No usa botones de denuncia ni reportes masivos? | 3 | Sí |
| Objeto | ¿Evalúa conductas de plataformas (publicidad, algoritmos, compromisos), no de personas? | 3 | Sí |
| Proporcionalidad | ¿Es la acción menos gravosa que alcanza el objetivo? | 2 | No |
| Reversibilidad | ¿Se puede retirar o corregir? ¿Tiene vencimiento? | 2 | No |
| Riesgo para participantes | Persecución, exposición, SLAPP (participant-protection) | 2 | No |
| Medibilidad | ¿Métrica, línea de base y plazo definidos antes? | 2 | No |
| Costo y capacidad | ¿Hay quien la ejecute y la mida? | 1 | No |

**Cómo se documenta sin denunciar:** observación pasiva y re-chequeo del estado público (A1), bibliotecas
de anuncios (A2), panel de exposición con consentimiento (A3), pedidos de información pública (Ley
27.275), derecho de acceso (Ley 25.326, P-4). Datos de terceros en capturas: difuminar, minimizar, retención fijada.

## 5. Partidos políticos

- **Cuentas de rol genéricas** en subredes separadas (TC-11 ★, TC-14 ★), sin identificar personas,
  fuera de la red de confianza; sus fiscales sólo en la red de actas (TC-7).
- **Sin voto** en consensos ni paneles; **sin veto**. Pueden argumentar, presentar descargos y objeciones
  fundadas con idéntico cupo y formato. Una objeción fundada obliga a una respuesta registrada, no frena sola.
- **Igualdad verificable:** tabla pública de permisos idéntica por partido y tipo de rol; tope idéntico
  de cuentas de rol por partido y nivel territorial; prueba automatizada que compare.
- **Sanciones a roles (NG-12):** recaen en el rol y en la cuenta raíz del partido, con escala idéntica y
  pública. El partido, persona jurídica, responde por lo que publican sus roles y lo acepta en términos
  de uso iguales para todos (03 §3.1). Delegaciones con vencimiento, congeladas el día de la elección
  salvo reemplazos.
- **Militancia en la red ciudadana:** legítima y no detectable por afiliación. Nunca vincular redes para
  "descubrir" militantes (art. 7 inc. 3). Defensa conductual: diversidad de rama, sincronía, revisión humana.
- **Veda:** pausa de publicaciones institucionales en la ventana de congelamiento (§3).

## 6. Fases

**Hackatón (datos ficticios; nada se instala sin aprobación del autor):** esta SPEC con las decisiones
NG-; borrador de constitución en tres capas; reglas de reputación en JSON versionado y **simulador**
(fórmula, catálogo, topes, decaimiento; escenarios adversariales G1–G4: captura por rama, Sybil lento,
compra, anillo de valoración); **registro append-only** simple (cadena de hashes en JSON firmada)
verificable con un script; **sorteo verificable** demostrativo y **dictamen de ejemplo** con la rúbrica
sobre una modalidad ficticia (carta abierta sobre anuncios en veda) con descargo simulado; prototipos
navegables (review-pipeline): propuesta → admisión → panel → dictamen → consenso → chequeo legal →
ejecución congelada en veda; pantalla "por qué subió o bajó mi nivel" con apelación; tabla de permisos por partido.

**Después:** constitución de la entidad (trámite del autor), inscripción de la base, testigos externos
del registro, federación, voto secreto criptográfico real, credenciales anónimas (TC-8), puente en
producción si se aprueba NG-5 (b), perfiles públicos sólo tras NG-20, calibración de umbrales con uso
real (lección de Decide Madrid, 02 §1), voto por convicción para el backlog (NG-18), auditoría externa
del algoritmo, evaluación de Decidim/CONSUL [NV].

## 7. Decisiones pendientes (unificadas)

| ID | Decisión | Origen | Opciones (★ recomendada) |
| --- | --- | --- | --- |
| NG-1 | Forma de la red | GV-1, GOV-1, NG-TS-4, 03 §5 | Off-chain verificable dentro de una persona jurídica, diseñada para federar ★ · DAO on-chain ⛔ · centralizada declarada |
| NG-2 | Persona jurídica responsable (precisa V-4) | 03 §1.3 | Asociación civil ★ · OSC aliada que aloje · fundación · wrapper extranjero (no recomendado) |
| NG-3 | Peso del voto | GV-3, GOV-2 | Una persona verificada, un voto ★ · ponderado por reputación |
| NG-4 | Estructura de la reputación | GV-2, GOV-3, NG-TS-2, TC-2 | Continua por dimensión con decaimiento y nivel visible 0–12 ★ · puntaje único con muchos niveles · tabla 0–3 |
| NG-5 | Algoritmo de puente / factor latente | GOV-5, NG-TS-1, 01 §5 | (a) no usar, ahora ★ · (b) efímero y restringido tras dictamen legal, después ★ · (c) persistente ⛔ |
| NG-6 | Quién evalúa modalidades | GV-4, GOV-4 | Panel sorteado + rúbrica + dictamen + ratificación ★ · comité fijo elegido · niveles altos · equipo |
| NG-7 | Tamaño de los paneles | 01, 02, 04 | 15 para modalidades, 9 para activaciones ★ · 15–25 · 9–15 |
| NG-8 | Descentralización progresiva | GV-5, GOV-6 | Tres fases con criterios y fechas publicados ★ · inmediata · sin plan |
| NG-9 | Veda de reglas y congelamiento | GV-6, 03 G8 | 60 días antes hasta escrutinio definitivo + congelamiento 48 h / 3 h ★ · otro plazo · sin veda |
| NG-10 | Roles sensibles (moderación, apelación, custodia) | NG-TS-3, TC-2, 02 | Sorteo entre elegibles con mandato de 6 meses y confirmación ★ · elección por pares · designación |
| NG-11 | Gamificación visible | NG-TS-5 | No: ni rankings ni insignias ni rachas ★ · insignias privadas · rankings |
| NG-12 | Sanción a cuentas de rol de partido | NG-TS-6 | Sobre el rol y la cuenta raíz, escala idéntica y pública ★ · sólo el rol · sin sanción |
| NG-13 | Capturas de actas como fuente de reputación | NG-TS-7, TC-13 | No en la hackatón; después sólo con credencial anónima ★ · vincular por cuenta ⛔ |
| NG-14 | Freno de emergencia | 01 §3, 03 G6, 04 §3 | Consejo 5 de 9 que sólo pausa + pausa breve por panel en curso ★ · sólo consejo · sólo paneles |
| NG-15 | Registro verificable y anclaje | 01 opción B, 03 §1.4 | Log Merkle + testigos externos, hash diario en sitios de aliados y prensa ★ · además en cadena pública (sin datos) · sólo servidor |
| NG-16 | Vida media del decaimiento | 01, 02, 04 | ~90 días con piso de dignidad, calibrada en simulación ★ · 6 meses · sin decaimiento |
| NG-17 | Voto secreto en consensos | 03 G4, G10 | Cifrado con recuento verificable y agregados de k personas ★ · voto público · a definir después |
| NG-18 | Mecanismos avanzados de voto | 01 §2 | Postergar; convicción sólo para el backlog en v2 ★ · cuadrático · líquida |
| NG-19 | Quórum | 01 §3 | Adaptativo (% de activas 90 días) con piso absoluto ★ · fijo |
| NG-20 | Perfiles públicos identificados y vínculo con otras redes en la gobernanza (TC-15) | Precisión del autor | **Sin resolver**; requiere evaluación de `electoral_counsel` y trust & safety. Opciones de TC-15: persona pública separada, sin aristas ni historial, nivel sólo por credencial anónima · vinculado con aristas ocultas y aviso explícito del riesgo para la subred · sin perfiles públicos por ahora. Para roles públicos (custodios, voceros): cuentas sin aristas en el grafo ciudadano |

## 8. Criterios de aceptación

1. Ninguna acción externa ocurre sin dictamen de panel sorteado, consenso registrado, chequeo de
   `electoral_counsel` y decisión del autor (fase 0) o firma de la entidad.
2. En toda votación cada persona verificada pesa exactamente 1: una prueba automatizada compara el
   resultado con y sin reputación y no encuentra diferencia.
3. El registro es append-only y verificable: un script independiente reproduce la raíz de Merkle y
   detecta la alteración de cualquier entrada.
4. El sorteo de un panel es reproducible por un tercero con la lista hasheada y la semilla; en 100
   sorteos simulados ninguna rama aporta más de 2 personas.
5. Simulación adversarial: una rama de 50 cuentas coordinadas y un anillo de valoración de 20 no mueven
   más de un nivel visible a ninguna cuenta ni superan el umbral transversal; menos del 1 % de cuentas
   honestas afectadas (extiende el criterio 3 de TC).
6. Ninguna señal de reputación usa contenido de opiniones, partido ni sentido del voto: revisión de
   `neutrality_auditor` sobre código y reglas.
7. Toda baja de nivel tiene motivo legible y apelación; tiempo medio de resolución y porcentaje
   revocado publicados agregados.
8. En veda y congelamiento ningún cambio de regla, nivel ni acción externa se ejecuta (reloj simulado);
   la tabla de permisos de los partidos es idéntica entre sí (prueba automatizada).
9. Nada público (dictámenes, agregados, perfiles) permite vincular una cuenta de confianza con una
    persona o con su subred sin su elección explícita (TC-15); revisión de trust & safety.
10. Chequeos de `electoral_counsel`, `data_protection_officer`, `neutrality_auditor` y
    `trust_safety_analyst` registrados antes del alta de personas reales.

## 9. Riesgos

| Riesgo | Mitigación |
| --- | --- |
| Captura por grupo coordinado o partido (infiltración lenta) | Un voto por persona; diversidad de ramas; sorteo; timelocks; veda de reglas; derecho de salida |
| Plutocracia de reputación y élite cerrada (Wikipedia, Stack Overflow) | Reputación sin voto; decaimiento; umbral bajo para paneles; medir retención de recién llegados |
| Goodhart y Sybil | Sólo señales validadas por terceros; √ y topes; muestras de control; sin rankings; QR en persona + grafo (TC); S4 ampliado; apoyos ponderados por diversidad de ramas |
| Dato sensible por inferencia (puente, grupos de opinión, grafo) | NG-5 (a) ahora; retención limitada; agregados; nada vinculado a cuentas en lo publicado |
| **Perfil público que expone su subred** (TC-15): quien lo invitó y quienes invitó quedan a un paso de una persona conocida; cruce con otras redes | NG-20 sin resolver; mientras tanto, sin perfiles públicos ni vínculos externos; roles públicos sin aristas; evaluación de `electoral_counsel` y trust & safety |
| Responsabilidad personal de quienes deciden (simple asociación, SLAPP) | Persona jurídica antes del alta real; lenguaje de hallazgo; réplica previa; retractación rápida |
| Parálisis: todo pasa por panel | Vía rápida para activaciones de modalidades aprobadas; paneles asincrónicos y breves |
| Deslegitimación ("la red es de tal partido") | Prueba del espejo; dictámenes y disidencias públicos; métricas de simetría de evidencia (04 §5) |
| Fork hostil que se presenta como "la red"; abuso o robo de las claves de pausa | Firmas de la entidad en publicaciones oficiales; marca [NV]; k de n, llaves físicas, sólo pausar, expiración y reporte en 24 h |

## 10. Preguntas para abogado/a y seguridad

1. ¿Puede el estatuto de una asociación civil delegar decisiones en votaciones de personas usuarias no
   asociadas, y con qué responsabilidad de la comisión directiva?
2. ¿Riesgo de que la red se trate como simple asociación (CCyC 187-192) antes de la entidad? ¿Obligación
   de inscribir la base (art. 21) y con qué finalidad declarada?
3. ¿La reputación intransferible queda fuera de "activo virtual" (Ley 25.246 art. 4 bis)?
4. ¿Los dictámenes sobre plataformas quedan cubiertos por el art. 110 CP (interés público) y qué
   estándar civil aplica?
5. ¿El factor latente efímero (NG-5 b) constituye "archivo" del art. 7 inc. 3? ¿Un esquema de encargo
   (art. 25) con todos los partidos compromete la condición no partidaria (Acordada CNE 128/11 [NV])?
6. Perfiles públicos (NG-20): ¿la red responde por la reidentificación de la subred de quien opta por un
   perfil público? ¿Qué consentimiento informado alcanza? ¿Cómo verificar un vínculo con otra red sin
   que la plataforma externa pueda cruzarlo con la cuenta de confianza?
7. Seguridad: esquema de umbral auditado para el consejo de pausa; voto secreto con recuento verificable
   sin coordinador de confianza; diversidad de ramas sin abrir el grafo (A5-b); credencial anónima
   "nivel ≥ N" sin vinculación (TC-8).

## Fuentes

Las de cada posición, con sus marcas. Verificadas allí: Flanigan et al., *Nature* 596 (2021); Wojcik et
al. (2022); Beanstalk (2022); concentración en DAO con token; vTaiwan; Decide Madrid; Asamblea Ciudadana
de Irlanda; Ley 25.326 y Código Electoral en Infoleg (03). **No verificadas [NV]:** *CFTC v. Ooki DAO*;
RFC 9162 y Sigsum; drand; Panelot; algoritmo y *rater helpfulness* de Community Notes; Ostrom (1990);
Stack Overflow y Decidim; textos exactos de CCyC, Ley 26.215 art. 15 y Acordada CNE 128/11; registro de marca.
