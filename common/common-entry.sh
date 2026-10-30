#!/usr/bin/env bash
#
# Source      : common/entry.sh
# Dependencies: common/global/global-utils.sh
#               common/project/project-utils.sh
# Description : Entry point to access common scripts.
#

# =============================================================================
# Global Constants
# =============================================================================
G__COMMON_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
export G__COMMON_DIR

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
source "${G__COMMON_DIR}/global/global-entry.sh"

# shellcheck disable=SC1091
source "${G__COMMON_DIR}/project/project-entry.sh"
