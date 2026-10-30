#!/usr/bin/env bash
#
# Check format using clang-format.
#
# Directory product shall be checked by default.
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
    echo "Check format using clang-format."
    echo ""
    echo "    -f,--fix       Fix clang-format issues."
    echo "    -d,--dry-run   Run the command without executing anything."
    echo "    -h,--help      Show this help."
    echo ""
    echo "Example:"
    echo "    $SCRIPT_NAME"
    echo "    $SCRIPT_NAME --fix"
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
        -f | --fix)
            SHOULD_FIX="yes"
            shift
            ;;
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

    dump_env CLANG_FORMAT_VERSION SHOULD_FIX DRY_RUN
}

#######################################
# Find target paths to check.
# Returns:
#   Path of targets have to be checked.
#######################################
function _find_target_paths() {
    local target_paths=()

    local product_dir="${PROJECT_DIR}/product"
    if [[ -d "$product_dir" ]]; then
        log_info "Detected '$product_dir'"
        target_paths+=("$product_dir")
    fi

    FUNC_STDOUT="${target_paths[*]}"
}

#######################################
# Ensure script's prerequisites are satisfied.
# Globals:
#   CLANG_FORMAT_VERSION
#   CLANG_FORMAT_EXEC
#######################################
function _check_prerequisites() {
    log_info "Check if clang-format is installed"

    assert_empty CLANG_FORMAT_VERSION
    assert_empty CLANG_FORMAT_EXEC

    log_info "Check if clang-format is installed...OK"
}

#######################################
# Run clang-format on a file.
# Globals:
#   CLANG_FORMAT_EXEC
# Arguments:
#   should_fix: 'yes' if you want to fix findings, 'no' for checking only
#   target_file: Path of the file to check
# Returns:
#   0 if no finding found, 1 otherwise
#######################################
function _run_clang_format_on_file() {
    local should_fix="$1"
    local target_file="$2"

    log_info "Checking format in file: '$target_file'"

    local cmd_args=("$CLANG_FORMAT_EXEC")

    if [[ "$should_fix" == "yes" ]]; then
        cmd_args+=("-i")
    else
        cmd_args+=("--dry-run")
    fi

    cmd_args+=("$target_file")

    local return_code=0
    local result=""
    result="$(run_command "${cmd_args[@]}" 2>&1)"

    if [[ -n "$result" ]]; then
        return_code=1
        echo "$result"
    fi

    return $return_code
}

#######################################
# Find file to check.
# Globals:
# Arguments:
#   target_dir: Path of the directory to check
# Output:
#   Writes all files to check to STDOUT
#######################################
function _find_target_files() {
    local target_dir="$1"

    find "$target_dir" -type f \( -iname "*.hpp" -o -iname "*.cpp" \)
}

#######################################
# Run clang-format on a directory.
# Globals:
#   CLANG_FORMAT_EXEC
# Arguments:
#   should_fix: 'yes' if you want to fix findings, 'no' for checking only
#   target_dir: Path of the directory to check
# Returns:
#   0 if no finding found, 1 otherwise
#######################################
function _run_clang_format_on_dir() {
    local should_fix="$1"
    local target_dir="$2"

    log_info "Checking format in directory: '$target_dir'"

    local return_code=0

    mapfile -t file_paths < <(_find_target_files "$target_dir")

    for file_path in "${file_paths[@]}"; do
        _run_clang_format_on_file "$should_fix" "$file_path"
        local status=$?

        if [[ "$return_code" -eq 0 && "$status" -ne 0 ]]; then
            return_code=$status
        fi
    done

    return $return_code
}

#######################################
# Run clang-format.
# Globals:
#   CLANG_FORMAT_EXEC
# Arguments:
#   should_fix: 'yes' if you want to fix findings, 'no' for checking only
#   target_paths: All target paths to check
# Returns:
#   0 if no finding found, 1 otherwise
#######################################
function _check_format() {
    local should_fix="$1"
    shift
    local target_paths=("$@")

    local return_code=0
    local status=0

    for target_path in "${target_paths[@]}"; do
        if [[ -d "$target_path" ]]; then
            _run_clang_format_on_dir "$should_fix" "$target_path"
            status=$?

            if [[ "$return_code" -eq 0 && "$status" -ne 0 ]]; then
                return_code=$status
            fi
        else
            _run_clang_format_on_file "$should_fix" "$target_path"
            status=$?

            if [[ "$return_code" -eq 0 && "$status" -ne 0 ]]; then
                return_code=$status
            fi
        fi
    done

    return $return_code
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

    _check_format "$SHOULD_FIX" "${target_paths[@]}"
    return $?
}

main "$@"

EXIT_CODE=$?
if [[ "$EXIT_CODE" -eq 0 ]]; then
    log_info "PASSED"
else
    log_error "FAILED ($EXIT_CODE)"
fi
