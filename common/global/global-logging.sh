#!/usr/bin/env bash
#
# Source      : common/global/global-logging.sh
# Dependencies: common/global/global-constants.sh
# Description : Contextual logging utility supporting multiple verbosity levels.
#

[[ -n "${G__GLOBAL_LOGGING_SH_LOADED:-}" ]] && return 0
export G__GLOBAL_LOGGING_SH_LOADED=1

# =============================================================================
# Global Constants
# =============================================================================
readonly LOG_LEVEL_STRS=("DEBUG" "INFO " "WARN " "ERROR")
readonly DEFAULT_LOG_LEVEL="$G__LOG_LEVEL_INFO"
readonly DEFAULT_STACK=0

# =============================================================================
# Global Variables
# =============================================================================

# =============================================================================
# Private Functions
# =============================================================================
#######################################
# Write a formatted log message to STDOUT.
#
# Globals:
#   DEFAULT_STACK: Default stack frame depth when omitted.
#
# Arguments:
#   level_str [in]: Log level string (e.g., "ERROR", "WARN ", "INFO ", "DEBUG").
#   message [in]: Message text to print.
#   stack [in]: (optional) Stack depth (default: $DEFAULT_STACK).
#######################################
function _g_logging__write_log() {
    # Constants

    # Variables
    local _idx
    local _timestamp
    local _caller_path
    local _caller_name
    local _line_no
    local _context

    # Arguments
    local _level_str=""
    local _message
    local _stack

    if [[ $# -lt 2 ]]; then
        return "$G__ERR_MISSING_ARG"
    fi

    _message="$2"
    _stack="${3:-$DEFAULT_STACK}"

    for _idx in "${!LOG_LEVEL_STRS[@]}"; do
        if [[ "$1" == "${LOG_LEVEL_STRS[$_idx]}" ]]; then
            _level_str="$1"
        fi
    done

    if [[ -z "$_level_str" ]]; then
        return "$G__ERR_INVALID_ARG"
    fi

    if [[ ! "$_stack" =~ ^0*[1-9][0-9]*$ ]]; then
        return "$G__ERR_INVALID_ARG"
    fi

    printf -v _timestamp '%(%Y-%m-%d %H:%M:%S)T' -1

    _caller_path="${BASH_SOURCE[$((_stack + 1))]:-unknown}"
    _caller_name="${_caller_path##*/}"

    _line_no="${BASH_LINENO[$_stack]:-0}"

    _context="${_timestamp} ${_level_str} ${_caller_name}:${_line_no}"
    printf '%s %b\n' "${_context}" "${_message}"

    return "$G__ERR_OK"
}

# =============================================================================
# Public Functions
# =============================================================================
#######################################
# Log a debug message to STDOUT.
#
# Globals:
#   LOG_LEVEL: (optional) Active logging threshold level.
#   DEFAULT_LOG_LEVEL: Fallback severity threshold level.
#   G__LOG_LEVEL_DEBUG: Debug severity threshold level.
#
# Arguments:
#   message [in]: Message text to print.
#   stack [in]: (optional) Stack depth (default: 1).
#######################################
function g_logging__debug() {
    local _message="$1"
    local _stack="${2:-1}"

    local _level="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

    if [[ "$_level" -le "$G__LOG_LEVEL_DEBUG" ]]; then
        _g_logging__write_log "DEBUG" "$_message" "$_stack"
    fi
}

#######################################
# Log an info message to STDOUT.
#
# Globals:
#   LOG_LEVEL: (optional) Active logging threshold level.
#   DEFAULT_LOG_LEVEL: Fallback severity threshold level.
#   G__LOG_LEVEL_INFO: Info severity threshold level.
#
# Arguments:
#   message [in]: Message text to print.
#   stack [in]: (optional) Stack depth (default: 1).
#######################################
function g_logging__info() {
    local _message="$1"
    local _stack="${2:-1}"

    local _level="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

    if [[ "$_level" -le "$G__LOG_LEVEL_INFO" ]]; then
        _g_logging__write_log "INFO " "$_message" "$_stack"
    fi
}

#######################################
# Log a warning message to STDOUT with yellow color.
#
# Globals:
#   LOG_LEVEL: (optional) Active logging threshold level.
#   DEFAULT_LOG_LEVEL: Fallback severity threshold level.
#   G__LOG_LEVEL_WARN: Warning severity threshold level.
#   G__YELLOW: Yellow terminal ANSI sequence.
#   G__NC: Terminal reset ANSI sequence.
#
# Arguments:
#   message [in]: Message text to print.
#   stack [in]: (optional) Stack depth (default: 1).
#######################################
function g_logging__warn() {
    local _message="$1"
    local _stack="${2:-1}"

    local _level="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

    if [[ "$_level" -le "$G__LOG_LEVEL_WARN" ]]; then
        _g_logging__write_log "WARN " "${G__YELLOW}${_message}${G__NC}" "$_stack"
    fi
}

#######################################
# Log an error message to STDOUT with red color.
#
# Globals:
#   LOG_LEVEL: (optional) Active logging threshold level.
#   DEFAULT_LOG_LEVEL: Fallback severity threshold level.
#   G__LOG_LEVEL_ERROR: Error severity threshold level.
#   G__RED: Red terminal ANSI sequence.
#   G__NC: Terminal reset ANSI sequence.
#
# Arguments:
#   message [in]: Message text to print.
#   stack [in]: (optional) Stack depth (default: 1).
#######################################
function g_logging__error() {
    local _message="$1"
    local _stack="${2:-1}"

    local _level="${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}"

    if [[ "$_level" -le "$G__LOG_LEVEL_ERROR" ]]; then
        _g_logging__write_log "ERROR" "${G__RED}${_message}${G__NC}" "$_stack"
    fi
}
