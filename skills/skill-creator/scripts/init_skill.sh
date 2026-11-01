#!/usr/bin/env bash
# Scaffold a new skill folder. Bash + coreutils only (works on macOS bash 3.2).
#
# Usage: init_skill.sh <skill-name> [--path DIR] [--dirs scripts references assets]
# Creates DIR/<skill-name>/SKILL.md from a template. Refuses to overwrite.
set -eu

die() { echo "ERROR: $1" >&2; exit "${2:-1}"; }
usage() { echo "Usage: init_skill.sh <skill-name> [--path DIR] [--dirs scripts references assets]" >&2; exit 2; }

name=""
path="."
dirs=()
mode=""
while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help) usage ;;
    --path) [ $# -ge 2 ] || usage; path=$2; mode=""; shift 2 ;;
    --dirs) mode=dirs; shift ;;
    -*) usage ;;
    *)
      if [ "$mode" = dirs ]; then
        case "$1" in
          scripts | references | assets) dirs+=("$1") ;;
          *) die "invalid --dirs value '$1' (choose scripts, references, assets)" 2 ;;
        esac
      elif [ -z "$name" ]; then
        name=$1
      else
        usage
      fi
      shift
      ;;
  esac
done
[ -n "$name" ] || usage

if ! [[ $name =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || [ "${#name}" -gt 64 ]; then
  die "invalid name '$name': use lowercase letters, digits, single hyphens, max 64 chars"
fi

path=${path/#\~/$HOME}
root="$path/$name"
[ ! -e "$root" ] || die "$root already exists; not overwriting"

title=$(printf '%s' "$name" | tr - ' ' | awk '{for (i = 1; i <= NF; i++) $i = toupper(substr($i, 1, 1)) substr($i, 2)} 1')

mkdir -p "$root"
cat > "$root/SKILL.md" <<EOF
---
name: $name
description: TODO what the skill does. Use when TODO the situations and phrases that should trigger it.
---

# $title

TODO one or two lines on the purpose.

## Steps

1. TODO first step
2. TODO next step

## Output

TODO describe the expected output, with a short example if format matters.
EOF
for d in ${dirs[@]+"${dirs[@]}"}; do mkdir -p "$root/$d"; done

echo "Created $root/SKILL.md. Fill in every TODO, then run validate_skill.sh on the folder."
