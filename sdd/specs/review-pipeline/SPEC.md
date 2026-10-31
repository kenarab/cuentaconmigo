# SPEC · Pipeline de revisión con agentes

Estado: **propuesta en uso inicial (31/10/2026); ajustes pendientes del autor tras la primera corrida.**
Relacionada: [multiagent-system](../multiagent-system/SPEC.md), [AGENTS.md](../../../AGENTS.md).

## Objetivo

Que cada propuesta (SPEC, pantallas, textos, código) pase por revisores
**independientes de quien la escribió**, que los hallazgos queden registrados en el
repo y que el autor decida con las alternativas consolidadas.

## Etapas

```
0. sync ─► 1. propuesta ─► 2. validación independiente ─► 3. consolidación ─► 4. decisión del autor
                                                                                   │
           8. integración ◄─ 7. revisión de código ◄─ 6. verificación ◄─ 5. implementación
```

| Etapa | Quién (modelo efectivo) | Salida |
| --- | --- | --- |
| 0. Sync | planner (Claude Code) | `git pull --rebase`, PRs abiertos |
| 1. Propuesta | **Fable** para UX, textos y alternativas creativas; **Claude** para SPECs técnicas y código | SPEC o diseño con alternativas |
| 2. Validación | **Astra** (`gpt-6-astra` vía Codex CLI, sandbox de sólo lectura), una corrida por lente | `sdd/specs/<id>/checks/<lente>.astra.md` |
| 3. Consolidación | planner (Claude) | `sdd/specs/<id>/DECISION.md`: opciones, hallazgos, recomendación |
| 4. Decisión | **autor** | SPEC aceptada, o cambios pedidos |
| 5. Implementación | Claude (implementer/ios_engineer) | commits atómicos |
| 6. Verificación | executor (sin modelo): `ios/scripts/verify.sh` | resultados en `VERIFICATION.md` |
| 7. Revisión de código | Astra, lente `code` (sólo lectura) | `checks/code.astra.md` |
| 8. Integración | planner: commit + push; los PRs de Andy se revisan con la skill `review-pr` | `main` actualizado |

## Lentes de validación

Cada lente tiene su consigna en `.agents/review-prompts/<lente>.md`:

| Lente | Revisa | Rol equivalente |
| --- | --- | --- |
| `spec` | Coherencia con la visión, los contratos y las otras SPECs; criterios verificables; decisiones no tomadas presentadas como tomadas | reviewer |
| `ux` | Flujos, accesibilidad, uso bajo presión, poca luz, gama baja, offline, claridad del lenguaje | accessibility_ux_analyst |
| `legal` | Riesgos legales y líneas de acción, contra `docs/legal/MARCO_LEGAL.md` | electoral_counsel |
| `neutrality` | Igualdad entre partidos, lenguaje y criterios no partidarios | neutrality_auditor |
| `code` | Diff contra la SPEC, bugs, seguridad, privacidad, tests | reviewer |

## Reglas

- **Independencia:** quien revisa usa un modelo distinto de quien propuso. Si no es
  posible, se registra como autocontrol.
- **Sólo lectura:** Astra corre con `codex exec -s read-only`. El script guarda su
  salida en `~/home.codex/tmp`, la copia a `checks/` con encabezado (modelo, revisión
  revisada, fecha y lente) y el planner la commitea.
- **Formato del informe:** hallazgos ⛔/⚠️/✅ con fuente, al menos dos alternativas
  por cada ⛔/⚠️, y una sección de lo que no se pudo verificar (ver la skill `role-check`).
- **Concurrencia:** límite vigente de dos agentes IA activos en el proyecto (D-MA-1).
  Las lentes corren **en secuencia** en un solo proceso.
- **Costo:** cada corrida de Astra consume la cuota de Codex del autor. Sólo se corre
  cuando el autor lo pide o lo autorizó para esa etapa.
- Un ⛔ de la lente `legal` frena la integración hasta que el autor decida.

## Uso

```sh
scripts/review/astra-review.sh sdd/specs/app-screens spec ux legal neutrality
```

## Decisiones pendientes

- PR-1. ¿Qué lentes son obligatorias por tipo de cambio? Propuesta: todas para
  SPECs de producto; `code` + `legal` para código que toca datos o evidencia.
- PR-2. ¿Se sube el límite de agentes para correr lentes en paralelo? (D-MA-1)
- PR-3. ¿Se agrega una segunda opinión (por ejemplo Claude Opus) cuando Astra marca ⛔?
