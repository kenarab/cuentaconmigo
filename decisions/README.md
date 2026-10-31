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
