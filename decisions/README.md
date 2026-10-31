# Decisiones por consenso (human in the loop)

Las decisiones humanas se toman en **issues de GitHub** con la etiqueta `decision-humana`,
asignados a Alejandro (`kenarab`) y a Andy (`andytow`).

1. Cada issue trae una **plantilla precompletada**: cada pregunta con hasta cinco opciones
   codificadas (★ = propuesta de las SPECs, no vinculante) y **Otro** al final.
2. Cada uno pega la plantilla como **comentario** del issue y marca sus opciones con `[x]`.
3. El coordinador de diseño (skill `hitl-decisions`) comenta la comparación: coincidencias,
   diferencias y alternativas intermedias.
4. El consenso se cierra con un comentario en el issue. El coordinador lo aplica a las
   SPECs y a `CONSENSO.md`, y cierra el issue.

Fuente de las preguntas: [questions.json](questions.json). Vista de lectura:
[PREGUNTAS.md](PREGUNTAS.md). Para regenerar las vistas y los issues:

```sh
python3 scripts/decisions/render.py                    # PREGUNTAS.md
python3 scripts/decisions/render.py --issue N > body.md
gh issue edit N --body-file body.md
```

Nuevas decisiones: plantilla de issue "Decisión humana" (`.github/ISSUE_TEMPLATE/decision.md`).

| Issue | Tema |
| --- | --- |
| #1 | Funcionalidades iniciales y alcance de la hackatón (prioridad alta) |
| #2 | Pantallas y flujo del escrutinio en iPhone (prioridad alta) |
| #3 | Simulación del AMBA (prioridad alta) |
| #4 | Visión, marca y posicionamiento legal |
| #5 | Red ciudadana y deliberación |
| #6 | Herramientas frente a las plataformas |
| #7 | Protección de participantes |
| #8 | Plataforma móvil y backend |
| #9 | Organización del trabajo con agentes |
