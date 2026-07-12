#!/usr/bin/env bats

setup() {
    load "$BATS_LIB_PATH/bats-support/load"
    load "$BATS_LIB_PATH/bats-assert/load"
    load "$BATS_LIB_PATH/bats-file/load"

    TEST_TEMP="$(mktemp -d)"
}

teardown() {
    rm -rf "$TEST_TEMP"
}

@test "exits 0 with no arguments" {
    run lefthook-markdownlint
    assert_success
}

@test "exits 0 when no .md files in arguments" {
    touch "$TEST_TEMP/file.txt"
    run lefthook-markdownlint "$TEST_TEMP/file.txt"
    assert_success
}

@test "skips missing files silently" {
    run lefthook-markdownlint "/nonexistent/file.md"
    assert_success
}

@test "accepts valid markdown file" {
    cat > "$TEST_TEMP/good.md" << 'MDEOF'
# Hello

This is valid markdown.
MDEOF
    run lefthook-markdownlint "$TEST_TEMP/good.md"
    assert_success
}

@test "detects invalid markdown" {
    cat > "$TEST_TEMP/bad.md" << 'MDEOF'
# Hello
# Hello
MDEOF
    run lefthook-markdownlint "$TEST_TEMP/bad.md"
    assert_failure
}

@test "filters non-.md files from mixed input" {
    cat > "$TEST_TEMP/good.md" << 'MDEOF'
# Hello

This is valid markdown.
MDEOF
    touch "$TEST_TEMP/file.txt"
    run lefthook-markdownlint "$TEST_TEMP/good.md" "$TEST_TEMP/file.txt"
    assert_success
}

@test "LEFTHOOK_MARKDOWNLINT_CONFIG applies a custom config" {
    # Config disabling all rules -> otherwise-invalid markdown passes,
    # proving the config file is honored.
    cat > "$TEST_TEMP/relaxed.yml" << 'CFGEOF'
default: false
CFGEOF
    cat > "$TEST_TEMP/bad.md" << 'MDEOF'
# Hello
# Hello
MDEOF
    LEFTHOOK_MARKDOWNLINT_CONFIG="$TEST_TEMP/relaxed.yml" \
        run lefthook-markdownlint "$TEST_TEMP/bad.md"
    assert_success
}

@test "LEFTHOOK_MARKDOWNLINT_CONFIG from outside the repo root" {
    # The config need not be a committed root file (e.g. a nix out-link).
    mkdir -p "$TEST_TEMP/out/link"
    cat > "$TEST_TEMP/out/link/.markdownlint.yml" << 'CFGEOF'
default: false
CFGEOF
    cat > "$TEST_TEMP/bad.md" << 'MDEOF'
# Hello
# Hello
MDEOF
    LEFTHOOK_MARKDOWNLINT_CONFIG="$TEST_TEMP/out/link/.markdownlint.yml" \
        run lefthook-markdownlint "$TEST_TEMP/bad.md"
    assert_success
}

@test "unset LEFTHOOK_MARKDOWNLINT_CONFIG still flags invalid markdown" {
    cat > "$TEST_TEMP/bad.md" << 'MDEOF'
# Hello
# Hello
MDEOF
    run lefthook-markdownlint "$TEST_TEMP/bad.md"
    assert_failure
}

@test "skips agentic file in agent/ directory" {
    mkdir -p "$TEST_TEMP/agent"
    cat > "$TEST_TEMP/agent/set.md" << 'MDEOF'
# Hello
# Hello
MDEOF
    run lefthook-markdownlint "$TEST_TEMP/agent/set.md"
    assert_success
}

@test "skips agentic SPEC.md file" {
    mkdir -p "$TEST_TEMP/repo"
    cat > "$TEST_TEMP/repo/SPEC.md" << 'MDEOF'
# Hello
# Hello
MDEOF
    run lefthook-markdownlint "$TEST_TEMP/repo/SPEC.md"
    assert_success
}

@test "still lints non-agentic file alongside agentic file" {
    mkdir -p "$TEST_TEMP/agent"
    cat > "$TEST_TEMP/agent/set.md" << 'MDEOF'
# Hello
# Hello
MDEOF
    cat > "$TEST_TEMP/bad.md" << 'MDEOF'
# Hello
# Hello
MDEOF
    run lefthook-markdownlint "$TEST_TEMP/agent/set.md" "$TEST_TEMP/bad.md"
    assert_failure
}
