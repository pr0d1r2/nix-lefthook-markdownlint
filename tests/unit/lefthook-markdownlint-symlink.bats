#!/usr/bin/env bats

setup() {
    load "$BATS_LIB_PATH/bats-support/load"
    load "$BATS_LIB_PATH/bats-assert/load"

    TEST_TEMP="$(mktemp -d)"
}

teardown() {
    rm -rf "$TEST_TEMP"
}

@test "symlink to valid markdown file passes" {
    cat > "$TEST_TEMP/good.md" << 'MDEOF'
# Hello

This is valid markdown.
MDEOF
    ln -s "$TEST_TEMP/good.md" "$TEST_TEMP/link.md"
    run lefthook-markdownlint "$TEST_TEMP/link.md"
    assert_success
}

@test "symlink to invalid markdown file fails" {
    cat > "$TEST_TEMP/bad.md" << 'MDEOF'
# Hello
# Hello
MDEOF
    ln -s "$TEST_TEMP/bad.md" "$TEST_TEMP/link.md"
    run lefthook-markdownlint "$TEST_TEMP/link.md"
    assert_failure
}

@test "dangling symlink is skipped silently" {
    ln -s "$TEST_TEMP/nonexistent.md" "$TEST_TEMP/dangling.md"
    run lefthook-markdownlint "$TEST_TEMP/dangling.md"
    assert_success
    assert_output ""
}

@test "dangling symlink among valid files does not block linting" {
    cat > "$TEST_TEMP/good.md" << 'MDEOF'
# Hello

This is valid markdown.
MDEOF
    ln -s "$TEST_TEMP/nonexistent.md" "$TEST_TEMP/dangling.md"
    run lefthook-markdownlint "$TEST_TEMP/good.md" "$TEST_TEMP/dangling.md"
    assert_success
}

@test "symlink with .md extension to non-markdown target is linted by name" {
    echo "not markdown" > "$TEST_TEMP/data.txt"
    ln -s "$TEST_TEMP/data.txt" "$TEST_TEMP/link.md"
    run lefthook-markdownlint "$TEST_TEMP/link.md"
    assert_success
}

@test "only dangling symlinks exits 0" {
    ln -s "$TEST_TEMP/missing1.md" "$TEST_TEMP/a.md"
    ln -s "$TEST_TEMP/missing2.md" "$TEST_TEMP/b.md"
    run lefthook-markdownlint "$TEST_TEMP/a.md" "$TEST_TEMP/b.md"
    assert_success
    assert_output ""
}
