#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMPDIR="$(mktemp -d)"
    WATCH_LOG="$TMPDIR/watch_log"
    USE_LOG="$TMPDIR/use_log"
}

teardown() {
    rm -rf "$TMPDIR"
}

@test "uses flake" {
    run bash -c '
        watch_file() { :; }
        use() { echo "$*" >> "'"$USE_LOG"'"; }
        source .envrc
    '
    assert_success
    run cat "$USE_LOG"
    assert_output "flake"
}

@test "watches flake.nix for changes" {
    run bash -c '
        watch_file() { echo "$1" >> "'"$WATCH_LOG"'"; }
        use() { :; }
        source .envrc
    '
    assert_success
    run grep -x "flake.nix" "$WATCH_LOG"
    assert_success
}

@test "watches dev.sh for changes" {
    run bash -c '
        watch_file() { echo "$1" >> "'"$WATCH_LOG"'"; }
        use() { :; }
        source .envrc
    '
    assert_success
    run grep -x "dev.sh" "$WATCH_LOG"
    assert_success
}

@test "watches lefthook-markdownlint.sh for changes" {
    run bash -c '
        watch_file() { echo "$1" >> "'"$WATCH_LOG"'"; }
        use() { :; }
        source .envrc
    '
    assert_success
    run grep -x "lefthook-markdownlint.sh" "$WATCH_LOG"
    assert_success
}
