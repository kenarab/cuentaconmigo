#!/usr/bin/env python3
"""Renders decisions/questions.json into decisions/PREGUNTAS.md and issue bodies.

Usage:
  python3 scripts/decisions/render.py            # rewrite PREGUNTAS.md
  python3 scripts/decisions/render.py --issue N  # print the body of issue N
"""
import json, string, sys, pathlib

ROOT = pathlib.Path(__file__).resolve().parents[2]
DATA = json.loads((ROOT / "decisions/questions.json").read_text())
LETTERS = string.ascii_lowercase


def template(issue):
    lines = [f"## Respuesta de: <tu usuario>", ""]
    for q in issue["questions"]:
        assert len(q["options"]) <= 5, q["id"]
        lines += [f"### {q['id']} · {q['q']}"]
        lines += [f"- [ ] {LETTERS[i]}) {opt}" for i, opt in enumerate(q["options"])]
        lines += ["- [ ] Otro: ", ""]
        if q.get("extra"):
            lines += [q["extra"], ""]
        lines += ["Comentario: ", ""]
    return "\n".join(lines).rstrip() + "\n"


def issue_body(issue):
    return f"""{issue['context']}

## Cómo responder

1. Copiá la plantilla de abajo (botón de copiar del bloque) y pegala como **comentario** en este issue.
2. Marcá una opción por pregunta con `[x]` (o completá **Otro**) y agregá un comentario si querés.
3. Cuando estén las respuestas de los dos, el coordinador de diseño comenta acá la comparación:
   coincidencias, diferencias y alternativas intermedias.
4. Cierran el consenso con un comentario. El coordinador lo aplica a las SPECs y cierra el issue.

{DATA['legend']}. Pipeline: `sdd/specs/human-in-the-loop/SPEC.md`.

## Plantilla

````markdown
{template(issue)}````
"""


def preguntas_md():
    out = ["# Preguntas abiertas del proyecto", "",
           "Fuente: `decisions/questions.json` (generado con `scripts/decisions/render.py`).",
           "Se responden como comentarios en los issues de GitHub asignados a kenarab y andytow.",
           f"{DATA['legend']}.", ""]
    for issue in DATA["issues"]:
        out += [f"## #{issue['number']} · {issue['title'].removeprefix('Decidir: ')}", "", issue["context"], ""]
        for q in issue["questions"]:
            opts = " · ".join(f"{LETTERS[i]}) {o}" for i, o in enumerate(q["options"]))
            out += [f"- **{q['id']}** · {q['q']}: {opts} · Otro"]
        out += [""]
    return "\n".join(out)


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--issue":
        n = int(sys.argv[2])
        print(issue_body(next(i for i in DATA["issues"] if i["number"] == n)), end="")
    else:
        (ROOT / "decisions/PREGUNTAS.md").write_text(preguntas_md())
