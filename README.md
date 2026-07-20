# nix-lefthook-markdownlint

[![CI](https://github.com/pr0d1r2/nix-lefthook-markdownlint/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-lefthook-markdownlint/actions/workflows/ci.yml)

> This code is LLM-generated and validated through an automated integration process using [lefthook](https://github.com/evilmartians/lefthook) git hooks, [bats](https://github.com/bats-core/bats-core) unit tests, and GitHub Actions CI.

Lefthook-compatible [markdownlint](https://github.com/igorshubovych/markdownlint-cli) wrapper, packaged as a Nix flake.

Filters `.md` files from staged arguments and runs markdownlint on them. Exits 0 when no matching files are found.
Agentic files (`agent/`, `.claude/`, `files/commands/`, `SPEC.md`, `CLAUDE.md`, `PROMPT.md`) are automatically skipped — use [nix-lefthook-markdownlint-agentic](https://github.com/pr0d1r2/nix-lefthook-markdownlint-agentic) for those.

## Usage

### Option A: Lefthook remote (recommended)

Add to your `lefthook.yml` — no flake input needed, just the wrapper binary in your devShell:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-markdownlint
    ref: main
    configs:
      - lefthook-remote.yml
```

### Option B: Flake input

Add as a flake input:

```nix
inputs.nix-lefthook-markdownlint = {
  url = "github:pr0d1r2/nix-lefthook-markdownlint";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Add to your devShell:

```nix
nix-lefthook-markdownlint.packages.${pkgs.stdenv.hostPlatform.system}.default
```

Add to `lefthook.yml`:

```yaml
pre-commit:
  commands:
    markdownlint:
      glob: "*.md"
      run: timeout ${LEFTHOOK_MARKDOWNLINT_TIMEOUT:-30} lefthook-markdownlint {staged_files}
```

### Configuring timeout

The default timeout is 30 seconds. Override per-repo via environment variable:

```bash
export LEFTHOOK_MARKDOWNLINT_TIMEOUT=60
```

## Development

The repo includes an `.envrc` for [direnv](https://direnv.net/) — entering the directory automatically loads the devShell with all dependencies:

```bash
cd nix-lefthook-markdownlint  # direnv loads the flake
bats tests/unit/
```

If not using direnv, enter the shell manually:

```bash
nix develop
bats tests/unit/
```

### Reproducibility

`flake.lock` is tracked so every flake input is reproducible and the dependency
graph check can inspect the complete resolved graph. The
[`nixpkgs-lock`](https://github.com/pr0d1r2/nixpkgs-lock) input remains the
central pin for the nixpkgs package set: `nixpkgs` follows
`nixpkgs-lock/nixpkgs`, while the local lock file pins that input and all other
transitive inputs to exact revisions.

## License

MIT
