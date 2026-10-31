# SPEC · Pipeline con humanos en el circuito (decisiones en issues)

Estado: **definido por el autor el 31/10/2026.** Relacionadas:
[review-pipeline](../review-pipeline/SPEC.md), [decisions/README.md](../../../decisions/README.md).

## Objetivo

Las decisiones humanas del proyecto se toman en **issues de GitHub asignados al autor
(`kenarab`) y a Andy (`andytow`)**. Un agente coordinador de diseño mantiene la lista de
decisiones pendientes, plantea las preguntas en el momento oportuno, consolida las
respuestas y aplica lo decidido. Los agentes proponen y revisan; **las personas deciden**.

## Flujo (interacción definida por el autor, 31/10/2026)

```
SPEC/prototipo ─► revisión de agentes ─► issue "decision-humana" con plantilla precompletada
                                                   │
                   cada persona pega la plantilla como comentario y marca [x]
                                                   │
      SPECs actualizadas ◄── consenso en el issue ◄── comparación del coordinador
```

1. **Apertura:** el coordinador abre un issue por tema con contexto, enlaces y una
   **plantilla precompletada**: cada pregunta con hasta **cinco opciones codificadas**
   (★ marca la propuesta de las SPECs, no vinculante) y **Otro** al final. Fuente única:
   `decisions/questions.json`, que se convierte en issue con `scripts/decisions/render.py`.
2. **Respuestas:** cada persona copia la plantilla, la pega como **comentario** del issue
   y marca sus opciones con `[x]`.
3. **Comparación:** el coordinador comenta qué coincide, qué difiere (con los comentarios
   de cada uno) y alternativas intermedias, con el chequeo de electoral_counsel cuando aplica.
4. **Consenso:** se cierra por comentario en el issue. Ningún agente decide por las personas.
5. **Aplicación:** el coordinador actualiza las SPECs y `decisions/CONSENSO.md` en commits
   atómicos que referencian el issue, y lo cierra.

## Coordinador de diseño (`design_coordinator`)

Rol: [.agents/roles/design_coordinator.md](../../../.agents/roles/design_coordinator.md).
Skill: `hitl-decisions`.

- Mantiene `sdd/specs/roadmap/FEATURES.md` y `decisions/PREGUNTAS.md` al día.
- Decide **qué preguntar y cuándo**: primero lo que bloquea el trabajo siguiente.
  No satura: como máximo unos pocos issues abiertos por persona a la vez.
- Al empezar cada sesión revisa los issues `decision-humana`, las respuestas nuevas
  y los PRs, y avisa qué está bloqueado esperando a quién.
- Lanza el pipeline de revisión (Fable y Astra) cuando una decisión necesita
  insumos, siempre dentro del límite de agentes.
- Nunca cierra una decisión sin el consenso explícito de ambos en el issue.

## Reglas

- No se mencionan con `@` personas que no participan del proyecto.
- Los issues no contienen datos personales ni datos electorales reales.
- Una decisión urgente que bloquea la hackatón se marca `prioridad:alta`.

## Decisión pendiente

- HL-1. ¿Revisamos los issues con una tarea programada (por ejemplo, cada mañana)
  además de al empezar cada sesión? Propuesta: sí, una revisión diaria que resume en
  un comentario qué falta.
