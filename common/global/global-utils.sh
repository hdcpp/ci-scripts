#!/usr/bin/env bash
#
# Source      : common/global/global-utils.sh
# Dependencies: common/global/global-constants.sh
#               common/global/global-logging.sh
# Description : General utility helpers for cross-projects.
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
#######################################
# Print the table summary header and outer divider.
#
# Globals:
#   G__TABLE_WIDTH: Usable width of the formatted table.
#   G__DIVIDER_H2: Section divider string of '=' characters.
#   G__ROW_PREFIX: Prefix string for table row borders.
#   G__ROW_SUFFIX: Suffix string for table row borders.
#
# Arguments:
#   summary [in]: (optional) Summary text to print centered.
#   log_stack [in]: (optional) Stack depth for log output (default: 2).
#
# Returns:
#   0: On success.
#######################################
function _g_utils__print_table__print_summary() {
    local _summary="${1:-}"
    local _log_stack="${2:-2}"

    local _pad_len
    local _pad
    local _line

    _pad_len=$(((G__TABLE_WIDTH - ${#_summary}) / 2))
    _pad="$(printf "%0.s " $(seq 1 $_pad_len))"
    _line="$(printf "%-*s" "$G__TABLE_WIDTH" "${_pad}${_summary}")"

    g_logging__info "" "$_log_stack"
    g_logging__info "$G__DIVIDER_H2" "$_log_stack"

    if [[ -z "$_summary" ]]; then
        return 0
    fi

    g_logging__info "${G__ROW_PREFIX}${_line}${G__ROW_SUFFIX}" "$_log_stack"
    g_logging__info "$G__DIVIDER_H2" "$_log_stack"
}

#######################################
# Calculate column widths and adjust the full-width column to fit G__TABLE_WIDTH.
#
# Globals:
#   G__TABLE_WIDTH: Usable width of the formatted table.
#   G__COL_SEPARATOR_LEN: Character length of the column separator string.
#
# Arguments:
#   full_width_colx [in]: (optional) Index of column to expand (default: last column).
#######################################
function _g_utils__print_table_calc_col_widths() {
    local _full_width_colx="${1:-$((_ncols - 1))}"

    local _i
    local _colx
    local _col_width=0
    local _row_width=0

    # 1. Collect header lengths
    for _colx in $(seq 0 $((_ncols - 1))); do
        _col_widths[_colx]=${#_headers_iref[$_colx]}
    done

    # 2. Collect the maximum width of each column
    for _i in $(seq 0 $((_ncells - 1))); do
        _colx=$((_i % _ncols))

        local _col_value=${_rows_iref[$_i]}

        if [[ "$_col_value" == *$'\n'* ]]; then
            mapfile -t _col_value_lines <<<"$_col_value"

            for _col_value_line in "${_col_value_lines[@]}"; do
                if [[ ${#_col_value_line} -gt ${_col_widths[$_colx]} ]]; then
                    _col_widths[_colx]=${#_col_value_line}
                fi
            done
        elif [[ ${#_col_value} -gt ${_col_widths[$_colx]} ]]; then
            _col_widths[_colx]=${#_col_value}
        fi
    done

    # 3. Calculate width of the entire row
    for _colx in $(seq 0 $((_ncols - 1))); do
        _col_width=${_col_widths[$_colx]}
        _row_width=$((_row_width + _col_width))
    done
    _row_width=$((_row_width + (_ncols - 1) * G__COL_SEPARATOR_LEN))

    # 4. Make selected columns full width
    if [[ $_row_width -lt $G__TABLE_WIDTH ]]; then
        ((_col_widths[_full_width_colx] += (G__TABLE_WIDTH - _row_width)))
    fi
}

#######################################
# Print a single table row, wrapping or trimming lines as needed.
#
# Globals:
#   G__ROW_PREFIX: Prefix string for table row borders.
#   G__ROW_SUFFIX: Suffix string for table row borders.
#   G__COL_SEPARATOR: Separator string between table columns.
#   G__COL_SEPARATOR_LEN: Character length of the column separator string.
#
# Arguments:
#   log_stack [in]: Stack depth for log output.
#   col_values [in]: Values of columns in the row.
#######################################
function _g_utils__print_table_print_row() {
    local _log_stack=2
    local -a _col_values=()
    local -a _col_value_lines=()
    local _nsub_rows=1

    local _line
    local _colx
    local _col_value
    local _rowx

    if [[ $# -eq 0 ]]; then
        return
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -s | --stack)
            _log_stack="$2"
            shift 2
            ;;
        *)
            _col_values+=("$1")
            shift
            ;;
        esac
    done

    for _col_value in "${_col_values[@]}"; do
        if [[ "$_col_value" == *$'\n'* ]]; then
            mapfile -t _col_value_lines <<<"$_col_value"
            if [[ ${#_col_value_lines[@]} -gt $_nsub_rows ]]; then
                _nsub_rows=${#_col_value_lines[@]}
            fi
        fi
    done

    for _rowx in $(seq 0 $((_nsub_rows - 1))); do
        for _colx in "${!_col_widths[@]}"; do
            local _col_width="${_col_widths[$_colx]}"
            local _col_value="${_col_values[$_colx]}"

            mapfile -t _col_value_lines <<<"$_col_value"

            local _col_value_line=""
            if [[ ${#_col_value_lines[@]} -gt $_rowx ]]; then
                _col_value_line="${_col_value_lines[$_rowx]}"
            fi

            if [[ ${#_col_value_line} -gt $_col_width ]]; then
                local _trimmed_width=$((_col_width - G__COL_SEPARATOR_LEN))
                _col_value_line="...${_col_value_line: -_trimmed_width}"
            fi

            if [[ "$_colx" -eq 0 ]]; then
                _line="$(printf "%-*s" "$_col_width" "$_col_value_line")"
            else
                _line="${_line}${G__COL_SEPARATOR}$(printf "%-*s" "$_col_width" "$_col_value_line")"
            fi
        done

        g_logging__info "${G__ROW_PREFIX}${_line}${G__ROW_SUFFIX}" "$_log_stack"
    done
}

# =============================================================================
# Public Functions
# =============================================================================
#######################################
# Check whether the given string is a declared variable.
#
# Arguments:
#   str [in]: String identifier of the variable to check.
#
# Returns:
#   0: The string is a declared variable.
#   1: The string is not a declared variable.
#######################################
function g_utils__is_var() {
    local _str="$1"

    local _signature=""
    _signature="$(declare -p "$_str" 2>/dev/null)"

    if [[ -n "$_signature" ]]; then
        return 0
    else
        return 1
    fi
}

#######################################
# Check whether the given string is an array.
#
# Arguments:
#   str [in]: String identifier of the variable to check.
#
# Returns:
#   0: The variable is an indexed or associative array.
#   1: The variable is not an array.
#   2: The variable is undefined.
#######################################
function g_utils__is_array() {
    local _str="$1"

    local _signature=""
    _signature="$(declare -p "$_str" 2>/dev/null)"

    if [[ -z "$_signature" ]]; then
        return 2
    fi

    if [[ "$_signature" =~ ^declare\ -[aA] ]]; then
        return 0
    else
        return 1
    fi
}

#######################################
# Find the maximum string length across an array of strings.
#
# Arguments:
#   items [in]: Array of string items to measure.
#######################################
function g_utils__find_max_len() {
    local _items=("$@")

    local _max_len=0
    local _item
    for _item in "${_items[@]}"; do
        if [[ ${#_item} -gt $_max_len ]]; then
            _max_len=${#_item}
        fi
    done

    echo "$_max_len"
}

#######################################
# Print an ASCII table with headers, rows, and borders.
#
# Globals:
#   G__DIVIDER_H2: Section divider string of '=' characters.
#   G__DIVIDER_H3: Section divider string of '-' characters.
#   G__DIVIDER_H4: Section divider string of '.' characters.
#
# Arguments:
#   summary [in]: Summary text centered at the top of the table.
#   headers_var_name [in]: Name of array variable containing header titles.
#   rows_var_name [in]: Name of array variable containing flattened row cells.
#   log_stack [in]: (optional) Stack depth for log output (default: 3).
#######################################
function g_utils__print_table() {
    local _summary="$1"
    local _headers_var_name="$2"
    local _rows_var_name="$3"
    local _log_stack="${4:-3}"

    local -n _headers_iref="$_headers_var_name"
    local -n _rows_iref="$_rows_var_name"

    local _ncols=${#_headers_iref[@]}
    local _ncells=${#_rows_iref[@]}
    local _nrows=$((_ncells / _ncols))

    local -a _col_widths=()

    _g_utils__print_table__print_summary "$_summary" "$_log_stack"
    _g_utils__print_table_calc_col_widths

    local _has_header=0
    for _header in "${_headers_iref[@]}"; do
        if [[ -n "$_header" ]]; then
            _has_header=1
            break
        fi
    done

    if [[ $_has_header -ne 0 ]]; then
        _g_utils__print_table_print_row -s "$_log_stack" "${_headers_iref[@]}"
    fi

    local _rowx
    for _rowx in $(seq 0 $((_nrows - 1))); do
        if [[ $_rowx -eq 0 ]]; then
            if [[ $_has_header -ne 0 ]]; then
                g_logging__info "$G__DIVIDER_H3" $((_log_stack - 1))
            fi
        else
            g_logging__info "$G__DIVIDER_H4" $((_log_stack - 1))
        fi

        _g_utils__print_table_print_row -s "$_log_stack" "${_rows_iref[@]:_rowx*_ncols:_ncols}"
    done
    g_logging__info "$G__DIVIDER_H2" $((_log_stack - 1))
}

#######################################
# Print a table with environment variables in a predefined format.
#
# Arguments:
#   summary [in]: (optional) Summary title displayed above the table.
#   var_names [in]: Additional variable names to display.
#######################################
function g_utils__print_env_vars() {
    local _TABLE_HEADERS=("Name" "Value")

    local -a _var_names=()
    local -a _table_rows=()
    local _log_stack=4

    local _summary
    local _ret_code
    local _var_name

    if [[ $# -eq 0 ]]; then
        return
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -n | --summary)
            _summary="$2"
            shift 2
            ;;
        -s | --stack)
            _log_stack="$2"
            shift 2
            ;;
        *)
            _var_names+=("$1")
            shift
            ;;
        esac
    done

    for _var_name in "${_var_names[@]}"; do
        local _is_var
        local _is_array

        g_utils__is_var "$_var_name"
        _is_var=$?

        g_utils__is_array "$_var_name"
        _is_array=$?

        if [[ "$_is_array" -eq 0 ]]; then
            declare -n _arr_iref="$_var_name"
            _table_rows+=("$_var_name" "$(
                IFS=$'\n'
                echo "${_arr_iref[*]}"
            )")
        elif [[ "$_is_var" -eq 0 ]]; then
            _table_rows+=("$_var_name" "${!_var_name}")
        fi
    done

    g_utils__print_table "$_summary" "_TABLE_HEADERS" "_table_rows" "$_log_stack"
}

#######################################
# Print the entire command and run it if the dry-run flag is not set.
#
# Arguments:
#   cmd [in]: The command and its arguments to run.
#
# Returns:
#   0: Command executed successfully or dry-run mode is active.
#   <Return code>: Exit code of the executed command on failure.
#######################################
function g_utils__run_command() {
    local _cmd=("$@")

    local _log_stack=2

    if [[ -z "${DRY_RUN:-}" ]]; then
        eval "${_cmd[*]}"
    else
        g_logging__info "$(printf "Running: %s\n" "${_cmd[*]}")" "$_log_stack"
    fi
}
