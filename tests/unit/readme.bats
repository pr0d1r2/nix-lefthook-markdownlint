#!/usr/bin/env bats

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert

    README="README.md"
}

@test "README.md exists" {
    assert [ -f "$README" ]
}

@test "documents the flake.lock tracking rationale" {
    run grep -F 'flake.lock' "$README"
    assert_success
}

@test "explains flake.lock is tracked" {
    run grep -F '`flake.lock` is tracked' "$README"
    assert_success
}

@test "credits the nixpkgs-lock pin for reproducibility" {
    run grep -F 'nixpkgs-lock' "$README"
    assert_success
}

@test "documents reproducibility" {
    run grep -i 'reproducib' "$README"
    assert_success
}
