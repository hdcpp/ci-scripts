#!/usr/bin/env bash
#
# Unit test suite for shared/utils.sh functions.
#

# =====================================
# Global constants & variables
# =====================================
# Heading separators
SEPARATOR_WIDTH=80
SEPARATOR_H0="$(printf "%0.s@" $(seq 1 $SEPARATOR_WIDTH))"
SEPARATOR_H1="$(printf "%0.s#" $(seq 1 $SEPARATOR_WIDTH))"
SEPARATOR_H2="$(printf "%0.s=" $(seq 1 $SEPARATOR_WIDTH))"
SEPARATOR_H3="$(printf "%0.s-" $(seq 1 $SEPARATOR_WIDTH))"
SEPARATOR_H4="$(printf "%0.s." $(seq 1 $SEPARATOR_WIDTH))"

# Table manifest
ROW_PREFIX="| "
ROW_SUFFIX=" |"
COL_SEPARATOR=" : "
TABLE_WIDTH=$((SEPARATOR_WIDTH - ${#ROW_PREFIX} - ${#ROW_SUFFIX}))

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null)"

# Test results
SKIPPED="SKIPPED"
PASSED="PASSED"
FAILED="FAILED"

# =====================================
# SUT Declaration
# =====================================
FUT_FILE="${PROJECT_DIR}/shared/utils.sh"
FUT_DEPENDENCIES=(
    "${PROJECT_DIR}/shared/constants.sh"
    "${PROJECT_DIR}/shared/logging.sh"
)

declare -A TEST_CASES=()
declare -A TEST_RESULTS=()

# =====================================
# Helper Functions
# =====================================
function load_sut() {
    local _summary

    _summary="FUT: $(realpath --relative-to "$PROJECT_DIR" "$FUT_FILE")"

    echo -e ""
    echo -e "$SEPARATOR_H2"
    echo -e "${BLUE}>> $_summary${NC}"
    echo -e "$SEPARATOR_H2"

    for _sut_dep in "${FUT_DEPENDENCIES[@]}"; do
        # shellcheck disable=SC1090,SC1091
        source "$_sut_dep"
    done

    # shellcheck disable=SC1090,SC1091
    source "$FUT_FILE"
}

function collect_tests() {
    local _tc_names_raw
    _tc_names_raw="$(declare -F | grep 'declare -f tc_' | awk '{print $3}')"

    mapfile -t _tc_names <<<"$_tc_names_raw"

    for _tc_name in "${_tc_names[@]}"; do
        _sut="${_tc_name#tc__}"
        _sut="${_sut%%__*}"

        if [[ ! -v "TEST_CASES[$_sut]" ]]; then
            declare -g -a "$_sut=()"
            TEST_CASES[$_sut]=1
        fi

        local -n _sut_ref="$_sut"
        _sut_ref+=("$_tc_name")
    done
}

function run_tests() {
    local -a _suts=()
    local -a _tc_names=()

    for _sut in "${!TEST_CASES[@]}"; do
        # shellcheck disable=SC2178
        local -n _sut_ref="$_sut"
        local _total_tc="${#_sut_ref[@]}"
        local _sut_summary="SUT: ${_sut} - ${_total_tc} test case(s)"

        echo -e ""
        echo -e "$SEPARATOR_H2"
        echo -e "${BLUE}>> ${_sut_summary}${NC}"
        echo -e "$SEPARATOR_H2"

        for _i in "${!_sut_ref[@]}"; do
            local _tc_no=$((_i + 1))
            local _tc_name="${_sut_ref[$_i]}"
            local _tc_summary="[${_tc_no}/${_total_tc}] TC: ${_tc_name}"

            echo -e "${CYAN}>> ${_tc_summary}${NC}"

            _suts+=("$_sut")
            _tc_names+=("$_tc_name")

            "$_tc_name"

            local _ret_code=$?
            if [[ $_ret_code -eq 0 ]]; then
                echo -e "${GREEN}[$PASSED] << ${_tc_summary}${NC}"
                TEST_RESULTS[$_tc_name]="$PASSED"
            else
                echo -e "${RED}[$FAILED] << ${_tc_summary}${NC}"
                TEST_RESULTS[$_tc_name]="$FAILED"
            fi

            echo -e "$SEPARATOR_H3"
        done

        echo -e "${BLUE}<< ${_sut_summary}${NC}"
        echo -e "$SEPARATOR_H2"
    done
}

function print_test_results__print_summary() {
    local _summary
    _summary="FUT: $(realpath --relative-to "$PROJECT_DIR" "$FUT_FILE")"

    local _pad_len=$(((TABLE_WIDTH - ${#_summary}) / 2))

    local _pad
    _pad="$(printf "%0.s " $(seq 1 $_pad_len))"

    local _line
    _line="$(printf "%-*s" "$TABLE_WIDTH" "${_pad}${_summary}")"

    echo -e ""
    echo -e "$SEPARATOR_H2"
    echo -e "${ROW_PREFIX}${_line}${ROW_SUFFIX}"
    echo -e "$SEPARATOR_H2"

}

function print_test_results__prepare_table_values() {
    _col1_values=("SUT")
    _col2_values=("Test Case")
    _col3_values=("Status")

    for _sut in "${!TEST_CASES[@]}"; do
        # shellcheck disable=SC2178
        local -n _sut_ref="$_sut"

        for _test_case in "${_sut_ref[@]}"; do
            _test_result="${TEST_RESULTS[$_test_case]}"

            _col1_values+=("$_sut")
            _col2_values+=("$_test_case")
            _col3_values+=("$_test_result")
        done
    done
}

function print_test_results__calc_column_widths() {
    for _item in "${_col1_values[@]}"; do
        if [[ ${#_item} -gt $_col1_width ]]; then
            _col1_width=${#_item}
        fi
    done

    for _item in "${_col3_values[@]}"; do
        if [[ ${#_item} -gt $_col3_width ]]; then
            _col3_width=${#_item}
        fi
    done

    _col2_width=$((TABLE_WIDTH - _col1_width - ${#COL_SEPARATOR}))
    _col2_width=$((_col2_width - _col3_width - ${#COL_SEPARATOR}))
}

function print_test_results__print_row() {
    local _row_color="$NC"
    if [[ "$_col3_value" == "$PASSED" ]]; then
        _row_color="$GREEN"
    elif [[ "$_col3_value" == "$FAILED" ]]; then
        _row_color="$RED"
    else
        _row_color="$YELLOW"
    fi

    local _line
    _line="${_row_color}$(printf "%-*s" "$_col1_width" "$_col1_value")"
    _line="${_line}${COL_SEPARATOR}"
    _line="${_line}$(printf "%-*s" "$_col2_width" "$_col2_value")"
    _line="${_line}${COL_SEPARATOR}"
    _line="${_line}$(printf "%-*s" "$_col3_width" "$_col3_value")${NC}"

    echo -e "${ROW_PREFIX}${_line}${ROW_SUFFIX}"
}

function print_test_results() {
    local -a _col1_values=()
    local -a _col2_values=()
    local -a _col3_values=()

    local _col1_width=0
    local _col2_width=0
    local _col3_width=0

    local _line

    print_test_results__print_summary
    print_test_results__prepare_table_values
    print_test_results__calc_column_widths

    for i in "${!_col1_values[@]}"; do
        local _col1_value="${_col1_values[$i]}"
        local _col2_value="${_col2_values[$i]}"
        local _col3_value="${_col3_values[$i]}"

        print_test_results__print_row

        if [[ $i -eq 0 ]]; then
            echo "$SEPARATOR_H3"
        else
            echo "$SEPARATOR_H4"
        fi
    done

    echo "$SEPARATOR_H2"
}

function assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="$3"

    if [[ "$expected" == "$actual" ]]; then
        return 0
    fi

    echo -e "${RED}[$FAILED] ${message}${NC}"
    echo -e "${CYAN}    Expected: '$expected'${NC}"
    echo -e "${YELLOW}      Actual: '$actual'${NC}"
    return 1
}
# =====================================
# Test Cases
# =====================================
function tc__find_max_len__success() {
    local -a items=("12345" "123" "1234567")
    local expected=7
    local actual=0

    actual="$(find_max_len "${items[@]}")"

    assert_equals "$expected" "$actual" "find maximum len of non-empty array"
}

function tc__find_max_len__emtpy_list() {
    return 0
}

function tc__find_max_len__mix_list() {
    return 0
}

function tc__is_array__success() {
    return 0
}

function tc__is_array__undefined() {
    return 0
}

function tc__is_array__non_array() {
    return 0
}

# =====================================
# Test Entry Point
# =====================================
function test_main() {
    set -e

    load_sut
    collect_tests
    run_tests
    print_test_results
}

test_main
