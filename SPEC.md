# SPEC — nix-lefthook-markdownlint

## §D — Description

A Nix flake that packages a lefthook-compatible markdownlint wrapper (`lefthook-markdownlint`) for use as a git pre-commit and pre-push hook. The wrapper filters `.md` files from staged or pushed file arguments, skips missing or non-markdown files gracefully, and delegates to `markdownlint-cli` for the actual lint. It is consumed either as a lefthook remote (recommended) or as a flake input added to a project's devShell. Target users are Nix-based projects that enforce markdown style via lefthook git hooks, with cross-platform support for Linux and macOS on both arm64 and x86_64.

## §V — Invariants

1. `lefthook-markdownlint` exits 0 when invoked with no arguments.
2. `lefthook-markdownlint` exits 0 when none of the arguments are `.md` files.
3. Missing files in the argument list are skipped silently (no error).
4. Valid markdown files pass (exit 0); invalid markdown files fail (exit non-zero).
5. Non-`.md` files in a mixed argument list are filtered out before linting.
5a. Agentic markdown files (`agent/`, `.claude/`, `files/commands/`, `SPEC.md`, `CLAUDE.md`, `PROMPT.md`) are skipped — they are handled by `nix-lefthook-markdownlint-agentic`.
6. `LEFTHOOK_MARKDOWNLINT_CONFIG` overrides the config file passed to markdownlint; the config path may live outside the repo root.
7. When `LEFTHOOK_MARKDOWNLINT_CONFIG` is unset, markdownlint uses its default config discovery (`.markdownlint.*` walking up from cwd).
8. The dev shell (`dev.sh`) sets `BATS_LIB_PATH` from the `@BATS_LIB_PATH@` placeholder injected by `flake.nix`.
9. The dev shell runs `lefthook install` only when `.git/hooks/pre-commit` does not exist.
10. The flake builds on all four supported systems: `aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`, `aarch64-linux`.
11. CI runs on both Linux (`ubuntu-latest`) and macOS (`macos-latest`).
12. Every lefthook command appears in both `pre-commit` and `pre-push` sections.
13. Every lefthook command has a timeout (default 30s via `LEFTHOOK_MARKDOWNLINT_TIMEOUT`).
14. All shell scripts pass shellcheck (enforced by lefthook remote checks).
15. All Nix files pass statix, deadnix, and nixfmt (enforced by lefthook remote checks).
16. Every shell script has a corresponding bats unit test file under `tests/unit/`.

## §I — Interfaces

### CLI

| Command                 | Synopsis                           | Description                                                                                                          |
| ----------------------- | ---------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `lefthook-markdownlint` | `lefthook-markdownlint [file ...]` | Filter `.md` files from args, skip agentic files, run `markdownlint` on the rest. Exit 0 if no files match.          |
| `is-markdown-agentic`   | `is-markdown-agentic <path>`       | Exit 0 if path matches agentic patterns (`agent/`, `.claude/`, `files/commands/`, `SPEC.md`, `CLAUDE.md`, `PROMPT.md`). |

### Environment variables

| Variable                        | Default              | Description                                                                                    |
| ------------------------------- | -------------------- | ---------------------------------------------------------------------------------------------- |
| `LEFTHOOK_MARKDOWNLINT_TIMEOUT` | `30`                 | Timeout in seconds for the markdownlint lefthook command.                                      |
| `LEFTHOOK_MARKDOWNLINT_CONFIG`  | _(unset)_            | Path to a markdownlint config file. When unset, markdownlint auto-discovers `.markdownlint.*`. |
| `BATS_LIB_PATH`                 | _(set by dev shell)_ | Path to bats helper libraries; injected by `dev.sh` via `@BATS_LIB_PATH@` placeholder.         |

### Nix flake outputs

| Output                                  | Description                                                                                                   |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `packages.<system>.default`             | `writeShellApplication` wrapping `lefthook-markdownlint.sh` with `markdownlint-cli` and `is-markdown-agentic` on `PATH`. |
| `packages.<system>.is-markdown-agentic` | `writeShellApplication` wrapping `is-markdown-agentic.sh` — agentic-file path detector.                       |
| `devShells.<system>.default` | Development shell with all tools: bats (with libs), lefthook, linter wrappers, coreutils, git, nix, parallel. |
| `devShells.<system>.ci`      | Alias for `default`; used by CI.                                                                              |

### Config files

| File                                   | Format | Purpose                                                                          |
| -------------------------------------- | ------ | -------------------------------------------------------------------------------- |
| `lefthook.yml`                         | YAML   | Full lefthook config with remotes and local markdownlint commands.               |
| `lefthook-remote.yml`                  | YAML   | Minimal config consumed by other repos via lefthook remote.                      |
| `.markdownlint.yml`                    | YAML   | Markdownlint rules: MD013 (line length) and MD024 (duplicate headings) disabled. |
| `.yamllint.yml`                        | YAML   | Yamllint rules: default set, truthy key check off, line-length disabled.         |
| `.editorconfig`                        | INI    | UTF-8, LF endings, 2-space indent, trim trailing whitespace, final newline.      |
| `config/lefthook/file_size_limits.yml` | YAML   | Per-extension file size limits for the file-size-check lefthook command.         |

### Lefthook remote integration

Other repos add this to their `lefthook.yml`:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-markdownlint
    ref: main
    configs:
      - lefthook-remote.yml
```

## §T — Tasks

| status | id  | goal                                                                                                              |
| ------ | --- | ----------------------------------------------------------------------------------------------------------------- |
| `x`    | T1  | Add `watch_file` entries to `.envrc` for `flake.nix`, `dev.sh`, and nix modules per direnv/modularity skills      |
| `x`    | T2  | Add `nix/direnv.sh` extraction and wire it into `.envrc` to satisfy the nix/modularity skill pattern              |
| `x`    | T3  | Add bats test for timeout behavior (verify the wrapper respects `LEFTHOOK_MARKDOWNLINT_TIMEOUT`)                  |
| `x`    | T4  | Add bats test covering symlink edge case (`.md` symlink pointing to valid/invalid file)                           |
| `x`    | T5  | Align `actions/checkout` version in `update-pins.yml` (v4) with `ci.yml` (v6)                                     |
| `x`    | T6  | Extract the inline `SCANNER=` shell fragment in the `lefthook-nix-no-embedded-shell` wrapper to a separate script |
| `x`    | T7  | Add a bats test for `lefthook-remote.yml` validating its YAML structure and required keys                         |
| `x`    | T8  | Add `flake.lock` tracking rationale to README (currently gitignored; `nixpkgs-lock` pin provides reproducibility) |
| `x`    | T9  | Add `markdownlint` glob to the `lefthook-remote.yml` `pre-push` section to cover `{push_files}` consistently      |
| `x`    | T10 | Exclude agentic files from MD013 line-length — delegate to `markdownlint-agentic` (#23)                            |

## §B — Bugs / Known Issues

1. **`.envrc` missing `watch_file` directives** — The `.envrc` contains only `use flake`. Per the project's own direnv skill, it should watch `flake.nix`, `dev.sh`, and any nix modules for automatic reload on change. Currently, changes to these files require a manual `direnv reload`.

2. **`actions/checkout` version mismatch** — `ci.yml` uses `actions/checkout@v6` while `update-pins.yml` uses `actions/checkout@v4`. This is a minor inconsistency but could cause divergent checkout behavior.

3. **Inline shell in `lefthook-nix-no-embedded-shell` wrapper** — The flake embeds a `SCANNER=` shell assignment inline (concatenated with `readFile`), which contradicts the nix/modularity skill requiring no embedded shell in nix files.

4. **Bats library load syntax inconsistency** — `lefthook-markdownlint.bats` uses `load "$BATS_LIB_PATH/bats-support/load"` (no `.bash` extension) while `dev.bats` uses `load "${BATS_LIB_PATH}/bats-support/load.bash"` (with `.bash` extension). Both work, but the inconsistency could confuse contributors.

5. **`flake.lock` is gitignored** — While the `nixpkgs-lock` flake input provides pinned nixpkgs, other inputs (16 `nix-lefthook-*-src` repos) float to their latest commit on each `nix flake update`. This means builds across machines may use different versions of these inputs unless the lock is shared out-of-band.

6. **`dev.sh` pre-commit hook existence check is fragile** — The guard `[ -f .git/hooks/pre-commit ]` only checks for the pre-commit hook file. If lefthook is partially installed (e.g. pre-push exists but pre-commit was deleted), the install re-runs but may not detect the partial state. Additionally, this check fails in worktrees where `.git` is a file, not a directory.

7. **SPEC.md tables fail MD060 and file-size-check in CI (2026-07-04)** — Tables used unaligned pipe style (`|---|---|---|`) which violates MD060/table-column-style (markdownlint-cli 0.46). Additionally, SPEC.md at 7011 bytes exceeded the default 4096-byte file-size-check limit since no `.md` extension limit was configured. Fixed by aligning all tables and adding `md: 10240` to `config/lefthook/file_size_limits.yml`.

8. **shfmt case-pattern indentation in lefthook-markdownlint.sh (2026-07-04)** — The `case` pattern body (`*.md)`) used 4-space indent instead of the 2-space indent that `shfmt` expects (case patterns at same level as `case`/`esac`). Fixed by reducing the indent from 4 to 2 spaces.

9. **Symlink test used invalid markdown content (2026-07-05)** — The test "symlink with .md extension to non-markdown target is linted by name" used `echo "not markdown"` as file content, which fails markdownlint MD041 (first line must be a top-level heading). The test asserted success, so it always failed. Fixed by using valid markdown content (`# Heading`) so the test verifies the symlink is picked up for linting without a false lint failure.

10. **Orphaned `update-pins.bats` after dropping `update-pins.yml` (2026-07-06)** — Workflow was removed but its test file stayed, causing 6 CI failures. Fixed by deleting the orphaned test.

11. **`markdownlint-agentic` lefthook command missing its binary (2026-07-14)** — `lefthook.yml` (regenerated by the standards refresh) added a `markdownlint-agentic` command running `lefthook-markdownlint-agentic`, but `flake.nix` never wired that binary in, so it was absent from the dev/CI shell (`exit 127: No such file or directory`). Fixed by adding the `nix-lefthook-markdownlint-agentic-src` flake input and exposing its wrapper via `lefthookWrappersFor`. This also surfaced a pre-existing `README.md` line 9 exceeding `MD013 line_length: 300` (348 chars), fixed by splitting the paragraph across two lines.

12. **Invalid flake and guardrails after standards migration (2026-07-20)** — The migration placed an obsolete development-shell definition inside the package set under a second `default` attribute, so Nix rejected the flake before evaluating any checks. After evaluation was restored, the dependency-graph check failed because it requires the still-gitignored `flake.lock`, and the modularity check found an inline shell fragment in the new confirm app. Fixed by restoring the documented package outputs, tracking the lock file, and extracting the confirm script from `flake.nix`.
