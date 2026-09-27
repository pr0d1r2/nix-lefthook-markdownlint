#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  SYSTEM="$(nix --extra-experimental-features 'nix-command flakes' eval \
    --impure --raw --expr builtins.currentSystem)"
}

@test "flake exports the default package" {
  run --separate-stderr nix --extra-experimental-features 'nix-command flakes' eval \
    "$REPO_ROOT#packages.$SYSTEM" --apply builtins.attrNames
  assert_success
  assert_output --partial '"default"'
}

@test "default package provides lefthook-markdownlint" {
  run --separate-stderr nix --extra-experimental-features 'nix-command flakes' eval --raw \
    "$REPO_ROOT#packages.$SYSTEM.default.meta.mainProgram"
  assert_success
  assert_output "lefthook-markdownlint"
}

@test "flake exports the is-markdown-agentic package" {
  run --separate-stderr nix --extra-experimental-features 'nix-command flakes' eval --raw \
    "$REPO_ROOT#packages.$SYSTEM.is-markdown-agentic.meta.mainProgram"
  assert_success
  assert_output "is-markdown-agentic"
}
