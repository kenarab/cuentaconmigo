# Deliberación · Gobernanza de la red · 04 · Trust & safety y neutralidad

Rol: `trust_safety_analyst`. Fecha: 31/10/2026. **Posición para la deliberación,
no decisión del autor.** Pendiente: chequeo de `electoral_counsel`. Responde al pedido
del autor (DAO, niveles dinámicos, interacciones, evaluaciones colegiadas).
Base: [trust-chain-identity](../../trust-chain-identity/SPEC.md) (niveles 0–3,
TC-2, TC-10, TC-11, TC-13, TC-14 según fed6c7e) y su [chequeo](../../trust-chain-identity/checks/electoral_counsel.md)
(A5, A11), [civic-network](../../civic-network/SPEC.md) (RC-2, RC-4),
[civic-deliberation](../../civic-deliberation/SPEC.md),
[platform-accountability](../../platform-accountability/SPEC.md),
[participant-protection](../../participant-protection/SPEC.md).

## Tesis en 5 puntos

0. **Alcance (precisión del autor, fed6c7e):** esta posición rige sólo la **red de
   confianza** (identidad seudónima, reputación, deliberación, gobernanza). La **red
   de publicación de actas** (capturas, fiscales) queda desconectada (TC-13 ★): sus
   capturas se validan por coincidencia y contra el escrutinio oficial, **nunca por
   reputación**, y no suman niveles. Las subredes de partidos usan **cuentas de rol
   genéricas** (TC-11 ★, TC-14), fuera de la red de confianza.

1. "Descentralizado" no equivale a "resistente a captura". Las DAO con voto por
   tokens muestran concentración extrema del poder (ver fuentes). Lo que protege es
   **poder repartido por funciones, con sorteo, topes y rotación**, no un único puntaje.
2. **Reputación ≠ poder de voto.** Los niveles habilitan *tareas* (verificar,
   invitar, moderar); el consenso sigue siendo una persona verificada = un voto,
   más el requisito de **apoyo transversal** (algoritmo de puente).
3. Todo lo que se cuenta se optimiza (ley de Goodhart/Campbell). Sólo deben subir el
   nivel las señales **costosas de fabricar y validadas por terceros independientes**.
4. Nada de lo anterior requiere registrar afiliación ni ideología (Ley 25.326, art. 7).
   La "diversidad de perspectiva" se **infiere del comportamiento de valoración**
   (factor latente), no se pregunta.
5. No recomiendo blockchain ni token para la hackatón: agrega costo, exposición de
   datos (registros inmutables vs. derecho de supresión) y plutocracia, sin resolver
   Sybil. "DAO" sirve como *principio* (reglas públicas, ejecución verificable,
   ningún operador decide solo), no como tecnología. Arquitectura: decide el autor.

## 1. Niveles dinámicos que no premien volumen, conformismo ni bloque

**Diseño propuesto:** puntaje continuo de *confiabilidad por dominio* (capturas,
verificación, deliberación, moderación) → niveles discretos derivados (p. ej. 0–7),
recalculados periódicamente. Un nivel alto en capturas no da poder en moderación.

| Mecanismo | Regla propuesta | Contra qué protege |
| --- | --- | --- |
| **Sólo señales validadas por terceros** | Suma un aporte cuando lo confirma alguien **de otra rama de invitación** y, si es valoración, de **perspectiva distinta** | Granjas de cuentas, anillos de votación |
| **Verificación cruzada de evidencia** (sólo evidencia de plataformas, A1–A3) | Captura cuenta si coincide (hash o contenido) con otra independiente o con fuente oficial; divergencia sistemática resta | Fabricación de "pruebas" |
| **Puente (bridging)** | En deliberación, un aporte vale si lo valoran útil personas con factor latente opuesto (modelo tipo Community Notes: intercepto del aporte, no votos brutos) | Conformismo y bloque: el aplauso del propio grupo no suma |
| **Rendimientos decrecientes** | Contribución por período con curva logarítmica + tope diario/semanal | Volumen, bots, "farmeo" |
| **Decaimiento** | Vida media (p. ej. 90 días) por dominio; el nivel se mantiene con actividad *validada*, no con presencia | Élites vitalicias, cuentas compradas dormidas |
| **Topes de nivel y de poder** | Nivel máximo alcanzable sin elección/sorteo; mandatos con plazo y no reelección inmediata para roles de moderación | Concentración |
| **Aprendizaje de calidad del evaluador** | Quien valora "útil" lo que después se demuestra falso pierde peso como evaluador (tipo *rater helpfulness*, a verificar en la doc de Community Notes) | Valoración estratégica |
| **Diversidad de rama** | Peso de validaciones descontado si vienen de la misma subrama de invitación | Colusión intra-rama (señal local, compatible con A5-b del chequeo) |
| **Penalización proporcional** | Escalera: aviso → descuento temporal del dominio → cuarentena (aportes no cuentan) → revocación sólo con evidencia | Castigos desmedidos que se usen como arma |
| **Apelación** | Toda baja de nivel notificada con motivo legible; apelación ante panel sorteado de otro dominio y otras ramas; decisión y criterio publicados agregados | Errores y abuso del sistema de sanciones |
| **Inmunidad a la opinión** | Prohibido usar el contenido político de opiniones o su "dirección" como señal; el factor latente se usa sólo para exigir *diversidad*, nunca para premiar un polo | Sesgo y riesgo legal (dato sensible) |

**Advertencias:**

- El factor latente de valoración **es una inferencia de perspectiva política**
  (dato sensible indirecto, art. 7 inc. 3, a verificar con `electoral_counsel`).
  Mitigación: calcularlo efímero, no persistirlo por cuenta, no exponerlo, no
  rotularlo, y usarlo sólo como restricción de diversidad. ⚠️ alto, decisión del autor.
- Evitar tablas de posiciones, insignias públicas y rachas: son los incentivos
  perversos típicos de la gamificación (competencia, volumen, conformismo). El nivel
  se muestra a la persona; públicamente sólo lo necesario para la tarea.

## 2. Catálogo de interacciones: riesgo y validación

| Interacción | ¿Sube nivel? | Riesgo de manipulación | Validación propuesta |
| --- | --- | --- | --- |
| Leer, seguir temas | No | — | — |
| Comentar / argumentar a favor o en contra | Sólo si el argumento recibe puente | Medio: brigadas, tono | Valoración "aporta" por perspectivas distintas; límite de frecuencia |
| Valorar ("útil/no útil") un aporte | Indirecto (calidad del evaluador) | Alto: anillos, voto en bloque | Peso por calidad histórica del evaluador; descuento por misma rama; detección de co-voto anómalo |
| Proponer idea / propuesta estructurada | Sólo si pasa a deliberación con puente | Medio: spam, propuestas partidarias encubiertas | Plantilla obligatoria; revisión de neutralidad; cupo por persona |
| Enmendar | Si la enmienda se acepta con puente | Medio: sabotaje por enmiendas | Votación de enmiendas con puente |
| Respaldar una iniciativa | **No** (es un derecho, no un mérito) | Alto: Sybil, compra de apoyos | Persona verificada; consenso transversal; auditoría de diversidad de ramas |
| Cargar evidencia de plataformas (A1–A3) | Sí, al confirmarse | Alto: falsos positivos masivos, fabricación | Hash + coincidencia independiente o fuente oficial; extraído vs. confirmado separados |
| Capturar telegrama/acta (red de actas) | **No** (red desconectada, TC-13); a futuro sólo con credencial anónima "N capturas coincidentes" (TC-8) | Alto, pero se valida por coincidencia y escrutinio oficial, no por persona | Fuera de esta posición: scrutiny-backend |
| Verificar evidencia ajena | Sí, si concuerda con verificación independiente posterior | Alto: verificadores coludidos | Doble ciego (no ver quién cargó ni la verificación previa); muestreo de control |
| Chequeo de hechos con fuentes | Sí, con puente | Alto: "chequeo" partidario | Fuentes enlazadas; puente; revisión de muestra por panel sorteado |
| Invitar por QR | No directo; resta si la invitada es maliciosa | Alto: granjas | Cupos (TC-2); responsabilidad hacia arriba (TC-3) |
| Señalar abuso dentro de la red | No | Alto: denuncias coordinadas como arma | Pesar señalamientos por calidad histórica y diversidad; nunca sanción automática por cantidad |
| Moderar / resolver apelaciones | No (rol por sorteo/mandato) | Muy alto: captura | Sorteo estratificado, rotación, decisiones publicadas, auditoría cruzada |
| Votar en evaluación colegiada (§4) | No | Muy alto | Panel sorteado, conflicto de interés declarado, rúbrica pública |

Regla: **participar nunca da poder; acertar en forma verificable da tareas.**

## 3. Evitar captura partidaria o de grupos coordinados

- **Separación de poderes** (sin "nivel máximo" único): proponer, verificar evidencia,
  moderar, custodiar el grafo y evaluar modalidades son roles distintos, con
  incompatibilidades (quien modera un caso no lo evalúa en apelación).
- **Sorteo por sobre elección** para roles sensibles: la elección por pares (nivel 3
  actual) premia a los bloques organizados. Sorteo entre elegibles, con
  estratificación por señales no políticas (antigüedad, dominio, región gruesa,
  rama de invitación) y verificación posterior de diversidad de perspectiva (§4).
- **Consenso transversal obligatorio** para toda acción externa (RC-2): umbral de
  personas verificadas + puente (apoyo en ambos lados del factor latente) + objeciones
  fundadas respondidas. Una mayoría homogénea **no** alcanza.
- **Partidos (TC-11, TC-14):** subredes de **cuentas de rol genéricas** (p. ej.
  "coordinación de fiscales de la sección X"), sin identificar personas, fuera de la
  red de confianza; sus fiscales están sólo en la red de actas. Los partidos **no votan** consensos ni integran paneles; pueden
  argumentar con idéntico cupo y formato. Igualdad verificable: tabla pública de
  permisos idéntica por partido y prueba automatizada que la compare.
- **Riesgos de las cuentas de rol (TC-14):** (a) responsabilidad difusa: una
  cuenta de rol que publica contenido de campaña o abusa no tiene una persona a quien
  sancionar; la sanción recae en el **rol y en la cuenta raíz del partido**
  (suspensión del rol, igual escala para todos); (b) traspaso de clave = clave
  compartida y filtrable: preferir delegación con vencimiento firmada por el rol
  superior (TC-14 ★) y registro público agregado de delegaciones por partido;
  (c) inflación de roles: tope idéntico de cuentas de rol por partido y por nivel
  territorial, publicado, para que nadie gane visibilidad multiplicando roles.
- **Militancia dentro de la red ciudadana:** por diseño (redes no vinculables) una
  persona puede ser fiscal o tener un rol partidario y además cuenta ciudadana; es
  legítimo y no debe detectarse por afiliación. La defensa es conductual: puente,
  descuento por misma rama, detección de sincronía. No intentar vincular redes para
  "descubrir" militantes (sería crear el archivo prohibido por el art. 7 inc. 3).
- **Detección de coordinación** por comportamiento, no por contenido: sincronía
  temporal, co-valoración anómala, densidad intra-rama, saltos bruscos de puntaje
  (patrones documentados en anillos de voto de Stack Overflow). Resultado:
  revisión humana, no sanción automática.
- **Freno de emergencia distribuido:** cualquier panel sorteado puede suspender una
  decisión por sospecha de captura por un plazo corto; reanuda una revisión de
  `electoral_counsel` y el autor.
- **Cambiar las reglas cuesta más que usarlas:** cambios de umbrales o del algoritmo
  de reputación requieren supermayoría transversal, período de aviso público y no
  se aplican a decisiones en curso (evita ajustar reglas para ganar un caso).

## 4. Evaluaciones colegiadas de modalidades frente a plataformas

Objeto: decidir si una modalidad (carta abierta, pedido de acceso a la información,
auditoría A2, tablero A4, propuesta regulatoria) se activa, se ajusta o se descarta,
y evaluar después si funcionó.

**Composición del panel**

- 9–15 personas **sorteadas** entre elegibles (nivel mínimo en el dominio,
  sin sanciones vigentes), estratificadas por señales no políticas.
- **Verificación de diversidad de perspectiva sin registrar afiliación:** tras el
  sorteo se comprueba que el panel cubra ambos lados del factor latente de valoración
  (cálculo efímero, sólo "cubre/no cubre"); si no, se re-sortea un estrato. Alternativa
  menos invasiva: sorteo uniforme y evaluación por puente dentro del panel.
  Ambas ⚠️ legal (dato inferido), decide el autor con `electoral_counsel`.
- Algoritmo de selección con probabilidades lo más iguales posible y publicado
  (tipo Panelot, Flanigan et al., Nature 2021).
- Observadores sin voto: `electoral_counsel` (obligatorio), un perfil técnico de
  medición y, si el autor lo decide, organizaciones aliadas.

**Conflictos de interés:** declaración privada (no pública) de vínculo laboral o
contractual con la plataforma evaluada, con un partido o con quien propuso la
modalidad; la persona se excusa sin decir por qué. Quien propuso no integra el panel.
No se pide afiliación: se pregunta sólo "¿tenés un conflicto con este caso?".

**Rúbrica (pública, 0–3 por criterio, con justificación escrita)**

| Criterio | Pregunta |
| --- | --- |
| Evidencia | ¿Hay capturas verificadas, independientes y con cadena de custodia? |
| Proporcionalidad | ¿La acción es la mínima necesaria para el objetivo? |
| Neutralidad | ¿Se aplicaría igual si el contenido favoreciera a otra fuerza? (prueba de simetría: reescribir el caso invirtiendo actores) |
| Legalidad | Chequeo de `electoral_counsel` (un ⛔ frena) |
| No silenciamiento | ¿Pide transparencia o cumplimiento, no borrar a personas? ¿Evita botones de denuncia? |
| Medibilidad | ¿Define antes una métrica de éxito y un plazo? |
| Riesgo para participantes | Exposición, represalias, SLAPP (participant-protection) |

**Medir efectividad (definida antes de actuar):** métricas de platform-accountability
(tiempo hasta acción visible, % de contenido falso verificado sin etiqueta a
24/48/72 h, anuncios observados ausentes de la biblioteca, anuncios en veda), con
línea de base previa y grupo de comparación (otra plataforma o período); respuestas
formales recibidas y plazos; cambios de política documentados. Sin línea de base no
se afirma efecto.

**Documentar sin usar denuncias:** observación pasiva y re-chequeo del estado público
(A1), bibliotecas de anuncios, panel de exposición con consentimiento (A3), pedidos
de información pública (Ley 27.275), derecho de acceso (Ley 25.326, P-4). Como
referencia comparada, el acceso a datos para investigación del art. 40 de la DSA
europea (no aplica en Argentina; sirve como argumento de incidencia).

**Registro:** se publican rúbrica, votos agregados, disidencias y resultado. El panel
no ejecuta: el contacto externo lo decide el autor.

## 5. Métricas de sesgo y viabilidad

**Detectar que el sistema se sesga (tablero interno, agregado)**

- Concentración: Gini/Herfindahl del puntaje y de las tareas sensibles; % de
  decisiones con participación de las 5 ramas de invitación más grandes.
- Simetría de evidencia: proporción de capturas y modalidades que involucran a cada
  fuerza vs. una línea de base externa (p. ej. volumen de publicidad por fuerza en
  bibliotecas de anuncios). Desvío persistente → revisión de `neutrality_auditor`.
- Tasa de puente: % de propuestas que alcanzan apoyo transversal; si cae a ~0, el
  umbral bloquea todo (en Community Notes la mayoría de notas no logra mostrarse:
  CCDH 2024 informó 74 % de notas precisas no visibles en posts electorales).
- Polarización del factor latente en el tiempo y entre paneles sorteados.
- Apelaciones: tasa y % revocado, desagregado por dominio y rama (no por partido).
- Sanciones vs. perspectiva inferida (auditoría periódica, efímera): ¿se sanciona
  más un lado? Igual tasa de falsos positivos por grupo.
- Rotación: antigüedad media en roles sensibles; renovación efectiva.
- Simulación adversarial (red team): brigada de N cuentas, anillo de valoración,
  ataque al umbral transversal, partido que multiplica cuentas de rol; medir cuánto
  mueve cada métrica (criterio 3 de TC).

**Hackatón (viable, con datos ficticios)**

- Prototipo navegable del catálogo de interacciones y de la pantalla "por qué subió/
  bajó mi nivel" con apelación (review-pipeline exige prototipo aprobado).
- Tabla pública de permisos idéntica por partido y por cuenta de rol.
- Simulación offline: puntaje con rendimientos decrecientes + decaimiento + puente
  simple sobre datos sintéticos, usando el código abierto de Community Notes como
  referencia (instalar dependencias requiere consulta al autor).
- Panel sorteado demostrativo con rúbrica sobre un caso ficticio de plataforma.

**Después**

- Puente en producción (con pocos evaluadores no converge; a calibrar).
- Credenciales anónimas para "nivel ≥ k" (TC-8), detección de coordinación sobre
  señales locales (A5-b), auditoría externa del algoritmo con academia.
- Evaluar formalización institucional (V-4) antes que cualquier tecnología "DAO".

## Riesgos abiertos y decisiones sugeridas al autor

| ID sugerido | Tema | Recomendación |
| --- | --- | --- |
| NG-TS-1 | Usar factor latente de valoración (perspectiva inferida) | Sí, efímero y sólo como restricción de diversidad; ⚠️ legal |
| NG-TS-2 | Niveles por dominio vs. nivel único | Por dominio, con nivel visible derivado |
| NG-TS-3 | Elección por pares para nivel 3 | Reemplazar por sorteo entre elegibles con mandato |
| NG-TS-4 | Blockchain/token | No, al menos hasta después de 2027 |
| NG-TS-5 | Gamificación visible (rankings, insignias) | No |
| NG-TS-6 | Sanción a cuentas de rol de partido | Sobre el rol y la cuenta raíz, escala idéntica y pública |
| NG-TS-7 | Capturas de actas como fuente de reputación | No en la hackatón; después, sólo por credencial anónima (TC-8, TC-13) |

## Fuentes

- Puente (Wojcik et al. 2022, verificado): https://arxiv.org/abs/2210.15723
- Community Notes, código y guía (**no verificado**; *rater helpfulness* a confirmar):
  https://github.com/twitter/communitynotes ·
  https://communitynotes.x.com/guide/en/under-the-hood/ranking-notes
- CCDH, oct. 2024 (74 % vía prensa; "<9 % mostradas" del Washington Post, no verificado):
  https://counterhate.com/wp-content/uploads/2024/10/CCDH.CommunityNotes.FINAL-30.10.pdf
- vTaiwan/Polis: https://arxiv.org/pdf/2502.05017
- Concentración en DAO (leídos sólo como resumen): https://arxiv.org/pdf/2302.12125 ·
  https://arxiv.org/abs/2604.25959 · https://arxiv.org/html/2510.05830v1
- Sorteo justo (Nature 2021): https://pmc.ncbi.nlm.nih.gov/articles/PMC8387237/
- Gaming en Stack Overflow: https://arxiv.org/abs/2111.07101
- CIB de Meta y crítica: https://transparency.meta.com/policies/community-standards/inauthentic-behavior ·
  https://journals.sagepub.com/doi/10.1177/29768624251369784
- DSA art. 40: https://arxiv.org/html/2505.01122v2
- Sin fuente encontrada: Optimism Citizens' House (gobernanza bicameral).
