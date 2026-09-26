# Changelog

All notable changes to this project are documented here.

## Unreleased

### Fixed

- Pin bump: `set-and-setting` now follows this flake's `nixpkgs` and
  `nixpkgs-lock`, and the flake drops the `lib` override that the current
  `mkConsumerFlake` no longer accepts.
