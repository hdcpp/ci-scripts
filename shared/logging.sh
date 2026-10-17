#!/usr/bin/env bash
#
# Common logging utilities for shell scripts.
#
# Provides functions for logging messages with timestamps and caller
# information; assert expressions and dump environment variables.
#

# =====================================
# Global constants & variables
# =====================================
LOG_LEVEL_DEBUG=1
LOG_LEVEL_INFO=2
LOG_LEVEL_WARN=3
LOG_LEVEL_ERROR=4

_DEFAULT_LOG_LEVEL="$LOG_LEVEL_INFO"
_DEFAULT_ASSERT_EXIT_CODE=1

# =====================================
# Private functions
# =====================================
#######################################
# Print log messages with timestamp and location.
# Globals:
#   BASH_SOURCE
#   BASH_LINENO
# Arguments:
#   log_level_str: String form of the log level associating with the messages
#   messages: Log messages to print
# Outputs:
#   Writes log messages to STDOUT
#######################################
function _log_message() {
    local log_level_str="$1"
    shift
    local messages=("$@")

    local line_no_stack_level="${STACK_LEVEL:-1}"
    local caller_stack_level=$((line_no_stack_level + 1))

    local timestamp
    local caller_path
    local caller_name
    local line_no="${BASH_LINENO[$line_no_stack_level]}"

    timestamp="$(date +'%Y-%m-%d %H:%M:%S')"
    caller_path="$(realpath "${BASH_SOURCE[$caller_stack_level]}")"
    caller_name="$(basename "$caller_path")"

    echo "$timestamp $log_level_str ${caller_name}:${line_no} ${messages[*]}"
}

# =====================================
# Public functions
# =====================================
#######################################
# Print debug messages with timestamp and location.
# Globals:
#   LOG_LEVEL
#   _DEFAULT_LOG_LEVEL
#   LOG_LEVEL_DEBUG
# Arguments:
#   messages: Log messages to print
# Outputs:
#   Writes log messages to STDOUT
#######################################
function log_debug() {
    local messages=("$@")
    local log_level="${LOG_LEVEL:-$_DEFAULT_LOG_LEVEL}"

    if [[ "$log_level" -le "$LOG_LEVEL_DEBUG" ]]; then
        _log_message "DEBUG" "${messages[@]}"
    fi
}

#######################################
# Print info messages with timestamp and location.
# Globals:
#   LOG_LEVEL
#   _DEFAULT_LOG_LEVEL
#   LOG_LEVEL_INFO
# Arguments:
#   messages: Log messages to print
# Outputs:
#   Writes log messages to STDOUT
#######################################
function log_info() {
    local messages=("$@")
    local log_level="${LOG_LEVEL:-$_DEFAULT_LOG_LEVEL}"

    if [[ "$log_level" -le "$LOG_LEVEL_INFO" ]]; then
        _log_message "INFO " "${messages[@]}"
    fi
}

#######################################
# Print warning messages with timestamp and location.
# Globals:
#   LOG_LEVEL
#   _DEFAULT_LOG_LEVEL
#   LOG_LEVEL_WARN
# Arguments:
#   messages: Log messages to print
# Outputs:
#   Writes log messages to STDOUT
#######################################
function log_warn() {
    local messages=("$@")
    local log_level="${LOG_LEVEL:-$_DEFAULT_LOG_LEVEL}"

    if [[ "$log_level" -le "$LOG_LEVEL_WARN" ]]; then
        _log_message "WARN " "${messages[@]}"
    fi
}

#######################################
# Print error messages with timestamp and location.
# Globals:
#   LOG_LEVEL
#   _DEFAULT_LOG_LEVEL
#   LOG_LEVEL_ERROR
# Arguments:
#   messages: Log messages to print
# Outputs:
#   Writes log messages to STDOUT
#######################################
function log_error() {
    local messages=("$@")
    local log_level="${LOG_LEVEL:-$_DEFAULT_LOG_LEVEL}"

    if [[ "$log_level" -le "$LOG_LEVEL_ERROR" ]]; then
        _log_message "ERROR" "${messages[@]}"
    fi
}

#######################################
# Assert and exit if a variable is empty.
# Globals:
#   _DEFAULT_ASSERT_EXIT_CODE
# Arguments:
#   var_name: Name of the variable to assert
#   exit_code (optional): Exit code when assertion failed
# Outputs:
#   Writes log messages to STDOUT
#######################################
function assert_empty() {
    local var_name="$1"
    local exit_code="$2"

    local var_value="${!var_name}"

    if [[ -z "$var_value" ]]; then
        _log_message "FATAL" "$var_name cannot be empty"
        exit "${exit_code:-$_DEFAULT_ASSERT_EXIT_CODE}"
    fi
}
