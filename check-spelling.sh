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

    dump_env CSPELL_VERSION DRY_RUN
}

#######################################
# Find target paths to check.
# Returns:
#   Path of targets have to be checked.
#######################################
function _find_target_paths() {
    local target_paths=()

    local doc_dir="${PROJECT_DIR}/doc"
    if [[ -d "$doc_dir" ]]; then
        log_info "Detected '$doc_dir'"
        target_paths+=("$doc_dir")
    fi

    local product_dir="${PROJECT_DIR}/product"
    if [[ -d "$product_dir" ]]; then
        log_info "Detected '$product_dir'"
        target_paths+=("$product_dir")
    fi

    local cmake_file="${PROJECT_DIR}/CMakeLists.txt"
    if [[ -f "$cmake_file" ]]; then
        log_info "Detected '$cmake_file'"
        target_paths+=("$cmake_file")
    fi

    local conan_file="${PROJECT_DIR}/conanfile.py"
    if [[ -f "$conan_file" ]]; then
        log_info "Detected '$conan_file'"
        target_paths+=("$conan_file")
    fi

    FUNC_STDOUT="${target_paths[*]}"
}

#######################################
# Ensure script's prerequisites are satisfied.
# Globals:
#   CSPELL_VERSION
#   CSPELL_EXEC
#######################################
function _check_prerequisites() {
    log_info "Check if cspell is installed"

    assert_empty CSPELL_VERSION
    assert_empty CSPELL_EXEC

    log_info "Check if cspell is installed...OK"
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

    _find_target_paths
    IFS=" " read -r -a target_paths <<<"$FUNC_STDOUT"

    _check_prerequisites

    run_command "$CSPELL_EXEC" "--gitignore" "${target_paths[@]}"
    return $?
}

main "$@"

EXIT_CODE=$?
if [[ "$EXIT_CODE" -eq 0 ]]; then
    log_info "PASSED"
else
    log_error "FAILED ($EXIT_CODE)"
fi
