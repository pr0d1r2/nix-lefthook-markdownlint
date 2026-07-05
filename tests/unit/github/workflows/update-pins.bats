#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    WORKFLOW=".github/workflows/update-pins.yml"
}

@test "update-pins.yml exists" {
    [ -f "$WORKFLOW" ]
}

@test "uses actions/checkout@v6" {
    run grep "actions/checkout@v6" "$WORKFLOW"
    assert_success
}

@test "does not use actions/checkout@v4" {
    run grep "actions/checkout@v4" "$WORKFLOW"
    assert_failure
}

@test "has workflow name" {
    run grep "^name:" "$WORKFLOW"
    assert_success
}

@test "has workflow_dispatch trigger" {
    run grep "workflow_dispatch" "$WORKFLOW"
    assert_success
}

@test "has schedule trigger" {
    run grep "schedule:" "$WORKFLOW"
    assert_success
}

@test "has jobs section" {
    run grep "^jobs:" "$WORKFLOW"
    assert_success
}
