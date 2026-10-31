# Configuración de agentes del proyecto

Pedido del autor, 31/10/2026: iniciar CuentaConmigo configurando agentes, commits
atómicos y las prácticas vigentes en sus otros proyectos. Esta entrega configura
instrucciones del repositorio; no instala herramientas ni inicia agentes.

## Referencias y alcance

Se reutiliza la estructura portable de `gorra-hacking` (que a su vez adapta
`archimedianTillings`): `AGENTS.md` como fuente única, `CLAUDE.md` que lo importa,
`.agents/manifest.json`, roles, plantilla de tarea y `sdd/agents.json`.
Los roles se adaptan al dominio: se reemplazan los de cliente iOS/BLE por
`capture_engineer`, `electoral_analyst` y `trust_safety_analyst`. No se copian
modelos, permisos, credenciales ni reglas de producto de otros proyectos.

`git fetch origin` 31/10/2026 11:41 -03: correcto; el origin estaba vacío.

## Criterios de aceptación

1. Catálogo con ocho roles e instrucciones existentes; ejecutor sin modelo,
   revisor y analistas de sólo lectura, integración Git sólo del planner.
2. `AGENTS.md` única fuente común; `CLAUDE.md` la importa sin duplicar reglas.
3. Concurrencia, tareas, modelos, revisión y traspaso explícitos; sin invocaciones,
   instalaciones ni selección silenciosa de proveedor/modelo.
4. Reglas del dominio: neutralidad, evidencia inmutable, datos personales fuera de
   Git, arquitectura e instalaciones sujetas a decisión del autor.
5. Registro SDD coherente con el manifiesto y su hash.

## Resultado comprobado · 31/10/2026

- JSON válidos; ocho roles con instrucciones existentes; ningún modelo fijado.
- Hash SHA-256 del manifiesto coincide con `sdd/agents.json` y los roles son idénticos.
- Sólo `planner` integra Git; `reviewer` read-only; `executor` sin modelo.
- `.private/`, `.runtime/`, `data/private/` y `.env` comprobados como ignorados.
- Autocontrol estructural/documental, sin revisión independiente. Ningún agente
  fue iniciado por esta entrega.
