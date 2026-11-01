#!/usr/bin/env bash
# Validate a Claude Code skill folder. Bash + coreutils only (works on macOS bash 3.2).
#
# Usage: validate_skill.sh <skill-folder>
# Exit 0 = no errors (warnings allowed), 1 = errors, 2 = bad usage.
set -u

if [ $# -ne 1 ]; then
  echo "Usage: validate_skill.sh <skill-folder>" >&2
  exit 2
fi
folder=$1
if [ ! -d "$folder" ]; then
  echo "ERROR: not a directory: $folder" >&2
  exit 2
fi

errors=()
warns=()
finish() {
  local w e
  if [ "${#warns[@]}" -gt 0 ]; then
    for w in "${warns[@]}"; do echo "WARN  $w"; done
  fi
  if [ "${#errors[@]}" -gt 0 ]; then
    for e in "${errors[@]}"; do echo "ERROR $e"; done
    echo "FAIL"
    exit 1
  fi
  echo "OK"
  exit 0
}

skill_md="$folder/SKILL.md"
if [ ! -f "$skill_md" ]; then
  errors+=("SKILL.md not found")
  finish
fi

# --- frontmatter: must open on line 1 and close on a later line starting with '---'
if [ "$(head -n 1 "$skill_md")" != "---" ]; then
  errors+=("frontmatter: missing opening '---' on line 1")
  finish
fi
end=$(awk 'NR>1 && /^---/ {print NR; exit}' "$skill_md")
if [ -z "$end" ]; then
  errors+=("frontmatter: missing closing '---'")
  finish
fi

name=""
desc=""
unknown=""
while IFS= read -r line; do
  case "$line" in
    "" | [[:space:]]*) continue ;;  # blank or indented (nested) line
    "#"*) continue ;;
  esac
  case "$line" in
    *:*) ;;
    *) errors+=("frontmatter: unparseable line: $line"); finish ;;
  esac
  key=${line%%:*}
  key=${key//[[:space:]]/}
  val=${line#*:}
  val=$(printf '%s' "$val" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/[[:space:]]+#.*$//; s/^["'"'"']+//; s/["'"'"']+$//')
  case "$key" in
    name) name=$val ;;
    description) desc=$val ;;
    license | allowed-tools | metadata) ;;
    *) unknown="$unknown $key" ;;
  esac
done < <(sed -n "2,$((end - 1))p" "$skill_md")

# --- name
if [ -z "$name" ]; then
  errors+=("frontmatter: 'name' missing")
else
  if ! [[ $name =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    errors+=("name '$name': use lowercase letters, digits, single hyphens")
  fi
  if [ "${#name}" -gt 64 ]; then
    errors+=("name is ${#name} chars (max 64)")
  fi
  dir_name=$(basename "$(cd "$folder" && pwd -P)")
  if [ "$name" != "$dir_name" ]; then
    warns+=("name '$name' differs from folder '$dir_name'")
  fi
fi

# --- description
if [ -z "$desc" ]; then
  errors+=("frontmatter: 'description' missing")
else
  if [ "${#desc}" -gt 1024 ]; then
    errors+=("description is ${#desc} chars (max 1024)")
  fi
  case "$desc" in
    *"<"* | *">"*) warns+=("description contains angle brackets") ;;
  esac
  if ! printf '%s' "$desc" | grep -qiE '(^|[^a-zA-Z0-9_])(use|when)([^a-zA-Z0-9_]|$)'; then
    warns+=("description never says when to use the skill; triggering will suffer")
  fi
fi
if [ -n "$unknown" ]; then
  warns+=("unrecognized frontmatter keys:$unknown")
fi

# --- body
body=$(tail -n +"$((end + 1))" "$skill_md")
if [ -z "$(printf '%s' "$body" | tr -d '[:space:]')" ]; then
  errors+=("SKILL.md body is empty")
fi
if grep -q "TODO" "$skill_md"; then
  warns+=("SKILL.md still contains TODO placeholders")
fi
lines=$(wc -l < "$skill_md" | tr -d ' ')
if [ "$lines" -gt 500 ]; then
  warns+=("SKILL.md is $lines lines (aim for <500; move bulk to references/)")
fi

# --- referenced files: `scripts/..`, `references/..`, `assets/..` in backticks
while IFS= read -r ref; do
  [ -z "$ref" ] && continue
  path=$(printf '%s' "$ref" | sed -E 's#[/.,:;]+$##')
  if [ ! -e "$folder/$path" ]; then
    errors+=("referenced file not found: $ref")
  fi
done < <(printf '%s\n' "$body" | grep -oE '`(scripts|references|assets)/[^` ]+`' | tr -d '`' | sort -u)

finish
