---
name: review-pr
description: Revisa un pull request del equipo (por ejemplo de Andy) contra las SPECs, contratos y reglas de AGENTS.md. Usar cuando haya PRs abiertos o el usuario pida revisar uno.
---

# Revisar un PR

1. Skill `sync`. `gh pr view <n>` y `gh pr diff <n>`.
2. Verificar: SPEC actualizada antes del cambio de comportamiento, contratos y vectores
   si cambia una regla, commits atómicos en inglés, sin datos reales/personales,
   neutralidad, idioma (docs en español + traducción).
3. Si toca `ios/` o `contracts/`: `gh pr checkout <n>` en un worktree aparte
   (no cambiar la rama del checkout principal) y correr la skill `ios-verify`.
4. Informar hallazgos al autor priorizados (archivo:línea, consecuencia, sugerencia).
   Publicar comentarios en el PR sólo si el autor lo pide. **No mergear** sin
   autorización explícita del autor.
