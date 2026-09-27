# Changelog

All notable changes to this project are documented here.

## Unreleased

### Fixed

- Pin bump: `set-and-setting` now follows this flake's `nixpkgs` and
  `nixpkgs-lock`, and the flake drops the `lib` override that the current
  `mkConsumerFlake` no longer accepts.
- Restore the `lefthook-markdownlint` (default) and `is-markdown-agentic`
  packages, the package build check, and the flake description, all
  dropped by the vendored-to-referenced migration.
- Put the packaged wrapper and classifier first on every devShell PATH so
  the unit tests exercise this repository's code, not the pinned copy.
- Unit tests load bats libraries with `bats_load_library` and no longer
  reassign `TMPDIR`.
- `SPEC.md` bug list: fix duplicate and unseparated item numbers that
  failed `markdownlint-agentic`, and record the dropped-package bug.
