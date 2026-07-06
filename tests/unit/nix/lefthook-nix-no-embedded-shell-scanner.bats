#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMPDIR="$(mktemp -d)"
}

teardown() {
    rm -rf "$TMPDIR"
}

@test "contains SCANNER assignment" {
    run grep -c 'SCANNER=' nix/lefthook-nix-no-embedded-shell-scanner.sh
    assert_success
    assert_output "1"
}

@test "uses @SCANNER_PATH@ placeholder" {
    run grep -c '@SCANNER_PATH@' nix/lefthook-nix-no-embedded-shell-scanner.sh
    assert_success
    assert_output "1"
}

@test "sets SCANNER variable after placeholder substitution" {
    sed 's|@SCANNER_PATH@|/test/scanner.sh|' nix/lefthook-nix-no-embedded-shell-scanner.sh > "$TMPDIR/scanner.sh"
    run bash -c 'source "$1"; echo "$SCANNER"' -- "$TMPDIR/scanner.sh"
    assert_success
    assert_output "/test/scanner.sh"
}
