#!/usr/bin/env bash
#
# Source      : common/global/global-tests.sh
# Dependencies: common/global/global-constants.sh
# Description : Testing framework.
#

# =============================================================================
# Global Constants
# =============================================================================
PASSED="PASSED"
FAILED="FAILED"

# =============================================================================
# Global Variables
# =============================================================================
declare -A TEST_CASES=()
declare -A TEST_RESULTS=()

# =============================================================================
# Private Functions
# =============================================================================
#######################################
# Load and source the File Under Test (FUT) and its dependencies.
#
# Globals:
#   G__DIVIDER_H2: Section divider string of '=' characters.
#   G__BLUE: Blue terminal ANSI escape sequence.
#   G__WHITE: White terminal ANSI escape sequence.
#   G__NC: Terminal reset ANSI sequence.
#
# Arguments:
#   fut_path [in]: Path to the File Under Test (FUT) script.
#   fut_deps [in]: (optional) Paths of dependency scripts required by the FUT.
#######################################
function _load_sut() {
    local _fut_path="$1"
    shift
    local _fut_deps=("$@")

    local _fut_dep

    echo "Loading FUT..."
    if [[ ! -f "$_fut_path" ]]; then
        echo "  FUT does not exist: $_fut_path"
        return 1
    fi

    echo "Loading FUT dependencies..."
    for _fut_dep in "${_fut_deps[@]}"; do
        if [[ ! -f "$_fut_dep" ]]; then
            echo "  FUT dependency does not exist: $_fut_dep"
            return 1
        fi

        # shellcheck disable=SC1090,SC1091
        source "$_fut_dep"
    done
    echo "FUT dependencies are loaded successfully"

    # shellcheck disable=SC1090,SC1091
    source "$_fut_path"
    echo "FUT is loaded successfully"

    echo ""
    echo "$G__DIVIDER_H2"
    echo -e "${G__BLUE}>> FUT: ${_fut_path}${G__NC}"
    for _fut_dep in "${_fut_deps[@]}"; do
        echo -e "${G__WHITE}     - ${_fut_dep}${G__NC}"
    done
    echo "$G__DIVIDER_H2"
}

#######################################
# Discover and group test functions starting with 'tc_' by their SUT.
#
# Globals:
#   TEST_CASES: Associative array mapping discovered SUT names to test cases.
#   G__CYAN: Cyan terminal ANSI escape sequence.
#   G__NC: Terminal reset ANSI sequence.
#
# Returns:
#   0: Test discovery completed or no test cases found.
#######################################
function _collect_tests() {
    local -a _fut_tc_names=()

    local _fut_tc_names_raw
    local _tc_name
    local _sut_names
    local _sut_name

    echo "Finding test cases..."

    _fut_tc_names_raw="$(declare -F | grep 'declare -f tc_' | sort | awk '{print $3}')"

    if [[ -z "$_fut_tc_names_raw" ]]; then
        echo -e "${G__YELLOW}No test case is found. All test cases should start with 'tc_' to be able to recognize${G__NC}"
        return 0
    fi

    mapfile -t _fut_tc_names <<<"$_fut_tc_names_raw"

    for _tc_name in "${_fut_tc_names[@]}"; do
        _sut_name="${_tc_name#tc__}"
        _sut_name="${_sut_name%%__*}"

        if [[ ! -v "TEST_CASES[$_sut_name]" ]]; then
            declare -g -a "$_sut_name=()"
            TEST_CASES["$_sut_name"]=1
        fi

        local -n _sut_ref="$_sut_name"
        _sut_ref+=("$_tc_name")
    done

    mapfile -t _sut_names < <(printf "%s\n" "${!TEST_CASES[@]}" | sort)
    for _sut_name in "${_sut_names[@]}"; do
        local _tc_idx

        # shellcheck disable=SC2178
        local -n _sut_ref="$_sut_name"

        echo -e "${G__CYAN}>> SUT: $_sut_name - ${#_sut_ref[@]} TCs${G__NC}"

        for _tc_idx in "${!_sut_ref[@]}"; do
            echo "     $((_tc_idx + 1)). ${_sut_ref[$_tc_idx]}"
        done
    done

    echo "Total SUTs: ${#TEST_CASES[@]}"
    echo "Total TCs: ${#_fut_tc_names[@]}"
}

#######################################
# Execute all collected test cases grouped by SUT and record the results.
#
# Globals:
#   TEST_CASES: Associative array mapping discovered SUT names to test cases.
#   TEST_RESULTS: Associative array storing execution status of each test case.
#   PASSED: Constant string indicating a passed test result.
#   FAILED: Constant string indicating a failed test result.
#   G__DIVIDER_H2: Section divider string of '=' characters.
#   G__DIVIDER_H3: Section divider string of '-' characters.
#   G__CYAN: Cyan terminal ANSI escape sequence.
#   G__GREEN: Green terminal ANSI escape sequence.
#   G__NC: Terminal reset ANSI sequence.
#######################################
function _run_tests() {
    local _total_suts="${#TEST_CASES[@]}"
    local _sut_no=1
    local _sut_result_color="$G__GREEN"

    local _ret_code=0
    local _sut_names
    local _sut_name

    mapfile -t _sut_names < <(printf "%s\n" "${!TEST_CASES[@]}" | sort)
    for _sut_name in "${_sut_names[@]}"; do
        # shellcheck disable=SC2178
        local -n _sut_ref="$_sut_name"

        local _total_tcs="${#_sut_ref[@]}"
        local _tc_idx

        echo ""
        echo "$G__DIVIDER_H2"
        echo -e "${G__CYAN}>> START SUT: [${_sut_no}/${_total_suts}] ${_sut_name}${G__NC}"
        echo "$G__DIVIDER_H2"

        for _idx in "${!_sut_ref[@]}"; do
            local _tc_name="${_sut_ref[$_idx]}"
            local _tc_summary="[$((_idx + 1))/${_total_tcs}] TC: ${_tc_name}"

            local _tc_return_code
            local _tc_result_color

            echo -e "${G__CYAN}  ++ TC: [$((_idx + 1))/${_total_tcs}] ${_tc_name}${G__NC}"

            "$_tc_name"
            _tc_return_code=$?

            if [[ $_tc_return_code -eq 0 ]]; then
                _tc_result_color="$G__GREEN"
                TEST_RESULTS[$_tc_name]="$PASSED"
            else
                _tc_result_color="$G__RED"
                _sut_result_color="$G__RED"
                TEST_RESULTS[$_tc_name]="$FAILED"
                _ret_code=1
            fi

            echo "$G__DIVIDER_H3"
        done

        echo -e "${_sut_result_color}>> END SUT: [${_sut_no}/${_total_suts}] ${_sut_name}${G__NC}"
        echo "$G__DIVIDER_H2"

        _sut_no=$((_sut_no + 1))
    done

    return "$_ret_code"
}

#######################################
# Print a formatted summary table of all test case execution results.
#
# Globals:
#   G__DIVIDER_H2: Section divider string of '=' characters.
#   G__DIVIDER_H3: Section divider string of '-' characters.
#   G__DIVIDER_H4: Section divider string of '.' characters.
#   G__WHITE: White terminal ANSI escape sequence.
#   G__NC: Terminal reset ANSI sequence.
#
# Arguments:
#   fut_path [in]: Path to the File Under Test (FUT) script.
#######################################
function _print_test_results() {
    local _fut_path="${1}"

    local -a _col1_values=()
    local -a _col2_values=()
    local -a _col3_values=()

    local _col1_width=0
    local _col2_width=0
    local _col3_width=0

    local _total_passed=0
    local _total_failed=0

    local _line
    local _rowx

    _print_test_results__print_summary "$_fut_path"
    _print_test_results__prepare_table_values
    _print_test_results__calc_column_widths

    for _rowx in "${!_col1_values[@]}"; do
        local _col1_value="${_col1_values[$_rowx]}"
        local _col2_value="${_col2_values[$_rowx]}"
        local _col3_value="${_col3_values[$_rowx]}"

        if [[ "$_col3_value" == "$PASSED" ]]; then
            _total_passed=$((_total_passed + 1))
        elif [[ "$_col3_value" == "$FAILED" ]]; then
            _total_failed=$((_total_failed + 1))
        fi

        _print_test_results__print_row

        if [[ $_rowx -eq 0 ]]; then
            echo -e "${G__WHITE}${G__DIVIDER_H3}${G__NC}"
        else
            echo -e "${G__WHITE}${G__DIVIDER_H4}${G__NC}"
        fi
    done

    echo -e "Total passed: ${G__GREEN}${_total_passed} TCs${G__NC}"
    echo -e "Total failed: ${G__RED}${_total_failed} TCs${G__NC}"
    echo -e "${G__WHITE}${G__DIVIDER_H2}${G__NC}"
}

#######################################
# Print the test summary banner displaying the path of the FUT.
#
# Globals:
#   G__DIVIDER_H2: Section divider string of '=' characters.
#   G__ROW_PREFIX: Prefix string for table row borders.
#   G__ROW_SUFFIX: Suffix string for table row borders.
#   G__WHITE: White terminal ANSI escape sequence.
#   G__NC: Terminal reset ANSI sequence.
#
# Arguments:
#   fut_path [in]: Path to the File Under Test (FUT) script.
#######################################
function _print_test_results__print_summary() {
    local _fut_path="${1}"

    local _summary="FUT: $_fut_path"
    local _pad_len=$(((G__TABLE_WIDTH - ${#_summary}) / 2))

    local _pad
    local _line

    _pad="$(printf "%0.s " $(seq 1 $_pad_len))"
    _line="$(printf "%-*s" "$G__TABLE_WIDTH" "${_pad}${_summary}")"

    echo ""
    echo -e "${G__WHITE}${G__DIVIDER_H2}${G__NC}"
    echo -e "${G__WHITE}${G__ROW_PREFIX}${_line}${G__ROW_SUFFIX}${G__NC}"
    echo -e "${G__WHITE}${G__DIVIDER_H2}${G__NC}"
}

#######################################
# Populate table column value arrays with headers and test case execution statuses.
#
# Globals:
#   TEST_CASES: Associative array mapping discovered SUT names to test cases.
#   TEST_RESULTS: Associative array storing execution status of each test case.
#######################################
function _print_test_results__prepare_table_values() {
    _col1_values=("SUT")
    _col2_values=("Test Case")
    _col3_values=("Status")

    local _sut_names
    local _sut_name
    mapfile -t _sut_names < <(printf "%s\n" "${!TEST_CASES[@]}" | sort)

    for _sut_name in "${_sut_names[@]}"; do
        # shellcheck disable=SC2178
        local -n _sut_ref="$_sut_name"

        local _tc_name

        for _tc_name in "${_sut_ref[@]}"; do
            _test_result="${TEST_RESULTS[$_tc_name]}"

            _col1_values+=("$_sut_name")
            _col2_values+=("$_tc_name")
            _col3_values+=("$_test_result")
        done
    done
}

#######################################
# Calculate column widths for the test results table.
#
# Globals:
#   G__TABLE_WIDTH: Usable width of the formatted table.
#   G__COL_SEPARATOR_LEN: Character length of the column separator string.
#######################################
function _print_test_results__calc_column_widths() {
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

    _col2_width=$((G__TABLE_WIDTH - _col1_width - G__COL_SEPARATOR_LEN))
    _col2_width=$((_col2_width - _col3_width - G__COL_SEPARATOR_LEN))
}

#######################################
# Print a formatted row of the test results table with status-based color styling.
#
# Globals:
#   PASSED: Constant string indicating a passed test result.
#   FAILED: Constant string indicating a failed test result.
#   G__ROW_PREFIX: Prefix string for table row borders.
#   G__ROW_SUFFIX: Suffix string for table row borders.
#   G__COL_SEPARATOR: Separator string between table columns.
#   G__GREEN: Green terminal ANSI escape sequence.
#   G__RED: Red terminal ANSI escape sequence.
#   G__YELLOW: Yellow terminal ANSI escape sequence.
#   G__NC: Terminal reset ANSI sequence.
#######################################
function _print_test_results__print_row() {
    local _row_color="$G__NC"

    local _line

    if [[ "$_col3_value" == "$PASSED" ]]; then
        _row_color="$G__GREEN"
    elif [[ "$_col3_value" == "$FAILED" ]]; then
        _row_color="$G__RED"
    else
        _row_color="$G__YELLOW"
    fi

    _line="${_row_color}$(printf "%-*s" "$_col1_width" "$_col1_value")"
    _line="${_line}${G__COL_SEPARATOR}"
    _line="${_line}$(printf "%-*s" "$_col2_width" "$_col2_value")"
    _line="${_line}${G__COL_SEPARATOR}"
    _line="${_line}$(printf "%-*s" "$_col3_width" "$_col3_value")${G__NC}"

    echo "${G__ROW_PREFIX}${_line}${G__ROW_SUFFIX}"
}

# =============================================================================
# Public Functions
# =============================================================================
#######################################
# Assert equality between expected and actual values.
#
# Arguments:
#   expected [in]: Expected value.
#   actual [in]: Actual value to compare against expected.
#######################################
function tests__eq() {
    local _expected="$1"
    local _actual="$2"

    if [[ "$_expected" == "$_actual" ]]; then
        return 0
    fi

    g_logging__error "Assertion failed: values are not equal"
    g_logging__info "${G__CYAN}  Expected: '${_expected}'${G__NC}"
    g_logging__info "${G__MAGENTA}    Actual: '${_actual}'${G__NC}"
}

# =====================================
# Test Entry Point
# =====================================
#######################################
# Execute the main test suite workflow for a given File Under Test (FUT).
#
# Globals:
#   G__CYAN: Cyan terminal ANSI escape sequence.
#   G__NC: Terminal reset ANSI sequence.
#
# Arguments:
#   fut_path [in]: Path to the File Under Test (FUT) script.
#   fut_deps [in]: (optional) Paths of dependency scripts required by the FUT.
#######################################
function test_main() {
    if [[ $# -lt 1 ]]; then
        echo "Must provide FUT path"
        return 1
    fi

    local _fut_path="${1}"
    shift
    local _fut_deps=("$@")

    local _ret_code

    echo -e "${G__CYAN}----- START TESTS -----${G__NC}"

    _load_sut "$_fut_path" "${_fut_deps[@]}"

    _collect_tests
    _run_tests
    _ret_code=$?
    _print_test_results "$_fut_path"

    echo -e "${G__CYAN}----- END TESTS -----${G__NC}"

    return "$_ret_code"
}
