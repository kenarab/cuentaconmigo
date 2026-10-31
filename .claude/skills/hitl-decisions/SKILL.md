---
name: hitl-decisions
description: Coordina las decisiones humanas del proyecto en issues de GitHub asignados a kenarab y andytow (abrir, comparar respuestas, aplicar consensos). Usar al empezar cada sesión, cuando surja una decisión pendiente o cuando el usuario pregunte qué hay que decidir.
---

# Decisiones con humanos en el circuito

Rol: `.agents/roles/design_coordinator.md`. SPEC: `sdd/specs/human-in-the-loop/SPEC.md`.

1. Skill `sync`.
2. Estado: `gh issue list --label decision-humana --state open` y
   `git log --oneline -10 -- decisions/respuestas/`.
3. Por cada issue abierto:
   - Si están las dos respuestas en `decisions/respuestas/` y todavía no hay comparación,
     comentar en el issue (`gh issue comment`): coincidencias, diferencias con las razones
     de cada uno y alternativas intermedias.
   - Si en el issue hay un consenso explícito de ambos, aplicarlo a las SPECs y a
     `decisions/CONSENSO.md` (commit atómico "Apply decision #N: …" + push) y cerrar
     el issue con un comentario que enlace el commit.
4. Si aparecen decisiones nuevas en SPECs o revisiones, agregarlas a `decisions/PREGUNTAS.md`
   y a las plantillas de respuestas; abrir un issue sólo si bloquean el trabajo siguiente:
   `gh issue create --label decision-humana --label area:<x> --assignee kenarab --assignee andytow`.
5. Informar al usuario en pocas líneas qué espera a quién.

Nunca decidir por las personas ni cerrar un issue sin el consenso explícito de ambos.
