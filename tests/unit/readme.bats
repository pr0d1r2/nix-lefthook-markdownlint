#!/usr/bin/env bats

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert

    README="README.md"
}

@test "README.md exists" {
    assert [ -f "$README" ]
}

@test "discloses autonomous tending with a maintained disclaimer link" {
    run grep -F '<!-- hallucinogen:autonomy-disclaimer start -->' "$README"
    assert_success
    run grep -F 'tended by an autonomous loop' "$README"
    assert_success
    run grep -F '[LLM-DISCLAIMER](docs/LLM-DISCLAIMER.md)' "$README"
    assert_success
    run grep -F '<!-- hallucinogen:autonomy-disclaimer end -->' "$README"
    assert_success
}

@test "the linked LLM disclaimer exists" {
    assert [ -f docs/LLM-DISCLAIMER.md ]
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
