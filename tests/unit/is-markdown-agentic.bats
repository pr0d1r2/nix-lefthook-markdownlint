#!/usr/bin/env bats

setup() {
    load "$BATS_LIB_PATH/bats-support/load"
    load "$BATS_LIB_PATH/bats-assert/load"

    TEST_TEMP="$(mktemp -d)"
}

teardown() {
    rm -rf "$TEST_TEMP"
}

@test "exits 1 with no arguments" {
    run is-markdown-agentic
    assert_failure
}

@test "agent/ directory file is agentic" {
    run is-markdown-agentic "agent/set.md"
    assert_success
}

@test "nested agent/ directory file is agentic" {
    run is-markdown-agentic "agent/set/skills/tdd.md"
    assert_success
}

@test "absolute path agent/ file is agentic" {
    run is-markdown-agentic "$TEST_TEMP/agent/set.md"
    assert_success
}

@test ".claude/skills/ file is agentic" {
    run is-markdown-agentic ".claude/skills/review.md"
    assert_success
}

@test ".claude/commands/ file is agentic" {
    run is-markdown-agentic ".claude/commands/deploy.md"
    assert_success
}

@test "absolute .claude/ path is agentic" {
    run is-markdown-agentic "$TEST_TEMP/.claude/skills/foo.md"
    assert_success
}

@test "files/commands/ file is agentic" {
    run is-markdown-agentic "files/commands/run.md"
    assert_success
}

@test "SPEC.md at root is agentic" {
    run is-markdown-agentic "SPEC.md"
    assert_success
}

@test "SPEC.md with absolute path is agentic" {
    run is-markdown-agentic "$TEST_TEMP/SPEC.md"
    assert_success
}

@test "CLAUDE.md at root is agentic" {
    run is-markdown-agentic "CLAUDE.md"
    assert_success
}

@test "CLAUDE.md with absolute path is agentic" {
    run is-markdown-agentic "$TEST_TEMP/CLAUDE.md"
    assert_success
}

@test "PROMPT.md at root is agentic" {
    run is-markdown-agentic "PROMPT.md"
    assert_success
}

@test "PROMPT.md with absolute path is agentic" {
    run is-markdown-agentic "$TEST_TEMP/PROMPT.md"
    assert_success
}

@test "README.md is not agentic" {
    run is-markdown-agentic "README.md"
    assert_failure
}

@test "CHANGELOG.md is not agentic" {
    run is-markdown-agentic "CHANGELOG.md"
    assert_failure
}

@test "CONTRIBUTING.md is not agentic" {
    run is-markdown-agentic "CONTRIBUTING.md"
    assert_failure
}

@test "docs/ directory file is not agentic" {
    run is-markdown-agentic "docs/guide.md"
    assert_failure
}

@test "arbitrary nested markdown is not agentic" {
    run is-markdown-agentic "src/components/button.md"
    assert_failure
}
