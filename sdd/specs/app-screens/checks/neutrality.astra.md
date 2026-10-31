<!-- reviewer: Astra (gpt-6-astra via codex exec, read-only) · lens: neutrality · target: sdd/specs/app-screens · revision: c8b3d20 · date: 2026-10-31 12:48 -03 -->

## 1. Alcance revisado

Revisión independiente por Codex de `sdd/specs/app-screens/SPEC.md`, completo, en **`c8b3d20`**. HEAD del checkout: **`271704a`**, obtenido con `git rev-parse --short HEAD`.

Fuentes de contraste: `AGENTS.md`, instrucciones del rol `reviewer` y, en la revisión objetivo, las SPEC de `civic-network`, `civic-deliberation`, `design/icon/README.md` y el código de `design/cover/cover.svg`.

La SPEC revisada es una **propuesta pendiente del autor**, no una decisión (líneas 3–5). Sin escrituras ni acceso a red.

## 2. Hallazgos

1. **⚠️ Ordenar argumentos por respuestas introduce amplificación por interacción.**  
   **Ubicación:** `sdd/specs/app-screens/SPEC.md:879–880`, R-03.  
   **Consecuencia:** una fuerza con mayor capacidad de generar respuestas podría aumentar la visibilidad de sus argumentos, aunque todos tengan iguales permisos. Excluir votos y “me gusta” no elimina este mecanismo.  
   **Fuente:** contradice el principio de ausencia de algoritmo de interacción de `sdd/specs/civic-network/SPEC.md:33–35`.

2. **⚠️ “Fuerzas de distinto signo” no tiene un criterio verificable.**  
   **Ubicación:** `sdd/specs/app-screens/SPEC.md:882–904`, R-04.  
   **Consecuencia:** queda indeterminado quién clasifica a las fuerzas y cómo se computan alianzas; esa discrecionalidad podría admitir o excluir apoyos de manera desigual. Además, el boceto muestra el requisito sin limitarlo a acciones que involucren partidos. Es un riesgo pendiente de RC-2, no evidencia de favoritismo aplicado.  
   **Fuente:** `sdd/specs/civic-network/SPEC.md:70–78` limita ese requisito a dichas acciones; líneas 94–95 mantienen pendientes los umbrales y reglas.

3. **✅ Igualdad explícita de herramientas y presentación institucional.**  
   **Ubicación:** `sdd/specs/app-screens/SPEC.md:51` y `906–911`, R-05.  
   **Consecuencia:** misma tarjeta, permisos, límites y tamaño de logos; sin destacados ni privilegios para el oficialismo. Es una garantía propuesta, todavía no comprobada en una implementación.  
   **Fuente:** igualdad exigida por `AGENTS.md` y `civic-network/SPEC.md:30–32`.

4. **✅ Ejemplos y textos sin identificación partidaria explícita.**  
   **Ubicación:** `sdd/specs/app-screens/SPEC.md:327–340`, E-00; `563–614`, E-07; `765–770`, E-12.  
   **Consecuencia:** “Lista A/B/C”, etiquetas ficticias y avisos de prototipo evitan atribuir resultados o errores a partidos reales. No encontré nombres, consignas ni acusaciones dirigidas al oficialismo o a otra fuerza.  
   **Fuente:** ejemplos y textos de la propia SPEC.

## 3. Alternativas

| Hallazgo | Alternativa | Costo | Riesgo residual |
|---|---|---|---|
| 1 | Orden cronológico, con desempate documentado. | Bajo | Publicaciones coordinadas pueden ocupar posiciones recientes. |
| 1 | Rotación uniforme entre argumentos, sin usar respuestas como señal. | Medio | Menor continuidad de lectura; requiere reglas auditables. |
| 2 | Computar diversidad institucional con un criterio público de partidos y alianzas, sujeto a aceptación del autor. | Medio | Varias entidades pueden representar un mismo bloque político. |
| 2 | Mantener “distinto signo”, pero definir clasificación, responsables y apelación; limitar su aplicación a las acciones correspondientes. | Alto | Persiste controversia sobre categorías ideológicas. |

## 4. No verificado

- Implementación, permisos efectivos, moderación y distribución real de visibilidad.
- Percepción partidaria de la identidad visual: el README declara colores nacionales, pero esa intención no prueba ausencia de asociaciones. Leí el SVG; no hice una evaluación visual con personas.
- Aceptación posterior del autor y validación legal; esta revisión no sustituye a `electoral_counsel`.
- Cuota disponible: no hay herramienta de consulta.

## 5. Veredicto

**⚠️ Propuesta sin favoritismo partidario explícito; resolver los riesgos de ordenamiento y consenso antes de aprobar esas funciones.**