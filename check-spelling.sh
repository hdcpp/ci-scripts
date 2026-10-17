#!/usr/bin/env bash
#
# Check spelling using cspell.
#
# Directory product, doc and CMakeLists.txt shall be checked by default.
#

# =====================================
# Global constants & variables
# =====================================
SCRIPTS_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
SCRIPT_NAME="$(basename "$(realpath "${BASH_SOURCE[0]}")")"
SCRIPT_NAME=${SCRIPT_NAME%%.*}

export DRY_RUN=""

# =====================================
# Private functions
# =====================================
#######################################
# Print usage of this script.
# Globals:
#   SCRIPT_NAME
# Outputs:
#   Writes usage to STDOUT
#######################################
function _print_usage() {
    echo "Usage: $SCRIPT_NAME [OPTIONS]"
    echo "Check spelling using cspell."
    echo ""
    echo "    -d,--dry-run   Run the command without executing anything."
    echo "    -h,--help      Show this help."
    echo ""
    echo "Example:"
    echo "    $SCRIPT_NAME"
    echo "    $SCRIPT_NAME --dry-run"
    echo ""
}

#######################################
# Parse script's argument.
# Globals:
#   DRY_RUN
# Arguments:
#   script's argument
#######################################
function _parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
        -d | --dry-run)
            DRY_RUN="yes"
            shift
            ;;
        -h | --help)
            _print_usage
            exit
            ;;
        *)
            shift
            ;;
        esac
    done
}

#######################################
# Find target paths to check.
# Returns:
#   Path of targets have to be checked.
#######################################
function _find_target_paths() {
    local target_paths=()

    if [[ -d "${PROJECT_DIR}/doc" ]]; then
        target_paths+=("${PROJECT_DIR}/doc")
    fi

    if [[ -d "${PROJECT_DIR}/product" ]]; then
        target_paths+=("${PROJECT_DIR}/product")
    fi

    if [[ -f "${PROJECT_DIR}/CMakeLists.txt" ]]; then
        target_paths+=("${PROJECT_DIR}/CMakeLists.txt")
    fi

    if [[ -f "${PROJECT_DIR}/conanfile.py" ]]; then
        target_paths+=("${PROJECT_DIR}/conanfile.py")
    fi

    echo "${target_paths[@]}"
}

#######################################
# Ensure script's prerequisites are satisfied.
# Globals:
#   CSPELL_VERSION
#   CSPELL_EXEC
#######################################
function _check_prerequisites() {
    assert_empty CSPELL_VERSION
    assert_empty CSPELL_EXEC
}

# =====================================
# Public functions
# =====================================
#######################################
# Script main function.
# Globals:
#   DRY_RUN
# Arguments:
#   script's argument
#######################################
function main() {
    # shellcheck disable=SC1091
    source "${SCRIPTS_DIR}/shared/shared.sh"

    _parse_args "$@"

    IFS=" " read -r -a TARGET_PATHS <<<"$(_find_target_paths)"

    dump_env "CSPELL_VERSION" "TARGET_PATHS" "DRY_RUN"

    _check_prerequisites

    run_command "$CSPELL_EXEC" "--gitignore" "${TARGET_PATHS[@]}"
}

main "$@"
