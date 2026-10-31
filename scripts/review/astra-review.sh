#!/usr/bin/env bash
# Runs Astra (gpt-6-astra via Codex CLI, read-only sandbox) over a target, one lens at a
# time, and stores each report in <target>/checks/<lens>.astra.md. Does not commit.
# Usage: scripts/review/astra-review.sh <target-dir-or-file> <lens> [<lens>...]
set -euo pipefail
export TMPDIR="$HOME/home.codex/tmp" TMP="$HOME/home.codex/tmp" TEMP="$HOME/home.codex/tmp"
root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$root"
target="$1"; shift
model="${ASTRA_MODEL:-gpt-6-astra}"
command -v codex >/dev/null || { echo "codex CLI no encontrado; no se instala nada." >&2; exit 1; }
[ -d "$target" ] && checks="$target/checks" || checks="$(dirname "$target")/checks"
mkdir -p "$checks" "$TMPDIR/astra-review"
rev="$(git rev-parse --short HEAD)"
for lens in "$@"; do
  prompt_file=".agents/review-prompts/$lens.md"
  [ -f "$prompt_file" ] || { echo "Lente desconocida: $lens" >&2; exit 2; }
  out="$TMPDIR/astra-review/$(basename "$target")-$lens-$(date +%Y%m%d-%H%M%S).md"
  prompt="$(cat .agents/review-prompts/_common.md)

$(cat "$prompt_file")

Target to review: $target (revision $rev)."
  echo "== Astra · lente $lens · $target @ $rev"
  codex exec -m "$model" -s read-only -C "$root" --skip-git-repo-check -o "$out" "$prompt" >/dev/null
  {
    echo "<!-- reviewer: Astra ($model via codex exec, read-only) · lens: $lens · target: $target · revision: $rev · date: $(date '+%Y-%m-%d %H:%M %Z') -->"
    echo
    cat "$out"
  } > "$checks/$lens.astra.md"
  echo "   -> $checks/$lens.astra.md"
done
