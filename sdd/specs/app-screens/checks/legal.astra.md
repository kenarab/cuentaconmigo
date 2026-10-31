<!-- reviewer: Astra (gpt-6-astra via codex exec, read-only) · lens: legal · target: sdd/specs/app-screens · revision: c8b3d20 · date: 2026-10-31 12:48 -03 -->

## 1. Alcance revisado

Revisión independiente de Codex, rol `electoral_counsel`, sobre [sdd/specs/app-screens/SPEC.md](/Users/kenarab/home.agents/git/cuentaconmigo/sdd/specs/app-screens/SPEC.md), revisión **`c8b3d20`**, coincidente con `git rev-parse --short HEAD`.

Base: `AGENTS.md`, rol electoral, `docs/legal/MARCO_LEGAL.md` y secciones relacionadas de `telegram-capture`, `civic-network` y `platform-accountability`. Trabajo de solo lectura; red utilizada únicamente para verificar fuentes legales.

La SPEC es una **propuesta pendiente de aceptación**, no una decisión. Este informe no constituye asesoramiento jurídico profesional.

## 2. Hallazgos

Las ubicaciones siguientes corresponden a `sdd/specs/app-screens/SPEC.md`.

1. **⛔ Autorización de fotografía presentada como resuelta.** E-02, líneas 394–399, afirma “Sí podés escanear” certificado, telegrama y acta; E-03 propone fotografiar el telegrama antes de entregarlo al Correo. Contradice la pregunta abierta del marco legal, §3.2. Recibir un certificado no equivale a una autorización general para fotografiar documentos. Puede inducir intervenciones objetadas por la autoridad de mesa o demoras en su traslado. El aviso sobre BUP es adecuado, pero importar imágenes tampoco garantiza preservar el secreto del voto. **Fuentes:** marco legal §§3.2 y 8; Código Electoral, arts. 71 g, 85, 102, 128, 134 y 141. La fotografía prohibida tiene multa; obstaculización y violación del secreto pueden tener consecuencias penales, según los hechos. [Código Electoral actualizado](https://www.argentina.gob.ar/normativa/nacional/ley-19945-19442/actualizacion).

2. **⛔ Protección y conservación de datos incompletas.** Líneas 322–325, E-09 y E-10: se promete que las fotos no salen de la app, pero se exportan JPEG completos mediante cualquier aplicación de compartir. No pedir nombres no evita tratar firmas, DNI o información que revele opiniones políticas. Tampoco se define responsable, base jurídica, destinatarios, conservación ni canal de derechos. “Nunca borrar” necesita excepciones legales y procedimiento: integridad no significa conservación perpetua. Consecuencia posible: exposición de terceros, reclamos de titulares y actuaciones ante la AAIP. El consentimiento, por sí solo, **no resuelve** las restricciones sobre datos sensibles; debe corregirse esa posible lectura del marco legal §5. **Fuente:** Ley 25.326, arts. 2, 4–7, 9, 11–12 y 14–16. [Texto oficial original consultado](https://www.argentina.gob.ar/normativa/nacional/ley-25326-64790/texto).

3. **⚠️ Falta trasladar la ventana de proyecciones al flujo de compartir.** E-10, líneas 723–729, invita a compartir sin distinguir entrega documental restringida de difusión pública; §9.2 sólo exige que la app no publique ni agregue. Una exportación individual **no es automáticamente una proyección**, pero puede alimentar difusión anticipada. Consecuencia: exposición a multas si se publican o difunden proyecciones durante el comicio y hasta tres horas después del cierre. **Fuentes:** marco legal §4; Código Electoral, arts. 71 h y 128 bis. [Texto actualizado](https://www.argentina.gob.ar/normativa/nacional/ley-19945-19442/actualizacion).

4. **⚠️ El “modo jornada” no acredita cumplimiento de la veda.** Líneas 120–155 y R-05: puede activarse manualmente, permite volver a la red y deja notificaciones pendientes, pero afirma que “respeta la veda”. La igualdad entre partidos es positiva; no resuelve contenidos, horarios ni acreditaciones. Puede mantenerse accesible actividad proselitista durante la ventana restringida. **Fuentes:** Código Electoral, art. 71 e; marco legal §§6–8. La Acordada 128/11 está verificada sólo parcialmente en ese marco: no permite concluir que una app compartida sea incompatible ni que otorgue condición de acompañante acreditado. [Código Electoral](https://www.argentina.gob.ar/normativa/nacional/ley-19945-19442/actualizacion).

5. **⚠️ Control de acciones externas formulado como estado visual.** R-04, líneas 903–904, exige chequeo para marcar una acción “en curso”, pero no explicita impedir su ejecución sin consenso registrado y decisión del autor. La carta a plataformas es sólo un boceto; no hay ejecución demostrada. Consecuencia: implementar un control de etiqueta podría permitir contactos sin autorización o difundir imputaciones sin evidencia suficiente. **Fuentes:** `AGENTS.md`, “Consenso antes que acción”; `civic-network`, criterio 1; `platform-accountability`, A5 y criterio 3. Es principalmente un incumplimiento de gobernanza del proyecto, no un delito establecido por esta revisión.

6. **✅ Salvaguardas bien orientadas.** E-00, E-07 y R-05/R-07 proponen datos ficticios identificados, aceptación humana del OCR, igualdad de presentación partidaria y ausencia de afinidad política en el perfil. Reducen confusión y recopilación innecesaria. **Fuente:** criterios de neutralidad, evidencia y privacidad de `AGENTS.md`. Su implementación no fue verificada.

## 3. Alternativas

Opciones propuestas, ordenadas por menor riesgo inmediato; ninguna decide arquitectura.

| Hallazgo | Alternativa A: costo y riesgo | Alternativa B: costo y riesgo |
|---|---|---|
| **1** | Mantener demostración exclusivamente ficticia y retirar “Sí podés”. **Costo bajo; riesgo bajo**, sin habilitación de campo. | Protocolo validado por abogado electoral: documento, rol, momento, instrucciones locales y exclusión de BUP en cámara/importación. **Costo medio; riesgo residual** de captura indebida. |
| **2** | Usar únicamente documentos sintéticos hasta definir tratamiento y derechos. **Costo bajo; riesgo bajo**, utilidad limitada. | Definir responsable, base jurídica, plazos y supresión; originales restringidos y copias disociadas para difusión, identificadas como derivadas. **Costo alto; riesgo residual** de filtración y reidentificación. |
| **3** | Posponer difusión pública de resultados hasta finalizar la ventana aplicable. **Costo bajo; riesgo bajo**, demora informativa. | Separar entrega documental restringida de publicación, con destinatarios y reglas revisados jurídicamente. **Costo medio; riesgo residual** de reenvíos. |
| **4** | Postergar funciones partidarias durante el piloto de captura. **Costo bajo; riesgo bajo**, menor alcance. | Política transversal de veda para publicaciones, accesos y notificaciones, con calendario validado y roles claramente separados. **Costo alto; riesgo residual** interpretativo. |
| **5** | Mantener modalidades como borradores sin ejecución. **Costo bajo; riesgo bajo**, demora de acciones. | Exigir consenso registrado, revisión legal del contenido final y autorización del autor antes de cada contacto; excluir denuncias coordinadas a plataformas. **Costo medio; riesgo residual** por contenido o destinatario. |

## 4. No verificado

- Implementación, dispositivos, cifrado efectivo, exportaciones y pruebas de campo.
- Instrucciones electorales de 2027, reglas provinciales y texto completo de la Acordada 128/11.
- Texto actualizado de la Ley 25.326: el acceso falló; se consultó su texto original oficial.
- Autorización concreta para fotografiar y uso por autoridades de mesa; encuadre de difusión privada, participación partidaria y tratamiento de datos sensibles. **Requieren abogado o abogada electoral humano**, mediante el autor.
- Cuota disponible: no hay herramienta de consulta.

## 5. Veredicto

**⛔ Bloquear la integración de la propuesta tal como está hasta decisión del autor sobre los hallazgos 1–2, con revisión jurídica humana antes de cualquier uso real.**