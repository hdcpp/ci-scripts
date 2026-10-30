#!/usr/bin/env bash
#
# Source      : common/global/global-entry.sh
# Dependencies: common/global/global-entry.sh
#

# =============================================================================
# Global Constants
# =============================================================================
GLOBAL_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")"

# shellcheck disable=SC2034
# FOR_TESTS is used to load the test framework by `source global-entry.sh`
FOR_TESTS=1

function tc__find_max_len__success() {
    local -a items=("12345" "123" "1234567")
    local expected=7

    local actual

    actual="$(g_utils__find_max_len "${items[@]}")"

    tests__eq "$expected" "$actual"
}

function tc__find_max_len__empty_list() {
    local -a items=()
    local expected=0

    local actual

    actual="$(g_utils__find_max_len "${items[@]}")"

    tests__eq "$expected" "$actual"
}

# =============================================================================
# Entry Point
# =============================================================================
function main() {
    set -e

    # shellcheck disable=SC1091
    source "${GLOBAL_DIR}/global-entry.sh"

    local _fut="${GLOBAL_DIR}/global-utils.sh"
    local _fut_deps=(
        "${GLOBAL_DIR}/global-constants.sh"
        "${GLOBAL_DIR}/global-logging.sh"
    )

    test_main "$_fut" "${_fut_deps[@]}"
}

main
