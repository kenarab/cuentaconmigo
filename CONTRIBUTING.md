# Cómo trabajamos sin pisarnos

Trabajamos varias personas y agentes (Claude Code, Codex, Fable, Astra) en varias
computadoras a la vez. Estas reglas valen para todos. La versión para agentes está en
[AGENTS.md](AGENTS.md).

## 1. Sincronizar siempre al empezar

Antes de **cada tarea** (y antes de cada push):

```sh
scripts/sync.sh        # git pull --rebase --autostash origin main, con un resumen
```

Claude Code lo corre solo al iniciar cada sesión (hook en `.claude/settings.json`).
En Codex o a mano, corrélo vos. Si avisa un conflicto, resolvelo antes de editar.

## 2. Avisar qué vas a tocar

- Tomá la tarea en su **issue**: asignátela y comentá qué archivos o carpetas vas a tocar.
- Si no hay issue y el cambio no es trivial, abrí uno.
- **Un escritor por archivo:** si alguien anunció que está con un archivo, no lo edites.
  Coordiná en el issue.

## 3. Cambios chicos, commit y push enseguida

- Commits **atómicos** (un propósito), mensajes en inglés, rutas explícitas
  (`git add <archivo>`, nunca `git add .`).
- **Push inmediato** después de cada commit: `scripts/sync.sh && git push`.
  Cuanto más tiempo queda algo sin pushear, más probable es el conflicto.
- Archivos generados (por ejemplo `decisions/PREGUNTAS.md` o los cuerpos de los issues):
  se cambia la fuente (`decisions/questions.json`) y se regeneran con su script.

## 4. Trabajo largo: rama y PR

Si algo va a tardar más de una sesión o toca muchos archivos:

```sh
git switch -c <tu-nombre-o-herramienta>/<tema>     # ej. andy/simulacion-amba, claude/flujo-escrutinio
# ... commits atómicos, push de la rama ...
gh pr create --fill
```

Andy integra siempre por PR. Los PRs se revisan contra su SPEC (skill `review-pr`).

## 5. Conflictos

- Nunca descartes trabajo ajeno: resolvé conservando lo de los dos.
- Si el conflicto es de contenido (qué dice una SPEC o una regla), no elijas vos:
  dejalo marcado y consultalo en el issue.
- Nunca `git push --force` sobre `main`.

## 6. Decisiones

Las decisiones humanas se toman en issues `decision-humana` con plantilla
(ver [decisions/README.md](decisions/README.md)).

## 7. Diseño

Ninguna pantalla se implementa sin un prototipo aprobado (`design/prototypes/`).
Flujo completo en [sdd/specs/review-pipeline/SPEC.md](sdd/specs/review-pipeline/SPEC.md).

## Datos que no están en Git

Los datos grandes o con datos personales (`data/private/`, telegramas de ejemplo, recursos
generados de la app) no se suben. En una computadora nueva se reconstruyen todos con:

```sh
scripts/private-data.sh
```

Cada paso baja de la fuente pública que figura en su manifiesto y verifica el SHA-256.
Si agregás datos nuevos fuera de Git, sumá su manifiesto y su script a ese comando.
