<!-- reviewer: Astra (gpt-6-astra via codex exec, read-only) · lens: spec · target: sdd/specs/participant-protection · revision: 271704a · date: 2026-10-31 12:50 -03 -->

## 1. Alcance revisado

Revisión independiente de **Codex**, rol `reviewer`, sobre **`271704a`**, confirmado con `git rev-parse --short HEAD`.

Leídos: `AGENTS.md`, `participant-protection/SPEC.md`, las SPEC de `vision`, `civic-network`, `civic-deliberation`, `telegram-capture` y `mobile-platform`; contrato de captura, ejemplo y vectores; decisiones PP-1–PP-5. Contrastadas las secciones de exportación y equivalencias móviles de `app-screens`, y la verificación registrada de captura.

Trabajo de sólo lectura, sin red ni modificaciones. Excluidas las revisiones no versionadas en `checks/`. Los bloqueos siguientes corresponden a **aceptar la propuesta como especificación implementable**.

## 2. Hallazgos

1. **⛔ Falta distinguir evidencia preservada de copia publicable.**  
   **Ubicación:** [participant-protection/SPEC.md:44](/Users/kenarab/home.agents/git/cuentaconmigo/sdd/specs/participant-protection/SPEC.md:44).  
   Se exige eliminar EXIF antes de compartir, pero no se define si se genera una copia ni cómo se vincula con el original. Modificar el JPEG preservado rompería su hash; conservarlo y exportarlo podría incumplir la protección propuesta. Además, quitar EXIF no elimina nombres o firmas visibles.  
   **Fuente:** `telegram-capture/SPEC.md:35–43,76–80`; `contracts/schemas/capture.schema.json:67–99` sólo representa archivo, hash, fecha y origen, sin relación original–derivado.

2. **⛔ El criterio de anonimato no tiene una prueba de aprobación definida.**  
   **Ubicación:** [participant-protection/SPEC.md:113](/Users/kenarab/home.agents/git/cuentaconmigo/sdd/specs/participant-protection/SPEC.md:113).  
   “No se puede identificar” ante una incautación total es absoluto: no delimita información auxiliar del atacante, claves, respaldos ni contenido que la persona haya revelado. Una revisión de diseño no alcanza para demostrar esa garantía. Podría aprobarse documentalmente sin acreditar el resultado.  
   **Fuente:** la propia SPEC permite revelación voluntaria (`:37–39`), reconoce ataques por cruce de metadatos (`:24`) y aclara que ningún sistema es inmune (`:17`).

3. **⚠️ Falta un alcance de protección verificable para P0 y su equivalente Android.**  
   **Ubicación:** [participant-protection/SPEC.md:109](/Users/kenarab/home.agents/git/cuentaconmigo/sdd/specs/participant-protection/SPEC.md:109), criterios 1–5.  
   La aceptación se centra en servidor, replicación y alianzas; no identifica qué debe cumplir ahora el prototipo local: almacenamiento, respaldos, temporales y exportación. Tampoco define pruebas equivalentes para Android. Esto permite tanto exigir infraestructura ajena a P0 como dar por protegida una app sin comprobar su comportamiento local.  
   **Fuente:** `telegram-capture/SPEC.md:31–33,74–80` excluye servidor, cuentas y Android de P0; `mobile-platform/SPEC.md:18,24–37` establece Android nativo equivalente y contratos compartidos.

4. **⚠️ “Consenso transversal” amplía una regla todavía pendiente.**  
   **Ubicación:** [participant-protection/SPEC.md:55](/Users/kenarab/home.agents/git/cuentaconmigo/sdd/specs/participant-protection/SPEC.md:55).  
   Se exige transversalidad para los consensos en general, sin definición. La red la propone específicamente para acciones que involucran partidos. Aplicarla universalmente podría condicionar iniciativas ciudadanas al respaldo partidario; medirla mediante afinidad individual chocaría con la prohibición de registrarla.  
   **Fuente:** `civic-network/SPEC.md:70–78,94`; `participant-protection/SPEC.md:34–39`.

5. **✅ Las opciones principales siguen identificadas como propuestas.**  
   **Ubicación:** `participant-protection/SPEC.md:3,97–107`.  
   No encontré fundamento para considerar aprobadas PP-1–PP-5 ni confirmadas las alianzas. La tabla dice “candidatas” y exige acuerdo escrito: no corresponde tratarlas como apoyos obtenidos.  
   **Fuente:** `decisions/README.md:20` y respuestas PP todavía vacías en ambas hojas.

## 3. Alternativas

Todas requieren evaluación; no constituyen decisiones.

| Hallazgo | Alternativa A: costo y riesgo | Alternativa B: costo y riesgo |
|---|---|---|
| 1 | Conservar original privado y definir derivado publicable, hashes y trazabilidad. **Costo medio/alto**; riesgo de anonimización incompleta. | Limitar P0 a evidencia ficticia y diferir publicación real. **Costo bajo**; no valida protección en campo. |
| 2 | Acotar adversario, datos accesibles y escenarios con resultados observables. **Costo medio**; queda riesgo de correlación externo. | Mantener el anonimato como objetivo y aceptar controles concretos auditables. **Costo bajo/medio**; no acredita anonimato integral. |
| 3 | Separar aceptación P0/red y definir pruebas de protección equivalentes por plataforma. **Costo medio**; Android seguirá pendiente hasta ejecutarlas. | Acotar expresamente esta SPEC a la red y trasladar protección local a captura/plataforma. **Costo documental bajo**; riesgo de descoordinación entre SPEC. |
| 4 | Remitir a RC-2 y limitar transversalidad a acciones con partidos. **Costo bajo**; su definición continúa pendiente. | Proponer una transversalidad no partidaria con métricas sin afinidad personal. **Costo alto**; riesgo de indicadores indirectos sesgados. |

## 4. No verificado

No ejecuté compilaciones, pruebas de seguridad ni pruebas en dispositivos. La evidencia existente corresponde a `796e5fa`, es autocontrol y deja pendiente el iPhone real. No verifiqué fuentes legales, acuerdos institucionales ni aprobaciones externas al repositorio. No hay herramienta disponible para consultar cuota.

## 5. Veredicto

**⛔ No aceptar todavía como especificación implementable: resolver preservación/publicación y reemplazar la garantía absoluta por criterios verificables.**