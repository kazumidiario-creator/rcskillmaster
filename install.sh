#!/bin/sh
# install.sh - cria symlinks das skills deste pacote nas pastas que Claude Code e Codex leem.
# Uso (de qualquer pasta):
#   sh <clone>/install.sh [--only claude|codex] [--skill a,b] [--exclude a,b] [--project <pasta do projeto>] [--force-guide]
# --project copia templates/SKILLS.md para <projeto>/.ai/SKILLS.md se ainda nao existir (e o guia que o rcskillmaster le); --force-guide sobrescreve.
# Pasta ou link que ja existe no destino e deixado em paz. Os links apontam para ESTE clone: nao apague nem mova a pasta depois.
set -e
raiz="$(cd "$(dirname "$0")" && pwd)"
only=all; so_skills=""; excluir=""; projeto=""; forcar_guia=0
while [ $# -gt 0 ]; do
  case "$1" in
    --only)        shift; [ $# -gt 0 ] || { echo "--only exige um valor: all|claude|codex" >&2; exit 2; }; only="$1" ;;
    --skill)       shift; [ $# -gt 0 ] || { echo "--skill exige um valor: nome[,nome]" >&2; exit 2; }; so_skills="$1" ;;
    --exclude)     shift; [ $# -gt 0 ] || { echo "--exclude exige um valor: nome[,nome]" >&2; exit 2; }; excluir="$1" ;;
    --project)     shift; [ $# -gt 0 ] || { echo "--project exige a pasta do projeto" >&2; exit 2; }; projeto="$1" ;;
    --force-guide) forcar_guia=1 ;;
    *) echo "argumento desconhecido: $1" >&2; exit 2 ;;
  esac
  shift
done
case "$only" in all|claude|codex) ;; *) echo "valor invalido para --only: $only (use all|claude|codex)" >&2; exit 2 ;; esac
[ -n "$HOME" ] || HOME="$(cd ~ 2>/dev/null && pwd)"
[ -n "$HOME" ] || { echo "HOME nao definido; exporte HOME antes de rodar" >&2; exit 2; }
ls -d "$raiz"/skills/*/ >/dev/null 2>&1 || { echo "nenhuma skill em $raiz/skills" >&2; exit 2; }

# valida nome a nome as listas --skill e --exclude
valida_lista() {  # $1 = rotulo, $2 = lista separada por virgula
  [ -z "$2" ] && return 0
  faltando=""; oldifs=$IFS; IFS=','
  for n in $2; do IFS=$oldifs; [ -d "$raiz/skills/$n" ] || faltando="$faltando $n"; IFS=','; done
  IFS=$oldifs
  [ -z "$faltando" ] || { echo "$1: skill nao encontrada em $raiz/skills:$faltando" >&2; exit 2; }
}
valida_lista "--skill" "$so_skills"; valida_lista "--exclude" "$excluir"

quer_skill() {  # 0 se a skill $1 entra na instalacao
  if [ -n "$excluir" ]; then case ",$excluir," in *",$1,"*) return 1 ;; esac; fi
  [ -z "$so_skills" ] && return 0
  case ",$so_skills," in *",$1,"*) return 0 ;; *) return 1 ;; esac
}

destinos=""
if [ "$only" = all ] || [ "$only" = claude ]; then destinos="$destinos|$HOME/.claude/skills"; fi
if [ "$only" = all ] || [ "$only" = codex ]; then destinos="$destinos|$HOME/.agents/skills|$HOME/.codex/skills"; fi

criadas=0; mantidas=0; quebrados=0
IFS='|'
for destino in $destinos; do
  unset IFS
  [ -z "$destino" ] && { IFS='|'; continue; }
  mkdir -p "$destino"
  for s in "$raiz"/skills/*/; do
    [ -d "$s" ] || continue
    nome="$(basename "$s")"; alvo="$destino/$nome"
    quer_skill "$nome" || continue
    if [ -L "$alvo" ] && [ ! -e "$alvo" ]; then echo "aviso: link quebrado, remova e rode de novo: $alvo -> $(readlink "$alvo")" >&2; quebrados=$((quebrados+1)); continue; fi
    if [ -e "$alvo" ] || [ -L "$alvo" ]; then echo "aviso: ja existe, deixado em paz: $alvo"; mantidas=$((mantidas+1)); continue; fi
    ln -s "${s%/}" "$alvo"; echo "symlink: $alvo -> ${s%/}"; criadas=$((criadas+1))
  done
  IFS='|'
done
unset IFS
if [ "$criadas" -eq 0 ] && [ "$mantidas" -eq 0 ]; then echo "nenhuma skill instalada (a combinacao de --skill e --exclude nao deixou nenhuma)" >&2; exit 2; fi

if [ -n "$projeto" ]; then
  [ -d "$projeto" ] || { echo "pasta do projeto nao existe: $projeto" >&2; exit 2; }
  guia="$(cd "$projeto" && pwd)/.ai/SKILLS.md"
  if [ -e "$guia" ] && [ "$forcar_guia" -eq 0 ]; then echo "aviso: guia ja existe, nao sobrescrevo (use --force-guide para trocar): $guia"
  else mkdir -p "$(dirname "$guia")"; cp "$raiz/templates/SKILLS.md" "$guia"; echo "guia criado ou sobrescrito: $guia (revise as fichas: apague as das skills que voce nao instalou)"; fi
fi
echo "Pronto: $criadas links criados, $mantidas ja existiam, $quebrados quebrados. Os links apontam para $raiz/skills (nao apague nem mova o clone)."
echo "Abra uma sessao nova do Claude Code ou do Codex na raiz do projeto e confira com /rcskillmaster (Claude) ou \$rcskillmaster (Codex)."
