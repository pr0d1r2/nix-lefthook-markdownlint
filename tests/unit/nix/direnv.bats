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

@test "watches flake.nix for changes" {
    run bash -c '
        watch_file() { echo "$1" >> "'"$WATCH_LOG"'"; }
        use() { :; }
        source nix/direnv.sh
    '
    assert_success
    run grep -x "flake.nix" "$WATCH_LOG"
    assert_success
}

@test "watches dev.sh for changes" {
    run bash -c '
        watch_file() { echo "$1" >> "'"$WATCH_LOG"'"; }
        use() { :; }
        source nix/direnv.sh
    '
    assert_success
    run grep -x "dev.sh" "$WATCH_LOG"
    assert_success
}

@test "watches lefthook-markdownlint.sh for changes" {
    run bash -c '
        watch_file() { echo "$1" >> "'"$WATCH_LOG"'"; }
        use() { :; }
        source nix/direnv.sh
    '
    assert_success
    run grep -x "lefthook-markdownlint.sh" "$WATCH_LOG"
    assert_success
}

@test "watches is-markdown-agentic.sh for changes" {
    run bash -c '
        watch_file() { echo "$1" >> "'"$WATCH_LOG"'"; }
        use() { :; }
        source nix/direnv.sh
    '
    assert_success
    run grep -x "is-markdown-agentic.sh" "$WATCH_LOG"
    assert_success
}

@test "watches nix/lefthook-nix-no-embedded-shell-scanner.sh for changes" {
    run bash -c '
        watch_file() { echo "$1" >> "'"$WATCH_LOG"'"; }
        use() { :; }
        source nix/direnv.sh
    '
    assert_success
    run grep -x "nix/lefthook-nix-no-embedded-shell-scanner.sh" "$WATCH_LOG"
    assert_success
}

@test "uses flake" {
    run bash -c '
        watch_file() { :; }
        use() { echo "$*" >> "'"$USE_LOG"'"; }
        source nix/direnv.sh
    '
    assert_success
    run cat "$USE_LOG"
    assert_output "flake"
}
