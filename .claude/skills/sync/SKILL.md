---
name: sync
description: Sincroniza el repo con origin (pull --rebase, PRs abiertos, push). Usar al empezar cualquier tarea, antes de cada push y cuando el usuario pida "sincronizar", "pullear" o "pushear".
---

# Sincronizar con el equipo

El equipo (ver AGENTS.md) trabaja en paralelo: Andy (`andytow`) por PRs y las sesiones
del autor directo a `main`. Sincronizar **todo el tiempo**.

1. `git status --short`: si hay cambios propios sin commitear, primero commitearlos
   atómicamente (rutas explícitas, nunca `git add .`).
2. `git pull --rebase origin main`.
   - Si hay conflicto: resolverlo preservando ambos trabajos. Si la decisión es de
     contenido (SPEC, regla, texto), detenerse y preguntar al autor.
3. `gh pr list --state open`: informar PRs nuevos o actualizados en una línea cada uno.
4. `git push origin main` si hay commits locales.
5. Informar: commits recibidos (`git log --oneline ORIG_HEAD..HEAD` si aplica),
   commits enviados y PRs abiertos.

Identidad de commits de Claude: `alejandro baranek <alejandrobaranek+claude@gmail.com>`
por variables de entorno `GIT_AUTHOR_*`/`GIT_COMMITTER_*`, sin tocar la config global.
