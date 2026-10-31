---
name: review-pipeline
description: Corre el pipeline de revisión con agentes (propuesta de Fable/Claude → validación Astra por lentes → consolidación → decisión del autor). Usar cuando haya que validar una SPEC, pantallas, textos o código con revisores independientes.
---

# Pipeline de revisión

Fuente: `sdd/specs/review-pipeline/SPEC.md`.

1. Skill `sync`.
2. Confirmar que el autor pidió o autorizó la corrida de Astra (consume la cuota de Codex).
3. Respetar el límite de agentes activos: no correr Astra mientras otro subagente está activo.
4. Ejecutar en segundo plano:
   `scripts/review/astra-review.sh <sdd/specs/id> spec ux legal neutrality` (o `code`).
5. Leer `sdd/specs/<id>/checks/*.astra.md`. Commit atómico de los informes + push.
6. Consolidar en `sdd/specs/<id>/DECISION.md`: alternativas, hallazgos ⛔/⚠️ por
   lente, recomendación y preguntas para el autor. Commit + push.
7. Presentar al autor un resumen breve y las decisiones pendientes. No implementar
   hasta que decida. Un ⛔ de la lente `legal` frena la integración.
