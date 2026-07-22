# shellcheck shell=bash
# Lefthook-compatible markdownlint wrapper.
# NOTE: sourced by writeShellApplication — no shebang or set needed.

if [ $# -eq 0 ]; then
  exit 0
fi

classifier_available=false
if command -v is-markdown-agentic >/dev/null 2>&1; then
  classifier_available=true
fi

files=()
for f in "$@"; do
  [ -f "$f" ] || continue
  case "$f" in
    *.md)
      if "$classifier_available" && is-markdown-agentic "$f"; then
        continue
      fi
      files+=("$f")
      ;;
  esac
done

if [ ${#files[@]} -eq 0 ]; then
  exit 0
fi

# Optional config path. Unset -> markdownlint auto-discovers (.markdownlint.*
# walking up from cwd), preserving prior behavior. Set -> use the given file,
# which may live outside the repo root (e.g. a nix out-link), so the config
# need not be a committed root file.
config_args=()
if [ -n "${LEFTHOOK_MARKDOWNLINT_CONFIG:-}" ]; then
  config_args=(--config "$LEFTHOOK_MARKDOWNLINT_CONFIG")
fi

exec markdownlint "${config_args[@]}" "${files[@]}"
