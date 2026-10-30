#!/usr/bin/env bash
#
# Source      : common/project/common.sh
# Dependencies: common/global/global-constants.sh
#               common/project/constants.sh
# Description : Shared legacy adapter utilities for local Pull Request pipeline
#               stages. Provides environment setup, result recording, JSON artifact
#               generation, and summary reporting.
#
set -u

# =============================================================================
# Global Constants
# =============================================================================
LIB_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
DANG_DIR="$(realpath "${LIB_DIR}/..")"
REPO_ROOT="$(git -C "${DANG_DIR}/.." rev-parse --show-toplevel 2>/tmp/git_root_err.log || realpath "${DANG_DIR}/..")"
CONFIG_FILE="$G__DEFAULT_CONFIG_FILE"
LOG_DIR="${REPO_ROOT}/_build/logs"
mkdir -p "${LOG_DIR}"

if [[ -f "${CONFIG_FILE}" ]]; then
    # shellcheck disable=SC1090,SC1091
    source "${CONFIG_FILE}"
fi

# ANSI escape sequences for terminal output colors (exported for stages)
export RED="${G__RED:-$'\033[0;31m'}"
export GREEN="${G__GREEN:-$'\033[0;32m'}"
export YELLOW="${G__YELLOW:-$'\033[0;33m'}"
export BLUE="${G__BLUE:-$'\033[0;34m'}"
export CYAN="${G__CYAN:-$'\033[0;36m'}"
export G__BOLD="${G__BOLD:-$'\033[1m'}"
export NC="${G__NC:-$'\033[0m'}"

# =============================================================================
# Global Variables
# =============================================================================
BRANCH_NAME="$(git -C "${REPO_ROOT}" rev-parse --abbrev-ref HEAD 2>"${LOG_DIR}/git.log" || echo "unknown")"
COMMIT_HASH="$(git -C "${REPO_ROOT}" rev-parse HEAD 2>"${LOG_DIR}/git.log" || echo "unknown")"
TIMESTAMP="$(date +"%Y-%m-%d %H:%M:%S")"

TOTAL_RUN=0
TOTAL_PASSED=0
TOTAL_FAILED=0

RESULTS_STATUS=()
RESULTS_TARGET=()
RESULTS_STEP=()
RESULTS_DETAILS=()

# =============================================================================
# Private Functions
# =============================================================================

# =============================================================================
# Public Functions
# =============================================================================
#######################################
# Check whether an executable command exists in PATH.
#
# Arguments:
#   cmd [in]: Name of the command to locate.
#
# Returns:
#   0: Command exists in PATH.
#   1: Command was not found.
#######################################
function has_command() {
    local _cmd="$1"
    command -v "${_cmd}" >"${LOG_DIR}/cmd_check.log" 2>&1
    return $?
}

#######################################
# Initialize stage output directory and write environment status JSON files.
#
# Arguments:
#   stage_title [in]: Title of the pipeline stage.
#   stage_dir [in]: Subdirectory under build directory for stage artifacts.
#   extra_pipeline_json [in]: (optional) Additional JSON metadata to merge (default: "{}").
#######################################
function init_stage_env() {
    local _stage_title="$1"
    local _stage_dir="$2"
    local _extra_pipeline_json="${3:-"{}"}"

    local _target_dir="${REPO_ROOT}/_build/${_stage_dir}"
    mkdir -p "${_target_dir}"

    if has_command jq; then
        jq -n \
            --arg job "${_stage_title} (Local)" \
            --arg branch "${BRANCH_NAME}" \
            --arg commit "${COMMIT_HASH}" \
            --arg timestamp "${TIMESTAMP}" \
            '{
                JOB_NAME: $job,
                BRANCH_NAME: $branch,
                GIT_COMMIT: $commit,
                TIMESTAMP: $timestamp,
                JENKINS_URL: "local",
                BUILD_TAG: "local-run"
            }' >"${_target_dir}/environment.json"

        local _base_pipeline_json
        _base_pipeline_json="$(jq -n \
            --arg branch "${BRANCH_NAME}" \
            --arg commit "${COMMIT_HASH}" \
            '{
                cycurhsm_source_branch: $branch,
                cycurhsm_source_hash: $commit,
                cycurhsm_target_branch: "master",
                cycurhsm_target_hash: $commit
            }')"

        echo "${_base_pipeline_json}" |
            jq --argjson extra "${_extra_pipeline_json}" '. + $extra' \
                >"${_target_dir}/pipeline_status.json"
    else
        cat <<EOF >"${_target_dir}/environment.json"
{
  "JOB_NAME": "${_stage_title} (Local)",
  "BRANCH_NAME": "${BRANCH_NAME}",
  "GIT_COMMIT": "${COMMIT_HASH}",
  "TIMESTAMP": "${TIMESTAMP}",
  "JENKINS_URL": "local",
  "BUILD_TAG": "local-run"
}
EOF

        cat <<EOF >"${_target_dir}/pipeline_status.json"
{
  "cycurhsm_source_branch": "${BRANCH_NAME}",
  "cycurhsm_source_hash": "${COMMIT_HASH}",
  "cycurhsm_target_branch": "master",
  "cycurhsm_target_hash": "${COMMIT_HASH}"
}
EOF
    fi
}

#######################################
# Print a formatted stage execution banner with branch and commit details.
#
# Arguments:
#   stage_index [in]: Stage index number (e.g., "00").
#   stage_title [in]: Stage title text.
#   details [in]: (optional) Additional detail lines to print in the banner.
#######################################
function print_stage_banner() {
    local _stage_index="$1"
    local _stage_title="$2"
    shift 2

    echo "========================================================================"
    echo -e "${G__BOLD} [Stage ${_stage_index}] ${_stage_title}${G__NC}"
    echo "========================================================================"
    echo -e " Branch         : ${BRANCH_NAME}"
    echo -e " Commit         : ${COMMIT_HASH:0:12}"
    while [[ $# -gt 0 ]]; do
        echo -e " $1"
        shift
    done
    echo "========================================================================"
}

#######################################
# Record a step result and update stage pass/fail counters.
#
# Arguments:
#   status [in]: Result status ("PASSED" or "FAILED").
#   target [in]: Hardware target name or "ALL".
#   step [in]: Name of the step or task executed.
#   details [in]: Description or outcome details.
#######################################
function record_result() {
    local _status="$1"
    local _target="$2"
    local _step="$3"
    local _details="$4"

    TOTAL_RUN=$((TOTAL_RUN + 1))
    RESULTS_STATUS+=("${_status}")
    RESULTS_TARGET+=("${_target}")
    RESULTS_STEP+=("${_step}")
    RESULTS_DETAILS+=("${_details}")

    if [[ "${_status}" == "PASSED" ]]; then
        TOTAL_PASSED=$((TOTAL_PASSED + 1))
    else
        TOTAL_FAILED=$((TOTAL_FAILED + 1))
    fi
}

#######################################
# Write a simple result JSON artifact file for dashboard consumption.
#
# Arguments:
#   json_path [in]: Path to destination JSON artifact file.
#   title [in]: Result title string.
#   is_successful [in]: Boolean string ("true" or "false").
#   message [in]: Short summary message.
#   details [in]: Extended message details.
#######################################
function save_simple_result() {
    local _json_path="$1"
    local _title="$2"
    local _is_successful="$3"
    local _message="$4"
    local _details="$5"

    local _parent_dir
    _parent_dir="$(dirname "${_json_path}")"
    mkdir -p "${_parent_dir}"

    cat <<EOF >"${_json_path}"
{
  "title": "${_title}",
  "successful": ${_is_successful},
  "message": "${_message}",
  "details": "${_details}",
  "url": null
}
EOF
}

#######################################
# Print a summary table of stage results and return exit code based on failures.
#
# Arguments:
#   stage_title [in]: Stage title string.
#
# Returns:
#   0: All stage checks passed.
#   1: One or more checks failed.
#######################################
function print_stage_summary() {
    local _stage_title="$1"

    echo ""
    echo "========================================================================"
    echo -e "${G__BOLD} Summary: ${_stage_title}${G__NC}"
    echo "========================================================================"
    printf "| %-3s | %-8s | %-16s | %-32s | %-24s |\n" "No." "Status" "Target" "Step / Task" "Details"
    printf "| %-3s | %-8s | %-16s | %-32s | %-24s |\n" \
        "---" "--------" "----------------" "--------------------------------" "------------------------"

    local _i
    for _i in "${!RESULTS_STATUS[@]}"; do
        local _no=$((_i + 1))
        local _st="${RESULTS_STATUS[$_i]}"
        local _tg="${RESULTS_TARGET[$_i]}"
        local _sp="${RESULTS_STEP[$_i]}"
        local _dt="${RESULTS_DETAILS[$_i]}"

        printf "| %-3d | " "$_no"
        if [[ "${_st}" == "PASSED" ]]; then
            printf "${GREEN}%-8s${G__NC}" "$_st"
        else
            printf "${RED}%-8s${G__NC}" "$_st"
        fi
        printf " | %-16s | %-32s | %-24s |\n" "${_tg:0:16}" "${_sp:0:32}" "${_dt:0:24}"
    done

    echo ""
    echo " Total checks   : ${TOTAL_RUN}"
    echo -e " Passed checks  : ${GREEN}${TOTAL_PASSED}${G__NC}"
    echo -e " Failed checks  : ${RED}${TOTAL_FAILED}${G__NC}"
    echo ""

    if [[ ${TOTAL_FAILED} -eq 0 ]]; then
        echo -e "${GREEN}>> All checks in '${_stage_title}' PASSED!${G__NC}"
        return 0
    else
        echo -e "${RED}>> Some checks in '${_stage_title}' FAILED!${G__NC}"
        return 1
    fi
}
