#!/usr/bin/env bats

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert

    TEST_TEMP="$(mktemp -d)"
    WATCH_LOG="$TEST_TEMP/watch_log"
    USE_LOG="$TEST_TEMP/use_log"
}

teardown() {
    rm -rf "$TEST_TEMP"
}

@test "watches nix/direnv.sh for changes" {
    run bash -c '
        watch_file() { echo "$1" >> "'"$WATCH_LOG"'"; }
        use() { :; }
        source .envrc
    '
    assert_success
    run grep -x "nix/direnv.sh" "$WATCH_LOG"
    assert_success
}

@test "sources nix/direnv.sh" {
    run bash -c '
        watch_file() { echo "$1" >> "'"$WATCH_LOG"'"; }
        use() { echo "$*" >> "'"$USE_LOG"'"; }
        source .envrc
    '
    assert_success
    run cat "$USE_LOG"
    assert_output "flake"
}

@test "transitively watches flake.nix via nix/direnv.sh" {
    run bash -c '
        watch_file() { echo "$1" >> "'"$WATCH_LOG"'"; }
        use() { :; }
        source .envrc
    '
    assert_success
    run grep -x "flake.nix" "$WATCH_LOG"
    assert_success
}

@test "transitively watches dev.sh via nix/direnv.sh" {
    run bash -c '
        watch_file() { echo "$1" >> "'"$WATCH_LOG"'"; }
        use() { :; }
        source .envrc
    '
    assert_success
    run grep -x "dev.sh" "$WATCH_LOG"
    assert_success
}

@test "transitively watches lefthook-markdownlint.sh via nix/direnv.sh" {
    run bash -c '
        watch_file() { echo "$1" >> "'"$WATCH_LOG"'"; }
        use() { :; }
        source .envrc
    '
    assert_success
    run grep -x "lefthook-markdownlint.sh" "$WATCH_LOG"
    assert_success
}

@test "transitively watches is-markdown-agentic.sh via nix/direnv.sh" {
    run bash -c '
        watch_file() { echo "$1" >> "'"$WATCH_LOG"'"; }
        use() { :; }
        source .envrc
    '
    assert_success
    run grep -x "is-markdown-agentic.sh" "$WATCH_LOG"
    assert_success
}

@test "transitively watches nix/lefthook-nix-no-embedded-shell-scanner.sh via nix/direnv.sh" {
    run bash -c '
        watch_file() { echo "$1" >> "'"$WATCH_LOG"'"; }
        use() { :; }
        source .envrc
    '
    assert_success
    run grep -x "nix/lefthook-nix-no-embedded-shell-scanner.sh" "$WATCH_LOG"
    assert_success
}

@test "transitively watches nix/outputs.nix via nix/direnv.sh" {
    run bash -c '
        watch_file() { echo "$1" >> "'"$WATCH_LOG"'"; }
        use() { :; }
        source .envrc
    '
    assert_success
    run grep -x "nix/outputs.nix" "$WATCH_LOG"
    assert_success
}
