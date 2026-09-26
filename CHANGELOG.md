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
