#!/usr/bin/env bash
#
# Common utilities for shell scripts.
#

# =====================================
# Global constants & variables
# =====================================

# =====================================
# Private functions
# =====================================
#######################################
# Find the maximum length of array of strings.
# Arguments:
#   items: Array of strings
# Returns:
#   The length of the longest string
#######################################
function _find_max_len() {
    local items=("$@")

    local max_len=0
    for item in "${items[@]}"; do
        if [[ ${#item} -gt $max_len ]]; then
            max_len=${#item}
        fi
    done

    echo "$max_len"
}

#######################################
# Check whether the given variable is an array or not.
# Arguments:
#   var_name: Name of the variable to check
# Returns:
#   0 if the variable is an array
#   1 if the variable is defined but not an array
#   2 if the variable is undefined
#######################################
function _is_array() {
    local var_name="$1"

    local var_signature=""
    var_signature="$(declare -p "$var_name" 2>/dev/null)"

    if [[ -z "$var_signature" ]]; then
        return 2
    fi

    local array_signature=""
    array_signature="$(echo "$var_signature" | grep -E '^declare -[aA]')"

    if [[ -n "$array_signature" ]]; then
        return 0
    else
        return 1
    fi
}

# =====================================
# Public functions
# =====================================
#######################################
# Print environment variables with a predefine format.
# Globals:
#   PROJECT_DIR
#   PROJECT_NAME
#   REMOTE_NAME
# Arguments:
#   var_names: Names of the variables to print
# Outputs:
#   Writes the environment variables info to STDOUT
#######################################
function dump_env() {
    local var_names=("$@")

    local all_var_names=("PROJECT_DIR" "PROJECT_NAME" "REMOTE_NAME")
    all_var_names+=("${var_names[@]}")

    local column_width=0
    column_width=$(_find_max_len "${all_var_names[@]}")
    column_width=$((column_width + 4))

    local separator
    separator="#$(printf "%0.s-" $(seq 1 79))"

    STACK_LEVEL=2 log_info "$separator"

    for var_name in "${all_var_names[@]}"; do
        _is_array "$var_name"
        local is_array=$?
        local line=""

        if [[ "$is_array" -eq 0 ]]; then
            declare -n arr_ref="$var_name"
            line="# $(printf "%-*s" $column_width "$var_name"): ${arr_ref[0]}"
            STACK_LEVEL=2 log_info "$line"

            for ((i = 1; i < ${#arr_ref[@]}; i++)); do
                line="# $(printf "%-*s" $column_width): ${arr_ref[$i]}"
                STACK_LEVEL=2 log_info "$line"
            done
        else
            line="# $(printf "%-*s" $column_width "$var_name"): ${!var_name}"
            STACK_LEVEL=2 log_info "$line"
        fi
        STACK_LEVEL=2 log_info "$separator"
    done
}

#######################################
# Print the entire command and run it if the DRY_RUN flag is set.
# Globals:
#   DRY_RUN
# Arguments:
#   cmd: The command to run
# Outputs:
#   Writes entire command to STDOUT
#######################################
function run_command() {
    local cmd=("$@")

    STACK_LEVEL=2 log_info "$(printf "Running: %s\n" "${cmd[*]}")"

    if [[ -z "$DRY_RUN" ]]; then
        "${cmd[@]}"
    fi
}
