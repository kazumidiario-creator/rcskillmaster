#!/bin/sh
# uninstall.sh - remove SO os symlinks das skills deste pacote em ~/.claude/skills, ~/.agents/skills e ~/.codex/skills.
# Uso: sh <clone>/uninstall.sh [--project <pasta do projeto>]
# Nunca apaga pasta real: um destino que nao seja symlink e deixado em paz, com aviso. --project apaga tambem <projeto>/.ai/SKILLS.md.
set -e
raiz="$(cd "$(dirname "$0")" && pwd)"
projeto=""
while [ $# -gt 0 ]; do
  case "$1" in
    --project) shift; [ $# -gt 0 ] || { echo "--project exige a pasta do projeto" >&2; exit 2; }; projeto="$1" ;;
    *) echo "argumento desconhecido: $1" >&2; exit 2 ;;
  esac
  shift
done
[ -n "$HOME" ] || { echo "HOME nao definido" >&2; exit 2; }
removidos=0
for destino in "$HOME/.claude/skills" "$HOME/.agents/skills" "$HOME/.codex/skills"; do
  for s in "$raiz"/skills/*/; do
    [ -d "$s" ] || continue
    alvo="$destino/$(basename "$s")"
    [ -e "$alvo" ] || [ -L "$alvo" ] || continue
    if [ -L "$alvo" ]; then rm "$alvo"; echo "removido: $alvo"; removidos=$((removidos+1))
    else echo "aviso: nao e link, deixado em paz: $alvo" >&2; fi
  done
done
if [ -n "$projeto" ] && [ -e "$projeto/.ai/SKILLS.md" ]; then rm "$projeto/.ai/SKILLS.md"; echo "removido: $projeto/.ai/SKILLS.md"; fi
echo "Pronto: $removidos links removidos. O clone e as skills reais continuam onde estavam."
