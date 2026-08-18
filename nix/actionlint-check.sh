#!/usr/bin/env bash
set -euo pipefail

: "${out:?out must be set}"
: "${WORKFLOWS_DIR:?WORKFLOWS_DIR must be set}"

mapfile -t workflows < <(find "$WORKFLOWS_DIR" -type f \( -name '*.yml' -o -name '*.yaml' \) | sort)
if [ "${#workflows[@]}" -eq 0 ]; then
  echo "actionlint: no workflow files, nothing to check"
  touch "$out"
  exit 0
fi
actionlint "${workflows[@]}"
echo "actionlint: PASS (${#workflows[@]} files)"
touch "$out"
