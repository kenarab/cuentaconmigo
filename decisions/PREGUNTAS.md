# Preguntas abiertas del proyecto

Fuente: `decisions/questions.json` (generado con `scripts/decisions/render.py`).
Se responden como comentarios en los issues de GitHub asignados a kenarab y andytow.
★ = propuesta de las SPECs (no vinculante).

## #1 · funcionalidades iniciales y alcance de la hackatón

Backlog: `sdd/specs/roadmap/FEATURES.md` (F-01 a F-51 con prioridad propuesta y estado).

- **F-P0** · ¿Qué entra en la hackatón (P0)?: a) Propuesta completa: escrutinio guiado (F-01..F-05) + simulación AMBA (F-10) + deliberación de muestra (F-21, F-40) + evidencia viral con tablero (F-30..F-32) ★ · b) Sólo escrutinio guiado + simulación AMBA · c) Escrutinio + AMBA + deliberación de muestra · d) Escrutinio + AMBA + evidencia viral con tablero · e) Deliberación + evidencia viral (sin escrutinio) · Otro
- **F-ORD** · ¿Por dónde empezamos a construir?: a) Escrutinio en iPhone (ya hay base) ★ · b) Simulación del AMBA · c) Deliberación de muestra · d) Evidencia viral y tablero · e) En paralelo con Andy · Otro

## #2 · pantallas y flujo del escrutinio en iPhone

Propuesta de Fable: `sdd/specs/app-screens/SPEC.md`. Revisión de Astra: `sdd/specs/app-screens/DECISION.md`. Prototipo navegable: `design/prototypes/escrutinio/`.

- **AS-1** · Navegación global: a) N-A: pestañas con la red al centro · b) N-B: app de escrutinio separada · c) N-C: una app con "modo jornada electoral" ★ · d) N-B ahora y N-C cuando exista la red · Otro
- **AS-2** · Flujo de escrutinio: a) F-1: asistente paso a paso · b) F-2: imagen arriba + campos con OCR · c) F-3: doble carga a ciegas · d) Híbrido: 4 pasos + F-2, F-3 opcional después ★ · Otro
- **AS-3** · ¿Certificado de escrutinio preseleccionado?: a) Sí · b) No, para no sugerir qué documento fotografiar · Otro
- **AS-4** · ¿Registrar en el contrato que se aceptó el aviso de Boleta Única?: a) Sí (cambio de contrato) · b) No · Otro
- **AS-5** · Doble carga a ciegas: a) Mínima ya (votantes y totales) · b) Completa ya (todas las celdas) · c) Después ★ · Otro
- **AS-6** · Campos vacíos: a) Botón "Cero" explícito ★ · b) Vacío = 0 con aviso · Otro
- **AS-7** · Aviso de plantilla ficticia en la demo: a) Franja permanente ★ · b) Aviso al inicio + etiqueta discreta · c) Sólo en "Acerca de" · Otro
- **AS-8** · ¿Mostrar si cada valor vino del OCR o se tipeó?: a) Sí, en pantalla · b) Sólo en el JSON exportado · c) En pantalla sólo al revisar · Otro
- **AS-9** · Pantalla "Acerca de" (E-12): a) Ahora · b) Después · Otro
- **AS-10** · Consulta a abogado/a electoral sobre fotografiar certificado/telegrama: a) Condición antes de cualquier uso real ★ · b) En paralelo al desarrollo · c) Más adelante · Otro
- **AS-11** · Datos de terceros en las imágenes exportadas: a) Definirlo con abogado/a antes del uso real ★ · b) Responsable: la organización operadora; conservar hasta el escrutinio definitivo + plazo · c) Cada fiscal responde por lo que exporta; la app no guarda fuera del teléfono · Otro
- **AS-12** · Campos `fictitious`, `lockedAt`, `exportedAt`: a) Agregar los tres al contrato · b) Agregar sólo `fictitious` · c) Dejarlos fuera del paquete exportado · Otro

## #3 · simulación del AMBA

SPEC: `sdd/specs/amba-simulation/SPEC.md`. Datos reales por mesa de las generales 2023, CABA + 24 partidos (decisión del autor).

- **S-1** · Plataforma: a) Web estática con mapa (MapLibre) ★ · b) Notebook Python · c) SwiftUI + MapKit · d) Web para la demo + notebook para el análisis · Otro
- **S-2** · Geografía: a) Polígonos oficiales ★ · b) Locales de votación reales si hay dataset público · c) Grilla sin geografía real · Otro
- **S-3** · Modelo estadístico: a) Estratificado por municipio ★ · b) Postestratificado con regresión · c) Bayesiano jerárquico · d) Estratificado ahora, bayesiano después · Otro

## #4 · visión, marca y posicionamiento legal

SPEC: `sdd/specs/vision/SPEC.md`. Marco legal: `docs/legal/MARCO_LEGAL.md`.

- **V-2** · Nombre y marca "CuentaConmigo": a) Confirmar ★ · b) Buscar otro nombre · c) Confirmar y sumar una bajada fija · Otro
- **V-3** · ¿Qué alianzas buscamos primero?: a) Derechos digitales · b) Verificación y periodismo · c) Universidades · d) Transparencia electoral · e) Todas en paralelo · Otro
- **V-4** · Posicionamiento frente al acompañamiento cívico (Acordada CNE 128/11): a) Herramienta abierta a cualquier fiscal, sin acreditación · b) Organización sin fines de lucro y sin vínculo partidario que se acredite · c) Las dos ★ · Otro

## #5 · red ciudadana y deliberación

SPECs: `sdd/specs/civic-network/SPEC.md` y `sdd/specs/civic-deliberation/SPEC.md`.

- **RC-1** · ¿Construir o reutilizar la red?: a) Decidim · b) CONSUL · c) Desarrollo propio · d) Híbrido: reutilizar + puente propio con la evidencia ★ · Otro
- **RC-2** · Umbral de consenso para pasar a la acción: a) Bajo: 50 personas verificadas y 60 % de acuerdo · b) Medio: 200 y 66 % · c) Alto: 500 y 75 % · d) Distinto según el tipo de acción · e) Definirlo en un piloto · Otro
- **RC-2b** · Consenso transversal (acciones que involucran partidos): a) Apoyo de al menos 3 fuerzas distintas · b) Apoyo de al menos 2 fuerzas de bloques distintos · c) Mayoría de las fuerzas participantes · d) No exigirlo salvo acciones con partidos · Otro
- **RC-3** · Reglas para los partidos: a) Cuentas verificadas con límites iguales; sin publicar durante la veda ★ · b) Cuentas verificadas sin reglas especiales de veda · c) Los partidos sólo leen y firman compromisos · d) Definirlo con electoral_counsel · Otro
- **RC-4** · Gobernanza de la red: a) Asociación civil con comisión directiva plural · b) Consejo consultivo de organizaciones aliadas · c) La comunidad elige moderadores por consenso · d) Combinación de las tres · Otro
- **RC-5** · Verificación de personas: a) Mismo criterio que PP-3 ★ · b) Invitación por personas de confianza · c) Verificación presencial con organizaciones aliadas · d) Credenciales anónimas · Otro
- **DL-2** · ¿Quién modera?: a) Voluntarios capacitados + comité diverso de apelación ★ · b) Organizaciones aliadas · c) Rotativa entre participantes · d) Mixta · Otro
- **DL-4** · Iniciativa popular (Constitución art. 39) como vía formal: a) Explorarla con chequeo legal ★ · b) No por ahora · Otro

## #6 · herramientas frente a las plataformas (eje A)

SPEC: `sdd/specs/platform-accountability/SPEC.md`. Toda acción frente a las plataformas surge de consensos de la red.

- **P-1** · Plataformas a cubrir primero: a) Meta, X, TikTok y YouTube + método especial para WhatsApp/Telegram ★ · b) Sólo Meta y X · c) Sólo TikTok y YouTube · d) Todas, incluidas Telegram y Kick · Otro
- **P-2** · ¿Qué herramientas del eje A van a la hackatón?: a) A1 archivo de evidencia + A4 tablero mínimo ★ · b) Sólo A1 · c) A1 + A2 publicidad indebida · d) Ninguna en la hackatón · Otro
- **P-3** · Plataforma técnica de A1/A4: a) Web estática + backend serverless · b) Web + backend propio · c) Reutilizar una herramienta de archivo existente · d) Decidir después de la hackatón · Otro
- **P-4** · Pedido colectivo de datos personales a las plataformas (derecho de acceso): a) Explorarlo con opinión legal ★ · b) No · Otro

## #7 · protección de participantes

SPEC: `sdd/specs/participant-protection/SPEC.md`. Revisión de Astra: `sdd/specs/participant-protection/DECISION.md`.

- **PP-1** · ¿Quién se ocupa de la protección?: a) Rol de agente `protection_officer` · b) Repartir entre seguridad, datos personales y electoral_counsel · c) Una persona responsable + rol de agente de apoyo · Otro
- **PP-2** · Arquitectura: a) Centralizada con minimización · b) Federada · c) Híbrida · Otro
- **PP-3** · Verificar personas sin pedir identidad: a) Invitación por personas de confianza · b) Verificación presencial con organizaciones aliadas · c) Credenciales anónimas · d) Combinación · Otro
- **PP-4** · Jurisdicción y alojamiento: a) Argentina · b) Exterior · c) Varias jurisdicciones con espejos · d) Definirlo con abogado/a · Otro
- **PP-5** · ¿A qué organizaciones contactamos primero?: a) Derechos digitales (ADC, Vía Libre) · b) Derechos humanos (CELS) · c) Transparencia electoral (Poder Ciudadano) · d) Periodismo y verificación (FOPEA, Chequeado) · e) Un grupo diverso en paralelo · Otro
- **PP-6** · Evidencia preservada vs. copia publicable: a) Separarlas, con cambio de contrato ★ · b) No publicar imágenes, sólo datos · Otro
- **PP-7** · Garantía de anonimato: a) Reemplazarla por criterios verificables ★ · b) Otra formulación · Otro

## #8 · plataforma móvil y backend

SPEC: `sdd/specs/mobile-platform/SPEC.md`.

- **D-002** · Lógica compartida iOS/Android: a) Dos apps nativas + contratos ★ · b) Kotlin Multiplatform para el núcleo · c) Skip (SwiftUI → Compose) · d) Nativas ahora; evaluar KMP al empezar Android · Otro
- **D-003** · Backend y recepción central: a) Serverless gestionado · b) Backend propio en contenedores · c) Reutilizar la plataforma de la red (RC-1) · d) Después de la hackatón · Otro

## #9 · organización del trabajo con agentes

SPECs: `sdd/specs/multiagent-system/SPEC.md`, `sdd/specs/review-pipeline/SPEC.md`, `sdd/specs/human-in-the-loop/SPEC.md`.

- **D-MA-1** · Agentes IA activos en paralelo: a) Mantener 2 · b) 4 para revisiones de sólo lectura · c) 6 · d) Sin límite fijo, a criterio del coordinador · Otro
- **D-MA-2** · Roles de chequeo a activar ya (además de electoral_counsel): a) platform_accountability, legal, data_protection y neutrality ★ · b) Esos 4 + security · c) Todos · d) Sólo electoral_counsel por ahora · Otro
- **D-MA-3** · Abogado/a electoral humano que valide el marco legal: a) Sí, buscarlo ya ★ · b) Más adelante · Otro
- **PR-1** · Lentes de revisión obligatorias: a) Todas para SPECs de producto; code + legal para código con datos ★ · b) Todas, siempre · c) Sólo legal obligatoria · Otro
- **PR-3** · Segunda opinión cuando Astra marca ⛔: a) Sí, con otro modelo · b) No · Otro
- **HL-1** · Revisión de issues de decisión: a) Diaria programada con resumen ★ · b) Sólo al empezar cada sesión · c) Dos veces por semana · Otro
