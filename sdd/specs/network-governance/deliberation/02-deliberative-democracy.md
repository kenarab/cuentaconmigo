# Deliberación 02 · Democracia deliberativa y participación ciudadana digital

Perspectiva: especialista en democracia deliberativa (vTaiwan, Pol.is, Decidim, CONSUL,
minipúblicos por sorteo, Wikipedia, Stack Overflow, Ostrom). Fecha: 31/10/2026.
Estado: **propuesta para el autor.** No es una decisión ni tiene chequeo de `electoral_counsel`.
Responde al pedido del autor sobre una red sin control centralizado, con niveles dinámicos
y evaluaciones colegiadas de las acciones frente a las plataformas. Se relaciona con RC-2
y RC-4 ([civic-network](../../civic-network/SPEC.md)), DL-2 y DL-3
([civic-deliberation](../../civic-deliberation/SPEC.md)), TC-2 y TC-10
([trust-chain-identity](../../trust-chain-identity/SPEC.md)) y PP-2
([participant-protection](../../participant-protection/SPEC.md)).

Marcas: **[V]** = fuente consultada hoy (resumen o abstract, no siempre el texto
completo). **[NV]** = de memoria o sin verificar hoy.

## Tesis en 5 líneas

1. **Descentralizar el poder, no "tokenizarlo".** Conviene una DAO *sin token y sin
   blockchain pública*: reglas públicas, roles rotativos, sorteo y contrapesos.
2. **La reputación da responsabilidades, no votos.** En los consensos vale una persona
   verificada, un voto. La reputación habilita herramientas (verificar, moderar, invitar).
3. **Muchos niveles sí, pero por dimensión** (verificación, moderación, acompañamiento...),
   con decaimiento y topes, en lugar de un único número que se convierta en estatus.
4. **Se premia la exactitud y el puente entre grupos que piensan distinto**, no el volumen ni
   la coincidencia con la mayoría.
5. **Toda acción frente a plataformas pasa por un panel sorteado con una rúbrica pública**
   y después por el consenso de la red. El contacto externo lo decide el autor.

## 1. Qué enseñan los casos reales

| Caso | Qué hizo | Resultado conocido | Lección para CuentaConmigo |
| --- | --- | --- | --- |
| **vTaiwan + Pol.is** (Uber, 2015-16) | Encuesta Pol.is de 4 semanas; los participantes votan afirmaciones y el sistema muestra grupos de opinión y los puntos que comparten. Después, una reunión transmitida con gobierno, Uber y taxistas | Aparecieron consensos entre grupos opuestos. El gobierno ratificó parte de ellos (mayo 2016). El conflicto no se cerró: taxistas que no participaron siguieron protestando [V] | El valor está en **buscar el puente**, no la mayoría. Además, la deliberación sólo legitima si hay un compromiso previo de qué se hace con el resultado, y no reemplaza a quienes quedan afuera |
| **Community Notes / Birdwatch** (X) | Las notas se publican sólo si las califican como útiles personas que suelen discrepar entre sí (factorización de matrices, "bridging") | El estudio de los autores reporta 25-34 % menos de difusión de los posts anotados [V, cifra de fuente secundaria]. Limitación reconocida: datos sólo de EE. UU. [V] | Aplicable al **eje B**: una refutación cuenta cuando la avalan personas de grupos distintos. Es resistente a brigadas de un solo grupo |
| **Decide Madrid (CONSUL)** | Propuestas ciudadanas con umbral de apoyos para ir a consulta | El umbral del 2 % del padrón no lo alcanzó nadie. Se bajó al 1 % (≈27.000 apoyos) y para 2018 sólo 2 de unas 20.000 propuestas lo superaron [V] | Los **umbrales fijos de apoyos** mal calibrados frustran. Hay que calibrar con datos reales y publicar los umbrales antes de usarlos (ya está en RC-2) |
| **Decidim** (Barcelona) | Plataforma libre con un "contrato social" que obliga a transparencia, trazabilidad y datos abiertos | Se usa en muchas ciudades. La plataforma es abierta, pero el poder de decisión sigue en el municipio [NV] | Que el **código y las reglas** sean de todos no alcanza: hay que definir quién decide y cómo se le piden cuentas (RC-4) |
| **Asamblea Ciudadana de Irlanda** (2016-17) | 99 personas sorteadas y una presidencia, cinco sesiones con expertos y testimonios | Recomendó la reforma por amplia mayoría. Una comisión parlamentaria la tomó y en el referéndum de 2018 ganó el Sí con 66,4 % [V] | **El sorteo da legitimidad** frente a la acusación de "facción", sobre todo en temas polarizados. El minipúblico propone y otra instancia decide |
| **Algoritmos de sorteo justo** (Flanigan, Procaccia y otros, *Nature* 2021) | Sorteo estratificado que maximiza la equidad de la probabilidad de ser elegido | Usado en más de 40 asambleas, con herramienta libre (Panelot) [V] | El sorteo con cuotas está resuelto técnicamente. No hay que inventarlo |
| **Wikipedia** | Privilegios por elección de la comunidad (administradores) y control de calidad intenso | Los nuevos administradores cayeron de 408 (2007) a 121 (2009) [V, prensa]. Halfaker y otros (2013): el control de calidad hizo más hostil el ingreso, porque aumentó la proporción de recién llegados de buena fe a quienes se les revierte el aporte [V] | Los niveles altos tienden a **cerrarse** y a expulsar a quien llega. Hace falta medir la retención de los recién llegados y premiar el acompañamiento |
| **Stack Overflow** | Reputación por aportes valorados, privilegios por umbral (comentar, editar, cerrar, moderar), tope diario de reputación y moderadores elegidos | Funciona como guía de privilegios graduales. También es conocido por la hostilidad hacia los nuevos [NV] | **Privilegios por umbral, con topes** y elección de moderadores. No copiar el "puntaje único" visible como estatus |
| **DAO con token** (The DAO 2016; Compound, Uniswap) | Votan los dueños de tokens | El poder queda concentrado: en Compound, unas 19 direcciones superan el 50 % del suministro, con un Gini de poder de voto ≥ 0,94 [V]. The DAO terminó en un hackeo y en un *hard fork* de Ethereum (2016) [NV] | **Un token compra poder.** Eso contradice el principio 6 de la visión (sin amplificación paga) y la igualdad entre partidos |
| **Ostrom** (*Governing the Commons*, 1990) | Ocho principios de los bienes comunes que perduran | Base empírica clásica [NV] | Límites claros, reglas adaptadas al lugar, **quienes cumplen las reglas participan en cambiarlas**, monitoreo por pares, **sanciones graduales**, resolución de conflictos barata y niveles anidados |

### Conclusión de la sección

- **Una "DAO" sí, en el sentido de Ostrom; no en el sentido de un token.** Además, una
  cadena de bloques pública guarda votos y aristas de forma inmutable. Con seudónimos
  re-identificables, eso choca con la Ley 25.326 (art. 7 inc. 3, datos sensibles
  indirectos, y el derecho de supresión, art. 16) [NV para la aplicación del art. 16; ver
  L2 del [chequeo de trust-chain](../../trust-chain-identity/checks/electoral_counsel.md)].
- **Descentralizar = separar poderes**, no eliminarlos: quien propone, quien evalúa
  (panel sorteado), quien decide (consenso de la red), quien ejecuta (autor/organización)
  y quien controla (auditoría pública y apelación) no deben ser la misma instancia.
- **Fases de transición:** fundadores con poder de veto explícito y temporal, que se
  transfiere por etapas publicadas (por ejemplo, después de 2027). Prometer una
  descentralización total desde el día uno no es creíble ni seguro.

## 2. Niveles y privilegios dinámicos

### Principios

1. **Una persona verificada, un voto en los consensos.** La reputación nunca multiplica
   votos. Es la regla más importante contra la captura y lo que hace compatible un
   sistema de niveles con la igualdad.
2. **Reputación por dimensión**, no un puntaje único. Una persona puede ser experta
   verificando capturas y nueva moderando.
3. **Se gana con aportes que otras personas o la realidad confirman**, no con actividad.
   La realidad confirma, por ejemplo, cuando una captura coincide con el acta oficial o
   cuando una refutación se sostiene con fuentes.
4. **Decaimiento** (por ejemplo, vida media de 6 meses) y **topes por día y por semana**.
   El nivel refleja la contribución reciente, y nadie se queda con un privilegio para
   siempre.
5. **Los niveles son dinámicos y muchos:** se derivan de umbrales públicos por dimensión,
   recalculables, versionados y modificables por consenso, como cualquier regla de la red.
   La tabla de TC-2 (0-3) pasa a ser el resumen visible.
6. **Nada depende de opiniones políticas** (criterio 4 de trust-chain). Los cálculos se
   publican y cualquiera los puede reproducir con datos agregados.
7. **Sanciones graduales y reversibles** (Ostrom): advertencia, pérdida temporal de un
   privilegio, cuarentena. Siempre con apelación.

### Catálogo de interacciones y qué suma

| Dimensión | Interacción | Qué la valida (señal que suma) | Anti-gaming |
| --- | --- | --- | --- |
| **Deliberar** | Argumentar a favor o en contra con fuente | Valoración "útil" de personas de **grupos distintos** al propio (puente) | Las valoraciones del propio grupo de opinión o de la propia rama de invitación pesan poco |
| **Proponer** | Propuesta estructurada, enmiendas | Avance de fase (idea → consolidada) y enmiendas aceptadas por quien no es autor | Tope de propuestas activas; no suma por cantidad de apoyos |
| **Verificar capturas** (ejes A, D) | Segunda verificación de telegramas, anuncios o publicaciones | **Exactitud** frente a la verdad posterior (acta oficial, re-chequeo, consenso de verificadores independientes) | Verificación ciega (sin ver lo que respondió el otro); muestras de control con resultado conocido |
| **Refutar desinformación** (eje B) | Nota con fuentes al estilo Community Notes | Nota aceptada por el algoritmo de puente | Se refutan afirmaciones, no personas; mismas reglas para contenido de cualquier fuerza |
| **Moderar** | Aplicar reglas públicas | Decisiones confirmadas en apelación o por revisión de una muestra | Moderación en pares; rotación; los votos de confianza de la comunidad son periódicos |
| **Acompañar a nuevos** | Invitar y ayudar a las personas que entran | **Retención y calidad** de quienes invitó a los 30 y 90 días, no la cantidad | Suma con decaimiento y resta si la rama es maliciosa (TC-3) |
| **Fiscalizar** (eje D) | Capturar el telegrama de su mesa | Coincidencia con el escrutinio y con otras capturas | Fiscales de partido fuera de la jerarquía ciudadana (TC-7) |
| **Evaluar acciones** | Integrar un panel sorteado (sección 3) | Asistencia, dictamen fundado y calibración posterior | No es una carrera: se llega por sorteo, no por mérito |
| **Auditar la propia red** | Revisar métricas de neutralidad, reportar sesgos | Hallazgos confirmados por otras personas | Recompensa sin importar a quién beneficie el hallazgo |

### Qué no suma

- Volumen de publicaciones, seguidores, "me gusta" o tiempo conectado.
- **Coincidir con la mayoría.** Disentir con fuentes no resta. Lo que suma es que el
  argumento sea útil también para quien piensa distinto. Así se protege la diversidad.
- Apoyos recibidos de la propia rama de invitación o de un grupo coordinado.

### La diversidad como valor (puentes)

- En las deliberaciones, mostrar el **mapa de opiniones** al estilo Pol.is: los grupos
  y los puntos de acuerdo entre ellos. El orden por defecto prioriza los puntos de puente,
  lo que es coherente con un "orden transparente".
- **Precaución legal:** los grupos de opinión son una inferencia de opinión política,
  un dato sensible por inferencia (art. 7 inc. 3). Propuesta: calcularlos sólo dentro de
  cada deliberación, publicarlos agregados, no guardarlos por persona y no usarlos fuera
  de esa deliberación. Requiere el chequeo de `electoral_counsel` y de
  `data_protection_officer` (no lo resuelvo yo).

### Privilegios por umbral (ilustrativo, a calibrar)

| Privilegio | Requisito ilustrativo |
| --- | --- |
| Leer, deliberar, cargar capturas | Alta por invitación |
| Respaldar propuestas (cuenta para el consenso) | Verificación de persona (DL-3) más 14 días. **Igual voto para todos** |
| Segunda verificación de capturas | Exactitud ≥ 90 % en N muestras de control |
| Escribir notas de refutación | Exactitud de calificaciones de notas ≥ umbral |
| Moderar (en pares) | Dimensión moderación ≥ X, sin sanciones en 90 días y elección o confirmación por la comunidad, con mandato de 6 meses |
| Abrir foros de trabajo | Dimensiones ≥ X en dos áreas (límite de foros por persona) |
| Entrar al sorteo de paneles | Verificación de persona y 30 días. **No se exige un nivel alto** (evita la élite) |

## 3. Evaluaciones colegiadas de las modalidades frente a plataformas

### Proceso propuesto (7 pasos)

```
propuesta → admisión → panel sorteado → dictamen público → consenso de la red → chequeo legal → decisión del autor → ejecución → revisión posterior
```

1. **Propuesta** con la plantilla de civic-deliberation más una ficha de acción: qué se
   pide, a quién, evidencia (enlaces a A1-A4), cuándo y cómo se revierte.
2. **Admisión formal** (moderación en pares): ¿está completa y es no partidaria? No
   evalúa el fondo.
3. **Panel sorteado** de 15 a 25 personas:
   - sorteo estratificado entre personas verificadas que se ofrecieron, con un algoritmo
     de sorteo justo (Panelot o equivalente libre; **instalar o usar herramientas lo decide
     el autor**);
   - estratos **sin datos sensibles**: provincia o región, antigüedad en la red, ramas de
     invitación distintas (como máximo una o dos personas por rama), y paridad de género si
     la persona lo declara voluntariamente. **Nunca** afinidad política (Ley 25.326);
   - semilla del sorteo pública y verificable (por ejemplo, derivada de un número que se
     publica después, como un resultado de lotería oficial) para que nadie pueda manipularlo;
   - rotación: nadie repite panel en el mismo trimestre;
   - **partidos**: todos con el mismo derecho a presentar un descargo escrito o una
     exposición de igual duración. No tienen voto en el panel;
   - expertos invitados (derecho, datos, periodismo) que informan pero no votan.
4. **Rúbrica pública** (0 a 3 por criterio; cada puntuación con fundamento escrito):

   | Criterio | Pregunta | Mínimo para avanzar |
   | --- | --- | --- |
   | Legalidad | ¿Hay riesgo legal identificado por `electoral_counsel`? ¿Respeta la veda y la Ley 25.326? | Sin ⛔ |
   | Evidencia | ¿Hay capturas con hash, metodología y datos reproducibles? ¿Se distingue lo extraído de lo confirmado? | 2 |
   | Proporcionalidad | ¿La acción es la menos gravosa que alcanza el objetivo? | 2 |
   | Neutralidad | ¿Se aplicaría igual si el contenido fuera de cualquier otra fuerza? ¿Hay casos simétricos documentados? | 3 |
   | Riesgos | Para participantes (persecución), para la red (deslegitimación) y para terceros (exposición) | 2 |
   | Reversibilidad | ¿Se puede retirar o corregir? ¿Tiene fecha de vencimiento? | 2 |
   | Coherencia con principios | ¿No usa botones de denuncia? ¿No busca silenciar a personas? | 3 |

5. **Dictamen público**: recomendación (adoptar, adoptar con cambios o rechazar), puntajes,
   votos del panel, **votos en disidencia fundados** y fuentes. Sin nombres: el panel firma
   con seudónimos.
6. **Consenso de la red** según RC-2: umbral publicado de antemano, consenso transversal
   (apoyo desde grupos distintos del mapa de opiniones o desde ramas distintas) y ausencia
   de objeciones fundadas sin respuesta. Si la red contradice el dictamen, se registra el
   motivo.
7. **Chequeo de `electoral_counsel` y decisión del autor** antes de cualquier contacto
   externo, como exige AGENTS.md. Después de ejecutar la acción, el panel (o uno nuevo)
   publica una **revisión posterior**: qué pasó y si la acción tuvo el efecto buscado.
   Esa revisión ajusta la rúbrica.

### Por qué un panel sorteado y no los niveles altos

- Evita que las personas con más reputación se conviertan en una élite que decide.
- Un grupo coordinado no puede elegir quién lo evalúa (resistencia a la captura).
- Frente al público y a los partidos, "lo evaluaron personas sorteadas con reglas públicas"
  es más defendible que "lo decidió el equipo" (escudo de legitimidad, PP principio 7).

## 4. Riesgos

| Riesgo | Mitigación |
| --- | --- |
| **Goodhart**: la gente optimiza la métrica | Muchas dimensiones, decaimiento, topes, muestras de control y cambios de fórmula por consenso |
| **Élite y cierre** (caso Wikipedia) | Una persona, un voto; sorteo sin requisito de nivel alto; medir la retención de los recién llegados |
| **Captura coordinada / Sybil** | Peso bajo para apoyos de la misma rama; puente obligatorio; detección en el grafo (trust-chain); sorteo |
| **"Puntaje ciudadano"** (connotación y riesgo legal de perfilado) | Llamarlo "reputación de participación" (TC-10); cálculo transparente; apelación con revisión humana; nunca usarlo fuera de la red |
| **Grupos de opinión = dato sensible** | Cálculo efímero por deliberación y sólo agregado; chequeo legal previo |
| **Fatiga y baja participación en paneles** | Paneles chicos, asincrónicos, de 1 a 2 semanas, con materiales breves; reconocimiento en la dimensión "evaluar" |
| **Parálisis**: todo pasa por un panel y nada se hace | Vía rápida para acciones de bajo riesgo ya evaluadas (plantillas aprobadas) |
| **Deslegitimación** ("la DAO es de tal partido") | Rúbrica de neutralidad con casos simétricos; dictámenes y disidencias públicos; aliados diversos |
| **Una blockchain o un token** vuelve el poder comprable y los datos inmutables | No usar token ni cadena pública; si hace falta prueba de integridad, publicar hashes de los registros de consenso |
| **Responsabilidad legal difusa** de una DAO sin entidad | Una entidad sin fines de lucro responde (V-4); la gobernanza distribuida decide dentro de ella [NV: forma jurídica] |

## 5. Hackatón vs después

**Viable para la hackatón** (con datos ficticios, sin instalar nada sin aprobación):

- Este documento consolidado en una SPEC `network-governance` con decisiones para el autor.
- **Rúbrica pública** aplicada a un caso real de catálogo (por ejemplo, la carta abierta a
  plataformas sobre anuncios en veda), con un **panel simulado** y su dictamen de ejemplo.
- Tabla de dimensiones y privilegios en un JSON de reglas versionado, más un cálculo de
  ejemplo con perfiles ficticios.
- Prototipo navegable (pantallas, según review-pipeline) del mapa de opiniones y del
  dictamen, sin backend.

**Después:**

- Implementar el algoritmo de puente para refutaciones y argumentos.
- Sorteo estratificado con semilla verificable; calibrar umbrales con uso real (lección de
  Madrid).
- Decaimiento, topes y muestras de control para verificadores.
- Plan de transferencia de poder de los fundadores a la red, con fechas.
- Evaluar Decidim o CONSUL (DL-1/RC-1): ya tienen procesos, asambleas y sorteo parcial [NV].

## Decisiones propuestas para el autor

| ID | Decisión | Opciones (★ recomendada) |
| --- | --- | --- |
| GOV-1 | Tipo de descentralización | Gobernanza distribuida sin token ni blockchain ★ · DAO con token · centralizada con auditoría |
| GOV-2 | Peso del voto | Una persona verificada, un voto ★ · ponderado por reputación |
| GOV-3 | Estructura de niveles | Multidimensional con decaimiento ★ · puntaje único con muchos niveles · tabla 0-3 de TC-2 |
| GOV-4 | Quién evalúa las acciones externas | Panel sorteado con rúbrica más consenso de la red ★ · niveles altos · equipo |
| GOV-5 | Mapa de opiniones (Pol.is) | Efímero y agregado, con chequeo legal ★ · persistente · no usarlo |
| GOV-6 | Transición del poder fundador | Por etapas con fechas publicadas ★ · inmediata · indefinida |

## Fuentes

- vTaiwan y Uber: https://www.shareable.net/open-data-hactivists-help-taipei-craft-regulatory-response-to-uber/ ;
  https://sayit.archive.tw/2016-07-30-ridesharing-in-taiwan ; https://arxiv.org/pdf/2312.03893 [V]
- Birdwatch / Community Notes: https://arxiv.org/abs/2210.15723 [V abstract]
- Decide Madrid: https://participedia.net/case/6895 ;
  https://www.diariodeleon.es/sociedad/170219/389707/cierran-urnas-primera-gran-consulta-madrid.html [V]
- Asamblea Ciudadana de Irlanda: https://www.electoral-reform.org.uk/the-irish-abortion-referendum-how-a-citizens-assembly-helped-to-break-years-of-political-deadlock/ ;
  https://www.rte.ie/news/newslens/2018/0526/966234-referendum-results-at-a-glance [V]
- Sorteo justo: https://pmc.ncbi.nlm.nih.gov/articles/PMC8387237/ (Nature 596:548-552, 2021) [V]
- Wikipedia: https://dailydot.com/wikipedia-administrator-crisis-stats ; https://arxiv.org/abs/2601.20016 ;
  https://stuartgeiger.com/papers/abs-rise-and-decline-wikipedia.pdf (Halfaker y otros, 2013) [V]
- Concentración en DAO: https://arxiv.org/pdf/2510.05830 ; https://arxiv.org/pdf/2204.01176 ;
  https://blogs.law.ox.ac.uk/business-law-blog/blog/2021/11/how-decentralised-are-decentralised-autonomous-organisations-daos [V]
- Stack Overflow, privilegios: https://stackoverflow.com/help/privileges [NV hoy]
- Decidim, contrato social: https://decidim.org/contract/ [NV hoy]
- Ostrom, E. (1990). *Governing the Commons*. Cambridge University Press [NV hoy]
- Pol.is: https://compdemocracy.org/ [NV hoy]
