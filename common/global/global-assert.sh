#!/usr/bin/env bash
#
# Source      : common/global/global-assert.sh
# Dependencies: common/global/global-constants.sh
#               common/global/global-logging.sh
# Description : Assertion utilities for validating runtime preconditions.
#

[[ -n "${G__GLOBAL_ASSERT_SH_LOADED:-}" ]] && return 0
export G__GLOBAL_ASSERT_SH_LOADED=1

# =============================================================================
# Global Constants
# =============================================================================
ASSERT_PASSED_CODE=0
ASSERT_FAILED_CODE=1

# =============================================================================
# Global Variables
# =============================================================================

# =============================================================================
# Private Functions
# =============================================================================

# =============================================================================
# Public Functions
# =============================================================================
#######################################
# Assert that a variable is set and not empty.
#
# Arguments:
#   var_name [in]: Name of the variable to validate.
#
# Returns:
#   0: If variable is set and non-empty.
#   1: If variable is unset or empty.
#######################################
function g_assert__not_empty() {
    local _var_name="$1"

    if [[ -n "${!_var_name:-}" ]]; then
        return "$ASSERT_PASSED_CODE"
    fi

    g_logging__error "Assertion failed: $_var_name is empty or unset"
    return "$ASSERT_FAILED_CODE"
}

#######################################
# Assert that two values are equal.
#
# Globals:
#   G__CYAN: Cyan terminal ANSI sequence.
#   G__MAGENTA: Magenta terminal ANSI sequence.
#   G__NC: Terminal reset ANSI sequence.
#
# Arguments:
#   left [in]: Left value to compare.
#   right [in]: Right value to compare.
#   left_label [in]: (optional) Display label for the left value.
#   right_label [in]: (optional) Display label for the right value.
#
# Returns:
#   0: If both values are equal.
#   1: If values differ.
#######################################
function g_assert__eq() {
    local _left="$1"
    local _right="$2"
    local _left_label="${3:-Left}"
    local _right_label="${4:-Right}"

    if [[ "$_left" == "$_right" ]]; then
        return "$ASSERT_PASSED_CODE"
    fi

    g_logging__error "Assertion failed: values are not equal"
    g_logging__info "${G__CYAN}  $_left_label: '${_left}'${G__NC}"
    g_logging__info "${G__MAGENTA}  $_right_label: '${_right}'${G__NC}"

    return "$ASSERT_FAILED_CODE"
}

#######################################
# Assert that two values are not equal.
#
# Globals:
#   G__CYAN: Cyan terminal ANSI sequence.
#   G__MAGENTA: Magenta terminal ANSI sequence.
#   G__NC: Terminal reset ANSI sequence.
#
# Arguments:
#   left [in]: Left value to compare.
#   right [in]: Right value to compare.
#   left_label [in]: (optional) Display label for the left value.
#   right_label [in]: (optional) Display label for the right value.
#
# Returns:
#   0: If values differ.
#   1: If both values are equal.
#######################################
function g_assert__ne() {
    local _left="$1"
    local _right="$2"
    local _left_label="${3:-Left}"
    local _right_label="${4:-Right}"

    if [[ "$_left" != "$_right" ]]; then
        return "$ASSERT_PASSED_CODE"
    fi

    g_logging__error "Assertion failed: values are equal"
    g_logging__info "${G__CYAN}  $_left_label: '${_left}'${G__NC}"
    g_logging__info "${G__MAGENTA}  $_right_label: '${_right}'${G__NC}"

    return "$ASSERT_FAILED_CODE"
}

#######################################
# Assert that a path exists and is a regular file.
#
# Globals:
#   G__MAGENTA: Magenta terminal ANSI sequence.
#   G__NC: Terminal reset ANSI sequence.
#
# Arguments:
#   path [in]: File path to validate.
#   path_label [in]: (optional) Display label for the path.
#
# Returns:
#   0: If path exists and is a regular file.
#   1: If path does not exist or is not a regular file.
#######################################
function g_assert__file() {
    local _path="$1"
    local _path_label="${2:-Path}"

    if [[ -f "$_path" ]]; then
        return "$ASSERT_PASSED_CODE"
    fi

    g_logging__error "Assertion failed: path is not a file"
    g_logging__info "${G__MAGENTA}  $_path_label: '$_path'${G__NC}"

    return "$ASSERT_FAILED_CODE"
}
