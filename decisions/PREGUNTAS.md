# Preguntas abiertas del proyecto

Fecha: 31/10/2026. Cada pregunta enlaza a su SPEC. La columna **Propuesta** es la
recomendación de las SPECs (Claude/Fable); **no es una decisión**. Respondan por
separado en `decisions/respuestas/<usuario>.md` (ver [README](README.md)).

## Visión y alcance

SPEC: `sdd/specs/vision/SPEC.md`

| ID | Pregunta | Opciones | Propuesta |
| --- | --- | --- | --- |
| V-1 | ¿Qué mostramos en la hackatón? | a) la red con una deliberación real en curso + una herramienta de evidencia del eje A + escrutinio y simulación del AMBA para cerrar · b) sólo escrutinio + simulación · c) otra | a |
| V-2 | ¿Confirmamos el nombre y la marca "CuentaConmigo" para todo el proyecto? | a) sí · b) buscar otro | a |
| V-3 | ¿Qué tipo de alianzas buscamos primero (chequeo, sociedad civil, universidades, observatorios de medios)? | orden de prioridad libre | — |
| V-4 | Posicionamiento legal frente al acompañamiento cívico (Acordada CNE 128/11) | a) herramienta abierta a cualquier fiscal, sin acreditación · b) organización sin fines de lucro y sin vínculo partidario que se acredite · c) las dos | c |

## Red ciudadana

SPEC: `sdd/specs/civic-network/SPEC.md`

| ID | Pregunta | Opciones | Propuesta |
| --- | --- | --- | --- |
| RC-1 | ¿Construimos la red o reutilizamos una plataforma existente? | a) Decidim · b) CONSUL · c) desarrollo propio · d) híbrido: reutilizar + puente propio con la evidencia | d |
| RC-2 | Umbrales de consenso y de consenso transversal | proponer números: participantes verificados mínimos, % de acuerdo, cantidad de fuerzas distintas | — |
| RC-3 | Reglas para partidos y verificación de sus cuentas (incluida la veda) | libre | — |
| RC-4 | Gobernanza: quién opera la red, cómo se eligen moderadores y cómo rinden cuentas | libre | — |
| RC-5 | Identidad: cómo verificar personas sin pedir más datos de los necesarios | ver PP-3 | — |

## Deliberación

SPEC: `sdd/specs/civic-deliberation/SPEC.md`

| ID | Pregunta | Opciones | Propuesta |
| --- | --- | --- | --- |
| DL-2 | ¿Quién modera? | a) voluntarios capacitados + comité diverso de apelación · b) organizaciones aliadas · c) otra | a |
| DL-4 | ¿Exploramos la iniciativa popular (Constitución art. 39) como vía formal? | a) sí, con chequeo legal · b) no por ahora | a |

## Plataformas (eje A)

SPEC: `sdd/specs/platform-accountability/SPEC.md`

| ID | Pregunta | Opciones | Propuesta |
| --- | --- | --- | --- |
| P-1 | ¿Qué plataformas cubrimos primero? | a) Meta, X, TikTok, YouTube + método especial para WhatsApp/Telegram · b) otra selección | a |
| P-2 | ¿Qué herramientas del eje A entran en la hackatón? | a) A1 (archivo de evidencia viral) + A4 mínimo (tablero) · b) otra combinación | a |
| P-3 | Plataforma técnica de A1/A4 (web y backend) | libre; arquitectura sin decidir | — |
| P-4 | ¿Exploramos pedir colectivamente a las plataformas los datos personales de cada participante (derecho de acceso, Ley 25.326)? | a) sí, con opinión legal · b) no | a |

## Protección de participantes

SPEC: `sdd/specs/participant-protection/SPEC.md`

| ID | Pregunta | Opciones | Propuesta |
| --- | --- | --- | --- |
| PP-1 | ¿Rol específico de protección o tarea compartida? | a) crear `protection_officer` · b) repartir entre security, data_protection y electoral_counsel | — |
| PP-2 | Arquitectura frente a la persecución | a) centralizada con minimización · b) federada · c) híbrida | — |
| PP-3 | Verificar personas sin identidad | a) invitación por personas de confianza · b) verificación presencial con organizaciones aliadas · c) credenciales anónimas · d) combinación | — |
| PP-4 | Jurisdicción y alojamiento de la infraestructura y de la entidad | libre | — |
| PP-5 | Organizaciones a contactar y en qué orden | lista priorizada | — |
| PP-6 | ¿Separamos evidencia preservada (original) de copia publicable (derivada, con datos tapados y referencia al hash del original)? | a) sí, con cambio de contrato · b) no publicar imágenes, sólo datos | a |
| PP-7 | ¿Reemplazamos la garantía de anonimato absoluto por criterios verificables (inventario de datos, incautación simulada con un modelo de atacante definido)? | a) sí · b) otra formulación | a |

## Plataforma móvil

SPEC: `sdd/specs/mobile-platform/SPEC.md`

| ID | Pregunta | Opciones | Propuesta |
| --- | --- | --- | --- |
| D-002 | Mecanismo para compartir lógica entre iOS y Android | a) dos apps nativas + contratos · b) Kotlin Multiplatform para el núcleo · c) Skip · d) otra | a ahora, evaluar b |
| D-003 | Backend y recepción central de capturas | libre; fuera del prototipo | — |

## Pantallas de la app (escrutinio)

SPEC: `sdd/specs/app-screens/SPEC.md`

| ID | Pregunta | Opciones | Propuesta |
| --- | --- | --- | --- |
| AS-1 | Navegación global | a) N-A: barra de pestañas con la red al centro · b) N-B: app de escrutinio separada · c) N-C: una app con "modo jornada electoral" | c |
| AS-2 | Flujo de escrutinio | a) F-1 asistente · b) F-2 imagen + campos con OCR · c) F-3 doble carga a ciegas · d) híbrido recomendado (4 pasos + F-2, F-3 opcional después) | d |
| AS-3 | ¿El certificado de escrutinio va preseleccionado? | a) sí · b) no, para no sugerir qué documento fotografiar | — |
| AS-4 | ¿Registramos en el contrato que se leyó el aviso de Boleta Única (`bupWarningAcknowledgedAt`)? | a) sí (cambio de contrato) · b) no | — |
| AS-5 | ¿Doble carga mínima (F-3) en el prototipo? | a) sí: re-tipear votantes y totales a ciegas · b) después | b |
| AS-6 | Campos vacíos | a) botón "Cero" explícito · b) vacío = 0 con aviso | a |
| AS-7 | Aviso de plantilla ficticia en la demo | a) franja amarilla permanente · b) algo menos invasivo | a |
| AS-8 | ¿Mostrar en pantalla si cada valor vino del OCR o se tipeó? | a) sí · b) sólo en el JSON exportado | — |
| AS-9 | ¿Incluir la pantalla "Acerca de" (E-12) en el prototipo? | a) sí · b) después | — |
| AS-10 | Antes de usar la app con documentos reales, ¿consultamos a un abogado o abogada electoral si se puede fotografiar el certificado o el telegrama? | a) sí, es condición para el uso real · b) en paralelo | a |
| AS-11 | Exportación de imágenes con datos de terceros: ¿quién es responsable de los datos, cuánto se conservan y por qué canal se ejercen los derechos? | libre (ver DECISION.md de app-screens) | — |
| AS-12 | ¿Agregamos al contrato `fictitious`, `lockedAt` y `exportedAt`, o se dejan fuera? | a) agregar con contract-change · b) dejar fuera del paquete exportado | — |

## Simulación del AMBA

SPEC: `sdd/specs/amba-simulation/SPEC.md`

| ID | Pregunta | Opciones | Propuesta |
| --- | --- | --- | --- |
| S-1 | Plataforma | a) web estática con MapLibre · b) notebook Python · c) SwiftUI + MapKit | a |
| S-2 | Geografía | a) polígonos oficiales + puntos sintéticos · b) locales de votación reales si hay dataset público | a |
| S-3 | Modelo estadístico | a) estratificado por municipio · b) postestratificado con regresión · c) bayesiano jerárquico | a |

## Organización del trabajo con agentes

SPEC: `sdd/specs/multiagent-system/SPEC.md · sdd/specs/review-pipeline/SPEC.md`

| ID | Pregunta | Opciones | Propuesta |
| --- | --- | --- | --- |
| D-MA-1 | Límite de agentes IA activos en paralelo en el proyecto | a) mantener 2 · b) subir a 4 para revisiones de sólo lectura · c) otro | — |
| D-MA-2 | ¿Qué roles de chequeo activamos ya (además de electoral_counsel)? | platform_accountability, legal, data_protection, neutrality, security, ux, civic_ops… | — |
| D-MA-3 | ¿Buscamos un abogado o abogada electoral humano que valide el marco legal? | a) sí · b) más adelante | a |
| PR-1 | ¿Qué lentes de revisión son obligatorias por tipo de cambio? | a) todas para SPECs de producto; code + legal para código con datos o evidencia · b) otra | a |
| PR-3 | ¿Pedimos una segunda opinión (otro modelo) cuando Astra marca ⛔? | a) sí · b) no | — |

## Preguntas de investigación (no requieren respuesta; las investiga un rol)

- Formato oficial 2027 del telegrama, acta y certificado; identificación impresa de la mesa (telegram-capture Q1–Q3) → electoral_analyst.
- ¿La suma por categoría debe igualar a `votantes`? (telegram-capture Q2) → electoral_analyst.
- Dataset público de locales de votación con coordenadas; definición de AMBA (amba-simulation Q1–Q2) → electoral_analyst.
- ¿Se puede fotografiar el certificado o el telegrama? ¿Un tablero parcial cuenta como "proyección" (art. 71 inc. h)? → abogado/a electoral humano.
