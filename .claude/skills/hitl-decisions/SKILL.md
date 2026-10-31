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
   - Leer los comentarios (`gh issue view N --comments`). Las respuestas son la plantilla
     pegada con opciones marcadas `[x]`. Si están las de kenarab y andytow y todavía no hay
     comparación, comentar (`gh issue comment`): coincidencias, diferencias con los
     comentarios de cada uno y alternativas intermedias.
   - Si en el issue hay un consenso explícito de ambos, aplicarlo a las SPECs y a
     `decisions/CONSENSO.md` (commit atómico "Apply decision #N: …" + push) y cerrar
     el issue con un comentario que enlace el commit.
4. Si aparecen decisiones nuevas, agregarlas a `decisions/questions.json` (máximo cinco
   opciones codificadas + Otro; ★ en la propuesta), regenerar con
   `scripts/decisions/render.py` y actualizar o abrir el issue
   (`gh issue create --label decision-humana --label area:<x> --assignee kenarab --assignee andytow --body-file …`).
   Abrir issues sólo para lo que bloquea el trabajo siguiente.
5. Informar al usuario en pocas líneas qué espera a quién.

Nunca decidir por las personas ni cerrar un issue sin el consenso explícito de ambos.
