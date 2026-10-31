#!/usr/bin/env bash
# Syncs this checkout with origin/main without losing local work.
# Used by people and agents at the start of every task (and by the Claude Code
# SessionStart hook). Never fails the caller: it only reports.
set -u
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit 0
branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
if [ "$branch" != "main" ]; then
  echo "sync: rama '$branch' (no es main); sólo fetch."
  git fetch --quiet origin 2>/dev/null && echo "sync: fetch OK" || echo "sync: fetch falló (¿sin red?)"
  exit 0
fi
before="$(git rev-parse --short HEAD)"
err="$(mktemp "${TMPDIR:-/tmp}/cc-sync.XXXXXX")"
if git pull --rebase --autostash --quiet origin main 2>"$err"; then
  after="$(git rev-parse --short HEAD)"
  if [ "$before" = "$after" ]; then echo "sync: main al día ($after)"; else echo "sync: main actualizado $before → $after ($(git rev-list --count "$before..$after") commits nuevos)"; fi
else
  echo "sync: ⚠️ no se pudo sincronizar: $(head -2 "$err" | tr '\n' ' ')"
  echo "sync: resolver antes de editar (git status). No se perdió trabajo local."
fi
rm -f "$err"
ahead="$(git rev-list --count origin/main..HEAD 2>/dev/null || echo 0)"
[ "$ahead" != "0" ] && echo "sync: hay $ahead commits locales sin pushear"
exit 0
