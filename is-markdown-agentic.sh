# shellcheck shell=bash
# Detect whether a markdown file path matches agentic patterns.
# Agentic files: agent/, .claude/, files/commands/, SPEC.md, CLAUDE.md, PROMPT.md
# Exits 0 (agentic), 1 (non-agentic).
# NOTE: sourced by writeShellApplication — no shebang or set needed.

if [ $# -ne 1 ]; then
  exit 1
fi

case "$1" in
  agent/* | */agent/*) exit 0 ;;
  .claude/* | */.claude/*) exit 0 ;;
  files/commands/* | */files/commands/*) exit 0 ;;
  SPEC.md | */SPEC.md) exit 0 ;;
  CLAUDE.md | */CLAUDE.md) exit 0 ;;
  PROMPT.md | */PROMPT.md) exit 0 ;;
esac

exit 1
