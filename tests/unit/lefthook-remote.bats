#!/usr/bin/env bats

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert

    CONFIG="lefthook-remote.yml"
    TEST_TEMP="$(mktemp -d)"
    PRE_COMMIT="$TEST_TEMP/pre-commit"
    PRE_PUSH="$TEST_TEMP/pre-push"

    awk '/^[a-zA-Z]/{s=($0=="pre-commit:")?"y":"n";next} s=="y"{print}' \
        "$CONFIG" > "$PRE_COMMIT"
    awk '/^[a-zA-Z]/{s=($0=="pre-push:")?"y":"n";next} s=="y"{print}' \
        "$CONFIG" > "$PRE_PUSH"
}

teardown() {
    rm -rf "$TEST_TEMP"
}

@test "lefthook-remote.yml exists" {
    assert [ -f "$CONFIG" ]
}

@test "starts with YAML document marker" {
    run head -n 1 "$CONFIG"
    assert_output "---"
}

@test "defines a pre-commit section" {
    run grep -c '^pre-commit:' "$CONFIG"
    assert_success
    assert_output "1"
}

@test "defines a pre-push section" {
    run grep -c '^pre-push:' "$CONFIG"
    assert_success
    assert_output "1"
}

@test "pre-commit defines a commands block" {
    run grep -c '^  commands:' "$PRE_COMMIT"
    assert_success
    assert_output "1"
}

@test "pre-push defines a commands block" {
    run grep -c '^  commands:' "$PRE_PUSH"
    assert_success
    assert_output "1"
}

@test "pre-commit defines a markdownlint command" {
    run grep -c '^    markdownlint:' "$PRE_COMMIT"
    assert_success
    assert_output "1"
}

@test "pre-push defines a markdownlint command" {
    run grep -c '^    markdownlint:' "$PRE_PUSH"
    assert_success
    assert_output "1"
}

@test "pre-commit markdownlint globs *.md" {
    run grep -c 'glob: "\*.md"' "$PRE_COMMIT"
    assert_success
    assert_output "1"
}

@test "pre-push markdownlint globs *.md" {
    run grep -c 'glob: "\*.md"' "$PRE_PUSH"
    assert_success
    assert_output "1"
}

@test "pre-commit runs lefthook-markdownlint on staged_files" {
    # shellcheck disable=SC2016 # literal placeholder text, must not expand
    run grep -F 'run: timeout ${LEFTHOOK_MARKDOWNLINT_TIMEOUT:-30} lefthook-markdownlint {staged_files}' "$PRE_COMMIT"
    assert_success
}

@test "pre-push runs lefthook-markdownlint on push_files" {
    # shellcheck disable=SC2016 # literal placeholder text, must not expand
    run grep -F 'run: timeout ${LEFTHOOK_MARKDOWNLINT_TIMEOUT:-30} lefthook-markdownlint {push_files}' "$PRE_PUSH"
    assert_success
}
