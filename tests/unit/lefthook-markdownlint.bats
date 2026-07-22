#!/usr/bin/env bats

setup() {
    load "$BATS_LIB_PATH/bats-support/load"
    load "$BATS_LIB_PATH/bats-assert/load"
    load "$BATS_LIB_PATH/bats-file/load"

    TEST_TEMP="$(mktemp -d)"
    BASH_BIN="$(command -v bash)"
}

teardown() {
    rm -rf "$TEST_TEMP"
}

make_markdownlint_stub() {
    mkdir -p "$TEST_TEMP/bin"
    cat > "$TEST_TEMP/bin/markdownlint" << 'SH'
#!/bin/sh
printf '%s\n' "$@"
SH
    chmod +x "$TEST_TEMP/bin/markdownlint"
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
# Title

## Repeated

Text.

## Repeated

Text.
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
    # Override the repository's MD024 setting so otherwise-invalid markdown
    # passes, proving the selected config file is honored.
    cat > "$TEST_TEMP/relaxed.yml" << 'CFGEOF'
MD024: false
CFGEOF
    cat > "$TEST_TEMP/bad.md" << 'MDEOF'
# Title

## Repeated

Text.

## Repeated

Text.
MDEOF
    export LEFTHOOK_MARKDOWNLINT_CONFIG="$TEST_TEMP/relaxed.yml"
    run lefthook-markdownlint "$TEST_TEMP/bad.md"
    assert_success
}

@test "LEFTHOOK_MARKDOWNLINT_CONFIG from outside the repo root" {
    # The config need not be a committed root file (e.g. a nix out-link).
    mkdir -p "$TEST_TEMP/out/link"
    cat > "$TEST_TEMP/out/link/.markdownlint.yml" << 'CFGEOF'
MD024: false
CFGEOF
    cat > "$TEST_TEMP/bad.md" << 'MDEOF'
# Title

## Repeated

Text.

## Repeated

Text.
MDEOF
    export LEFTHOOK_MARKDOWNLINT_CONFIG="$TEST_TEMP/out/link/.markdownlint.yml"
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

@test "missing classifier silently treats ordinary markdown as non-agentic" {
    make_markdownlint_stub
    touch "$TEST_TEMP/README.md"

    run env PATH="$TEST_TEMP/bin" "$BASH_BIN" lefthook-markdownlint.sh "$TEST_TEMP/README.md"

    assert_success
    assert_output "$TEST_TEMP/README.md"
}

@test "missing classifier safely treats agentic paths as non-agentic" {
    make_markdownlint_stub
    mkdir -p "$TEST_TEMP/agent"
    touch "$TEST_TEMP/agent/set.md"

    run env PATH="$TEST_TEMP/bin" "$BASH_BIN" lefthook-markdownlint.sh "$TEST_TEMP/agent/set.md"

    assert_success
    assert_output "$TEST_TEMP/agent/set.md"
}
