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

# =============================================================================
# Global Variables
# =============================================================================

# =============================================================================
# Private Functions
# =============================================================================

# =============================================================================
# Public Functions
# =============================================================================
function tc___write_log__no_arg() {
    local actual_ret_code

    _g_logging__write_log
    actual_ret_code=$?
    tests__eq "$G__ERR_MISSING_ARG" "$actual_ret_code"
}

function tc___write_log__missing_message() {
    local actual_ret_code

    _g_logging__write_log "DEBUG"
    actual_ret_code=$?
    tests__eq "$G__ERR_MISSING_ARG" "$actual_ret_code"
}

function tc___write_log__invalid_level() {
    local actual_ret_code

    _g_logging__write_log "INVALID_LEVEL" "log message"
    actual_ret_code=$?
    tests__eq "$G__ERR_INVALID_ARG" "$actual_ret_code"
}

function tc___write_log__invalid_stack() {
    local actual_ret_code

    _g_logging__write_log "ERROR" "log message" "abc"
    actual_ret_code=$?
    tests__eq "$G__ERR_INVALID_ARG" "$actual_ret_code"
}

function tc__debug__enabled() {
    local _actual
    local _actual_level
    local _actual_msg

    _actual="$(LOG_LEVEL="$G__LOG_LEVEL_DEBUG" g_logging__debug "test_debug")"
    _actual_level="$(awk '{print $3}' <<<"$_actual")"
    _actual_msg="$(awk '{print $5}' <<<"$_actual")"

    tests__eq "DEBUG" "$_actual_level"
    tests__eq "test_debug" "$_actual_msg"
}

function tc__debug__disabled() {
    local _expected=""
    local _actual

    _actual="$(LOG_LEVEL="$G__LOG_LEVEL_INFO" g_logging__debug "test_debug")"

    tests__eq "$_expected" "$_actual"
}

function tc__info__enabled() {
    local _actual
    local _actual_level
    local _actual_msg

    _actual="$(LOG_LEVEL="$G__LOG_LEVEL_INFO" g_logging__info "test_info")"
    _actual_level="$(awk '{print $3}' <<<"$_actual")"
    _actual_msg="$(awk '{print $5}' <<<"$_actual")"

    tests__eq "INFO" "$_actual_level"
    tests__eq "test_info" "$_actual_msg"
}

function tc__info__disabled() {
    local _expected=""
    local _actual

    _actual="$(LOG_LEVEL="$G__LOG_LEVEL_WARN" g_logging__info "test_info")"

    tests__eq "$_expected" "$_actual"
}

function tc__warn__enabled() {
    local _actual
    local _actual_level
    local _actual_msg

    _actual="$(LOG_LEVEL="$G__LOG_LEVEL_WARN" g_logging__warn "test_warn")"
    _actual_level="$(awk '{print $3}' <<<"$_actual")"
    _actual_msg="$(awk '{print $5}' <<<"$_actual")"

    tests__eq "WARN" "$_actual_level"
    tests__eq "${G__YELLOW}test_warn${G__NC}" "$_actual_msg"
}

function tc__warn__disabled() {
    local _expected=""
    local _actual

    _actual="$(LOG_LEVEL="$G__LOG_LEVEL_ERROR" g_logging__warn "test_warn")"

    tests__eq "$_expected" "$_actual"
}

function tc__error__enabled() {
    local _actual
    local _actual_level
    local _actual_msg

    _actual="$(LOG_LEVEL="$G__LOG_LEVEL_ERROR" g_logging__error "test_error")"
    _actual_level="$(awk '{print $3}' <<<"$_actual")"
    _actual_msg="$(awk '{print $5}' <<<"$_actual")"

    tests__eq "ERROR" "$_actual_level"
    tests__eq "${G__RED}test_error${G__NC}" "$_actual_msg"
}

function tc__error__disabled() {
    local _expected=""
    local _actual

    _actual="$(LOG_LEVEL=$((G__LOG_LEVEL_ERROR + 1)) g_logging__error "test_error")"

    tests__eq "$_expected" "$_actual"
}

# =============================================================================
# Entry Point
# =============================================================================
function main() {
    set -u

    # shellcheck disable=SC1091
    source "${GLOBAL_DIR}/global-entry.sh"

    local _fut="${GLOBAL_DIR}/global-logging.sh"
    local -a _fut_deps=(
        "${GLOBAL_DIR}/global-constants.sh"
    )

    test_main "$_fut" "${_fut_deps[@]}"
}

main
