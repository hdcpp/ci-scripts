#!/usr/bin/env bash
#
# Entry point to access shared scripts.
#
# Provides common functions and variables that might be used across scripts.
#

# =====================================
# Global constants & variables
# =====================================

SCRIPTS_SHARED_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

# shellcheck disable=SC1091
source "${SCRIPTS_SHARED_DIR}/logging.sh"
# shellcheck disable=SC1091
source "${SCRIPTS_SHARED_DIR}/utils.sh"
# shellcheck disable=SC1091
source "${SCRIPTS_SHARED_DIR}/tool-versions.sh"

PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null)"
assert_empty PROJECT_DIR
export PROJECT_DIR

PROJECT_NAME="$(basename "$PROJECT_DIR")"
assert_empty PROJECT_NAME
export PROJECT_NAME

REMOTE_NAME="$(git ls-remote --get-url origin | xargs basename | cut -d'.' -f1)"
assert_empty REMOTE_NAME
export REMOTE_NAME

# =====================================
# Private functions
# =====================================

# =====================================
# Public functions
# =====================================
