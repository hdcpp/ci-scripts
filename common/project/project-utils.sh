#!/usr/bin/env bash
#
# Source      : common/project/project-utils.sh
# Dependencies: common/global/global-logging.sh
#               common/global/global-utils.sh
#               common/project/project-constants.sh
# Description : Project-level utility helpers.
#

# =============================================================================
# Global Constants
# =============================================================================

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
# Print a table with environment variables in a predefined format.
#
# Arguments:
#   summary [in]: (optional) Summary title displayed above the table.
#   var_names [in]: Additional variable names to display.
#######################################
function p_utils__print_env_vars() {
    local _summary="${1:-}"

    local _log_stack=4

    local _ret_code
    g_utils__is_var "$_summary"
    _ret_code=$?
    if [[ "$_ret_code" -ne 0 ]]; then
        shift
    else
        _summary=""
    fi

    local _var_names=("$@")

    local _all_var_names=(
        "G__ROOT_PROJECT_DIR"
        "G__ROOT_PROJECT_NAME"
        "G__ROOT_REMOTE_NAME"
        "G__ROOT_BRANCH_NAME"
        "G__ROOT_COMMIT_HASH"
    )
    _all_var_names+=("${_var_names[@]}")

    g_utils__print_env_vars -n "$_summary" -s 5 "${_all_var_names[@]}"
}

#######################################
# Load pipeline configuration file.
#
# Arguments:
#   config_file [in]: Path of the configuration file to load.
#   ret_val_vref [out]: Reference to scalar variable receiving resolved configuration path.
#######################################
function p_utils__load_config() {
    local _config_file="$1"
    local -n _ret_val_vref="$2"

    local _log_stack=2

    if [[ ! -f "$_config_file" ]]; then
        g_logging__warn ">> Configuration file not found: '${_config_file}'" "$_log_stack"
        g_logging__warn "   Fall back to default config file: '${G__DEFAULT_CONFIG_FILE}'" "$_log_stack"
        _config_file="$G__DEFAULT_CONFIG_FILE"
    fi

    g_logging__info "Load configuration file '$_config_file'" "$_log_stack"
    _ret_val_vref="$_config_file"

    # shellcheck disable=SC1090,SC1091
    source "$_config_file"
}
