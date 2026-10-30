#!/usr/bin/env bash
#
# Source      : common/project/project-entry.sh
# Dependencies: common/global/global-assert.sh
#               common/project/project-constants.sh
#               common/project/project-utils.sh
# Description : Entry point to access shared project scripts.
#

# =============================================================================
# Global Constants
# =============================================================================
G__COMMON_PROJECT_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
export G__COMMON_PROJECT_DIR

# =============================================================================
# Global Variables
# =============================================================================

# =============================================================================
# Private Functions
# =============================================================================

# =============================================================================
# Entry Point
# =============================================================================
# shellcheck disable=SC1091
source "${G__COMMON_PROJECT_DIR}/project-constants.sh"

# shellcheck disable=SC1091
source "${G__COMMON_PROJECT_DIR}/project-utils.sh"
