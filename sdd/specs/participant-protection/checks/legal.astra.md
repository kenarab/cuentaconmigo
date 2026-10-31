<!-- reviewer: Astra (gpt-6-astra via codex exec, read-only) · lens: legal · target: sdd/specs/participant-protection · revision: 271704a · date: 2026-10-31 12:50 -03 -->

## 1. Alcance revisado

**Revisor:** Codex, rol `electoral_counsel`, sin intervención en la implementación. Revisión documental de solo lectura.

**Revisión:** `git rev-parse --short HEAD` → **`271704a`**, coincidente con la solicitada.

Archivos leídos:

- `AGENTS.md`, `.agents/roles/electoral_counsel.md` y `.agents/templates/task.md`.
- `docs/legal/MARCO_LEGAL.md`, base preliminar, no dictamen profesional.
- [sdd/specs/participant-protection/SPEC.md](/Users/kenarab/home.agents/git/cuentaconmigo/sdd/specs/participant-protection/SPEC.md), denominada **SPEC** abajo.
- Como contexto: `sdd/specs/{vision,civic-network,telegram-capture,platform-accountability}/SPEC.md`.

La SPEC es **una propuesta**; PP-1 a PP-5 siguen pendientes. Los hallazgos evalúan su diseño, no acreditan infracciones efectivamente cometidas.

## 2. Hallazgos

1. **⛔ Protección incompleta de personas y datos sensibles.**  
   **Ubicación:** SPEC:34–46, 55–57 y 113–114. Ocultar al aportante y quitar EXIF deja visibles nombres, firmas y personas mencionadas. Los respaldos y la detección de coordinación también podrían revelar opiniones políticas asociadas a seudónimos identificables. Consecuencia: exposición de participantes y terceros, reclamos de titulares y eventuales sanciones administrativas. El consentimiento no basta por sí solo para superar las restricciones sobre datos sensibles; debe corregirse esa posible lectura de `MARCO_LEGAL.md`, §5. **Fuente:** [Ley 25.326, arts. 2, 7, 9 y 31 — texto original oficial consultado](https://www.argentina.gob.ar/normativa/nacional/ley-25326-64790/texto). La aplicación al diseño es una interpretación que requiere abogado/a humano/a.

2. **⛔ Réplicas abiertas sin condiciones de publicación ni corrección.**  
   **Ubicación:** SPEC:47–49, 91, 106 y 115. Replicar datos “públicos” sin permiso puede propagar datos personales y frustrar el retiro rápido prometido. Que algo esté publicado no demuestra disociación. Faltan responsable, procedimiento de derechos y condiciones para destinos internacionales. Consecuencia: persistencia del daño y exposición del operador a reclamos, aun después de corregir su servidor. **Fuente:** [Ley 25.326, arts. 6, 11, 12, 14 y 16](https://www.argentina.gob.ar/normativa/nacional/ley-25326-64790/texto). La arquitectura sigue pendiente: corresponde fijar requisitos antes de elegirla.

3. **⚠️ Saneamiento de imágenes sin distinguir originales y copias.**  
   **Ubicación:** SPEC:40–46 y 88–90. No aclara si eliminar metadatos afecta sólo la copia compartida. Aplicarlo al original podría romper hashes y perder procedencia; conservar todo indefinidamente tampoco resuelve la privacidad. Consecuencia: evidencia menos verificable y conflicto entre custodia, retención y atención de órdenes válidas. **Fuente:** `AGENTS.md`, regla de originales inmutables; `telegram-capture/SPEC.md:35–43`; [Ley 25.326, art. 4.7](https://www.argentina.gob.ar/normativa/nacional/ley-25326-64790/texto). No equivale automáticamente a falsificación documental.

4. **⚠️ La protección del aportante no habilita la fotografía.**  
   **Ubicación:** SPEC:44–46; dependencia de `telegram-capture/SPEC.md:88–98`. Ese módulo ya advierte sobre BUP y deja abierta la autorización para fotografiar certificados o telegramas; falta incorporar esa condición al circuito general de evidencia. El derecho del fiscal a recibir un certificado no constituye autorización expresa para fotografiar cualquier documento. Consecuencia: multas por fotos de BUP y eventual responsabilidad penal por vulnerar el secreto del voto. **Fuente:** [Código Electoral, arts. 71.g, 102, 128 y 141–142](https://www.argentina.gob.ar/normativa/nacional/ley-19945-19442/actualizacion). Requiere validación humana antes del uso en campo.

5. **⚠️ Publicación y continuidad sin reglas operativas de veda.**  
   **Ubicación:** SPEC:44–51, 94 y 115. Los agregados y espejos no incorporan el embargo previsto en captura; la neutralidad tampoco resuelve cómo moderar cuentas partidarias. Consecuencia: difusión anticipada de proyecciones o proselitismo prohibido. El Código prohíbe proyecciones durante el comicio y hasta tres horas después; el art. 71.e regula proselitismo desde 48 horas antes hasta el cierre. **Fuente:** [Código Electoral, arts. 71.e/h y 128 bis](https://www.argentina.gob.ar/normativa/nacional/ley-19945-19442/actualizacion). Que un agregado concreto constituya proyección requiere interpretación profesional; no corresponde prohibir toda deliberación cívica por defecto.

6. **✅ Alianzas y acciones hacia plataformas tienen límites institucionales adecuados.**  
   **Ubicación:** SPEC:67–84; `civic-network/SPEC.md:27–31, 77–78`; `platform-accountability/SPEC.md:14–23`. Las organizaciones son candidatas, no aliadas confirmadas. Rigen consentimiento escrito, contacto por el autor, consenso y chequeo legal previo; se excluyen denuncias masivas como estrategia. **Consecuencia:** reduce atribuciones falsas de respaldo y actuaciones no autorizadas. Mantener esos requisitos también para campañas públicas de defensa del proyecto. **Fuente:** documentos citados y `AGENTS.md`; son reglas internas, no inmunidad jurídica.

## 3. Alternativas

Ordenadas de menor a mayor riesgo residual; ambas son propuestas.

| Hallazgo | Alternativa A: costo y riesgo | Alternativa B: costo y riesgo |
|---|---|---|
| **1** | Publicar únicamente cifras y derivados revisados, sin perfiles políticos individuales. **Costo:** revisión y menor detalle. **Riesgo:** reidentificación residual. | Custodiar originales necesarios con acceso restringido y fundamento jurídico específico. **Costo:** alto, legal y operativo. **Riesgo:** exposición de datos sensibles. |
| **2** | Replicar libremente sólo código y datos efectivamente disociados. **Costo:** limitar el conjunto exportable. **Riesgo:** errores de disociación. | Réplicas gestionadas con responsables, correcciones y encuadre internacional documentados. **Costo:** alto. **Riesgo:** copias fuera de control. |
| **3** | Separar original inmutable y derivado saneado, con hashes y retención justificada. **Costo:** medio. **Riesgo:** custodiar información identificatoria. | Conservar originales en origen y recibir sólo derivados. **Costo:** coordinación. **Riesgo:** pérdida de disponibilidad y menor verificabilidad. |
| **4** | Usar material ficticio hasta resolver la habilitación de campo. **Costo:** demora. **Riesgo legal:** bajo. | Priorizar certificados recibidos por fiscales, con protocolo validado para el distrito, sin BUP ni interferencia. **Costo:** capacitación y consulta humana. **Riesgo:** instrucciones locales pendientes. |
| **5** | Embargar resultados potencialmente proyectivos en todas las salidas y moderar contenido electoral con reglas iguales. **Costo:** medio. **Riesgo:** filtraciones. | Suspender temporalmente publicaciones nuevas no revisadas durante las ventanas aplicables. **Costo:** menor participación. **Riesgo:** restricción excesiva del debate legítimo. |

## 4. No verificado

- Implementación, resistencia a incautaciones, disociación efectiva y cumplimiento por espejos.
- Calendario e instrucciones electorales de 2027, normas provinciales y autorización concreta de fotografías.
- Texto completo vigente de la Acordada 128/11: una alianza no acredita por sí sola como observador.
- La fuente consolidada de la Ley 25.326 falló; se consultó el texto original oficial, sin verificar exhaustivamente reformas y reglamentación.
- No se consultó cuota: no hay herramienta disponible. No hubo modificaciones ni acceso de red fuera de fuentes legales.

**No es asesoramiento jurídico profesional.** Los bloqueos y las preguntas de campo deben pasar, mediante el autor, a un/a abogado/a electoral humano/a.

## 5. Veredicto

**⛔ No integrar la propuesta como diseño aprobado hasta resolver los hallazgos 1–2; mantener pendientes las habilitaciones operativas de 3–5.**