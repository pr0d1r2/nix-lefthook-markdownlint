#!/usr/bin/env bats

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert

    TEST_TEMP="$(mktemp -d)"
}

teardown() {
    rm -rf "$TEST_TEMP"
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
    sed 's|@SCANNER_PATH@|/test/scanner.sh|' nix/lefthook-nix-no-embedded-shell-scanner.sh > "$TEST_TEMP/scanner.sh"
    run bash -c 'source "$1"; echo "$SCANNER"' -- "$TEST_TEMP/scanner.sh"
    assert_success
    assert_output "/test/scanner.sh"
}
