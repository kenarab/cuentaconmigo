# Decisiones por consenso

Proceso para resolver las preguntas abiertas entre Alejandro (`kenarab`) y Andy (`andytow`).

1. **Preguntas:** [PREGUNTAS.md](PREGUNTAS.md) reúne todas las decisiones pendientes de
   las SPECs, con opciones y la propuesta (no vinculante) de cada SPEC.
2. **Respuestas por separado:** cada uno completa su archivo sin mirar el del otro:
   - Alejandro → [respuestas/kenarab.md](respuestas/kenarab.md) (commit directo a `main`).
   - Andy → [respuestas/andytow.md](respuestas/andytow.md) (por PR).

   Archivos distintos, así no hay conflictos de merge.
3. **Comparación:** cuando estén los dos, el planner arma `CONSENSO.md`:
   - **Coinciden** → decisión propuesta para cerrar.
   - **Difieren** → se muestran ambas posturas con sus razones, más alternativas
     intermedias y el chequeo de electoral_counsel si aplica.
4. **Consenso:** lo cierran ustedes dos. El planner sólo registra el resultado.
5. **Aplicación:** cada decisión cerrada se aplica a su SPEC en un commit atómico
   (estado "Decidido por el autor y Andy, <fecha>").

Hasta el consenso, las propuestas de las SPECs **no son decisiones**.

## Issues de decisión (GitHub, asignados a kenarab y andytow)

| Issue | Tema | Preguntas |
| --- | --- | --- |
| #1 | Funcionalidades iniciales y alcance de la hackatón (prioridad alta) | FEATURES.md, V-1 |
| #2 | Pantallas y flujo del escrutinio en iPhone (prioridad alta) | AS-1 a AS-12 |
| #3 | Simulación del AMBA (prioridad alta) | S-1 a S-3 |
| #4 | Visión, marca y posicionamiento legal | V-2 a V-4 |
| #5 | Red ciudadana y deliberación | RC-1 a RC-5, DL-2, DL-4 |
| #6 | Herramientas frente a las plataformas | P-1 a P-4 |
| #7 | Protección de participantes | PP-1 a PP-7 |
| #8 | Plataforma móvil y backend | D-002, D-003 |
| #9 | Organización del trabajo con agentes | D-MA-1 a D-MA-3, PR-1, PR-3, HL-1 |

El coordinador de diseño (skill `hitl-decisions`) compara las respuestas en cada issue
y aplica sólo los consensos explícitos.
