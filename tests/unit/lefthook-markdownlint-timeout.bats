#!/usr/bin/env bats

setup() {
    load "$BATS_LIB_PATH/bats-support/load"
    load "$BATS_LIB_PATH/bats-assert/load"

    TEST_TEMP="$(mktemp -d)"

    cat > "$TEST_TEMP/good.md" << 'MDEOF'
# Hello

This is valid markdown.
MDEOF
}

teardown() {
    rm -rf "$TEST_TEMP"
}

@test "default timeout is 30 when LEFTHOOK_MARKDOWNLINT_TIMEOUT is unset" {
    run bash -c 'unset LEFTHOOK_MARKDOWNLINT_TIMEOUT; echo "${LEFTHOOK_MARKDOWNLINT_TIMEOUT:-30}"'
    assert_success
    assert_output "30"
}

@test "LEFTHOOK_MARKDOWNLINT_TIMEOUT overrides default timeout value" {
    run bash -c 'export LEFTHOOK_MARKDOWNLINT_TIMEOUT=10; echo "${LEFTHOOK_MARKDOWNLINT_TIMEOUT:-30}"'
    assert_success
    assert_output "10"
}

@test "timeout command wraps lefthook-markdownlint successfully" {
    run timeout "${LEFTHOOK_MARKDOWNLINT_TIMEOUT:-30}" lefthook-markdownlint "$TEST_TEMP/good.md"
    assert_success
}

@test "custom LEFTHOOK_MARKDOWNLINT_TIMEOUT wraps lefthook-markdownlint successfully" {
    run bash -c 'LEFTHOOK_MARKDOWNLINT_TIMEOUT=5; timeout "$LEFTHOOK_MARKDOWNLINT_TIMEOUT" lefthook-markdownlint "$1"' -- "$TEST_TEMP/good.md"
    assert_success
}

@test "timeout kills a process exceeding LEFTHOOK_MARKDOWNLINT_TIMEOUT" {
    cat > "$TEST_TEMP/slow-lint.sh" << 'SH'
#!/usr/bin/env bash
sleep 60
SH
    chmod +x "$TEST_TEMP/slow-lint.sh"
    LEFTHOOK_MARKDOWNLINT_TIMEOUT=1
    run timeout "$LEFTHOOK_MARKDOWNLINT_TIMEOUT" bash "$TEST_TEMP/slow-lint.sh"
    assert_failure
    assert_equal "$status" 124
}

@test "process completing within LEFTHOOK_MARKDOWNLINT_TIMEOUT succeeds" {
    cat > "$TEST_TEMP/fast-lint.sh" << 'SH'
#!/usr/bin/env bash
exit 0
SH
    chmod +x "$TEST_TEMP/fast-lint.sh"
    LEFTHOOK_MARKDOWNLINT_TIMEOUT=5
    run timeout "$LEFTHOOK_MARKDOWNLINT_TIMEOUT" bash "$TEST_TEMP/fast-lint.sh"
    assert_success
}
