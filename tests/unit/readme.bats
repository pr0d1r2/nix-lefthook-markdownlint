#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    README="README.md"
}

@test "README.md exists" {
    assert [ -f "$README" ]
}

@test "documents the flake.lock tracking rationale" {
    run grep -F 'flake.lock' "$README"
    assert_success
}

@test "explains flake.lock is gitignored" {
    run grep -i 'gitignore' "$README"
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
