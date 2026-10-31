<!-- reviewer: Astra (gpt-6-astra via codex exec, read-only) · lens: spec · target: sdd/specs/app-screens · revision: c8b3d20 · date: 2026-10-31 12:46 -03 -->

## 1. Alcance revisado

**Revisión:** `c8b3d20` (`git rev-parse --short HEAD`), coincidente con la solicitada; sin cambios locales.

**Revisor:** Codex, rol `reviewer`, independiente de la implementación atribuida a Claude en Git.

Revisado:

- [sdd/specs/app-screens/SPEC.md](/Users/kenarab/home.agents/git/cuentaconmigo/sdd/specs/app-screens/SPEC.md).
- SPECs de `vision`, `civic-network`, `mobile-platform`, `telegram-capture`, `civic-deliberation`, `participant-protection`, `platform-accountability`, `amba-simulation` y `reg-electoral-escrow`.
- `contracts/`: esquema, plantilla, ejemplo y vectores.
- Núcleo `Capture.swift`, `CaptureStore.swift`, tests y verificación registrada de captura; marco legal interno y reglas de revisión.

Los bloqueos siguientes impiden aceptar la propuesta como base de implementación; no impiden conservarla como borrador.

## 2. Hallazgos

1. **⛔ Contrato incompatible con la aceptación exigida.**  
   **Ubicación:** app-screens, E-00, líneas 338–340; E-10, 732–733; 792–794.  
   E-00 exige exportar `template.id` y `fictitious`, pero el esquema admite `templateId`/`templateVersion` y rechaza propiedades adicionales. No se pueden satisfacer simultáneamente ambos criterios. Además, `lockedAt` y `exportedAt` carecen de un mapeo documentado; no alcanza con declarar que sólo cambiaría `bupWarningAcknowledgedAt`.  
   **Fuente:** `contracts/schemas/capture.schema.json`, propiedades y `additionalProperties: false`; mobile-platform, «Contratos primero».

2. **⛔ El bloqueo del núcleo se presenta como probado sin estar cubierto íntegramente.**  
   **Ubicación:** app-screens, E-09, líneas 690–691.  
   Se afirma que editar por código lanza error y está cubierto por tests. Sin embargo, `mesa`, `pages`, `header` y `cells` son propiedades públicas mutables: permiten cambios directos después de confirmar. El test sólo comprueba el rechazo de un setter. Aceptar esa evidencia permitiría conservar modificaciones de una captura supuestamente bloqueada.  
   **Fuente:** `Capture.swift:77`, `CaptureStore.swift:71`, `ContractTests.swift:84`; telegram-capture, «Evidencia y cadena de custodia».

3. **⚠️ Textos propuestos convierten incertidumbres legales en certezas.**  
   **Ubicación:** app-screens, E-02, líneas 394–399; N-C, 139–140.  
   «Sí podés escanear» y «respeta la veda» son afirmaciones concluyentes, aunque las fuentes internas mantienen pendientes la autorización para fotografiar documentos y el comportamiento durante la veda. Podrían llegar a la interfaz como garantías sin revisión. **Este hallazgo es documental, no un dictamen sobre la normativa.**  
   **Fuente:** telegram-capture:92–94; civic-network:87–88; `docs/legal/MARCO_LEGAL.md`, §3.2.

4. **⚠️ E-11 mezcla el prototipo local con un envío futuro.**  
   **Ubicación:** app-screens, E-10/E-11, líneas 724–763.  
   P0 excluye servidor, pero el estado offline remite al texto «se van a enviar cuando haya red». Tampoco define cuándo corresponde marcar «Exportada»: abrir el menú, cancelar y completar una exportación no son equivalentes. La persona podría creer que su evidencia ya salió del teléfono. El criterio de modo avión no especifica condiciones para AirDrop ni destino local en Archivos.  
   **Fuente:** telegram-capture, alcance P0 y privacidad; mobile-platform, D-003 pendiente.

5. **⚠️ La equivalencia Android no cubre datos válidos ni recuperación del flujo.**  
   **Ubicación:** app-screens, E-04 y §6, líneas 476–477 y 812.  
   E-04 admite entrada alfanumérica, pero su equivalente Android prescribe teclado `Number`. El ejemplo contractual usa circuito `0001A`: ese teclado no ofrece una entrada suficiente. La tabla tampoco define aceptación para recuperar el borrador tras recreación de pantalla o terminación del proceso, pese a prometer reanudación en E-01.  
   **Fuente:** `contracts/examples/capture.example.json`, `mesa.circuito`; mobile-platform, requisito de equivalencia nativa.

6. **⚠️ Ordenar argumentos por respuestas contradice el principio contra el orden por interacción.**  
   **Ubicación:** app-screens, R-03, líneas 879–880.  
   Ordenar por cantidad de respuestas vuelve a premiar interacción, aunque no haya «me gusta». Una discusión coordinada podría ganar visibilidad por volumen. La transparencia del criterio no elimina la contradicción con el principio declarado.  
   **Fuente:** civic-network, principio 3; civic-deliberation, «Resistencia a brigadas».

7. **⚠️ Las garantías de recuperación del iPhone no tienen criterios verificables suficientes.**  
   **Ubicación:** app-screens, E-01, líneas 368–373; E-09, 685–687.  
   Se promete retomar el paso y que «no se perdió nada», sin definir persistencia, recuperación tras cierre ni éxito de confirmación ante fallo de disco. El almacenamiento actual comunica errores mediante `lastError`; no acredita esas garantías. Para un prototipo bajo presión y con poca batería, son condiciones de aceptación pendientes, no simples textos de error.  
   **Fuente:** `CaptureStore.swift:40` y `:71`; telegram-capture/VERIFICATION.md, prueba en iPhone pendiente.

8. **✅ Las principales elecciones siguen correctamente identificadas como propuestas.**  
   **Ubicación:** app-screens, encabezado, §§3, 6 y 10.  
   N-C y el flujo híbrido requieren decisión del autor; D-002 y las dependencias Android permanecen pendientes. D-001 sí tiene respaldo documental como decisión tomada. Red y herramientas están fuera de P0: no corresponde exigir su implementación para este prototipo ni interpretar este documento como aceptación de la prioridad de hackatón V-1.  
   **Fuente:** mobile-platform, tabla de decisiones; vision, V-1 pendiente.

## 3. Alternativas

Todas son propuestas para evaluación del autor.

| Hallazgo | Alternativa A: costo y riesgo | Alternativa B: costo y riesgo |
|---|---|---|
| 1 | Ajustar pantallas al contrato vigente y separar metadatos locales. **Costo bajo; riesgo:** menor información autocontenida en la exportación. | Aprobar un cambio contractual con ejemplos y vectores. **Costo medio; riesgo:** compatibilidad y migración. |
| 2 | Encapsular mutaciones y ampliar pruebas de bloqueo. **Costo medio; riesgo:** modificar consumidores del núcleo. | Separar borrador mutable y captura confirmada inmutable. **Costo mayor; riesgo:** refactorización y serialización. |
| 3 | Usar texto descriptivo de documentos admitidos y explicitar lo pendiente. **Costo bajo; riesgo:** menor orientación práctica. | Condicionar esos textos a revisión documentada de `electoral_counsel`. **Costo de revisión; riesgo:** demora. |
| 4 | Retirar E-11 de P0 y conservar exportación manual. **Costo bajo; riesgo:** menos historial visible. | Mantener un historial local con estados de intento, cancelación y resultado observable. **Costo medio; riesgo:** no acreditar recepción externa. |
| 5 | Admitir entrada alfanumérica y agregar casos de reanudación Android. **Costo bajo documental/medio técnico; riesgo:** trabajo pendiente de dispositivo. | Definir capacidades de entrada en la plantilla y escenarios compartidos de conformidad. **Costo medio; riesgo:** ampliar el contrato. |
| 6 | Orden cronológico. **Costo bajo; riesgo:** argumentos valiosos pueden quedar atrás. | Agrupar por tema o tipo de argumento sin contar respuestas. **Costo medio; riesgo:** clasificación discutible. |
| 7 | Especificar guardado y recuperación, con pruebas de interrupción y disco lleno. **Costo medio; riesgo:** ampliar P0. | Acotar las promesas a lo efectivamente guardado y explicitar la recuperación limitada. **Costo bajo; riesgo:** menor utilidad en campo. |

## 4. No verificado

- No ejecuté compilación, tests ni pruebas en dispositivos: esta revisión fue de lectura. La verificación existente corresponde a `796e5fa` y es autocontrol.
- No acredité accesibilidad, rendimiento, OCR, exportación offline ni funcionamiento de campo en iPhone o Android.
- No consulté la red ni revalidé normas: contrasté las afirmaciones con el marco legal interno.
- No verifiqué decisiones del autor fuera del repositorio.
- No hay herramienta disponible para consultar cuota. No modifiqué archivos ni estado de Git.

## 5. Veredicto

**⛔ No aceptar todavía como base de implementación: resolver contrato y bloqueo de capturas, y precisar los criterios pendientes de P0 y Android.**