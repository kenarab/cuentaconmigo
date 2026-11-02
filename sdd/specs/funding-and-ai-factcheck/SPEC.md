# SPEC · Financiamiento y verificación de desinformación con IA

Estado: **investigación de escritorio; opciones para el autor, nada decidido.** Encargo del
autor transmitido por la sesión de Nexo (2/11/2026), planteado por voz como idea. No se
contactó a nadie. El autor escribe por su cuenta a Fundar; este documento no lo
reemplaza ni lo prepara. Relacionada con [vision](../vision/SPEC.md) (eje B),
[platform-accountability](../platform-accountability/SPEC.md),
[network-governance](../network-governance/SPEC.md),
[participant-protection](../participant-protection/SPEC.md) (PP-5, sigue abierta) y
[app-screens](../app-screens/SPEC.md) (nota con fuentes).

## 1. Pedido

1. **Financiamiento:** quién podría financiar un proyecto así, con fuentes.
2. **Herramienta:** IA que verifique desde afuera, no a cargo de las plataformas, las
   falsedades que circulan. Según el autor, hay muchas fáciles de rebatir y la
   manipulación se normalizó en todo el espectro político. No es sólo técnico y cuesta plata.

## 2. Encaje en el producto

La herramienta es el eje B (Desinformación: detección, verificación y respuesta
comunitaria), que la visión ya nombra (`misinformation-response`, sin SPEC todavía), y
la nota con fuentes de app-screens. **Propuesta:** tratarla como la SPEC del eje B y no
como un producto aparte. Así hereda las reglas vigentes:
- refutar con fuentes, sin buscar silenciar a personas;
- no usar los mecanismos de denuncia de las plataformas;
- consenso registrado antes de cualquier acción externa;
- mismas métricas para todos los actores.

## 3. Herramienta: qué existe y qué se puede hacer

| Pieza | Estado del arte (fuente) | Uso propuesto |
| --- | --- | --- |
| Detección de afirmaciones verificables | Full Fact AI: F1 0,83 en detección; más de 40 verificadores en 30 países y 12 elecciones nacionales en 2024 ([Full Fact](https://fullfact.org/ai/), [arXiv 1809.08193](https://arxiv.org/pdf/1809.08193)) | Priorizar qué revisar, no decidir |
| Cotejo con chequeos ya publicados | Los LLM igualan a personas en *claim matching* ([arXiv 2310.09223](https://arxiv.org/pdf/2310.09223v1.pdf)); arquitectura de 4 etapas tipo ClaimBuster ([survey](https://arxiv.org/pdf/2109.11427)) | Respuesta inmediata con un chequeo existente y su fuente |
| Verificación en Argentina | Chequeado tiene Chequeabot y un laboratorio de IA; según Africa Check, la mitad de sus chequeos semanales parte de afirmaciones detectadas por IA ([Chequeado](https://chequeado.com/que-hicimos-frente-a-la-desinformacion-en-2024-y-como-podes-ayudarnos-este-ano-electoral/), [Africa Check](https://africacheck.org/fact-checks/blog/how-were-using-artificial-intelligence-scale-global-fact-checking)) | Aliado natural (PP-5 d); no duplicar lo que ya hacen |
| Notas escritas por IA y calificadas por personas | X abrió la API de notas escritas por IA (7/2025), pero sólo las personas califican ([arXiv 2506.24118](https://arxiv.org/html/2506.24118v1)). En el campo, las notas de un LLM resultaron más útiles que las humanas con igual exposición, en un solo estudio de 1.614 notas ([arXiv 2604.02592](https://arxiv.org/abs/2604.02592)). Tras una nota, las republicaciones caen 45,7 % (Slaughter et al., 2025) | Modelo a seguir: la IA redacta, la red con diversidad de posiciones califica, una persona publica |

**Propuesta de diseño (a validar):**
- La IA nunca emite un veredicto automático público. Detecta, busca fuentes y redacta un
  borrador.
- La red califica el borrador con el criterio de "útil para personas que suelen
  discrepar". Publicar requiere confirmación humana y fuentes enlazadas.
- Se arranca por la categoría que el autor marca como fácil: datos verificables con fuente
  oficial (fechas, cifras públicas, reglas electorales).
- Se mide por igual en todo el espectro: el muestreo de qué se verifica es
  auditable y se publica.
- Por la regla de infraestructura propia, los modelos corren localmente o en servidores
  propios. Usar un LLM de terceros es una decisión aparte que toma el autor.

**Costos que no son técnicos:**
- moderación y calificación humana;
- revisión legal de cada formato público;
- trabajo editorial;
- cómputo.

Sin financiamiento, la escala realista es un piloto acotado.

## 4. Financiamiento: quién podría

| Fuente | Qué financia (fuente) | Encaje | Riesgo |
| --- | --- | --- | --- |
| **IFCN Global Fact Check Fund** (Google y YouTube vía Poynter) | Hasta USD 12 M en total y USD 100 k por proyecto; en 2026, fondos libres para sostenibilidad (SUSTAIN). Se anuncia SUSTAIN 2027 ([Poynter](https://www.poynter.org/ifcn/grants-ifcn/globalfactcheckfund/), [2026](https://www.poynter.org/ifcn/2026/ifcn-awards-750000-to-25-fact-checkers-navigating-a-funding-crisis/)) | Exige ser signatario de IFCN o socio de uno; vía realista: alianza con Chequeado | Dinero de plataformas que el eje A mide: conflicto de interés a declarar |
| **Luminate** (Omidyar) | Proyecto Elecciones Argentina: financió Chequeado, Democracia en Red y Conocimiento Abierto; subsidios típicos de USD 125–265 k; estrategia 2022–2027 ([Luminate](https://luminategroup.com/posts/story/driving-civic-engagement-in-argentina-through-advocacy-fact-checking-and-technology), [estrategia](https://luminategroup.com/storage/1653/Luminate-Strategy-2022-2027.pdf)) | Muy alto (tecnología y democracia) | Extranjero; confirmar la vigencia después de 2027 |
| **Fondo Luminate + Open Society + Fundación Avina** | USD 3 M para derechos digitales y democracia en América Latina, coordinado por Avina ([Forbes MX](https://www.forbes.com.mx/grupos-de-derechos-digitales-humanos-y-democraticos-recibiran-apoyo-de-3-mdd-en-al/), [Inside Philanthropy](https://www.insidephilanthropy.com/home/2020/8/19/with-osf-and-omidyar-backing-a-new-fund-targets-civic-engagement-in-latin-america)) | Alto | Edición de 2020; confirmar si sigue activo |
| **NED** | Lista de subsidios para América Latina, ejercicio 2024 ([NED](https://ned.org/wp-content/uploads/2025/04/LAC-Grant-Listing-FY24.pdf)) | Medio | Fondos del Congreso de EE.UU.: riesgo de percepción de injerencia extranjera |
| **Embajada de EE.UU. / UE** | Convocatorias para soluciones digitales de gobierno que relevó CONICET en 2026 ([CONICET](https://noasur.conicet.gov.ar/wp-content/uploads/sites/101/2026/03/Coleccion-de-Convocatorias-Febrero-2026_3.pdf)) | Bajo a medio | Gobiernos extranjeros: el más sensible (§5) |
| **Fondos públicos locales** | FITBA de la Provincia de Buenos Aires, $3.500 M en 2026, para empresas, cooperativas y municipios ([Espacio Tech](https://www.espaciotech.net/2026/08/10/buenos-aires-destinara-3-500-millones-a-financiar-nuevos-proyectos-de-tecnologia-e-innovacion)) | Bajo: no es tecnología cívica | Dinero de un gobierno que compite en la elección: compromete la neutralidad |
| **Donaciones ciudadanas** | Chequeado se sostiene en parte así y publica un informe anual de financiamiento ([Chequeado](https://chequeado.com/que-hicimos-frente-a-la-desinformacion-en-2024-y-como-podes-ayudarnos-este-ano-electoral/)) | Alto en legitimidad, bajo en monto | Requiere una persona jurídica y transparencia |

No verificado:
- los montos y plazos de 2027 de cada fuente;
- si NED y la embajada de EE.UU. mantienen programas para Argentina;
- quién financia a Fundar (no buscado: el contacto es del autor).

## 5. Marco legal (chequeo preliminar de `electoral_counsel`, autocontrol)

- **Ley 26.215, art. 15, incisos e) y f):** prohíbe a partidos y campañas (art. 44)
  recibir aportes de gobiernos o entidades públicas extranjeras, y de personas humanas o
  jurídicas extranjeras sin residencia en el país. El art. 66 multa también a quien dona
  ([InfoLEG](https://servicios.infoleg.gob.ar/infolegInternet/anexos/120000-124999/124231/texact.htm)).
  Esto **no prohíbe** que una asociación civil no partidaria reciba fondos extranjeros. Pero
  ⚠️ si la red apoyara a un partido o candidato, ese apoyo podría leerse como un aporte en
  especie con fondos prohibidos.
- ⚠️ **"Iniciativa política" contra "red no partidaria":** el autor la describió como parte de
  una iniciativa política, y AGENTS.md exige neutralidad y consenso antes de actuar.
  Recomendación: la herramienta verifica afirmaciones, no actores, con las mismas reglas
  para todo el espectro, y ningún financiador puede orientar qué se verifica. Una
  iniciativa política del autor puede *usar* los resultados públicos como cualquiera, pero
  no conducir la herramienta.
- ⚠️ **Veredictos automáticos:** que una IA etiquete algo como falso, sin revisión humana, se
  expone a reclamos por daño al honor y por errores; en veda electoral, a reproches por
  incidir en la campaña. Además, el Congreso tiene proyectos que prohíben contenido
  electoral engañoso generado con IA (3728-D-2025) y que crean un sandbox de IA
  (3330-D-2026), que todavía no son ley
  ([HCDN](https://www4.hcdn.gob.ar/dependencias/dsecretaria/Periodo2025/PDF2025/TP2025/3728-D-2025.pdf),
  [Digital Policy Alert](https://digitalpolicyalert.org/event/43704-testing-requirement-in-legal-regime-for-the-responsible-use-of-artificial-intelligence-3330-d-2026-was-introduced-to-chamber-of-deputies)).
  Recomendación: siempre una persona responsable y fuentes enlazadas, como en §3.
- ⚠️ **Fondos de plataformas o de gobiernos que compiten:** no son ilegales, pero afectan la
  neutralidad percibida. Recomendación:
  - publicar a todos los financiadores y montos;
  - fijar un tope por financiador;
  - no aceptar dinero de partidos, candidatos, gobiernos en ejercicio que compiten ni
    plataformas auditadas por el eje A, salvo que el autor decida otra cosa.
- **Datos personales (Ley 25.326):** analizar publicaciones de personas identificables exige
  minimizar datos y no armar perfiles de usuarios.
- Este chequeo no reemplaza a un abogado o una abogada electoral humanos: hay que
  consultar antes de recibir fondos.

## 6. Preguntas para el autor

1. **FV-1** · ¿La verificación con IA es la SPEC del eje B (★) o un producto aparte?
2. **FV-2** · ¿Qué nivel de autonomía tiene la IA?
   - a) borradores calificados por la red y publicados por una persona ★;
   - b) respuestas automáticas sólo cuando hay un chequeo existente;
   - c) veredicto automático (no recomendado).
3. **FV-3** · ¿Qué política de financiamiento?
   - a) transparencia total, tope por financiador y exclusiones de §5 ★;
   - b) sólo donaciones ciudadanas y fundaciones locales;
   - c) sin restricciones propias más allá de la ley.
4. **FV-4** · ¿Con qué figura recibir fondos?
   - a) una asociación civil propia;
   - b) a través de una organización aliada (por ejemplo, alianza con un signatario de IFCN) ★;
   - c) se decide después de hablar con Fundar.
5. **FV-5** · ¿Cómo se resuelve la tensión entre la "iniciativa política" del autor y la red no partidaria (§5)?
6. PP-5 sigue abierta. La investigación sugiere sumar a Chequeado (opción d) como socio
   técnico de la herramienta, pero eso lo decide el autor.
